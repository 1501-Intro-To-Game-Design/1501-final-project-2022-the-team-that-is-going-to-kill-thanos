extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var health = 10
export var damage = 2
export var speed = 50
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkIfDead()

func checkIfDead():
	if(health <= 0):
		dead = true

func _on_Enemy_body_entered(body):
	pass # Replace with function body.
