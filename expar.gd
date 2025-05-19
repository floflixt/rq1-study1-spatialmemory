extends Node

# This autoload script contains experimental parameters (EXPAR)

var is_debug_mode : bool = true

## file names and paths
var documents_path : String 
var participant_info_file : String
var participant_calibration_file : String
var log_file : String
var ratings_file : String
var placement_file : String
var savefile_images: String
var tracking_file : String = "NOFILE"

var rng_seed : int = 42
var sgic : String = "INVALID_SGIC"

## experiment information
enum ExpVersion { LEARNING,
				  RECALL, }
var current_expversion : ExpVersion = ExpVersion.LEARNING

# IMPORTANT: each ExpState needs a corresponding Node+Variable in the SceneManager
enum ExpState { START,
				TUTORIAL,
				PARTICIPANT_INFO,
				CALIBRATION,
				TASK_PRACTICE_LEARNING,
				TASK_PRACTICE_RECALL,
				LEARNING_PHASE,
				RECALL_PHASE,
				END,
				ERROR, }
var current_scene : ExpState

enum QuestNumber { SIXTEEN,
				   XXX}
var current_questnr : QuestNumber = QuestNumber.SIXTEEN

var furniture_condition: String = ""
var language : String = ""


## stuff to keep track of during the experiment
var images_array : Array[String]

var xr_interface : OpenXRInterface
var camera_transform : Transform3D 
var calibrated_experimenter: Transform3D
var calibrated_origin: Transform3D

var current_left_gesture : String = "..."
var current_right_gesture : String = "..."

var currently_highlighted_image : Node3D

const SAVE_INTERVAL_SEC : float = 0.1

###################################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# save file path: MyDocuments folder -> easy to find/access
	documents_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS, true) + "/"

	# get the list of possible images
	var dir := DirAccess.open("res://assets/images/")
	# apparently, assign() is necessary to convert from PackedStringArray to Array[String]
	images_array.assign(dir.get_files())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

###################################################################################################

## called once from participant_info once a valid sgic is entered to create all files with the code
func create_save_files(exp_version: String) -> bool:
	
	####### LOG FILE
	log_file = documents_path + sgic + "_" + exp_version + "_LOG.txt"
	if not FileAccess.file_exists(log_file):
		var file : FileAccess = FileAccess.open(log_file, FileAccess.READ_WRITE)
		file.store_string(Time.get_datetime_string_from_system(false) + ":created log file (" + str(Time.get_ticks_msec()) + " ticks_msec)\n")
		file.close()
	
	####### TRACKING FILE
	tracking_file = documents_path + sgic + "_" + exp_version + "_tracking.txt"
	if not FileAccess.file_exists(tracking_file):
		var file : FileAccess = FileAccess.open(tracking_file, FileAccess.READ_WRITE)
		file.store_line("currTime,x,y,z,rot.x,rot.y,rot.z")
		file.close()
	
	####### INFO FILE
	participant_info_file = documents_path + sgic + "_" + exp_version + "_INFO.json"
	# information to save
	var questnr_string : String
	match current_questnr:
		QuestNumber.SIXTEEN:
			questnr_string = "SIXTEEN"
		QuestNumber.XXX:
			questnr_string = "XXX"
	var info: Dictionary
	info = {
		"start_date_time": Time.get_datetime_string_from_system(false, false),
		"debug_mode": is_debug_mode,
		"rng_seed": rng_seed,
		"language": language,
		"current_questnr": questnr_string,
		"furniture_condition": furniture_condition,
	}
	# save information to file if it does not yet exist
	if not FileAccess.file_exists(participant_info_file):
		var file : FileAccess = FileAccess.open(participant_info_file, FileAccess.WRITE)
		file.store_string(JSON.stringify(info, "\t"))
		file.close()
		get_tree().call_group("log", "log", "expar.gd/create_save_files()/participant_info_file created")
	else:
		get_tree().call_group("log", "log", "expar.gd/create_save_files()/failed to create participant_info_file")
		return false
	
	######## CALIBRATION FILE
	participant_calibration_file = documents_path + sgic + "_" + exp_version + "_calibration.json"
	if not FileAccess.file_exists(participant_calibration_file):
		var file : FileAccess = FileAccess.open(participant_calibration_file, FileAccess.WRITE)
		file.close()
		get_tree().call_group("log", "log", "expar.gd/create_save_files()/participant_calibration_file created")
	else:
		get_tree().call_group("log", "log", "expar.gd/create_save_files()/failed to create participant_calibration_file")
		return false

	######## IMAGE LOCATIONS FILE
	savefile_images = documents_path + sgic + "_" + exp_version + "_image_locations.txt"
	if not FileAccess.file_exists(savefile_images):
		var file: FileAccess = FileAccess.open(savefile_images, FileAccess.WRITE)
		file.store_line("node,image,currTime,basis.x.x,basis.y.x,basis.z.x,origin.x,basis.x.y,basis.y.y,basis.z.y,origin.y,basis.x.z,basis.y.z.,basis.z.z,origin.z,currTimeDeg,rot.x,rot.y,rot.z,phase")
		file.close()
		get_tree().call_group("log", "log", "expar.gd/create_save_files()/savefile_images created")
	else:
		get_tree().call_group("log", "log", "expar.gd/create_save_files()/failed to create savefile_images")
		return false
	
	
	# create a file for the ratings in the learning phase, and a file for the placements in the recall phase
	if EXPAR.current_expversion == EXPAR.ExpVersion.LEARNING:
		####### RATINGS FILE
		ratings_file = documents_path + sgic + "_" + exp_version + "_ratings.txt"
		if not FileAccess.file_exists(ratings_file):
			var file : FileAccess = FileAccess.open(ratings_file, FileAccess.WRITE)
			file.store_line("image,currTime,dwellTime,liking,ai")
			file.close()
			get_tree().call_group("log", "log", "expar.gd/create_save_files()/_ratings file created")
		else:
			get_tree().call_group("log", "log", "expar.gd/create_save_files()/failed to create _ratings file")
			return false
	else:
		######### PLACEMENT FILE
		placement_file = documents_path + sgic + "_" + exp_version + "_placements.txt"
		if not FileAccess.file_exists(placement_file):
			var file : FileAccess = FileAccess.open(placement_file, FileAccess.WRITE)
			file.store_line("node,image,elapsedTime,currTime,basis.x.x,basis.y.x,basis.z.x,origin.x,basis.x.y,basis.y.y,basis.z.y,origin.y,basis.x.z,basis.y.z.,basis.z.z,origin.z,isNewImage,responseString,timeOfResponseButtonPress,currTimeDeg,rot.x,rot.y,rot.z,phase")
			file.close()
			get_tree().call_group("log", "log", "expar.gd/create_save_files()/_placements file created")
		else:
			get_tree().call_group("log", "log", "expar.gd/create_save_files()/failed to create _placements file")
			return false
	
	# if everything happemed up until here, we had complete success
	return true
	
	
