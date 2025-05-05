extends XRToolsPickable

@export var frame_color : Color = Color.hex(272727)
@export var is_highlighted : bool = false
@export var image_texture : String = "no_texture_string"
@export var image : Texture2D
@export var rating_complete : bool = false
@export var final_ratings : String

@export var is_new_image: bool = false

@export var elapsed_time : float = 0.0

@export var confirm_counter : int = 0
@export var placement_confirmed : bool = false
@export var can_confirm : bool = false
@export var response_to_save : String = ""

var orange : Material = preload("res://components/orange_material.tres")
var black : Material = preload("res://components/black_material.tres")
var green : Material = preload("res://components/green_material.tres")
var yellow : Material = preload("res://components/pale_yellow_material.tres")

###############################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("images")
	hide_rating_tablet()
	hide_recognition_tablet()
	$Image.texture = image

# raycasting happens here, independent of visual framerate
func _physics_process(delta: float) -> void:
	# set raycast to target camera/head position (to_local to make it relative)
	if $RayCast3D.enabled:
		$RayCast3D.target_position = to_local(EXPAR.camera_transform.origin)
	if $ImageFrameRay.enabled:
		$ImageFrameRay.target_position = to_local(EXPAR.camera_transform.origin)
	
	# first, we check if the ImageFrameRay is hitting the image frame
	# -> that would mean that the RayCast3D is facing forwards, so we should be able to see the image
	if $ImageFrameRay.get_collider().name == "ImageArea":
		# we are in front, so we can update the time - IF the image is also in the cameraCone 
		if $RayCast3D.is_colliding() and $RayCast3D.get_collider().name == "CameraVisibleArea":
			elapsed_time += delta
	$VisibleLabel.text = str(snapped(elapsed_time, .001))
	#$VisibleLabel.text += "\n" + $RayCast3D.get_collider().name + "\nback: " + $ImageFrameRay.get_collider().name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# only if we are currently waiting for confirming a placement, we set the frame color
	if can_confirm:
		if confirm_counter < 100:
			set_frame_material(black)
		if confirm_counter > 100:
			set_frame_material(orange)
		if confirm_counter > 200:
			set_frame_material(yellow)
		if confirm_counter > 300:
			set_frame_material(green)
		if confirm_counter > 360:
			placement_confirmed = true

###################################################################

# reset rotation to upright
func _on_released(pickable: Variant, by: Variant) -> void:
	var curr_rotation_vector = self.get_global_rotation()
	var tween = get_tree().create_tween()
	
	# set the rotation around x to 0
	curr_rotation_vector.x = 0
	curr_rotation_vector.z = 0
	
	# reset rotation by animating
	#self.set_global_rotation(curr_rotation_vector)
	tween.tween_property(self, "global_rotation", curr_rotation_vector, 0.3)
	
func toggle_highlighted() -> void:
	get_tree().call_group("xr", "debug_message", "toggle highlight called")
	is_highlighted = not is_highlighted
	# now change the frame material + hide rating tablet if not highlighted anymore
	if is_highlighted:
		# tell all other images to be not highlighted anymore
		get_tree().call_group("images", "hide_rating_tablet")
		# then highlight this image
		set_frame_material(orange)
		# make it known to everybody that this is the currently highlighted image
		EXPAR.currently_highlighted_image = self
	else:
		hide_rating_tablet()


func show_rating_tablet(left_hand_position: Transform3D) -> void:
	# make sure the frame is highlighted
	set_frame_material(orange)
	if is_highlighted:
		# spawn at marker position
		$RatingTablet.global_transform = left_hand_position
		# rotate
		var curr_rotation_vector = $RatingTablet.get_global_rotation()
		var tween = get_tree().create_tween()
		curr_rotation_vector.z = 0
		# reset rotation by animating
		tween.tween_property($RatingTablet, "global_rotation", curr_rotation_vector, 0.3)
		$RatingTablet.visible = true
		$RatingTablet.process_mode = Node.PROCESS_MODE_INHERIT
		
func show_recognition_tablet() -> void:
	$RecognitionTablet.visible = true
	$RecognitionTablet.process_mode = Node.PROCESS_MODE_INHERIT

func hide_rating_tablet() -> void:
	# disable rating tablet
	$RatingTablet.visible = false
	$RatingTablet.process_mode = Node.PROCESS_MODE_DISABLED
	set_frame_material(black)
	# instead of making the frame black:
	if rating_complete:
		set_frame_material(green)
	
	# now everything is done, the EXPAR can forget which image is the current one
	EXPAR.currently_highlighted_image = null


func hide_recognition_tablet() -> void:
	$RecognitionTablet.visible = false
	$RecognitionTablet.process_mode = Node.PROCESS_MODE_DISABLED
	# make placement of image active
	self.enabled = true


