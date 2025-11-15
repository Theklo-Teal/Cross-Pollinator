extends TacticsState

var cam_state

func _entering(_prev):
	cam_state = my("Cam").disabled
	me.require_UI(["Pause_Menu"])
	my("Cam").disabled = true

func _exiting(_next):
	my("Cam").disabled = cam_state
