﻿Shader "DavidLeon/CelShadingForward" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf CelShadingForward
		#pragma target 3.0

		struct Input {
			float2 uv_MainTex;
		};
		
		sampler2D _MainTex;
		fixed4 _Color;

		// calculates NdotL, then polarizes it to 0 or 1
		half4 LightingCelShadingForward(SurfaceOutput s, half3 lightDir, half atten) {
			half NdotL = dot(s.Normal, lightDir);
			/*
			if(NdotL <= 0.0)
				NdotL = 0;
			else
				NdotL = 1;
			*/

			NdotL = 1 + clamp(floor(NdotL), -1, 0);
			// NdotL = smoothstep(0, 0.025f, NdotL);

			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten * 2);
			c.a = s.Alpha;
			return c;
		}

		void surf(Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
