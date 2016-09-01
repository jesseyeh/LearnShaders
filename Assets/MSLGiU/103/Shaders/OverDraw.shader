Shader "MSLGiU/103/OverDraw"
{
	SubShader
	{
		Tags
		{
      // render the replacement shader over the skybox
			"Queue" = "Transparent"
		}

		ZTest Always  // regardless of what is in the depth buffer, this will always be drawn
		ZWrite Off    // either ZTest Always or ZWrite Off is sufficient
		Blend One One // additive

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}

			half4 _OverDrawColor;

			fixed4 frag(v2f i) : SV_Target
			{
				return _OverDrawColor;
			}
			ENDCG
		}
	}
}
