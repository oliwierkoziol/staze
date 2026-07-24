# AGENTS.md — TurnBaseGame / PrototypSystemuWalki

## Projekt
- Engine: Godot 4.7 (Forward Plus, Jolt Physics 3D, D3D12 on Windows).
- Branch roboczy: `PrototypSystemuWalki`.
- Main zawiera tylko dzienniczki — nie commituj tu kodu systemu walki.
- Język kodu, UI i komentarzy: polski.

## Zakres tego brancha
Prototyp systemu walki turowej na heksagonalnej planszy:
- 15×10 heksów, side-view camera.
- Jednostki należą do strony `player` lub `enemy`.
- Lewy panel: statystyki i akcje wybranej jednostki.
- Prawy panel: generał + log bitwy.
- Dolny pasek: lista jednostek.
- Podstawowa akcja + 3 umiejętności specjalne z cooldownem w turach.
- Statusy: buffs/debuffs, odporności (np. ogień).
- Stack count nad jednostką.

## Struktura
- `project.godot` — konfiguracja projektu.
- `gra.tscn` — główna scena UI/HUD.
- `scripts/gra.gd` — logika bitwy, dane jednostek, input, log.
- `scripts/plansza_walki.gd` — rysowanie heksów, jednostek, highlightów, animacje.
- `web/` — build HTML5 (generowany, nie edytować ręcznie).

## Zasady kodu
- GDScript: typuj zmienne i funkcje (`-> void`, `-> int`, itd.).
- Nie używaj `:=` tam gdzie typ jest `Variant` — użyj `=`.
- Najpierw rozumiem problem, potem najmniejsza zmiana (Ponytail full).
- Nie dodawaj abstrakcji z jedną implementacją, fabryk dla jednego produktu ani configu dla wartości stałej.
- Usuń martwy kod zamiast go zostawiać.
- Każda nietrywialna logika zostawia za sobą minimalny test/smoke — jeśli nie da się uruchomić w Godot, opisz krok weryfikacji w commicie.

## Weryfikacja
- Przed powiedzeniem "gotowe": uruchom projekt w Godot i sprawdź, czy scena się otwiera bez błędów.
- Jeśli nie możesz uruchomić Godot — przynajmniej `tscn` musi być poprawny, a skrypty bez oczywistych błędów składniowych.
- Nie commituj buildów `web/` ani folderu `.godot/`.
