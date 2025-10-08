extends Node

var items := {
	"blood_bag": 2,
	"cobweb_pillow": 1,
	"silver_polish": 0,
}

func has_item(key:String) -> bool:
	return items.get(key, 0) > 0

func add_item(key:String, amount:int=1) -> void:
	items[key] = items.get(key, 0) + amount

func take_item(key:String, amount:int=1) -> bool:
	var cur: int = items.get(key, 0)
	if cur >= amount:
		items[key] = cur - amount
		return true
	return false
