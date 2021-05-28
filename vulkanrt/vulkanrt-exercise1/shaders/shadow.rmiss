#version 460
#extension GL_EXT_ray_tracing : require

layout(location = 1) rayPayloadInEXT bool isShadowed;

void main()
{
	// TODO: The miss shader means no geometry has been hit -> Geometry is visible to the light source. Set payload accordingly
}
