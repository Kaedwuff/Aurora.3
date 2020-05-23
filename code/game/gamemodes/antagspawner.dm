// Helper proc to make sure no more than one active syndieborg exists at a time.
/proc/can_buy_syndieborg()
	for (var/mob/living/silicon/robot/R in silicon_mob_list)
		if (istype(R, /mob/living/silicon/robot/syndicate))
			return 0

	return 1

/obj/item/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/uses = 1

/obj/item/antag_spawner/proc/equip_antag(mob/target as mob)
	return

/obj/item/antag_spawner/borg_tele
	name = "syndicate cyborg teleporter"
	desc = "A single-use teleporter used to deploy a Syndicate Cyborg on the field. Due to budget restrictions, it is only possible to deploy a single cyborg at time."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"

/obj/item/antag_spawner/borg_tele/attack_self(mob/user)

	if(uses == 0)
		to_chat(usr, "This teleporter is out of uses.")
		return

	to_chat(user, "<span class='notice'>The syndicate robot teleporter is attempting to locate an available cyborg.</span>")
	var/datum/ghosttrap/ghost = get_ghost_trap("syndicate cyborg")
	uses--

	var/mob/living/silicon/robot/syndicate/F = new(get_turf(usr))
	spark(F, 4, alldirs)
	ghost.request_player(F,"An operative is requesting a syndicate cyborg.", 60 SECONDS)
	F.faction = usr.faction
	spawn(600)
		if(F)
			if(!F.ckey || !F.client)
				F.visible_message("With no working brain to keep \the [F] working, it is teleported back.")
				qdel(F)
				uses++

/obj/item/antag_spawner/kitspawner
	name = "generic telekit beacon"
	desc = "A single-use teleporter that can call a kit. This one is not tuned and does not function."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"

/obj/item/antag_spawner/kitspawner/espionage
	name = "espionage telekit beacon"
	desc = "A single-use telekit beacon that calls a variety of items intended for espionage. It is highly recommended you not activate this in a public area!"

/obj/item/antag_spawner/kitspawner/espionage/attack_self(mob/user)
	if(uses == 0)
		to_chat(usr, "This telekit beacon is out of uses.")
		return

	else
		to_chat(user, "<span class='notice'>The telekit beacon sparks and with a flash a number of items appear at your feet!</span>")
		new /obj/item/storage/box/syndie_kit/spy(src)
		new /obj/item/storage/box/syndie_kit/chameleon(src)
		new /obj/item/storage/box/syndie_kit/clerical(src)
		new /obj/item/device/encryptionkey/syndicate(src)
		new /obj/item/clothing/mask/gas/voice(src)
		new /obj/item/card/id/syndicate(src)
		new /obj/item/clothing/glasses/thermal/aviator(src)
		uses--

/obj/item/antag_spawner/kitspawner/stealth
	name = "stealth telekit beacon"
	desc = "A single-use telekit beacon that calls a variety of items intended for stealth. It is highly recommended you not activate this in a public area!"

/obj/item/antag_spawner/kitspawner/stealth/attack_self(mob/user)
	if(uses == 0)
		to_chat(usr, "This telekit beacon is out of uses.")
		return

	else
		to_chat(user, "<span class='notice'>The telekit beacon sparks and with a flash a number of items appear at your feet!</span>")
		new /obj/item/device/chameleon(src)
		new /obj/item/card/id/syndicate(src)
		new /obj/item/device/multitool/hacktool(src)
		new /obj/item/device/encryptionkey/syndicate(src)
		new /obj/item/clothing/mask/gas/voice(src)
		new /obj/item/device/radiojammer(src)
		new /obj/item/pen/reagent/paralysis(src)
		uses--

/obj/item/antag_spawner/powersink
	name = "power sink beacon"
	desc = "A device that teleports in a power sink. Use only when ready!"
	
/obj/item/antag_spawner/powersink/attack_self(mob/user)
	if(uses == 0)
		to_chat(usr, "This beacon is dead now.")
		return

	else
		to_chat(user, "<span class='notice'>The telekit beacon sparks and with a flash a power sink appears at your feet!</span>")
		new /obj/item/device/powersink(src)	
		uses--

/obj/item/antag_spawner/kitspawner/sabotage
	name = "sabotage telekit beacon"
	desc = "A single-use telekit beacon that calls a variety of items intended for sabotage. It is highly recommended you not activate this in a public area!"

/obj/item/antag_spawner/kitspawner/sabotage/attack_self(mob/user)
	if(uses == 0)
		to_chat(usr, "This telekit beacon is out of uses.")
		return

	else
		to_chat(user, "<span class='notice'>The telekit beacon sparks and with a flash a number of items appear at your feet!</span>")
		new /datum/uplink_item/item/tools/emag(src)
		new /obj/item/storage/box/syndie_kit/c4(src)
		new /obj/item/antag_spawner/powersink(src)
		new /obj/item/device/pin_extractor(src)
		uses--

/obj/item/antag_spawner/kitspawner/assassin
	name = "assassin telekit beacon"
	desc = "A single-use telekit beacon that calls a variety of items intended for assassination. It is highly recommended you not activate this in a public area!"

/obj/item/antag_spawner/kitspawner/assassin/attack_self(mob/user)
	if(uses == 0)
		to_chat(usr, "This telekit beacon is out of uses.")
		return

	else
		to_chat(user, "<span class='notice'>The telekit beacon sparks and with a flash a number of items appear at your feet!</span>")
		new /obj/item/storage/box/syndie_kit/g9mm(src)
		new /obj/item/melee/energy/sword(src)
		new /obj/item/storage/box/syndie_kit/g9mmpack(src)
		new /obj/item/pen/reagent/paralysis(src)
		new /obj/item/reagent_containers/pill/cyanide(src)
		uses--

/obj/item/antag_spawner/kitspawner/poison
	name = "poisoner telekit beacon"
	desc = "A single-use telekit beacon that calls a variety of items intended for poisoning. It is highly recommended you not activate this in a public area!"

/obj/item/antag_spawner/kitspawner/poison/attack_self(mob/user)
	if(uses == 0)
		to_chat(usr, "This telekit beacon is out of uses.")
		return

	else
		to_chat(user, "<span class='notice'>The telekit beacon sparks and with a flash a number of items appear at your feet!</span>")
		new /obj/item/storage/box/syndie_kit/g9mm(src)
		new /obj/item/melee/energy/sword(src)
		new /obj/item/storage/box/syndie_kit/g9mmpack(src)
		new /obj/item/pen/reagent/paralysis(src)
		new /obj/item/reagent_containers/pill/cyanide(src)
		uses--

