﻿#define OBJNUM 1

#define MaxSDF 1000000000
#define MaxTraceDis 10
#define MaxTraceTime 100
#define TraceThre 0.001
#define NormalEpsilon 0.01

#define SceneSDFShadowNormalBias 0.001

#define SceneSDFSoftShadowBias 0.1
#define SceneSDFSoftShadowK 16

#include "../../../HLSL/PBR/PBRCommonDef.hlsl"
#include "../../../HLSL/PBR/PBR_IBL.hlsl"
#include "../../../HLSL/PBR/PBR_GGX.hlsl"
#include "../../../HLSL/UV/UVCommonDef.hlsl"

#include "../../../HLSL/Random/RandUtility.hlsl"
#include "../../../HLSL/Noise/NoiseCommonDef.hlsl"
#include "../../../HLSL/Transform/TransformCommonDef.hlsl"
#include "../../../HLSL/SDFGame/SDFCommonDef.hlsl"
#include "../../../HLSL/MatLib/CommonMatLib.hlsl"
float daoScale;

//@@@SDFBakerMgr TexSys
//@@@

//@@@SDFBakerMgr DyValSys
//@@@

float GetPntlightAttenuation(float3 pos, float3 lightPos)
{
	//return 1;
	float d = length(pos - lightPos);
	return saturate(1 / (d*d));
	//return 1 / (1 + 0.01*d + 0.005*d*d);
}

float DigSeg (float2 q)
{
return step (abs (q.x), 0.12) * step (abs (q.y), 0.6);
}

#define DSG(q) k = kk; kk = k / 2; if (kk * 2 != k) d += DigSeg (q)

float ShowDig (float2 q, int iv)
{
float d;
int k, kk;
float2 vp = float2 (0.5, 0.5), vm = float2 (-0.5, 0.5), vo = float2 (1., 0.);
if (iv == -1) k = 8;
else if (iv < 2) k = (iv == 0) ? 119 : 36;
else if (iv < 4) k = (iv == 2) ? 93 : 109;
else if (iv < 6) k = (iv == 4) ? 46 : 107;
else if (iv < 8) k = (iv == 6) ? 122 : 37;
else k = (iv == 8) ? 127 : 47;
q = (q - 0.5);
d = 0.;
kk = k;
DSG (q.yx - vo); DSG (q.xy - vp); DSG (q.xy - vm); DSG (q.yx);
DSG (q.xy + vm); DSG (q.xy + vp); DSG (q.yx + vo);
return d;
}

//float2 mfmod(float2 a, float2 b)
//{
// float2 c = frac(abs(a/b))*abs(b);
// return (a < 0) ? -c : c; /* if ( a < 0 ) c = 0-c */
//}

float ShowInt(float2 q, int iv, int maxLen=4)
{
	//!!!
	q.x *= -1;
	int base = 10;
	int tnum = iv;
	int resi;
	float re = 0;
	float2 offset = float2(2,0);
	int i=0;
	if(iv<0)
	{
		tnum = abs(tnum);
	}
	for(;i<maxLen;i++)
	{
		resi = tnum%base;
		re += ShowDig(q - offset*i,resi);
		tnum -= resi;
		tnum /= base;
		if(tnum == 0)
		{
			break;
		}
	}
	if(iv<0)
	{
		re += ShowDig(q - offset*(i+1),-1);
	}
	return re;
}

void SH_AddLightDirectional( inout float3 sh[9], in float3 col, in float3 v )
{
float DI = 64;
	
	sh[0] += col * (21.0/DI);
	sh[0] -= col * (15.0/DI) * v.z*v.z;
	sh[1] += col * (32.0/DI) * v.x;
	sh[2] += col * (32.0/DI) * v.y;
	sh[3] += col * (32.0/DI) * v.z;
	sh[4] += col * (60.0/DI) * v.x*v.z;
	sh[5] += col * (60.0/DI) * v.z*v.y;
	sh[6] += col * (60.0/DI) * v.y*v.x;
	sh[7] += col * (15.0/DI) * (3.0*v.z*v.z-1.0);
	sh[8] += col * (15.0/DI) * (v.x*v.x-v.y*v.y);
}

