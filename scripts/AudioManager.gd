extends Node

# Uses 2D/3D-agnostic AudioStreamPlayers arranged in children
@onready var bgm: AudioStreamPlayer = $BGM
@onready var sfx: AudioStreamPlayer = $SFX

var library := {
"lobby": null, # Can be replaced with real .ogg later
"night": null,
"panic": null,
"ding": null,
"buzz": null,
}

func play_bgm(key: String) -> void:
	if !library.has(key):
		return
	bgm.stop()
	bgm.stream = library[key]
	bgm.play()


func play_sfx(key: String) -> void:
	if !library.has(key):
		return
	sfx.stream = library[key]
	sfx.play()
