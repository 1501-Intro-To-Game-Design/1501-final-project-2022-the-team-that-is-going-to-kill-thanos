extends Node2D


var velocity = Vector2.ZERO
var destination = Vector2.ZERO
var direction = Vector2.ZERO
export var speed = 1


var moving = false;
var clicked = false;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moving:
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.animation = "Standing"
		$AnimatedSprite.stop()
	
	if direction.x >= 0 and moving: #moving right
		$AnimatedSprite.animation = "Running"
		$AnimatedSprite.flip_h = false		
	elif direction.x < 0: #moving left
		$AnimatedSprite.animation = "Running"
		$AnimatedSprite.flip_h = true
	
	if moving and abs((destination - position).x) < 1 and abs((destination - position).y) < 1: #if youve arived
		moving = false
	#MOVEMENT STUFF
	velocity.x = 0
	if moving:  
		position += direction.normalized() * speed * delta * 10
		
		
func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if !clicked:
			destination = event.position 
			direction = destination - position;
			clicked = true
			moving = true;
		else: 
			clicked = false
			
		
	

func _on_AnimatedSprite_animation_finished():
	pass # Replace with function body.
