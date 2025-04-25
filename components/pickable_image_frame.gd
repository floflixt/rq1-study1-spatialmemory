extends XRToolsPickable

@export var frame_color : Color = Color.hex(272727)
@export var is_highlighted : bool = false
@export var image_texture : String = "no_texture_string"
@export var image : Texture2D
@export var rating_complete : bool = false
@export var final_ratings : String

@export var elapsed_time : float = 0.0

var orange : Material = preload("res://components/orange_material.tres")
var black : Material = preload("res://components/black_material.tres")
var green : Material = preload("res://components/green_material.tres")

###############################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("images")
	hide_rating_tablet()
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
	pass

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

# 
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
	if not phase == "TUTORIAL":
		$Image.texture = load("res://assets/images/" + image_texture)
	#else:
		#$Image.texture = load("res://assets/turotial_images/" + image_texture)


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
	
