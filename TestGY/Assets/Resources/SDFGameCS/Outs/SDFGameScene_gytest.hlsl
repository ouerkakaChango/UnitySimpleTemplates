#define OBJNUM 1

#define MaxSDF 1000000000
#define MaxTraceDis 100
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
Texture3D<float> HalfSphereSDF3D;
Texture3D<float3> Norm_Bunny;
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
re.reflective = 0;
re.reflect_ST = float2(1, 0);
}
//@@@
	return re;
}

int GetObjRenderMode(int obj)
{
//@@@SDFBakerMgr ObjRenderMode
int renderMode[1];
renderMode[0] = 444;
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

float4 RenderSceneObj(Ray ray, inout HitInfo minHit, out Material_PBR mat, inout ExtraInfo extra)
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
lightColors[0] = float3(0.8705883, 0.8784314, 0.882353);
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
else if (mode == 444)
{
//??? test GYCloudRenderMode
float3 lightDirs[1];
float3 lightColors[1];
lightDirs[0] = float3(-0.3213938, -0.7660444, 0.5566705);
lightColors[0] = float3(0.8705883, 0.8784314, 0.882353);

float3 N = minHit.N;
float3 L = normalize(-lightDirs[0]);
float3 V = normalize(-ray.dir);

float NdotL = max(0, dot(N,L));
	float ori = extra.cloudLength;
float clipRate = ori;
float smoothNdotL = saturate(pow(NdotL,2-clipRate));

float BackSSSStrength = 1.0;
float3 backLitDir = N*BackSSSStrength+L;
float backSSS = saturate(dot(V,-backLitDir));
backSSS = 0.3*saturate(pow(backSSS,clipRate*10)*10);

float NdotV = max(0, dot(N,V));
float smoothNdotV = saturate(pow(NdotV, 2 - clipRate));

float sha = 1.0;

	float final = saturate(smoothNdotV*0 + sha * saturate(lerp(smoothNdotL,ori,0.0)+backSSS)*(1-NdotV*0.5));

	float4 SHA[3];
	SHA[0] = float4(0.007252,-0.005682,0.012560, 0.169953);
	SHA[1] = float4(0.011403,0.041343,-0.019753, 0.211334);
	SHA[2] = float4(0.019656,0.127484,-0.034053, 0.289207);
	float4 SHB[3];
	SHB[0] = float4(0.005699,-0.009872,0.030990, -0.010436);
	SHB[1] = float4(0.009111,-0.015783,0.043139, -0.015223);
	SHB[2] = float4(0.016365,-0.028334,0.053146, -0.022085);
	float3 SHC = float3(0.025035,0.034436,0.040465);

	float3 indirCol = ShadeSH9(N,SHA,SHB,SHC);

	result.rgb = indirCol+lightColors[0]*final;
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
lightPos[0] = float3(0, 0, 0);
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


float GetObjSDF(int inx, float3 p, in TraceInfo traceInfo, inout ExtraInfo extra)
{
//###
float re = MaxSDF; //Make sure default is an invalid SDF
//@@@SDFBakerMgr BeforeObjSDF
//@@@
//@@@SDFBakerMgr ObjSDF
if(inx == 0 )
{
extra.cloudLength = fbm4_01(5*p+_Time.y);
re = 0+ extra.cloudLength * 0.2 + SDFTex3D(p, float3(0, 0, -5), float3(5, 5, 5), HalfSphereSDF3D, TraceThre);
extra.cloudLength = 1 - extra.cloudLength;
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
		
		float3 moveDirection = float3(0,1,0);
		r += fbm4_01(scale1*p.xyz+moveDirection*_Time.y)*scale2;
		re = 0.5*SDFSphere(p, center, r);
	}
}

return re;
}

float3 GetObjSDFNormal(int inx, float3 p, in TraceInfo traceInfo, in ExtraInfo extra, float eplisonScale = 1.0f)
{
	float normalEpsilon = NormalEpsilon;
	//normalEpsilon *= daoScale;
	return normalize(float3(
		GetObjSDF(inx, float3(p.x + NormalEpsilon*eplisonScale, p.y, p.z), traceInfo,extra) - GetObjSDF(inx, float3(p.x - NormalEpsilon*eplisonScale, p.y, p.z), traceInfo,extra),
		GetObjSDF(inx, float3(p.x, p.y + NormalEpsilon*eplisonScale, p.z), traceInfo,extra) - GetObjSDF(inx, float3(p.x, p.y - NormalEpsilon*eplisonScale, p.z), traceInfo,extra),
		GetObjSDF(inx, float3(p.x, p.y, p.z + NormalEpsilon*eplisonScale), traceInfo,extra) - GetObjSDF(inx, float3(p.x, p.y, p.z - NormalEpsilon*eplisonScale), traceInfo,extra)
		));
}

float3 GetObjNormal(int inx, in Ray ray, in TraceInfo traceInfo, inout ExtraInfo extra)
{
float3 p = ray.pos;
//@@@SDFBakerMgr ObjNormal
if(inx == 0 )
{
return GetObjSDFNormal(inx, ray.pos, traceInfo, extra, 100);
}
//@@@

//@@@SDFBakerMgr SpecialObj
if(inx == 0 )
{
}
//@@@
	return GetObjSDFNormal(inx, ray.pos, traceInfo, extra);
}

//Not used,can be used to trace from inside to outside
void TraceScene2(Ray ray, out HitInfo info);

//Main
void TraceScene(Ray ray, out HitInfo info, inout ExtraInfo extra)
{
	float traceThre = TraceThre;

	//traceThre *= daoScale;

	Init(info);

	TraceInfo traceInfo;
	Init(traceInfo);
	float3 oriPos = ray.pos;

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
					objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo, extra) * innerBoundStepScale[inx];
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
				objSDF[inx] = GetObjSDF(inx, ray.pos, traceInfo, extra);
				sdf = min(sdf,objSDF[inx]);
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
			info.N = GetObjNormal(objInx, ray, traceInfo, extra);
			info.P = ray.pos;
			break;
		}
		ray.pos += sdf * ray.dir;
		Update(traceInfo,sdf);
	}
}

void SetIndirectColor(inout float3 re, float3 seed, Ray ray, HitInfo minHit, Material_PBR mat)
{
	
}
