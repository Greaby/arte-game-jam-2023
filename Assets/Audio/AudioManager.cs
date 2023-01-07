using FMODUnity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMOD.Studio;
using UnityEngine.Playables;

public class AudioManager : MonoBehaviour
{

    private static AudioManager _instance;
    public static AudioManager Instance { get { return _instance; } }
    
    public StudioEventEmitter SEE_ButtonClick;
    
    private void Awake()
    {
        if (_instance != null && _instance != this)
        {
            Destroy(this.gameObject);
        }
        else
        {
            _instance = this;
        }
    }

    void Update()
    {
        
    }

    public void PlayButtonClickSound()
    {
        SEE_ButtonClick.Play();
    }
}
