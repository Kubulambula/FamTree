shader_type canvas_item;

const float corner_radius = 10.0;


bool is_in_rect(vec2 uv, vec2 rect_position, vec2 rect_size){
	return all(lessThan(uv, rect_size)) && all(greaterThan(uv, rect_position));
}


bool is_outside_border(vec2 uv, vec2 size, float radius){
	// circle centers
	vec2 a = vec2(radius, radius);               //                     \/-ru_position
	vec2 b = vec2(size.x-radius, radius);        //              + - - - - +
	vec2 c = vec2(radius, size.y-radius);        //              | a     b |<- ru_size
	vec2 d = vec2(size.x-radius, size.y-radius); //              |         |
	vec2 ru_position = vec2(size.x-radius, 0);   //              |         |
	vec2 ru_size = vec2(size.x, radius);         // ld_position->| c     d |
	vec2 ld_position = vec2(0, size.y-radius);   //              + - - - - +
	vec2 ld_size = vec2(radius, size.y);         //                ^- lu_size
	
	if(is_in_rect(uv, a, d)){ // check the big rect in the middle for early return
		return false;
	}
	else if(is_in_rect(uv, vec2(0.0), a)){
		return distance(a, uv) > radius;
	}
	else if(is_in_rect(uv, ru_position, ru_size)){
		return distance(b, uv) > radius;
	}
	else if(is_in_rect(uv, ld_position, ld_size)){
		return distance(c, uv) > radius;
	}
	else if(is_in_rect(uv, d, size)){
		return distance(d, uv) > radius;
	}
	
	return false;
}


void fragment() {
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	if(is_outside_border(texture_size * UV, texture_size, corner_radius)){
		COLOR = vec4(0.0);
	}
}