float3 SH_Evalulate( in float3 v, in float3 sh[9] )
{
	return sh[0] +
sh[1] * v.x +
sh[2] * v.y +
sh[3] * v.z +
sh[4] * v.x*v.z +
sh[5] * v.z*v.y +
sh[6] * v.y*v.x +
sh[7] * v.z*v.z +
sh[8] *(v.x*v.x-v.y*v.y);
}


Material_PBR GetObjMaterial_PBR(int obj)
{
	Material_PBR re;
	Init(re);

//@@@SDFBakerMgr ObjMaterial
if(obj == 0 )
{
re.albedo = float3(1, 1, 1);
re.metallic = 0;
re.roughness = 1;
}
//@@@
	return re;
}

int GetObjRenderMode(int obj)
{
//@@@SDFBakerMgr ObjRenderMode
int renderMode[1];
renderMode[0] = 333;
return renderMode[obj];
//@@@
}

float2 GetObjUV(in HitInfo minHit)
{
	float2 uv = 0;
	int inx = minHit.obj;
	//@@@SDFBakerMgr ObjUV
if(inx == 0 )
{
}
	//@@@

	//----------------------------------

	//@@@SDFBakerMgr SpecialObj
if(inx == 0 )
{
inx = -1;
}
	//@@@
	if(inx <0)
	{
		uv = SimpleUVFromPos(minHit.P,minHit.N, float3(1,1,1));
	}
return uv;
}

void GetObjTB(inout float3 T, inout float3 B, in HitInfo minHit)
{
	int inx = minHit.obj;
	T=0;
	B=0;
//@@@SDFBakerMgr ObjTB
if(inx == 0 )
{
}
//@@@
basis_unstable(minHit.N, T, B);
}

void ObjPreRender(inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
int inx = minHit.obj;
//@@@SDFBakerMgr ObjMatLib

//@@@

//@@@SDFBakerMgr ObjImgAttach

//@@@

//@@@SDFBakerMgr SpecialObj
if(inx == 0 )
{
inx = -1;
}
//@@@

//float2 q = minHit.P.xz;
//float dis = 20;
//float m = floor(minHit.P.y/dis);
//
//if(ShowInt(q,m))
//{
//	mat.albedo = float3(0,1,0);
//}

}

void ObjPostRender(inout float3 result, inout int mode, inout Material_PBR mat, inout Ray ray, inout HitInfo minHit)
{
SmoothWithDither(result.rgb, suv);
if(camGammaMode == 1)
{
	
}
else{
	//gamma
	//result.rgb = result.rgb / (result.rgb + 1.0);
	//result.rgb = pow(result.rgb, 1/2.2);
}
}

