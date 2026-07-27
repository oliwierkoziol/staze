extends Control
# hud.gd (Podpięty pod węzeł CanvasLayer/UI)

@onready var resources_label = $Panel/ResourcesLabel
@onready var turn_button = $TurnButton
@onready var menu_budowania = $MenuBudowania

@onready var build_chata = $MenuBudowania/VBoxContainer/BuildChata
@onready var build_iron = $MenuBudowania/VBoxContainer/BuildKopalniaZelaza
@onready var build_coal = $MenuBudowania/VBoxContainer/BuildKopalniaWegla

var build_farma: Button
var build_pastwisko: Button
var build_dom: Button 
var build_spichlerz: Button
var info_label: RichTextLabel
var menu_zalozenia_miasta: PopupPanel
var zaloz_miasto_button: Button
var kup_pole_button: Button
var upgrade_button: Button
var destroy_button: Button
var tile_info_menu: PanelContainer
var skip_button: Button
var turn_actions_row: HBoxContainer

const TURN_ACTIONS_MARGIN_RIGHT := 48.0
const TURN_ACTIONS_MARGIN_BOTTOM := 56.0
const TURN_ACTIONS_GAP := 12.0
const TURN_BUTTON_HEIGHT := 48.0
const RIGHT_PANEL_OFFSET_LEFT := -340.0
const RIGHT_PANEL_OFFSET_RIGHT := -20.0
const RIGHT_PANEL_WIDTH := RIGHT_PANEL_OFFSET_RIGHT - RIGHT_PANEL_OFFSET_LEFT

var cat_zasobowe: Button
var cat_tech: Button
var cat_naukowe: Button
var cat_wojskowe: Button

var btn_tech_1: Button
var btn_tech_2: Button
var btn_naukowy_1: Button
var btn_naukowy_2: Button
var build_baraki: Button

var tech_tree_menu: TechTreeMenu
var culture_tree_menu: CultureTreeMenu

var culture_tree_button: Button

var world_ref: Node2D
var active_tile_pos: Vector2 = Vector2.ZERO
var active_tile_type: String = ""
var last_mouse_pos: Vector2 = Vector2.ZERO
var confirm_dialog: ConfirmationDialog
var destroy_confirm_dialog: ConfirmationDialog
var wood_warning_dialog: ConfirmationDialog
var tech_warning_dialog: AcceptDialog
var turn_warning_dialog: AcceptDialog
var research_unlocked_dialog: AcceptDialog
var _last_unlocked_tree_type: String = ""
var pending_building: String = ""
var _tree_pan_active := false

var active_building_name: String = ""
var active_building_level: int = 0

var barracks_menu: BarracksMenu
var army_menu: ArmyMenu
var camp_menu: CampMenu
var unit_data_json: Dictionary = {}
var recruit_button: Button
var army_button: Button
var camp_details_btn: Button
var battle_button: Button

var potions_menu: PotionsMenu
var btn_my_potions: Button
var btn_buy_potions: Button

var resources_container: HBoxContainer
var resource_labels: Dictionary = {}

var points_panel: PanelContainer
var culture_label: Label
var culture_bar: ProgressBar
var culture_research_ready_label: Label
var tech_label: Label
var tech_bar: ProgressBar
var tech_research_ready_label: Label

var hunger_label: Label
var quick_actions_panel: PanelContainer
var movement_label: Label
var quick_army_button: Button
var quick_potions_button: Button
var quick_help_button: Button
var quick_settings_button: Button
var center_general_button: Button
var skip_confirm_dialog: ConfirmationDialog
var battle_confirm_dialog: ConfirmationDialog

var help_menu: HelpMenu

var settings_menu: SettingsMenu
var _menu_backdrop: ColorRect

var temple_menu: TempleMenu
var workshop_menu: WorkshopMenu
var library_research_menu: LibraryResearchMenu
var temple_button: Button
var workshop_button: Button
var library_research_button: Button

var tutorial_menu: TutorialMenu

var admin_menu: AdminMenu
var admin_button: Button

# Krótkie opóźnienie po naciśnięciu „Następnej tury”, żeby zapobiec
# przypadkowemu spamowaniu przycisku (np. dwoma szybkimi kliknięciami).
# Osobna flaga, bo turn_button.disabled jest też co klatkę nadpisywane w
# _process() na podstawie any_menu_visible() — bez tej flagi to opóźnienie
# zostałoby natychmiast skasowane w kolejnej klatce.
const TURN_BUTTON_DELAY: float = 0.6
var _turn_button_cooldown: bool = false

# --- PALETA "DARK FANTASY" -------------------------------------------------
# Wspólne kolory używane w całym HUD-zie, żeby całość wyglądała spójnie:
# głębokie, prawie czarne tła z chłodnym odcieniem, postarzałe złoto jako
# główny akcent oraz krwista czerwień dla akcji bojowych/niebezpiecznych.
const DF_BG: Color = Color(0.06, 0.05, 0.025, 0.97)
const DF_BG_LIGHT: Color = Color(0.105, 0.065, 0.025, 0.96)
const DF_GOLD: Color = Color(0.65, 0.52, 0.2, 0.9)
const DF_GOLD_BRIGHT: Color = Color(0.88, 0.75, 0.34, 1.0)
const DF_GOLD_TEXT: Color = Color(0.86, 0.72, 0.34, 1.0)
const DF_BLOOD: Color = Color(0.45, 0.08, 0.09, 1.0)
const DF_BLOOD_BRIGHT: Color = Color(0.62, 0.13, 0.14, 1.0)
const DF_TEXT: Color = Color(0.92, 0.88, 0.78, 1.0)
const DF_TEXT_DIM: Color = Color(0.75, 0.68, 0.5, 0.85)
const MENU_BACKDROP_COLOR: Color = Color(0.02, 0.02, 0.04, 0.78)
const PANEL_TEXTURE: Texture2D = preload("res://turn-base-game/assets/ui/panel.png")

func _ready():
	apply_emoji_fallback()
	
	world_ref = get_tree().current_scene
	if world_ref == null or not world_ref.has_method("build_on_tile"):
		world_ref = get_tree().root.find_child("GameWorld", true, false)
		
	EconomyManager.economy_updated.connect(_on_economy_updated)
	EconomyManager.research_completed.connect(_on_tech_research_completed)
	EconomyManager.culture_research_completed.connect(_on_culture_research_completed)
	
	turn_button.pressed.connect(_on_turn_pressed)

	turn_actions_row = HBoxContainer.new()
	turn_actions_row.name = "TurnActions"
	turn_actions_row.add_theme_constant_override("separation", int(TURN_ACTIONS_GAP))
	var parent = turn_button.get_parent()
	parent.add_child(turn_actions_row)
	turn_button.reparent(turn_actions_row)

	skip_button = Button.new()
	skip_button.text = "POMIŃ 5 TUR"
	skip_button.pressed.connect(_show_skip_confirmation)
	turn_actions_row.add_child(skip_button)
	_layout_turn_actions()
	
	build_chata.pressed.connect(func(): execute_build("Chata Drwala"))
	build_iron.pressed.connect(func(): execute_build("Kopalnia Żelaza"))
	build_coal.pressed.connect(func(): execute_build("Kopalnia Węgla"))
	
	setup_points_panel()
	setup_resources_header()
	setup_hunger_label()
	setup_quick_actions()
	setup_custom_popups()
	setup_skip_confirmation()
	tech_tree_menu = TechTreeMenu.new(self)
	tech_tree_menu.setup_tech_tree_ui()
	culture_tree_menu = CultureTreeMenu.new(self)
	culture_tree_menu.setup_culture_tree_ui()
	load_unit_data()
	barracks_menu = BarracksMenu.new(self)
	barracks_menu.setup_barracks_window()
	army_menu = ArmyMenu.new(self)
	potions_menu = PotionsMenu.new(self)
	potions_menu.setup_potions_windows()
	army_menu.setup_army_window()
	camp_menu = CampMenu.new(self)
	camp_menu.setup_camp_windows()
	temple_menu = TempleMenu.new(self)
	temple_menu.setup_temple_window()
	workshop_menu = WorkshopMenu.new(self)
	workshop_menu.setup_workshop_window()
	library_research_menu = LibraryResearchMenu.new(self)
	library_research_menu.setup_library_window()
	setup_battle_button()
	help_menu = HelpMenu.new(self)
	help_menu.setup_help_window()
	settings_menu = SettingsMenu.new(self)
	settings_menu.setup_settings_window()
	style_main_hud_elements()
	style_context_popup()
	style_individual_buttons()

	tutorial_menu = TutorialMenu.new(self)
	tutorial_menu.setup_tutorial_window()
	if not SaveManager.has_save(GameSettings.current_seed):
		tutorial_menu.show_tutorial_menu()

	admin_menu = AdminMenu.new(self)
	admin_menu.setup_admin_window()
	setup_admin_button()
	_setup_menu_backdrop()
	_apply_modal_z_indices()

	call_deferred("_align_right_column")
	EconomyManager.notify_change()

func apply_emoji_fallback() -> void:
	var ui_font := GameSettings.get_ui_font()
	if ui_font == null:
		return
	if not self.theme:
		self.theme = Theme.new()
	self.theme.default_font = ui_font


func setup_admin_button():
	# POPRAWKA: Panel administratora zależał wcześniej od "hacka" (seed == 0
	# jako custom seed). Teraz zależy jawnie od GameSettings.debug_mode,
	# ustawianego checkboxem "Tryb Debug" w menu głównym — seed 0 jest więc
	# normalnym, poprawnym seedem świata.
	if OS.is_debug_build() and GameSettings.debug_mode:
		admin_button = Button.new()
		admin_button.text = "🛠️ Admin"
		admin_button.custom_minimum_size = Vector2(100, 40)
		_style_df_button(admin_button)
		admin_button.pressed.connect(func():
			hide_all_menus()
			admin_menu.show_admin_menu()
		)
		admin_button.anchor_left = 0.0
		admin_button.anchor_top = 0.0
		admin_button.offset_left = 20
		admin_button.offset_top = 178
		add_child(admin_button)

func _process(_delta: float) -> void:
	_update_battle_button()
	_update_movement_label()
	
	var menu_open = any_menu_visible()
	if tech_tree_menu and tech_tree_menu.tech_tree_button:
		tech_tree_menu.tech_tree_button.disabled = menu_open
	if culture_tree_button:
		culture_tree_button.disabled = menu_open
	if turn_button:
		turn_button.disabled = menu_open or _turn_button_cooldown
		turn_button.modulate.a = 0.5 if turn_button.disabled else 1.0
	if skip_button:
		skip_button.disabled = menu_open or _turn_button_cooldown
		skip_button.modulate.a = 0.5 if skip_button.disabled else 1.0
	_update_menu_backdrop()
	for button: Button in [quick_army_button, quick_potions_button, quick_help_button, quick_settings_button]:
		if button != null:
			button.disabled = menu_open
	# POPRAWKA: Przyciski kategorii (Surowce/Kultura/Technologia/Wojskowe) są
	# dziećmi menu_budowania, więc nie wolno ich blokować na podstawie
	# any_menu_visible() — menu_budowania samo w sobie powoduje, że ta
	# funkcja zwraca true, co blokowało zakładki w momencie, gdy menu
	# budowania było otwarte (czyli dokładnie wtedy, gdy miały być klikalne).
	# Skoro te przyciski są widoczne wyłącznie wtedy, gdy widoczny jest ich
	# panel nadrzędny (a on chowa się razem z resztą menu w hide_all_menus),
	# dodatkowe blokowanie tutaj jest zbędne i błędne.

