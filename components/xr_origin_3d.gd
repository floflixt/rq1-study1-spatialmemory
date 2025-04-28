extends XROrigin3D

## Spatial Anchors
#@onready var scene_manager: OpenXRFbSceneManager = $OpenXRFbSceneManager
#@onready var spatial_anchor_manager: OpenXRFbSpatialAnchorManager = $OpenXRFbSpatialAnchorManager
#var anchor_uuids: Array[StringName] = []

@onready var rating_tablet : PackedScene = preload("res://components/rating_tablet.tscn")

## Tracking Status
var xr_interface : OpenXRInterface
var current_tracking_status : OpenXRInterface.TrackingStatus
var tracking_status_debug : String = ""

signal scene_switch_requested
signal rating_tablet_requested(left_hand_position: Transform3D)
signal next_image_requested(left_hand_position: Transform3D)

##############################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# at this point, XR should already be loaded and working, so we try to load the spatial anchors we saved
	# (because the StartXR node comes before this one and thus should be initialized before this one)
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		# connect signal to the function below (_on_openxr_session_begun) which then loads the anchors
		xr_interface.session_begun.connect(_on_openxr_session_begun)
	
	# reset stuff 
	participant_feedback("", Color.WHITE)
	_disable_poking($RightTrackedHand/RightHandHumanoid2/RightHandHumanoid/Skeleton3D/BoneAttachment3D/Poke)
	_disable_poking($LeftTrackedHand/LeftHandHumanoid2/LeftHandHumanoid/Skeleton3D/BoneAttachment3D/Poke)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#EXPAR.current_left_hand_transform = $LeftTrackedHand.global_transform
	$XRCamera3D.set_cull_mask_value(2, EXPAR.is_debug_mode)

	# the following provide mostly debug information
	$XRCamera3D/Feedback/CurrentScene.text = EXPAR.ExpState.keys()[EXPAR.current_scene]
	$XRCamera3D/Feedback/FrameRate.text = str(Engine.get_frames_per_second()) + " Hz"
	
	$RightVirtualController/Marker3D/MarkerPosition.text = "global_transform\n" + MY.transf_to_str($RightVirtualController/Marker3D/MarkerPosition.global_transform)
	
	EXPAR.camera_transform = $XRCamera3D.global_transform
	
	# display debug information if debugging
	if EXPAR.is_debug_mode:
		# tracking status
			# keep track of the tracking status
		current_tracking_status = xr_interface.get_tracking_status()
		match current_tracking_status:
			OpenXRInterface.TrackingStatus.XR_NORMAL_TRACKING:
				tracking_status_debug = "normal"
			OpenXRInterface.TrackingStatus.XR_EXCESSIVE_MOTION:
				tracking_status_debug = "XR_EXCESSIVE_MOTION"
				participant_feedback("Please move slower!", Color.YELLOW)
			OpenXRInterface.TrackingStatus.XR_INSUFFICIENT_FEATURES:
				tracking_status_debug = "XR_INSUFFICIENT_FEATURES"
				participant_feedback("Not enough features for tracking", Color.RED)
			OpenXRInterface.TrackingStatus.XR_UNKNOWN_TRACKING:
				tracking_status_debug = "XR_UNKNOWN_TRACKING"
				participant_feedback("Unknown tracking", Color.RED)
			OpenXRInterface.TrackingStatus.XR_NOT_TRACKING:
				tracking_status_debug = "XR_NOT_TRACKING"
				participant_feedback("Not tracking", Color.RED)
			_:
				tracking_status_debug = "no valid tracking status"
				participant_feedback("Tracking error", Color.RED)
		$XRCamera3D/Feedback/TrackingStatus.text = tracking_status_debug


func _on_openxr_session_begun() -> void:
	pass
	#load_spatial_anchors_from_file()


########################################################## FEEDBACK

func participant_feedback(message: String, color: Color = Color.WHITE) -> void:
	$XRCamera3D/Feedback/ParticipantFeedback.modulate = color
	# if timer for warning message is not currently running, show the message
	if $XRCamera3D/Feedback/ParticipantFeedback/Timer.is_stopped():
		$XRCamera3D/Feedback/ParticipantFeedback.text = message
		$XRCamera3D/Feedback/ParticipantFeedback/Timer.start()
	