float4 RenderSceneObj(Ray ray, inout HitInfo minHit, out Material_PBR mat)
{
	mat = GetObjMaterial_PBR(minHit.obj);
	int mode = GetObjRenderMode(minHit.obj);
	ObjPreRender(mode, mat, ray, minHit);
	float4 result = float4(0,0,0,1);
//@@@SDFBakerMgr ObjRender
if(mode==0)
{
float3 lightDirs[1];
float3 lightColors[1];
lightDirs[0] = float3(-0.3213938, -0.7660444, 0.5566705);
lightColors[0] = 3*float3(0.8705883, 0.8784314, 0.882353);
result.rgb = 0.1 * mat.albedo * mat.ao;
for(int i=0;i<1;i++)
{
result.rgb += PBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], lightColors[i]);
}
}
//@@@
else if (mode == 1)
{
	//result.rgb = PBR_IBL(envSpecTex2DArr, mat, minHit.N, -ray.dir);
}
//else if (mode == 2)
//{
//	//object reflection IBL
//	//bool isPNGEnv=false;
//	//Texture2DArray tempEnv;
//	//GetEnvTexArrByObj(minHit.obj, isPNGEnv, tempEnv);
//	//if(isPNGEnv)
//	//{
//	//	//result.rgb = PBR_IBL(tempEnv, mat, minHit.N, -ray.dir,1,1,true,true);
//	//}
//	//else
//	//{
//	//	//result.rgb = PBR_IBL(tempEnv, mat, minHit.N, -ray.dir);
//	//}
//}
else if (mode == 3)
{
	//lightmap mode
	//result.rgb = mat.albedo;
}
else if (mode == 333)
{
//???
float3 lightDirs[1];
float3 lightColors[1];
lightDirs[0] = float3(-0.3213938, -0.7660444, 0.5566705);
lightColors[0] = float3(0.8705883, 0.8784314, 0.882353);
//result.rgb = 0.1 * mat.albedo * mat.ao;
//for(int i=0;i<1;i++)
//{
// result.rgb += PBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], lightColors[i]);
//}
float3 N = lerp(normalize(minHit.P-float3(3,0,0)), minHit.N, 0);//minHit.N;//
float3 L = normalize(-lightDirs[0]);
float3 V = normalize(-ray.dir);

float NdotL = max(0, dot(N,L));
float cloudHeight = 0.1*(1+0.5+0.25+0.125);
float clipRate = (minHit.cloudLength/cloudHeight);
//float clipRate = minHit.cloudLength;
float ori = clipRate;
float smoothNdotL = saturate(pow(NdotL,2-clipRate));

float BackSSSStrength = 0.5;
float3 backLitDir = N*BackSSSStrength+L;
float backSSS = saturate(dot(V,-backLitDir));
backSSS = saturate(pow(backSSS,clipRate*10)*10);

float NdotV = max(0, dot(N,V));
float smoothNdotV = saturate(pow(NdotV, 2 - clipRate));

float sha = 1.0;

float final = saturate(smoothNdotV*0.0 + sha * saturate(lerp(smoothNdotL,ori,0.5)+backSSS)*(1-NdotV*0.5));

	float4 SHA[3];
	SHA[0] = float4(0.007252,-0.005682,0.012560, 0.169953);
	SHA[1] = float4(0.011403,0.041343,-0.019753, 0.211334);
	SHA[2] = float4(0.019656,0.127484,-0.034053, 0.289207);
	//SHA[0] = 0;
	//SHA[1] = 0;
	//SHA[2] = float4(0,0,0,1);
	float4 SHB[3];
	SHB[0] = float4(0.005699,-0.009872,0.030990, -0.010436);
	SHB[1] = float4(0.009111,-0.015783,0.043139, -0.015223);
	SHB[2] = float4(0.016365,-0.028334,0.053146, -0.022085);
	//SHB[0] = 0;
	//SHB[1] = 0;
	//SHB[2] = 0;
	float3 SHC = float3(0.025035,0.034436,0.040465);
	//float3 SHC = 0;

	float3 col = ShadeSH9(N,SHA,SHB,SHC);

	result.rgb = 1*col+float3(0.8705883,0.8784314,0.882353)*final;//pow(lerp(final,0+1*float3(173,212,254)/255,0.5),1);
//result.rgb = N;
}
else if (mode == 444)
{
//???
	float3 lightDirs[1];
	float3 lightColors[1];
	lightDirs[0] = float3(-0.3213938, -0.7660444, 0.5566705);
	lightColors[0] = 1.5*float3(2, 2, 2);
	result.rgb = 0.03 * mat.albedo * mat.ao;
	for(int i=0;i<1;i++)
	{
	 result.rgb += PBR_GGX(mat, minHit.N, -ray.dir, -lightDirs[i], lightColors[i]);
	}

	float3 V = -ray.dir;
	float3 N = minHit.N;
	float3 L = -lightDirs[0];

	float k = smoothstep(0,1.4,minHit.cloudLength);
	//result.rgb = lerp(result.rgb,1,0.5*k);
	//result.rgb = k;
	result.a = k;//step(0.1,pow(k,1));
}
else if (mode == 1001)
{
	//result.rgb = minHit.N;
}
else if (mode == 1002)
{
	float3 T,B;
	GetObjTB(T, B, minHit);
	//result.rgb = T;
}
else
{
	//result.rgb = float3(1,0,1);
}
	//ObjPostRender(result, mode, mat, ray, minHit);
	return result;
}