func _update_battle_button() -> void:
	if not battle_button: return

	if world_ref and world_ref.has_method("is_battle_running") and world_ref.is_battle_running():
		battle_button.visible = false
		return

	if not world_ref or not world_ref.get("character"):
		battle_button.visible = false
		return

	var gen = world_ref.character
	if not gen or not gen.has_method("has_army") or not gen.has_army():
		battle_button.visible = false
		return

	# Podczas ruchu generała (niepusta ścieżka) lub gdy otwarte jest inne menu, nie pokazujemy przycisku
	if not gen.path.is_empty() or any_menu_visible():
		battle_button.visible = false
		return

	if not world_ref.get("camps"):
		battle_button.visible = false
		return

	var tile_pos = world_ref.world_to_nearest_cell(gen.global_position)
	if not world_ref.camps.has(tile_pos):
		battle_button.visible = false
		return

	var cell_world_pos = world_ref.cell_to_world.get(tile_pos, null)
	if cell_world_pos == null or gen.global_position.distance_to(cell_world_pos) > 40.0:
		battle_button.visible = false
		return

	var screen_pos: Vector2 = get_viewport().canvas_transform * (gen.global_position + Vector2(0, -75))
	var visible_rect = get_viewport().get_visible_rect()
	
	if not visible_rect.has_point(screen_pos):
		battle_button.visible = false
		return
		
	battle_button.visible = true
	var camp_data: Dictionary = world_ref.camps.get(tile_pos, {})
	if camp_data.get("is_castle", false) or camp_data.get("is_boss", false):
		battle_button.text = "🏰 Szturm na Zamek"
	else:
		battle_button.text = "⚔️ Rozpocznij walkę"
	battle_button.position = screen_pos - battle_button.size / 2.0

func setup_battle_button() -> void:
	battle_button = Button.new()
	battle_button.text = "⚔️ Rozpocznij walkę"
	battle_button.custom_minimum_size = Vector2(190, 46)
	battle_button.visible = false
	battle_button.z_index = 10
	battle_button.tooltip_text = "Uruchom moduł walki"
	_style_df_button(battle_button)

	battle_button.pressed.connect(_on_battle_button_pressed)
	add_child(battle_button)

	battle_confirm_dialog = ConfirmationDialog.new()
	battle_confirm_dialog.title = "Rozpoczęcie walki"
	battle_confirm_dialog.ok_button_text = "ROZPOCZNIJ WALKĘ"
	battle_confirm_dialog.cancel_button_text = "ANULUJ"
	battle_confirm_dialog.confirmed.connect(_start_battle_now)
	_style_alert_dialog(battle_confirm_dialog)
	add_child(battle_confirm_dialog)

func _on_battle_button_pressed() -> void:
	if world_ref == null or not world_ref.get("character") or not world_ref.get("camps"):
		return
	var tile_pos = world_ref.world_to_nearest_cell(world_ref.character.global_position)
	var camp_data: Dictionary = world_ref.camps.get(tile_pos, {})
	var player_count := int(world_ref.character.get_army_size())
	var enemy_count := int(camp_data.get("army", []).size())
	var is_castle: bool = bool(camp_data.get("is_castle", false)) or bool(camp_data.get("is_boss", false))
	if is_castle:
		var stage1 := 0
		if world_ref.has_method("get_castle_stage_enemy_count"):
			stage1 = world_ref.get_castle_stage_enemy_count(0)
		battle_confirm_dialog.dialog_text = (
			"🏰 Szturm na Zamek (3 etapy)\n"
			+ "Twoje gotowe jednostki: %d\n"
			+ "Obrońcy etapu 1: %d\n"
			+ "Łącznie ~%d wrogów w trzech falach\n\n"
			+ "Możesz zaatakować w każdej chwili, ale pełna armia (~%d) daje realną szansę.\n\n"
			+ "Rozpocząć szturm?"
		) % [
			player_count,
			stage1,
			stage1 + (world_ref.get_castle_stage_enemy_count(1) if world_ref.has_method("get_castle_stage_enemy_count") else 0) + (world_ref.get_castle_stage_enemy_count(2) if world_ref.has_method("get_castle_stage_enemy_count") else 0),
			EconomyManager.MAX_ARMY_SIZE,
		]
	else:
		battle_confirm_dialog.dialog_text = (
			"Obozowisko: %s (poziom %d)\n"
			+ "Twoje gotowe jednostki: %d\n"
			+ "Jednostki przeciwnika: %d\n\n"
			+ "Rozpocząć walkę?"
		) % [
			camp_data.get("faction_name", "Nieznana frakcja"),
			int(camp_data.get("level", 1)),
			player_count,
			enemy_count,
		]
	battle_confirm_dialog.popup_centered(Vector2i(540, 270))


func _start_battle_now() -> void:
	if not world_ref or not world_ref.has_method("start_battle"):
		return
	var tile_pos = world_ref.world_to_nearest_cell(world_ref.character.global_position)
	if world_ref.start_battle(tile_pos):
		return
	if AudioManager:
		AudioManager.play_error()
	tech_warning_dialog.title = "Nie można rozpocząć walki"
	tech_warning_dialog.dialog_text = str(world_ref.get("battle_error_message"))
	tech_warning_dialog.popup_centered()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if (
			(tech_tree_menu and tech_tree_menu.tech_tree_window and tech_tree_menu.tech_tree_window.visible)
			or (culture_tree_menu and culture_tree_menu.culture_tree_window and culture_tree_menu.culture_tree_window.visible)
		):
			get_viewport().set_input_as_handled()
			return
		if _menu_backdrop_active():
			return
		if any_menu_visible():
			hide_all_menus()
			get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		get_viewport().set_input_as_handled()
		if help_menu and help_menu.help_window and help_menu.help_window.visible:
			help_menu.help_window.visible = false
		else:
			hide_all_menus()
			help_menu.show_help_menu()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		var menu_was_visible := any_menu_visible()
		hide_all_menus()
		if not menu_was_visible:
			settings_menu.show_settings_menu()
			if AudioManager: AudioManager.pause_bg_music()

func _panel_style(content_margin := 0.0, top_margin := -1.0) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = PANEL_TEXTURE
	style.texture_margin_left = 8
	style.texture_margin_top = 8
	style.texture_margin_right = 8
	style.texture_margin_bottom = 8
	style.axis_stretch_horizontal = 2
	style.axis_stretch_vertical = 2
	style.set_content_margin_all(content_margin)
	if top_margin >= 0:
		style.content_margin_top = top_margin
	return style


func _setup_menu_backdrop() -> void:
	_menu_backdrop = ColorRect.new()
	_menu_backdrop.name = "MenuBackdrop"
	_menu_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_menu_backdrop.color = MENU_BACKDROP_COLOR
	_menu_backdrop.visible = false
	_menu_backdrop.z_index = 9
	_menu_backdrop.gui_input.connect(_on_menu_backdrop_gui_input)
	add_child(_menu_backdrop)
	move_child(_menu_backdrop, 0)


func _add_visible_modal(modals: Array[Control], menu_ref, prop: StringName) -> void:
	if menu_ref == null:
		return
	var window: Control = menu_ref.get(prop)
	if window and window.visible:
		modals.append(window)


func _raise_active_modals() -> void:
	if _menu_backdrop:
		move_child(_menu_backdrop, 0)
	var modals: Array[Control] = []
	_add_visible_modal(modals, tech_tree_menu, &"tech_tree_window")
	_add_visible_modal(modals, culture_tree_menu, &"culture_tree_window")
	_add_visible_modal(modals, barracks_menu, &"barracks_window")
	_add_visible_modal(modals, army_menu, &"army_window")
	_add_visible_modal(modals, help_menu, &"help_window")
	_add_visible_modal(modals, settings_menu, &"settings_window")
	_add_visible_modal(modals, tutorial_menu, &"tutorial_window")
	_add_visible_modal(modals, admin_menu, &"admin_window")
	if potions_menu:
		_add_visible_modal(modals, potions_menu, &"my_potions_window")
		_add_visible_modal(modals, potions_menu, &"buy_potions_window")
	_add_visible_modal(modals, temple_menu, &"temple_window")
	_add_visible_modal(modals, workshop_menu, &"workshop_window")
	_add_visible_modal(modals, library_research_menu, &"library_window")
	if camp_menu:
		_add_visible_modal(modals, camp_menu, &"camp_details_window")
		_add_visible_modal(modals, camp_menu, &"camp_army_window")
	for modal in modals:
		modal.move_to_front()


func _menu_backdrop_active() -> bool:
	return (
		(tech_tree_menu and tech_tree_menu.tech_tree_window and tech_tree_menu.tech_tree_window.visible)
		or (culture_tree_menu and culture_tree_menu.culture_tree_window and culture_tree_menu.culture_tree_window.visible)
		or (barracks_menu and barracks_menu.barracks_window and barracks_menu.barracks_window.visible)
		or (army_menu and army_menu.army_window and army_menu.army_window.visible)
		or (camp_menu and camp_menu.camp_details_window and camp_menu.camp_details_window.visible)
		or (camp_menu and camp_menu.camp_army_window and camp_menu.camp_army_window.visible)
		or (help_menu and help_menu.help_window and help_menu.help_window.visible)
		or (settings_menu and settings_menu.settings_window and settings_menu.settings_window.visible)
		or (tutorial_menu and tutorial_menu.tutorial_window and tutorial_menu.tutorial_window.visible)
		or (admin_menu and admin_menu.admin_window and admin_menu.admin_window.visible)
		or (potions_menu and potions_menu.my_potions_window and potions_menu.my_potions_window.visible)
		or (potions_menu and potions_menu.buy_potions_window and potions_menu.buy_potions_window.visible)
		or (temple_menu and temple_menu.temple_window and temple_menu.temple_window.visible)
		or (workshop_menu and workshop_menu.workshop_window and workshop_menu.workshop_window.visible)
		or (library_research_menu and library_research_menu.library_window and library_research_menu.library_window.visible)
	)


func _apply_modal_z_indices() -> void:
	const MODAL_Z := 10
	if barracks_menu and barracks_menu.barracks_window:
		barracks_menu.barracks_window.z_index = MODAL_Z
	if army_menu and army_menu.army_window:
		army_menu.army_window.z_index = MODAL_Z
	if potions_menu:
		if potions_menu.my_potions_window:
			potions_menu.my_potions_window.z_index = MODAL_Z
		if potions_menu.buy_potions_window:
			potions_menu.buy_potions_window.z_index = MODAL_Z
	if help_menu and help_menu.help_window:
		help_menu.help_window.z_index = MODAL_Z
	if workshop_menu and workshop_menu.workshop_window:
		workshop_menu.workshop_window.z_index = MODAL_Z
	if temple_menu and temple_menu.temple_window:
		temple_menu.temple_window.z_index = MODAL_Z
	if library_research_menu and library_research_menu.library_window:
		library_research_menu.library_window.z_index = MODAL_Z
	if camp_menu:
		if camp_menu.camp_details_window:
			camp_menu.camp_details_window.z_index = MODAL_Z
		if camp_menu.camp_army_window:
			camp_menu.camp_army_window.z_index = MODAL_Z
	if admin_menu and admin_menu.admin_window:
		admin_menu.admin_window.z_index = MODAL_Z


