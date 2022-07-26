using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XCGame;
public class GameSceneSystem : MonoBehaviour
{
    public GameObject nextLevelObj;
    public SDFGameSceneTrace trace;
    public List<TriggerAction> startActions = new List<TriggerAction>();
    // Start is called before the first frame update
    void Start()
    {
        if(trace==null)
        {
            Debug.Log("Warning:No trace for GameSceneSystem ");
            return;
        }
        var keyboard = trace.gameObject.GetComponent<KeyboardInputer>();
        if(!keyboard)
        {
            Debug.LogError("FFF");
        }
        for (int i = 0; i < startActions.Count; i++)
        {
            var action = startActions[i];
            if (action == TriggerAction.TestKeyBind_qe)
            {
                keyboard.keyDic.Add("q", trace.Dao_GetSmall);
                keyboard.keyDic.Add("e", trace.Dao_GetBig);
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
