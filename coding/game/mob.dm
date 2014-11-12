/mob/proc/clientMove(dir) src.setVelocityAndDirection(8, dir)

/world/mob =/mob/living/humanoid/human

/mob/living/humanoid/human
	icon = 'icons/game/mob/human.dmi'
	icon_state = "body_m_s"
	pixel_x = -8
	bound_width = 16
	bound_height = 10
	step_size = 8

/mob/living/clientMove(dir)
	src.setVelocityAndDirection((src.hud.getMoveIntent() == "running" ? 1.75 : 1), dir)

/datum/hooks/mob/game_mob/onLogin(mob/mob, client/client)
	mob.loc = locate(17, 15, 1)