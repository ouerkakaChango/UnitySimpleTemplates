using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;
using static MathHelper.Vec;

namespace XAudio
{
    public class AudioStarter : MonoBehaviour
    {
        public int gridEdge = 4;
        public AudioClip gridClip;
        public Sound[] sounds;
        public GameObject rootObj;
        public Vector3 grid = new Vector3(5, 5, 5);
        public GameObject[] gridObjs;
        private void Awake()
        {
            gridObjs = new GameObject[gridEdge* gridEdge];
            for(int j=0;j< gridEdge; j++)
            {
                for(int i=0;i< gridEdge; i++)
                {
                    Vector3 newPos = rootObj.transform.position + Mul(new Vector3(i,0,j),grid);
                    gridObjs[i + gridEdge * j] = new GameObject();
                    gridObjs[i + gridEdge * j].transform.parent = rootObj.transform;
                    gridObjs[i + gridEdge * j].transform.position = newPos;
                }
            }
            sounds = new Sound[gridObjs.Length];
            for (int i = 0; i < sounds.Length; i++)
            {
                sounds[i] = new Sound();
                //Debug.Log(sounds[i] != null);
                sounds[i].obj = gridObjs[i];
                float rr = Random.Range(0f, 1f);
                //Debug.Log(rr);
                sounds[i].startTime = 3.0f*rr;
                sounds[i].clip = gridClip;

                sounds[i].source = sounds[i].obj.AddComponent<AudioSource>();
                sounds[i].source.clip = sounds[i].clip;
                sounds[i].source.volume = sounds[i].volume;
                sounds[i].source.loop = sounds[i].loop;
                sounds[i].source.playOnAwake = false;
                sounds[i].source.spatialBlend = 1;
                sounds[i].source.spread = 100;
                sounds[i].source.minDistance = 20;
                sounds[i].source.maxDistance = 1000;
            }
        }

        // Start is called before the first frame update
        void Start()
        {
            for(int i=0;i<sounds.Length;i++)
            {
                sounds[i].source.PlayDelayed(sounds[i].startTime);
            }
        }

        // Update is called once per frame
        void Update()
        {
        }
    }

}
