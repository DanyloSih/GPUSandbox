Shader "Custom/HeightMapShader"
{
    Properties
    {
        _Seed ("Seed", Integer) = 13513513
        _Octaves ("Octaves", Integer) = 2
        _WavesGap ("WavesGap", Float) = 0.2
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            int _Seed;
            int _Octaves;
            float _WavesGap;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float sinNoise(uint octaves, float wavesGap, float pos)
            {
                int i;
                float result = sin(pos);
                float currentGap = wavesGap;
                for(i = 1; i < octaves; i++)
                {
                    result += sin(pos * currentGap);
                    currentGap += wavesGap;
                }

                return (result);
            }

            float sinNoise2D(uint octaves, float wavesGap, float2 pos)
            {
                float height1 = sinNoise(octaves, wavesGap, pos.x);
                float height2 = sinNoise(octaves, wavesGap, pos.y);
                return height1 + height2;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 col;
                UNITY_APPLY_FOG(i.fogCoord, col);
                float height = sinNoise2D(_Octaves, _WavesGap, i.uv);
                col = float4(height, height, height, 1);
                return col;
            }
            ENDCG
        }
    }
}