func _on_combined_ratings_rating_confirmed(ratings: String) -> void:
	# this happens only by pressing the okay button, so we can say the rating is complete
	rating_complete = true
	hide_rating_tablet()
	final_ratings = ratings
	save_ratings(ratings)
	
	
func set_frame_material(new_material: Material) -> void:
	$Frame/FrameMesh.set_surface_override_material(0, new_material)

func set_pickupability(new_state: bool) -> void:
	self.enabled = new_state


func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	$RayCast3D.enabled = true
	$ImageFrameRay.enabled = true
	
func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	$RayCast3D.enabled = false
	$ImageFrameRay.enabled = false

func update_texture(phase: String) -> void:
	#get_tree().call_group("xr", "debug_message", "texture updated:" + self.name)
	#else:
		#$Image.texture = load("res://assets/turotial_images/" + image_texture)
	match phase:
		"TUTORIAL":
			$Image.texture = load("res://assets/tutorial_images/" + image_texture)
			get_tree().call_group("xr", "debug_message", "new tutorial image texture:" + image_texture)
			if is_new_image:
				$RecognitionTablet/MeshInstance3D/Viewport2Din3D/Viewport/RecognitionTest.image_was_present = false
			else:
				$RecognitionTablet/MeshInstance3D/Viewport2Din3D/Viewport/RecognitionTest.image_was_present = true
		"RECALL":
			if is_new_image:
				$Image.texture = load("res://assets/new_images/" + image_texture)
				get_tree().call_group("xr", "debug_message", "new image texture:" + image_texture)
				$RecognitionTablet/MeshInstance3D/Viewport2Din3D/Viewport/RecognitionTest.image_was_present = false
			else:
				$Image.texture = load("res://assets/images/" + image_texture)	
				get_tree().call_group("xr", "debug_message", "standard image texture:" + image_texture)
				$RecognitionTablet/MeshInstance3D/Viewport2Din3D/Viewport/RecognitionTest.image_was_present = true
		_:
			get_tree().call_group("xr", "debug_message", "image texture updated - default")
			$Image.texture = load("res://assets/images/" + image_texture)

func save_ratings(ratings: String) -> void:
	var complete_data_string: String
	complete_data_string = image_texture + "," + str(Time.get_ticks_msec()) + "," + str(snapped(elapsed_time, .001)) + "," + ratings
	var file : FileAccess = FileAccess.open(EXPAR.ratings_file, FileAccess.READ_WRITE)
	file.seek_end()
	file.store_line(complete_data_string)
	file.close()
	get_tree().call_group("xr", "debug_message", complete_data_string)

func save_final_ratings() -> void:
	save_ratings(final_ratings)
	
func save_location() -> void:
	# disable the image
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED
	
	# save the final location of this image
	save_image_info(false)
	
	
	
func save_image_info(before_response_is_given: bool) -> void:
	var response_string: String = ""
	if before_response_is_given:
		# we need to add a final value (which is the response time until button press)
		response_string = "spawn_location" + "," + str(Time.get_ticks_msec())
	else:
		response_string = response_to_save
	var file : FileAccess = FileAccess.open(EXPAR.placement_file, FileAccess.READ_WRITE)
	file.seek_end()
	file.store_line(self.name + "," + image_texture + "," + str(snapped(elapsed_time, .001)) + "," + MY.transf_to_csv(self.transform) + "," + str(is_new_image) + "," + response_string)
	file.close()
	
	
func make_available_for_placing(hand_transform: Transform3D) -> void:
	get_tree().call_group("xr", "debug_message", "making image available for placing..." + self.name)
	self.visible = true
	self.process_mode = Node.PROCESS_MODE_INHERIT
	# do NOT make the image moveable yet
	self.enabled = false
	#get_tree().call_group("xr", "debug_message", "visible set to true")
	#self.update_texture("RECALL")
	#get_tree().call_group("xr", "debug_message", "texture updated")
	#get_tree().call_group("xr", "debug_message", "process mode enabled")
	self.global_transform = hand_transform
	#get_tree().call_group("xr", "debug_message", "transform set to hand_transform:" + MY.transf_to_str(hand_transform))
	# rotate upright
	var curr_rotation_vector = self.get_global_rotation()
	var tween = get_tree().create_tween()
	curr_rotation_vector.z = 0
	# reset rotation by animating
	tween.tween_property(self, "global_rotation", curr_rotation_vector, 0.3)
	#get_tree().call_group("xr", "debug_message", "rotated upright")
	show_recognition_tablet()
	
	# save the initial transform where this image appears (BEFORE RESPONSE IS GIVEN -> true)
	save_image_info(true)

func _on_recognition_test_response(response_string: String, continue_placing: bool) -> void:
	response_to_save = response_string
	hide_recognition_tablet()
	can_confirm = true
	if not continue_placing:
		# simply confirm the placement as if the participant is done placing, this will
		# automatically take care of saving the final location and hiding the image as well as
		# making placing the next image placement possible 
		placement_confirmed = true
