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
    public StudioEventEmitter SEE_Music;
    public StudioEventEmitter SEE_Pickup;

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
    public void PlayMusic()
    {
        SEE_Music.Play();
    }
    public void PlayPickupSound()
    {
        SEE_Pickup.Play();
    }
}
