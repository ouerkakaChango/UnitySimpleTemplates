// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

#pragma target 3.0

#include "Lighting.cginc"
#include "UnityCG.cginc"
#include "AutoLight.cginc"

struct v2f
{
    float4 pos: SV_POSITION;
    half4 uv: TEXCOORD0;
    float3 worldNormal: TEXCOORD1;
    float3 worldPos: TEXCOORD2;
	float3 worldTangent: TEXCOORD3;
	half4 uv2: TEXCOORD4;
	//LIGHTING_COORDS(4, 5)
};

fixed4 _Color;
fixed4 _Specular;
half _Shininess;

sampler2D _MainTex;
half4 _MainTex_ST;
sampler2D _FurTex;
half4 _FurTex_ST;

//???
sampler2D _DirTex;
half4 _DirTex_ST;
float _DirStrength;
float _AnisoRoughness;
float4 _AnisoSpecular;
float _AnisoIntensity;
//__

fixed _FurLength;
fixed _FurDensity;
fixed _FurThinness;
fixed _FurShading;

//float4 _ForceGlobal;
float4 _ForceLocal;

fixed4 _RimColor;
half _RimPower;

v2f vert_surface(appdata_tan v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	o.worldTangent = 0;
    return o;
}

v2f vert_base(appdata_tan v)
{
    v2f o;
    float3 P = v.vertex.xyz + v.normal * _FurLength * FURSTEP;
	float3 dir_tan = tex2Dlod(_DirTex, float4(v.texcoord.xy, 0, 0)).rgb;
	//???
	//if (v.texcoord.x < 0.5)
	//{
	//	dir_tan = normalize(float3(1, 1, 0));
	//}
	//else
	//{
	//	dir_tan = normalize(float3(-1, 1, 0));
	//}
	dir_tan = normalize(float3(0, 1, 0));
	float3 bitangent = cross(v.normal, v.tangent);
	float3 dir_obj = dir_tan.x * v.tangent + dir_tan.y*v.normal + dir_tan.z * bitangent;
	float4 forceGlobal = mul(unity_ObjectToWorld, float4(dir_obj,1));
	//float4 forceGlobal = mul(unity_ObjectToWorld, v.tangent);
	//float4 forceGlobal = 0;
    P += clamp(mul(unity_WorldToObject, forceGlobal).xyz + _ForceLocal.xyz, -1, 1) * pow(FURSTEP, 3) * _FurLength;
    o.pos = UnityObjectToClipPos(float4(P, 1.0));
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.texcoord, _FurTex);
	o.uv2.xy = TRANSFORM_TEX(v.texcoord, _DirTex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	o.worldTangent = mul(unity_ObjectToWorld, v.tangent).xyz;
    return o;
}

fixed4 frag_surface(v2f i): SV_Target
{
    
    fixed3 worldNormal = normalize(i.worldNormal);
    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
    fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    fixed3 worldHalf = normalize(worldView + worldLight);
    
    fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight));
    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess);

    fixed3 color = ambient + diffuse + specular*0;
    
    return fixed4(color, 1.0);
}

inline half LightAtten(half3 pos)
{
	half atten = 1;

#if defined(POINT)
	float3 lightCoord = mul(unity_WorldToLight, float4(pos, 1)).xyz;
	atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
#elif defined(SPOT)
	float4 lightCoord = mul(unity_WorldToLight, float4(pos, 1));
	atten = (lightCoord.z > 0) * UnitySpotCookie(lightCoord) * UnitySpotAttenuate(lightCoord.xyz);
#elif defined(POINT_COOKIE)
	float3 lightCoord = mul(unity_WorldToLight, float4(pos, 1)).xyz;
	atten = tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).r * texCUBE(_LightTexture0, lightCoord).w;
#elif defined(DIRECTIONAL_COOKIE)
	float3 lightCoord = mul(unity_WorldToLight, float4(pos, 1)).xyz;
	atten = tex2D(_LightTexture0, lightCoord).w;
#else
	atten = 1.0;
#endif

	return atten;
}

