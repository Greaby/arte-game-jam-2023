// Made with Amplify Shader Editor v1.9.1.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Sprite"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		_Sprite_Corjn("Sprite_Corjn", 2D) = "white" {}
		_Sprite_Corjn1("Sprite_Corjn", 2D) = "white" {}
		_Sprite_Corjn2("Sprite_Corjn", 2D) = "white" {}
		_Outline_Color("Outline_Color", Color) = (0,0,0,0)
		_Float0("Float 0", Range( 0 , 0.01)) = 0
		_Float1("Float 0", Range( -0.01 , 0.01)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		
		Pass
		{
		CGPROGRAM
			
			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			uniform sampler2D _Sprite_Corjn;
			uniform float4 _Sprite_Corjn_ST;
			uniform sampler2D _Sprite_Corjn1;
			uniform float _Float0;
			uniform float4 _Outline_Color;
			uniform sampler2D _Sprite_Corjn2;
			uniform float _Float1;

			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				
				
				IN.vertex.xyz +=  float3(0,0,0) ; 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				float2 uv_Sprite_Corjn = IN.texcoord.xy * _Sprite_Corjn_ST.xy + _Sprite_Corjn_ST.zw;
				float4 tex2DNode2 = tex2D( _Sprite_Corjn, uv_Sprite_Corjn );
				float2 temp_cast_0 = (_Float0).xx;
				float2 texCoord5 = IN.texcoord.xy * float2( 1,1 ) + temp_cast_0;
				float4 blendOpSrc12 = ( tex2D( _Sprite_Corjn1, texCoord5 ) - tex2DNode2 );
				float4 blendOpDest12 = _Outline_Color;
				float2 temp_cast_1 = (_Float1).xx;
				float2 texCoord13 = IN.texcoord.xy * float2( 1,1 ) + temp_cast_1;
				float4 blendOpSrc18 = ( tex2D( _Sprite_Corjn2, texCoord13 ) - tex2DNode2 );
				float4 blendOpDest18 = _Outline_Color;
				
				fixed4 c = ( tex2DNode2 + ( tex2DNode2 - ( ( saturate( ( 1.0 - ( 1.0 - blendOpSrc12 ) * ( 1.0 - blendOpDest12 ) ) )) + ( saturate( ( 1.0 - ( 1.0 - blendOpSrc18 ) * ( 1.0 - blendOpDest18 ) ) )) ) ) );
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19103
Node;AmplifyShaderEditor.TextureCoordinatesNode;5;-1301,208.5;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-965,186.5;Inherit;True;Property;_Sprite_Corjn1;Sprite_Corjn;1;0;Create;True;0;0;0;False;0;False;-1;None;d40c191aa46654db7a426d6a1fa3aa30;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-1305.78,596.3171;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-969.7802,574.3171;Inherit;True;Property;_Sprite_Corjn2;Sprite_Corjn;2;0;Create;True;0;0;0;False;0;False;-1;None;d40c191aa46654db7a426d6a1fa3aa30;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;8;-570,276.5;Inherit;False;Property;_Outline_Color;Outline_Color;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;18;-166.5801,452.6879;Inherit;False;Screen;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;19;30.91992,136.6879;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-1714,247.5;Inherit;False;Property;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0;0.0005882353;0;0.01;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1717.08,575.6879;Inherit;False;Property;_Float1;Float 0;5;0;Create;True;0;0;0;False;0;False;0;-0.002235294;-0.01;0.01;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-944,-284.5;Inherit;True;Property;_Sprite_Corjn;Sprite_Corjn;0;0;Create;True;0;0;0;False;0;False;-1;None;d40c191aa46654db7a426d6a1fa3aa30;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;12;-265,126.5;Inherit;False;Screen;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;767,-26;Float;False;True;-1;2;ASEMaterialInspector;0;10;Sprite;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;3;1;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-544,-9.5;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;25;-555.0801,544.6879;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;258.9199,60.68787;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;481.9199,-71.31213;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
WireConnection;5;1;9;0
WireConnection;3;1;5;0
WireConnection;13;1;20;0
WireConnection;14;1;13;0
WireConnection;18;0;25;0
WireConnection;18;1;8;0
WireConnection;19;0;12;0
WireConnection;19;1;18;0
WireConnection;12;0;4;0
WireConnection;12;1;8;0
WireConnection;1;0;24;0
WireConnection;4;0;3;0
WireConnection;4;1;2;0
WireConnection;25;0;14;0
WireConnection;25;1;2;0
WireConnection;26;0;2;0
WireConnection;26;1;19;0
WireConnection;24;0;2;0
WireConnection;24;1;26;0
ASEEND*/
//CHKSM=5835803F7B5FC577F38E2473CCAD052317309F1C