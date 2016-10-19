Shader "ConeWars/MeltDisplacementTessellation" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _MeltY("Melt Y", Float) = 0.0
        _MeltDistance("Melt Distance", Float) = 1.0
        _MeltCurve("Melt Curve", Range(1.0, 10.0)) = 2.0

        _Tess("Tessellation Amount", Range(1, 32)) = 10

        _MeltColor("Color", Color) = (1, 1, 1, 1)
        _MeltGlossiness("Smoothness", Range(0, 1)) = 0.0
        _MeltMetallic("Metallic", Range(0, 1)) = 0.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:disp addshadow tessellate:tessDistance nolightmap

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        #include "Tessellation.cginc"

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
            float3 worldPos;
        };

        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float2 texcoord : TEXCOORD0;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        half _MeltY;
        half _MeltDistance;
        half _MeltCurve;

        float _Tess;

        half _MeltGlossiness;
        half _MeltMetallic;
        fixed4 _MeltColor;

        //---------------------------------------------------------------------
        // add tess verts if the vertex is within the melt range
        float MeltCalcDistanceTessFactor(float4 vertex, float minDist, float maxDist, float tess) {
            float3 wpos = mul(unity_ObjectToWorld, vertex).xyz;
            float dist = distance(wpos, _WorldSpaceCameraPos);
            float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0);

            float melt = ((wpos.y - _MeltY) / _MeltDistance);

            if(melt < -0.1 || melt > 1.1) {
                f = 0.01;
            }

            return f * tess;
        }

        //---------------------------------------------------------------------
        float4 MeltDistanceBasedTess(float4 v0, float4 v1, float4 v2, float minDist, float maxDist, float tess) {
            float3 f;
            f.x = MeltCalcDistanceTessFactor(v0, minDist, maxDist, tess);
            f.y = MeltCalcDistanceTessFactor(v1, minDist, maxDist, tess);
            f.z = MeltCalcDistanceTessFactor(v2, minDist, maxDist, tess);

            return UnityCalcTriEdgeTessFactors(f);
        }
        
        //---------------------------------------------------------------------
        float4 tessDistance(appdata v0, appdata v1, appdata v2) {
            float minDist = 10.0;
            float maxDist = 25.0;
            // return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
            return MeltDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
        }

        //---------------------------------------------------------------------
        float4 getNewVertPosition(float4 objectSpacePosition, float3 objectSpaceNormal) {
            // conver the position and normal from object space to world space
            float4 worldSpacePosition = mul(unity_ObjectToWorld, objectSpacePosition);
            float4 worldSpaceNormal = mul(unity_ObjectToWorld, float4(objectSpaceNormal, 0));
            
            // _MeltY is like a threshold and _MeltDistance is like a tolerance range
            float melt = (worldSpacePosition.y - _MeltY) / _MeltDistance;
            // make melt correspond to 0 for not melted, 1 for fully melted
            melt = 1 - saturate(melt);

            // take the linear 0 - 1 melt value and give it a curve
            melt = pow(melt, _MeltCurve);

            // push the vert out forwards and sideways by the melt amount
            worldSpacePosition.xz += worldSpaceNormal.xz * melt;

            // return to object space
            return mul(unity_WorldToObject, worldSpacePosition);
        }

        //---------------------------------------------------------------------
        void disp(inout appdata v) {
            // calculate bitangent with a cross product (see right-hand rule)
            float4 position = getNewVertPosition(v.vertex, v.normal);

            // calculate the bitangent using the cross product between the normal and the tangent
            float4 bitangent = float4(cross(v.normal, v.tangent), 0);

            // how far to offset the vert position to calculate the new normal
            float vertOffset = 0.01;
            float4 positionAndTangent = getNewVertPosition(v.vertex + v.tangent * vertOffset, v.normal);
            float4 positionAndBitangent = getNewVertPosition(v.vertex + bitangent * vertOffset, v.normal);

            // create the new tangents and bitangents based on the deformed positions
            float4 newTangent = positionAndTangent - position;     // leaves just "tangent"
            float4 newBitangent = positionAndBitangent - position; // leaves just "bitangent"

            float4 newNormal = float4(cross(newTangent, newBitangent), 0);
            v.normal = newNormal;
            v.vertex = position;
        }

        float getMelt(float3 worldSpacePosition) {
            float4 objectSpacePosition = mul(unity_WorldToObject, float4(worldSpacePosition, 0));
            float melt = (worldSpacePosition.y - _MeltY) / _MeltDistance;

            melt = 1 - saturate(melt);
            float wave = sin(objectSpacePosition.x * 4 + objectSpacePosition.z * 5) * 0.15;
            float hardMelt = step(0.5, melt + wave);

            return hardMelt;
        }

        //---------------------------------------------------------------------
        void surf (Input IN, inout SurfaceOutputStandard o) {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            float hardMelt = getMelt(IN.worldPos);
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