float HardShadow_TraceScene(Ray ray, out HitInfo info, float maxLength = MaxSDF);
float Expensive_HardShadow_TraceScene(Ray ray, out HitInfo info, float maxLength = MaxSDF);
float SoftShadow_TraceScene(Ray ray, out HitInfo info, float maxLength = MaxSDF);

float GetDirHardShadow(float3 lightDir, in HitInfo minHit, float maxLength = MaxSDF)
{
	Ray ray;
	ray.pos = minHit.P;
	ray.dir = -lightDir;
	ray.pos += ray.dir*TraceThre*2 + minHit.N*TraceThre*2;
	HitInfo hitInfo;
	return HardShadow_TraceScene(ray, hitInfo, maxLength);
}

float GetDirSoftShadow(float3 lightDir, in HitInfo minHit, float maxLength = MaxSDF)
{
	Ray ray;
	ray.pos = minHit.P;
	ray.dir = -lightDir;
	ray.pos += ray.dir*TraceThre*2 + minHit.N*TraceThre*2;
	HitInfo hitInfo;
	return SoftShadow_TraceScene(ray, hitInfo, maxLength);
}

float RenderSceneSDFShadow(HitInfo minHit)
{
	float sha = 1;
if(true)
{
//@@@SDFBakerMgr DirShadow
int lightType[1];
lightType[0] = 0;
float3 lightPos[1];
lightPos[0] = float3(0, 3, 0);
float3 lightDirs[1];
lightDirs[0] = float3(-0.3213938, -0.7660444, 0.5566705);
int shadowType[1];
shadowType[0] =0;
float lightspace = 1;
float maxLength = MaxSDF;
float tsha = 1;
for (int i = 0; i < 1; i++)
{
float maxLength = MaxSDF;
if(lightType[i]==0)
{
maxLength = MaxSDF;
}
if(lightType[i]==1)
{
maxLength = length(minHit.P - lightPos[i]);
}
if(lightType[i]<0)
{
tsha = 1;
}
else
{
if(shadowType[i]==0)
{
tsha = GetDirHardShadow(lightDirs[i], minHit, maxLength);
}
if(shadowType[i]==1)
{
tsha = GetDirSoftShadow(lightDirs[i], minHit, maxLength);
}
}
lightspace -= (1 - tsha);
}
lightspace /= 1;
sha = lightspace;
//@@@
}
sha = saturate(0.3+sha);
return sha;
}

//###################################################################################
#include "../../../HLSL/SDFGame/SDFCommonDef.hlsl"
#include "../../../HLSL/Noise/NoiseCommonDef.hlsl"

//tutorial: iq modeling https://www.youtube.com/watch?v=-pdSjBPH3zM


float GetObjSDF(int inx, float3 p, in TraceInfo traceInfo)
{
//###
float re = MaxSDF; //Make sure default is an invalid SDF
//@@@SDFBakerMgr BeforeObjSDF
//@@@
//@@@SDFBakerMgr ObjSDF
if(inx == 0 )
{
inx = -1;
}
//@@@

if(inx == -1)
{//???
//if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300)
	{
		float3 center = float3(3, 0.0, 0);
		float r = 0.5f;
		float scale1 = 10;
		float scale2 = 0.1;
		
		//float2 uv = SimpleUVFromPos(p, normalize(p-center), float3(1,1,1));
		r += fbm5(scale1*p.xyz,float3(1,0,0)*_Time.y)*scale2;
		//r += perlinNoiseFromTex(uv) * scale2;
		re = 0.5*SDFSphere(p, center, r);
	}
}
if(inx == -2)
{//???
//if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300)
	{
		float3 center = float3(1.5, 0, 0);
		float r = 0.5f;
		float scale1 = 5;
		float scale2 = 0.05;
		//
		//r += fbm5(scale1*p.xyz,_Time.y)*scale2;
		//float d1 = SDFSphere(p, center, r);
		//
		//re =0.5*d1;
		float d = abs(p.y - fbm5(scale1*p.xyz,_Time.y)*scale2);
		re = 0.5*d;
	}
}
if(inx == -3)
{//???
//if(abs(p.x-eyePos.x)<300 && abs(p.z - eyePos.z)<300)
	{
		float3 center = float3(3.5, 0.2, 0);
		float r = 0.5f;
		float scale1 = 30;
		float scale2 = 0.1;
		
		r += fbm5(scale1*p.xyz,float3(1,0,0)*_Time.y)*scale2;
		float d1 = SDFSphere(p, center, r);

		re = 0.5*d1;
	}
}

return re;
}

