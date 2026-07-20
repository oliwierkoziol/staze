class_name TrescPomocy


const STRONY_TUTORIALA: Array = [
	[
		"Witaj w prototypie turowego systemu walki!",
		"",
		"Twoim celem jest pokonanie wszystkich wrogich jednostek na heksagonalnej planszy.",
		"Przed bitwą wybierasz frakcję i rozstawiasz swoje jednostki.",
		"Po kliknięciu START rozpoczyna się walka oparta na inicjatywie.",
	],
	[
		"Rozstaw swoje jednostki w trzech skrajnych kolumnach po swojej stronie planszy.",
		"",
		"Wybierz jednostkę LPM, a następnie kliknij podświetlone pole, aby się przemieścić.",
		"PPM wykonuje podstawowy atak w zasięgu aktywnej jednostki.",
		"Każda jednostka ma ograniczone Punkty Akcji (PA) i Zasięg Ruchu na turę.",
	],
	[
		"Karta aktywnej jednostki wyświetla się w lewym panelu — znajdziesz tam statystyki, buffy i debuffy.",
		"",
		"Dolny panel pokazuje umiejętności specjalne jednostki.",
		"Prawy panel to generał, jego umiejętności oraz log bitwy.",
		"Górna belka to kolejka inicjatywy — kolejność aktywacji jednostek.",
	],
	[
		"Teren ma znaczenie:",
		"• Woda — wejście zużywa cały pozostały ruch i pomija turę.",
		"• Kamienie — blokują ruch i linię strzału.",
		"• Krzaki — jednostka w krzaku jest niewidzialna dla wrogów poza sąsiednim krzakiem.",
		"",
		"Statusy i odporności jednostek wpływają na obrażenia oraz zachowanie w walce.",
	],
	[
		"Generał może raz na bitwę użyć jednej z dwóch globalnych umiejętności.",
		"",
		"Kliknij ZAKOŃCZ TURĘ, gdy skończysz działać aktywną jednostką.",
		"Bitwę wygrywa strona, która jako pierwsza zniszczy wszystkie wrogie jednostki.",
		"",
		"Naciśnij Tab w dowolnym momencie, aby otworzyć pełną pomoc.",
	],
]

const SEKCJE_POMOCY: Array[Dictionary] = [
	{
		"title": "STEROWANIE",
		"lines": [
			"LPM — wybierz jednostkę, wskaż pole ruchu lub cel umiejętności.",
			"PPM — wykonaj podstawowy atak aktywną jednostką.",
			"Tab — pokaż lub ukryj tę pomoc.",
			"START — rozpocznij bitwę po rozstawieniu jednostek.",
			"RESET — wróć do ekranu wyboru frakcji.",
			"ZAKOŃCZ TURĘ — kończy turę aktywnej jednostki i przekazuje inicjatywę dalej.",
			"Umiejętności generała — dwa przyciski w prawym panelu, używalne raz na bitwę.",
		],
	},
	{
		"title": "ROZGRYWKA",
		"lines": [
			"Przygotowanie — wybierz frakcję gracza i przeciwnika, rozstaw jednostki w trzech skrajnych kolumnach.",
			"Kolejka inicjatywy — górna belka pokazuje kolejność aktywacji w rundzie.",
			"Tura jednostki — każda jednostka ma Punkty Akcji (PA) i Zasięg Ruchu.",
			"Ruch — kliknij podświetlone pole; koszt zależy od terenu.",
			"Atak — PPM lub umiejętność; obrażenia uwzględniają DEF celu i aktywne statusy.",
			"Umiejętności — do 3 aktywnych umiejętności z cooldownem w turach.",
			"Statusy — buffy/debuffy widoczne w lewym panelu; niektóre jednostki mają odporności.",
			"Teren — woda pomija turę, kamienie blokują ruch i linię strzału, krzaki ukrywają jednostkę.",
			"Generał — globalne umiejętności wpływające na przebieg bitwy.",
			"Zwycięstwo — zniszcz wszystkie wrogie jednostki.",
		],
	},
	{
		"title": "PANELE INTERFEJSU",
		"lines": [
			"Lewy panel — portret, nazwa, statystyki oraz aktywne buffy i debuffy wybranej jednostki.",
			"Prawy panel — generał, jego umiejętności, log bitwy i przycisk zakończenia tury.",
			"Dolny panel — karty umiejętności aktualnie aktywnej jednostki.",
			"Górna belka — kolejka inicjatywy z portretami jednostek.",
		],
	},
]


static func odbuduj(battle: Node) -> void:
	if battle.help_popup_content == null:
		return
	for child in battle.help_popup_content.get_children():
		child.queue_free()
	if battle.help_mode_tutorial:
		_zbuduj_tutorial(battle)
	else:
		_zbuduj_pomoc(battle)


static func _zbuduj_tutorial(battle: Node) -> void:
	var page_index := clampi(battle.tutorial_page, 0, STRONY_TUTORIALA.size() - 1)
	var page_lines: Array[String] = []
	page_lines.assign(STRONY_TUTORIALA[page_index])
	for line in page_lines:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = line
		label.add_theme_font_size_override("font_size", 15)
		battle.help_popup_content.add_child(label)
	battle.help_popup_page_label.text = "STRONA %d / %d" % [page_index + 1, STRONY_TUTORIALA.size()]
	battle.help_popup_prev_button.disabled = page_index == 0
	battle.help_popup_next_button.disabled = page_index == STRONY_TUTORIALA.size() - 1
	battle.help_popup_action_button.text = "ROZPOCZNIJ" if page_index == STRONY_TUTORIALA.size() - 1 else "POMIŃ"


static func _zbuduj_pomoc(battle: Node) -> void:
	for section in SEKCJE_POMOCY:
		var lines: Array[String] = []
		lines.assign(section.get("lines", []))
		battle.help_popup_content.add_child(battle._make_help_section(str(section.get("title", "")), lines))
	battle.help_popup_page_label.text = "POMOC"
	battle.help_popup_prev_button.disabled = true
	battle.help_popup_next_button.disabled = true
	battle.help_popup_action_button.text = "ZAMKNIJ"
