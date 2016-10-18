Shader "ConeWars/MeltVertexDisplacementHardEdge" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _MeltY("Melt Y", Float) = 0.0
        _MeltDistance("Melt Distance", Float) = 1.0
        _MeltCurve("Melt Curve", Range(1.0, 10.0)) = 2.0

        _MeltColor("Color", Color) = (1, 1, 1, 1)
        _MeltGlossiness("Smoothness", Range(0, 1)) = 0.0
        _MeltMetallic("Metallic", Range(0, 1)) = 0.0
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

            // add here to pass data from the vertex shader to the surface shader
            float pixelMelt;
        }
;
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        half _MeltY;
        half _MeltDistance;
        half _MeltCurve;

        fixed4 _MeltColor;
        half _MeltGlossiness;
        half _MeltMetallic;

        //---------------------------------------------------------------------
        float4 getNewVertPosition(float4 objectSpacePosition, float3 objectSpaceNormal, out float pixelMelt) {
            // conver the position and normal from object space to world space
            float4 worldSpacePosition = mul(unity_ObjectToWorld, objectSpacePosition);
            float4 worldSpaceNormal = mul(unity_ObjectToWorld, float4(objectSpaceNormal, 0));
            
            // _MeltY is like a threshold and _MeltDistance is like a tolerance range
            float melt = (worldSpacePosition.y - _MeltY) / _MeltDistance;
            // make melt correspond to 0 for not melted, 1 for fully melted
            melt = 1 - saturate(melt);

            // set the melt value
            pixelMelt = melt;

            // take the linear 0 - 1 melt value and give it a curve
            melt = pow(melt, _MeltCurve);

            // push the vert out forwards and sideways by the melt amount
            worldSpacePosition.xz += worldSpaceNormal.xz * melt;

            // return to object space
            return mul(unity_WorldToObject, worldSpacePosition);
        }

        //---------------------------------------------------------------------
        void vert(inout appdata_full v, out Input o) {
            // need to initialize all values correctly when adding custom data to Input
            // especially important when it is a parameter for the custom vert function
            UNITY_INITIALIZE_OUTPUT(Input, o);

            float pixelMelt = 0.0;

            // calculate bitangent with a cross product (see right-hand rule)
            float4 position = getNewVertPosition(v.vertex, v.normal, pixelMelt);

            // set here to pass the variable to the surface shader
            o.pixelMelt = pixelMelt;

            // calculate the bitangent using the cross product between the normal and the tangent
            float4 bitangent = float4(cross(v.normal, v.tangent), 0);

            // how far to offset the vert position to calculate the new normal
            float vertOffset = 0.01;
            float4 positionAndTangent = getNewVertPosition(v.vertex + v.tangent * vertOffset, v.normal, pixelMelt);
            float4 positionAndBitangent = getNewVertPosition(v.vertex + bitangent * vertOffset, v.normal, pixelMelt);

            // create the new tangents and bitangents based on the deformed positions
            float4 newTangent = positionAndTangent - position;     // leaves just "tangent"
            float4 newBitangent = positionAndBitangent - position; // leaves just "bitangent"

            float4 newNormal = float4(cross(newTangent, newBitangent), 0);
            v.normal = newNormal;
            v.vertex = position;
        }

        //---------------------------------------------------------------------
        void surf (Input IN, inout SurfaceOutputStandard o) {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            float hardMelt = step(0.5, IN.pixelMelt);

            o.Albedo = lerp(c.rgb, _MeltColor.rgb, hardMelt);
            // Metallic and smoothness come from slider variables
            o.Metallic = lerp(_Metallic, _MeltMetallic, hardMelt);
            o.Smoothness = lerp(_Glossiness, _MeltGlossiness, hardMelt);
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
