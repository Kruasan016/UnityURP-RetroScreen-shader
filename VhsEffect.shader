Shader "Custom/Vhs Effect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Header(CRT Settings)]
        _ScanlinesOpacity("Scanlines Opacity", Range(0, 1)) = 0.4
        _ScanlinesWidth("Scanlines Width", Range(0, 0.5)) = 0.25
        _GrilleOpacity("Grille Opacity", Range(0, 1)) = 0.3
        _Resolution("Resolution", Vector) = (640, 480, 0, 0)
        
        [Toggle]_Pixelate("Pixelate", Float) = 1
        
        [Header(Roll Effect)]
        [Toggle]_Roll("Roll", Float) = 1
        _RollSpeed("Roll Speed", Float) = 8.0
        _RollSize("Roll Size", Range(0, 100)) = 15.0
        _RollVariation("Roll Variation", Range(0.1, 5)) = 1.8
        _DistortIntensity("Distort Intensity", Range(0, 0.2)) = 0.05
        
        [Header(Noise)]
        _NoiseOpacity("Noise Opacity", Range(0, 1)) = 0.4
        _NoiseSpeed("Noise Speed", Float) = 5.0
        _StaticNoiseIntensity("Static Noise Intensity", Range(0, 1)) = 0.06
        
        [Header(Color)]
        _Aberration("Chromatic Aberration", Range(-1, 1)) = 0.03
        _Brightness("Brightness", Float) = 1.4
        [Toggle]_Discolor("Discolor", Float) = 1
        
        [Header(Warp)]
        _WarpAmount("Warp Amount", Range(0, 5)) = 1.0
        [Toggle]_ClipWarp("Clip Warp", Float) = 0
        
        [Header(Vignette)]
        _VignetteIntensity("Vignette Intensity", Float) = 0.4
        _VignetteOpacity("Vignette Opacity", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" }
        Pass
        {
            Name "VhsPass"
            ZTest Always Cull Off ZWrite Off

            HLSLPROGRAM
            #pragma vertex VertDefault
            #pragma fragment FragVhs
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            #define PI 3.14159265358979323846

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            Varyings VertDefault(uint vertexID : SV_VertexID)
            {
                Varyings o;
                float2 uv = float2((vertexID << 1) & 2, vertexID & 2);
                o.uv = uv;
                o.positionCS = float4(uv * 2.0 - 1.0, 0.0, 1.0);
                return o;
            }
            
            #include "Assets/Shaders/VhsEffect.hlsl"
            ENDHLSL
        }
    }
}