//inline half LightDir(half3 pos)
//{
//	half atten = 1;
//
//#if defined(POINT)
//	return _WorldSpaceLightPos0.xyz-pos
//#elif defined(SPOT)
//	float4 lightCoord = mul(unity_WorldToLight, float4(pos, 1));
//	atten = (lightCoord.z > 0) * UnitySpotCookie(lightCoord) * UnitySpotAttenuate(lightCoord.xyz);
//#elif defined(POINT_COOKIE)
//	float3 lightCoord = mul(unity_WorldToLight, float4(pos, 1)).xyz;
//	atten = tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).r * texCUBE(_LightTexture0, lightCoord).w;
//#elif defined(DIRECTIONAL_COOKIE)
//	float3 lightCoord = mul(unity_WorldToLight, float4(pos, 1)).xyz;
//	atten = tex2D(_LightTexture0, lightCoord).w;
//#else
//	atten = 1.0;
//#endif
//
//	return atten;
//}

fixed4 frag_surface_add(v2f i) : SV_Target
{

	fixed3 worldNormal = normalize(i.worldNormal);
	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
	fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
	fixed3 worldHalf = normalize(worldView + worldLight);

	fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
	//---Pntlight handle
	float3 lightColor = _LightColor0.rgb * LightAtten(i.worldPos.xyz);
	//___
	fixed3 diffuse = lightColor * albedo * saturate(dot(worldNormal, worldLight));
	fixed3 specular = lightColor * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess);
	fixed3 color = 0*ambient + diffuse + specular*0;

	//AO should be in albedo texture,so don't lower brightness here --xc
	return fixed4(color, 1.0);
}

//interpolation {(0,0),(0.2,0.1),(0.4,0.3),(0.5,0.5),(0.6,0.7), (0.8,0.9),(1,1)}
half remap(half x)
{
	return 2.04167f*x - 16.1458f*pow(x, 2) + 54.1667f*pow(x, 3) - 65.1042*pow(x, 4) + 26.0417*pow(x, 5);
}

half3 SpecularTerm_BRDF2_Anisotropic_Cloth(half3 lightColor, half3 specColor, half nl, half3 worldNormal, half3 lightDir, half3 viewDir, half roughness, half3 worldTangent)
{
	half3 tangent = normalize(worldTangent + worldNormal);
	float3 halfDir = Unity_SafeNormalize(float3(lightDir)+viewDir);
	half th = dot(tangent, halfDir);
	half sinTH = sqrt(1 - th * th);
	float nh = saturate(dot(worldNormal, halfDir));
	float lh = saturate(dot(lightDir, halfDir));

	half a2 = roughness * roughness;

	half d = sinTH * sinTH * (a2 - 1.f) + 1.00001f;
	half specularTerm = 1;
	specularTerm = a2 / (max(0.1h, lh * lh) * (roughness + 0.5h) * (d * d) * 4.0h);
#if defined (SHADER_API_MOBILE)
	specularTerm = specularTerm - 1e-4f;
#endif
#if defined (SHADER_API_MOBILE)
	specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
#endif

	return specularTerm * specColor * max(nl, 0) * lightColor;
}