func _update_menu_backdrop() -> void:
	if _menu_backdrop == null:
		return
	var active := _menu_backdrop_active()
	_menu_backdrop.visible = active
	if active:
		_raise_active_modals()


func _on_menu_backdrop_gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if (
		(tech_tree_menu and tech_tree_menu.tech_tree_window and tech_tree_menu.tech_tree_window.visible)
		or (culture_tree_menu and culture_tree_menu.culture_tree_window and culture_tree_menu.culture_tree_window.visible)
	):
		return
	hide_all_menus()


func _resource_icon_texture(resource_name: String) -> Texture2D:
	match resource_name:
		"Drewno", "🪵": return preload("res://assets/resources/wood.png")
		"Żelazo", "⛏", "⛏️", "⛓️": return preload("res://assets/resources/iron.png")
		"Węgiel", "🌋": return preload("res://assets/resources/coal.png")
		"Jedzenie", "🌾": return preload("res://assets/resources/food.png")
		"Złoto", "💰", "🪙": return preload("res://assets/resources/gold.png")
		"Populacja", "👥": return preload("res://assets/resources/population.png")
		"Nauka", "Technologia", "🔬": return preload("res://assets/resources/technology.png")
		"Kultura": return preload("res://assets/resources/cultural.png")
	return null


func _resource_icon_bbcode(resource_name: String, size: int = 18) -> String:
	var texture := _resource_icon_texture(resource_name)
	return "[img=%dx%d]%s[/img]" % [size, size, texture.resource_path] if texture else ""


func bind_tree_panning(scroll: ScrollContainer, canvas: Control) -> void:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	for input_area: Control in [scroll, canvas]:
		input_area.mouse_default_cursor_shape = Control.CURSOR_DRAG
		var callback := _on_tree_pan_input.bind(input_area, scroll)
		if not input_area.gui_input.is_connected(callback):
			input_area.gui_input.connect(callback)


func _on_tree_pan_input(event: InputEvent, input_area: Control, scroll: ScrollContainer) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_tree_pan_active = event.pressed
			input_area.accept_event()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if event.shift_pressed:
				scroll.scroll_horizontal -= 60
			else:
				scroll.scroll_vertical -= 60
			input_area.accept_event()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if event.shift_pressed:
				scroll.scroll_horizontal += 60
			else:
				scroll.scroll_vertical += 60
			input_area.accept_event()
	elif event is InputEventMouseMotion and _tree_pan_active:
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_tree_pan_active = false
			return
		_apply_tree_pan(scroll, event.relative)
		input_area.accept_event()


func _apply_tree_pan(scroll: ScrollContainer, relative: Vector2) -> void:
	scroll.scroll_horizontal -= roundi(relative.x)
	scroll.scroll_vertical -= roundi(relative.y)


func setup_points_panel():
	points_panel = PanelContainer.new()
	points_panel.anchor_left = 1.0
	points_panel.anchor_right = 1.0
	points_panel.anchor_top = 0.0
	points_panel.anchor_bottom = 0.0
	points_panel.offset_left = RIGHT_PANEL_OFFSET_LEFT
	points_panel.offset_right = RIGHT_PANEL_OFFSET_RIGHT
	points_panel.offset_top = 72

	points_panel.add_theme_stylebox_override("panel", _panel_style(12))
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	points_panel.add_child(vbox)

	var title := Label.new()
	title.text = "ROZWÓJ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", DF_GOLD_TEXT)
	vbox.add_child(title)
	
	var culture_vbox = VBoxContainer.new()
	culture_vbox.add_theme_constant_override("separation", 5)
	
	var culture_hbox = HBoxContainer.new()
	culture_hbox.add_theme_constant_override("separation", 10)
	
	var c_icon = TextureRect.new()
	c_icon.texture = preload("res://assets/resources/cultural.png")
	c_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	c_icon.custom_minimum_size = Vector2(36, 36)
	c_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	c_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	var c_info_vbox = VBoxContainer.new()
	c_info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c_info_vbox.add_theme_constant_override("separation", 2)
	c_info_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	culture_label = Label.new()
	culture_label.text = "Punkty Kultury: 0/100"
	culture_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	culture_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	culture_label.mouse_filter = Control.MOUSE_FILTER_STOP
	culture_label.add_theme_font_size_override("font_size", 14)
	
	culture_bar = ProgressBar.new()
	culture_bar.custom_minimum_size = Vector2(0, 8)
	culture_bar.show_percentage = false
	var c_bg = StyleBoxFlat.new()
	c_bg.bg_color = Color(0.2, 0.15, 0.25)
	var c_fg = StyleBoxFlat.new()
	c_fg.bg_color = Color(0.65, 0.35, 0.75)  
	culture_bar.add_theme_stylebox_override("background", c_bg)
	culture_bar.add_theme_stylebox_override("fill", c_fg)
	
	c_info_vbox.add_child(culture_label)
	c_info_vbox.add_child(culture_bar)
	
	culture_hbox.add_child(c_icon)
	culture_hbox.add_child(c_info_vbox)
	culture_vbox.add_child(culture_hbox)
	
	culture_tree_button = Button.new()
	culture_tree_button.text = "Drzewo Kultury"
	culture_tree_button.custom_minimum_size = Vector2(0, 40)
	_style_df_button(culture_tree_button)
	culture_vbox.add_child(culture_tree_button)
	
	culture_research_ready_label = Label.new()
	culture_research_ready_label.text = "💡 Badanie dostępne!"
	culture_research_ready_label.add_theme_font_size_override("font_size", 12)
	culture_research_ready_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
	culture_research_ready_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	culture_research_ready_label.visible = false
	culture_vbox.add_child(culture_research_ready_label)

	vbox.add_child(culture_vbox)
	
	var tech_vbox = VBoxContainer.new()
	tech_vbox.add_theme_constant_override("separation", 5)
	
	var tech_hbox = HBoxContainer.new()
	tech_hbox.add_theme_constant_override("separation", 10)
	
	var t_icon = TextureRect.new()
	t_icon.texture = preload("res://assets/resources/technology.png")
	t_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t_icon.custom_minimum_size = Vector2(36, 36)
	t_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	var t_info_vbox = VBoxContainer.new()
	t_info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t_info_vbox.add_theme_constant_override("separation", 2)
	t_info_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	tech_label = Label.new()
	tech_label.text = "Punkty Technologii: 0/100"
	tech_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tech_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tech_label.mouse_filter = Control.MOUSE_FILTER_STOP
	tech_label.add_theme_font_size_override("font_size", 14)
	
	tech_bar = ProgressBar.new()
	tech_bar.custom_minimum_size = Vector2(0, 8)
	tech_bar.show_percentage = false
	var t_bg = StyleBoxFlat.new()
	t_bg.bg_color = Color(0.1, 0.25, 0.25)
	var t_fg = StyleBoxFlat.new()
	t_fg.bg_color = Color(0.25, 0.7, 0.65) 
	tech_bar.add_theme_stylebox_override("background", t_bg)
	tech_bar.add_theme_stylebox_override("fill", t_fg)
	
	t_info_vbox.add_child(tech_label)
	t_info_vbox.add_child(tech_bar)
	
	tech_hbox.add_child(t_icon)
	tech_hbox.add_child(t_info_vbox)
	tech_vbox.add_child(tech_hbox)
	
	tech_research_ready_label = Label.new()
	tech_research_ready_label.text = "💡 Badanie dostępne!"
	tech_research_ready_label.add_theme_font_size_override("font_size", 12)
	tech_research_ready_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
	tech_research_ready_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tech_research_ready_label.visible = false
	tech_vbox.add_child(tech_research_ready_label)
	
	vbox.add_child(tech_vbox)
	
	add_child(points_panel)


func _align_right_column() -> void:
	if points_panel == null or tile_info_menu == null:
		return
	tile_info_menu.offset_left = points_panel.offset_left
	tile_info_menu.offset_right = points_panel.offset_right
	tile_info_menu.offset_top = points_panel.position.y + points_panel.size.y + 12
	if menu_budowania:
		menu_budowania.offset_left = points_panel.offset_left
		menu_budowania.offset_right = points_panel.offset_right


func setup_resources_header():
	resources_label.visible = false
	
	resources_container = HBoxContainer.new()
	resources_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resources_container.alignment = BoxContainer.ALIGNMENT_CENTER
	resources_container.add_theme_constant_override("separation", 12)
	$Panel.add_child(resources_container)
	
	var resources_list = ["Drewno", "Żelazo", "Węgiel", "Jedzenie", "Złoto", "Populacja"]
	for res_name in resources_list:
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 5)
		
		var icon = TextureRect.new()
		icon.texture = _resource_icon_texture(res_name)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.custom_minimum_size = Vector2(24, 24)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		var lbl = Label.new()
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color(0.9, 0.88, 0.8))
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		lbl.text = res_name + ": 0"
		
		hbox.add_child(icon)
		hbox.add_child(lbl)
		
		resources_container.add_child(hbox)
		resource_labels[res_name] = lbl

# Ostrzeżenie o głodzie — pokazywane pod górnym paskiem zasobów, gdy
# EconomyManager zgłosi w balances["Głoduje"] == true (jedzenie spadło do 0).
func setup_hunger_label():
	hunger_label = Label.new()
	hunger_label.name = "HungerWarningLabel"
	hunger_label.visible = false
	hunger_label.text = "⚠️ Głód! Brak jedzenia — populacja wymiera, a Złoto gwałtownie topnieje (kara % od skarbca)."
	hunger_label.add_theme_font_size_override("font_size", 14)
	hunger_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.3, 1.0))
	hunger_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	hunger_label.add_theme_constant_override("shadow_offset_x", 1)
	hunger_label.add_theme_constant_override("shadow_offset_y", 1)
	hunger_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hunger_label.anchor_left = 0.0
	hunger_label.anchor_right = 1.0
	hunger_label.anchor_top = 0.0
	hunger_label.anchor_bottom = 0.0
	hunger_label.offset_left = 10
	hunger_label.offset_right = -10
	hunger_label.offset_top = 58
	hunger_label.offset_bottom = 82
	hunger_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_child(hunger_label)


