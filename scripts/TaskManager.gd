extends Node

# Tracks active guest requests and delivery order
var tasks: Array = [] # [{guest_id, need:"blood_bag", order:0..N, done:false}]

func add_task(guest_id:String, need:String, order:int) -> void:
	tasks.append({"guest_id":guest_id, "need":need, "order":order, "done":false})

func complete_task(guest_id:String, need:String) -> void:
	for t in tasks:
		if t.guest_id == guest_id and t.need == need:
			t.done = true
		break

func get_pending_sorted() -> Array:
	var pending := tasks.filter(func(t): return !t.done)
	pending.sort_custom(func(a,b): return a.order < b.order)
	return pending

func get_daily_delta() -> float:
	# Reward for completing >70% tasks
	if tasks.is_empty():
		return 0.0
	var done := tasks.filter(func(t): return t.done).size()
	var ratio := float(done)/float(tasks.size())
	return 0.5 if ratio >= 0.7 else -0.25
