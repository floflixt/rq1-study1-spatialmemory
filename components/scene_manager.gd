extends Node3D

# the scene nodes
@onready var start_scene : Node3D = $Start
@onready var tutorial_scene : Node3D = $Tutorial
@onready var participant_info_scene : Node3D = $ParticipantInfo
@onready var calibration_scene : Node3D =$Calibration
@onready var task_practice_learning_scene : Node3D = $TaskPracticeLearning
@onready var task_practice_recall_scene : Node3D = $TaskPracticeRecall
@onready var learning_phase_scene : Node3D = $LearningPhase
@onready var recall_phase_scene : Node3D = $RecallPhase
@onready var end_scene : Node3D = $End
@onready var error_scene : Node3D = $Error

# these are mainly for debug purposes
signal scene_disabled
signal scene_enabled

####################################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# make all scenes invisble and disable them
	for scene_node : Node3D in self.get_children():
		scene_node.visible = false
		scene_node.process_mode = Node.PROCESS_MODE_DISABLED

	# save START to current_scene
	#EXPAR.current_scene = EXPAR.ExpState.START
	# make start scene ready
	switch_to_scene(EXPAR.ExpState.START)
	#switch_to_scene(EXPAR.current_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# keep the transforms continuously updated
	# this is the location the EXPERIMENTER places the cube  in the start scene
	#calibrated_experimenter = start_scene.initial_calibration_transform
	#EXPAR.calibrated_experimenter = calibrated_experimenter
	## this is the location the PARTICIPANT defines in the calibration scene
	#calibrated_origin = calibration_scene.calibrated_origin
	#EXPAR.calibrated_origin = calibrated_origin
	pass

#################################################################################### SCENE SWITCHING

func switch_to_scene(new_scene_name: EXPAR.ExpState) -> void:
	# disable the current scene, then switch to the next
	_disable_scene(EXPAR.current_scene)
	
	get_tree().call_group("xr", "participant_feedback", "WAIT", Color.WHITE)
	await get_tree().create_timer(1.5).timeout
	
	# update which scene is the current one
	EXPAR.current_scene = new_scene_name
	
	# for tutorial, participantInfo, error and end scene:
	# set the scene's rotation to match the START calibration cube (experimenter chosen)
	match new_scene_name:
		EXPAR.ExpState.START:
			_enable_scene(new_scene_name, Basis.IDENTITY)
		EXPAR.ExpState.PARTICIPANT_INFO, EXPAR.ExpState.ERROR:
			_enable_scene(new_scene_name, EXPAR.calibrated_experimenter)
		EXPAR.ExpState.CALIBRATION:
			# reset rotation and centre on START-cube
			#var transform_reset_rotation : Transform3D = Transform3D(Basis.IDENTITY, calibrated_experimenter.origin)
			_enable_scene(new_scene_name, EXPAR.calibrated_experimenter)
		# for the experimental scenes: CENTRE ON CALIBRATED CUBE
		# re-set roatation --------IMPORTANT--------
		EXPAR.ExpState.TUTORIAL, EXPAR.ExpState.TASK_PRACTICE_LEARNING, EXPAR.ExpState.TASK_PRACTICE_RECALL, EXPAR.ExpState.LEARNING_PHASE, EXPAR.ExpState.RECALL_PHASE, EXPAR.ExpState.END:
			# set the rotation of the calibration scene to match the BASIS IDENTITY rotation
			# -> so basically reset the rotation so that the coordinates are relative to the basis/origin transform
			#var transform_reset_rotation : Transform3D = Transform3D(Basis.IDENTITY, calibrated_origin.origin)
			_enable_scene(new_scene_name, EXPAR.calibrated_origin)
		_:
			_enable_scene(EXPAR.ExpState.ERROR, Basis.IDENTITY)
		
## this function defines the default order of the scenes for switching
func switch_to_next_scene() -> void:
	match EXPAR.current_scene:
		EXPAR.ExpState.START:
			switch_to_scene(EXPAR.ExpState.PARTICIPANT_INFO)
		EXPAR.ExpState.PARTICIPANT_INFO:
			switch_to_scene(EXPAR.ExpState.CALIBRATION)
		EXPAR.ExpState.CALIBRATION:
			match EXPAR.current_expversion:
				EXPAR.ExpVersion.LEARNING:
					switch_to_scene(EXPAR.ExpState.TASK_PRACTICE_LEARNING)
				EXPAR.ExpVersion.RECALL:
					switch_to_scene(EXPAR.ExpState.TUTORIAL)
				_:
					switch_to_scene(EXPAR.ExpState.ERROR)
		EXPAR.ExpState.TUTORIAL:
			switch_to_scene(EXPAR.ExpState.TASK_PRACTICE_RECALL)
		EXPAR.ExpState.TASK_PRACTICE_LEARNING:
			switch_to_scene(EXPAR.ExpState.LEARNING_PHASE)
		EXPAR.ExpState.TASK_PRACTICE_RECALL:
			switch_to_scene(EXPAR.ExpState.RECALL_PHASE)
		EXPAR.ExpState.LEARNING_PHASE:
			switch_to_scene(EXPAR.ExpState.END)
			get_tree().call_group("xr", "participant_feedback", "EXPERIMENT_COMPLETE", Color.GREEN)
		EXPAR.ExpState.RECALL_PHASE:
			switch_to_scene(EXPAR.ExpState.END)
			get_tree().call_group("xr", "participant_feedback", "EXPERIMENT_COMPLETE", Color.GREEN)
		EXPAR.ExpState.ERROR, EXPAR.ExpState.END:
			get_tree().call_group("log", "log", "scene_manager.gd/switch_to_next_scene()/QUIT")
			get_tree().quit()
		_:
			switch_to_scene(EXPAR.ExpState.ERROR)

