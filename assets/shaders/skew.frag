//SHADERTOY PORT FIX
#pragma header
vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
//SHADERTOY PORT FIX

uniform float skew = 0.0;



float lerpp(float a, float b, float t){
	return a + (b - a) * t;
}
void main(void){
	float dfb = uv.y;
	vec4 c = vec4(0.0,0.0,0.0,0.0);
	vec2 pos = uv;
	pos.x = uv.x+(skew*dfb);
	if(pos.x > 0 && pos.x < 1){
		gl_FragColor = flixel_texture2D( bitmap, pos);
	}
	
}
