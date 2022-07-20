using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleSkyCycle : MonoBehaviour
{
    public float secondsPerMinute = 0.625f; 

    //starting time in hours, use decimal points for minutes
    public float startTime  = 12.0f; 
    
    //show date/time information?
    public bool showGUI = false;
    
    //this floatiable is for the position of the area in degrees from the equator, therfore it must stay between 0 and 90.
    //It determines now high the sun rises throughout the day, but not the length of the day yet.
    public float latitudeAngle = 45.0f;
    
    //The transform component of the empty that tilts the sun's roataion.(the SunTilt object, not the Sun object itself)
    public Transform sunTilt;
    
    
    private float day  ;
    private float min  ;
    private float smoothMin  ;
    
    private float texOffset  ;
    private Material skyMat ;
    private Transform sunOrbit;
    // Start is called before the first frame update
    void Start()
    {
        var mr = GetComponent<MeshRenderer>();
        if(mr==null)
        {
            return;
        }

        skyMat = mr.sharedMaterial;
        sunOrbit = sunTilt.GetChild(0);

        var rot1 = sunTilt.eulerAngles;
        rot1.x = Mathf.Clamp(latitudeAngle, 0, 90); //set the sun tilt
        sunTilt.eulerAngles = rot1;

        if (secondsPerMinute == 0)
        {
            Debug.LogError("Error! Can't have a time of zero, changed to 0.01 instead.");
            secondsPerMinute = 0.01f;
        }
    }

    // Update is called once per frame
    void Update()
    {
        UpdateSky();
    }

    //###########
    void UpdateSky()
    {
        smoothMin = (Time.time / secondsPerMinute) + (startTime * 60);
        day = Mathf.Floor(smoothMin / 1440) + 1;

        smoothMin = smoothMin - (Mathf.Floor(smoothMin / 1440) * 1440); //clamp smoothMin between 0-1440
        min = Mathf.Round(smoothMin);

        var rot1 = sunOrbit.localEulerAngles;
        rot1.y = smoothMin / 4;
        sunOrbit.localEulerAngles = rot1;

        texOffset = Mathf.Cos((((smoothMin) / 1440) * 2) * Mathf.PI) * 0.25f + 0.25f;
        skyMat.mainTextureOffset = new Vector2(Mathf.Round((texOffset - (Mathf.Floor(texOffset / 360) * 360)) * 1000) / 1000, 0);
    }
}
