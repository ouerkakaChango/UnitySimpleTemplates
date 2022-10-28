using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

namespace XAudio
{
    [System.Serializable]
    public class Sound
    {
        public AudioClip clip;
        [Range(0f,1f)]
        public float volume = 1f;
        public GameObject obj;
        public bool loop = true;
        public float startTime = 0f;

        [HideInInspector]
        public AudioSource source;
    }
}
