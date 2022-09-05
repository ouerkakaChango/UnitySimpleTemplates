Shader "Fur/DirFurRimColorShader"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(0.01, 256.0)) = 8.0
        
        _MainTex ("Texture", 2D) = "white" { }
        _FurTex ("Fur Pattern", 2D) = "white" { }
        
        _FurLength ("Fur Length", Range(0.0, 1)) = 0.5
        _FurDensity ("Fur Density", Range(0, 2)) = 0.11
        _FurThinness ("Fur Thinness", Range(0.01, 10)) = 1
        _FurShading ("Fur Shading", Range(0.0, 1)) = 0.25

        //_ForceGlobal ("Force Global", Vector) = (0, 0, 0, 0)
		_DirTex("DirTex", 2D) = "blue" { }
        _ForceLocal ("Force Local", Vector) = (0, 0, 0, 0)
        
        _RimColor ("Rim Color", Color) = (0, 0, 0, 1)
        _RimPower ("Rim Power", Range(0.0, 8.0)) = 6.0

		_AnisoRoughness("AnisoRoughness", Range(0.0, 1.0)) = 0.5
		_AnisoSpecular("AnisoSpecular", Color) = (0, 0, 0, 1)
		_AnisoIntensity("AnisoIntensity", Float) = 1
    }
    
    Category
    {

        Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" }
		//Tags { "RenderType" = "TransparentCutout" "IgnoreProjector" = "True" "Queue" = "AlphaTest" }
        Cull Back
        ZWrite On
		ZTest LEqual
        Blend SrcAlpha OneMinusSrcAlpha
        
        SubShader
        {
			//###BLOCK AutoGenerate
			Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_surface
	#pragma fragment frag_surface
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.00
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_surface
	#pragma fragment frag_surface_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.00
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.05
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.05
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.1
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.1
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.15
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.15
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.2
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.2
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.25
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.25
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.3
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.3
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.35
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.35
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.4
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.4
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.45
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.45
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.5000001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.5000001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.5500001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.5500001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.6000001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.6000001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.6500001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.6500001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.7000001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.7000001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.7500001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.7500001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.8000001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.8000001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.8500001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.8500001
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.9000002
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.9000002
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 0.9500002
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 0.9500002
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardBase" }
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base
	#pragma multi_compile_fwdbase

	#define FURSTEP 1
	#include "DirFurHelper.cginc"

	ENDCG
}

Pass
{
	Tags { "LightMode" = "ForwardAdd" }
	ZWrite Off
	ZTest Equal
	Blend SrcAlpha One
	CGPROGRAM

	#pragma vertex vert_base
	#pragma fragment frag_base_add
	#pragma multi_compile_fwdadd

	#define FURSTEP 1
	#include "DirFurHelper.cginc"

	ENDCG
}


			//###
        }
    }
}