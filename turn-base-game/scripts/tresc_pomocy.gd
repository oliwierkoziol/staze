class_name TrescPomocy


const STRONY_TUTORIALA: Array = [
	[
		"Witaj w prototypie turowego systemu walki!",
		"",
		"Wybierz gotowy scenariusz, własne armie w Sandbox albo dowolne oddziały w trybie Debug.",
		"Poziom trudności zmienia sposób działania przeciwnika sterowanego przez komputer.",
		"Celem bitwy jest zniszczenie wszystkich wrogich jednostek na heksagonalnej planszy.",
	],
	[
		"Rozstaw swoje jednostki w trzech skrajnych kolumnach po swojej stronie planszy.",
		"",
		"Wybierz jednostkę LPM i kliknij podświetlone pole albo przeciągnij ją na nowe miejsce.",
		"Kliknij START po prawej lub naciśnij Spację, aby rozpocząć bitwę.",
		"Po rozpoczęciu gry LPM wybiera jednostkę i pole ruchu, a PPM atakuje wskazanego wroga.",
	],
	[
		"Aktywna jednostka ma ograniczony Zasięg Ruchu i Punkty Akcji (PA) na swoją turę.",
		"Poziom widzisz pod nazwą; obecnie każda jednostka zaczyna na poziomie 1.",
		"",
		"Dolny panel zawiera do 3 umiejętności. Kliknij kartę, a potem podświetlony cel.",
		"Użycie umiejętności może kosztować PA i uruchamia cooldown liczony w turach tej jednostki.",
		"Górna belka pokazuje kolejność aktywacji, a prawy panel generała i log bitwy.",
	],
	[
		"Teren ma znaczenie:",
		"• Woda i ruchome piaski — wejście kończy ruch, ale nie odbiera Punktów Akcji.",
		"• Kamienie — blokują ruch i linię strzału.",
		"• Krzaki — ukrywają jednostkę; atak lub otrzymanie obrażeń ujawnia ją na 2 tury.",
		"",
		"Kliknij przeszkodę, aby przeczytać jej opis w lewym panelu.",
	],
	[
		"Generał może raz na bitwę użyć jednej z dwóch globalnych umiejętności.",
		"",
		"Kliknij ZAKOŃCZ TURĘ lub naciśnij Spację, gdy skończysz działać aktywną jednostką.",
		"Bitwę wygrywa strona, która jako pierwsza zniszczy wszystkie wrogie jednostki.",
		"",
		"Tab otwiera pełną pomoc, a Esc wraca do wyboru trybu gry.",
	],
]

const SEKCJE_POMOCY: Array[Dictionary] = [
	{
		"title": "STEROWANIE",
		"lines": [
			"LPM — wybierz jednostkę, pole ruchu, przeszkodę lub cel umiejętności.",
			"PPM — wykonaj podstawowy atak aktywną jednostką.",
			"Tab — pokaż lub ukryj tę pomoc.",
			"Spacja — rozpocznij bitwę albo zakończ turę aktywnej jednostki.",
			"Esc — wróć do ekranu wyboru trybu gry.",
			"START — rozpocznij bitwę po rozstawieniu jednostek.",
			"RESET — wróć do ekranu wyboru trybu gry.",
			"ZAKOŃCZ TURĘ — kończy turę aktywnej jednostki i przekazuje inicjatywę dalej.",
			"Umiejętności generała — dwa przyciski w prawym panelu, używalne raz na bitwę.",
		],
	},
	{
		"title": "ROZGRYWKA",
		"lines": [
			"Przygotowanie — wybierz tryb i armie, a potem rozstaw jednostki w trzech skrajnych kolumnach.",
			"Kolejka inicjatywy — górna belka pokazuje kolejność aktywacji w rundzie.",
			"Tura jednostki — każda jednostka ma Punkty Akcji (PA) i Zasięg Ruchu.",
			"Ruch — kliknij podświetlone pole; koszt zależy od terenu.",
			"Atak — PPM lub umiejętność; obrażenia uwzględniają DEF celu i aktywne statusy.",
			"Umiejętności — do 3 aktywnych umiejętności z cooldownem w turach.",
			"Statusy — buffy/debuffy widoczne w lewym panelu; niektóre jednostki mają odporności.",
			"Teren — woda i ruchome piaski kończą ruch, kamienie blokują drogę i strzał, a krzaki ukrywają jednostkę.",
			"Generał — globalne umiejętności wpływające na przebieg bitwy.",
			"Zwycięstwo — zniszcz wszystkie wrogie jednostki.",
		],
	},
	{
		"title": "PANELE INTERFEJSU",
		"lines": [
			"Lewy panel — portret, nazwa, poziom, statystyki oraz aktywne buffy i debuffy wybranej jednostki.",
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
