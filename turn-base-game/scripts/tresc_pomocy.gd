class_name TrescPomocy


const STRONY_TUTORIALA: Array = [
	[
		"Witaj w prototypie turowego systemu walki!",
		"",
		"Wybierz gotowy scenariusz, własne armie w Sandbox albo dowolne oddziały w trybie Debug, gdzie sterujesz obiema stronami.",
		"Poziom trudności zmienia sposób działania przeciwnika sterowanego przez komputer.",
		"Przycisk WCZYTAJ w menu lub prawym panelu przywraca zapisaną bitwę.",
		"Celem bitwy jest zniszczenie wszystkich wrogich jednostek na heksagonalnej planszy.",
	],
	[
		"Rozstaw swoje jednostki w trzech skrajnych kolumnach po swojej stronie planszy.",
		"",
		"Wybierz jednostkę LPM i kliknij podświetlone pole albo przeciągnij ją na nowe miejsce.",
		"ZAPISZ, RESET i WCZYTAJ znajdziesz w prawym panelu nad przyciskiem START lub ZAKOŃCZ TURĘ.",
		"Kliknij START po prawej lub naciśnij Spację, aby rozpocząć bitwę.",
		"Po rozpoczęciu gry LPM wybiera jednostkę i pole ruchu, a PPM atakuje wskazanego wroga.",
	],
	[
		"Aktywna jednostka ma ograniczony Zasięg Ruchu i Punkty Akcji (PA) na swoją turę.",
		"",
		"Niebieskie pola oznaczają ruch, czerwone wrogie cele, żółte zasięg umiejętności sojuszniczej, a zielone jej poprawny cel. Przygaszony zasięg jest tylko podglądem nieaktywnej jednostki.",
		"Najedź na pole, aby zobaczyć planowaną trasę i koszt ruchu, albo przewidywane obrażenia ataku.",
		"Dolny panel zawiera do 3 umiejętności. Kliknij kartę, a potem podświetlony cel.",
		"Użycie umiejętności może kosztować PA i uruchamia cooldown liczony w turach tej jednostki.",
	],
	[
		"Teren i wydarzenia zależą od wybranego scenariusza:",
		"• Woda i ruchome piaski — wejście kończy ruch, ale nie odbiera Punktów Akcji.",
		"• Kamienie, wydmy i bariery — blokują ruch oraz linię strzału.",
		"• Krzaki, Święte Drzewa i wozy — ukrywają jednostkę; atak lub obrażenia ujawniają ją na 2 tury.",
		"• Dziury zabijają, a detonator można uruchomić PPM z sąsiedniego pola lub zastrzelić za 1 PA.",
		"",
		"Ikona w kolejce zapowiada wydarzenie mapy. Dwuklik pokazuje opis jednostki, przeszkody lub wydarzenia.",
	],
	[
		"Generał może raz na bitwę użyć jednej z dwóch globalnych umiejętności.",
		"Górna belka pokazuje kolejność aktywacji, a prawy panel generała i log bitwy.",
		"W scenariuszu Szturm na Zamek ocalali walczą przez 3 etapy i są rozstawiani przed każdym z nich.",
		"",
		"Kliknij ZAKOŃCZ TURĘ lub naciśnij Spację, gdy skończysz działać aktywną jednostką.",
		"Bitwę wygrywa strona, która jako pierwsza zniszczy wszystkie wrogie jednostki.",
		"W tej wersji testowej Tab otwiera pełną pomoc, a Esc wraca do menu wyboru trybu gry.",
	],
]

const SEKCJE_POMOCY: Array[Dictionary] = [
	{
		"title": "STEROWANIE",
		"lines": [
			"LPM — wybierz jednostkę, pole ruchu, przeszkodę lub cel umiejętności.",
			"LPM na karcie kolejki — wybierz jednostkę do podglądu; działać może tylko jednostka aktualnie aktywna.",
			"Dwuklik LPM — otwórz pełny opis jednostki, przeszkody albo wydarzenia w kolejce.",
			"PPM — wykonaj podstawowy atak albo aktywuj detonator.",
			"Kursor nad polem — pokaż trasę i koszt ruchu albo przewidywane obrażenia.",
			"Tab — pokaż lub ukryj tę pomoc.",
			"Spacja — rozpocznij bitwę albo zakończ turę aktywnej jednostki.",
			"Esc — w tej wersji testowej wróć do menu wyboru trybu gry.",
			"START — rozpocznij bitwę po rozstawieniu jednostek.",
			"ZAPISZ — zapisz aktualny stan przygotowania lub bitwy do pliku JSON.",
			"WCZYTAJ — przywróć zapisany stan z głównego menu lub prawego panelu.",
			"RESET — wróć do ekranu wyboru trybu gry.",
			"ZAKOŃCZ TURĘ — kończy turę aktywnej jednostki i przekazuje inicjatywę dalej.",
			"Umiejętności generała — dwa przyciski w prawym panelu, używalne raz na bitwę.",
		],
	},
	{
		"title": "ROZGRYWKA",
		"lines": [
			"Tryby — scenariusze oferują gotowe bitwy, Sandbox własne armie, a Debug dowolne oddziały i ręczne sterowanie obiema stronami.",
			"Przygotowanie — rozstaw jednostki w trzech skrajnych kolumnach po swojej stronie planszy.",
			"Kolejka inicjatywy — górna belka pokazuje kolejność aktywacji oraz nadchodzące wydarzenia mapy.",
			"Tura jednostki — każda jednostka ma Punkty Akcji (PA) i Zasięg Ruchu.",
			"Ruch — niebieskie pola są dostępne; przygaszone pokazują zasięg nieaktywnej jednostki, a najechanie trasę, koszt i pozostały ruch.",
			"Atak — PPM lub umiejętność; obrażenia uwzględniają DEF celu i aktywne statusy.",
			"Cele — czerwony oznacza wroga, żółty zasięg umiejętności sojuszniczej, a zielony poprawny cel sojuszniczy lub własny.",
			"Umiejętności — do 3 umiejętności aktywnych lub biernych; aktywne mogą kosztować PA i mają cooldown w turach.",
			"Statusy — buffy/debuffy widoczne w lewym panelu; niektóre jednostki mają odporności.",
			"Teren — woda i piaski kończą ruch; przeszkody blokują lub ukrywają, a dziury i detonatory są śmiertelnymi zagrożeniami.",
			"Wydarzenia mapy — zależą od scenariusza, są zapowiadane w kolejce i mogą zmieniać teren, statystyki lub zadawać obrażenia.",
			"Generał — globalne umiejętności wpływające na przebieg bitwy.",
			"Szturm na Zamek — trzy kolejne etapy; ocalali zachowują stan i są ponownie rozstawiani.",
			"Zwycięstwo — zniszcz wszystkie wrogie jednostki.",
		],
	},
	{
		"title": "PANELE INTERFEJSU",
		"lines": [
			"Lewy panel — portret, nazwa, poziom, liczebność, statystyki, odporności i statusy jednostki albo opis klikniętej przeszkody.",
			"Prawy panel — generał, jego umiejętności, log bitwy, zapis, wczytywanie, reset i przycisk zakończenia tury.",
			"Dolny panel — karty umiejętności wybranej jednostki z opisem, kosztem PA i cooldownem.",
			"Górna belka — kolejka inicjatywy z portretami jednostek i kartą następnego wydarzenia mapy.",
			"Plansza — liczba nad oddziałem pokazuje jego aktualną liczebność, a kolorowe obrysy dostępne akcje i cele.",
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
