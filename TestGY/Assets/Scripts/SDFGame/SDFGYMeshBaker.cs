using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class SDFGYMeshBaker : MonoBehaviour
{
    public Mesh mesh;
    public float normalEpsilon = 0.01f;
    public float normalEpsilonScale = 100.0f;
    public Texture3D meshSDF3D = null;
    public RenderTexture volu = null;
    public Texture3D meshNormal3D = null;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void BakeMeshNormalToTex3D()
    {
        if(meshSDF3D==null)
        {
            Debug.LogError("Need Mesh SDF 3D!");
            return;
        }
        var cs = Resources.Load<ComputeShader>("BakeCS/BakeMeshToSDF");
        Vector3Int size = new Vector3Int(meshSDF3D.width, meshSDF3D.height, meshSDF3D.depth);
        CreateRWTex3D(ref volu, size);
        float delta = normalEpsilon * normalEpsilonScale;
        //Debug.Log(size);
        //###########
        //### compute
        int kInx = cs.FindKernel("BakeMeshNormal");
        cs.SetTexture(kInx, "Result_meshNormal", volu);
        cs.SetTexture(kInx, "MeshSDF", meshSDF3D);
        cs.SetFloat("delta", delta);
        cs.Dispatch(kInx, size.x / 8, size.y / 8,size.z / 8);
        //### compute
        //###########
    }

    void CreateRWTex3D(ref RenderTexture volu, Vector3Int size)
    {
        volu = new RenderTexture(size.x, size.y, 0, RenderTextureFormat.ARGBFloat);
        volu.volumeDepth = size.z;
        volu.dimension = TextureDimension.Tex3D;
        volu.enableRandomWrite = true;
        volu.Create();
    }
}
