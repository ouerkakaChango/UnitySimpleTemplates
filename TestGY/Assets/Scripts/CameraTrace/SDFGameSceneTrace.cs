﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FastGeo;
using Ray = FastGeo.Ray;
using Debugger;
using static StringTool.StringHelper;
using static MathHelper.XMathFunc;

//可能之后加点物理相机 https://ciechanow.ski/cameras-and-lenses/
public abstract class SDFCameraParam
{
    public int w = 1024, h = 720;
    public int camType = 0;//0:normal 1:orthogonal 2:Cubemap-SingleFaceCam
    public int camGammaMode = 0;

    public abstract void UpdateCamParam(ref Camera cam, float daoScale);
    public virtual void InsertParamToComputeShader(ref ComputeShader cs)
    {
        cs.SetInt("w", w);
        cs.SetInt("h", h);
        cs.SetInt("camType", camType);
        cs.SetInt("camGammaMode", camGammaMode);
    }

    public static void Copy(SDFCameraParam from, SDFCameraParam to)
    {
        to.w = from.w;
        to.h = from.h;
        to.camType = from.camType;
        to.camGammaMode = from.camGammaMode;
    }

    public void DoNothing()
    {

    }
}

public delegate void SimpleHandler();

//camType
//0-正常
//1-正交
//2-Cube烘培用(调整near)
public class SDFGameCameraParam : SDFCameraParam
{
    public float pixW, pixH;
    public Vector3 eyePos;
    public Vector3 screenLeftDownPix;
    public Vector3 screenU;
    public Vector3 screenV;
    public Vector3 camForward;
    public float camFar;
    public float camNear;
    public SimpleHandler paramFinalFunc = null;

    public SDFGameCameraParam() {
        paramFinalFunc = this.DoNothing;
    }

    public SDFGameCameraParam(SDFGameCameraParam p)
    {
        SDFCameraParam.Copy(p,this);
        Copy(p, this);
    }

    public static void Copy(SDFGameCameraParam from, SDFGameCameraParam to)
    {
        to.pixW = from.pixW;
        to.pixH = from.pixH;
        to.eyePos = from.eyePos;
        to.screenLeftDownPix = from.screenLeftDownPix;
        to.screenU = from.screenU;
        to.screenV = from.screenV;
        to.camForward = from.camForward;
        to.camFar = from.camFar;
        to.camNear = from.camNear;
        to.paramFinalFunc = from.paramFinalFunc;
    }

    public override void UpdateCamParam(ref Camera cam, float daoScale = 1.0f)
    {
        var obj = cam.gameObject;

        camNear = cam.nearClipPlane;
        var near = cam.nearClipPlane;
        near *= daoScale;

        //根据near和fov算出pixH
        float verticleFOV = cam.fieldOfView / 180.0f*Mathf.PI;

        //tan(half) = (0.5*H)/(near)
        float screenHeight = Mathf.Tan(verticleFOV * 0.5f) * near * 2;
        float screenWidth = screenHeight * cam.aspect;

        pixW = screenWidth / w;
        pixH = screenHeight / h;

        if (camType==2)
        {
            near = pixW * w /2.0f;
        }

        eyePos = obj.transform.position;
        camForward = obj.transform.forward;
        camFar = cam.farClipPlane;
        var screenPos = eyePos + near * camForward;
        screenU = obj.transform.right;
        screenV = obj.transform.up;

        screenLeftDownPix = screenPos + screenU * (-w / 2.0f + 0.5f) * pixW + screenV * (-h / 2.0f + 0.5f) * pixH;
        paramFinalFunc();
    }

    public override void InsertParamToComputeShader(ref ComputeShader cs)
    {
        base.InsertParamToComputeShader(ref cs);
        cs.SetFloat("pixW", pixW);
        cs.SetFloat("pixH", pixH);
        cs.SetVector("screenLeftDownPix", screenLeftDownPix);
        cs.SetVector("eyePos", eyePos);
        cs.SetVector("screenU", screenU);
        cs.SetVector("screenV", screenV);
        cs.SetVector("camForward", camForward);
        cs.SetFloat("camFar", camFar);
        cs.SetFloat("camNear", camNear);
    }
}

