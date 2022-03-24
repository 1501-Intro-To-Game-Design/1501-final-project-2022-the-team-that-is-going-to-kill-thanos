extends Node2D

var rng = RandomNumberGenerator.new()
var target = null
export var speed = 20
export var damage = 2.0
export var stun = false
var stun_chance = 0.15
var stun_duration = 0.4
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#move towards target (closest enemy)
	if is_instance_valid(target):
		var direction = (target.global_position - self.global_position).normalized()
		position += direction * speed * delta
	else:
		queue_free()
		


func _on_Area2D_area_entered(area):
	if(area == target):
		target.get_parent().change_health(-1 * damage)
		if stun:
			var my_random_number = rng.randf_range(0.00, 1.00)
			if my_random_number <= stun_chance:
				target.get_parent().start_stun(stun_duration)
		queue_free()
