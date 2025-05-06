extends CanvasLayer

signal rating_confirmed(ratings: String)

@export var colour_rated: int = 0
@export var complexity_rated: int = 0
@export var like_rated: int = 0
@export var ai_rated: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/TabContainer.set_tab_title(0, "COLOURFULNESS")
	$VBoxContainer/TabContainer.set_tab_title(1, "COMPLEXITY")
	$VBoxContainer/TabContainer.set_tab_title(2, "LIKE")
	$VBoxContainer/TabContainer.set_tab_title(3, "AI_GENERATED")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var total_ratings = colour_rated + complexity_rated + like_rated + ai_rated
	$VBoxContainer/ProgressBar.value = total_ratings
	if total_ratings == 4:
		$VBoxContainer/OkayButton.disabled = false
	

func _on_okay_button_pressed() -> void:
	var colour_rating: int = $VBoxContainer/TabContainer/Colours/ColourSlider.value
	var complexity_rating : int = $VBoxContainer/TabContainer/Complexity/ComplexitySlider.value
	var like_rating : int = $VBoxContainer/TabContainer/Like/LikeSlider.value
	var ai_rating : int = $VBoxContainer/TabContainer/AI/AISlider.value
	
	var ratings: String = str(colour_rating) + "," + str(complexity_rating) + "," + str(like_rating) + "," + str(ai_rating)
	rating_confirmed.emit(ratings)


func _on_colour_slider_drag_ended(value_changed: bool) -> void:
	colour_rated = 1


func _on_complexity_slider_drag_ended(value_changed: bool) -> void:
	complexity_rated = 1


func _on_like_slider_drag_ended(value_changed: bool) -> void:
	like_rated = 1


func _on_ai_slider_drag_ended(value_changed: bool) -> void:
	ai_rated = 1
