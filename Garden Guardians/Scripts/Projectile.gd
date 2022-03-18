extends Node2D

var target = null
export var speed = 20
export var damage = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
		queue_free()
