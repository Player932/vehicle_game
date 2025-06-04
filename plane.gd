extends CharacterBody3D

var min_fligt_speed = 10.0
var max_fligt_speed = 30.0
var turn_speed = 0.75
var pitch_speed = 0.5
var level_speed = 3.0
var throttle_delta = 30.0
var acceleration = 6.0
var forward_speed = 0.0
var grounded = false
var target_speed = 0.0
var turn_input = 0.0
var pitch_input = 0.0

func _physics_process(delta):
	if Input.is_action_pressed('forward'):
		target_speed = min(forward_speed + throttle_delta * delta, max_fligt_speed)
	if Input.is_action_pressed('back'):
		var limit = 0.0 if grounded else min_fligt_speed
		target_speed = min(forward_speed - throttle_delta * delta, limit)
	turn_input = 0.0
	if forward_speed > 0.5:
		turn_input = (Input.get_action_strength('left') - Input.get_action_strength('right'))
	pitch_input = 0.0
	if not grounded:
		pitch_input -= Input.get_action_strength('down')
	if forward_speed >= min_fligt_speed:
		pitch_input += Input.get_action_strength('up')
	transform.basis = transform.basis.rotated(transform.basis.x, pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(Vector3.UP, turn_input * turn_speed * delta)
	if not grounded:
		$MeshInstance3D2.rotation.z = lerp($MeshInstance3D2.rotation.y, turn_input * 5.0, level_speed * delta)
	else:
		$MeshInstance3D2.rotation.z = lerp($MeshInstance3D2.rotation.y, 0.0, level_speed * delta)
	forward_speed = lerp(forward_speed, target_speed, acceleration * delta)
	move_and_slide()
	velocity = -transform.basis.z * forward_speed
	if is_on_floor():
		if not grounded:
			rotation.x = 0.0
		grounded = true
		velocity.y -= 1
	else:
		grounded = false