# clear feedback text + reset color
func _on_timer_timeout() -> void:
	$XRCamera3D/Feedback/ParticipantFeedback.text = ""
	$XRCamera3D/Feedback/ParticipantFeedback.modulate = Color.WHITE
	
func debug_message(message: String) -> void:
	$XRCamera3D/Feedback/DebugMessage.text += "\n" + message

###############################################################


func _on_right_hand_pose_detector_pose_started(p_name: String) -> void:
	$RightTrackedHand/RightHandLabel.text = p_name
	if p_name == "Fist":
		EXPAR.current_right_gesture = "Fist"
	if p_name == "Point":
		EXPAR.current_right_gesture = "Point"
		_enable_poking($RightTrackedHand/RightHandHumanoid2/RightHandHumanoid/Skeleton3D/BoneAttachment3D/Poke)
	if p_name == "ThumbsUp":
		EXPAR.current_right_gesture = "ThumbsUp"
	if p_name == "Spock":
		EXPAR.current_right_gesture = "Spock"
	if p_name == "Metal":
		EXPAR.current_right_gesture = "Metal"
		#pass
		if EXPAR.is_debug_mode:
			# manual scene switching, only in debug mode
			scene_switch_requested.emit()
			#pass
	if p_name == "OpenHand":
		EXPAR.current_right_gesture = "OpenHand"
		match EXPAR.current_scene:
			EXPAR.ExpState.TASK_PRACTICE_LEARNING, EXPAR.ExpState.LEARNING_PHASE:
				rating_tablet_requested.emit($RightVirtualController/TabletLocation.global_transform)
			EXPAR.ExpState.TASK_PRACTICE_RECALL, EXPAR.ExpState.RECALL_PHASE:
				debug_message("next_image_requested-Right")
				next_image_requested.emit($RightVirtualController/TabletLocation.global_transform)
		
		
	#if p_name == "ThumbsUp" and (EXPAR.current_scene == EXPAR.ExpState.START):
		#EXPAR.is_debug_mode = not EXPAR.is_debug_mode
		# make debug stuff visible if in debug mode
		#$XRCamera3D.set_cull_mask_value(2, EXPAR.is_debug_mode)
		#participant_feedback("Toggled Debug Mode: " + str(EXPAR.is_debug_mode), Color.BLUE)
	
	
	
		
#XRServer.center_on_hmd(XRServer.DONT_RESET_ROTATION, true)
#debug_message("MANUAL RECENTERING TRIGGERED")		

func _on_right_hand_pose_detector_pose_ended(p_name: String) -> void:
	EXPAR.current_right_gesture = "..."
	if p_name == "Point":
		_disable_poking($RightTrackedHand/RightHandHumanoid2/RightHandHumanoid/Skeleton3D/BoneAttachment3D/Poke)
	

func _on_left_hand_pose_detector_pose_started(p_name: String) -> void:
	$LeftTrackedHand/LeftHandLabel.text = p_name
	if p_name == "Fist":
		EXPAR.current_left_gesture = "Fist"
	if p_name == "Point":
		EXPAR.current_left_gesture = "Point"
		# enable poking
		_enable_poking($LeftTrackedHand/LeftHandHumanoid2/LeftHandHumanoid/Skeleton3D/BoneAttachment3D/Poke)
	if p_name == "ThumbsUp":
		EXPAR.current_left_gesture = "ThumbsUp"
	if p_name == "Spock":
		EXPAR.current_left_gesture = "Spock"
	if p_name == "Metal":
		EXPAR.current_left_gesture = "Metal"
	if p_name == "OpenHand":
		EXPAR.current_left_gesture = "OpenHand"
		match EXPAR.current_scene:
			EXPAR.ExpState.TASK_PRACTICE_LEARNING, EXPAR.ExpState.LEARNING_PHASE:
				rating_tablet_requested.emit($LeftVirtualController/TabletLocation.global_transform)
			EXPAR.ExpState.TASK_PRACTICE_RECALL, EXPAR.ExpState.RECALL_PHASE:
				debug_message("next_image_requested-LEFT")
				next_image_requested.emit($LeftVirtualController/TabletLocation.global_transform)

	#if p_name == "ThumbsUp":
		#$"../SceneManager".switch_to_scene("Calibration")
		#pass
	#if p_name == "Metal":
		#scene_switch_requested.emit()
		#get_tree().call_group("SceneManager", "switch_to_scene", EXPAR.ExpState.PARTICIPANT_INFO)
	#if p_name == "Spock":
		#debug_message("Spatial Anchor created!")
		#var right_index_transform : Transform3D = $RightVirtualController/Marker3D.global_transform
		#right_index_transform.basis = right_index_transform.basis.rotated(Vector3(0, 1, 0), 180)
		#right_index_transform.basis = Basis.IDENTITY
		#spatial_anchor_manager.create_anchor(right_index_transform)
	#if p_name == "OpenHand":
		#spatial_anchor_manager.create_anchor($LeftTrackedHand.global_transform)
		#var new_tablet : Node3D = rating_tablet.instantiate()
		#$LeftTrackedHand.add_child(new_tablet, true)
		#debug_message("Tablet created")
		#pass

