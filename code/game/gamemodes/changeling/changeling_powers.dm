var/global/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

/datum/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/list/datum/absorbed_dna/absorbed_dna = list()
	var/list/absorbed_languages = list()
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_recharge_rate = 0.5
	var/chem_storage = 50
	var/sting_range = 1
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 5
	var/purchasedpowers = list()
	var/mimicing = ""
	var/justate

/datum/changeling/New(var/gender=FEMALE)
	..()
	var/honorific = (gender == FEMALE) ? "Ms." : "Mr."
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[honorific] [changelingID]"
	else
		changelingID = "[honorific] [rand(1,999)]"

/datum/changeling/proc/regenerate()
	chem_charges = min(max(0, chem_charges+chem_recharge_rate), chem_storage)
	geneticdamage = max(0, geneticdamage-1)

/datum/changeling/proc/GetDNA(var/dna_owner)
	for(var/datum/absorbed_dna/DNA in absorbed_dna)
		if(dna_owner == DNA.name)
			return DNA

/mob/proc/absorbDNA(var/datum/absorbed_dna/newDNA)
	var/datum/changeling/changeling = null
	if(src.mind && src.mind.changeling)
		changeling = src.mind.changeling
	if(!changeling)
		return

	for(var/language in newDNA.languages)
		changeling.absorbed_languages |= language

	changeling_update_languages(changeling.absorbed_languages)

	if(!changeling.GetDNA(newDNA.name)) // Don't duplicate - I wonder if it's possible for it to still be a different DNA? DNA code could use a rewrite
		changeling.absorbed_dna += newDNA

//Restores our verbs. It will only restore verbs allowed during lesser (monkey) form if we are not human
/mob/proc/make_changeling()

	if(!mind)				return
	if(!mind.changeling)	mind.changeling = new /datum/changeling(gender)

	verbs += /datum/changeling/proc/EvolutionMenu
	add_language("Changeling")

	var/lesser_form = !ishuman(src)

	if(!powerinstances.len)
		for(var/P in powers)
			powerinstances += new P()

	// Code to auto-purchase free powers.
	for(var/datum/power/changeling/P in powerinstances)
		if(!P.genomecost) // Is it free?
			if(!(P in mind.changeling.purchasedpowers)) // Do we not have it already?
				mind.changeling.purchasePower(mind, P.name, 0)// Purchase it. Don't remake our verbs, we're doing it after this.

	for(var/datum/power/changeling/P in mind.changeling.purchasedpowers)
		if(P.isVerb)
			if(lesser_form && !P.allowduringlesserform)	continue
			if(!(P in src.verbs))
				src.verbs += P.verbpath

	for(var/language in languages)
		mind.changeling.absorbed_languages |= language

	var/mob/living/carbon/human/H = src
	if(istype(H))
		var/datum/absorbed_dna/newDNA = new(H.real_name, H.dna, H.species.get_cloning_variant(), H.languages)
		absorbDNA(newDNA)

	return 1

//removes our changeling verbs
/mob/proc/remove_changeling_powers()
	if(!mind || !mind.changeling)	return
	for(var/datum/power/changeling/P in mind.changeling.purchasedpowers)
		if(P.isVerb)
			verbs -= P.verbpath


//Helper proc. Does all the checks and stuff for us to avoid copypasta
/mob/proc/changeling_power(var/required_chems=0, var/required_dna=0, var/max_genetic_damage=100, var/max_stat=0)

	if(!src.mind)		return
	if(!iscarbon(src))	return

	var/datum/changeling/changeling = src.mind.changeling
	if(!changeling)
		to_chat(world.log, "[src] has the changeling_transform() verb but is not a changeling.")
		return

	if(src.stat > max_stat)
		to_chat(src, "<span class='warning'>We are incapacitated.</span>")
		return

	if(changeling.absorbed_dna.len < required_dna)
		to_chat(src, "<span class='warning'>We require at least [required_dna] samples of compatible DNA.</span>")
		return

	if(changeling.chem_charges < required_chems)
		to_chat(src, "<span class='warning'>We require at least [required_chems] units of chemicals to do that!</span>")
		return

	if(changeling.geneticdamage > max_genetic_damage)
		to_chat(src, "<span class='warning'>Our genomes are still reassembling. We need time to recover first.</span>")
		return

	return changeling


//Used to dump the languages from the changeling datum into the actual mob.
/mob/proc/changeling_update_languages(var/updated_languages)

	languages = list()
	for(var/language in updated_languages)
		languages += language

	//This isn't strictly necessary but just to be safe...
	add_language("Changeling")

	return

