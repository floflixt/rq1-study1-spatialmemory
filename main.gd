extends Node3D

# as soon as the scene manager node is ready, assign it to these variables
@onready var scene_manager : Node3D = $SceneManager
@onready var xr : XROrigin3D = $XROrigin3D


## these are to keep track of various transforms/locations
var calibrated_origin : Transform3D
var calibration_cube : Transform3D
var current_left_hand_transform : Transform3D
var current_right_hand_transform : Transform3D

var hmd_location : String

var time_since_last_save_hmd: float = 0.0

## self generated identification code
var sgic : String = "XX-00-XX-00-XX" # this default code is invalid!

####################################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# keep track of transforms
	calibration_cube = $SceneManager/Start.initial_calibration_transform

#################################################################################### SIGNALS + DEBUG

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

################################################################################## GESTURE TRIGGERED

func _on_xr_origin_3d_scene_switch_requested() -> void:
	scene_manager.switch_to_next_scene()

# when the correct gesture is being gestured, show the rating tablet at the left hand
func _on_xr_origin_3d_rating_tablet_requested(left_hand_position: Transform3D) -> void:
	if EXPAR.currently_highlighted_image != null:
		# show the rating tablet for the currenly highilighted image
		EXPAR.currently_highlighted_image.show_rating_tablet(left_hand_position)
	else:
		self.log("main.gd/_on_xr_origin_3d_rating_tablet_requested()/tried to show NULL tablet")

func _on_xr_origin_3d_next_image_requested(left_hand_position: Transform3D) -> void:
	self.log("main.gd/_on_xr_origin_3d_next_image_requested()/trying to show next image...")
	scene_manager.present_next_image(left_hand_position)
	
##################################################################################### LOG + TRACKING

func log(info: String) -> void:
	var log_info: String = Time.get_datetime_string_from_system(false) + ":" + info
	var file: FileAccess = FileAccess.open(EXPAR.log_file, FileAccess.READ_WRITE)
	file.seek_end()
	file.store_line(log_info)
	file.close()
	# in debug mode, show the log
	# WARNING: might seriously impact performance!
	if EXPAR.is_debug_mode:
		xr.debug_message(log_info)


func _on_hmd_tracker_timer_timeout() -> void:
	hmd_location = MY.vec_to_csv($XROrigin3D/XRCamera3D.global_position - $SceneManager/Calibration/CalibratedOrigin.global_position) + "," + str(snapped($XROrigin3D/XRCamera3D.rotation_degrees.x - $SceneManager/Calibration/CalibratedOrigin.rotation_degrees.x, 0.001)) + "," + str(snapped($XROrigin3D/XRCamera3D.rotation_degrees.y - $SceneManager/Calibration/CalibratedOrigin.rotation_degrees.y, 0.001)) + "," + str(snapped($XROrigin3D/XRCamera3D.rotation_degrees.z - $SceneManager/Calibration/CalibratedOrigin.rotation_degrees.z, 0.001))
	#xr.debug_message(hmd_location)
	var tfile: FileAccess = FileAccess.open(EXPAR.tracking_file, FileAccess.READ_WRITE)
	tfile.seek_end()
	tfile.store_line(hmd_location)
	#xr.debug_message(EXPAR.tracking_file + ":" + hmd_location)
	tfile.close()
	$HMDTrackerTimer.start()
