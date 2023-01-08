using FMODUnity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMOD.Studio;
using UnityEngine.Playables;

public class AutoOverrideAttenuation : MonoBehaviour
{
    StudioEventEmitter emitter;
    public bool AutoOverrideDistances = true;

    void Awake()
    {
        if (AutoOverrideDistances && GetComponent<StudioEventEmitter>() != null)
        {
            emitter = GetComponent<StudioEventEmitter>();
            emitter.OverrideAttenuation = true;
            emitter.OverrideMaxDistance = 4f;
            emitter.OverrideMinDistance = 4f;
        }
    }
}
