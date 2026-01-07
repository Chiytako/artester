#version 460 core

// Flutter FragmentProgram requires these specific precision qualifiers
precision highp float;

// Output color
out vec4 fragColor;

// Uniforms - sampler must be first (Flutter requirement)
uniform sampler2D uTexture;

// Resolution of the output
uniform vec2 uResolution;

// Adjustment parameters (normalized: 0.0 = no change, -1.0 to 1.0 range)
uniform float uBrightness;   // -1.0 to 1.0
uniform float uContrast;     // -1.0 to 1.0
uniform float uSaturation;   // -1.0 to 1.0
uniform float uFilterStrength; // 0.0 to 1.0 (blend with original)

// Convert RGB to HSL
vec3 rgb2hsl(vec3 color) {
    float maxC = max(max(color.r, color.g), color.b);
    float minC = min(min(color.r, color.g), color.b);
    float delta = maxC - minC;
    
    float h = 0.0;
    float s = 0.0;
    float l = (maxC + minC) / 2.0;
    
    if (delta > 0.0) {
        s = l < 0.5 ? delta / (maxC + minC) : delta / (2.0 - maxC - minC);
        
        if (maxC == color.r) {
            h = (color.g - color.b) / delta + (color.g < color.b ? 6.0 : 0.0);
        } else if (maxC == color.g) {
            h = (color.b - color.r) / delta + 2.0;
        } else {
            h = (color.r - color.g) / delta + 4.0;
        }
        h /= 6.0;
    }
    
    return vec3(h, s, l);
}

// Helper function for HSL to RGB conversion
float hue2rgb(float p, float q, float t) {
    if (t < 0.0) t += 1.0;
    if (t > 1.0) t -= 1.0;
    if (t < 1.0/6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0/2.0) return q;
    if (t < 2.0/3.0) return p + (q - p) * (2.0/3.0 - t) * 6.0;
    return p;
}

// Convert HSL to RGB
vec3 hsl2rgb(vec3 hsl) {
    float h = hsl.x;
    float s = hsl.y;
    float l = hsl.z;
    
    if (s == 0.0) {
        return vec3(l);
    }
    
    float q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
    float p = 2.0 * l - q;
    
    float r = hue2rgb(p, q, h + 1.0/3.0);
    float g = hue2rgb(p, q, h);
    float b = hue2rgb(p, q, h - 1.0/3.0);
    
    return vec3(r, g, b);
}

// Apply brightness adjustment
vec3 applyBrightness(vec3 color, float brightness) {
    return color + brightness;
}

// Apply contrast adjustment
vec3 applyContrast(vec3 color, float contrast) {
    // Convert contrast from -1..1 to multiplier
    float factor = (1.0 + contrast);
    factor = factor * factor; // More intuitive curve
    return (color - 0.5) * factor + 0.5;
}

// Apply saturation adjustment
vec3 applySaturation(vec3 color, float saturation) {
    vec3 hsl = rgb2hsl(color);
    // Adjust saturation multiplicatively
    float satFactor = 1.0 + saturation;
    hsl.y = clamp(hsl.y * satFactor, 0.0, 1.0);
    return hsl2rgb(hsl);
}

void main() {
    // Calculate normalized texture coordinates
    vec2 uv = gl_FragCoord.xy / uResolution;
    
    // Flip Y coordinate (Flutter's coordinate system)
    uv.y = 1.0 - uv.y;
    
    // Sample the original texture
    vec4 originalColor = texture(uTexture, uv);
    vec3 color = originalColor.rgb;
    
    // Apply adjustments in order: Brightness -> Contrast -> Saturation
    color = applyBrightness(color, uBrightness);
    color = applyContrast(color, uContrast);
    color = applySaturation(color, uSaturation);
    
    // Clamp to valid range
    color = clamp(color, 0.0, 1.0);
    
    // Blend with original based on filter strength
    color = mix(originalColor.rgb, color, uFilterStrength);
    
    // Output with original alpha
    fragColor = vec4(color, originalColor.a);
}