float3 GetObjSDFNormal(int inx, float3 p, in TraceInfo traceInfo, float eplisonScale = 1.0f)
{
	float normalEpsilon = NormalEpsilon;
	//normalEpsilon *= daoScale;
	return normalize(float3(
		GetObjSDF(inx, float3(p.x + NormalEpsilon*eplisonScale, p.y, p.z), traceInfo) - GetObjSDF(inx, float3(p.x - NormalEpsilon*eplisonScale, p.y, p.z), traceInfo),
		GetObjSDF(inx, float3(p.x, p.y + NormalEpsilon*eplisonScale, p.z), traceInfo) - GetObjSDF(inx, float3(p.x, p.y - NormalEpsilon*eplisonScale, p.z), traceInfo),
		GetObjSDF(inx, float3(p.x, p.y, p.z + NormalEpsilon*eplisonScale), traceInfo) - GetObjSDF(inx, float3(p.x, p.y, p.z - NormalEpsilon*eplisonScale), traceInfo)
		));
}

float3 GetObjNormal(int inx, in Ray ray, in TraceInfo traceInfo)
{
//@@@SDFBakerMgr SpecialObj
if(inx == 0 )
{
inx = -1;
}
//@@@
if(inx == -1)
{//???
	//float3 N = GetObjSDFNormal(inx, ray.pos, traceInfo);
	//float3 V = -ray.dir;
	//float3 L = -normalize(float3(-0.3213938, -0.7660444, 0.5566705));
	////float k = saturate(1-dot(N,V));
	//float k = saturate(dot(N,L));
	//k = pow(k,0.2);
	//float3 center = float3(3,0,0);
	//return lerp(N,normalize(ray.pos-center),k);
}
	return GetObjSDFNormal(inx, ray.pos, traceInfo);
}

void TraceScene2(Ray ray, out HitInfo info);
void TraceScene(Ray ray, out HitInfo info)
{
	float traceThre = TraceThre;

	//traceThre *= daoScale;

	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo,MaxSDF);

	float objSDF[OBJNUM];
	bool innerBoundFlag[OBJNUM];
	float innerBoundStepScale[OBJNUM];
	int objInx = -1;
	float sdf = MaxSDF;
	float minSDF = MaxSDF;
	bool bInnerBound = false;

	while (traceInfo.traceCount <= MaxTraceTime)
	{
		objInx = -1;
		sdf = MaxSDF;
		minSDF = MaxSDF;
		bInnerBound = false;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			innerBoundFlag[inx] = false;
			innerBoundStepScale[inx] = 1;
		}

//@@@SDFBakerMgr CheckInnerBound
//@@@

		if(bInnerBound)
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				if(innerBoundFlag[inx])
				{
					objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo) * innerBoundStepScale[inx];
					if (objSDF[inx] < sdf)
					{
						sdf = objSDF[inx];
						objInx = inx;
					}
				}
			}
		}
		else
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo);
				sdf = smin(sdf,objSDF[inx]);
				if(objSDF[inx]<minSDF)
				{
					minSDF = objSDF[inx];
					objInx = inx;
				}
			}
		}

		if(objInx == -1)
		{
			break;
		}

		if (sdf > MaxTraceDis)
		{
			break;
		}

		if (sdf <= traceThre)
		{
			info.bHit = true;
			info.obj = objInx;
			info.N = GetObjNormal(objInx, ray, traceInfo);
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
	}

	if(info.bHit)
	{
		{
			//HitInfo info2;
			//ray.pos += ray.dir*(0+traceThre*2) - info.N*traceThre*10;
			//TraceScene2(ray,info2);
			//if(info2.bHit)
			//{
			//info.cloudLength = length(info2.P-info.P);
			//}
		}
		info.cloudLength = length(info.P - float3(3,0,0)) - 0.5f;
	}
}