func _disable_scene(scene_name: EXPAR.ExpState) -> void:
	var scene: Node3D = _scene_name_to_node(scene_name)
	scene.process_mode = Node.PROCESS_MODE_DISABLED
	scene.visible = false
	get_tree().call_group("log", "log", "scene_manager.gd/_disable_scene()/disabled " + str(EXPAR.ExpState.keys()[scene_name]))
	scene_disabled.emit(scene.name)
	
func _enable_scene(scene_name: EXPAR.ExpState, centre_on: Transform3D = Basis.IDENTITY) -> void:
	var scene: Node3D = _scene_name_to_node(scene_name)
	# centre the scene on the given location
	scene.global_transform = centre_on
	# and enable everything
	scene.process_mode = Node.PROCESS_MODE_INHERIT
	scene.visible = true
	# do the scene's specuial setup, if it has any
	if scene.is_in_group("setup"):
		scene.setup()
		get_tree().call_group("log", "log", "scene_manager.gd/_enable_scene()/setup complete " + str(EXPAR.ExpState.keys()[scene_name]))
	get_tree().call_group("log", "log", "scene_manager.gd/_enable_scene()/enabled " + str(EXPAR.ExpState.keys()[scene_name]))
	scene_enabled.emit(scene.name)

############################################################################################# HELPER

## get the scene node from the ExpState identifier
func _scene_name_to_node(scene_name: EXPAR.ExpState) -> Node3D:
	match scene_name:
		EXPAR.ExpState.START:
			return start_scene
		EXPAR.ExpState.TUTORIAL:
			return tutorial_scene
		EXPAR.ExpState.PARTICIPANT_INFO:
			return participant_info_scene
		EXPAR.ExpState.CALIBRATION:
			return calibration_scene
		EXPAR.ExpState.TASK_PRACTICE_LEARNING:
			return task_practice_learning_scene
		EXPAR.ExpState.TASK_PRACTICE_RECALL:
			return task_practice_recall_scene
		EXPAR.ExpState.LEARNING_PHASE:
			return learning_phase_scene
		EXPAR.ExpState.RECALL_PHASE:
			return recall_phase_scene
		EXPAR.ExpState.ERROR:
			return error_scene
		EXPAR.ExpState.END:
			return end_scene
		_:
			return error_scene

################################################################## REACT TO SIGNALS SENT FROM SCENES

## when a valid info file exists, go to calibration scene next -> happens only once
func participant_info_file_created() -> void:
	switch_to_scene(EXPAR.ExpState.CALIBRATION)

func _on_start_experiment_setup_finished() -> void:
	# since settings are done, let's notify all images whether they should be able to be picked up or not
	match EXPAR.current_expversion:
		EXPAR.ExpVersion.LEARNING:
			get_tree().call_group("images", "set_pickupability", false)
			get_tree().call_group("log", "log", "scene_manager.gd/_on_start_experiment_setup_finished()/image pickupability disabled")
		EXPAR.ExpVersion.RECALL:
			get_tree().call_group("images", "set_pickupability", true)
			get_tree().call_group("log", "log", "scene_manager.gd/_on_start_experiment_setup_finished()/image pickupability enabled")
	# and continue with the next scene
	switch_to_next_scene()

func _on_tutorial_tutorial_finished() -> void:
	switch_to_next_scene()

func _on_participant_info_participant_info_collected() -> void:
	switch_to_next_scene()

func _on_calibration_calibration_complete() -> void:
	switch_to_next_scene()
	# also start tracking the headset coordinates
	get_tree().call_group("log", "_on_hmd_tracker_timer_timeout")

# called when the end scene is set up AND we are in the LEARNING phase
func _on_end_save_final_ratings() -> void:
	task_practice_learning_scene.save_final_ratings()
	learning_phase_scene.save_final_ratings()
	get_tree().call_group("log", "log", "scene_manager.gd/_on_end_save_final_ratings()/practice+learning save_final_ratings called")

func _on_task_practice_learning_all_ratings_complete() -> void:
	switch_to_next_scene()
	
func _on_recall_phase_recall_phase_complete() -> void:
	switch_to_next_scene()

func _on_task_practice_recall_recall_phase_complete() -> void:
	get_tree().call_group("xr", "participant_feedback", "EXP_START", Color.WHITE)
	await get_tree().create_timer(1).timeout
	switch_to_next_scene()

func _on_learning_phase_learning_phase_finished() -> void:
	switch_to_next_scene()

func _on_end_experiment_complete() -> void:
	switch_to_next_scene()

######################################################################## PRESENT IMAGE DURING RECALL

# pass this on to the recall scene to get the next image
func present_next_image(hand_position: Transform3D) -> void:
	match EXPAR.current_scene:
		EXPAR.ExpState.TASK_PRACTICE_RECALL:
			get_tree().call_group("log", "log", "scene_manager.gd/present_next_image()/practice recall - trying to show next image")
			task_practice_recall_scene.present_next_image(hand_position)
		EXPAR.ExpState.RECALL_PHASE:
			get_tree().call_group("log", "log", "scene_manager.gd/present_next_image()/recall - trying to show next image")
			recall_phase_scene.present_next_image(hand_position)
		_:
			get_tree().call_group("log", "log", "scene_manager.gd/present_next_image()/Failed to get correct RECALL version practice vs real")
