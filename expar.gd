extends Node

# This autoload script contains experimental parameters (EXPAR)
var is_debug_mode : bool = true

## file paths
var documents_path : String 
#var spatial_anchors_file : String # maybe we don't even need the spatial anchors
var participant_info_file : String
var ratings_file : String
var placement_file : String
#var test_file_tracking : String
#var test_file : FileAccess
var images_array : Array[String]
var savefile_images: String

# default/debug seed
var rng_seed : int = 42
var sgic : String = "INVALID_SGIC"

var info_file_data

const SAVE_INTERVAL_SEC : float = 0.1
#var sec_since_last_save: float = 0

# IMPORTANT: each ExpState needs a corresponding Node+Variable in the SceneManager
enum ExpState { START,
				TUTORIAL, # TODO remove
				PARTICIPANT_INFO,
				CALIBRATION,
				TASK_PRACTICE_LEARNING,
				TASK_PRACTICE_RECALL,
				LEARNING_PHASE,
				RECALL_PHASE,
				END,
				ERROR, }
				
## Current state of the experiment
var current_scene : ExpState
				
enum ExpVersion { LEARNING,
				  RECALL, }
var current_expversion : ExpVersion = ExpVersion.LEARNING

enum QuestNumber { SIXTEEN,
				   TODO}
var current_questnr : QuestNumber = QuestNumber.SIXTEEN

var xr_interface : OpenXRInterface
var camera_transform : Transform3D 

var current_left_gesture : String = "..."
var current_right_gesture : String = "..."

var currently_highlighted_image : Node3D

var calibrated_experimenter: Transform3D
var calibrated_origin: Transform3D

var furniture_condition: String = ""
var language : String = ""

###################################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# save file path: MyDocuments folder -> easy to find/access
	documents_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS, true) + "/"
	#participant_info_file = documents_path + sgic + ".json"
	#save_expar_parameters()
	#spatial_anchors_file = documents_path + "spatial_anchors_file_empty.json"
	#test_file_tracking = documents_path + sgic + "_test_file_tracking.txt"
	
	# save file test for coordinate tracking
	#test_file = FileAccess.open(test_file_tracking, FileAccess.WRITE)

	# get the list of possible images
	var dir := DirAccess.open("res://assets/images/")
	# apparently, assign() is necessary to convert from PackedStringArray to Array[String]
	images_array.assign(dir.get_files())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	# add elapsed time to "time since last save"
	#sec_since_last_save += delta
	# if time since last save exceeds the save time interval
	#if sec_since_last_save >= SAVE_INTERVAL_SEC:
		# save stuff
		#test_file = FileAccess.open(test_file_tracking, FileAccess.WRITE)
		#test_file.store_string(MY.transf_to_csv(calibration_cube))
		#test_file.close()
		# reset the "time since last save"
		#sec_since_last_save = 0