func setup_quick_actions() -> void:
	quick_actions_panel = PanelContainer.new()
	quick_actions_panel.name = "QuickActionsPanel"
	quick_actions_panel.anchor_left = 0.0
	quick_actions_panel.anchor_top = 0.0
	quick_actions_panel.offset_left = 20
	quick_actions_panel.offset_top = 72
	quick_actions_panel.offset_right = 230
	quick_actions_panel.add_theme_stylebox_override("panel", _panel_style(10))

	var column := VBoxContainer.new()
	column.name = "CommandColumn"
	column.add_theme_constant_override("separation", 8)
	quick_actions_panel.add_child(column)

	var title := Label.new()
	title.text = "DOWODZENIE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", DF_GOLD_TEXT)
	column.add_child(title)

	movement_label = Label.new()
	movement_label.text = "Ruch generała: 0/0"
	movement_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	movement_label.add_theme_color_override("font_color", DF_GOLD_TEXT)
	movement_label.add_theme_font_size_override("font_size", 14)
	column.add_child(movement_label)

	var actions := VBoxContainer.new()
	actions.name = "CommandButtons"
	actions.add_theme_constant_override("separation", 6)
	column.add_child(actions)

	quick_army_button = _make_quick_button("Armia", "Otwórz zarządzanie armią")
	quick_army_button.pressed.connect(func() -> void:
		hide_all_menus()
		army_menu.show_army_menu()
	)
	actions.add_child(quick_army_button)

	center_general_button = _make_quick_button("Generał", "Wyśrodkuj kamerę na generale")
	center_general_button.pressed.connect(_center_camera_on_general)
	actions.add_child(center_general_button)

	quick_potions_button = _make_quick_button("Mikstury", "Pokaż posiadane i aktywne mikstury")
	quick_potions_button.pressed.connect(func() -> void:
		hide_all_menus()
		potions_menu.show_my_potions(false)
	)
	actions.add_child(quick_potions_button)

	quick_help_button = _make_quick_button("Pomoc", "Pomoc (Tab)")
	quick_help_button.pressed.connect(func() -> void:
		hide_all_menus()
		help_menu.show_help_menu()
	)
	actions.add_child(quick_help_button)

	quick_settings_button = _make_quick_button("Menu", "Menu gry i ustawienia (Esc)")
	quick_settings_button.pressed.connect(func() -> void:
		hide_all_menus()
		settings_menu.show_settings_menu()
		if AudioManager:
			AudioManager.pause_bg_music()
	)
	actions.add_child(quick_settings_button)
	add_child(quick_actions_panel)


func _make_quick_button(text: String, tooltip: String) -> Button:
	var button := Button.new()
	button.text = text
	button.tooltip_text = tooltip
	button.custom_minimum_size = Vector2(180, 38)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_df_button(button)
	var transparent := StyleBoxEmpty.new()
	transparent.set_content_margin_all(8)
	button.add_theme_stylebox_override("normal", transparent)
	button.add_theme_stylebox_override("disabled", transparent)
	return button


func _update_movement_label() -> void:
	if movement_label == null or world_ref == null or not world_ref.get("character"):
		return
	var general = world_ref.character
	var maximum := int(general.move_range)
	if EconomyManager.culture_tree["Ruch generała I"]["unlocked"]:
		maximum += 1
	if EconomyManager.culture_tree["Ruch generała II"]["unlocked"]:
		maximum += 1
	if EconomyManager.culture_tree["Ruch generała III"]["unlocked"]:
		maximum += 1
	if GameSettings.infinite_general_movement:
		movement_label.text = "Ruch generała: ∞"
	else:
		movement_label.text = "Ruch generała: %d/%d" % [int(general.moves_left), maximum]


func _center_camera_on_general() -> void:
	if world_ref == null or not world_ref.get("character"):
		return
	var camera := world_ref.get_node_or_null("StrategyCamera") as Camera2D
	if camera != null:
		camera.global_position = world_ref.character.global_position


func setup_skip_confirmation() -> void:
	skip_confirm_dialog = ConfirmationDialog.new()
	skip_confirm_dialog.title = "Przeminięcie 5 tur"
	skip_confirm_dialog.ok_button_text = "PRZEMIŃ 5 TUR"
	skip_confirm_dialog.cancel_button_text = "ANULUJ"
	skip_confirm_dialog.confirmed.connect(_advance_five_turns)
	_style_alert_dialog(skip_confirm_dialog)
	add_child(skip_confirm_dialog)


func _show_skip_confirmation() -> void:
	if skip_button.disabled:
		return
	var buildings: Array = []
	if world_ref != null and world_ref.has_method("get_active_buildings_list"):
		buildings = world_ref.get_active_buildings_list()
	var preview := EconomyManager.get_turn_preview(buildings)
	var lines: Array[String] = [
		"Tura %d → %d" % [EconomyManager.current_turn, EconomyManager.current_turn + 5],
		"Szacowana zmiana zasobów przy obecnej produkcji:",
	]
	for resource_name: String in ["Drewno", "Żelazo", "Węgiel", "Jedzenie", "Złoto"]:
		var delta := int(preview.get(resource_name, {}).get("balance", 0)) * 5
		lines.append("• %s: %s" % [resource_name, _format_delta(delta)])
	var expected_food: int = int(EconomyManager.resources.get("Jedzenie", 0)) + int(preview.get("Jedzenie", {}).get("balance", 0)) * 5
	if expected_food <= 0:
		lines.append("\nUWAGA: prognoza wskazuje głód.")
	lines.append("\nPrognoza może zmienić się po ukończeniu badań lub szkolenia.")
	skip_confirm_dialog.dialog_text = "\n".join(lines)
	skip_confirm_dialog.popup_centered(Vector2i(560, 390))


func _advance_five_turns() -> void:
	hide_all_menus()
	for _index in range(5):
		if world_ref != null and world_ref.has_method("get_active_buildings_list"):
			EconomyManager.next_turn(world_ref.get_active_buildings_list())
	_show_turn_warnings()
	if not GameSettings.skip_turn_button_delay:
		_turn_button_cooldown = true
		await get_tree().create_timer(TURN_BUTTON_DELAY).timeout
		_turn_button_cooldown = false


func _show_turn_warnings() -> void:
	if EconomyManager.turn_warnings.is_empty():
		return
	turn_warning_dialog.dialog_text = "\n".join(EconomyManager.turn_warnings)
	turn_warning_dialog.popup_centered()

var build_grid: GridContainer