/mob/proc/changeling_absorb_dna()
	set category = "Changeling"
	set name = "Absorb DNA"

	var/datum/changeling/changeling = changeling_power(0,0,100)
	if(!changeling)	return

	if (last_succ + 60 SECONDS > world.time)
		to_chat(src, "<span class='warning'>We still processing our last DNA sample!</span>")
		return

	if(changeling.isabsorbing)
		to_chat(src, "<span class='warning'>We are already engaged in an absorption!</span>")
		return

	var/mob/living/carbon/human/T = input(usr, "Who are we extracting from?", "Target selection") in typecache_filter_list(oview(1), typecacheof(/mob/living/carbon/human))|null
	if (!T)
		return
	
	if(changeling.isabsorbing)
		to_chat(src, "<span class='warning'>We are already engaged in an absorption!</span>")
		return

	if(!istype(T))
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	if(T.species.flags & NO_SCAN)
		to_chat(src, "<span class='warning'>We do not know how to parse this creature's DNA!</span>")
		return

	if (T.mind?.changeling)
		to_chat(src, "<span class='warning'>This creature's DNA is already as complex as yours!</span>")
		return

	if(islesserform(T))
		to_chat(src, "<span class='warning'>This creature DNA is not compatible with our form!</span>")
		return

	if(HUSK in T.mutations)
		to_chat(src, "<span class='warning'>This creature's DNA is ruined beyond useability!</span>")
		return

	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=2, stage++)
		switch(stage)
			if(1)
				to_chat(src, "<span class='notice'>We will attempt to infest and steal [T]'s DNA. We must remain next to them.</span>")
			if(2)
				to_chat(src, "<span class='notice'>We subtly touch [T], and begin to infest their genetic structure.</span>")

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(src, T, 75))
			to_chat(src, "<span class='warning'>Our extraction of [T] has been interrupted!</span>")
			changeling.isabsorbing = 0
			return

	to_chat(src, "<span class='notice'>We have finished infesting [T], and withdraw from their flesh, taking some of their genetic data.</span>")

	if (T.cloneloss > 100)
		T.adjustCloneLoss (20)
		T.Drain()
		T.paralysis = 2
		to_chat(src, "<span class='notice'>We have stolen so much of [T]'s genetic structure that is irreversably corrupted, and can no longer be used for our purposes.</span>")
		src.visible_message("<span class='danger'>[T]'d flesh roils and twists, leaking blood and turning into an ashen grey monstrosity!</span>")
		to_chat(T, "<span class='danger'>You are wracked with agony collapse as your body twists and changes, turning you into a hideous monstrosity!</span>")
	else
		addtimer(CALLBACK(T, /mob/living/.proc/adjustCloneLoss, rand(10, 15)), rand(10, 15) SECONDS)
	justate = world.time

	changeling.chem_charges += 5
	changeling.geneticpoints += 1
	for(var/language in T.languages)
		if(!(language in changeling.absorbed_languages))
			changeling.absorbed_languages += language

	changeling_update_languages(changeling.absorbed_languages)

	var/datum/absorbed_dna/newDNA = new(T.real_name, T.dna, T.species.get_cloning_variant(), T.languages)
	absorbDNA(newDNA)

	changeling.absorbedcount++
	changeling.isabsorbing = 0

	admin_attack_log(usr, T, "extracted the DNA of", "had their DNA extracted by", "extracted DNA from")

	return 1

