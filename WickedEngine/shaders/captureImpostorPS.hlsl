#define OBJECTSHADER_LAYOUT_COMMON
#include "objectHF.hlsli"

struct ImpostorOutput
{
	float4 color : SV_Target0;
	float4 normal : SV_Target1;
	float4 surface : SV_Target2;
};

ImpostorOutput main(PixelInput input)
{
	float4 color;
	[branch]
	if (GetMaterial().uvset_baseColorMap >= 0)
	{
		const float2 UV_baseColorMap = GetMaterial().uvset_baseColorMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		color = texture_basecolormap.Sample(sampler_objectshader, UV_baseColorMap);
	}
	else
	{
		color = 1;
	}
	color *= GetMaterial().baseColor /** input.color*/;
	clip(color.a - GetMaterial().alphaTest);

	float3 N = normalize(input.nor);
	float3 P = input.pos3D;

	float3x3 TBN = compute_tangent_frame(N, P, input.uvsets.xy);

	[branch]
	if (GetMaterial().uvset_normalMap >= 0)
	{
		float3 bumpColor;
		NormalMapping(input.uvsets, N, TBN, bumpColor);
	}

	float4 surfaceMap = 1;
	[branch]
	if (GetMaterial().uvset_surfaceMap >= 0)
	{
		const float2 UV_surfaceMap = GetMaterial().uvset_surfaceMap == 0 ? input.uvsets.xy : input.uvsets.zw;
		surfaceMap = texture_surfacemap.Sample(sampler_objectshader, UV_surfaceMap);
	}

	float4 surface;
	surface.r = surfaceMap.r;
	surface.g = GetMaterial().roughness * surfaceMap.g;
	surface.b = GetMaterial().metalness * surfaceMap.b;
	surface.a = GetMaterial().reflectance * surfaceMap.a;

	ImpostorOutput output;
	output.color = color;
	output.normal = float4(N * 0.5f + 0.5f, 1);
	output.surface = surface;
	return output;
}