func setup_custom_popups():
	var vbox = $MenuBudowania/VBoxContainer
	menu_budowania.custom_minimum_size = Vector2(RIGHT_PANEL_WIDTH, 420)
	
	# Anchor bottom right ONCE — nad rzędem przycisków tury, w tej samej kolumnie co ROZWÓJ
	menu_budowania.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	menu_budowania.offset_left = RIGHT_PANEL_OFFSET_LEFT
	menu_budowania.offset_right = RIGHT_PANEL_OFFSET_RIGHT
	menu_budowania.offset_bottom = -(TURN_ACTIONS_MARGIN_BOTTOM + TURN_BUTTON_HEIGHT + 16.0)
	menu_budowania.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	menu_budowania.grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	# 1. HEADER
	var header_hbox = HBoxContainer.new()
	header_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	var title_label = Label.new()
	title_label.text = "Menu Budowy"
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", DF_GOLD_TEXT)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.custom_minimum_size = Vector2(30, 30)
	close_btn.pressed.connect(func(): hide_all_menus())
	_style_df_button(close_btn)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(30, 30)
	header_hbox.add_child(spacer)
	header_hbox.add_child(title_label)
	header_hbox.add_child(close_btn)
	vbox.add_child(header_hbox)
	vbox.move_child(header_hbox, 0)
	
	# 2. TABS
	var tabs_hbox = HBoxContainer.new()
	cat_zasobowe = Button.new()
	cat_naukowe = Button.new()
	cat_tech = Button.new()
	cat_wojskowe = Button.new()
	cat_zasobowe.text = "Surowce"
	cat_naukowe.text = "Kultura"
	cat_tech.text = "Technologia"
	cat_wojskowe.text = "Wojskowe"
	cat_zasobowe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cat_naukowe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cat_tech.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cat_wojskowe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs_hbox.add_child(cat_zasobowe)
	tabs_hbox.add_child(cat_naukowe)
	tabs_hbox.add_child(cat_tech)
	tabs_hbox.add_child(cat_wojskowe)
	vbox.add_child(tabs_hbox)
	vbox.move_child(tabs_hbox, 1)
	
	cat_zasobowe.pressed.connect(func(): _show_building_category("zasobowe"))
	cat_naukowe.pressed.connect(func(): _show_building_category("naukowe"))
	cat_tech.pressed.connect(func(): _show_building_category("tech"))
	cat_wojskowe.pressed.connect(func(): _show_building_category("wojskowe"))
	
	# 3. KUP POLE BUTTON AND TILE INFO MENU SEPARATION
	tile_info_menu = PanelContainer.new()
	tile_info_menu.visible = false
	tile_info_menu.anchor_left = 1.0
	tile_info_menu.anchor_right = 1.0
	tile_info_menu.offset_left = RIGHT_PANEL_OFFSET_LEFT
	tile_info_menu.offset_right = RIGHT_PANEL_OFFSET_RIGHT
	tile_info_menu.offset_top = 348
	tile_info_menu.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	tile_info_menu.z_index = 5
	tile_info_menu.add_theme_stylebox_override("panel", _panel_style(8))
	
	var tile_info_vbox = VBoxContainer.new()
	tile_info_vbox.add_theme_constant_override("separation", 6)
	tile_info_menu.add_child(tile_info_vbox)
	
	info_label = RichTextLabel.new()
	info_label.bbcode_enabled = true
	info_label.fit_content = true
	info_label.custom_minimum_size = Vector2(300, 0)
	info_label.add_theme_color_override("default_color", DF_GOLD_TEXT)
	
	destroy_button = Button.new()
	destroy_button.text = "💥 Zniszcz budynek"
	destroy_button.pressed.connect(func():
		var costs = EconomyManager.get_modified_building_costs(active_building_name)
		var refund_gold = int(costs.get("Złoto", 0) * 0.5)
		destroy_confirm_dialog.dialog_text = "Czy na pewno chcesz zniszczyć ten budynek?\nOtrzymasz zwrot %d złota do skarbca (50%% ceny budynku)." % refund_gold
		destroy_confirm_dialog.popup_centered()
		hide_all_menus()
	)
	destroy_button.tooltip_text = "Zniszczenie budynku zwraca do skarbca 50% złota wydanego na jego budowę."
	_style_df_button(destroy_button)

	upgrade_button = Button.new()
	upgrade_button.text = "⬆️ Ulepsz budynek"
	upgrade_button.pressed.connect(func(): 
		var missing_tech = EconomyManager.get_missing_tech_for_upgrade(active_building_name, active_building_level + 1)
		if missing_tech != "":
			if AudioManager: AudioManager.play_error()
			tech_warning_dialog.dialog_text = "Aby ulepszyć ten budynek, musisz najpierw odkryć technologię:\n" + missing_tech
			tech_warning_dialog.popup_centered()
			return

		if not EconomyManager.can_afford_upgrade(active_building_name, active_building_level):
			if AudioManager: AudioManager.play_error()
			return

		if world_ref and world_ref.has_method("upgrade_building"):
			world_ref.upgrade_building(active_tile_pos)
			if AudioManager: AudioManager.play_upgrade()
		hide_all_menus()
	)
	_style_df_button(upgrade_button)

	recruit_button = Button.new()
	recruit_button.text = "⚔️ Rekrutuj"
	recruit_button.pressed.connect(func():
		hide_all_menus()
		var b_level = 1
		var source_pos = Vector2(-1, -1)
		if world_ref and active_tile_pos != null and world_ref.map_data.has(active_tile_pos):
			b_level = world_ref.map_data[active_tile_pos].get("level", 1)
			source_pos = active_tile_pos
		barracks_menu.show_barracks_menu(b_level, source_pos)
	)
	_style_df_button(recruit_button)

	army_button = Button.new()
	army_button.text = "🛡️ Moja Armia"
	army_button.pressed.connect(func():
		hide_all_menus()
		army_menu.show_army_menu()
	)
	_style_df_button(army_button)

	tile_info_vbox.add_child(info_label)
	tile_info_vbox.add_child(upgrade_button)
	tile_info_vbox.add_child(destroy_button)
	tile_info_vbox.add_child(army_button)
	tile_info_vbox.add_child(recruit_button)
	
	btn_my_potions = Button.new()
	btn_my_potions.text = "🧪 Moje mikstury"
	_style_df_button(btn_my_potions)
	btn_my_potions.pressed.connect(func():
		hide_all_menus()
		potions_menu.show_my_potions(true)
	)
	tile_info_vbox.add_child(btn_my_potions)
	
	btn_buy_potions = Button.new()
	btn_buy_potions.text = "💰 Kup mikstury"
	_style_df_button(btn_buy_potions)
	btn_buy_potions.pressed.connect(func():
		hide_all_menus()
		potions_menu.show_buy_potions()
	)
	tile_info_vbox.add_child(btn_buy_potions)
	
	temple_button = Button.new()
	temple_button.text = "🙏 Błogosławieństwo Świątyni"
	_style_df_button(temple_button)
	temple_button.pressed.connect(func():
		hide_all_menus()
		temple_menu.show_temple_menu()
	)
	tile_info_vbox.add_child(temple_button)

	workshop_button = Button.new()
	workshop_button.text = "🔧 Warsztat: Uzdrawianie"
	_style_df_button(workshop_button)
	workshop_button.pressed.connect(func():
		hide_all_menus()
		workshop_menu.show_workshop_menu(active_tile_pos)
	)
	tile_info_vbox.add_child(workshop_button)

	library_research_button = Button.new()
	library_research_button.text = "📚 Badania Umiejętności"
	_style_df_button(library_research_button)
	library_research_button.pressed.connect(func():
		hide_all_menus()
		library_research_menu.show_library_menu()
	)
	tile_info_vbox.add_child(library_research_button)
	
	camp_details_btn = Button.new()
	camp_details_btn.text = "⛺ Szczegóły Obozowiska"
	camp_details_btn.pressed.connect(func():
		hide_all_menus()
		camp_menu.show_camp_details_menu(active_tile_pos)
	)
	_style_df_button(camp_details_btn)
	tile_info_vbox.add_child(camp_details_btn)
	
	kup_pole_button = Button.new()
	# POPRAWKA: cena pobierana z EconomyManager zamiast zaszytej na sztywno
	# liczby — przyszła zmiana ceny w ekonomii nie rozjedzie już UI.
	kup_pole_button.text = "Kup to pole (%d złota)" % EconomyManager.TILE_PURCHASE_GOLD_COST
	kup_pole_button.icon = _resource_icon_texture("Złoto")
	kup_pole_button.expand_icon = true
	kup_pole_button.add_theme_constant_override("icon_max_width", 24)
	kup_pole_button.custom_minimum_size = Vector2(180, 35)
	_style_df_button(kup_pole_button)
	tile_info_vbox.add_child(kup_pole_button)
	
	kup_pole_button.pressed.connect(func():
		if world_ref and world_ref.has_method("buy_tile"):
			world_ref.buy_tile(active_tile_pos)
		hide_all_menus()
	)
	
	add_child(tile_info_menu)
	
	# 4. SCROLLABLE GRID FOR BUILDING BUTTONS
	var build_scroll := ScrollContainer.new()
	build_scroll.name = "BuildScroll"
	build_scroll.custom_minimum_size = Vector2(0, 250)
	build_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	build_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	build_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	build_scroll.follow_focus = true
	vbox.add_child(build_scroll)
	vbox.move_child(build_scroll, 2)

	build_grid = GridContainer.new()
	build_grid.columns = 3
	build_grid.custom_minimum_size = Vector2(320, 210)
	build_grid.add_theme_constant_override("h_separation", 10)
	build_grid.add_theme_constant_override("v_separation", 10)
	build_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	build_scroll.add_child(build_grid)
	
	# 5. BUTTONS (Reparent and create new ones)
	build_chata.reparent(build_grid)
	build_iron.reparent(build_grid)
	build_coal.reparent(build_grid)
	build_farma = Button.new()
	build_grid.add_child(build_farma)
	build_farma.pressed.connect(func(): execute_build("Farma"))
	
	build_pastwisko = Button.new()
	build_grid.add_child(build_pastwisko)
	build_pastwisko.pressed.connect(func(): execute_build("Pastwisko"))
	style_single_button(build_pastwisko, "Pastwisko", "Pastwisko")

	build_dom = Button.new()
	build_grid.add_child(build_dom)
	build_dom.pressed.connect(func(): execute_build("Dom mieszkalny"))
	
	build_spichlerz = Button.new()
	build_grid.add_child(build_spichlerz)
	build_spichlerz.pressed.connect(func(): execute_build("Spichlerz"))
	style_single_button(build_spichlerz, "Spichlerz", "Spichlerz")
	
	btn_tech_1 = Button.new()
	btn_tech_2 = Button.new()
	build_grid.add_child(btn_tech_1)
	build_grid.add_child(btn_tech_2)
	btn_tech_1.pressed.connect(func(): execute_build("Laboratorium"))
	btn_tech_2.pressed.connect(func(): execute_build("Warsztat"))
	
	btn_naukowy_1 = Button.new()
	btn_naukowy_2 = Button.new()
	build_grid.add_child(btn_naukowy_1)
	build_grid.add_child(btn_naukowy_2)
	btn_naukowy_1.pressed.connect(func(): execute_build("Biblioteka"))
	btn_naukowy_2.pressed.connect(func(): execute_build("Świątynia"))

	build_baraki = Button.new()
	build_grid.add_child(build_baraki)
	build_baraki.pressed.connect(func(): execute_build("Baraki"))
	
	# 7. ZALOZ MIASTO MENU
	menu_zalozenia_miasta = PopupPanel.new()
	menu_zalozenia_miasta.visible = false
	menu_zalozenia_miasta.add_theme_stylebox_override("panel", _panel_style(8))
	
	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 4)
	margin_container.add_theme_constant_override("margin_right", 4)
	margin_container.add_theme_constant_override("margin_top", 4)
	margin_container.add_theme_constant_override("margin_bottom", 4)
	
	zaloz_miasto_button = Button.new()
	zaloz_miasto_button.text = "👑 Załóż Miasto tutaj"
	zaloz_miasto_button.custom_minimum_size = Vector2(160, 35)
	_style_df_button(zaloz_miasto_button)
	margin_container.add_child(zaloz_miasto_button)
	menu_zalozenia_miasta.add_child(margin_container)
	add_child(menu_zalozenia_miasta)
	
	zaloz_miasto_button.pressed.connect(func():
		if world_ref and world_ref.has_method("create_city_at"):
			world_ref.create_city_at(active_tile_pos)
		hide_all_menus()
	)
	
	confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = "Uwaga: Zniszczenie Złoża!"
	confirm_dialog.dialog_text = "Czy na pewno chcesz postawić ten budynek na tym polu?\nPostawienie go tutaj bezpowrotnie zniszczy obecne złoże i zamieni pole w trawę."
	confirm_dialog.ok_button_text = "Tak"
	confirm_dialog.cancel_button_text = "Anuluj"
	confirm_dialog.confirmed.connect(_on_confirm_build_on_resource)
	_style_alert_dialog(confirm_dialog)
	add_child(confirm_dialog)
	
	destroy_confirm_dialog = ConfirmationDialog.new()
	destroy_confirm_dialog.title = "Zniszczenie Budynku"
	destroy_confirm_dialog.ok_button_text = "Zniszcz"
	destroy_confirm_dialog.cancel_button_text = "Anuluj"
	destroy_confirm_dialog.confirmed.connect(_on_confirm_destroy_building)
	_style_alert_dialog(destroy_confirm_dialog)
	add_child(destroy_confirm_dialog)
	
	wood_warning_dialog = ConfirmationDialog.new()
	wood_warning_dialog.title = "Uwaga: Mało drewna!"
	wood_warning_dialog.dialog_text = "Wybudowanie tego budynku obniży Twój zapas drewna poniżej 10.\nBędziesz polegał tylko na powolnym, pasywnym przychodzie z Centrum Miasta.\nCzy na pewno chcesz kontynuować?"
	wood_warning_dialog.ok_button_text = "Tak"
	wood_warning_dialog.cancel_button_text = "Anuluj"
	wood_warning_dialog.confirmed.connect(_on_confirm_wood_warning)
	_style_alert_dialog(wood_warning_dialog)
	add_child(wood_warning_dialog)
	
	tech_warning_dialog = AcceptDialog.new()
	tech_warning_dialog.title = "Brak technologii"
	tech_warning_dialog.dialog_text = ""
	tech_warning_dialog.ok_button_text = "Zrozumiałem"
	_style_alert_dialog(tech_warning_dialog)
	add_child(tech_warning_dialog)
	
	turn_warning_dialog = AcceptDialog.new()
	turn_warning_dialog.title = "Ostrzeżenie"
	turn_warning_dialog.dialog_text = ""
	turn_warning_dialog.ok_button_text = "Zrozumiałem"
	_style_alert_dialog(turn_warning_dialog)
	add_child(turn_warning_dialog)
	
	research_unlocked_dialog = AcceptDialog.new()
	research_unlocked_dialog.exclusive = false
	research_unlocked_dialog.title = "Osiągnięcie odblokowane"
	research_unlocked_dialog.dialog_text = ""
	research_unlocked_dialog.ok_button_text = "Przejdź do drzewka"
	research_unlocked_dialog.confirmed.connect(_on_research_unlocked_confirmed)
	_style_alert_dialog(research_unlocked_dialog)
	add_child(research_unlocked_dialog)

func _format_cost_dict(cost: Dictionary) -> String:
	var parts: Array = []
	for res in cost:
		parts.append("%d %s" % [cost[res], res])
	return ", ".join(parts)

# POPRAWKA: pomocnicza funkcja formatująca bilans zasobu "na turę" ze
# znakiem (+/-), używana w nagłówku HUD-u oraz przy Punktach Kultury/Nauki.
func _format_delta(value: int) -> String:
	if value > 0:
		return "+%d/turę" % value
	elif value < 0:
		return "%d/turę" % value
	else:
		return "+0/turę"

func _wrap_text(text: String, line_length: int = 50) -> String:
	var words = text.split(" ")
	var result = ""
	var current_line_len = 0
	for word in words:
		if current_line_len + word.length() > line_length:
			result += "\n" + word + " "
			current_line_len = word.length() + 1
		else:
			result += word + " "
			current_line_len += word.length() + 1
	return result.strip_edges()

