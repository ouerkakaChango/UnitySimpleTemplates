Shader "Unlit/S_CopyDepth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float4 extra : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.extra.x = o.vertex.z / o.vertex.w;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

			struct fragOut {
				float depth : DEPTH;
			};

			fragOut frag (v2f i)
            {
				fragOut tOut;
				tOut.depth = tex2D(_MainTex, i.uv).x;
				return tOut;
            }
            ENDCG
        }
    }
}