/mob/proc/changeling_extract_dna()
	set category = "Changeling"
	set name = "Full DNA Extraction"

	var/datum/changeling/changeling = changeling_power(0,0,100)
	if(!changeling)	return

	var/obj/item/weapon/grab/G = src.get_active_hand()
	if(!istype(G))
		to_chat(src, "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>")
		return

	var/mob/living/carbon/human/T = G.affecting
	if(!istype(T))
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	if(T.species.flags & NO_SCAN)
		to_chat(src, "<span class='warning'>We do not know how to parse this creature's DNA!</span>")
		return

	if(islesserform(T))
		to_chat(src, "<span class='warning'>This creature DNA is not compatible with our form!</span>")
		return

	if(HUSK in T.mutations)
		to_chat(src, "<span class='warning'>This creature's DNA is ruined beyond useability!</span>")
		return

	if(G.state != GRAB_KILL)
		to_chat(src, "<span class='warning'>We must have a tighter grip to absorb this creature.</span>")
		return

	if(changeling.isabsorbing)
		to_chat(src, "<span class='warning'>We are already absorbing!</span>")
		return

	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				to_chat(src, "<span class='notice'>This creature is compatible. We must hold still...</span>")
				src.visible_message("<span class='warning'>[src]'s skin begins to shift and squirm!</span>")
			if(2)
				to_chat(src, "<span class='notice'>We extend a proboscis.</span>")
				src.visible_message("<span class='warning'>[src] extends a proboscis!</span>")
				playsound(get_turf(src), 'sound/effects/lingextends.ogg', 50, 1)
			if(3)
				to_chat(src, "<span class='notice'>We stab [T] with the proboscis.</span>")
				src.visible_message("<span class='danger'>[src] stabs [T] with the proboscis!</span>")
				to_chat(T, "<span class='danger'>You feel a sharp stabbing pain!</span>")
				playsound(get_turf(src), 'sound/effects/lingstabs.ogg', 50, 1)
				var/obj/item/organ/external/affecting = T.get_organ(src.zone_sel.selecting)
				if(affecting.take_damage(39,0,1,0,"massive puncture wound"))
					T:UpdateDamageIcon()

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(src, T, 150))
			to_chat(src, "<span class='warning'>Our absorption of [T] has been interrupted!</span>")
			changeling.isabsorbing = 0
			return

	to_chat(src, "<span class='notice'>We have absorbed [T]!</span>")
	src.visible_message("<span class='danger'>[src] sucks the fluids from [T]!</span>")
	to_chat(T, "<span class='danger'>You have been absorbed by the changeling!</span>")
	playsound(get_turf(src), 'sound/effects/lingabsorbs.ogg', 50, 1)

	changeling.chem_charges += 50
	changeling.geneticpoints += 5

	//Steal all of their languages!
	for(var/language in T.languages)
		if(!(language in changeling.absorbed_languages))
			changeling.absorbed_languages += language

	changeling_update_languages(changeling.absorbed_languages)

	var/datum/absorbed_dna/newDNA = new(T.real_name, T.dna, T.species.get_cloning_variant(), T.languages)
	absorbDNA(newDNA)

	if(T.mind && T.mind.changeling)
		if(T.mind.changeling.absorbed_dna)
			for(var/datum/absorbed_dna/dna_data in T.mind.changeling.absorbed_dna)	//steal all their loot
				if(changeling.GetDNA(dna_data.name))
					continue
				absorbDNA(dna_data)
				changeling.absorbedcount++
			T.mind.changeling.absorbed_dna.len = 1

		if(T.mind.changeling.purchasedpowers)
			for(var/datum/power/changeling/Tp in T.mind.changeling.purchasedpowers)
				if(Tp in changeling.purchasedpowers)
					continue
				else
					changeling.purchasedpowers += Tp

					if(!Tp.isVerb)
						call(Tp.verbpath)()
					else
						src.make_changeling()

		changeling.chem_charges += T.mind.changeling.chem_charges
		changeling.geneticpoints += T.mind.changeling.geneticpoints
		T.mind.changeling.chem_charges = 0
		T.mind.changeling.geneticpoints = 0
		T.mind.changeling.absorbedcount = 0

	changeling.absorbedcount++
	changeling.isabsorbing = 0

	admin_attack_log(usr, T, "absorbed the DNA of", "had their DNA absorbed by", "lethally absorbed DNA from")

	T.death(0)
	T.Drain()
	return 1


//Change our DNA to that of somebody we've absorbed.
/mob/proc/changeling_transform()
	set category = "Changeling"
	set name = "Transform (5)"

	var/datum/changeling/changeling = changeling_power(5,1,0)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in changeling.absorbed_dna)
		names += "[DNA.name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	var/datum/absorbed_dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	changeling.chem_charges -= 5
	changeling.geneticdamage = 30

	handle_changeling_transform(chosen_dna)

	src.verbs -= /mob/proc/changeling_transform
	ADD_VERB_IN(src, 10, /mob/proc/changeling_transform)

	changeling_update_languages(changeling.absorbed_languages)

	feedback_add_details("changeling_powers","TR")
	return 1

/mob/proc/handle_changeling_transform(var/datum/absorbed_dna/chosen_dna)
	src.visible_message("<span class='warning'>[src] transforms!</span>")

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/newSpecies = chosen_dna.speciesName
		H.set_species(newSpecies,1)

		H.dna = chosen_dna.dna
		H.real_name = chosen_dna.name
		H.sync_organ_dna()
		H.flavor_text = ""
		domutcheck(H, null)
		H.UpdateAppearance()


//Transform into a monkey.
/mob/proc/changeling_lesser_form()
	set category = "Changeling"
	set name = "Lesser Form (1)"

	var/datum/changeling/changeling = changeling_power(1,0,0)
	if(!changeling)	return

	if(src.has_brain_worms())
		to_chat(src, "<span class='warning'>We cannot perform this ability at the present time!</span>")
		return

	var/mob/living/carbon/human/H = src

	if(!istype(H) || !H.species.primitive_form)
		to_chat(src, "<span class='warning'>We cannot perform this ability in this form!</span>")
		return

	changeling.chem_charges--
	H.visible_message("<span class='warning'>[H] transforms!</span>")
	changeling.geneticdamage = 30
	to_chat(H, "<span class='warning'>Our genes cry out!</span>")
	H = H.monkeyize()
	feedback_add_details("changeling_powers","LF")
	return 1

