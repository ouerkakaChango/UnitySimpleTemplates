Shader "Unlit/S_QuadCloud"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_TimeNormalized("TimeNormalized",Range(0,1)) = 0
    }
    SubShader
    {
		Tags{"Queue" = "Transparent"  "IgnoreProjection" = "True" "RenderType" = "Transparent" }
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
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
                float4 vertex : SV_POSITION;
				float4 wpos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _TimeNormalized;

            v2f vert (appdata v)
            {
                v2f o;
				o.wpos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			


            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				float time = _Time.y * 0.1;//_TimeNormalized
				time = _TimeNormalized;
				//???
				float PI = 3.1415926;
				float sunTheta = PI / 4; //wei(jingwei):range(0,2pi) ,oribit's 'rotation', don't move runtime
				float sunPhi = -PI + 2 * PI*time;  //jing(jingwei):range(-pi,pi) , time, sun's position on oribit,move in time
				float3 sunPos = float3(
					sin(sunPhi)*cos(sunTheta),
					cos(sunPhi),
					sin(sunPhi)*sin(sunTheta)
					);
				//___
				float3 pos = i.wpos.xyz;
				float intensity = saturate(dot(pos, sunPos));
				col *= intensity;
                return col;
            }
            ENDCG
        }
    }
}
