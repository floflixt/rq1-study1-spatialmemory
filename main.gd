extends Node3D

# as soon as the scene manager node is ready, assign it to these variables
@onready var scene_manager : Node3D = $SceneManager
@onready var xr : XROrigin3D = $XROrigin3D


## these are to keep track of various transforms/locations
var calibrated_origin : Transform3D
var calibration_cube : Transform3D
var current_left_hand_transform : Transform3D
var current_right_hand_transform : Transform3D

var time_since_last_save_hmd: float = 0.0

## self generated identification code
var sgic : String = "XX-00-XX-00-XX" # this default code is invalid!

###############################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	xr.debug_message("Main scene ready!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# keep track of sereval transforms
	calibration_cube = $SceneManager/Start.initial_calibration_transform
	#EXPAR.camera_transform = $XROrigin3D/XRCamera3D.global_transform
	# update origin location 
	#EXPAR.my_origin_transform = $Scene/MyOrigin.global_transform
	
	#EXPAR.global_hmd_transform = $XROrigin3D/XRCamera3D.global_transform
	#EXPAR.global_hmd_transform = XRServer.get_hmd_transform()
	#$XROrigin3D/XRCamera3D/XRMessageLabel.text = transf_to_str(hmd_transform)

############################################################ SIGNALS + DEBUG

func _on_start_xr_xr_started() -> void:
	xr.debug_message("XR started")

func _on_start_xr_xr_ended() -> void:
	xr.debug_message("XR ended")

func _on_start_xr_pose_recentered() -> void:
	xr.debug_message("POSE RECENTERED")


func _on_scene_manager_scene_disabled(scene_name: String) -> void:
	xr.debug_message(scene_name + " disabled")

func _on_scene_manager_scene_enabled(scene_name: String) -> void:
	xr.debug_message(scene_name + " enabled")


################################################### GESTURE TRIGGERED

func _on_xr_origin_3d_scene_switch_requested() -> void:
	scene_manager.switch_to_next_scene()
	# depending on the current scene, do something?
	# or should this signal only be emitted with the correct scene to switch to attached?

# when the correct gesture is being gestured, show the rating tablet at the left hand
func _on_xr_origin_3d_rating_tablet_requested(left_hand_position: Transform3D) -> void:
	if EXPAR.currently_highlighted_image != null:
		# show the rating tablet for the currenly highilighted image
		EXPAR.currently_highlighted_image.show_rating_tablet(left_hand_position)
	else:
		xr.debug_message("Tried to show NULL tablet!")
	

#################################################### OTHER


func _on_scene_manager_debug_message(message: String) -> void:
	xr.debug_message("SceneManager: " + message)


func _on_xr_origin_3d_next_image_requested(left_hand_position: Transform3D) -> void:
	xr.debug_message("MAIN:trying to show next image...")
	scene_manager.present_next_image(left_hand_position)