void TraceScene2(Ray ray, out HitInfo info)
{
	float traceThre = TraceThre;

	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo,MaxSDF);

	float objSDF[OBJNUM];
	bool innerBoundFlag[OBJNUM];
	float innerBoundStepScale[OBJNUM];
	int objInx = -1;
	float sdf = MaxSDF;
	bool bInnerBound = false;

	while (traceInfo.traceCount <= MaxTraceTime)
	{
		objInx = -1;
		sdf = MaxSDF;
		bInnerBound = false;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			innerBoundFlag[inx] = false;
			innerBoundStepScale[inx] = 1;
		}


		if(bInnerBound)
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				if(innerBoundFlag[inx])
				{
					objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo) * innerBoundStepScale[inx];
					if (objSDF[inx] < sdf)
					{
						sdf = objSDF[inx];
						objInx = inx;
					}
				}
			}
		}
		else
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo);
				if (objSDF[inx] < sdf)
				{
					sdf = objSDF[inx];
					objInx = inx;
				}
			}
		}

		if(objInx == -1)
		{
			break;
		}

		if (sdf > MaxTraceDis)
		{
			break;
		}

		if (abs(sdf) <= traceThre)
		{
			info.bHit = true;
			info.obj = objInx;
			info.N = GetObjNormal(objInx, ray, traceInfo);
			info.P = ray.pos;
			break;
		}
		ray.pos -= sdf * ray.dir;
		Update(traceInfo,sdf);
	}
}

float HardShadow_TraceScene(Ray ray, out HitInfo info, float maxLength)
{
	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo,MaxSDF);

	float objSDF[OBJNUM];
	bool innerBoundFlag[OBJNUM];
	float innerBoundStepScale[OBJNUM];
	int objInx = -1;
	float sdf = MaxSDF;
	bool bInnerBound = false;

	while (traceInfo.traceCount <= MaxTraceTime*0.01)
	{
		objInx = -1;
		sdf = MaxSDF;
		bInnerBound = false;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			innerBoundFlag[inx] = false;
			innerBoundStepScale[inx] = 1;
		}


		if(bInnerBound)
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				if(innerBoundFlag[inx])
				{
					objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo) * innerBoundStepScale[inx];
					if (objSDF[inx] < sdf)
					{
						sdf = objSDF[inx];
						objInx = inx;
					}
				}
			}
		}
		else
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo);
				if (objSDF[inx] < sdf)
				{
					sdf = objSDF[inx];
					objInx = inx;
				}
			}
		}

		if(objInx == -1)
		{
			break;
		}

		if (sdf > MaxTraceDis*0.05)
		{
			break;
		}

		if (sdf <= TraceThre*2)
		{
			info.bHit = true;
			info.obj = objInx;
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
		if(traceInfo.traceSum>maxLength)
		{
			break;
		}
	}

	if (info.bHit)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

float Expensive_HardShadow_TraceScene(Ray ray, out HitInfo info, float maxLength)
{
	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo,MaxSDF);

	float objSDF[OBJNUM];
	bool innerBoundFlag[OBJNUM];
	float innerBoundStepScale[OBJNUM];
	int objInx = -1;
	float sdf = MaxSDF;
	bool bInnerBound = false;

	while (traceInfo.traceCount <= MaxTraceTime)
	{
		objInx = -1;
		sdf = MaxSDF;
		bInnerBound = false;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			innerBoundFlag[inx] = false;
			innerBoundStepScale[inx] = 1;
		}

		if(bInnerBound)
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				if(innerBoundFlag[inx])
				{
					objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo) * innerBoundStepScale[inx];
					if (objSDF[inx] < sdf)
					{
						sdf = objSDF[inx];
						objInx = inx;
					}
				}
			}
		}
		else
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo);
				if (objSDF[inx] < sdf)
				{
					sdf = objSDF[inx];
					objInx = inx;
				}
			}
		}

		if(objInx == -1)
		{
			break;
		}

		if (sdf > MaxTraceDis)
		{
			break;
		}

		if (sdf <= TraceThre)
		{
			info.bHit = true;
			info.obj = objInx;
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
		if(traceInfo.traceSum>maxLength)
		{
			break;
		}
	}

	if (info.bHit)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

