extends CanvasLayer

signal experiment_started

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quest_number_selection_item_selected(index: int) -> void:
	match index:
		0:
			EXPAR.current_questnr = EXPAR.QuestNumber.SIXTEEN
		1:
			EXPAR.current_questnr = EXPAR.QuestNumber.XXX


func _on_experiment_version_selection_item_selected(index: int) -> void:
	match index:
		0:
			EXPAR.current_expversion = EXPAR.ExpVersion.LEARNING
		1:
			EXPAR.current_expversion = EXPAR.ExpVersion.RECALL



func _on_check_button_toggled(toggled_on: bool) -> void:
	EXPAR.is_debug_mode = toggled_on


func _on_start_experiment_pressed() -> void:
	experiment_started.emit()


func _on_participant_language_item_selected(index: int) -> void:
	match index:
		0:
			EXPAR.language = "DE"
			TranslationServer.set_locale("de")
		1:
			EXPAR.language = "EN"
			TranslationServer.set_locale("en")
		_:
			EXPAR.language = "NO-LANGUAGE-SELECTED"
			TranslationServer.set_locale("en")

func _on_furniture_shift_condition_item_selected(index: int) -> void:
	match index:
		0:
			EXPAR.furniture_condition = "NO-SHIFT"
		1:
			EXPAR.furniture_condition = "FURNITURE-SHIFT"
		_:
			EXPAR.furniture_condition = "NO-FURNITURE-CONDITION-SELECTED"
