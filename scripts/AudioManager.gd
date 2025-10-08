extends Node

var bgm: AudioStreamPlayer
var sfx: AudioStreamPlayer

func _ready() -> void:
	bgm = AudioStreamPlayer.new()
	add_child(bgm)
	sfx = AudioStreamPlayer.new()
	add_child(sfx)

var library := {
	"lobby": null,
	"night": null,
	"panic": null,
	"ding": null,
	"buzz": null,
}

func play_bgm(key: String) -> void:
	if !library.has(key): return
	bgm.stop()
	bgm.stream = library[key]
	bgm.play()

func play_sfx(key: String) -> void:
	if !library.has(key): return
	sfx.stream = library[key]
	sfx.play()
