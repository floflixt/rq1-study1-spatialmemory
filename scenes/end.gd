extends Node3D

signal save_final_ratings
signal experiment_complete

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func setup() -> void:
	if EXPAR.current_expversion == EXPAR.ExpVersion.LEARNING:
		save_final_ratings.emit()
		$FinalTimer.start()
	else:
		$FinalTimer.start()
	


func _on_final_timer_timeout() -> void:
	experiment_complete.emit()
