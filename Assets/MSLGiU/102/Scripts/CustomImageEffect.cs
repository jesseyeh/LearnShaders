using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class CustomImageEffect : MonoBehaviour {

  public Material EffectMaterial;

  void OnRenderImage(RenderTexture src, RenderTexture dst) {
    // "render this src to that dst with this material"
    Graphics.Blit(src, dst, EffectMaterial);
  }
}
