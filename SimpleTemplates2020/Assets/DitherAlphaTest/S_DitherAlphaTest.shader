// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/DitherAlphaTest"
{
	Properties
	{
		_Color("Main Tint",Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_DitherTex("_DitherTex", 2D) = "white" {}
		_Cutoff("DitherAlpha",Range(0,1)) = 0.5
	}
		SubShader
		{
			Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
			Pass
			{
				Tags{"LightMode" = "ForwardBase"}
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "Lighting.cginc"

				fixed4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;

				fixed _Cutoff;

				struct a2v
				{
					float4 vertex : POSITION;
					float3 normal:NORMAL;
					float4 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float3 worldNormal:TEXCOORD0;
					float3 worldPos:TEXCOORD1;
					float2 uv:TEXCOORD2;
					float3 viewPos:TEXCOORD3;
					float4 screenPos:TEXCOORD4;
				};

				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
					o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
					o.screenPos = ComputeScreenPos(UnityObjectToClipPos(v.vertex));
					return o;

				}

				fixed4 frag(v2f i) : SV_Target
				{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed4 texColor = tex2D(_MainTex,i.uv);
					float2 duv = i.screenPos.xy / i.screenPos.w;
					int2 inx = duv * _ScreenParams.xy;
					float maskAlpha = 1;
					if (_Cutoff < 0.5)
					{
						float k = (0.5 - _Cutoff) * 2;
						int modNum = (int)lerp(2.0, 8.0, k);
						maskAlpha *= inx.x%modNum == 0 && inx.y % modNum == 0;
	
						//other pattern
						//if ((abs(inx.x % 4) == abs(inx.y % 4))&& inx.y % 4 % 2 ==0)
						//{
						//	//maskAlpha = 0;
						//}
						//
						//if ((abs(inx.x % 6) == abs(inx.y % 6)) && inx.y % 6 % 3 == 0)
						//{
						//	//maskAlpha = 0;
						//}
						//
						//if ((abs(inx.x % 10) == abs(inx.y % 10)) && inx.y % 10 % 5 == 0)
						//{
						//	//maskAlpha = 0;
						//}
					}
					else
					{
						float k = (_Cutoff - 0.5) * 2;
						int modNum = (int)lerp(2.0, 8.0, k);
						maskAlpha *= inx.x%modNum == 0 && inx.y % modNum == 0;
						maskAlpha = 1 - maskAlpha;
					}

					clip(maskAlpha - 0.5); 

					fixed3 albedo = texColor.rgb*_Color.rgb;
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz*albedo;
					fixed3 diffuse = _LightColor0.rgb*albedo*max(0,dot(worldNormal,worldLightDir));
					return fixed4(ambient + diffuse,1.0);
				}
				ENDCG
			}
		}
			Fallback "Transparent/Cutout/VertexLit"
}