//basic transformation spell. Should work for most simple_animals

/spell/targeted/shapeshift
	name = "Shapeshift"
	desc = "This spell transforms the target into something else for a short while."

	school = "transmutation"

	charge_type = Sp_RECHARGE
	charge_max = 600

	duration = 0 //set to 0 for permanent.

	var/list/possible_transformations = list()
	var/list/newVars = list() //what the variables of the new created thing will be.

	cast_sound = 'sound/weapons/emitter2.ogg'
	var/revert_sound = 'sound/weapons/emitter.ogg' //the sound that plays when something gets turned back.
	var/share_damage = 1 //do we want the damage we take from our new form to move onto our real one? (Only counts for finite duration)
	var/drop_items = 0 //do we want to drop all our items when we transform?
	var/list/protected_roles = list() //which roles are immune to the spell

/mob/living
	var/datum/weakref/polymorph_origin

/proc/shapeshift(mob/living/M, mob/user, share_damage = 1, drop_items = 0, revert_sound = 'sound/weapons/emitter.ogg', list/possible_transformations = list(), duration = 0, list/newVars = list())
	if(M.buckled)
		M.buckled.unbuckle_mob()

	if (M.polymorph_origin)
		var/mob/living/origin = M.polymorph_origin.resolve()
		if (!origin)
			log_debug("shapeshift: target mob's origin no longer exists (deleted?), ignoring.")
			return

		origin.unshapeshift_from(M, revert_sound, share_damage)
		return

	var/new_mob = pick(possible_transformations)

	var/mob/living/trans = new new_mob(get_turf(M))
	trans.polymorph_origin = WEAKREF(M)
	for(var/varName in newVars) //stolen shamelessly from Conjure
		if(varName in trans.vars)
			trans.vars[varName] = newVars[varName]

	trans.name = "[trans.name] ([M])"
	if(istype(M,/mob/living/carbon/human) && drop_items)
		for(var/obj/item/I in M.contents)
			if(istype(I,/obj/item/organ))
				continue
			M.drop_from_inventory(I)
	if(M.mind)
		M.mind.transfer_to(trans)
	else
		trans.key = M.key
	var/atom/movable/overlay/effect = new /atom/movable/overlay(get_turf(M))
	effect.density = 0
	effect.anchored = 1
	effect.icon = 'icons/effects/effects.dmi'
	effect.layer = 3
	flick("summoning",effect)
	QDEL_IN(effect, 10)
	if(!duration)
		qdel(M)
	else
		M.forceMove(trans) //move inside the new dude to hide him.
		M.status_flags |= GODMODE //dont want him to die or breathe or do ANYTHING
		addtimer(CALLBACK(M, /mob/living/.proc/unshapeshift_from, trans, revert_sound, share_damage), duration)

	to_chat(trans, "You feel brief pain as your body twists and shifts into a new shape, but quickly forget as your mind is wiped away. You cannot remember your former life anymore, and your mind has become like that of \a [trans].")

/spell/targeted/shapeshift/cast(var/list/targets, mob/user)
	for(var/mob/living/M in targets)
		if (M.mind && M.mind.special_role in protected_roles)
			to_chat(user, "You can't shapeshift [M].")
			continue
		shapeshift(M, user, share_damage, drop_items, revert_sound, possible_transformations, duration, newVars)

/mob/living/proc/unshapeshift_from(mob/living/holder_mob, revert_sound, share_damage)
	if (QDELETED(holder_mob))
		log_debug("unshapeshift_from: holder mob was already deleted, aborting")
		return

	status_flags &= ~GODMODE //no more godmode.
	var/ratio = holder_mob.health / holder_mob.maxHealth
	if(ratio <= 0) //if he dead dont bother transforming them.
		qdel(src)
		return
	if(share_damage)
		adjustBruteLoss(maxHealth - round(maxHealth * (holder_mob.health / holder_mob.maxHealth))) //basically I want the % hp to be the same afterwards
	if(holder_mob.mind)
		holder_mob.mind.transfer_to(src)
	else
		key = holder_mob.key
	to_chat(src, "You suddenly find yourself a sentient being again, with vague memories of being \a [holder_mob] for a time.")
	playsound(get_turf(src), revert_sound, 50, 1)
	forceMove(get_turf(holder_mob))
	qdel(holder_mob)

/spell/targeted/shapeshift/baleful_polymorph
	name = "Baleful Polymorth"
	desc = "This spell transforms its target into a small animal temporarily. Those practiced in the high arcane arts can block this spell with ease, however."
	feedback = "BP"
	possible_transformations = list(/mob/living/simple_animal/lizard,/mob/living/simple_animal/rat,/mob/living/simple_animal/corgi, /mob/living/simple_animal/cat, /mob/living/simple_animal/slime, /mob/living/simple_animal/hostile/giant_spider, /mob/living/simple_animal/hostile/carp)

	share_damage = 0
	invocation = "Yo'balada!"
	invocation_type = SpI_SHOUT
	spell_flags = NEEDSCLOTHES | SELECTABLE
	range = 3
	duration = 600 //15 seconds.
	cooldown_min = 300 //30 seconds

	level_max = list(Sp_TOTAL = 4, Sp_SPEED = 1, Sp_POWER = 2)

	newVars = list("health" = 150, "maxHealth" = 150)

	protected_roles = list("Wizard")

	hud_state = "wiz_poly"

/spell/targeted/shapeshift/baleful_polymorph/empower_spell()
	if(!..())
		return 0

	duration += 150

	return "Your target will now stay in their polymorphed form for [duration/10] seconds."

/spell/targeted/shapeshift/corrupt_form
	name = "Corrupt Form"
	desc = "This spell shapes the wizard into a terrible, terrible beast."
	feedback = "CF"
	possible_transformations = list(/mob/living/simple_animal/hostile/faithless/wizard)

	invocation = "mutters something dark and twisted as their form begins to twist..."
	invocation_type = SpI_EMOTE
	spell_flags = INCLUDEUSER
	range = -1
	duration = 300
	charge_max = 1200
	cooldown_min = 600

	drop_items = 0
	share_damage = 0

	level_max = list(Sp_TOTAL = 3, Sp_SPEED = 2, Sp_POWER = 2)

	newVars = list("name" = "corrupted soul")

	hud_state = "wiz_corrupt"

/spell/targeted/shapeshift/corrupt_form/empower_spell()
	if(!..())
		return 0

	switch(spell_levels[Sp_POWER])
		if(1)
			duration += 100
			return "You will now stay corrupted for [duration/10] seconds."
		if(2)
			newVars = list("name" = "\proper corruption incarnate",
						"melee_damage_upper" = 45,
						"resistance" = 6,
						"health" = 650, //since it is foverer i guess it would be fine to turn them into some short of boss
						"maxHealth" = 650)
			duration = 0
			return "You revel in the corruption. There is no turning back."

