extends Node2D

var tweenSprite = preload("res://scripts/tweenSprite.gd")
var textbox = preload("res://objects/textbox.tscn")

enum ENTRANCES {from_left,from_right,from_top,from_bottom,fade}
enum POSITIONS {left,middle,right}
const DEFAULT_TWEEN = 0.5
signal tweened

onready var background = get_node("../background")
onready var gui = get_node("../gui")
onready var screen = get_viewport_rect()
var guid = false


func _ready():
	set_process(true)
	
	changeBackground("gradient")
	
	yield(addSprite("bat","1",from_bottom,middle,1),"tweened")
	yield(addSprite("bat","2",from_bottom,middle,1),"tweened")
	yield(addSprite("bat","3",from_bottom,middle,1),"tweened")
	yield(addSprite("bat","4",from_bottom,middle,1),"tweened")
	yield(addSprite("bat","5",from_bottom,middle,1),"tweened")
	
	yield(say("Angela Crawfordstein","helkl eyah\nI am seriously going to kill you one day it's\nnot a fuckling JOKE I AM GOING TO KILL YOU Orange Man"),"read")


	yield(removeSprite("1",from_bottom),"tweened")
	yield(removeSprite("2",from_bottom),"tweened")
	yield(removeSprite("3",from_bottom),"tweened")
	yield(removeSprite("4",from_bottom),"tweened")
	yield(removeSprite("5",from_bottom),"tweened")
	
	yield(changeBackground("fire"),"tweened")
	
	yield(say("narattoror","Meanwhile at tango's house"),"read")
	yield(addSprite("car","1",from_left,middle,1),"tweened")
	yield(say("Angela Crawfordstein","It's nice out"),"read")
	yield(removeSprite("1",from_right),"tweened")


func changeBackground(texture):
	var pic = tweenSprite.new(texture,false,false)
	background.add_child(pic)
	pic.set_opacity(0)
	pic.go(Vector2(),DEFAULT_TWEEN,1)
	pic.connect("tweened",self,"backgroundChanged",[pic])
	return self

func backgroundChanged(pic):
	for child in background.get_children(): if (child != pic): child.queue_free()
	emit_signal("tweened")


func say(name,text,replies=["->"]):
	if (guid): return null
	guid = true
	var ib = textbox.instance()
	gui.add_child(ib)
	ib.get_node("name").set_text(name)
	ib.get_node("content").set_text(text)
	
	for i in range(replies.size()):
		var button = Button.new()
		button.set_text(replies[i])
		button.set_v_size_flags(Control.SIZE_EXPAND_FILL)
		button.connect("button_down",ib,"pressed",[i])
		ib.get_node("vbox").add_child(button)
	ib.connect("read",self,"removeTextbox",[ib])
	return ib


func removeTextbox(index,box):
	guid = false


func settle():
	var section = screen.size.x / get_child_count()
	var i = 0
	for child in get_children():
		var idealX = section * i + section / 2 - screen.size.x / 2
		child.go(Vector2(idealX,0),DEFAULT_TWEEN)
		i += 1


func addSprite(name,specialName,entrance,position,fixTop=true):
	var sprite = tweenSprite.new(name,fixTop)
	sprite.set_name(specialName)
	add_child(sprite)
	if (position == left): move_child(sprite,0)
	if (position == middle): move_child(sprite,round(get_child_count() / 2))
	
	if (entrance == fade):
		sprite.set_opacity(0)
		sprite.set_global_pos(Vector2(screen.size.x / 2,screen.size.y / 2))
	if (entrance == from_top): sprite.set_global_pos(Vector2(screen.size.x / 2,-100))
	if (entrance == from_right): sprite.set_global_pos(Vector2(screen.size.x,screen.size.y / 2))
	if (entrance == from_bottom): sprite.set_global_pos(Vector2(screen.size.x / 2,screen.size.y))
	if (entrance == from_left): sprite.set_global_pos(Vector2(0,screen.size.y / 2))
	settle()
	return sprite


func removeSprite(name,entrance):
	var sprite = get_node(name)
	var target = Vector2()
	var opacityTarget = 1
	if (entrance == fade):
		opacityTarget = 0
		target = sprite.get_pos()
	if (entrance == from_top): target.y = -screen.size.y
	if (entrance == from_right): target.x = screen.size.x / 2
	if (entrance == from_bottom): target.y = screen.size.y
	if (entrance == from_left): target.x = -screen.size.x / 2
	sprite.go(target,DEFAULT_TWEEN,opacityTarget)
	sprite.connect("tweened",self,"spriteRemoved",[sprite])
	return self


func spriteRemoved(sprite):
	remove_child(sprite)
	sprite.queue_free()
	emit_signal("tweened")
	settle()
	yield(get_tree(), "idle_frame")
	return sprite