//https://www.shadertoy.com/view/MsfGRr
float SoftShadow_TraceScene(Ray ray, out HitInfo info, float maxLength)
{
	Init(info);
	float sha = 1.0;
	float t = 0.005 * 0.1; //一个非0小值，会避免极其细微的多余shadow

	TraceInfo traceInfo;
	Init(traceInfo,MaxSDF);
	while (traceInfo.traceCount <= MaxTraceTime*0.2)
	{
		int objInx = -1;
		float objSDF[OBJNUM];
		float sdf = MaxSDF;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo);
			if (objSDF[inx] < sdf)
			{
				sdf = objSDF[inx];
				objInx = inx;
			}
		}

		if (sdf <= 0)
		{
			sha = 0;
			break;
		}

		if (sdf > MaxTraceDis)
		{
			break;
		}

		sha = min(sha, SceneSDFSoftShadowK * sdf / t);
		if (sha < 0.001) break;

		//*0.1f解决背面漏光问题
		if (sdf <= TraceThre*0.1f)
		{
			info.bHit = true;
			info.obj = objInx;
			info.P = ray.pos;
			break;
		}

		t += clamp(sdf, 0.01*SceneSDFSoftShadowBias, 0.5*SceneSDFSoftShadowBias);

		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
		if(traceInfo.traceSum>maxLength)
		{
			break;
		}
	}

	return saturate(sha);
}

void Indir_TraceScene(Ray ray, out HitInfo info)
{
	float traceThre = TraceThre;

	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo,MaxSDF);

	float objSDF[OBJNUM];
	bool innerBoundFlag[OBJNUM];
	float innerBoundStepScale[OBJNUM];
	int objInx = -1;
	float sdf = MaxSDF;
	bool bInnerBound = false;

	while (traceInfo.traceCount <= 40)
	{
		objInx = -1;
		sdf = MaxSDF;
		bInnerBound = false;
		for (int inx = 0; inx < OBJNUM; inx++)
		{
			innerBoundFlag[inx] = false;
			innerBoundStepScale[inx] = 1;
		}

		if(bInnerBound)
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				if(innerBoundFlag[inx])
				{
					objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo) * innerBoundStepScale[inx];
					if (objSDF[inx] < sdf)
					{
						sdf = objSDF[inx];
						objInx = inx;
					}
				}
			}
		}
		else
		{
			for (int inx = 0; inx < OBJNUM; inx++)
			{
				objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo);
				if (objSDF[inx] < sdf)
				{
					sdf = objSDF[inx];
					objInx = inx;
				}
			}
		}

		if(objInx == -1)
		{
			break;
		}

		if (sdf > 100)
		{
			break;
		}

		if (sdf <= traceThre)
		{
			info.bHit = true;
			info.obj = objInx;
			info.N = GetObjNormal(objInx, ray, traceInfo);
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
	}
}

void SceneRenderIndirRay(in Ray ray, out float3 re, out HitInfo minHit, out Material_PBR indirSourceMat)
{
	re = 0;
	//---Trace
	Init(minHit);
	TraceScene(ray, minHit);
	//Indir_TraceScene(ray, minHit);
	//___Trace

	if (minHit.bHit)
	{
		re = RenderSceneObj(ray, minHit, indirSourceMat);
	}
}

