// Made with Amplify Shader Editor v1.9.1.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "__Corjn__/PBR_Retro_Shader"
{
	Properties
	{
		[Toggle(_RETROOVERCAMERA_ON)] _RetroOverCamera("RetroOverCamera", Float) = 0
		[Toggle(_RETRO_ON)] _retro("retro", Float) = 0
		_GeoRes("GeoRes", Float) = 0
		_GeoRes_2("GeoRes_2", Float) = 0
		[HDR]_Color0("Color 0", Color) = (1,1,1,0)
		[HDR]_Color1("Color 1", Color) = (0,0,0,0)
		_Float1("Float 1", Float) = 0
		_Float3("Float 1", Float) = 0
		_Shadow_Strenght("Shadow_Strenght", Range( 0 , 1)) = 0
		_Float5("Float 5", Range( 0 , 1)) = 0
		_Float6("Float 5", Range( 0 , 1)) = 0
		_Float7("Float 5", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _RETRO_ON
		#pragma multi_compile_local __ _RETROOVERCAMERA_ON
		struct Input
		{
			float4 screenPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _GeoRes;
		uniform float _GeoRes_2;
		uniform float _Float1;
		uniform float _Float3;
		uniform float _Float5;
		uniform float _Float6;
		uniform float _Float7;
		uniform float4 _Color0;
		uniform float4 _Color1;
		uniform float _Shadow_Strenght;


		float2 voronoihash42( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi42( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash42( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = max(abs(r.x), abs(r.y));
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return F2;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			#ifdef _RETROOVERCAMERA_ON
				float3 staticSwitch14 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos , 0.0 ) ).xyz;
			#else
				float3 staticSwitch14 = ase_vertex3Pos;
			#endif
			float mulTime44 = _Time.y * _Float3;
			float time42 = mulTime44;
			float2 voronoiSmoothId42 = 0;
			float2 coords42 = v.texcoord.xy * _Float1;
			float2 id42 = 0;
			float2 uv42 = 0;
			float fade42 = 0.5;
			float voroi42 = 0;
			float rest42 = 0;
			for( int it42 = 0; it42 <2; it42++ ){
			voroi42 += fade42 * voronoi42( coords42, time42, id42, uv42, 0,voronoiSmoothId42 );
			rest42 += fade42;
			coords42 *= 2;
			fade42 *= 0.5;
			}//Voronoi42
			voroi42 /= rest42;
			float lerpResult59 = lerp( _GeoRes , _GeoRes_2 , voroi42);
			float3 temp_output_10_0 = ( floor( ( staticSwitch14 * lerpResult59 ) ) / lerpResult59 );
			#ifdef _RETROOVERCAMERA_ON
				float3 staticSwitch8 = mul( float4( temp_output_10_0 , 0.0 ), UNITY_MATRIX_IT_MV ).xyz;
			#else
				float3 staticSwitch8 = temp_output_10_0;
			#endif
			#ifdef _RETRO_ON
				float3 staticSwitch2 = staticSwitch8;
			#else
				float3 staticSwitch2 = float3( 0,0,0 );
			#endif
			v.vertex.xyz = staticSwitch2;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float smoothstepResult77 = smoothstep( _Float5 , _Float6 , ase_screenPosNorm.y);
			float clampResult63 = clamp( 0.0 , 0.0 , 1.0 );
			float4 lerpResult34 = lerp( _Color0 , _Color1 , clampResult63);
			float4 lerpResult72 = lerp( ( lerpResult34 * ase_lightAtten ) , lerpResult34 , _Shadow_Strenght);
			c.rgb = lerpResult72.rgb;
			c.a = ( smoothstepResult77 * _Float7 );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19103
Node;AmplifyShaderEditor.RangedFloatNode;61;-1479.716,-162.1625;Inherit;False;Property;_Float3;Float 1;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1;-2545.703,622.0095;Inherit;False;1839.214;595.8164;Comment;14;22;20;15;14;13;10;9;8;7;5;4;2;59;60;Retro;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1215.811,-96.56689;Inherit;False;Property;_Float1;Float 1;14;0;Create;True;0;0;0;False;0;False;0;1.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-1247.811,-305.5669;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;44;-1247.811,-170.5669;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;13;-2523.266,839.8766;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.MVMatrixNode;5;-2513.935,687.2446;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.VoronoiNode;42;-874.811,-191.5669;Inherit;True;0;3;1;1;2;False;4;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RangedFloatNode;60;-2268.716,1047.838;Float;False;Property;_GeoRes_2;GeoRes_2;7;0;Create;True;0;0;0;False;0;False;0;-27.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-2356.392,686.4706;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;14;-2214.757,718.6425;Float;False;Property;_RetroOverCamera;RetroOverCamera;4;0;Create;True;0;0;0;False;0;False;1;0;1;True;PIXELSNAP_ON;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;59;-2039.716,968.8375;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1933.536,772.9784;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-852.811,165.4331;Inherit;False;Property;_Float2;Float 2;17;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-851.811,83.43311;Inherit;False;Property;_Float0;Float 0;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;9;-1793.138,782.6796;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;46;-581.811,-42.56689;Inherit;True;Remap To 0-1;-1;;1;;0;0;0
Node;AmplifyShaderEditor.InverseTranspMVMatrixNode;4;-1821.255,1115.524;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;10;-1661.801,787.3766;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;35;-1579.313,-95.4859;Inherit;False;Property;_Color0;Color 0;12;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;37;-1332.811,151.4331;Inherit;False;Property;_Color1;Color 1;13;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;63;-320.3916,-45.40332;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;47;-525.811,169.4331;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1506.687,890.5875;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;34;-295.313,-216.4859;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;68;-396.8477,471.5894;Inherit;True;Property;_Blue_Noise2;Blue_Noise;11;0;Create;True;0;0;0;False;0;False;None;039004ec2fad19949bfc60fa90b758a6;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.StaticSwitch;8;-1370.461,725.4025;Float;False;Property;_RetroOverCamera;RetroOverCamera;4;0;Create;True;0;0;0;False;0;False;1;0;1;True;PIXELSNAP_ON;Toggle;2;Key0;Key1;Reference;14;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-120.313,136.5141;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-453.2657,250.2932;Inherit;False;Property;_Shadow_Strenght;Shadow_Strenght;20;0;Create;True;0;0;0;False;0;False;0;0.052;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-470.3477,382.59;Inherit;False;Property;_Global_Alpha;Global_Alpha;9;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-877.313,285.5141;Inherit;False;Property;_Albedo_Intensity;Albedo_Intensity;10;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;32;-1221.313,-491.4859;Inherit;False;Property;_Tiling;Tiling;8;0;Create;True;0;0;0;False;0;False;0,0;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;26;-100.8062,596.4084;Inherit;False;Property;_Metallic;Metallic;2;0;Create;True;0;0;0;False;0;False;0;0.7528837;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;2;-876.42,708.672;Float;False;Property;_retro;retro;5;0;Create;True;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;25;-771.2829,403.4257;Inherit;False;Property;_Color;Color;1;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.2176376,0.2176376,0.2176376,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;67;-1916.701,240.3081;Inherit;False;Property;_Float4;Float 4;19;0;Create;True;0;0;0;False;0;False;0;4.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;69;-153.8477,349.59;Inherit;False;2;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-110.3347,684.2823;Inherit;False;Property;_Smoothness;Smoothness;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;64;-1407.701,328.3081;Inherit;True;Property;_Dessin_Trames;Dessin_Trames;18;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;66;-1690.701,291.3081;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;62;-1596.716,-365.1625;Inherit;False;Triplanar_Corjn with Jason stochastic;-1;;3;;0;0;0
Node;AmplifyShaderEditor.LerpOp;72;54.73425,163.2932;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-2273.917,980.4293;Float;False;Property;_GeoRes;GeoRes;6;0;Create;True;0;0;0;False;0;False;0;28.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;30;-963.313,-424.4859;Inherit;True;Spherical;World;False;Albedo;_Albedo;white;0;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;75;160.3806,-260.9922;Float;True;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;77;449.3806,-72.99219;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;87.38062,-78.39217;Inherit;False;Property;_Float5;Float 5;21;0;Create;True;0;0;0;False;0;False;0;0.09411765;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1014.99,2.001732;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;__Corjn__/PBR_Retro_Shader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;709.3806,19.00781;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;117.3806,18.00781;Inherit;False;Property;_Float6;Float 5;22;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;381.3806,77.00781;Inherit;False;Property;_Float7;Float 5;23;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
WireConnection;44;0;61;0
WireConnection;42;0;41;0
WireConnection;42;1;44;0
WireConnection;42;2;43;0
WireConnection;15;0;5;0
WireConnection;15;1;13;0
WireConnection;14;1;13;0
WireConnection;14;0;15;0
WireConnection;59;0;7;0
WireConnection;59;1;60;0
WireConnection;59;2;42;0
WireConnection;20;0;14;0
WireConnection;20;1;59;0
WireConnection;9;0;20;0
WireConnection;10;0;9;0
WireConnection;10;1;59;0
WireConnection;22;0;10;0
WireConnection;22;1;4;0
WireConnection;34;0;35;0
WireConnection;34;1;37;0
WireConnection;34;2;63;0
WireConnection;8;1;10;0
WireConnection;8;0;22;0
WireConnection;29;0;34;0
WireConnection;29;1;47;0
WireConnection;2;0;8;0
WireConnection;69;0;70;0
WireConnection;69;1;68;0
WireConnection;64;1;66;0
WireConnection;66;0;67;0
WireConnection;72;0;29;0
WireConnection;72;1;34;0
WireConnection;72;2;73;0
WireConnection;30;3;32;0
WireConnection;77;0;75;2
WireConnection;77;1;74;0
WireConnection;77;2;78;0
WireConnection;0;9;79;0
WireConnection;0;13;72;0
WireConnection;0;11;2;0
WireConnection;79;0;77;0
WireConnection;79;1;80;0
ASEEND*/
//CHKSM=15CC49138B72A997888E683E3E17EE1AF7D46EBE