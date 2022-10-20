#ifndef UNITYCOMMONDEF_HLSL
#define UNITYCOMMONDEF_HLSL
float4 _Time;

float3 SHEvalLinearL0L1(float4 normal, float4 SHAs[3])
{
	float3 x;

	// Linear (L1) + constant (L0) polynomial terms
	x.r = dot(SHAs[0], normal);
	x.g = dot(SHAs[1], normal);
	x.b = dot(SHAs[2], normal);


	return x;
}

// normal should be normalized, w=1.0
float3 SHEvalLinearL2(float4 normal, float4 SHBs[3], float3 SHC)
{
	float3 x1, x2;
	// 4 of the quadratic (L2) polynomials
	float4 vB = normal.xyzz * normal.yzzx;
	x1.r = dot(SHBs[0], vB);
	x1.g = dot(SHBs[1], vB);
	x1.b = dot(SHBs[2], vB);

	// Final (5th) quadratic (L2) polynomial
	float vC = normal.x*normal.x - normal.y*normal.y;
	x2 = SHC * vC;

	return x1 + x2;
}

// normal should be normalized, w=1.0
// output in active color space
float3 ShadeSH9(float3 normal,float4 SHAs[3],float4 SHBs[3],float3 SHC)
{
	float4 N = float4(normal, 1);
	// Linear + constant polynomial terms
	float3 res = SHEvalLinearL0L1(N, SHAs);

	// Quadratic polynomials
	res += SHEvalLinearL2(N, SHBs, SHC);

	return res;
}
#endif