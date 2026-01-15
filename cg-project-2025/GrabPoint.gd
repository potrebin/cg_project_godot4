extends Marker3D
class_name GrabPoint

# "reserved_by" = тентакля выбрала цель и тянется (но ещё не схватила)
# "occupied_by" = тентакля уже схватила и держит
var reserved_by: Node = null
var occupied_by: Node = null

func is_free() -> bool:
	return reserved_by == null and occupied_by == null

func is_reserved_or_occupied() -> bool:
	return reserved_by != null or occupied_by != null

func reserve(tentacle: Node) -> bool:
	if not is_free():
		return false
	reserved_by = tentacle
	return true

func occupy(tentacle: Node) -> void:
	# когда тентакля реально схватила
	reserved_by = null
	occupied_by = tentacle

func release(tentacle: Node) -> void:
	# освобождение при возврате/смерти/сбросе
	if reserved_by == tentacle:
		reserved_by = null
	if occupied_by == tentacle:
		occupied_by = null