func show_context_menu(mouse_pos: Vector2, tile_pos: Vector2, tile_type: String, building_name: String, building_level: int, is_owned: bool, borders_owned: bool, deposit_size: String = "") -> void:
	hide_all_menus()
	active_tile_pos = tile_pos
	active_tile_type = tile_type
	active_building_name = building_name
	active_building_level = building_level
	last_mouse_pos = mouse_pos
	
	var has_building = building_name != "Brak"
	var show_buildings = is_owned and not has_building
	
	menu_budowania.visible = show_buildings
	
	tile_info_menu.visible = true
	
	var show_upgrade = is_owned and has_building and building_name != "Centrum Miasta" and building_level < 3
	
	if has_building:
		if building_name == "Zamek" or building_name.begins_with("Obóz"):
			var camp_data = {}
			if world_ref and world_ref.get("camps") and world_ref.camps.has(active_tile_pos):
				camp_data = world_ref.camps[active_tile_pos]
			
			var army_text = "Brak"
			if camp_data.has("army") and camp_data["army"].size() > 0:
				army_text = str(camp_data["army"].size()) + " jednostek"
			if camp_data.get("is_castle", false) or camp_data.get("is_boss", false):
				army_text += " (3 etapy walki)"
				
			var res_text = ""
			if camp_data.has("resources"):
				res_text = "%s %d | %s %d | %s %d" % [
					_resource_icon_bbcode("Złoto"),
					camp_data["resources"]["gold"],
					_resource_icon_bbcode("Drewno"),
					camp_data["resources"]["wood"],
					_resource_icon_bbcode("Żelazo"),
					camp_data["resources"]["iron"],
				]
			
			var icon := "🏰" if building_name == "Zamek" else "⛺"
			info_label.text = "[center]%s %s (Lvl %d)\n⚔️ Nacja: %s\n📦 Surowce: %s\n🛡️ Armia: %s[/center]" % [icon, building_name, building_level, camp_data.get("faction_name", "Nieznana"), res_text, army_text]
		else:
			var t_text = ""
			if building_name == "Centrum Miasta":
				t_text = "[center]🏢 Budynek: %s\nPodłoże: %s" % [building_name, tile_type]
			else:
				t_text = "[center]🏢 Budynek: %s (Lvl %d)\nPodłoże: %s" % [building_name, building_level, tile_type]
			if deposit_size != "":
				t_text += "\n📦 Wielkość: %s" % deposit_size
			var active_buildings = []
			if world_ref and world_ref.has_method("get_active_buildings_list"):
				active_buildings = world_ref.get_active_buildings_list()
			t_text += EconomyManager.get_building_production_info(building_name, building_level, deposit_size, active_buildings)
			t_text += "[/center]"
			info_label.text = t_text
			

	elif tile_type == "Trawa":
		info_label.text = "[center]🌱 Typ: %s[/center]" % [tile_type]
	else:
		info_label.text = "[center]⛰️ Typ: Złoże %s\n📦 Wielkość: %s[/center]" % [tile_type, deposit_size]

	if is_owned or has_building:
		kup_pole_button.visible = false
	else:
		kup_pole_button.visible = true
		var can_afford = EconomyManager.resources["Złoto"] >= EconomyManager.TILE_PURCHASE_GOLD_COST
		var is_camp_territory = world_ref and world_ref.get("camp_owned_tiles") and world_ref.camp_owned_tiles.has(active_tile_pos)
		var can_buy = can_afford and borders_owned and not is_camp_territory
		kup_pole_button.disabled = not can_buy
		kup_pole_button.modulate.a = 1.0 if can_buy else 0.35
		
		if is_camp_territory:
			kup_pole_button.tooltip_text = "To pole należy do wrogiego obozowiska!"
		elif not borders_owned:
			kup_pole_button.tooltip_text = "Możesz kupić tylko pole sąsiadujące z własnym terytorium."
		elif not can_afford:
			kup_pole_button.tooltip_text = "Brakuje %d złota." % (EconomyManager.TILE_PURCHASE_GOLD_COST - EconomyManager.resources["Złoto"])
		else:
			kup_pole_button.tooltip_text = "Dołącz pole do swojego terytorium."

	upgrade_button.visible = show_upgrade
	destroy_button.visible = is_owned and has_building and building_name != "Centrum Miasta"
	recruit_button.visible = (has_building and building_name == "Baraki" and is_owned)
	army_button.visible = (has_building and building_name == "Baraki" and is_owned)
	camp_details_btn.visible = (has_building and (building_name.begins_with("Obóz") or building_name == "Zamek"))
	btn_my_potions.visible = (has_building and building_name == "Laboratorium" and is_owned)
	btn_buy_potions.visible = (has_building and building_name == "Laboratorium" and is_owned)
	temple_button.visible = (has_building and building_name == "Świątynia" and is_owned)
	workshop_button.visible = (has_building and building_name == "Warsztat" and is_owned)
	library_research_button.visible = (has_building and building_name == "Biblioteka" and is_owned)
	if show_upgrade:
		var missing_upgrade_tech := EconomyManager.get_missing_tech_for_upgrade(building_name, building_level + 1)
		var can_upgrade = missing_upgrade_tech == "" and EconomyManager.can_afford_upgrade(building_name, building_level)
		upgrade_button.disabled = not can_upgrade
		upgrade_button.modulate.a = 1.0 if can_upgrade else 0.5
		var up_cost = EconomyManager.get_upgrade_cost(building_name, building_level)
		var effect_desc = EconomyManager.get_building_effect_description(building_name)
		var tooltip = "Koszt ulepszenia:\n%s" % _format_cost_dict(up_cost)
		if missing_upgrade_tech != "":
			tooltip = "Wymagana technologia: %s\n\n%s" % [missing_upgrade_tech, tooltip]
		elif not can_upgrade:
			tooltip = "%s\n\nBrakuje: %s" % [tooltip, _missing_resources_text(up_cost)]
		if effect_desc != "":
			tooltip += "\n\nEfekt:\n%s" % _wrap_text(effect_desc, 60)
			
		var active_buildings = []
		if world_ref and world_ref.has_method("get_active_buildings_list"):
			active_buildings = world_ref.get_active_buildings_list()
			
		var future_prod = EconomyManager.get_building_production_info(building_name, building_level + 1, deposit_size, active_buildings, false)
		if future_prod != "":
			tooltip += "\n\nPrzewidywana produkcja (Lvl %d):%s" % [building_level + 1, future_prod]
		else:
			tooltip += "\n\nPrzewidywana produkcja (Lvl %d):\nBrak zmian w produkcji na turę." % [building_level + 1]
			
		upgrade_button.tooltip_text = tooltip
	
	cat_zasobowe.visible = show_buildings
	cat_tech.visible = show_buildings
	cat_naukowe.visible = show_buildings
	cat_wojskowe.visible = show_buildings
	
	build_chata.visible = false
	build_iron.visible = false
	build_coal.visible = false
	build_farma.visible = false
	build_pastwisko.visible = false
	build_dom.visible = false
	build_spichlerz.visible = false
	btn_tech_1.visible = false
	btn_tech_2.visible = false
	btn_naukowy_1.visible = false
	btn_naukowy_2.visible = false
	build_baraki.visible = false
	
	if show_buildings:
		update_button_state(build_chata, "Chata Drwala", tile_type)
		update_button_state(build_iron, "Kopalnia Żelaza", tile_type)
		update_button_state(build_coal, "Kopalnia Węgla", tile_type)
		update_button_state(build_farma, "Farma", tile_type)
		update_button_state(build_pastwisko, "Pastwisko", tile_type)
		update_button_state(build_dom, "Dom mieszkalny", tile_type)
		update_button_state(build_spichlerz, "Spichlerz", tile_type)
		update_button_state(btn_tech_1, "Laboratorium", tile_type)
		update_button_state(btn_tech_2, "Warsztat", tile_type)
		update_button_state(btn_naukowy_1, "Biblioteka", tile_type)
		update_button_state(btn_naukowy_2, "Świątynia", tile_type)
		update_button_state(build_baraki, "Baraki", tile_type)
		
		_show_building_category("zasobowe")
		
	tile_info_menu.reset_size()
	call_deferred("_align_right_column")

func _is_building_researched(b_name: String) -> bool:
	return EconomyManager.get_missing_tech_for_building(b_name) == ""

func _show_building_category(category: String):
	var is_zasobowe = (category == "zasobowe")
	build_chata.visible = is_zasobowe
	build_iron.visible = is_zasobowe
	build_coal.visible = is_zasobowe
	build_farma.visible = is_zasobowe
	build_pastwisko.visible = is_zasobowe
	build_dom.visible = is_zasobowe
	build_spichlerz.visible = is_zasobowe

	var is_tech = (category == "tech")
	btn_tech_1.visible = is_tech
	btn_tech_2.visible = is_tech

	var is_naukowe = (category == "naukowe")
	btn_naukowy_1.visible = is_naukowe
	btn_naukowy_2.visible = is_naukowe

	var is_wojskowe = (category == "wojskowe")
	build_baraki.visible = is_wojskowe
	
	var selected_color = DF_GOLD_TEXT
	var unselected_color = DF_TEXT
	cat_zasobowe.add_theme_color_override("font_color", selected_color if is_zasobowe else unselected_color)
	cat_naukowe.add_theme_color_override("font_color", selected_color if is_naukowe else unselected_color)
	cat_tech.add_theme_color_override("font_color", selected_color if is_tech else unselected_color)
	cat_wojskowe.add_theme_color_override("font_color", selected_color if is_wojskowe else unselected_color)

func show_city_creation_menu(_screen_pos: Vector2, tile_pos: Vector2) -> void:
	hide_all_menus()
	active_tile_pos = tile_pos
	var current_mouse_pos = get_viewport().get_mouse_position()
	var popup_rect = Rect2(current_mouse_pos + Vector2(10, 10), Vector2(170, 45))
	menu_zalozenia_miasta.popup(popup_rect)

func hide_all_menus():
	menu_budowania.visible = false
	if tile_info_menu: tile_info_menu.visible = false
	if menu_zalozenia_miasta: menu_zalozenia_miasta.visible = false
	if tech_tree_menu and tech_tree_menu.tech_tree_window: tech_tree_menu.tech_tree_window.visible = false
	if culture_tree_menu and culture_tree_menu.culture_tree_window: culture_tree_menu.culture_tree_window.visible = false
	if barracks_menu and barracks_menu.barracks_window: barracks_menu.barracks_window.visible = false
	if army_menu and army_menu.army_window: army_menu.army_window.visible = false
	if camp_menu and camp_menu.camp_details_window: camp_menu.camp_details_window.visible = false
	if camp_menu and camp_menu.camp_army_window: camp_menu.camp_army_window.visible = false
	if help_menu and help_menu.help_window: help_menu.help_window.visible = false
	if settings_menu and settings_menu.settings_window: settings_menu.settings_window.visible = false
	if tutorial_menu and tutorial_menu.tutorial_window: tutorial_menu.tutorial_window.visible = false
	if admin_menu and admin_menu.admin_window: admin_menu.admin_window.visible = false
	if potions_menu and potions_menu.my_potions_window: potions_menu.my_potions_window.visible = false
	if potions_menu and potions_menu.buy_potions_window: potions_menu.buy_potions_window.visible = false
	if temple_menu and temple_menu.temple_window: temple_menu.temple_window.visible = false
	if workshop_menu and workshop_menu.workshop_window: workshop_menu.workshop_window.visible = false
	if library_research_menu and library_research_menu.library_window: library_research_menu.library_window.visible = false
	if research_unlocked_dialog: research_unlocked_dialog.hide()
	if AudioManager: AudioManager.resume_bg_music()
	_update_menu_backdrop()

