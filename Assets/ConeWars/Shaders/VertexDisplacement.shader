Shader "ConeWars/VertexDisplacement"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Speed("Speed", Range(0.1, 4)) = 1
        _Amount("Amount", Range(0.1, 10)) = 3
        _Distance("Distance", Range(0, 2)) = 0.3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Speed = 1;
            float _Amount = 5;
            float _Distance = 0.1;
            
            v2f vert (appdata v)
            {
                v2f o;

                // object to world

                // take the mesh's verts and turn it into a point in world space
                float4 worldSpaceVertex = mul(unity_ObjectToWorld, v.vertex);

                worldSpaceVertex.x += sin(_Time.y * _Speed + v.vertex.y * _Amount) * _Distance;

                // go back to object space
                float4 objectSpaceVertex = mul(unity_WorldToObject, worldSpaceVertex);

                o.vertex = mul(UNITY_MATRIX_MVP, objectSpaceVertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
