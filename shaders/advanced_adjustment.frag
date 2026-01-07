#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform sampler2D uLut;       // 512x512 Hald CLUT

// LUT Parameters
uniform float uLutIntensity;  // 0.0 ~ 1.0
uniform float uHasLut;        // 1.0 = true, 0.0 = false

// Light Parameters
uniform float uExposure;      // -1.0 ~ 1.0 (露出)
uniform float uBrightness;    // -1.0 ~ 1.0 (明るさ)
uniform float uContrast;      // -1.0 ~ 1.0 (コントラスト)
uniform float uHighlight;     // -1.0 ~ 1.0 (ハイライト)
uniform float uShadow;        // -1.0 ~ 1.0 (シャドウ)

// Color Parameters
uniform float uSaturation;    // -1.0 ~ 1.0 (彩度)
uniform float uTemperature;   // -1.0 ~ 1.0 (色温度: 寒色/暖色)
uniform float uTint;          // -1.0 ~ 1.0 (色合い: 緑/マゼンタ)

// Effect Parameters
uniform float uVignette;      // 0.0 ~ 1.0 (周辺減光)
uniform float uGrain;         // 0.0 ~ 1.0 (粒子)

// Geometry Parameters
uniform float uRotation;      // 0.0=0°, 1.0=90°, 2.0=180°, 3.0=270°
uniform float uFlipX;         // 1.0 = Flip, 0.0 = None
uniform float uFlipY;         // 1.0 = Flip, 0.0 = None

out vec4 fragColor;

// Hald CLUT Lookup Logic (Tri-linear interpolation)
vec3 sampleLut(vec3 color) {
    float blueColor = color.b * 63.0;
    
    vec2 quad1;
    quad1.y = floor(floor(blueColor) / 8.0);
    quad1.x = floor(blueColor) - (quad1.y * 8.0);
    
    vec2 quad2;
    quad2.y = floor(ceil(blueColor) / 8.0);
    quad2.x = ceil(blueColor) - (quad2.y * 8.0);
    
    float size = 512.0;
    float cell = 1.0 / 8.0;
    float halfPixel = 0.5 / size;
    float scale = (0.125 - 1.0 / size);

    vec2 texPos1;
    texPos1.x = (quad1.x * cell) + halfPixel + (scale * color.r);
    texPos1.y = (quad1.y * cell) + halfPixel + (scale * color.g);
    
    vec2 texPos2;
    texPos2.x = (quad2.x * cell) + halfPixel + (scale * color.r);
    texPos2.y = (quad2.y * cell) + halfPixel + (scale * color.g);
    
    vec3 newColor1 = texture(uLut, texPos1).rgb;
    vec3 newColor2 = texture(uLut, texPos2).rgb;
    
    vec3 newColor = mix(newColor1, newColor2, fract(blueColor));
    return newColor;
}

// Simple pseudo-random noise for grain effect
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;

    // 1. Rotation (90 degree steps)
    if (uRotation == 1.0) {      // 90°
        uv = vec2(uv.y, 1.0 - uv.x);
    } else if (uRotation == 2.0) { // 180°
        uv = vec2(1.0 - uv.x, 1.0 - uv.y);
    } else if (uRotation == 3.0) { // 270°
        uv = vec2(1.0 - uv.y, uv.x);
    }

    // 2. Flip
    if (uFlipX > 0.5) uv.x = 1.0 - uv.x;
    if (uFlipY > 0.5) uv.y = 1.0 - uv.y;

    vec4 srcColor = texture(uTexture, uv);
    vec3 rgb = srcColor.rgb;

    // ======== Phase 1: LUT Application ========
    if (uHasLut > 0.5) {
        vec3 lutColor = sampleLut(rgb);
        rgb = mix(rgb, lutColor, uLutIntensity);
    }

    // ======== Phase 2: Exposure (露出) ========
    // Multiplicative exposure (like camera exposure stops)
    rgb *= pow(2.0, uExposure);

    // ======== Phase 3: White Balance (色温度・色合い) ========
    // Temperature: Warm (orange) <-> Cool (blue)
    // Tint: Green <-> Magenta
    vec3 wb = vec3(
        1.0 + uTemperature * 0.2,
        1.0 - abs(uTint) * 0.1,
        1.0 - uTemperature * 0.2
    );
    wb.g += uTint * 0.15;
    rgb *= wb;

    // ======== Phase 4: Highlights & Shadows ========
    float luma = dot(rgb, vec3(0.299, 0.587, 0.114));
    float shadowMask = 1.0 - smoothstep(0.0, 0.5, luma);
    float highlightMask = smoothstep(0.5, 1.0, luma);
    
    rgb += uShadow * shadowMask * 0.5;
    rgb -= uHighlight * highlightMask * 0.3;

    // ======== Phase 5: Basic Adjustments ========
    // Brightness
    rgb += uBrightness * 0.5;
    
    // Contrast
    rgb = (rgb - 0.5) * (1.0 + uContrast) + 0.5;
    
    // Saturation
    float gray = dot(rgb, vec3(0.299, 0.587, 0.114));
    rgb = mix(vec3(gray), rgb, 1.0 + uSaturation);

    // ======== Phase 6: Vignette (周辺減光) ========
    vec2 uvCenter = uv - 0.5;
    float dist = length(uvCenter) * 1.414; // Normalize to 0-1 at corners
    float vig = smoothstep(0.3, 1.0, dist);
    rgb *= 1.0 - vig * uVignette;

    // ======== Phase 7: Film Grain (粒子) ========
    float noise = (random(uv + fract(uSize.x * 0.001)) - 0.5) * 2.0;
    rgb += noise * uGrain * 0.08;

    // ======== Final: Clamp to valid range ========
    rgb = clamp(rgb, 0.0, 1.0);

    fragColor = vec4(rgb, srcColor.a);
}
