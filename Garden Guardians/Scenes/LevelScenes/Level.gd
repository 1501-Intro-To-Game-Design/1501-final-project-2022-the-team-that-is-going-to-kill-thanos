extends Node2D

export(PackedScene) var player

# Called when the node enters the scene tree for the first time.
func _ready():
	var p = player.instance()
	p.position = Vector2(300,300)
	add_child(p)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
