Shader "MSLGiU/101/101e_Exercise3" {
  Properties {
    _MainTex("Texture", 2D) = "white" {}
    _SecondTex("Second Texture", 2D) = "white" {}
    _Tween("Tween", Range(0, 1)) = 0
  }
  SubShader {
    Tags {
      // make sprites render after opaque geometry
      "Queue" = "Transparent"
    }
    Pass {
      // SrcColor * SrcAlpha + DstColor * OneMinusSrcALpha
      Blend SrcAlpha OneMinusSrcAlpha
      
      CGPROGRAM
      #pragma vertex vert
      #pragma fragment frag

      // user-defined vars
      sampler2D _MainTex;
      sampler2D _SecondTex;
      float _Tween;

      #include "UnityCG.cginc"

      struct appdata {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
      };
      struct v2f {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
      };

      v2f vert(appdata v) {
        v2f o;
        // does matrix multiplication on local vertex to transform it from a point on the object to a point on the screen
        o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
        o.uv = v.uv;
        return o;
      }

      float4 frag(v2f i) : SV_Target {
        // draw white pixels to the screen
        float4 color1 = tex2D(_MainTex, i.uv);
        float4 color2 = tex2D(_SecondTex, i.uv);
        float4 color = lerp(color1, color2, _Tween);
        return color;
      }

      ENDCG
    }
  }
}