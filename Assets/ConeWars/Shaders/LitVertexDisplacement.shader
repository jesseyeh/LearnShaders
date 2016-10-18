Shader "ConeWars/LitVertexDisplacement" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _Speed("Speed", Range(0.1, 4)) = 1
        _Amount("Amount", Range(0.1, 10)) = 3
        _Distance("Distance", Range(0, 2)) = 0.3
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        }
;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        float _Speed;
        float _Amount;
        float _Distance;

        float4 getNewVertPosition(float4 p) {
            p.x += sin(_Time.y * _Speed + p.y * _Amount) * _Distance;
            return p;
        }

        void vert(inout appdata_full v) {
            // calculate bitangent with a cross product (see right-hand rule)
            float4 position = getNewVertPosition(v.vertex);

            // calculate the bitangent using the cross product between the normal and the tangent
            float4 bitangent = float4(cross(v.normal, v.tangent), 0);

            // how far to offset the vert position to calculate the new normal
            float vertOffset = 0.01;
            float4 positionAndTangent = getNewVertPosition(v.vertex + v.tangent * vertOffset);
            float4 positionAndBitangent = getNewVertPosition(v.vertex + bitangent * vertOffset);

            // create the new tangents and bitangents based on the deformed positions
            float4 newTangent = positionAndTangent - position;     // leaves just "tangent"
            float4 newBitangent = positionAndBitangent - position; // leaves just "bitangent"

            float4 newNormal = float4(cross(newTangent, newBitangent), 0);
            v.normal = newNormal;
            v.vertex = position;
        }

        void surf (Input IN, inout SurfaceOutputStandard o) {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