func any_menu_visible() -> bool:
	return menu_budowania.visible or (tile_info_menu and tile_info_menu.visible) or (menu_zalozenia_miasta and menu_zalozenia_miasta.visible) or (tech_tree_menu and tech_tree_menu.tech_tree_window and tech_tree_menu.tech_tree_window.visible) or (culture_tree_menu and culture_tree_menu.culture_tree_window and culture_tree_menu.culture_tree_window.visible) or (barracks_menu and barracks_menu.barracks_window and barracks_menu.barracks_window.visible) or (army_menu and army_menu.army_window and army_menu.army_window.visible) or (help_menu and help_menu.help_window and help_menu.help_window.visible) or (camp_menu and camp_menu.camp_details_window and camp_menu.camp_details_window.visible) or (camp_menu and camp_menu.camp_army_window and camp_menu.camp_army_window.visible) or (settings_menu and settings_menu.settings_window and settings_menu.settings_window.visible) or (tutorial_menu and tutorial_menu.tutorial_window and tutorial_menu.tutorial_window.visible) or (admin_menu and admin_menu.admin_window and admin_menu.admin_window.visible) or (temple_menu and temple_menu.temple_window and temple_menu.temple_window.visible) or (workshop_menu and workshop_menu.workshop_window and workshop_menu.workshop_window.visible) or (library_research_menu and library_research_menu.library_window and library_research_menu.library_window.visible) or (potions_menu and ((potions_menu.my_potions_window and potions_menu.my_potions_window.visible) or (potions_menu.buy_potions_window and potions_menu.buy_potions_window.visible))) or (research_unlocked_dialog and research_unlocked_dialog.visible)

func update_button_state(btn: Button, b_name: String, tile_type: String):
	var reason := _building_block_reason(b_name, tile_type)
	var can_place := reason == ""
	btn.disabled = not can_place
	btn.modulate.a = 1.0 if can_place else 0.35
	var base_tooltip := str(btn.get_meta("base_tooltip", btn.tooltip_text))
	btn.tooltip_text = base_tooltip if can_place else "%s\n\nNIEDOSTĘPNE: %s" % [base_tooltip, reason]
	var name_label := btn.get_node_or_null("VBoxContainer/NameLabel") as Label
	if name_label != null:
		name_label.text = b_name if EconomyManager.get_missing_tech_for_building(b_name) == "" else "🔒 %s" % b_name


func _building_block_reason(building_name: String, tile_type: String) -> String:
	var missing_tech := EconomyManager.get_missing_tech_for_building(building_name)
	if missing_tech != "":
		return "wymagana technologia „%s”" % missing_tech
	var required_terrain := {
		"Chata Drwala": "Drewno",
		"Kopalnia Żelaza": "Żelazo",
		"Kopalnia Węgla": "Węgiel",
		"Farma": "Pszenica",
		"Pastwisko": "Bydło",
	}
	if required_terrain.has(building_name) and tile_type != required_terrain[building_name]:
		return "wymagane pole: %s" % required_terrain[building_name]
	if building_name in ["Laboratorium", "Warsztat", "Biblioteka", "Świątynia"]:
		if world_ref != null and world_ref.has_method("get_building_count") and world_ref.get_building_count(building_name) >= 3:
			return "osiągnięto limit 3 budynków tego typu"
	var missing := _missing_resources_text(EconomyManager.get_modified_building_costs(building_name))
	return "" if missing == "" else "brakuje: %s" % missing


func _missing_resources_text(cost: Dictionary) -> String:
	var missing: Array[String] = []
	for resource_name in cost:
		var shortage := int(cost[resource_name]) - int(EconomyManager.resources.get(resource_name, 0))
		if shortage > 0:
			missing.append("%d %s" % [shortage, resource_name])
	return ", ".join(missing)

func execute_build(building_name: String) -> void:
	var block_reason := _building_block_reason(building_name, active_tile_type)
	if block_reason != "":
		if AudioManager:
			AudioManager.play_error()
		tech_warning_dialog.title = "Nie można wybudować"
		tech_warning_dialog.dialog_text = "%s: %s." % [building_name, block_reason]
		tech_warning_dialog.popup_centered()
		hide_all_menus()
		return

	if building_name in ["Laboratorium", "Warsztat", "Biblioteka", "Świątynia"]:
		if world_ref.get_building_count(building_name) >= 3:
			tech_warning_dialog.dialog_text = "Osiągnięto limit budynków tego typu! (Maksymalnie 3)"
			tech_warning_dialog.popup_centered()
			hide_all_menus()
			return

	var costs = EconomyManager.get_modified_building_costs(building_name)
	var wood_cost = costs.get("Drewno", 0)
	var remaining_wood = EconomyManager.resources.get("Drewno", 0) - wood_cost
	
	if wood_cost > 0 and remaining_wood < 10 and building_name != "Chata Drwala":
		pending_building = building_name
		wood_warning_dialog.popup_centered()
		hide_all_menus()
		return

	if active_tile_type != "Trawa" and building_name in ["Dom mieszkalny", "Spichlerz", "Laboratorium", "Warsztat", "Biblioteka", "Świątynia", "Baraki"]:
		pending_building = building_name
		confirm_dialog.popup_centered()
		hide_all_menus()
	else:
		_do_execute_build(building_name)

func _on_confirm_wood_warning() -> void:
	if pending_building != "":
		if active_tile_type != "Trawa" and pending_building in ["Dom mieszkalny", "Spichlerz", "Laboratorium", "Warsztat", "Biblioteka", "Świątynia", "Baraki"]:
			confirm_dialog.popup_centered()
		else:
			_do_execute_build(pending_building)
			pending_building = ""

func _on_confirm_build_on_resource() -> void:
	if pending_building != "":
		_do_execute_build(pending_building)
		pending_building = ""

func _on_confirm_destroy_building() -> void:
	if active_building_name == "Brak" or active_building_name == "Centrum Miasta": return
	var costs = EconomyManager.get_modified_building_costs(active_building_name)
	# POPRAWKA: zniszczenie budynku zwraca 50% jego kosztu w złocie do
	# skarbca, zamiast dodatkowo obciążać gracza opłatą za zniszczenie.
	var refund_gold = int(costs.get("Złoto", 0) * 0.5)
	
	EconomyManager.resources["Złoto"] += refund_gold
	if world_ref and world_ref.has_method("destroy_building"):
		world_ref.destroy_building(active_tile_pos)
	EconomyManager.notify_change()
	hide_all_menus()

func _do_execute_build(building_name: String) -> void:
	if world_ref and world_ref.has_method("build_on_tile"):
		world_ref.build_on_tile(active_tile_pos, building_name)
		if AudioManager: AudioManager.play_build()
	hide_all_menus()

func _on_economy_updated(balances: Dictionary, turn: int, _selected_build: String):
	var preview: Dictionary = {}
	if world_ref and world_ref.has_method("get_active_buildings_list"):
		preview = EconomyManager.get_turn_preview(world_ref.get_active_buildings_list())

	var get_balance = func(res_name: String) -> int:
		if preview.has(res_name):
			return preview[res_name].get("balance", 0)
		return 0

	var setup_tooltip = func(res_name: String) -> String:
		if preview.has(res_name):
			var p = preview[res_name]
			var extra = ""
			if res_name == "Jedzenie" and p.has("max"):
				extra = "\nLimit magazynu (Spichlerz): %d" % p["max"]
			return "Zasób: %s\nProdukcja: +%d\nPobieranie: -%d\nBilans: %s%s" % [
				res_name, p.get("produced", 0), p.get("consumed", 0), _format_delta(p.get("balance", 0)), extra
			]
		return ""

	if resources_container:
		resource_labels["Drewno"].text = "Drewno: %d (%s)" % [balances["Drewno"], _format_delta(get_balance.call("Drewno"))]
		resource_labels["Drewno"].tooltip_text = setup_tooltip.call("Drewno")
		resource_labels["Żelazo"].text = "Żelazo: %d (%s)" % [balances["Żelazo"], _format_delta(get_balance.call("Żelazo"))]
		resource_labels["Żelazo"].tooltip_text = setup_tooltip.call("Żelazo")
		resource_labels["Węgiel"].text = "Węgiel: %d (%s)" % [balances["Węgiel"], _format_delta(get_balance.call("Węgiel"))]
		resource_labels["Węgiel"].tooltip_text = setup_tooltip.call("Węgiel")
		resource_labels["Jedzenie"].text = "Jedzenie: %d/%d (%s)" % [balances["Jedzenie"], balances.get("Maks_Jedzenie", 20), _format_delta(get_balance.call("Jedzenie"))]
		resource_labels["Jedzenie"].tooltip_text = setup_tooltip.call("Jedzenie")
		resource_labels["Złoto"].text = "Złoto: %d (%s)" % [balances["Złoto"], _format_delta(get_balance.call("Złoto"))]
		resource_labels["Złoto"].tooltip_text = setup_tooltip.call("Złoto")
		resource_labels["Populacja"].text = "Pop: %d/%d" % [balances.get("Populacja", 1), balances.get("Maks_Populacja", 5)]
		resource_labels["Populacja"].tooltip_text = "Twoja obecna populacja.\nJedzenie na turę: -%d" % [balances.get("Populacja", 1) * 1]
	else:
		resources_label.text = "Drewno: %d      Żelazo: %d      Węgiel: %d      Jedzenie: %d/%d      Złoto: %d      Pop: %d/%d" % [
			balances["Drewno"], balances["Żelazo"], balances["Węgiel"], balances["Jedzenie"], balances.get("Maks_Jedzenie", 20), balances["Złoto"], balances.get("Populacja", 1), balances.get("Maks_Populacja", 5)
		]
	turn_button.text = "NASTĘPNA TURA (%d)" % turn
	if turn_actions_row:
		turn_actions_row.reset_size()

	if hunger_label:
		hunger_label.visible = balances.get("Głoduje", false)
	
	if culture_label and tech_label:
		var c_val = balances.get("Kultura", 0)
		var t_val = balances.get("Nauka", 0)
		var c_max = EconomyManager.max_culture_points
		var t_max = EconomyManager.max_tech_points
		culture_label.text = "Punkty Kultury:    %d/%d" % [c_val, int(c_max)]
		culture_bar.max_value = c_max
		culture_bar.value = c_val
		culture_label.tooltip_text = setup_tooltip.call("Kultura")
		tech_label.text = "Punkty Technologii:    %d/%d" % [t_val, int(t_max)]
		tech_bar.max_value = t_max
		tech_bar.value = t_val
		tech_label.tooltip_text = setup_tooltip.call("Nauka")
		
		if culture_research_ready_label:
			culture_research_ready_label.visible = EconomyManager.can_research_any_culture()
		if tech_research_ready_label:
			tech_research_ready_label.visible = EconomyManager.can_research_any_technology()
	
	if tech_tree_menu and tech_tree_menu.tech_tree_window and tech_tree_menu.tech_tree_window.visible: tech_tree_menu.refresh_technology_tree_view()