func _on_left_hand_pose_detector_pose_ended(p_name: String) -> void:
	EXPAR.current_left_gesture = "..."
	if p_name == "Point":
		_disable_poking($LeftTrackedHand/LeftHandHumanoid2/LeftHandHumanoid/Skeleton3D/BoneAttachment3D/Poke)

#func _on_open_xr_fb_spatial_anchor_manager_openxr_fb_spatial_anchor_tracked(anchor_node: Object, spatial_entity: Object, is_new: bool) -> void:
	#if is_new:
		#save_spatial_anchors_to_file()
		## additionally, save the anchor uuid for deleting the latest anchor
		#anchor_uuids.push_front(spatial_entity.uuid)

#func _on_open_xr_fb_spatial_anchor_manager_openxr_fb_spatial_anchor_untracked(anchor_node: Object, spatial_entity: Object) -> void:
	#save_spatial_anchors_to_file()

#func save_spatial_anchors_to_file() -> void:
	#var file := FileAccess.open(EXPAR.spatial_anchors_file, FileAccess.WRITE)
	#if not file:
		#debug_message(str("ERROR: Unable to open file for writing: ", EXPAR.spatial_anchors_file))
		#return
	#var anchor_data: Dictionary
	#for uuid in spatial_anchor_manager.get_anchor_uuids():
		#var entity: OpenXRFbSpatialEntity = spatial_anchor_manager.get_spatial_entity(uuid)
		#anchor_data[uuid] = entity.custom_data
	#file.store_string(JSON.stringify(anchor_data))
	#file.close()

#func load_spatial_anchors_from_file() -> void:
	#var file := FileAccess.open(EXPAR.spatial_anchors_file, FileAccess.READ)
	#if not file:
		#return
	#var json := JSON.new()
	#if json.parse(file.get_as_text()) != OK:
		#debug_message("Error: Unable to parse spatial_anchors_file")
		#return
	#if not json.data is Dictionary:
		#debug_message("Error: spatial_anchors_file contains invalid data")
		#return
	#var anchor_data : Dictionary = json.data
	#if anchor_data.size() > 0:
		#spatial_anchor_manager.load_anchors(anchor_data.keys(), anchor_data, OpenXRFbSpatialEntity.STORAGE_LOCAL, true)



func _enable_poking(poke_node: XRToolsPoke) -> void:
	poke_node.enabled = true
	poke_node.visible = true
	
func _disable_poking(poke_node: XRToolsPoke) -> void:
	poke_node.enabled = false
	poke_node.visible = false


func _on_left_hand_collision_body_entered(body: Node3D) -> void:
	# if we are colliding with an image, highlight that image
	if body.is_in_group("images"):
		# only change highlight if we are in the learning phase
		if EXPAR.current_expversion == EXPAR.ExpVersion.LEARNING:
			body.toggle_highlighted()
		# debug information
		$LeftVirtualController/LeftHandCollision/Label3D.text = body.name
		debug_message("LeftHandCollision:" + body.name)
		
func _on_right_hand_collision_body_entered(body: Node3D) -> void:
	if body.is_in_group("images"):
		if EXPAR.current_expversion == EXPAR.ExpVersion.LEARNING:
			body.toggle_highlighted()
		# debug information
		$RightVirtualController/RightHandCollision/Label3D.text = body.name
		debug_message("RightHandCollision:" + body.name)

func enable_ranged() -> void:
	$RightVirtualController/FunctionPickup.ranged_enable = true
	
func disable_ranged() -> void:
	$RightVirtualController/FunctionPickup.ranged_enable = false
