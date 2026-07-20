class_name BibliotekaZdarzenMapy


const MAKSYMALNE_PRZESZKODY: Dictionary = {
	"woda": 6,
	"kamienie": 4,
	"krzok": 6,
	"ruchome_piaski": 6,
	"holy_tree": 5,
	"cart": 3,
	"elf_statue": 6,
	"hole": 4,
	"detonator": 2,
}

const PULE: Dictionary = {
	"orcs_vs_elves_forest": ["gniew_korzeni", "przebudzenie_gaju", "lesne_opary", "magiczny_rozkwit"],
	"dwarves_vs_goblins_mine": ["spadajacy_rumosz", "wybuch_gazu", "pekniecie_chodnika", "zawal_kopalni"],
	"humans_vs_orcs_village": ["rozprzestrzeniajacy_sie_pozar", "gesty_dym", "przerwanie_grobli", "plonace_zabudowania"],
	"elves_vs_dwarves_pass": ["wichura_lodowa", "sniezna_zamiec", "oblodzenie", "lawina"],
	"humans_vs_goblins_desert": ["burza_piaskowa", "zapadlisko", "palacy_skwar", "pustynny_podmuch"],
}

const DANE: Dictionary = {
	"gniew_korzeni": {"name": "Gniew Korzeni", "icon": preload("res://assets/ui/root.png"), "description": "Oznacza 3 pola. Jednostki stojace na nich otrzymuja zasieg ruchu 0 przez 1 ture."},
	"przebudzenie_gaju": {"name": "Przebudzenie Gaju", "icon": preload("res://assets/mapTiles/bush.png"), "description": "Tworzy 3 nowe krzaki na oznaczonych polach."},
	"lesne_opary": {"name": "Lesne Opary", "icon": preload("res://assets/ui/reveal.png"), "description": "Zmniejsza zasieg ataku wszystkich jednostek o 1 przez 1 ture."},
	"magiczny_rozkwit": {"name": "Magiczny Rozkwit", "icon": preload("res://assets/ui/aura.png"), "description": "Oznacza 3 pola. Kazdy stojacy na nich oddzial odzyskuje HP rowne bazowemu HP jednej jednostki, nie przekraczajac maksimum."},
	"spadajacy_rumosz": {"name": "Spadajacy Rumosz", "icon": preload("res://assets/mapTiles/rock1.png"), "description": "Oznacza 3 pola. Zadaje 1 obrazenie za kazda zywa jednostke w stojacym na nich oddziale."},
	"wybuch_gazu": {"name": "Wybuch Gazu", "icon": preload("res://assets/ui/poison_cloud.png"), "description": "Tworzy toksyczna chmure na 5-8 polach na 2 rundy. Zatrucie zadaje 1 obrazenie za kazda zywa jednostke w oddziale przez 2 tury."},
	"pekniecie_chodnika": {"name": "Pekniecie Chodnika", "icon": preload("res://assets/ui/water.png"), "description": "Tworzy 3 pola wody. Wejscie zuzywa caly pozostaly ruch jednostki."},
	"zawal_kopalni": {"name": "Zawal Kopalni", "icon": preload("res://assets/mapTiles/rock2.png"), "description": "Tworzy kamienie na 2 polach. Jednostka na oznaczonym polu otrzymuje 1 obrazenie za kazdego zywego czlonka oddzialu; kamienie powstaja, jesli pole zostanie zwolnione."},
	"rozprzestrzeniajacy_sie_pozar": {"name": "Rozprzestrzeniajacy sie Pozar", "icon": preload("res://assets/ui/fire.png"), "description": "Tworzy ogien na 5-8 polach na 2 rundy. Ploniecie zadaje 2 obrazenia za kazda zywa jednostke w oddziale przez 3 tury."},
	"gesty_dym": {"name": "Gesty Dym", "icon": preload("res://assets/ui/reveal.png"), "description": "Okrywa przechodnie pola Mgla na 1 runde. Wrogie jednostki sa widoczne tylko z sasiednich pol."},
	"przerwanie_grobli": {"name": "Przerwanie Grobli", "icon": preload("res://assets/ui/water.png"), "description": "Tworzy 3 pola wody. Wejscie zuzywa caly pozostaly ruch jednostki."},
	"plonace_zabudowania": {"name": "Plonace Zabudowania", "icon": preload("res://assets/ui/fire.png"), "description": "Oznacza 3 pola. Zadaje 1 obrazenie za kazda zywa jednostke w stojacym na nich oddziale."},
	"wichura_lodowa": {"name": "Wichura Lodowa", "icon": preload("res://assets/ui/frost.png"), "description": "Zmniejsza zasieg ruchu wszystkich jednostek o 2 przez 1 ture."},
	"sniezna_zamiec": {"name": "Sniezna Zamiec", "icon": preload("res://assets/ui/frost.png"), "description": "Zmniejsza zasieg ataku wszystkich jednostek o 1 przez 1 ture."},
	"oblodzenie": {"name": "Oblodzenie", "icon": preload("res://assets/ui/frost.png"), "description": "Tworzy lod na 5-8 polach na 2 rundy. Lodowe Podloze zmniejsza Szybkosc i zasieg ruchu o 2 przez 1 ture."},
	"lawina": {"name": "Lawina", "icon": preload("res://assets/mapTiles/rock3.png"), "description": "Oznacza 4 pola. Zadaje 1 obrazenie za kazda zywa jednostke w stojacym na nich oddziale."},
	"burza_piaskowa": {"name": "Burza Piaskowa", "icon": preload("res://assets/ui/reveal.png"), "description": "Okrywa przechodnie pola piaskiem na 1 runde. Wrogie jednostki sa widoczne tylko z sasiednich pol."},
	"zapadlisko": {"name": "Zapadlisko", "icon": preload("res://assets/ui/exhaust.png"), "description": "Tworzy 3 pola ruchomych piaskow. Wejscie zuzywa caly pozostaly ruch jednostki."},
	"palacy_skwar": {"name": "Palacy Skwar", "icon": preload("res://assets/ui/fire.png"), "description": "Oznacza 3 pola. Zadaje 1 obrazenie za kazda zywa jednostke w stojacym na nich oddziale."},
	"pustynny_podmuch": {"name": "Pustynny Podmuch", "icon": preload("res://assets/ui/speed.png"), "description": "Zmniejsza zasieg ruchu wszystkich jednostek o 2 przez 1 ture."},
}

