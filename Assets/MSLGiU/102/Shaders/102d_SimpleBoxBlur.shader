Shader "MSLGiU/102/102d_SimpleBoxBlur" {
  Properties {
    _MainTex("Texture", 2D) = "white" {}
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
      float4 _MainTex_TexelSize;

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

      float4 box(sampler2D tex, float2 uv, float4 size) {
        float4 c = tex2D(tex, uv + float2(-size.x, size.y)) + tex2D(tex, uv + float2(0, size.y)) + tex2D(tex, uv + float2(size.x, size.y)) +
                   tex2D(tex, uv + float2(-size.x, 0)) + tex2D(tex, uv + float2(0, 0)) + tex2D(tex, uv + float2(size.x, 0)) +
                   tex2D(tex, uv + float2(-size.x, -size.y)) + tex2D(tex, uv + float2(0, -size.y)) + tex2D(tex, uv + float2(size.x, -size.y));
        
        return c / 9;
      }

      float4 frag(v2f i) : SV_Target {
        float4 col = box(_MainTex, i.uv, _MainTex_TexelSize);
        return col;
      }

      ENDCG
    }
  }
}