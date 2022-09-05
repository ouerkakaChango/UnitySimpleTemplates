using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(PassDuplicator))]
public class PassDuplicatorEditor : Editor
{
    PassDuplicator Target;
    void OnEnable()
    {
        Target = (PassDuplicator)target;
    }

    //@@@
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (GUILayout.Button("Create"))
        {
            Target.Create();
        }

        GUILayout.TextArea(Target.GetFinalString());

    }
}
