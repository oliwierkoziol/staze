extends SceneTree


var bledy: Array[String] = []
const BibliotekaZdarzenMapyScript = preload("res://scripts/biblioteka_zdarzen_mapy.gd")


class AtrapaBitwy extends Node:
	var next_map_event_round := 3
	var round_number := 3
	var next_map_event_id := "wichura_lodowa"
	var map_event_cells: Array[Vector2i] = [Vector2i(5, 5)]
	var wykonane_zdarzenie := ""
	var zaplanowano_po_rundzie := -1
	var synchronizacje := 0

	func _event_global_move_penalty(event_id: String, event_name: String) -> void:
		wykonane_zdarzenie = "%s:%s" % [event_id, event_name]

	func _schedule_next_map_event(after_round: int) -> void:
		zaplanowano_po_rundzie = after_round

	func _sync_board() -> void:
		synchronizacje += 1


func _initialize() -> void:
	call_deferred("_uruchom")


func _sprawdz(warunek: bool, opis: String) -> void:
	if warunek:
		print("PASS: ", opis)
	else:
		bledy.append(opis)
		print("FAIL: ", opis)


func _uruchom() -> void:
	var bitwa := AtrapaBitwy.new()
	BibliotekaZdarzenMapyScript.wykonaj(bitwa)
	_sprawdz(bitwa.wykonane_zdarzenie == "wichura_lodowa:Wichura Lodowa", "Dispatcher wybiera wlasciwa obsluge zdarzenia")
	_sprawdz(bitwa.map_event_cells.is_empty(), "Wykonane zdarzenie czysci pola ostrzezenia")
	_sprawdz(bitwa.zaplanowano_po_rundzie == 3, "Po zdarzeniu planowana jest kolejna runda wydarzenia")
	_sprawdz(bitwa.synchronizacje == 1, "Po zdarzeniu plansza jest synchronizowana raz")
	bitwa.free()
	print("MAP_EVENT_TEST_FAILURES=", bledy.size())
	quit(bledy.size())