float3 IndirPointLightRender(float3 P, float3 N, float3 lightColor,float3 lightPos)
{
	float3 Li = lightColor * saturate(1*GetPntlightAttenuation(P,lightPos));
	float3 L = normalize(lightPos - P);
	return Li*saturate(dot(N,L));
}

float3 Sample_MIS_H(float3 Xi, float3 N, in Material_PBR mat, float p_diffuse) {
//float r_diffuse = (1.0 - material.metallic);
//float r_specular = 1.0;
//float r_sum = r_diffuse + r_specular;
	//
//float p_diffuse = r_diffuse / r_sum;
//float p_specular = r_specular / r_sum;

float rd = Xi.z;

if(rd <= p_diffuse) {
return IS_SampleDiffuseH(N,mat.roughness,Xi.x,Xi.y);
}
	else
	{
		return IS_SampleSpecularH(N,mat.roughness,Xi.x,Xi.y);
	}
return 0;
}

void SetCheapIndirectColor(inout float3 re, float3 seed, Ray ray, HitInfo minHit, Material_PBR mat)
{
	Ray ray_indirect;
	ray_indirect.pos = minHit.P;
	float3 Xi = float3(rand01(seed),rand01(seed.zxy),rand01(seed.zyx));

	float r_diffuse = saturate(1.0 - mat.metallic);
	float r_specular = saturate(1.0);
	float r_sum = r_diffuse + r_specular;
	float p_diffuse = r_diffuse / r_sum;
	float p_specular = r_specular / r_sum;

	float3 H = Sample_MIS_H(Xi, minHit.N, mat,p_diffuse);
	ray_indirect.dir = reflect(ray.dir,H);
	{
		//float3 d1 = Vec2NormalHemisphere(randDir,minHit.N);
		//float3 d2 = reflect(ray.dir,minHit.N);
		//ray_indirect.dir = lerp(d2, d1, mat.roughness);
		//ray_indirect.dir = reflect(ray.dir,minHit.N);
		//ray_indirect.dir = toNormalHemisphere(randP_hemiRound(seed), minHit.N);
	}
	//minHit.N*TraceThre*2 ensure escape from 'judging surface'
	ray_indirect.pos = minHit.P + ray_indirect.dir*TraceThre*2 + minHit.N*TraceThre*2;
	HitInfo indirHit;
	float3 indirLightColor;
	Material_PBR indirSourceMat;
	SceneRenderIndirRay(ray_indirect, indirLightColor, indirHit, indirSourceMat);
	indirLightColor *= RenderSceneSDFShadow(indirHit);
	//---
	float3 L = ray_indirect.dir;
	float m_NL = saturate(dot(minHit.N,L));
	float pdf_diffuse = m_NL / PI;

	float pdf_GGX = 0;
	float a = mat.roughness;
	a = max(0.001f, a*a);
	
	//float3 H = normalize(-ray.dir+L);
	float m_NH = saturate(dot(minHit.N, H));
	float nomi = a * a * m_NH;
	float m_NH2 = m_NH * m_NH;
	
	float denom = (m_NH2 * (a*a - 1.0) + 1.0);
	denom = PI * denom * denom;
	pdf_GGX = nomi / denom;
	pdf_GGX /= 4 * dot(L, H);	
	pdf_GGX = max(pdf_GGX, 0.001f);
	float pdf_specular = pdf_GGX;

	float pdf = p_diffuse * pdf_diffuse
				+ p_specular * pdf_specular;
	pdf = max(0.001f, pdf);
	indirLightColor /= pdf;
	if(indirSourceMat.roughness<0.5 && mat.roughness>0.2)
	{
		indirLightColor = 0;
	}
	//___

	{
		//re = IndirPointLightRender(minHit.P,minHit.N, indirLightColor, indirHit.P);
	}
	float3 Li = indirLightColor * GetPntlightAttenuation(minHit.P,indirHit.P);
	re = PBR_GGX(mat, minHit.N, -ray.dir, L, Li);
}

void SetIndirectColor(inout float3 re, float3 seed, Ray ray, HitInfo minHit, Material_PBR mat)
{
	SetCheapIndirectColor(re, seed, ray, minHit, mat);
}
