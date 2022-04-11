extends Node2D

export(PackedScene) var player
export(PackedScene) var tower

# Called when the node enters the scene tree for the first time.

func _ready():
	ui.connect_stuff("Level")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