//Transform into a human
/mob/proc/changeling_lesser_transform()
	set category = "Changeling"
	set name = "Transform (1)"

	var/datum/changeling/changeling = changeling_power(1,1,0)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	var/mob/living/carbon/C = src

	changeling.chem_charges--
	C.remove_changeling_powers()
	C.visible_message("<span class='warning'>[C] transforms!</span>")
	C.dna = chosen_dna.Clone()

	var/list/implants = list()
	for (var/obj/item/weapon/implant/I in C) //Still preserving implants
		implants += I

	C.transforming = 1
	C.canmove = 0
	C.icon = null
	C.cut_overlays()
	C.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( C.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("monkey2h", animation)
	sleep(48)
	qdel(animation)

	for(var/obj/item/W in src)
		C.drop_from_inventory(W)

	var/mob/living/carbon/human/O = new /mob/living/carbon/human( src )
	if (C.dna.GetUIState(DNA_UI_GENDER))
		O.gender = FEMALE
	else
		O.gender = MALE
	O.dna = C.dna.Clone()
	C.dna = null
	O.real_name = chosen_dna.real_name

	for(var/obj/T in C)
		qdel(T)

	O.forceMove(C.loc)

	O.UpdateAppearance()
	domutcheck(O, null)
	O.setToxLoss(C.getToxLoss())
	O.adjustBruteLoss(C.getBruteLoss())
	O.setOxyLoss(C.getOxyLoss())
	O.adjustFireLoss(C.getFireLoss())
	O.stat = C.stat
	for (var/obj/item/weapon/implant/I in implants)
		I.forceMove(O)
		I.implanted = O

	C.mind.transfer_to(O)
	O.make_changeling()
	O.changeling_update_languages(changeling.absorbed_languages)

	feedback_add_details("changeling_powers","LFT")
	qdel(C)
	return 1


//Fake our own death and fully heal. You will appear to be dead but regenerate fully after a short delay.
/mob/proc/changeling_fakedeath()
	set category = "Changeling"
	set name = "Regenerative Stasis (20)"

	var/datum/changeling/changeling = changeling_power(20,1,100,DEAD)
	if(!changeling)	return

	var/mob/living/carbon/C = src
	if(!C.stat && alert("Are we sure we wish to fake our death?",,"Yes","No") == "No")//Confirmation for living changelings if they want to fake their death
		return
	to_chat(C, "<span class='notice'>We will attempt to regenerate our form.</span>")

	C.status_flags |= FAKEDEATH		//play dead
	C.update_canmove()
	C.remove_changeling_powers()

	C.emote("gasp")
	C.tod = worldtime2text()

	spawn(rand(800,2000))
		if(changeling_power(20,1,100,DEAD))
			// charge the changeling chemical cost for stasis
			changeling.chem_charges -= 20

			to_chat(C, "<span class='notice'><font size='5'>We are ready to rise.  Use the <b>Revive</b> verb when you are ready.</font></span>")
			C.verbs += /mob/proc/changeling_revive

	feedback_add_details("changeling_powers","FD")
	return 1

/mob/proc/changeling_revive()
	set category = "Changeling"
	set name = "Revive"

	var/mob/living/carbon/C = src
	// restore us to health
	C.revive(FALSE)
	// remove our fake death flag
	C.status_flags &= ~(FAKEDEATH)
	// let us move again
	C.update_canmove()
	// re-add out changeling powers
	C.make_changeling()
	// sending display messages
	to_chat(C, "<span class='notice'>We have regenerated.</span>")
	C.verbs -= /mob/proc/changeling_revive


//Boosts the range of your next sting attack by 1
/mob/proc/changeling_boost_range()
	set category = "Changeling"
	set name = "Ranged Sting (10)"
	set desc="Your next sting ability can be used against targets 2 squares away."

	var/datum/changeling/changeling = changeling_power(10,0,100)
	if(!changeling)	return 0
	changeling.chem_charges -= 10
	to_chat(src, "<span class='notice'>Your throat adjusts to launch the sting.</span>")
	changeling.sting_range = 2
	src.verbs -= /mob/proc/changeling_boost_range
	ADD_VERB_IN(src, 5, /mob/proc/changeling_boost_range)
	feedback_add_details("changeling_powers","RS")
	return 1


//Recover from stuns.
/mob/proc/changeling_unstun()
	set category = "Changeling"
	set name = "Epinephrine Sacs (45)"
	set desc = "Removes all stuns"

	var/datum/changeling/changeling = changeling_power(45,0,100,UNCONSCIOUS)
	if(!changeling)	return 0
	changeling.chem_charges -= 45

	var/mob/living/carbon/human/C = src
	C.stat = 0
	C.SetParalysis(0)
	C.SetStunned(0)
	C.SetWeakened(0)
	C.lying = 0
	C.update_canmove()

	src.verbs -= /mob/proc/changeling_unstun
	ADD_VERB_IN(src, 5, /mob/proc/changeling_unstun)
	feedback_add_details("changeling_powers","UNS")
	return 1


//Speeds up chemical regeneration
/mob/proc/changeling_fastchemical()
	src.mind.changeling.chem_recharge_rate *= 2
	return 1

//Increases macimum chemical storage
/mob/proc/changeling_engorgedglands()
	src.mind.changeling.chem_storage += 25
	return 1


//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/mob/proc/changeling_digitalcamo()
	set category = "Changeling"
	set name = "Toggle Digital Camoflague"
	set desc = "The AI can no longer track us, but we will look different if examined.  Has a constant cost while active."

	var/datum/changeling/changeling = changeling_power()
	if(!changeling)	return 0

	var/mob/living/carbon/human/C = src
	if(C.digitalcamo)	to_chat(C, "<span class='notice'>We return to normal.</span>")
	else				to_chat(C, "<span class='notice'>We distort our form to prevent AI-tracking.</span>")
	C.digitalcamo = !C.digitalcamo

	spawn(0)
		while(C && C.digitalcamo && C.mind && C.mind.changeling)
			C.mind.changeling.chem_charges = max(C.mind.changeling.chem_charges - 1, 0)
			sleep(40)

	src.verbs -= /mob/proc/changeling_digitalcamo
	ADD_VERB_IN(src, 5, /mob/proc/changeling_digitalcamo)
	feedback_add_details("changeling_powers","CAM")
	return 1


//Starts healing you every second for 10 seconds. Can be used whilst unconscious.
/mob/proc/changeling_rapidregen()
	set category = "Changeling"
	set name = "Rapid Regeneration (30)"
	set desc = "Begins rapidly regenerating.  Does not effect stuns or chemicals."

	var/datum/changeling/changeling = changeling_power(30,0,100,UNCONSCIOUS)
	if(!changeling)	return 0
	src.mind.changeling.chem_charges -= 30

	var/mob/living/carbon/human/C = src
	spawn(0)
		for(var/i = 0, i<10,i++)
			if(C)
				C.adjustBruteLoss(-10)
				C.adjustToxLoss(-10)
				C.adjustOxyLoss(-10)
				C.adjustFireLoss(-10)
				sleep(10)

	src.verbs -= /mob/proc/changeling_rapidregen
	ADD_VERB_IN(src, 5, /mob/proc/changeling_rapidregen)
	feedback_add_details("changeling_powers","RR")
	return 1

// HIVE MIND UPLOAD/DOWNLOAD DNA

var/list/datum/absorbed_dna/hivemind_bank = list()

/mob/proc/changeling_hiveupload()
	set category = "Changeling"
	set name = "Hive Channel (10)"
	set desc = "Allows you to channel DNA in the airwaves to allow other changelings to absorb it."

	var/datum/changeling/changeling = changeling_power(10,1)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in changeling.absorbed_dna)
		var/valid = 1
		for(var/datum/absorbed_dna/DNB in hivemind_bank)
			if(DNA.name == DNB.name)
				valid = 0
				break
		if(valid)
			names += DNA.name

	if(names.len <= 0)
		to_chat(src, "<span class='notice'>The airwaves already have all of our DNA.</span>")
		return

	var/S = input("Select a DNA to channel: ", "Channel DNA", null) as null|anything in names
	if(!S)	return

	var/datum/absorbed_dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	changeling.chem_charges -= 10
	hivemind_bank += chosen_dna
	to_chat(src, "<span class='notice'>We channel the DNA of [S] to the air.</span>")
	feedback_add_details("changeling_powers","HU")
	return 1

