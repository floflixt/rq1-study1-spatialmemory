extends CanvasLayer

# self generated identification code
var sgic : String = ""
var regex = RegEx.new()
var is_valid_sgic : bool = false

signal valid_sgic_entered

################################################################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	regex.compile("[A-Z]{2}[0-9]{2}[A-Z]{2}[0-9]{2}[A-Z]{2}")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# put all input together and mark as valid as soon as it matches the pattern
	sgic = $VBoxContainer/HBoxContainer/FirstName.text + $VBoxContainer/HBoxContainer2/BirthDay.text + $VBoxContainer/HBoxContainer3/MiddleName.text + $VBoxContainer/HBoxContainer4/BirthMonth.text + $VBoxContainer/HBoxContainer5/BirthCity.text
	
	if regex.search(sgic).get_string() == sgic:
		is_valid_sgic = true
	
	# enable button to continue if the code is valid
	$VBoxContainer/HBoxContainer6/Button.disabled = not is_valid_sgic
	
	#$VBoxContainer/Label2.text = "TEST"
	

## the following functions serve to go to the next input field if enter is pressed
## and convert letters to upper case

func _on_first_name_text_changed(new_text: String) -> void:
	$VBoxContainer/HBoxContainer/FirstName.text = new_text.to_upper()
	$VBoxContainer/HBoxContainer/FirstName.caret_column = new_text.length()
	
func _on_first_name_text_submitted(new_text: String) -> void:
	$VBoxContainer/HBoxContainer2/BirthDay.grab_focus()

func _on_birth_day_text_submitted(new_text: String) -> void:
	$VBoxContainer/HBoxContainer3/MiddleName.grab_focus()

func _on_middle_name_text_changed(new_text: String) -> void:
	$VBoxContainer/HBoxContainer3/MiddleName.text = new_text.to_upper()
	$VBoxContainer/HBoxContainer3/MiddleName.caret_column = new_text.length()
	
func _on_middle_name_text_submitted(new_text: String) -> void:
	$VBoxContainer/HBoxContainer4/BirthMonth.grab_focus()
	
func _on_birth_month_text_submitted(new_text: String) -> void:
	$VBoxContainer/HBoxContainer5/BirthCity.grab_focus()

func _on_birth_city_text_changed(new_text: String) -> void:
	$VBoxContainer/HBoxContainer5/BirthCity.text = new_text.to_upper()
	$VBoxContainer/HBoxContainer5/BirthCity.caret_column = new_text.length()

func _on_birth_city_text_submitted(new_text: String) -> void:
	$VBoxContainer/HBoxContainer6/Button.grab_focus()

func _on_button_pressed() -> void:
	EXPAR.sgic = sgic
	valid_sgic_entered.emit()
	
