extends Node2D


var destination = Vector2.ZERO
var direction = Vector2.ZERO
export var speed = 1
export (PackedScene) var ui

var moving = false;
var clicked = false;

#Resources
var items = []

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
	if moving:  
		position += direction.normalized() * speed * delta * 10
	if items.size() > 0:
		for item in items:
			if abs((item.poosition - position).x) < 1.5 and abs((item.positon - position).y) < 1.5:
				if item.is_Wood:
					ui._update_Resources(true)
				if item.is_Metal:
					ui._update_Resources(false)

		
		
func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		if !clicked:
			destination = event.position 
			direction = destination - position
			clicked = true
			moving = true;
		else: 
			clicked = false
			
		
	

func _on_AnimatedSprite_animation_finished():
	pass # Replace with function body.


func _on_PickUp_area_entered(area:Area2D): #Resources
	var item = area.get_parent()
	if item.is_in_group("Resources"):
		item._pulled(position)
		items.append(item)