/mob/proc/changeling_hivedownload()
	set category = "Changeling"
	set name = "Hive Absorb (20)"
	set desc = "Allows you to absorb DNA that is being channeled in the airwaves."

	var/datum/changeling/changeling = changeling_power(20,1)
	if(!changeling)	return

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in hivemind_bank)
		if(!(changeling.GetDNA(DNA.name)))
			names[DNA.name] = DNA

	if(names.len <= 0)
		to_chat(src, "<span class='notice'>There's no new DNA to absorb from the air.</span>")
		return

	var/S = input("Select a DNA absorb from the air: ", "Absorb DNA", null) as null|anything in names
	if(!S)	return
	var/datum/dna/chosen_dna = names[S]
	if(!chosen_dna)
		return

	changeling.chem_charges -= 20
	absorbDNA(chosen_dna)
	to_chat(src, "<span class='notice'>We absorb the DNA of [S] from the air.</span>")
	feedback_add_details("changeling_powers","HD")
	return 1

// Fake Voice

/mob/proc/changeling_mimicvoice()
	set category = "Changeling"
	set name = "Mimic Voice"
	set desc = "Shape our vocal glands to form a voice of someone we choose. We cannot regenerate chemicals when mimicing."


	var/datum/changeling/changeling = changeling_power()
	if(!changeling)	return

	if(changeling.mimicing)
		changeling.mimicing = ""
		to_chat(src, "<span class='notice'>We return our vocal glands to their original location.</span>")
		return

	var/mimic_voice = sanitize(input(usr, "Enter a name to mimic.", "Mimic Voice", null), MAX_NAME_LEN)
	if(!mimic_voice)
		return

	changeling.mimicing = mimic_voice

	to_chat(src, "<span class='notice'>We shape our glands to take the voice of <b>[mimic_voice]</b>, this will stop us from regenerating chemicals while active.</span>")
	to_chat(src, "<span class='notice'>Use this power again to return to our original voice and reproduce chemicals again.</span>")

	feedback_add_details("changeling_powers","MV")

	spawn(0)
		while(src && src.mind && src.mind.changeling && src.mind.changeling.mimicing)
			src.mind.changeling.chem_charges = max(src.mind.changeling.chem_charges - 1, 0)
			sleep(40)
		if(src && src.mind && src.mind.changeling)
			src.mind.changeling.mimicing = ""
	//////////
	//STINGS//	//They get a pretty header because there's just so fucking many of them ;_;
	//////////

