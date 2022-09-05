using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PassDuplicator : MonoBehaviour
{
    List<string> final = new List<string>();
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    //Pass
    //{
    //    Tags { "LightMode" = "ForwardBase" } //ForwardBase ForwardAdd
    //    CGPROGRAM
    //    
    //    #pragma vertex vert_base
    //    #pragma fragment frag_base
    //    #pragma multi_compile_fwdbase

    //    #define FURSTEP 0.05
    //    #include "DirFurHelper.cginc"
    //    
    //    ENDCG 
    //}

    //Pass
    //{
    //    Tags { "LightMode" = "ForwardAdd" }
    //    Blend One One
    //    CGPROGRAM
    //    
    //    #pragma vertex vert_surface
    //    #pragma fragment frag_surface_add
    //    #pragma multi_compile_fwdadd
    //    
    //    #define FURSTEP 0.00
    //    #include "DirFurHelper.cginc"
    //    
    //    ENDCG
    //}
    public void Create_old()
    {
        List<string> block = new List<string>();
        /*00*/block.Add("Pass");
        /*01*/block.Add("{");
        /*02*/block.Add("    Tags { \"LightMode\" = \"ForwardBase\" }");
        /*03*/block.Add("    CGPROGRAM");
        /*04*/block.Add("");
        /*05*/block.Add("    #pragma vertex vert_base");
        /*06*/block.Add("    #pragma fragment frag_base");
        /*07*/block.Add("    #pragma multi_compile_fwdbase");
        /*08*/block.Add("");
        /*09*/block.Add("    #define FURSTEP 0.05");
        /*10*/block.Add("    #include \"DirFurHelper.cginc\"");
        /*11*/block.Add("");
        /*12*/block.Add("    ENDCG");
        /*13*/block.Add("}");

        List<string> surfaceBlock = new List<string>(block.ToArray());
        surfaceBlock[5] = "    #pragma vertex vert_surface";
        surfaceBlock[6] = "    #pragma fragment frag_surface";
        surfaceBlock[9] = "    #define FURSTEP 0.00";

        final.Clear();
        final.AddRange(surfaceBlock);
        final.Add("");
        //ForwardBase
        for (float step=0.05f;step<1.05f;step+=0.05f)
        {
            var temp = new List<string>(block.ToArray());
            temp[9] = "    #define FURSTEP " + step;
            final.AddRange(temp);
            final.Add("");
        }

        var surface2 = new List<string>(surfaceBlock.ToArray());
        surface2[2] = "    Tags { \"LightMode\" = \"ForwardAdd\" }";
        surface2[6] = "    #pragma fragment frag_surface_add";
        surface2[7] = "    #pragma multi_compile_fwdadd";
        surface2.Insert(3, "    Blend One One");
        surface2.Insert(3, "    ZTest Equal");

        final.AddRange(surface2);
        final.Add("");
        //ForwardAdd
        for (float step = 0.05f; step < 1.05f; step += 0.05f)
        {
            var temp = new List<string>(block.ToArray());
            temp[2] = "    Tags { \"LightMode\" = \"ForwardAdd\" }";
            temp[6] = "    #pragma fragment frag_base_add";
            temp[7] = "    #pragma multi_compile_fwdadd";
            temp[9] = "    #define FURSTEP " + step;
            temp.Insert(3, "    Blend One One");
            temp.Insert(3, "    ZTest Equal");
            temp.Insert(3, "    ZWrite Off");
            final.AddRange(temp);
            final.Add("");
        }
    }

    public void Create()
    {
        List<string> block = new List<string>();
        /*00*/
        block.Add("Pass");
        /*01*/
        block.Add("{");
        /*02*/
        block.Add("    Tags { \"LightMode\" = \"ForwardBase\" }");
        /*03*/
        block.Add("    CGPROGRAM");
        /*04*/
        block.Add("");
        /*05*/
        block.Add("    #pragma vertex vert_base");
        /*06*/
        block.Add("    #pragma fragment frag_base");
        /*07*/
        block.Add("    #pragma multi_compile_fwdbase");
        /*08*/
        block.Add("");
        /*09*/
        block.Add("    #define FURSTEP 0.05");
        /*10*/
        block.Add("    #include \"DirFurHelper.cginc\"");
        /*11*/
        block.Add("");
        /*12*/
        block.Add("    ENDCG");
        /*13*/
        block.Add("}");

        List<string> surfaceBlock = new List<string>(block.ToArray());
        surfaceBlock[5] = "    #pragma vertex vert_surface";
        surfaceBlock[6] = "    #pragma fragment frag_surface";
        surfaceBlock[9] = "    #define FURSTEP 0.00";

        final.Clear();
        final.AddRange(surfaceBlock);
        final.Add("");
        var surface2 = new List<string>(surfaceBlock.ToArray());
        surface2[2] = "    Tags { \"LightMode\" = \"ForwardAdd\" }";
        surface2[6] = "    #pragma fragment frag_surface_add";
        surface2[7] = "    #pragma multi_compile_fwdadd";
        surface2.Insert(3, "    Blend One One");
        surface2.Insert(3, "    ZTest Equal");

        final.AddRange(surface2);
        final.Add("");

        //ForwardBase
        for (float step = 0.05f; step < 1.05f; step += 0.05f)
        {
            var temp2 = new List<string>(block.ToArray());
            temp2[9] = "    #define FURSTEP " + step;
            final.AddRange(temp2);
            final.Add("");

            var temp = new List<string>(block.ToArray());
            temp[2] = "    Tags { \"LightMode\" = \"ForwardAdd\" }";
            temp[6] = "    #pragma fragment frag_base_add";
            temp[7] = "    #pragma multi_compile_fwdadd";
            temp[9] = "    #define FURSTEP " + step;
            temp.Insert(3, "    Blend One One");
            temp.Insert(3, "    ZTest Equal");
            temp.Insert(3, "    ZWrite Off");
            final.AddRange(temp);
            final.Add("");
        }
    }

    public string GetFinalString()
    {
        string re = "";
        for(int i=0;i<final.Count;i++)
        {
            re += final[i];
            re += "\n";
        }
        return re;
    }
}
