shader_type spatial;

render_mode blend_mul, depth_draw_opaque, cull_back, shadow_to_opacity;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(0.0, 0.0, 0.0);
	//ALPHA = 1.0;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}


//
//shader_type spatial;
//
//// These flags affect the #defines that are used in the GLES3 scene uber shader. blend_mix causes the material to get shadows
//render_mode blend_mix,cull_back,shadow_to_opacity;
//
//void fragment() {
   //ALBEDO = vec3(0.0, 0.0, 0.0); // Black shadows
   //ALPHA = 0.5; // Make sure Godot sends this through the transparent rendering path.
//}
//
//void light() {
        //// Take the attenuation (shadow strength) and use it to manipulate the alpha
        //// 0.75 is there to let some of the camera feed through.
   //ALPHA = clamp(1.0 - length(ATTENUATION), 0.0, 1.0) * 0.75;
//}