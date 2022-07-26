#ifndef NOISECOMMONDEF_HLSL
#define NOISECOMMONDEF_HLSL
//https ://www.shadertoy.com/view/ldScDh
Texture2D NoiseRGBTex;
Texture2D perlinNoise1,voronoiNoise1,blueNoise, greyNoiseMedium, RGBANoiseMedium;

SamplerState noise_linear_repeat_sampler;
float noise_texBase(in float3 x)
{
	float3 p = floor(x);
	float3 f = frac(x);
	f = f * f*(3.0 - 2.0*f);
	float2 uv = (p.xy + float2(37.0, 17.0)*p.z) + f.xy;
	float2 rg = NoiseRGBTex.SampleLevel(noise_linear_repeat_sampler, (uv + 0.5)/256, 0).yx;
	return lerp(rg.x, rg.y, f.z);
}
 
float iqhash(float n)
{
	return frac(sin(n)*43758.5453);
}

float noise_computational(in float3 x)
{
	// The noise function returns a value in the range -1.0f -> 1.0f
	float3 p = floor(x);
	float3 f = frac(x);

	f = f * f*(3.0 - 2.0*f);
	float n = p.x + p.y*57.0 + 113.0*p.z;
	return lerp(lerp(lerp(iqhash(n + 0.0), iqhash(n + 1.0), f.x),
		lerp(iqhash(n + 57.0), iqhash(n + 58.0), f.x), f.y),
		lerp(lerp(iqhash(n + 113.0), iqhash(n + 114.0), f.x),
			lerp(iqhash(n + 170.0), iqhash(n + 171.0), f.x), f.y), f.z);
}

float noise(in float3 x)
{
	return noise_texBase(x);
	//return noise_computational(x);
}

float ppnoise(in float3 x)
{
	return perlinNoise1.SampleLevel(noise_linear_repeat_sampler, x.xy, 0).r;
}

float3 hash3(float3 p) {  						// rand in [-1,1]
	p = float3(dot(p, float3(127.1, 311.7, 213.6)),
		dot(p, float3(327.1, 211.7, 113.6)),
		dot(p, float3(269.5, 183.3, 351.1)));
	return -1. + 2.*frac(sin(p)*43758.5453123);
}
float noise3(in float3 p) {
	float3 i = floor(p), f = frac(p);
	float3 u = f * f*(3. - 2.*f);
	float re =  lerp( 
		lerp(lerp(dot(hash3(i + float3(0., 0., 0.)), f - float3(0., 0., 0.)),
			dot(hash3(i + float3(1., 0., 0.)), f - float3(1., 0., 0.)), u.x),
			lerp(dot(hash3(i + float3(0., 1., 0.)), f - float3(0., 1., 0.)),
				dot(hash3(i + float3(1., 1., 0.)), f - float3(1., 1., 0.)), u.x), u.y),
		lerp(lerp(dot(hash3(i + float3(0., 0., 1.)), f - float3(0., 0., 1.)),
			dot(hash3(i + float3(1., 0., 1.)), f - float3(1., 0., 1.)), u.x),
			lerp(dot(hash3(i + float3(0., 1., 1.)), f - float3(0., 1., 1.)),
				dot(hash3(i + float3(1., 1., 1.)), f - float3(1., 1., 1.)), u.x), u.y),
		u.z);
	return 0.5*(re + 1);
}

float fbm4(in float3 p)
{
	float n = 0.0;
	n += 1.000*noise(p*1.0);
	n += 0.500*noise(p*2.0); 
	n += 0.250*noise(p*4.0);
	n += 0.125*noise(p*8.0);
	return n;
}

float fbm4_01(in float3 p)
{
	return fbm4(p) / (1 + 0.5 + 0.25 + 0.125);
}

float fbm3(in float3 p)
{
	float n = 0.0;
	n += 1.000*noise(p*1.0);
	n += 0.500*noise(p*2.0);
	n += 0.250*noise(p*4.0);
	return n;
}

float perlinNoiseFromTex(float2 uv)
{
	return perlinNoise1.SampleLevel(noise_linear_repeat_sampler, uv, 0).r;
}

float voronoiNoiseFromTex(float2 uv)
{
	return voronoiNoise1.SampleLevel(noise_linear_repeat_sampler, uv, 0).r;
}

//https://www.shadertoy.com/view/NldfRl
void SmoothWithDither(inout float3 color, in float2 uv)
{
	int2 fragCoord = uv * 1024;//blueNoise is 1024*1024
	color += blueNoise.Load(int3(fragCoord & 1023, 0)).rgb * (1.0 / 256.0);//For our mornitor only support 32bit 
}
#endif