func _on_turn_pressed():
	if turn_button.disabled:
		return
	hide_all_menus()

	if world_ref and world_ref.has_method("get_active_buildings_list"):
		var buildings = world_ref.get_active_buildings_list()
		EconomyManager.next_turn(buildings)
		_show_turn_warnings()

	if not GameSettings.skip_turn_button_delay:
		_turn_button_cooldown = true
		await get_tree().create_timer(TURN_BUTTON_DELAY).timeout
		_turn_button_cooldown = false

func style_main_hud_elements():
	var top_panel = $Panel
	top_panel.anchor_left = 0.0
	top_panel.anchor_right = 1.0
	top_panel.anchor_top = 0.0
	top_panel.anchor_bottom = 0.0
	top_panel.offset_left = 10
	top_panel.offset_right = -10
	top_panel.offset_top = 5
	top_panel.offset_bottom = 50
	
	top_panel.add_theme_stylebox_override("panel", _panel_style())
	
	resources_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resources_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resources_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	resources_label.add_theme_font_size_override("font_size", 14)
	resources_label.add_theme_color_override("font_color", DF_TEXT)
	
	turn_button.text = "NASTĘPNA TURA"

	for action_button: Button in [turn_button, skip_button]:
		_style_df_button(action_button)
		action_button.add_theme_font_size_override("font_size", 18)
		action_button.clip_text = false
		action_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		action_button.custom_minimum_size = Vector2(0, TURN_BUTTON_HEIGHT)
	_layout_turn_actions()

func _layout_turn_actions() -> void:
	if turn_actions_row == null:
		return
	# Punkt kotwiczenia: prawy-dolny róg z marginesem; rozmiar bierze się z treści
	# (rośnie w lewo i w górę), żeby nic nie wychodziło poza ekran.
	turn_actions_row.anchor_left = 1.0
	turn_actions_row.anchor_right = 1.0
	turn_actions_row.anchor_top = 1.0
	turn_actions_row.anchor_bottom = 1.0
	turn_actions_row.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	turn_actions_row.grow_vertical = Control.GROW_DIRECTION_BEGIN
	turn_actions_row.offset_right = -TURN_ACTIONS_MARGIN_RIGHT
	turn_actions_row.offset_bottom = -TURN_ACTIONS_MARGIN_BOTTOM
	turn_actions_row.offset_left = turn_actions_row.offset_right
	turn_actions_row.offset_top = turn_actions_row.offset_bottom
	turn_actions_row.reset_size()

func style_context_popup():
	menu_budowania.add_theme_stylebox_override("panel", _panel_style(10))
	$MenuBudowania/VBoxContainer.add_theme_constant_override("separation", 8)

	for tab_btn in [cat_zasobowe, cat_naukowe, cat_tech, cat_wojskowe]:
		_style_df_button(tab_btn)

func style_individual_buttons():
	style_single_button(build_chata, "Chata Drwala", "Chata Drwala")
	style_single_button(build_iron, "Kopalnia Żelaza", "Kopalnia Żelaza")
	style_single_button(build_coal, "Kopalnia Węgla", "Kopalnia Węgla")
	style_single_button(build_farma, "Farma", "Farma")
	style_single_button(build_dom, "Dom mieszkalny", "Dom mieszkalny")
	style_single_button(btn_tech_1, "Laboratorium", "Laboratorium")
	style_single_button(btn_tech_2, "Warsztat", "Warsztat")
	style_single_button(btn_naukowy_1, "Biblioteka", "Biblioteka")
	style_single_button(btn_naukowy_2, "Świątynia", "Świątynia")
	style_single_button(build_baraki, "Baraki", "Baraki")

func style_single_button(btn: Button, display_name: String, building_name := ""):
	btn.text = ""
	btn.custom_minimum_size = Vector2(100, 100)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(vbox)
	
	var icon = TextureRect.new()
	icon.texture = _get_icon_for_building(building_name)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.custom_minimum_size = Vector2(40, 40)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var lbl = Label.new()
	lbl.name = "NameLabel"
	lbl.text = display_name
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	vbox.add_child(icon)
	vbox.add_child(lbl)

	_style_df_button(btn)
	
	if building_name != "":
		var raw_tooltip = EconomyManager.get_building_tooltip(building_name)
		var lines = raw_tooltip.split("\n")
		var final_tooltip = ""
		for line in lines:
			final_tooltip += _wrap_text(line, 60) + "\n"
		btn.tooltip_text = final_tooltip.strip_edges()
		btn.set_meta("base_tooltip", btn.tooltip_text)

func _get_icon_for_building(b_name: String) -> Texture2D:
	var path = ""
	match b_name:
		"Centrum Miasta": path = "res://assets/tiles/city_center.png"
		"Dom mieszkalny": path = "res://assets/tiles/residential_house.png"
		"Chata Drwala": path = "res://assets/tiles/sawmill.png"
		"Kopalnia Żelaza": path = "res://assets/tiles/iron_mine.png"
		"Kopalnia Węgla": path = "res://assets/tiles/coal_mine.png"
		"Farma": path = "res://assets/tiles/farm.png"
		"Pastwisko": path = "res://assets/tiles/pasture.png"
		"Laboratorium": path = "res://assets/tiles/lab.png"
		"Warsztat": path = "res://assets/tiles/workshop.png"
		"Biblioteka": path = "res://assets/tiles/library.png"
		"Świątynia": path = "res://assets/tiles/temple.png"
		"Baraki": path = "res://assets/tiles/barracks.png"
		"Spichlerz": path = "res://assets/tiles/spichlerz.png"
	if path != "": return load(path)
	return null

func load_unit_data():
	unit_data_json = {"factions": []}
	var dir = DirAccess.open("res://data/fractions")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				var file = FileAccess.open("res://data/fractions/" + file_name, FileAccess.READ)
				if file:
					var content = file.get_as_text()
					var json = JSON.new()
					var error = json.parse(content)
					if error == OK and typeof(json.data) == TYPE_DICTIONARY:
						if json.data.has("faction"):
							unit_data_json["factions"].append(json.data["faction"])
						elif json.data.has("factions"):
							unit_data_json["factions"].append_array(json.data["factions"])
					file.close()
			file_name = dir.get_next()
		dir.list_dir_end()

func _style_alert_dialog(dialog: AcceptDialog) -> void:
	# Wspólne ostylowanie alertów (AcceptDialog / ConfirmationDialog) w
	# klimacie "dark fantasy" spójnym z resztą HUD-u — domyślny, jasny
	# systemowy wygląd Godota mocno odstawał od reszty interfejsu.
	dialog.transparent_bg = true
	dialog.add_theme_stylebox_override("panel", _panel_style(24, 70))
	dialog.add_theme_stylebox_override("embedded_border", StyleBoxEmpty.new())
	dialog.add_theme_stylebox_override("embedded_unfocused_border", StyleBoxEmpty.new())
	dialog.set_flag(Window.FLAG_BORDERLESS, true)
	dialog.min_size = Vector2i(450, 180)

	var custom_title = Label.new()
	custom_title.add_theme_color_override("font_color", DF_GOLD_TEXT)
	custom_title.add_theme_font_size_override("font_size", 20)
	custom_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var custom_close = Button.new()
	custom_close.text = "X"
	custom_close.custom_minimum_size = Vector2(35, 35)
	_style_df_button(custom_close)

	var anchor = Control.new()
	anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog.add_child(anchor)
	anchor.add_child(custom_title)
	anchor.add_child(custom_close)
	
	custom_close.pressed.connect(func(): dialog.hide())
	
	var update_layout = func():
		custom_title.text = dialog.title
		var btn_width = custom_close.get_combined_minimum_size().x
		
		# Ustawiamy pozycję absolutną względem okna (0, 0 to lewy górny róg okna),
		# a następnie odejmujemy przesunięcie, by zniwelować wpływ marginesów wewnętrznych okna.
		# Zamiast anchor.position używamy sztywnego Vector2(24, 70), bo anchor.position może
		# wynosić (0,0) przy pierwszym wywołaniu zanim Godot przeliczy layout!
		var anchor_offset = Vector2(24, 70)
		
		# Tytuł: wyśrodkowany, 20px od górnej krawędzi okna
		custom_title.size = Vector2(dialog.size.x, 30)
		custom_title.position = Vector2(0, 20) - anchor_offset
		
		# Przycisk X: 15px od prawej krawędzi okna, 15px od górnej krawędzi okna
		var margin_right = 15
		var margin_top = 15
		custom_close.position = Vector2(dialog.size.x - btn_width - margin_right, margin_top) - anchor_offset
		
	dialog.size_changed.connect(update_layout)
	dialog.about_to_popup.connect(update_layout)
	update_layout.call()

	var label = dialog.get_label()
	if label:
		label.add_theme_color_override("font_color", DF_TEXT)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var ok_btn = dialog.get_ok_button()
	if ok_btn:
		_style_df_button(ok_btn)

	if dialog is ConfirmationDialog:
		var cancel_btn = dialog.get_cancel_button()
		if cancel_btn:
			_style_df_button(cancel_btn)

func _style_df_button(btn: Button) -> void:
	# domyślny chrome Godota + Georgia/krem
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		btn.remove_theme_stylebox_override(state)
	btn.remove_theme_color_override("font_hover_color")
	btn.add_theme_color_override("font_color", DF_TEXT)
	btn.add_theme_font_size_override("font_size", 20)

func _on_tech_research_completed(tech_name: String):
	_last_unlocked_tree_type = "tech"
	research_unlocked_dialog.title = "Technologia Odblokowana"
	research_unlocked_dialog.dialog_text = "Oczekiwanie zakończone.\nOdblokowano technologię: " + tech_name
	research_unlocked_dialog.ok_button_text = "Przejdź do Drzewka Technologii"
	research_unlocked_dialog.popup_centered()

func _on_culture_research_completed(culture_name: String):
	_last_unlocked_tree_type = "culture"
	research_unlocked_dialog.title = "Kultura Odblokowana"
	research_unlocked_dialog.dialog_text = "Oczekiwanie zakończone.\nOdblokowano osiągnięcie kulturowe: " + culture_name
	research_unlocked_dialog.ok_button_text = "Przejdź do Drzewka Kultury"
	research_unlocked_dialog.popup_centered()

func _on_research_unlocked_confirmed():
	if _last_unlocked_tree_type == "tech":
		if tech_tree_menu and tech_tree_menu.tech_tree_button:
			tech_tree_menu.tech_tree_button.pressed.emit()
	elif _last_unlocked_tree_type == "culture":
		if culture_tree_button:
			culture_tree_button.pressed.emit()
