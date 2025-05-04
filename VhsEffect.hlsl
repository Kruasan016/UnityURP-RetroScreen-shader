#ifndef VHS_EFFECT_INCLUDED
#define VHS_EFFECT_INCLUDED


#define MAIN_TEX SamplerState_Linear_Repeat
TEXTURE2D_X(_CameraColorTexture);
SAMPLER(sampler_CameraColorTexture);

float _ScanlinesOpacity;
float _ScanlinesWidth;
float _GrilleOpacity;
float2 _Resolution;
float _Pixelate;
float _Roll;
float _RollSpeed;
float _RollSize;
float _RollVariation;
float _DistortIntensity;
float _NoiseOpacity;
float _NoiseSpeed;
float _StaticNoiseIntensity;
float _Aberration;
float _Brightness;
float _Discolor;
float _WarpAmount;
float _ClipWarp;
float _VignetteIntensity;
float _VignetteOpacity;

float2 random(float2 uv) {
    uv = float2(dot(uv, float2(127.1, 311.7)), dot(uv, float2(269.5, 183.3)));
    return -1.0 + 2.0 * frac(sin(uv) * 43758.5453);
}

float noise(float2 uv) {
    float2 i = floor(uv);
    float2 f = frac(uv);
    float2 blur = smoothstep(0.0, 1.0, f);
    return lerp(
        lerp(dot(random(i), f), 
        dot(random(i + float2(1, 0)), f - float2(1, 0)), blur.x),
        lerp(dot(random(i + float2(0, 1)), f - float2(0, 1)), 
        dot(random(i + float2(1, 1)), f - float2(1, 1)), blur.x), blur.y
    ) * 0.5 + 0.5;
}

float2 warp(float2 uv) {
    float2 delta = uv * 2.0 - 1.0;
    float r2 = dot(delta, delta);
    float k = _WarpAmount * 0.1;
    float2 warped = delta * (1.0 + k * r2);
    return (warped + 1.0) * 0.5;
}

float border(float2 uv) {
    float radius = clamp(_WarpAmount * 0.08, 0.0, 0.08);
    float2 q = abs(uv * 2.0 - 1.0) - 1.0 + radius;
    return 1.0 - smoothstep(0.95, 1.0, length(max(q, 0.0)) / radius);
}

float vignette(float2 uv) {
    uv *= 1.0 - uv;
    return pow(uv.x * uv.y * 15.0, _VignetteIntensity * _VignetteOpacity);
}

float4 FragVhs(Varyings IN) : SV_Target
{
    float time = _Time.y;
    float2 uv = IN.uv;
    uv.y = 1.0 - uv.y;
    
    // Warping
    uv = warp(uv);
    if(_Pixelate) uv = floor(uv * _Resolution) / _Resolution;
    
    // Roll distortion
    float rollLine = 0.0;
    float2 rollUV = 0.0;
    if(_Roll) {
        rollLine = smoothstep(0.3, 0.9, sin(uv.y * _RollSize - time * _RollSpeed));
        rollLine *= smoothstep(0.3, 0.9, sin(uv.y * _RollSize * _RollVariation - time * _RollSpeed * _RollVariation));
        rollUV = float2(rollLine * _DistortIntensity * (1.0 - uv.x), 0.0);
    }
    
    // Chromatic Aberration
    float4 col = SAMPLE_TEXTURE2D_X(_CameraColorTexture, sampler_CameraColorTexture, uv);
    col.r = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, uv + rollUV * 0.8 + float2(_Aberration, 0.0)).r;
    col.g = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, uv + rollUV * 1.2 - float2(_Aberration, 0.0)).g;
    col.b = SAMPLE_TEXTURE2D(_CameraColorTexture, sampler_CameraColorTexture, uv + rollUV).b;
    col.a = 1.0;
    
    // Grille effect
    float2 screenUV = IN.positionCS.xy / _ScreenParams.xy;

    if (_GrilleOpacity > 0) {
        float pixelX = screenUV.x * _ScreenParams.x;
        float phase = floor(fmod(pixelX, 3.0));
    
        float3 mask = float3(0.0, 0.0, 0.0);
        if (phase == 0.0)      mask.r = 1.0;
        else if (phase == 1.0) mask.g = 1.0;
        else                   mask.b = 1.0;
    
        col.rgb = lerp(col.rgb, col.rgb * mask, _GrilleOpacity);
    }
    
    // Scanlines
    if(_ScanlinesOpacity > 0) {
        float scanlines = smoothstep(_ScanlinesWidth, _ScanlinesWidth + 0.5, abs(sin(uv.y * _Resolution.y * PI)));
        col.rgb = lerp(col.rgb, col.rgb * scanlines, _ScanlinesOpacity);
    }
    
    // Noise effects
    if(_NoiseOpacity > 0) {
        float n = smoothstep(0.4, 0.5, noise(uv * float2(2.0, 200.0) + time * _NoiseSpeed));
        rollLine *= n * clamp(random(floor(uv * _Resolution) / _Resolution + time * 0.8).x + 0.8, 0.0, 1.0);
        col.rgb = lerp(col.rgb, col.rgb + rollLine, _NoiseOpacity);
    }
    
    // Static noise
    if(_StaticNoiseIntensity > 0)
        col.rgb += clamp(random(floor(uv * _Resolution) / _Resolution + frac(time)).x, 0.0, 1.0) * _StaticNoiseIntensity;
    
    // Vignette & brightness
    col.rgb *= vignette(uv) * _Brightness;
    col.rgb *= border(uv);
    
    // Discolor effect
    if(_Discolor) {
        float3 greyscale = dot(col.rgb, float3(0.299, 0.587, 0.114));
        col.rgb = lerp(col.rgb, greyscale, 0.5);
        col.rgb = (col.rgb - 0.5) * 1.2 + 0.5;
    }
    
    return col;
}

#endif