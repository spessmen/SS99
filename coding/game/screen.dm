mob/living/var/datum/game/hud/hud = new

/datum/hooks/mob/game_screen/onLogin(mob/living/mob, client/client)
	if (client && istype(mob))
		client.screen.Add(static_hud_elements)

		var/mob/living/user = client.mob

		if (istype(user) && user.hud.show_optional_items)
			client.screen.Add(static_hud_elements_opt)

		var/screen/hud/object

		object                      = locate(/screen/hud/gun_mode, client.screen)
		mob.hud.gun_mode.loc        = object

		object                      = locate(/screen/hud/action_intent, client.screen)
		mob.hud.action_intent.loc   = object

		object                      = locate(/screen/hud/move_intent, client.screen)
		mob.hud.move_intent.loc     = object

		object                      = locate(/screen/hud/damage_zone, client.screen)
		mob.hud.damage_zone.loc     = object

		object                      = locate(/screen/hud/inventory/r_hand, client.screen)
		mob.hud.inventory_r_hand.loc= object

		object                      = locate(/screen/hud/inventory/l_hand, client.screen)
		mob.hud.inventory_l_hand.loc= object

		client.images.Add(list(mob.hud.gun_mode, mob.hud.move_intent, mob.hud.action_intent, mob.hud.damage_zone, mob.hud.inventory_r_hand, mob.hud.inventory_l_hand))

/datum/hooks/mob/game_mob/onLogout(mob/living/mob, client/client)
	if (client && istype(mob))
		client.screen.Remove(static_hud_elements)
		client.screen.Remove(static_hud_elements_opt)

		client.images.Remove(list(mob.hud.gun_mode, mob.hud.move_intent, mob.hud.action_intent, mob.hud.damage_zone, mob.hud.inventory_r_hand, mob.hud.inventory_l_hand))

var/list/static_hud_elements = list(new/screen/hud/other,
									new/screen/hud/inventory/suit_storage, new/screen/hud/inventory/id, new/screen/hud/inventory/belt, new/screen/hud/inventory/back,
									new/screen/hud/inventory/r_hand, new/screen/hud/inventory/l_hand,
									new/screen/hud/button_swap, new/screen/hud/button_equip,
									new/screen/hud/inventory/storage1, new/screen/hud/inventory/storage2,
									new/screen/hud/move_intent, new/screen/hud/action_intent,
									new/screen/hud/damage_zone,
									new/screen/hud/button_throw, new/screen/hud/button_drop, new/screen/hud/button_resist, new/screen/hud/button_pull,
									new/screen/hud/gun_mode,
									new/screen/hud/stat_health, new/screen/hud/stat_internal, new/screen/hud/stat_nutrition, new/screen/hud/stat_temperature,
									new/screen/hud/stat_pressure, new/screen/hud/stat_oxygen, new/screen/hud/stat_fire, new/screen/hud/stat_toxin)

var/list/static_hud_elements_opt = list(new /screen/hud/inventory/optional/shoes,
									new/screen/hud/inventory/optional/internal_clothing, new/screen/hud/inventory/optional/external_clothing, new/screen/hud/inventory/optional/gloves,
									new/screen/hud/inventory/optional/eyes, new/screen/hud/inventory/optional/mask, new/screen/hud/inventory/optional/l_ear,
									new/screen/hud/inventory/optional/head, new/screen/hud/inventory/optional/r_ear)

/datum/game/hud/var
	show_optional_items = FALSE
	image
		gun_mode         = new/image(icon = 'icons/game/screen/hud/screen.dmi', icon_state = "gun0")
		action_intent    = new/image(icon = 'icons/game/screen/hud/screen_midnight.dmi', icon_state = "intent_help")
		move_intent      = new/image(icon = 'icons/game/screen/hud/screen_midnight.dmi', icon_state = "running")
		damage_zone      = new/image(icon = 'icons/game/screen/hud/zone_sel.dmi', icon_state = "chest")
		inventory_r_hand = new/image(icon = 'icons/game/screen/hud/screen_midnight.dmi', icon_state = "hand_active", dir = WEST)
		inventory_l_hand = new/image(icon = 'icons/game/screen/hud/screen_midnight.dmi', icon_state = "hand_inactive", dir = EAST)

