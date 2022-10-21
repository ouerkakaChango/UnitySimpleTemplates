using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CommonGizmoHelper : MonoBehaviour
{
    public bool meshHideInGame = false;
    // Start is called before the first frame update
    void Start()
    {
        if(meshHideInGame)
        {
            var mr = gameObject.GetComponent<MeshRenderer>();
            mr.enabled = false;
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
