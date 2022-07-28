Shader "Unlit/S_XCSky"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_TimeNormalized("TimeNormalized",Range(0,1)) = 0

		_SunBaseColor("SunBaseColor",Color) = (1,1,1,1)
		_SunStrength("SunStrength",Float) = 1
		_SunRadius("SunRadius",Float) = 1

		_SunDiskRadius("SunDiskRadius",Float) = 1
		_SunDiskStrength("SunDiskStrength",Float) = 1
		_SunDiskSolidPercent("SunDiskSolidPercent",Float) = 0.9
		_SunRimColor("SunRimColor",Color) = (1,0,0,1)

		_MoonBaseColor("MoonBaseColor", Color) = (1,1,1,1)
		[HDR]_MoonDiskTintColor("MoonDiskTintColor", Color) = (1,1,1,1)
		_MoonStrength("MoonStrength",Float) = 1
		_MoonRadius("MoonRadius",Float) = 1
		_MoonDiskRadius("MoonDiskRadius",Float) = 1
		_MoonTex("Texture", 2D) = "white" {}
		_MoonRimInnerColor("MoonRimInnerColor",Color) = (1,0,0,1)
		_MoonRimOuterColor("MoonRimOuterColor",Color) = (1,0,0,1)
		_MoonRimOuterControl1("MoonRimOuterControl1",Float) = 0.71
		_MoonRimOuterControl2("MoonRimOuterControl2",Float) = 0.988
		_MoonRimInnerControl1("MoonRimInnerControl1",Float) = 5
		_MoonRimOuterPower("MoonRimOuterPower",Float) = 80

		_CloudScale("CloudScale",Float) = 1
		_CloudStrength("CloudStrength",Float) = 1
		_CloudStrength2("CloudStrength2",Float) = 1
		_CloudPower("CloudPower",Float) = 4
		_CloudBaseColor("CloudBaseColor", Color) = (1,1,1,1)
		_CloudNightIntensity("CloudNightIntensity",Float) = 1
		_CloudDayIntensity("CloudDayIntensity",Float) = 1
    }
    SubShader
    {
        Tags {"RenderType" = "Background" }
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
				float3 direction : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.direction = mul(unity_ObjectToWorld, v.vertex).xyz - _WorldSpaceCameraPos;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

			//###########################
			static const float2x2 m = float2x2(1.6, 1.2, -1.2, 1.6);
			float2 hash(float2 p) {
				p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
				return -1.0 + 2.0*frac(sin(p)*43758.5453123);
			}

			float noise(in float2 p) {
				const float K1 = 0.366025404; // (sqrt(3)-1)/2;
				const float K2 = 0.211324865; // (3-sqrt(3))/6;
				float2 i = floor(p + (p.x + p.y)*K1);
				float2 a = p - i + (i.x + i.y)*K2;
				float2 o = (a.x > a.y) ? float2(1.0, 0.0) : float2(0.0, 1.0); //float2 of = 0.5 + 0.5*float2(sign(a.x-a.y), sign(a.y-a.x));
				float2 b = a - o + K2;
				float2 c = a - 1.0 + 2.0*K2;
				float3 h = max(0.5 - float3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
				float3 n = h * h*h*h*float3(dot(a, hash(i + 0.0)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));
				return dot(n, float3(70,70,70));
			}

			float fbm(float2 n) {
				float total = 0.0, amplitude = 0.1;
				for (int i = 0; i < 7; i++) {
					total += noise(n) * amplitude;
					n = mul(transpose(m),n);
					amplitude *= 0.4;
				}
				return total;
			}
			//######################################################

			float _TimeNormalized;

			float _SunStrength;
			float _SunRadius;
			float4 _SunBaseColor;

			float _SunDiskRadius;
			float _SunDiskStrength;
			float _SunDiskSolidPercent;
			float4 _SunRimColor;

			float _MoonStrength;
			float4 _MoonBaseColor;
			float4 _MoonDiskTintColor;
			float _MoonRadius;
			float _MoonDiskRadius;
			sampler2D _MoonTex;
			float4 _MoonTex_ST;
			float4 _MoonRimInnerColor;
			float4 _MoonRimOuterColor;
			float _MoonRimOuterControl1;
			float _MoonRimOuterControl2;
			float _MoonRimInnerControl1;
			float _MoonRimOuterPower;

			float _CloudScale;
			float _CloudStrength;
			float _CloudStrength2;
			float _CloudPower;
			float4 _CloudBaseColor;
			float _CloudNightIntensity;
			float _CloudDayIntensity;

			float remap(float x, float oldmin, float oldmax, float newmin, float newmax)
			{
				float k = (x - oldmin) / (oldmax - oldmin);
				return newmin + k * (newmax - newmin);
			}

			//https://en.wikipedia.org/wiki/Spherical_coordinate_system
			//float3 SkyPosToWorldPos(float2 pos)
			//{
			//	float PI = 3.14159;
			//	float theta = 0.5*PI*(1 - pos.y);
			//	float phi = 2 * PI*pos.x;
			//	//!!!
			//	float r = 1;
			//	return float3(
			//		r*sin(theta)*cos(phi),
			//		r*sin(theta)*sin(phi),
			//		r*cos(theta)
			//		);
			//}

			bool InSpherePos(float3 p, float3 sun, float r)
			{
				return length(p - sun) < r;
			}

			float sdBox(float3 p, float3 b)
			{
				float3 q = abs(p) - b;
				return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
			}

			float SDFBox(float3 p, float3 center, float3 bound)
			{
				//return SDFSphere(p, center, 1);
				float3 q = abs(p - center) - bound;
				return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
			}

			float SDFBoxByUVW(float3 p, float3 u, float3 v, float3 w, float3 center, float3 bound)
			{
				p = p - center;
				float3 lp;
				lp.x = dot(p, u);
				lp.y = dot(p, v);
				lp.z = dot(p, w);
				return SDFBox(lp, float3(0, 0, 0), bound);
			}

			float3 CartesianToSpherical(float3 xyz)
			{
				float PI = 3.1415926;
				float r = length(xyz);
				xyz *= 1.f / r;
				float theta = acos(xyz.z);

				float phi = atan2(xyz.y, xyz.x); //atan2 [-PI,PI]
				phi += (phi < 0) ? 2 * PI : 0;

				return float3(phi, theta, r);
			}

			bool InBoxPos(float3 p, float3 moon, float r, float moonPhi, float moonTheta, float3 u,float3 v,float3 w)
			{
				//1.球面uv，长条错误形状
				//float2 k = abs(p - moon);
				//return k.x < r&&k.y < r;

				//2.轴对称box,无法沿着轨道固定UV错误形状
				//return sdBox(p - moon, r) < 0;

				//3. 沿着轨道的正确box
				//moonPos = float3(
				//	sin(moonPhi)*cos(moonTheta),
				//	cos(moonPhi),
				//	sin(moonPhi)*sin(moonTheta)
				//	);
				
				return SDFBoxByUVW(p, u, v, w, moon, r)<0;
			}

			float4 GetSunDiskColor(float3 p, float3 sun, float r, float powerk = 2)
			{
				float3 sunDiskColor = _SunBaseColor.rgb;
				float solidPercent = _SunDiskSolidPercent;
				float a = 0;
				float disK = length(p - sun) / r;
				float3 col = sunDiskColor;
				if (disK < solidPercent)
				{
					a = 1;
				}
				else
				{
					a = (disK - solidPercent)/(1- solidPercent);
					a = 1 - a;
					a = pow(a, powerk);
					//float3 sunDiskRimColor = float3(1, 0, 0);
					//col = sunDiskRimColor;//lerp(sunDiskRimColor, col, a);
					//a = 0;
				}

				float3 sunDiskRimColor = _SunRimColor.rgb;
				col = lerp(col, sunDiskRimColor, disK);

				return float4(col, a);
			}

			float4 GetSunColor(float3 p, float3 sun, float r, float powerk = 2)
			{
				float3 sunBaseColor = _SunBaseColor.rgb;
				//float shineRadiusPercent = 0.9;
				float a = length(p - sun) / r;
				a = 1 - a;
				a = pow(a, powerk);
				float3 col = sunBaseColor;
				float sunDiskRadius = 0.1 * _SunDiskRadius;
				if (InSpherePos(p, sun, sunDiskRadius))
				{
					float4 diskColor = GetSunDiskColor(p, sun, sunDiskRadius,2);
					col += _SunDiskStrength * diskColor.rgb * diskColor.a;
				}
				return float4(col, a);
			}

			float4 GetMoonColor(float3 p, float3 moon, float r, float diskR, float moonPhi, float moonTheta,float3 udir, float3 vdir, float3 wdir, float powerk = 2)
			{
				float3 moonColor = _MoonStrength * _MoonBaseColor;
				float3 diskColor = 0;
				float a = 1;
				float diska = 0;
				
				a = length(p - moon) / r;
				a = 1 - a;
				a = pow(a, powerk);

				if (InBoxPos(p, moon, diskR, moonPhi, moonTheta, udir, vdir, wdir))
				{
					float3 local = p - moon;

					float u = dot(local, udir) / (diskR);
					float v = dot(local, vdir) / (diskR);
					//[-1,1]=>[0,1]
					u = (u + 1)*0.5;
					v = (v + 1)*0.5;
					float4 moonDiskColor = tex2D(_MoonTex, float2(u, v));

					//inner
					float disK = 0;
					disK = saturate(length(p - moon) / diskR);
					disK = pow(disK, _MoonRimInnerControl1);
					float3 moonDiskRimColor = _MoonRimInnerColor.rgb;
					moonDiskColor.rgb = lerp(moonDiskColor, moonDiskRimColor, disK);

					moonColor = lerp(moonColor, moonDiskColor.rgb * _MoonDiskTintColor, moonDiskColor.a * _MoonDiskTintColor.a);
					a = lerp(a, moonDiskColor.a+ disK, moonDiskColor.a* _MoonDiskTintColor.a);
				}

				//ouer
				float outDis = length(p - moon) - diskR* _MoonRimOuterControl1;
				if (outDis > 0)
				{
					float disK = pow(saturate(_MoonRimOuterControl2 - outDis), _MoonRimOuterPower);
					float3 moonDiskRimColor = _MoonRimOuterColor.rgb;

					moonColor += _MoonStrength * moonDiskRimColor.rgb * disK * _MoonDiskTintColor.a;
					a += disK * _MoonDiskTintColor.a;
				}

			
				float3 col = moonColor;
				return float4(col, a);
			}

			inline float SubsurfaceScattering(float3 viewDir, float3 lightDir, float3 normalDir,
				float frontSubsurfaceDistortion, float backSubsurfaceDistortion, float frontSssIntensity)
			{
				// 分别计算正面和反面的次表面散射
				float3 frontLitDir = normalDir * frontSubsurfaceDistortion - lightDir;
				float3 backLitDir = normalDir * backSubsurfaceDistortion + lightDir;

				float frontSSS = saturate(dot(viewDir, -frontLitDir));
				float backSSS = saturate(dot(viewDir, -backLitDir));
				// 最后叠加到一起
				float result = saturate(frontSSS * frontSssIntensity + backSSS);

				return result;
			}

			//https://www.shadertoy.com/view/stBcW1

			// License: MIT OR CC-BY-NC-4.0, author: mercury, found: https://mercury.sexy/hg_sdf/
			float2 mod2(inout float2 p, float2 size) {
				float2 c = floor((p + size * 0.5) / size);
				p = fmod(p + size * 0.5, size) - size * 0.5;
				return c;
			}

			// License: Unknown, author: Unknown, found: don't remember
			float2 hash2(float2 p) {
				p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
				return frac(sin(p)*43758.5453123);
			}

			// License: Unknown, author: Unknown, found: don't remember
			float tanh_approx(float x) {
				//  Found this somewhere on the interwebs
				//  return tanh(x);
				float x2 = x * x;
				return clamp(x*(27.0 + x2) / (27.0 + 9.0*x2), -1.0, 1.0);
			}

			// License: CC BY-NC-SA 3.0, author: Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick), found: https://www.shadertoy.com/view/Mt3GW2
			float3 blackbody(float Temp) {
				float3 col = float3(255, 255, 255);
				col.x = 56100000. * pow(Temp, (-3. / 2.)) + 148.;
				col.y = 100.04 * log(Temp) - 623.6;
				if (Temp > 6500.) col.y = 35200000. * pow(Temp, (-3. / 2.)) + 184.;
				col.z = 194.18 * log(Temp) - 1448.6;
				col = clamp(col, 0., 255.) / 255.;
				if (Temp < 1000.) col *= Temp / 1000.;
				return col;
			}

#define LAYERS            5.0
			float3 stars(float3 ro, float3 rd, float2 sp, float hh) {
				float3 col = float3(0, 0, 0);
				float PI = 3.1415926;
				const float m = LAYERS;
				hh = tanh_approx(20.0*hh);

				for (float i = 0.0; i < m; ++i) {
					float2 pp = sp + 0.5*i;
					float s = i / (m - 1.0);
					float2 dim = lerp(0.05, 0.003, s)*PI;
					float2 np = mod2(pp, dim);
					float2 h = hash2(np + 127.0 + i);
					float2 o = -1.0 + 2.0*h;
					float y = sin(sp.x);
					pp += o * dim*0.5;
					pp.y *= y;
					float l = length(pp);

					float h1 = frac(h.x*1667.0);
					float h2 = frac(h.x*1887.0);
					float h3 = frac(h.x*2997.0);

					float3 scol = lerp(8.0*h2, 0.25*h2*h2, s)*blackbody(lerp(3000.0, 22000.0, h1*h1));

					float3 ccol = col + exp(-(lerp(6000.0, 2000.0, hh) / lerp(2.0, 0.25, s))*max(l - 0.001, 0.0))*scol;
					col = h3 < y ? ccol : col;
				}

				return col;
			}

			//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			float4 frag (v2f i) : SV_Target
            {
				float time = _Time.y * 0.1;//_TimeNormalized
				time = _TimeNormalized;
				float samplev = i.uv.y;
				if (samplev < 0)
				{
					return 0;
				}
				//remap 0-1 to 0.1-0.96
				samplev = remap(samplev,0,1,0.1,0.96);			
				float2 sampleuv = float2(time, samplev);
                // sample the texture
				float4 skyColor = tex2D(_MainTex, sampleuv);
                fixed4 col = skyColor;

				//-- Utility variable 
				time = frac(time);
				float intensityFromTime = -pow(time - 0.5, 2) + 1 + lerp(-0.75 + 0.1, 0, 1 - abs(time - 0.5) / 0.5);
				float lightInten = skyColor.r*0.3 + skyColor.g*0.6 + skyColor.b*0.1;
				float3 pos = normalize(i.direction);
				float3 p2 = pos;
				p2.xz *= lerp(1, 2, 1 - p2.y);
				//__

				//--star
				float2 sp = CartesianToSpherical(pos).yx;
				float3 starColor = stars(0, pos, sp, 0);
				float starIntensity = pow(1 - intensityFromTime, 2);

				col.rgb += stars(0, pos, sp, 0) * pow(1- intensityFromTime,2);
				//__

				//--sunPos
				float PI = 3.1415926;
				float sunTheta = PI/4; //wei(jingwei):range(0,2pi) ,oribit's 'rotation', don't move runtime
				float sunPhi = -PI + 2 * PI*time;  //jing(jingwei):range(-pi,pi) , time, sun's position on oribit,move in time
				float3 sunPos = normalize(float3(1, 1, 0));
				//sphere coord changed by unity coord
				sunPos = float3(
						sin(sunPhi)*cos(sunTheta),				
						cos(sunPhi),
						sin(sunPhi)*sin(sunTheta)
						);
				float sunRadius = 0.1 * _SunRadius;
				//__
				//--sunDraw
				if (InSpherePos(pos, sunPos,sunRadius))
				{
					float4 sunColor = _SunStrength * GetSunColor(pos, sunPos, sunRadius);
					col.rgb = lerp(col.rgb, sunColor.rgb, sunColor.a*_SunBaseColor.a);
				}
				//__

				//--moonPos
				float moonTheta = sunTheta; //wei(jingwei):range(0,2pi) ,oribit's 'rotation', don't move runtime
				float moonPhi = 2 * PI*time;  //jing(jingwei):range(-pi,pi) , time, sun's position on oribit,move in time
				float3 moonPos = normalize(float3(1, 1, 0));
				//sphere coord changed by unity coord
				moonPos = float3(
					sin(moonPhi)*cos(moonTheta),
					cos(moonPhi),
					sin(moonPhi)*sin(moonTheta)
					);
				float moonRadius = 0.1 * _MoonRadius;
				float moonDiskRadius = 0.1 * _MoonDiskRadius;
				//对phi求导(已经保证了normalize)
				float3 moon_u = float3(
					cos(moonPhi)*cos(moonTheta),
					-sin(moonPhi),
					cos(moonPhi)*sin(moonTheta)
					);
				//已经保证了normalize
				float3 moon_w = -moonPos;
				float3 moon_v = cross(moon_u, moon_w);
				//__
				//--moonDraw
				if (InSpherePos(pos, moonPos, moonRadius))//InBoxPos(pos, moonPos, moonRadius, moonPhi, moonTheta, moon_u, moon_v, moon_w))
				{
					float4 moonColor = GetMoonColor(pos, moonPos, moonRadius, moonDiskRadius, moonPhi, moonTheta, moon_u, moon_v, moon_w);
					col.rgb = lerp(col.rgb, moonColor.rgb, moonColor.a*_MoonBaseColor.a);
				}
				//__

				//merge from https://www.shadertoy.com/view/WdXBW4
				//warp coord, ensure a large change of xz,when y is small
				float cloudtime = time * 5;
				float cloudscale = _CloudScale;
				//p2.xz += cloudtime;
				float2 p = (p2.xz + 1) / 2;

				float2 iResolution = float2(1, 1);
				float2 uv = p * float2(iResolution.x / iResolution.y, 1.0);
				float q = fbm(uv * cloudscale * 0.5);
				
				//ridged noise shape
				float r = 0.0;
				uv *= cloudscale;
				uv -= q - cloudtime;
				float weight = 0.8;
				for (int i1 = 0; i1 < 8; i1++) {
					r += abs(weight*noise(uv));
					uv = mul(m, uv) + cloudtime;
					weight *= 0.7;
				}

				//noise shape
				float f = 0.0;
				uv = p * float2(iResolution.x / iResolution.y, 1.0);
				uv *= cloudscale;
				uv -= q -cloudtime;
				weight = 0.7;
				for (int iter = 0; iter < 8; iter++) {
					f += weight * noise(uv);
					uv = mul(m, uv) + cloudtime;
					weight *= 0.6;
				}

				f *= r + f;
				//___

				float3 cloudBaseColor = _CloudBaseColor;
				//??? need to K
				float3 cloudColor = cloudBaseColor * pow(intensityFromTime,2) ;

				float cloudIntensity = abs((f+1)*0.5);
				cloudIntensity *= _CloudStrength;
				cloudIntensity = pow(cloudIntensity, _CloudPower);
				//far vanish
				cloudIntensity *= lerp(0, 1, pow(p2.y,3));			
				cloudIntensity *= intensityFromTime;
				cloudIntensity *= lerp(1,lightInten, intensityFromTime);
				{
					float frontSubsurfaceDistortion = 0.1;
					float backSubsurfaceDistortion = 0.9;
					float frontSssIntensity = 1;
					float sss = SubsurfaceScattering(normalize(i.direction), sunPos, normalize(float3(0,1,0)), frontSubsurfaceDistortion, backSubsurfaceDistortion, frontSssIntensity);
					cloudIntensity *= lerp(1, sss, intensityFromTime);
				}
				cloudIntensity = smoothstep(0, 1, cloudIntensity);

				cloudIntensity *= lerp(0.1*_CloudNightIntensity, 0.1*_CloudDayIntensity, pow(intensityFromTime, 2))*(_CloudStrength2 + 10 * pow(1 - intensityFromTime,1));
				cloudIntensity = saturate(cloudIntensity);
				col.rgb = lerp(col.rgb, cloudColor, cloudIntensity);
				//cloudIntensity *= lerp(0.1, 0.7, pow(intensityFromTime, 2))*(_CloudStrength2 + 10 * (1 - intensityFromTime));
				col.rgb += cloudIntensity * cloudColor;
				
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