//[ExecuteInEditMode]
public class SDFGameSceneTrace : MonoBehaviour
{
    struct MeshInfo
    {
        public Matrix4x4 localToWorldMatrix;
    };

    bool hasDraw = false;
    int frameID = 0;
    const int CoreX = 8;
    const int CoreY = 8;
    public Vector2Int renderSize = new Vector2Int(1024, 720);
    public bool useIndirectRT = false;
    public float indirectMultiplier = 1.0f;

    //---Indirect
    Vector3 lastPos;
    Quaternion lastRot;
    //___

     RenderTexture rt;
    public RenderTexture rt_gyFinal = null;
    RenderTexture directRT = null;
     RenderTexture newFrontIndirectRT = null, frontIndirectRT =null,indirectRT = null;
     RenderTexture uselessRT = null;
    //FSR
    RenderTexture easuRT,finalRT;

    public bool useFSR = false;
    public float FSR_Scale = 2.0f;

    public string SceneName = "Undefined";
    public AutoCS autoCS;
    ComputeShader cs;
    ComputeShader cs_blendGYResult=null;
    ComputeShader cs_blendResult;
    ComputeShader cs_FSR;

    SDFGameCameraParam maincamParam;

    float daoScale = 1.0f;

    //--- Keyboard
    [HideInInspector]
    public KeyboardInputer keyboard;
    //___

    //---DepthRT
    public RenderTexture rt1,rt2;
    public RenderTexture rt_gyDepth;
    //___

    bool hasInited = false;
    //##########################################################################################
    void Start()
    {
        ReInit();
    }

    //private void Awake()
    //{
    //    ReInit();
    //}
    private void OnValidate()
    { 
        //ReInit();
    }
    RenderBuffer colorBuffer;

    void ReInit()
    {
        //if (Application.isEditor && !Application.isPlaying)
        //{
        //    //RefreshAutoCS();
        //}
        //else
        {
            var cam = GetComponent<Camera>();
            rt1 = new RenderTexture(renderSize.x,renderSize.y, 0,RenderTextureFormat.ARGBFloat);
            rt2 = new RenderTexture(renderSize.x, renderSize.y, 24, RenderTextureFormat.Depth);
            cam.SetTargetBuffers(rt1.colorBuffer, rt2.depthBuffer);

            //CreateRT(ref rt_camDepth, 1, renderSize.x, renderSize.y, 0, RenderTextureFormat.RFloat);

            maincamParam = new SDFGameCameraParam();
            maincamParam.w = renderSize.x;
            maincamParam.h = renderSize.y;
            QualitySettings.vSyncCount = 0;

            if (useIndirectRT)
            {
                CreateRT(ref directRT, 1, renderSize.x, renderSize.y);
                CreateRT(ref indirectRT, 1, renderSize.x, renderSize.y);
                CreateRT(ref frontIndirectRT, 1, renderSize.x, renderSize.y);
                CreateRT(ref newFrontIndirectRT, 1, renderSize.x, renderSize.y);
            }
            else
            {
                CreateRT(ref uselessRT, 1, 1, 1);
            }

            //StartCoroutine(GoIter());

            keyboard = GetComponent<KeyboardInputer>();
            if (keyboard == null)
            {
                Debug.Log("Warning: KeyboardInputer null.");
            }
            else
            {
                //keyboard.keyDic.Add("q", Dao_GetSmall);
                //keyboard.keyDic.Add("e", Dao_GetBig);
                //keyboard.keyDic.Add("1", TestChangeCamDir);
            }
        }
    }

    void Update()
    {
        if(frameID>0)
        {
            Vector3 dPos = abs(transform.position - lastPos);
            Vector3 dq = abs(transform.rotation.eulerAngles - lastRot.eulerAngles);
            if(dPos.magnitude>0.0 || dq.magnitude>0)
            {
                //!!! refresh indirectRender
                frameID = 0;          
            }
        }
        lastPos = transform.position;
        lastRot = transform.rotation;
    }

    private void OnDisable()
    {
        //SafeDispose(buffer_tris);
    }