const TYPY_PRZESZKOD: Dictionary = {
	"przebudzenie_gaju": "krzok",
	"pekniecie_chodnika": "woda",
	"zawal_kopalni": "kamienie",
	"przerwanie_grobli": "woda",
	"zapadlisko": "ruchome_piaski",
}

const LICZBY_POL_OSTRZEZENIA: Dictionary = {
	"gniew_korzeni": 3,
	"przebudzenie_gaju": 3,
	"magiczny_rozkwit": 3,
	"spadajacy_rumosz": 3,
	"wybuch_gazu": 3,
	"pekniecie_chodnika": 3,
	"zawal_kopalni": 2,
	"rozprzestrzeniajacy_sie_pozar": 3,
	"przerwanie_grobli": 3,
	"plonace_zabudowania": 3,
	"oblodzenie": 3,
	"lawina": 4,
	"zapadlisko": 3,
	"palacy_skwar": 3,
}


static func pobierz_pule(scenario_id: String) -> Array:
	return (PULE.get(scenario_id, []) as Array).duplicate()


static func pobierz_nazwe(event_id: String) -> String:
	return str((DANE.get(event_id, {}) as Dictionary).get("name", ""))


static func pobierz_typ_przeszkody(event_id: String) -> String:
	return str(TYPY_PRZESZKOD.get(event_id, ""))


static func pobierz_limit_przeszkod(type_id: String) -> int:
	return int(MAKSYMALNE_PRZESZKODY.get(type_id, 0))


static func pobierz_liczbe_pol_ostrzezenia(event_id: String) -> int:
	return int(LICZBY_POL_OSTRZEZENIA.get(event_id, 0))


static func czy_runda_ostrzezenia(current_round: int, event_round: int) -> bool:
	return event_round >= 2 and current_round == event_round - 1


static func wykonaj(battle: Node) -> void:
	if battle.next_map_event_round == 0 or battle.round_number < battle.next_map_event_round:
		return
	if battle.next_map_event_id == "brak_eventu":
		battle._log_event(battle._color_log_text("Runda mija bez wydarzenia na mapie.", battle.LOG_COLOR_YELLOW), false)
		battle._schedule_next_map_event(battle.round_number)
		battle._sync_board()
		return
	match battle.next_map_event_id:
		"gniew_korzeni": battle._event_forest_roots()
		"przebudzenie_gaju": battle._event_forest_awakening()
		"lesne_opary": battle._event_global_range("Lesne Opary")
		"magiczny_rozkwit": battle._event_magic_bloom()
		"spadajacy_rumosz": battle._event_falling_rubble()
		"wybuch_gazu": battle._event_random_terrain("poison_cloud", 3, 2)
		"pekniecie_chodnika": battle._event_random_obstacles("woda", "water", 3, "Pekniecie Chodnika zalewa trzy pola.")
		"zawal_kopalni": battle._event_random_obstacles("kamienie", "rock1", 2, "Zawal Kopalni blokuje dwa pola.")
		"rozprzestrzeniajacy_sie_pozar": battle._event_spreading_fire()
		"gesty_dym": battle._event_board_concealment("mgla")
		"przerwanie_grobli": battle._event_random_obstacles("woda", "water", 3, "Przerwanie Grobli zalewa trzy pola.")
		"plonace_zabudowania": battle._event_damage_on_marked_cells("Plonace Zabudowania")
		"wichura_lodowa": battle._event_global_move_penalty("wichura_lodowa", "Wichura Lodowa")
		"sniezna_zamiec": battle._event_global_range("Sniezna Zamiec")
		"oblodzenie": battle._event_random_terrain("ice", 3, 2)
		"lawina": battle._event_damage_on_marked_cells("Lawina")
		"burza_piaskowa": battle._event_board_concealment("burza_piaskowa")
		"zapadlisko": battle._event_random_obstacles("ruchome_piaski", "quicksand", 3, "Zapadlisko tworzy trzy pola ruchomych piaskow.")
		"palacy_skwar": battle._event_damage_on_marked_cells("Palacy Skwar")
		"pustynny_podmuch": battle._event_global_move_penalty("pustynny_podmuch", "Pustynny Podmuch")
		_: return
	battle.map_event_cells.clear()
	battle._schedule_next_map_event(battle.round_number)
	battle._sync_board()
