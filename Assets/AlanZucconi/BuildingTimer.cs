using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BuildingTimer : MonoBehaviour {

    public Material material;

    public float minY = 0f;
    public float maxY = 2f;
    public float duration = 5f;

    void Update() {
        float y = Mathf.PingPong(Time.time * maxY / duration, maxY);
        material.SetFloat("_ConstructY", y);
    }
}
