#pragma header

#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 resolution;

float pi = 3.14159265359;
float curvature = 0.065;
float vignetteStrength = 0.4;
float theScanLine = 0.0;

vec2 curve(vec2 inp)
{
    inp.x = inp.x - sin(inp.y * pi) * curvature * (inp.x - 0.5);
    inp.y = inp.y - sin(inp.x * pi) * curvature * (inp.y - 0.5);
    return inp;
}

vec2 zoomOut(vec2 inp)
{
    float zoom = 1.0 + 1.3 * curvature;
    return vec2(0.5, 0.5) + ((inp - vec2(0.5, 0.5)) * zoom);
}

float lerp(float a, float b, float c)
{
    return a + c * (b - a);
}

vec4 vignette(vec2 inp)
{
    float t = 0.0;
    t = lerp(0.5, vignetteStrength * distance(inp, vec2(0.5, 0.5)), 0.98);
    return vec4(t, t, t, 1.0);
}

vec4 staticc(vec2 inp)
{
    float t = 0.0;
    t = cos(inp.y * resolution.y) * 2.0;

    float val = sin(100.0 + time * cos(100.0 + time) * 2.0) * 14.0 * inp.y;
    val = clamp(val, -1.55, 1.55);
    t += tan(val) * 0.05;

    return vec4(t, t, t, 1.0);
}

bool inRect(vec2 rect, vec2 rectDim, vec2 inp)
{
    vec2 clamped = clamp(inp, rect, rectDim);
    return (clamped.x == inp.x && clamped.y == inp.y);
}

// curved shadow overlay (matches CRT-like rounded rectangle)
float shadowMask(vec2 uv) {
    // Shift so center is (0,0)
    vec2 c = uv - 0.5;

    // Stretch horizontally/vertically for rounded rectangle shape
    float distX = abs(c.x) * 1.4; 
    float distY = abs(c.y) * 1.2;

    // Combine into a rounded-edge mask
    float edge = max(distX, distY);

    // Smoothstep = soft fade near edges
    return smoothstep(0.55, 0.85, edge);
}

void main(void)
{
    vec2 uv = zoomOut(curve(openfl_TextureCoordv.xy));
    vec4 col;
    theScanLine = sin(time * pi + uv.y) + tan(time - uv.y * uv.y) - cos(uv.y);

    if (inRect(vec2(0.0, 0.0), vec2(1.0, 1.0), uv))
    {
        if (inRect(vec2(0.0, theScanLine), vec2(1.0, theScanLine + 0.1), uv))
            uv.x -= sin(theScanLine - uv.y) * 0.04;

        col = texture(bitmap, uv);

        // vignette + static
        col -= vignette(uv);
        col += staticc(uv) * 0.015;

        // apply curved shadow overlay
        float shadow = shadowMask(uv);
        col.rgb *= (1.0 - shadow * 0.6); 
    }
    else
    {
        col = vec4(0.0, 0.0, 0.0, 1.0);
    }

    gl_FragColor = col;
}