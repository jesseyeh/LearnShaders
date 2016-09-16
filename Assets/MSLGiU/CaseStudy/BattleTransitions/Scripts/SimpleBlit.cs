using UnityEngine;
using System.Collections;

public class SimpleBlit : MonoBehaviour {

  public Material TransitionMaterial;

  void OnRenderImage(RenderTexture src, RenderTexture dst) {
    Graphics.Blit(src, dst, TransitionMaterial);
  }
}