    //private void OnPostRender()
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //Graphics.Blit(rt1, null as RenderTexture);
        //return;
        MainRenderFunc();
        if (rt == null)
        {
            return;
        }
        if (useFSR)
        {
            FSRProcessor.ProcessRT(ref cs_FSR, ref rt, ref easuRT, ref finalRT);
            Graphics.Blit(finalRT, (RenderTexture)null);
        }
        else
        {
            //Graphics.Blit((RenderTexture)rt1, trt);
            //CopyDepth(ref rt2, ref rt_camDepth);
            //###########
            //### compute
            //int kInx = cs_blendGYResult.FindKernel("BlendBAlpha");
            //cs_blendGYResult.SetTexture(kInx, "Result", rt_gyFinal);
            //cs_blendGYResult.SetTexture(kInx, "TexA", trt);
            //cs_blendGYResult.SetTexture(kInx, "TexB", rt);
            //cs_blendGYResult.Dispatch(kInx, renderSize.x / CoreX, renderSize.y / CoreY, 1);
            //### compute
            //###########

            var cam = GetComponent<Camera>();
            //###########
            //### compute
            int kInx = cs_blendGYResult.FindKernel("BlendABWithDepth");
            cs_blendGYResult.SetVector("_ZBufferParams", GetZBufferParams(cam.nearClipPlane, cam.farClipPlane));
            cs_blendGYResult.SetTexture(kInx, "Result", rt_gyFinal);
            cs_blendGYResult.SetTexture(kInx, "TexSceneA", rt1);
            cs_blendGYResult.SetTexture(kInx, "TexB", rt);
            cs_blendGYResult.SetTexture(kInx, "TexSceneAUnlinearDepth", rt2);
            cs_blendGYResult.SetTexture(kInx, "TexBNdcDepth", rt_gyDepth);
            cs_blendGYResult.Dispatch(kInx, renderSize.x / CoreX, renderSize.y / CoreY, 1);
            //### compute
            //###########
            Graphics.Blit(rt_gyFinal, destination);
        }
    }

    //##################################################################################################
    public void Dao_GetSmall()
    {
        daoScale *= 0.5f;
    }

    public void Dao_GetBig()
    {
        daoScale *= 2;
    }

    bool qToggle = true;
    public void TestChangeCamDir()
    {
        if (qToggle)
        {
            //Debug.Log("TestChangeCamDir");
            //new rot: -0.86 -99.21 -68.3
            gameObject.transform.rotation = Quaternion.Euler(-0.86f, -99.21f, -68.3f);
            var mouseLook = GetComponent<XCCamMouseLook>();
            mouseLook.RecordCamDir();
        }
        else
        {
            gameObject.transform.rotation = Quaternion.Euler(0, 0, 0);
            var mouseLook = GetComponent<XCCamMouseLook>();
            mouseLook.RecordCamDir();
        }
        qToggle = !qToggle;
    }

    public void AddKeybind_q()
    {
        keyboard.keyDic.Add("q", TestChangeCamDir);
    }

    //##################################################################################################

    static public void PreComputeBuffer(ref ComputeBuffer buffer, int stride, in System.Array dataArr)
    {
        if (buffer != null)
        {
            return;
        }
        buffer = new ComputeBuffer(dataArr.Length, stride);
        buffer.SetData(dataArr);
    }

    static public void PostComputeBuffer(ref ComputeBuffer buffer, System.Array arr)
    {
        return;
        //buffer.GetData(arr);
        //buffer.Dispose();
    }


    static public int GetRayStride()
    {
        int vec3Size = sizeof(float) * 3;
        return 2 * vec3Size;
    }
    //################################################################################################################
    void Compute_Render(ref ComputeShader computeShader, ref RenderTexture rTex, in SDFCameraParam camParam)
    {
        //###########
        //### compute
       //int kInx = cs_blendGYResult.FindKernel("SetRed");
       //cs_blendGYResult.SetTexture(kInx, "Result", rt);
       //cs_blendGYResult.Dispatch(kInx, renderSize.x / CoreX, renderSize.y / CoreY, 1);
       //### compute
       //###########
       //hasDraw = true;
       //return;
        if(!hasInited)
        {
            return;
        }

        //PreComputeBuffer(ref buffer_vertices, sizeof(float) * 3, vertices);
        //##################################
        //### compute
        int kInx = computeShader.FindKernel("Render");

        //####
        //System Value
        computeShader.SetInt("frameID", frameID);
        computeShader.SetFloat("daoScale", daoScale);
        computeShader.SetVector("_Time", Shader.GetGlobalVector("_Time"));
        //??? 写成for循环
        hasDraw = ShaderToyTool.Instance.noiseRGB != null;
        computeShader.SetTexture(kInx, "NoiseRGBTex", ShaderToyTool.Instance.noiseRGB);
        computeShader.SetTexture(kInx, "LUT_BRDF", ShaderToyTool.Instance.LUT_BRDF);
        computeShader.SetTexture(kInx, "perlinNoise1", ShaderToyTool.Instance.perlinNoise1);
        computeShader.SetTexture(kInx, "voronoiNoise1", ShaderToyTool.Instance.voronoiNoise1);
        computeShader.SetTexture(kInx, "blueNoise", ShaderToyTool.Instance.blueNoise);
        computeShader.SetTexture(kInx, "greyNoiseMedium", ShaderToyTool.Instance.greyNoiseMedium);
        computeShader.SetTexture(kInx, "RGBANoiseMedium", ShaderToyTool.Instance.RGBANoiseMedium);
        if (autoCS.texSys != null)
        {
            for (int i = 0; i < autoCS.texSys.outTextures.Count; i++)
            {
                computeShader.SetTexture(kInx, autoCS.texSys.outTextures[i].name, autoCS.texSys.outTextures[i].tex);
            }
        }
        else
        {
            //Debug.Log("Warning:No Texture Sys");
        }
        if (autoCS.dyValSys != null)
        {
            for (int i = 0; i < autoCS.dyValSys.outFloats.Count; i++)
            {
                computeShader.SetFloat(autoCS.dyValSys.outFloats[i].name, autoCS.dyValSys.outFloats[i].GetVal());
            }
        }
        else
        {
            //Debug.Log("Warning:No dyVal Sys");
        }
        //___
        //####

        computeShader.SetBool("useIndirectRT", useIndirectRT);
        if (useIndirectRT)
        {
            computeShader.SetTexture(kInx, "Result", directRT);
            computeShader.SetTexture(kInx, "IndirectResult", indirectRT);
        }
        else
        {
            computeShader.SetTexture(kInx, "Result", rTex);
            //!!! 反正不用到，但是参数要传进去，省得变shader代码
            computeShader.SetTexture(kInx, "IndirectResult", uselessRT);
            computeShader.SetTexture(kInx, "NdcDepthRT", rt_gyDepth);
        }

        camParam.InsertParamToComputeShader(ref computeShader);
        computeShader.Dispatch(kInx, renderSize.x / CoreX, renderSize.y / CoreY, 1);
        hasDraw = true;
        //### compute
        //#####################################;
        if (useIndirectRT)
        {
            //???
            //Blend dir+indir=>rTex
            //###########
            //### compute
            kInx = cs_blendResult.FindKernel("BlendFnial");
            cs_blendResult.SetInt("frameID", frameID);
            cs_blendResult.SetFloat("indirectMultiplier", indirectMultiplier);
            cs_blendResult.SetTexture(kInx, "Result", rTex);
            cs_blendResult.SetTexture(kInx, "Direct", directRT);
            cs_blendResult.SetTexture(kInx, "Indirect", indirectRT);
            cs_blendResult.SetTexture(kInx, "FrontIndirect", frontIndirectRT);
            cs_blendResult.SetTexture(kInx, "NewFrontIndirect", newFrontIndirectRT);
            cs_blendResult.SetTexture(kInx, "blueNoise", ShaderToyTool.Instance.blueNoise);
            cs_blendResult.Dispatch(kInx, renderSize.x / CoreX, renderSize.y / CoreY, 1);
            //### compute
            //###########
            //Copy newFrontIndirectRT to frontIndirectRT
            {
                //Graphics.CopyTexture(newFrontIndirectRT, frontIndirectRT);
                kInx = cs_blendResult.FindKernel("CopyToNewFront");
                cs_blendResult.SetTexture(kInx, "Result", frontIndirectRT);
                cs_blendResult.SetTexture(kInx, "NewFrontIndirect", newFrontIndirectRT);
                cs_blendResult.Dispatch(kInx, renderSize.x / CoreX, renderSize.y / CoreY, 1);
            }
        }
    }
    //####################################################################################

    void Init(ref RenderTexture rTex, in SDFCameraParam camParam)
    {
        if (rTex == null)
        {
            rTex = new RenderTexture(camParam.w, camParam.h, 0, RenderTextureFormat.ARGBFloat);
            rTex.enableRandomWrite = true;
            rTex.Create();
            if (useFSR)
            {
                CreateRT(ref easuRT, FSR_Scale, camParam.w, camParam.h);
                CreateRT(ref finalRT, FSR_Scale, camParam.w, camParam.h);
            }
            var csResourcesPath = ChopEnd(autoCS.outs[0], ".compute");
            csResourcesPath = ChopBegin(csResourcesPath, "Resources/");
            cs = (ComputeShader)Resources.Load(csResourcesPath);
            if(useIndirectRT)
            {
                cs_blendResult = (ComputeShader)Resources.Load("LightingCS/BlendFinal");
            }
            cs_FSR = (ComputeShader)Resources.Load("FSR/FSR");
        }
        if (rTex == rt)
        {
            hasInited = true;
        }
    }

    public void RefreshAutoCS()
    {
        autoCS.Generate();
    }

    void CreateRT(ref RenderTexture rTex, float scale, int w, int h, int depth = 0, RenderTextureFormat format = RenderTextureFormat.ARGBFloat)
    {
        rTex = new RenderTexture((int)(w* scale), (int)(h* scale), depth, format);
        rTex.enableRandomWrite = true;
        rTex.Create();
    }
    //####################################################################################

    static public void SafeDispose(ComputeBuffer cb)
    {
        if (cb != null)
        {
            cb.Dispose();
        }
    }

    public float GetDaoScale()
    {
        return daoScale;
    }
    //####################################################################################
    //IEnumerator Co_GoIter;
    //@@@
    private void OnGUI()
    {

    }



    void MainRenderFunc()
    {
        var cam = gameObject.GetComponent<Camera>();
        if (cs_blendGYResult == null)
        {
            //trt = new RenderTexture(maincamParam.w, maincamParam.h, 0, RenderTextureFormat.ARGBFloat);
            //trt.enableRandomWrite = true;
            //trt.Create();

            CreateRT(ref rt_gyFinal,1, maincamParam.w, maincamParam.h);
            CreateRT(ref rt_gyDepth, 1, maincamParam.w, maincamParam.h,0,RenderTextureFormat.RFloat);

            cs_blendGYResult = (ComputeShader)Resources.Load("LightingCS/BlendFinal");
            if (cs_blendGYResult == null)
            {
                Debug.LogError("Error loading cs_blendGYResult");
            }
            //Debug.Log("@@@@@@@@@@@@@@@@");
        }
        if (cam == null)
        {
            Debug.LogError("No Camera with SDFGameSceneTrace");
        }
        else
        {
            RenderCamToRT(ref rt, ref cam, maincamParam);
        }
        frameID += 1;
    }

    public void RenderCamToRT(ref RenderTexture rTex, ref Camera cam, in SDFCameraParam camParam)
    {
        Init(ref rTex, camParam);
        camParam.UpdateCamParam(ref cam, daoScale);
        Compute_Render(ref cs, ref rTex, camParam);
    }

    public Material depthCopyMat;
    void CopyDepth(ref RenderTexture src, ref RenderTexture tar)
    {
        Graphics.Blit(src, tar);
    }

    //代码:https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
    //推导:https://www.wgqing.com/lineareyedepth%E6%8E%A8%E5%AF%BC/
    Vector4 GetZBufferParams(float n, float f)
    {
        float x = (1 - f) / n;
        float y = f / n;
        float z = x / f;
        float w = y / f;
        return new Vector4(x, y, z, w);
    }
}
