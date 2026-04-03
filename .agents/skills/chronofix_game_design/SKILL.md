---
name: ChronoFix Game Design
description: Complete game design document for ChronoFix, a 2D time-switching platformer built in Godot. Reference this skill when working on any ChronoFix game code, levels, mechanics, or story-related features.
---

# ChronoFix – Game Design Document

> *"Fixing the past. Save the present."*

## Overview

**ChronoFix** is a 2D time-switching platformer where players navigate levels by shifting between the **Past** and **Present** versions of the same environment.

**Engine:** Godot 4.6 | **Genre:** 2D Platformer | **Chapters:** 5

---

## Story

The protagonist — a robot connected to the **Chrono Core** — was caught in its catastrophic explosion. The blast merged two timeline versions, linking the protagonist to both past and present. Across 5 chapters the player recovers memories and prevents the disaster.

---

## Architecture

- **Root.gd** — Timeline switcher with shader-based transition (ripple + glitch + flash). Uses `process_mode` toggling via `_toggle()`.
- **Prototype movement.gd** — Player controller (`PlatformerController2D` extending `CharacterBody2D`). Player is in group `"player"`.
- **Levels** live in `Level 1/` folder: `level_past.tscn` and `level_present.tscn`.
- **Main.tscn** — Root scene. Has `Level handler` node (with Root.gd) containing `LevelPast` and `LevelPresent`.
- **Elevator** — `AnimatableBody2D` with `DetectionArea`. Checks `body.is_in_group("player")`.
- **Doors** — Teleport player between positions.

### Robot NPCs (Dual-Timeline)

**Present (Hostile) — `EnemyRobot.tscn` + `Scripts/enemy_robot.gd`:**
- `CharacterBody2D` that patrols within `patrol_distance`
- `RayCast2D` detects player (checks `is_in_group("player")`)
- Shoots `Bullet.tscn` projectiles on detection
- Bullets call `take_damage()` on the player

**Past (Friendly) — `FriendlyRobot.tscn` + `Scripts/friendly_robot.gd`:**
- `AnimatableBody2D` (same pattern as Elevator) — player rides on top
- Moves back and forth (horizontal or vertical via `axis` export)

**Placement:** EnemyRobot in `level_present.tscn`, FriendlyRobot at matching positions in `level_past.tscn`. Root.gd's `_toggle()` handles visibility/process_mode automatically.
