using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SDFGYMeshBaker))]
public class SDFGYMeshBakerEditor : Editor
{
    SDFGYMeshBaker Target;

    void OnEnable()
    {
        Target = (SDFGYMeshBaker)target;
    }
     
    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if(GUILayout.Button("BakeMeshNormalToTex3D"))
        {
            Target.BakeMeshNormalToTex3D();
        }

        if(GUILayout.Button("SaveNormVolu"))
        {
            AssetDatabase.CreateAsset(Target.volu, "Assets/Norm_Bunny.asset");
        }
    }
}
