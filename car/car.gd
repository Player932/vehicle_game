extends VehicleBody3D

@export_range(0,1) var max_steering = .5
@export var engine_power = 21000
@export var cam_speed = 5.0
@export var max_velocity = 30

@onready var headlightl = $lights/headlightleft
@onready var headlightr = $lights/headlightright
var light = false

@onready var horn = $horn

@onready var action_cam = $pivot/action
@onready var reverse_cam = $pivot/reverse
@onready var god_cam = $pivot/god
@onready var perspective_cam = $perspective
@onready var pivot = $pivot
var cam_used = 1
var look_at

@onready var speedometer = $speedometer
@onready var speedometer_val = $value
var velocity
var converted
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.get_window().mode = 2
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	look_at = global_position
	
	var s = get_viewport().size
	speedometer.position = Vector2(s.x/2, s.y - s.y/7)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = linear_velocity.length()
	velocity= clamp(velocity,0,max_velocity)
	converted = velocity * 3.6
	speedometer.rotation = deg_to_rad(1.2 * (converted - 25))
	speedometer_val.text = str(int(converted))+' km/h'
	if Input.is_action_just_pressed('restart'):
		rotation = Vector3(0,rotation.y,0)
	elif Input.is_action_just_pressed('exit'):
		get_tree().quit()
		
	steering = lerp(steering,Input.get_axis("right","left") * max_steering, delta * 3)
	engine_force = Input.get_axis("back","forward") * engine_power
	
	if velocity > max_velocity:
		engine_force = 0
		
	if Input.is_action_just_pressed('light'):
		light = !light
		headlightl.light_energy = int(light) * 16
		headlightr.light_energy = int(light) * 16
	if Input.is_action_just_pressed('horn'):
		horn.play()
		
	pivot.global_position = pivot.global_position.lerp(global_position, delta * cam_speed)
	pivot.transform = pivot.transform.interpolate_with(transform, delta * cam_speed/2)
	look_at = look_at.lerp(global_position + linear_velocity, delta * cam_speed/2)
	
	action_cam.look_at(look_at)
	reverse_cam.look_at(look_at)
	god_cam.look_at(look_at)
	if Input.is_action_just_pressed('cam_change'):
		if cam_used == 3:
			cam_used = 1
		else:
			cam_used += 1
		
	if cam_used == 1:
		if linear_velocity.dot(transform.basis.z) > -1:
			action_cam.current = true
		else:
			reverse_cam.current = true
	elif cam_used == 2:
		perspective_cam.current = true
	elif cam_used == 3:
		god_cam.current = true
	