/datum/game/hud/proc/isHoldHostage()   return src.gun_mode.icon_state == "gun1"
/datum/game/hud/proc/getActionIntent() return src.action_intent.icon_state
/datum/game/hud/proc/getMoveIntent()   return src.move_intent.icon_state
/datum/game/hud/proc/getDamageZone()   return src.damage_zone.icon_state
/datum/game/hud/proc/getActiveHand()   return src.inventory_r_hand.icon_state == "hand_active" ? "r_hand" : "l_hand"

/screen/hud/icon = 'icons/game/screen/hud/screen_midnight.dmi'

/screen/hud/other
	icon_state = "other"
	screen_loc = "1:6,1:5"

/screen/hud/other/onClick(mob/living/user, location, control, params)
	if (istype(user))
		user.hud.show_optional_items = !user.hud.show_optional_items

		user.client.screen.Remove(static_hud_elements_opt)

		if (user.hud.show_optional_items)
			user.client.screen.Add(static_hud_elements_opt)

/screen/hud/inventory/optional/shoes
	icon_state = "shoes"
	screen_loc = "2:8,1:5"

/screen/hud/inventory/optional/internal_clothing
	icon_state = "center"
	screen_loc = "1:6,2:7"

/screen/hud/inventory/optional/external_clothing
	icon_state = "equip"
	dir = SOUTH
	screen_loc = "2:7,2:7"

/screen/hud/inventory/optional/gloves
	icon_state = "gloves"
	screen_loc = "3:10,2:7"

/screen/hud/inventory/optional/eyes
	icon_state = "glasses"
	screen_loc = "1:6,3:9"

/screen/hud/inventory/optional/mask
	icon_state = "equip"
	dir = NORTH
	screen_loc = "2:8,3:9"

/screen/hud/inventory/optional/l_ear
	icon_state = "ears"
	screen_loc = "3:10,3:9"

/screen/hud/inventory/optional/head
	icon_state = "hair"
	screen_loc = "2:8,4:11"

/screen/hud/inventory/optional/r_ear
	icon_state = "ears"
	screen_loc = "3:10,4:11"

/screen/hud/inventory/suit_storage
	icon_state = "belt"
	dir = WEST
	screen_loc = "3:10,1:5"

/screen/hud/inventory/id
	icon_state = "id"
	screen_loc = "4:12,1:5"

/screen/hud/inventory/belt
	icon_state = "belt"
	screen_loc = "5:14,1:5"

/screen/hud/inventory/back
	icon_state = "back"
	screen_loc = "6:14,1:5"

/screen/hud/inventory/r_hand
	icon_state = "blank"
	screen_loc = "7:16,1:5"

/screen/hud/inventory/l_hand
	icon_state = "blank"
	screen_loc = "8:16,1:5"

/screen/hud/inventory/storage1
	icon_state = "pocket"
	screen_loc = "9:18,1:5"

/screen/hud/inventory/storage2
	icon_state = "pocket"
	screen_loc = "10:20,1:5"

/screen/hud/button_swap
	icon_state = "hand1"
	screen_loc = "7:16,2:5"

/screen/hud/button_swap/New()
	. = ..()

	// Workaround due to split of icons in hand1/hand2. WontFixYet because not modifying icons until everything is stable.
	src.overlays.Add(image(icon = src.icon, icon_state = "hand2", pixel_x = 32))

/screen/hud/button_swap/onClick(mob/living/user, location, control, params)
	if (istype(user))
		if (user.hud.inventory_r_hand.icon_state == "hand_active")
			user.hud.inventory_r_hand.icon_state = "hand_inactive"
			user.hud.inventory_l_hand.icon_state = "hand_active"
		else
			user.hud.inventory_r_hand.icon_state = "hand_active"
			user.hud.inventory_l_hand.icon_state = "hand_inactive"

/screen/hud/button_equip
	icon_state = "act_equip"
	screen_loc = "7:16,2:5"

/screen/hud/move_intent
	icon_state = "blank"
	screen_loc = "12:24,1:5"

/screen/hud/move_intent/onClick(mob/living/user, location, control, params)
	if (istype(user))
		if (user.hud.move_intent.icon_state == "running")
			user.hud.move_intent.icon_state = "walking"
		else
			user.hud.move_intent.icon_state = "running"

		if (user.velocity != 0)
			user.clientMove(user.dir)

