/datum/hooks/client/game_screen/onNew(client/client)
	client.screen.Add(new/screen/hud/other())

/screen/hud
	icon = 'icons/game/screen/hud/screen_midnight.dmi'
	other
		icon_state = "other"
		screen_loc = "1,1"
		onClick(mob/user, location, control, params)
			...