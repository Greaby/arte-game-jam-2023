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
    public StudioEventEmitter SEE_DialogueBodyParts;
    public StudioEventEmitter SEE_DialogueDoor;
    public StudioEventEmitter SEE_Lose;
    public StudioEventEmitter SEE_Win;

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

    public void PlayButtonClickSound()
    {
        SEE_ButtonClick.Play();
    }

    public void PlayMusic()
    {
        SEE_Music.Play();
    }
    public void StopMusic()
    {
        SEE_Music.Stop();
    }

    public void PlayPickupSound()
    {
        SEE_Pickup.Play();
    }

    public void PlayLoseSound()
    {
        SEE_Lose.Play();
    }

    public void PlayWinSound()
    {
        SEE_Win.Play();
    }

    public void PlayDialogBodyPartsSound()
    {
        SEE_DialogueBodyParts.Play();
    }
    public void StopDialogBodyPartsSound()
    {
        SEE_DialogueBodyParts.Stop();
    }

    public void PlayDialogDoorSound()
    {
        SEE_DialogueBodyParts.Play();
    }
    public void StopDialogDoorSound()
    {
        SEE_DialogueBodyParts.Stop();
    }
}
