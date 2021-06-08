#version 460
#extension GL_EXT_ray_tracing : require
#extension GL_EXT_nonuniform_qualifier : enable

struct RayPayload {
	vec3 color;
	float distance;
	vec3 normal;
	float reflector;
};

layout(location = 0) rayPayloadInEXT RayPayload rayPayload;
layout(location = 2) rayPayloadEXT bool isShadowed;			// We use this rayPayloadEXT to remember wether the shadow ray generated an intersect or not

hitAttributeEXT vec3 attribs;

layout(binding = 0, set = 0) uniform accelerationStructureEXT topLevelAS;
layout(binding = 2, set = 0) uniform UBO 
{
	mat4 viewInverse;
	mat4 projInverse;
	vec4 lightPos;
	int vertexSize;
} ubo;
layout(binding = 3, set = 0) buffer Vertices { vec4 v[]; } vertices;
layout(binding = 4, set = 0) buffer Indices { uint i[]; } indices;

struct Vertex
{
  vec3 pos;
  vec3 normal;
  vec2 uv;
  vec4 color;
  vec4 _pad0; 
  vec4 _pad1;
};

Vertex unpack(uint index)
{
	// Unpack the vertices from the SSBO using the glTF vertex structure
	// The multiplier is the size of the vertex divided by four float components (=16 bytes)
	const int m = ubo.vertexSize / 16;

	vec4 d0 = vertices.v[m * index + 0];
	vec4 d1 = vertices.v[m * index + 1];
	vec4 d2 = vertices.v[m * index + 2];

	Vertex v;
	v.pos = d0.xyz;
	v.normal = vec3(d0.w, d1.x, d1.y);
	v.color = vec4(d2.x, d2.y, d2.z, 1.0);

	return v;
}

void main()
{
	ivec3 index = ivec3(indices.i[3 * gl_PrimitiveID], indices.i[3 * gl_PrimitiveID + 1], indices.i[3 * gl_PrimitiveID + 2]);

	Vertex v0 = unpack(index.x);
	Vertex v1 = unpack(index.y);
	Vertex v2 = unpack(index.z);

	// Interpolate normal
	const vec3 barycentricCoords = vec3(1.0f - attribs.x - attribs.y, attribs.x, attribs.y);
	vec3 normal = normalize(v0.normal * barycentricCoords.x + v1.normal * barycentricCoords.y + v2.normal * barycentricCoords.z);

	// Basic lighting
	vec3 intersectPos = gl_WorldRayOriginEXT + gl_WorldRayDirectionEXT * gl_HitTEXT;
	vec3 lightVector = ubo.lightPos.xyz - intersectPos;
	vec3 lightDir = normalize(lightVector);
	float dot_product = max(dot(lightDir, normal), 0.6);
	rayPayload.color = v0.color.rgb * vec3(dot_product);
	rayPayload.distance = gl_RayTmaxEXT;
	rayPayload.normal = normal;


	// Objects with full white vertex color are treated as reflectors
	rayPayload.reflector = ((v0.color.r == 1.0f) && (v0.color.g == 1.0f) && (v0.color.b == 1.0f)) ? 1.0f : 0.0f;

	// Ignoring a perfect reflector for shadow tests; A shadow test would only change 
	// its appearance if the light source itself is reflected. We use point lights
	// here which by definition have no area, therefor cannot be "visualized".
	// By extension their reflection cannot be "visualized" either.
	if (rayPayload.reflector == 1.0)
	{
		return;
	}

	// Casting shadow ray
	float tmin = 0.001;							// Minimum travel distance means the ray cannot re-intersect with the same primitive this closest hit shader was called for.
	float tmax = length(lightVector);			// Preventing intersects "behind" the light source.
	uint rayflags = 
		gl_RayFlagsTerminateOnFirstHitEXT |			// We only care about any intersect, as this is a visibility test.
		gl_RayFlagsOpaqueEXT |						// Intersect tests with opaque geometry only.
		gl_RayFlagsSkipClosestHitShaderEXT;			// No information about closest hit is required, only wether it exists or not.
	vec3 origin = 
		intersectPos +
		normal * 0.0001;			// Origin bias away from geometry to prevent artifacts
	isShadowed = true;
	if (dot(normal, lightDir) > 0)	// Only do shadow tests when the surface faces the light source
	{
		// Trace shadow ray and offset indices to match shadow hit/miss shader group indices
		traceRayEXT(topLevelAS, 
			rayflags, 
			0xFF,					// Cullmask, can be used to remove geometry from intersection tests.
			1,						// SBT offset and
			0,						// SBT stride are both used to select the shader to call for the result of the raycast.
			1,						// Additionally which miss shader is called can be adjusted here with this offset.
			origin,					// Ray origin in world space.
			tmin,					
			lightDir,				// The direction of the ray.
			tmax, 
			2						// Layout location index the rayPayloadEXT has been assigned to in this shader.
		);
	}
	// In case of shadow we reduce the color level and don't generate a fake specular highlight
	if (isShadowed) {
		rayPayload.color = v0.color.rgb * 0.3;
	}
}
