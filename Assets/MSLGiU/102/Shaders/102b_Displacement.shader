Shader "MSLGiU/102/102b_Displacement" {
  Properties {
    _MainTex("Texture", 2D) = "white" {}
    _DisplacementTex("Displacement Texture", 2D) = "white" {}
    _Magnitude("Magnitude", Range(0, 0.1)) = 1
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
      sampler2D _DisplacementTex;
      float _Magnitude;

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
        float2 disp = tex2D(_DisplacementTex, i.uv).xy;
        // transform range from 0 to 1 -> -1 to 1
        disp = ((disp * 2) - 1) * _Magnitude;

        float4 col = tex2D(_MainTex, i.uv + disp);
        return col;
      }

      ENDCG
    }
  }
}