func create_save_files(exp_version: String) -> bool:
	####### INFO FILE #########
	participant_info_file = documents_path + sgic + "_" + exp_version + "_INFO.json"
	# information to save
	var questnr_string : String
	match current_questnr:
		QuestNumber.SIXTEEN:
			questnr_string = "SIXTEEN"
		QuestNumber.TODO:
			questnr_string = "TODO"
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
		#get_tree().call_group("xr", "participant_feedback", "INFO file successfully created!", Color.GREEN)
	else:
		#get_tree().call_group("xr", "participant_feedback", "INFO file already exists!", Color.RED)
		return false

	######## IMAGE LOCATIONS FILE  ###########
	savefile_images = documents_path + sgic + "_" + exp_version + "_image_locations.txt"
	if not FileAccess.file_exists(savefile_images):
		var file: FileAccess = FileAccess.open(savefile_images, FileAccess.WRITE)
		file.store_line("node,image,currTime,basis.x.x,basis.y.x,basis.z.x,origin.x,basis.x.y,basis.y.y,basis.z.y,origin.y,basis.x.z,basis.y.z.,basis.z.z,origin.z,currTimeDeg,rot.x,rot.y,rot.z,phase")
		file.close()
	else:
		return false
	
	
	# create a file for the ratings in the learning phase, and a file for the placements in the recall phase
	if EXPAR.current_expversion == EXPAR.ExpVersion.LEARNING:
		####### RATINGS FILE #########
		# create an empty file first
		ratings_file = documents_path + sgic + "_ratings.txt"
		if not FileAccess.file_exists(ratings_file):
			var file : FileAccess = FileAccess.open(ratings_file, FileAccess.WRITE)
			# write the header
			file.store_line("image,currTime,dwellTime,colour,complexity,liking,ai")
			file.close()
			#get_tree().call_group("xr", "participant_feedback", "ratings file successfully created!", Color.GREEN)
		else:
			#get_tree().call_group("xr", "participant_feedback", "ratings file already exists!", Color.RED)
			return false
	else:
		######### PLACEMENT FILE ############
		placement_file = documents_path + sgic + "_placements.txt"
		if not FileAccess.file_exists(placement_file):
			var file : FileAccess = FileAccess.open(placement_file, FileAccess.WRITE)
			file.store_line("node,image,elapsedTime,currTime,basis.x.x,basis.y.x,basis.z.x,origin.x,basis.x.y,basis.y.y,basis.z.y,origin.y,basis.x.z,basis.y.z.,basis.z.z,origin.z,isNewImage,responseString,timeOfResponseButtonPress,currTimeDeg,rot.x,rot.y,rot.z,phase")
			file.close()
			#get_tree().call_group("xr", "participant_feedback", "placement file successfully created!", Color.GREEN)
		else:
			#get_tree().call_group("xr", "participant_feedback", "placement file already exists!", Color.RED)
			return false
	
	# if everything happemed up until here, we had complete success
	return true
	
	

#func get_info_file() -> bool:
	#participant_info_file = documents_path + sgic + "_INFO.json"
	## load the file as text, if it exists
	#if not FileAccess.file_exists(participant_info_file):
		#get_tree().call_group("xr", "debug_message", "No file found: " + participant_info_file)
		#return false
	#else:
		#var file := FileAccess.open(participant_info_file, FileAccess.READ)
		#var file_content: String = file.get_as_text()
		## check for json format
		#var json : JSON = JSON.new()
		#var error := json.parse(file_content)
		#if error == OK:
			#info_file_data = json.data
			#get_tree().call_group("xr", "debug_message", str(info_file_data["rng_seed"]))
			#return true
		#else:
			#get_tree().call_group("xr", "debug_message", "Error while reading file:" + participant_info_file)
			#return false
	
	
	
	

## prepare save file, spatial anchor file
#func _prepare_files() -> void:
	#
	## get user documents directory to save files to
	#documents_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS, true) + "/"
	#
	#spatial_anchors_file = documents_path + "spatial_anchors_test.json"
	#
	## create spatial anchors file if it not exists
	#if not FileAccess.file_exists(spatial_anchors_file):
		#var file : FileAccess = FileAccess.open(spatial_anchors_file, FileAccess.WRITE)
		#file.close()
#

	#
#func set_sgic(new_sgic: String) -> void:
	#sgic = new_sgic
#
	#var temp_file : FileAccess
	#participant_info_file = documents_path + sgic + ".json"
	#
	## create the file if it doesn't already exist
	#if not FileAccess.file_exists(participant_info_file):
		#temp_file = FileAccess.open(participant_info_file, FileAccess.WRITE)
		#save_participant_info(temp_file)
		#temp_file.close()
	#else:
		## if the file already exists, and we are in debug mode, then just replace it
		#if debug_mode:
			## remove the old file first
			#var dir = DirAccess.open(documents_path)
			#dir.remove(participant_info_file)
			#temp_file = FileAccess.open(participant_info_file, FileAccess.WRITE)
			#save_participant_info(temp_file)
			#temp_file.close()
		#else:
			## to not lose data, we add a suffix to the sgic and try again
			#set_sgic(sgic + "-X")
	

## saves some general participant information
#func save_participant_info(file : FileAccess) -> void:
	#var info: Dictionary
	#info = {
		#"sgic": sgic,
		#"start_date_time": Time.get_datetime_string_from_system(true),
		#"debug_mode": debug_mode,
		#"rng_seed": rng_seed,
	#}
	#file.store_string(JSON.stringify(info, "\t"))
	## notify the scene manager to go to the next scene
	#get_tree().call_group("SceneManager", "participant_info_file_created")
