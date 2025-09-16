#pragma header

#ifdef GL_ES
precision mediump float;
#endif

uniform float time;

// --- noise function code unchanged ---
// (kept for the fuzzOffset effect)

float snoise(vec2 v) {
    // your snoise implementation stays here...
    // (omitted for brevity)
}

void main()
{
    float fuzzOffset = snoise(vec2(time*15.0, openfl_TextureCoordv.y*80.0)) * 0.0005;
    float largeFuzzOffset = snoise(vec2(time*1.0, openfl_TextureCoordv.y*25.0)) * 0.001;
    float xOffset = (fuzzOffset + largeFuzzOffset);
    // Smaller red/blue offset (was ±0.003)
    float red   = texture(bitmap, vec2(openfl_TextureCoordv.x + xOffset - 0.001, openfl_TextureCoordv.y)).r;
    float green = texture(bitmap, vec2(openfl_TextureCoordv.x + xOffset, openfl_TextureCoordv.y)).g;
    float blue  = texture(bitmap, vec2(openfl_TextureCoordv.x + xOffset + 0.001, openfl_TextureCoordv.y)).b;
    float alpha = texture(bitmap, vec2(openfl_TextureCoordv.x + xOffset, openfl_TextureCoordv.y)).a;

    vec3 color = vec3(red, green, blue);

    // scanlines removed
    // float scanline = sin(openfl_TextureCoordv.y*800.0)*0.04;
    // color -= scanline;

    gl_FragColor = vec4(color, alpha);
}