fixed4 frag_base(v2f i): SV_Target
{
	//###
	float2 uv_fur = i.uv.zw * _FurThinness;
	float3 dir_tan = tex2D(_DirTex, i.uv2.xy).rgb;
	dir_tan = normalize(2 * dir_tan - 1);
	uv_fur += _DirStrength * FURSTEP * float2(dir_tan.x, dir_tan.y);
	fixed noise = tex2D(_FurTex, uv_fur).r;
	//___
	fixed alpha = clamp(noise - (FURSTEP * FURSTEP) * _FurDensity, 0, 1);

	//clip(alpha-0.5);

    fixed3 worldNormal = normalize(i.worldNormal);
    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
    fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    fixed3 worldHalf = normalize(worldView + worldLight);

    fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
	{//original 
		albedo -= (pow(1 - FURSTEP, 3)) * _FurShading;
	}
	{
		//int step = 20;
		//float layerBottomDark = 0.1;
		//float layerTopDark = 1.0;
		//float dark = lerp(layerBottomDark, layerTopDark, FURSTEP);
		//dark = remap(dark);
		//dark = lerp(1, dark, _FurShading);
		//albedo *= dark;
	}
    half rim = 1.0 - saturate(dot(worldView, worldNormal));
    //albedo += fixed4(_RimColor.rgb * pow(rim, _RimPower), 1.0);

    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight));
    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess);

	//### Aniso
	float3 dirWorld = dir_tan.x * i.worldTangent
		+ dir_tan.y * i.worldNormal
		+ dir_tan.z * normalize(cross(i.worldNormal, i.worldTangent));
	float3 tangentWorld = normalize(i.worldTangent + _DirStrength * FURSTEP * dirWorld);

	float nl = dot(i.worldNormal, worldLight);
	float anisoRoughness = _AnisoRoughness;
	half3 anisoSpecTerm = SpecularTerm_BRDF2_Anisotropic_Cloth(_LightColor0.rgb, _AnisoSpecular.rgb, nl, i.worldNormal, worldLight, worldView, anisoRoughness, tangentWorld);
	anisoSpecTerm = abs(anisoSpecTerm);
	//___

	//donnot use the origin dumy specular--xc
    fixed3 color = ambient + diffuse + specular*0+ anisoSpecTerm* _AnisoIntensity;
    
    return fixed4(color, alpha);
}

fixed4 frag_base_add(v2f i) : SV_Target
{
	fixed3 worldNormal = normalize(i.worldNormal);
	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
	fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
	fixed3 worldHalf = normalize(worldView + worldLight);

	fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
	{//original 
		albedo -= (pow(1 - FURSTEP, 3)) * _FurShading;
	}
	{
		//int step = 20;
		//float layerBottomDark = 0.1;
		//float layerTopDark = 1.0;
		//float dark = lerp(layerBottomDark, layerTopDark, FURSTEP);
		//dark = remap(dark);
		//dark = lerp(1, dark, _FurShading);
		//albedo *= dark;
	}
	half rim = 1.0 - saturate(dot(worldView, worldNormal));
	//albedo += fixed4(_RimColor.rgb * pow(rim, _RimPower), 1.0);

	//---Pntlight handle
	float3 lightColor = _LightColor0.rgb * LightAtten(i.worldPos.xyz);
	//___

	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
	fixed3 diffuse = lightColor * albedo *  saturate(dot(worldNormal, worldLight));
	fixed3 specular = lightColor * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess);

	//### Aniso
	float3 dir_tan = tex2D(_DirTex, i.uv2.xy).rgb;
	dir_tan = normalize(2 * dir_tan - 1);
	float3 dirWorld = dir_tan.x * i.worldTangent
		+ dir_tan.y * i.worldNormal
		+ dir_tan.z * normalize(cross(i.worldNormal, i.worldTangent));
	float3 tangentWorld = normalize(i.worldTangent + _DirStrength * FURSTEP * dirWorld);

	float nl = dot(i.worldNormal, worldLight);
	float anisoRoughness = _AnisoRoughness;
	half3 anisoSpecTerm = SpecularTerm_BRDF2_Anisotropic_Cloth(lightColor, _AnisoSpecular.rgb, nl, i.worldNormal, worldLight, worldView, anisoRoughness, tangentWorld);
	anisoSpecTerm = abs(anisoSpecTerm);
	//___

	//donnot use the origin dumy specular--xc
	fixed3 color = 0*ambient + diffuse + specular*0 + anisoSpecTerm * _AnisoIntensity;
	//###
	float2 uv_fur = i.uv.zw * _FurThinness;
	uv_fur += _DirStrength * FURSTEP * float2(dir_tan.x, dir_tan.y);
	fixed noise = tex2D(_FurTex, uv_fur).r;
	//___
	fixed alpha = clamp(noise - (FURSTEP * FURSTEP) * _FurDensity, 0, 1);
	return fixed4(color, alpha);
}