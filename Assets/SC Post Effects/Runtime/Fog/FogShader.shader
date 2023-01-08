Shader "Hidden/SC Post Effects/Fog"
{
	HLSLINCLUDE

	#define REQUIRE_DEPTH
	#include "../../Shaders/Pipeline/Pipeline.hlsl"
	#include "../../Shaders/Blurring.hlsl"
	#include "Fog.hlsl"

	//Light scattering
	TEXTURE2D(_BloomTex);
	TEXTURE2D(_AutoExposureTex);

	float  _SampleScale;
	float4 _Threshold; // x: threshold value (linear), y: threshold - knee, z: knee * 2, w: 0.25 / knee
	float4 _ScatteringParams; // x: Sample scale y: Intensity z: 0 w: Itterations

	half4 Prefilter(half4 color, float2 uv)
	{
		half autoExposure = SAMPLE_TEXTURE2D(_AutoExposureTex, Clamp, uv).r;
		color *= autoExposure;
		//color = min(_Params.x, color); // clamp to max
		color = QuadraticThreshold(color, _Threshold.x, _Threshold.yzw);
		return color;
	}

	half4 FragPrefilter(Varyings input) : SV_Target
	{
		half4 color = BoxFilter4(TEXTURE2D_ARGS(_MainTex, Clamp), UV, _MainTex_TexelSize.xy, 1);
		return Prefilter(SafeHDR(color), UV);
	}

		half4 FragDownsample(Varyings input) : SV_Target
	{
		half4 color = BoxFilter4(TEXTURE2D_ARGS(_MainTex, Clamp), UV, _MainTex_TexelSize.xy, 1);
		return color;
	}

		half4 Combine(half4 bloom, float2 uv)
	{
		half4 color = SAMPLE_TEXTURE2D(_BloomTex, Clamp, uv);
		return bloom + color;
	}

	half4 FragUpsample(Varyings input) : SV_Target
	{
		half4 bloom = UpsampleBox(TEXTURE2D_ARGS(_MainTex, Clamp), UV, _MainTex_TexelSize.xy, _SampleScale);
		return Combine(bloom, UV);
	}

	float4 ComputeFog(float3 worldPos, float3 worldNormal, float2 screenPos, float depth, float time)
	{
		#if !defined(SHADERGRAPH_PREVIEW)
		float linearDepth = LINEAR_DEPTH(depth);

		float skyboxMask = 1;
		if (linearDepth > 0.99) skyboxMask = 0;

		//Same as GetFogDensity but distance/fog calculated separately
		float g = _DistanceParams.x;
		float distanceFog = GetFogDistance(worldPos, linearDepth);
		g += distanceFog;
		float heightFog = GetFogHeight(worldPos, time, skyboxMask);
		g += heightFog;
		float fogFactor = ComputeFactor(max(0.0, g));

		//Skybox influence
		if (linearDepth > 0.99) fogFactor = lerp(1.0, fogFactor, _SkyboxParams.x);

		//Color
		float4 fogColor = GetFogColor(screenPos, worldPos, distanceFog);

		fogColor.a = fogFactor;

		return fogColor;
		#else
		return 1.0
		#endif
	}

	float4 FragBlend(Varyings input) : SV_Target
	{
		UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

		half4 screenColor = ScreenColor(UV);

		float depth = SAMPLE_DEPTH(UV);

		float3 worldPos = GetWorldPosition(UV, depth);
		
		//Alpha is density, do not modify
		float4 fogColor = ComputeFog(worldPos, WorldViewDirection, UV, depth, _Time.y);

		//Linear blend
		float3 blendedColor = lerp(fogColor.rgb, screenColor.rgb, fogColor.a);

		//Keep alpha channel for FXAA
		return float4(blendedColor.rgb, screenColor.a);
	}


	float4 FragBlendScattering(Varyings input) : SV_Target
	{
		UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

		half4 screenColor = ScreenColor(UV);
		half4 bloom = SAMPLE_TEXTURE2D(_BloomTex, Clamp, UV) * _ScatteringParams.y;

		float depth = SAMPLE_DEPTH(UV);

		float3 worldPos = GetWorldPosition(UV, depth);

		//Alpha is density, do not modify
		float4 fogColor = ComputeFog(worldPos, WorldViewDirection, UV, depth, _Time.y);

		fogColor.rgb = fogColor.rgb + bloom.rgb;

		screenColor.rgb = lerp(bloom.rgb, screenColor.rgb, fogColor.a);

		//Linear blend
		float3 blendedColor = lerp(fogColor.rgb, screenColor.rgb, fogColor.a);

		//Keep alpha channel for FXAA
		return float4(blendedColor.rgb, screenColor.a);
	}

	ENDHLSL

	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass //0
		{
			Name "Fog: Light Scattering Prefilter"
			HLSLPROGRAM
			#pragma exclude_renderers gles
			
			#pragma vertex Vert
			#pragma fragment FragPrefilter
			ENDHLSL
		}

		Pass //1
		{
			Name "Fog: Light Scattering Downsample"
			HLSLPROGRAM
			#pragma exclude_renderers gles
			
			#pragma vertex Vert
			#pragma fragment FragDownsample
			ENDHLSL
		}
		Pass //2
		{
			Name "Fog: Light Scattering Upsample"
			HLSLPROGRAM
			#pragma exclude_renderers gles
			
			#pragma vertex Vert
			#pragma fragment FragUpsample
			ENDHLSL
		}
		Pass //3
		{
			Name "Fog: Composite"
			HLSLPROGRAM
			#pragma multi_compile_vertex _ _USE_DRAW_PROCEDURAL
			#pragma exclude_renderers gles

			#pragma vertex Vert
			#pragma fragment FragBlend
			ENDHLSL
		}
		Pass //4
		{
			Name "Fog: Light Scattering Composite"
			HLSLPROGRAM
			#pragma exclude_renderers gles
			
			#pragma vertex Vert
			#pragma fragment FragBlendScattering
			ENDHLSL
		}
	}
}