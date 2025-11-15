extends Node

## Simulate sex by dragging body parts to raise certain scores. Score thresholds result in certain effects (eg. orgasms).
## Some body parts are poseables, meaning that they are dragged into position and stay there. For example the torso of a woman during penetration, which must be dragged cyclicly to produce stimulation.
## Some body parts are soft, meaning that they deform to a "virtual hand" and can even be pushed around, but return to a neutral position and shape according to physics.

#NOTE: This is probably better implemented as an on-rails animation, where the mouse drag tells the position on the animation sequence.
# Physics is only used for jiggliness.

var selected : Node


func _unhandled_input(event:InputEvent):
	if event is InputEventMouseMotion:
		%Ray.position = get_viewport().get_camera_3d().project_ray_origin(event.position)
		%Ray.target_position = get_viewport().get_camera_3d().project_ray_normal(event.position) * 10000
		
		if %Ray.is_colliding():
			%Hand.show()
			%Hand.position = %Ray.get_collision_point()
		else:
			%Hand.hide()
			
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and selected == %Torso:
			%Torso.position += Vector3(0, -event.relative.y, 0) * 0.01
			%Torso.position.y = clamp(%Torso.position.y, -1, 1)
	
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			selected = %Ray.get_collider()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif event.is_released():
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