/mob/proc/sting_can_reach(mob/M as mob, sting_range = 1)
	if(M.loc == src.loc)
		return 1 //target and source are in the same thing
	if(!isturf(src.loc) || !isturf(M.loc))
		to_chat(src, "<span class='warning'>We cannot reach \the [M] with a sting!</span>")
		return 0 //One is inside, the other is outside something.
	// Maximum queued turfs set to 25; I don't *think* anything raises sting_range above 2, but if it does the 25 may need raising
	if(!AStar(src.loc, M.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, max_nodes=25, max_node_depth=sting_range)) //If we can't find a path, fail
		to_chat(src, "<span class='warning'>We cannot find a path to sting \the [M] by!</span>")
		return 0
	return 1

//Handles the general sting code to reduce on copypasta (seeming as somebody decided to make SO MANY dumb abilities)
/mob/proc/changeling_sting(var/required_chems=0, var/verb_path, var/stealthy = 0)
	var/datum/changeling/changeling = changeling_power(required_chems)
	if(!changeling)								return

	var/list/victims = list()
	for(var/mob/living/carbon/C in oview(changeling.sting_range))
		victims += C
	var/mob/living/carbon/T = input(src, "Who will we sting?") as null|anything in victims

	if(!T) return
	if(!(T in view(changeling.sting_range))) return
	if(!sting_can_reach(T, changeling.sting_range)) return
	if(!changeling_power(required_chems)) return
	if(T.isSynthetic())
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	changeling.chem_charges -= required_chems
	changeling.sting_range = 1
	src.verbs -= verb_path
	ADD_VERB_IN(src, 10, verb_path)

	if(stealthy == 1)
		to_chat(src, "<span class='notice'>We stealthily sting [T].</span>")
		to_chat(T, "<span class='warning'>You feel a tiny prick.</span>")
	else
		src.visible_message(pick("<span class='danger'>[src]'s eyes balloon and burst out in a welter of blood, burrowing into [T]!</span>",
								"<span class='danger'>[src]'s arm rapidly shifts into a giant scorpion-stinger and stabs into [T]!</span>",
								"<span class='danger'>[src]'s throat lengthens and twists before vomitting a chunky red spew all over [T]!</span>",
								"<span class='danger'>[src]'s tongue stretches an impossible length and stabs into [T]!</span>",
								"<span class='danger'>[src] sneezes a cloud of shrieking spiders at [T]!</span>",
								"<span class='danger'>[src] erupts a grotesque tail and impales [T]!</span>",
								"<span class='danger'>[src]'s chin skin bulges and tears, launching a bone-dart at [T]!</span>"))

	if(!T.mind || !T.mind.changeling)	return T	//T will be affected by the sting

	return


/mob/proc/changeling_lsdsting()
	set category = "Changeling"
	set name = "Hallucination Sting (15)"
	set desc = "Causes terror in the target."

	var/mob/living/carbon/T = changeling_sting(15,/mob/proc/changeling_lsdsting,stealthy = 1)
	if(!T)	return 0
	spawn(rand(300,600))
		if(T)	T.hallucination += 400
	feedback_add_details("changeling_powers","HS")
	return 1

