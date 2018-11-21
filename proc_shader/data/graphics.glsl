#define PROCESSING_COLOR_SHADER
#ifdef GL_ES
precision mediump float;
#endif
// #extension GL_OES_standard_derivatives : enable
vec4 color_in = vec4(1.,1.,1.,1.); //color A
uniform vec2 res;
uniform vec3 g0, g1, g2;

//the following determines wether width or the height is the broadest side
// and returns the
float bs = step(res.x, res.y)*res.y + step(res.y, res.x)*res.x;
float ns = step(res.x, res.y)*res.x + step(res.y, res.x)*res.y;

vec4 drawLine(vec4 c_in, float pr, float lw, float bl, float p){
	lw *= bs/ns;
	//if the y pos of the fragment is within the boundaries of the stroke, color component
	float r = step(p-lw/ns, pr) *	step(pr, p+lw) * c_in.r;
	float g = step(p-lw/ns, pr) *	step(pr, p+lw) * c_in.g;
	float b = step(p-lw/ns, pr) *	step(pr, p+lw) * c_in.b;
	float a = step(p-lw/ns, pr) *	step(pr, p+lw) * c_in.a;
	// add smooth bleed
	bl *= .1;
	//bl += 1. + (bl*.1);
	r += smoothstep(p, pr, p-bl) + smoothstep(p, pr-lw, p+bl) *	c_in.r;
	g += smoothstep(p, pr, p-bl) + smoothstep(p, pr-lw, p+bl) *	c_in.g;
	b += smoothstep(p, pr, p-bl) + smoothstep(p, pr-lw, p+bl) *	c_in.b;
	a += smoothstep(p, pr, p-bl) + smoothstep(p, pr-lw, p+bl) *	c_in.a;
	return vec4(r,g,b,a);
}

//color, progress, linewidth, bleed, orientation
vec4 drawLineH(vec4 c_in, float pr, float lw, float bl) {
	/*
	(res.y/ns)
	scale to % of narrowest side - fixes position offset
	+lw
	offsets position to push line beyond edge
	lw*.5
	line is drawn as two halves on each side of pr
	decide axis, scale to narrowest side to fix offset
	*/
	return drawLine(c_in, pr*((res.y/ns)+lw), lw*.5, bl, gl_FragCoord.y/ns);
}

vec4 drawLineV(vec4 c_in, float pr, float lw, float bl) {
	return drawLine(c_in, pr*((res.x/ns)+lw), lw*.5, bl, gl_FragCoord.x/ns);
}

vec4 drawRingBleed(float v1, float v2, float v3, vec4 c_in) {
	float r = smoothstep(v1, v2, v3)*c_in.x;
	float g = smoothstep(v1, v2, v3)*c_in.y;
	float b = smoothstep(v1, v2, v3)*c_in.z;
	float a = smoothstep(v1, v2, v3)*c_in.w;
	return vec4(r,g,b,a);
}

vec4 drawRing(vec4 tint, float pr, float lw, float bl) {
	vec2 pos;
	vec4 c = vec4(0.);
	lw*=.5;

	float hyp = sqrt(	pow(res.x,2.)+pow(res.y,2.)	);
	//broadest side
	pos = (gl_FragCoord.xy-res/2.) * 2. / bs;
	//lw *= smoothstep(.01, .03, pr);
	float r = length(pos);
	pr += lw;

	float a = atan(pos.y,pos.x);
	float f = cos(a*0.000)*pr;

	// f = abs(cos(a*3.));
	// f = abs(cos(a*2.5))*.5+.3;
	 // f = abs(cos(a*16.)*sin(a*12.3))*.01+.21;
 	//f += smoothstep(-.5,1., cos(a*10.))*0.2+0.5;

	 //return a color vector for inner + outer edge
	if (bl > 0.) {
		bl *= .1;
		bl += 1. + (bl*.1);
		c += drawRingBleed(r*bl, f+lw, r, tint);
		c += drawRingBleed(r, f-lw, r*pow(bl, 1.5),tint);
	}
	c += step(pr,r+lw)*step(r-lw, pr)*tint;

	return c;
}

vec4 evaluate(vec3 g) {
	vec4 rgba = vec4(0.);
	if (g.x > 0. && g.x <= 1.) rgba += drawLineH(color_in, g.x, g.y, g.z); //color, progress, linewidth, bleed
	else if (g.x > 1. && g.x < 2.) rgba += drawLineV(color_in, g.x-1., g1.y, g1.z);
	else if (g.x > 2. && g.x < 3.) rgba += drawRing(color_in, g.x-2., g1.y, g1.z);
	return rgba;
}

void main( void ) {
	vec4 color = vec4(0.);
 	color += evaluate(g0);
	color += evaluate(g1);
	color += evaluate(g2);

	gl_FragColor = color;
}
