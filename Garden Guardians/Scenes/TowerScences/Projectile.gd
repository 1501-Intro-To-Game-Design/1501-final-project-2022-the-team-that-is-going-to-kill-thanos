extends Node2D

var target = null
export var speed = 20
export var damage = 2

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#move towards target (closest enemy)
	if not (target == null):
		var direction = (target.position - self.position).normalized()
		position += direction * speed * delta
		


func _on_Area2D_area_entered(area):
	if(area == target):
		target.change_health(-1 * damage)
		queue_free()