/mob/proc/changeling_silence_sting()
	set category = "Changeling"
	set name = "Silence sting (10)"
	set desc="Sting target"

	var/mob/living/carbon/T = changeling_sting(10,/mob/proc/changeling_silence_sting,stealthy = 1)
	if(!T)	return 0
	T.silent += 30
	feedback_add_details("changeling_powers","SS")
	return 1

/mob/proc/changeling_blind_sting()
	set category = "Changeling"
	set name = "Blind sting (20)"
	set desc="Sting target"

	var/mob/living/carbon/T = changeling_sting(20,/mob/proc/changeling_blind_sting,stealthy = 0)
	if(!T)	return 0
	to_chat(T, "<span class='danger'>Your eyes burn horrificly!</span>")
	T.disabilities |= NEARSIGHTED
	spawn(300)	T.disabilities &= ~NEARSIGHTED
	T.eye_blind = 10
	T.eye_blurry = 20
	feedback_add_details("changeling_powers","BS")
	return 1

/mob/proc/changeling_deaf_sting()
	set category = "Changeling"
	set name = "Deaf sting (5)"
	set desc="Sting target:"

	var/mob/living/carbon/T = changeling_sting(5,/mob/proc/changeling_deaf_sting,stealthy = 0)
	if(!T)	return 0
	to_chat(T, "<span class='danger'>Your ears pop and begin ringing loudly!</span>")
	T.sdisabilities |= DEAF
	spawn(300)	T.sdisabilities &= ~DEAF
	feedback_add_details("changeling_powers","DS")
	return 1

/mob/proc/changeling_paralysis_sting()
	set category = "Changeling"
	set name = "Paralysis sting (30)"
	set desc="Sting target"

	var/mob/living/carbon/T = changeling_sting(30,/mob/proc/changeling_paralysis_sting,stealthy = 0)
	if(!T)	return 0
	to_chat(T, "<span class='danger'>Your muscles begin to painfully tighten.</span>")
	T.Weaken(20)
	feedback_add_details("changeling_powers","PS")
	return 1

/mob/proc/changeling_transformation_sting()
	set category = "Changeling"
	set name = "Transformation sting (40)"
	set desc="Sting target"

	var/datum/changeling/changeling = changeling_power(40)
	if(!changeling)	return 0

	var/list/names = list()
	for(var/datum/absorbed_dna/DNA in changeling.absorbed_dna)
		names += "[DNA.name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)	return

	var/datum/absorbed_dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	var/mob/living/carbon/T = changeling_sting(40,/mob/proc/changeling_transformation_sting,stealthy = 1)
	if(!T)	return 0
	if((HUSK in T.mutations) || (!ishuman(T) && !issmall(T)))
		to_chat(src, "<span class='warning'>Our sting appears ineffective against its DNA.</span>")
		return 0

	if(islesserform(T))
		to_chat(src, "<span class='warning'>Our sting appears ineffective against this creature.</span>")
		return 0

	if(T.stat != DEAD)
		to_chat(src, "<span class='warning'>Our sting can only be used against dead targets.</span>")
		return 0

	T.handle_changeling_transform(chosen_dna)

	feedback_add_details("changeling_powers","TS")
	return 1

/mob/proc/changeling_unfat_sting()
	set category = "Changeling"
	set name = "Unfat sting (5)"
	set desc = "Sting target"

	var/mob/living/carbon/T = changeling_sting(5,/mob/proc/changeling_unfat_sting,stealthy = 1)
	if(!T)	return 0
	to_chat(T, "<span class='danger'>you feel a small prick as stomach churns violently and you become to feel skinnier.</span>")
	T.adjustNutritionLoss(100)
	feedback_add_details("changeling_powers","US")
	return 1

/mob/proc/changeling_DEATHsting()
	set category = "Changeling"
	set name = "Death Sting (40)"
	set desc = "Causes spasms onto death."

	var/mob/living/carbon/T = changeling_sting(40,/mob/proc/changeling_DEATHsting,stealthy = 0)
	if(!T)	return 0
	to_chat(T, "<span class='danger'>You feel a small prick and your chest becomes tight.</span>")
	T.silent = 10
	T.Paralyse(10)
	T.make_jittery(1000)
	if(T.reagents)	T.reagents.add_reagent("cyanide", 5)
	feedback_add_details("changeling_powers","DTHS")
	return 1

/mob/proc/changeling_extract_dna_sting()
	set category = "Changeling"
	set name = "Extract DNA Sting (40)"
	set desc="Stealthily sting a target to extract their DNA."

	var/datum/changeling/changeling = null
	if(src.mind && src.mind.changeling)
		changeling = src.mind.changeling
	if(!changeling)
		return 0

	var/mob/living/carbon/human/T = changeling_sting(40, /mob/proc/changeling_extract_dna_sting,stealthy = 1)
	if(!T)	return 0

	var/datum/absorbed_dna/newDNA = new(T.real_name, T.dna, T.species.get_cloning_variant(), T.languages)
	absorbDNA(newDNA)

	feedback_add_details("changeling_powers","ED")
	return 1

