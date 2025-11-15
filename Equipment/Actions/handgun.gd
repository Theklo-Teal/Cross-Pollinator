extends CharacterAction


func setup():
	slot = Character.K.SECO
	title = "Generic Handgun"


func select_next():
	super()
	highlight_target()
func select_prev():
	super()
	highlight_target()

func highlight_target():
	Ses.mission_scene.clear_plots()
	var selected = Ses.mission_scene.get_node("%Sidebar").get_selected_target()
	if not selected == null:
		Ses.mission_scene.plot_on_grid([ selected.get_grid_coord() ], Color.RED)

func on_mouse_entered_character(chara:Character):
	var sidebar = Ses.mission_scene.get_node("%Sidebar")
	var tgt = sidebar.pool.values().find(chara)
	if tgt >= 0:
		sidebar.select_target(tgt)
		highlight_target()
