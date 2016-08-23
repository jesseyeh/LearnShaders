using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode]
public class ReplacementShaderEffect : MonoBehaviour {
  public Shader ReplacementShader;
  public Color OverDrawColor;

  // called when script is loaded or value is changed in the inspector
  void OnValidate() {
    Shader.SetGlobalColor("_OverDrawColor", OverDrawColor);
  }

  void OnEnable() {
    if(ReplacementShader != null)
      // passing in "" for the tag will only apply the first subshader
      // in the case of OverDraw, we want everything to use the same subshader
      GetComponent<Camera>().SetReplacementShader(ReplacementShader, "");
  }

  void OnDisable() {
    GetComponent<Camera>().ResetReplacementShader();
  }
}