/mob/proc/armblades()
	set category = "Changeling"
	set name = "Form Blades (20)"
	set desc="Rupture the flesh and mend the bone of your hand into a deadly blade."

	var/datum/changeling/changeling = changeling_power(20,0,0)
	if(!changeling)	return 0
	src.mind.changeling.chem_charges -= 20

	var/mob/living/M = src

	if(M.l_hand && M.r_hand)
		to_chat(M, "<span class='danger'>Your hands are full.</span>")
		return

	var/obj/item/weapon/melee/arm_blade/blade = new(M)
	blade.creator = M
	M.put_in_hands(blade)
	playsound(loc, 'sound/weapons/bloodyslice.ogg', 30, 1)
	src.visible_message("<span class='danger'>A grotesque blade forms around [M]\'s arm!</span>",
							"<span class='danger'>Our arm twists and mutates, transforming it into a deadly blade.</span>",
							"<span class='danger'>You hear organic matter ripping and tearing!</span>")

/mob/proc/changeling_shield()
	set category = "Changeling"
	set name = "Form Shield (20)"
	set desc="Bend the flesh and bone of your hand into a grotesque shield."

	var/datum/changeling/changeling = changeling_power(20,0,0)
	if(!changeling)	return 0
	src.mind.changeling.chem_charges -= 20

	var/mob/living/M = src

	if(M.l_hand && M.r_hand)
		to_chat(M, "<span class='danger'>Your hands are full.</span>")
		return

	var/obj/item/weapon/shield/riot/changeling/shield = new(M)
	shield.creator = M
	M.put_in_hands(shield)
	playsound(loc, 'sound/effects/blobattack.ogg', 30, 1)
	src.visible_message("<span class='danger'>The end of [M]\'s hand inflates rapidly, forming a huge shield-like mass!</span>",
							"<span class='warning'>We inflate our hand into a robust shield.</span>",
							"<span class='warning'>You hear organic matter ripping and tearing!</span>")

/mob/proc/horror_form()
	set category = "Changeling"
	set name = "Horror Form (40)"
	set desc = "Tear apart your human disguise, revealing your true form."

	var/datum/changeling/changeling = changeling_power(40,0,0)
	if(!changeling)	return 0
	src.mind.changeling.chem_charges -= 40

	var/mob/living/M = src

	M.visible_message("<span class='danger'>[M] writhes and contorts, their body expanding to inhuman proportions!</span>", \
						"<span class='danger'>We begin our transformation to our true form!</span>")
	if(!do_after(src,60))
		M.visible_message("<span class='danger'>[M]'s transformation abruptly reverts itself!</span>", \
							"<span class='danger'>Our transformation has been interrupted!</span>")
		return 0

	M.visible_message("<span class='danger'>[M] grows into an abomination and lets out an awful scream!</span>")
	playsound(loc, 'sound/effects/greaterling.ogg', 100, 1)

	var/mob/living/simple_animal/hostile/true_changeling/ling = new (get_turf(M))

	if(istype(M,/mob/living/carbon/human))
		for(var/obj/item/I in M.contents)
			if(isorgan(I))
				continue
			M.drop_from_inventory(I)

	if(M.mind)
		M.mind.transfer_to(ling)
	else
		ling.key = M.key
	var/atom/movable/overlay/effect = new /atom/movable/overlay(get_turf(M))
	effect.density = 0
	effect.anchored = 1
	effect.icon = 'icons/effects/effects.dmi'
	effect.layer = 3
	flick("summoning",effect)
	QDEL_IN(effect, 10)
	M.forceMove(ling) //move inside the new dude to hide him.
	M.status_flags |= GODMODE //dont want him to die or breathe or do ANYTHING
	addtimer(CALLBACK(src, .proc/revert_horror_form,ling), 10 MINUTES)

/mob/proc/revert_horror_form(var/mob/living/ling)
	if(QDELETED(ling))
		return
	src.status_flags &= ~GODMODE //no more godmode.
	if(ling.mind)
		ling.mind.transfer_to(src)
	else
		src.key = ling.key
	playsound(get_turf(src),'sound/effects/blobattack.ogg',50,1)
	src.forceMove(get_turf(ling))
	qdel(ling)

//dna related datum

/datum/absorbed_dna
	var/name
	var/datum/dna/dna
	var/speciesName
	var/list/languages

/datum/absorbed_dna/New(var/newName, var/newDNA, var/newSpecies, var/newLanguages)
	..()
	name = newName
	dna = newDNA
	speciesName = newSpecies
	languages = newLanguages