/screen/hud/action_intent
	icon_state = "blank"
	screen_loc = "13:26,1:5"

/screen/hud/action_intent/onClick(mob/living/user, location, control, params)
	if (istype(user))
		params           = params2list(params)

		var/new_intent
		var/x            = text2num(params["icon-x"])
		var/y            = text2num(params["icon-y"])

		if (x <= 16)
			if (y <= 16) new_intent = "hurt"
			else         new_intent = "help"
		else
			if (y <= 16) new_intent = "grab"
			else         new_intent = "disarm"

		user.hud.action_intent.icon_state = "intent_[new_intent]"

/screen/hud/damage_zone
	icon_state = "zone_sel"
	screen_loc = "14:28,1:5"

/screen/hud/damage_zone/onClick(mob/living/user, location, control, params)
	if (istype(user))
		params           = params2list(params)

		var/new_zone
		var/x            = text2num(params["icon-x"])
		var/y            = text2num(params["icon-y"])

		if      (x >= 11 && x <= 20 && y >= 24 && y <= 29)
			if      (x >= 14 && x <= 16 && y >= 26 && y <= 27) new_zone = "eyes"
			else if (x >= 14 && x <= 16 && y >= 23 && y <= 24) new_zone = "mouth"
			else                                               new_zone = "head"
		else if (x >= 7  && x <= 10 && y >= 15 && y <= 21)     new_zone = "r_arm"
		else if (x >= 7  && x <= 10 && y >= 11 && y <  15)     new_zone = "r_hand"
		else if (x >  10 && x <  20 && y >= 13 && y <  24)     new_zone = "chest"
		else if (x >= 20 && x <= 24 && y >= 15 && y <= 21)     new_zone = "l_arm"
		else if (x >= 20 && x <= 24 && y >= 11 && y <  15)     new_zone = "l_hand"
		else if (x >= 11 && x <= 20 && y >= 10 && y <  13)     new_zone = "groin"
		else if (x >= 11 && x <= 14 && y >= 5  && y <  10)     new_zone = "r_leg"
		else if (x >= 9  && x <= 14 && y >= 1  && y <  5)      new_zone = "r_foot"
		else if (x >= 16 && x <= 20 && y >= 5  && y <  10)     new_zone = "l_leg"
		else if (x >= 16 && x <= 22 && y >= 1  && y <  5)      new_zone = "l_foot"

		if (new_zone)                                          user.hud.damage_zone.icon_state = new_zone

/screen/hud/button_throw
	icon_state = "act_throw_off"
	screen_loc = "14:28,2:7"

/screen/hud/button_drop
	icon_state = "act_drop"
	screen_loc = "14:28,2:7"

/screen/hud/button_resist
	icon_state = "act_resist"
	screen_loc = "13:26,2:7"

/screen/hud/button_pull
	icon_state = "pull0"
	screen_loc = "13:26,2:7"

/screen/hud/gun_mode
	icon = 'icons/game/screen/hud/screen.dmi'
	icon_state = "blank"
	screen_loc = "14:28,3:7"

/screen/hud/gun_mode/onClick(mob/living/user, location, control, params)
	if (istype(user))
		if (user.hud.gun_mode.icon_state == "gun1")
			user.hud.gun_mode.icon_state = "gun0"
		else
			user.hud.gun_mode.icon_state = "gun1"

/screen/hud/stat_health
	icon_state = "health0"
	screen_loc = "14:28,7:15"

/screen/hud/stat_internal
	icon_state = "internal0"
	screen_loc = "14:28,8:17"

/screen/hud/stat_nutrition
	icon_state = "blank"
	screen_loc = "14:28,5:11"

/screen/hud/stat_temperature
	icon_state = "blank"
	screen_loc = "14:28,6:13"

/screen/hud/stat_pressure
	icon_state = "blank"
	screen_loc = "14:28,10:21"

/screen/hud/stat_oxygen
	icon_state = "blank"
	screen_loc = "14:28,11:23"

/screen/hud/stat_fire
	icon_state = "blank"
	screen_loc = "14:28,12:25"

/screen/hud/stat_toxin
	icon_state = "blank"
	screen_loc = "14:28,13:27"