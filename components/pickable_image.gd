extends XRToolsPickable

@onready var beauty_rating : int
@onready var ai_rating : int

var is_pickable : bool = false
var is_highlighted : bool = false

var has_beauty_rating : bool = false
var has_ai_rating : bool = false

###################################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#match EXPAR.current_state:
		#EXPAR.ExpState.START:
			#is_pickable = false
		#EXPAR.ExpState.PARTICIPANT_INFO:
			#is_pickable = true
		#_:
			#is_pickable = false
	#
	#self.enabled = is_pickable
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
	
# called when created as a spatial anchor
func setup_scene(spatial_entity: OpenXRFbSpatialEntity) -> void:
	var possible_images: Array = DirAccess.open("res://assets/images/").get_files()
	var image: String = possible_images.pick_random()
	image = image.trim_suffix(".import")
	$MeshInstance3D/Sprite3D.texture = load(str("res://assets/images/", image))
	#$Label3D.text = str("uuid: ", spatial_entity.uuid)
	call_deferred("_save_position")
	
var initial_global_transform: Transform3D
	
func _save_position() -> void:
	initial_global_transform = $".".global_transform
	$LabelStart.text = str("START; relative to ORIGIN:\n", MY.transf_to_str($".".global_transform))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$LabelCurrent.text = str("CURRENT:\n", MY.transf_to_str($".".global_transform))
	var shift = $".".global_transform.origin - initial_global_transform.origin
	$LabelShift.text = str("SHIFT:\n", MY.vec_to_str(shift))

# this function is always called when the highlight ring switches
func _on_highlight_updated(pickable: Variant, enable: Variant) -> void:
	# first, we decide:
	# if we are already highlighted and we are entered (enable = true), then we turn off
	if is_highlighted and enable:
		is_highlighted = false
	# if we are highlighted and we are left, we do nothing
	elif is_highlighted and not enable:
		pass
	# if we are not highlighted and something enters, we enable
	elif not is_highlighted and enable:
		is_highlighted = true
	# if we are not enabled and something leaves, we do nothgin
	elif not is_highlighted and not enable:
		pass
	
	# and now we turn the tablet on or off
	if is_highlighted:
		enable_rating_tablet(EXPAR.current_left_hand_transform)
	if not is_highlighted:
		disable_rating_tablet()
	
	
	
	
	# if the image is highlighted and the ring switches to off, 
		



	#if not is_highlighted:
		#if enable:
			#$Colliding.text = "not highligth + enable"
			#enable_rating_tablet()
			##is_highlighted = true
		#if not enable:
			#$Colliding.text = "not highligth + not enable"
	#if is_highlighted:
		#if enable:
			#$Colliding.text = "highligth + enable"
			##disable_rating_tablet()
			##is_highlighted = false
		#if not enable:
			##disable_rating_tablet()
			##is_highlighted = false
			#$Colliding.text = " highligth + not enable"
			#
	
	
	#
	## if the image is not currently highlighted
	#if is_highlighted and not enable:
		#disable_rating_tablet()
		## also, make the tablet highlighted now
		#is_highlighted = false
	#elif not is_highlighted and enable:
		#enable_rating_tablet()
		#is_highlighted = true
	#else:
		#pass


func enable_rating_tablet(at_transform: Transform3D) -> void:
	$RatingTablet.global_transform = at_transform
	$MeshInstance3D.get_surface_override_material(0).albedo_color = Color.DARK_ORANGE
	$RatingTablet.visible = true
	$RatingTablet.process_mode = Node.PROCESS_MODE_INHERIT
	
func disable_rating_tablet() -> void:
	$MeshInstance3D.get_surface_override_material(0).albedo_color = Color.BLACK
	$RatingTablet.visible = false
	$RatingTablet.process_mode = Node.PROCESS_MODE_DISABLED
