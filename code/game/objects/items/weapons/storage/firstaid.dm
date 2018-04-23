/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 */

/*
 * First Aid Kits
 */
/obj/item/weapon/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
	var/empty = 0


/obj/item/weapon/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "It's an emergency medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"

	fill()
		..()
		if (empty) return

		icon_state = pick("ointment","firefirstaid")

		new /obj/item/device/healthanalyzer( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
		new /obj/item/stack/medical/ointment( src )
		new /obj/item/stack/medical/ointment( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src ) //Replaced ointment with these since they actually work --Errorage
		return


/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaid"

	fill()
		..()
		if (empty) return
		new /obj/item/stack/medical/bruise_pack(src)
		new /obj/item/stack/medical/bruise_pack(src)
		new /obj/item/stack/medical/bruise_pack(src)
		new /obj/item/stack/medical/ointment(src)
		new /obj/item/stack/medical/ointment(src)
		new /obj/item/device/healthanalyzer(src)
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
		return

/obj/item/weapon/storage/firstaid/toxin
	name = "toxin first aid"
	desc = "Used to treat when you have a high amoutn of toxins in your body."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"

	fill()
		..()
		if (empty) return

		icon_state = pick("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

		new /obj/item/weapon/reagent_containers/syringe/antitoxin( src )
		new /obj/item/weapon/reagent_containers/syringe/antitoxin( src )
		new /obj/item/weapon/reagent_containers/syringe/antitoxin( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/device/healthanalyzer( src )
		return

/obj/item/weapon/storage/firstaid/o2
	name = "oxygen deprivation first aid"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-o2"

	fill()
		..()
		if (empty) return
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/pill/dexalin( src )
		new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
		new /obj/item/weapon/reagent_containers/syringe/inaprovaline( src )
		new /obj/item/device/healthanalyzer( src )
		return

/obj/item/weapon/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "advfirstaid"
	item_state = "firstaid-advanced"

/obj/item/weapon/storage/firstaid/adv/fill()
	..()
	if (empty) return
	new /obj/item/weapon/reagent_containers/hypospray/autoinjector( src )
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/advanced/ointment(src)
	new /obj/item/stack/medical/splint(src)
	return

/obj/item/weapon/storage/firstaid/combat
	name = "combat medical kit"
	desc = "Contains advanced medical treatments."
	icon_state = "bezerk"
	item_state = "firstaid-advanced"

/obj/item/weapon/storage/firstaid/combat/fill()
	..()
	if (empty) return
	new /obj/item/weapon/storage/pill_bottle/bicaridine(src)
	new /obj/item/weapon/storage/pill_bottle/dermaline(src)
	new /obj/item/weapon/storage/pill_bottle/dexalin_plus(src)
	new /obj/item/weapon/storage/pill_bottle/dylovene(src)
	new /obj/item/weapon/storage/pill_bottle/tramadol(src)
	new /obj/item/weapon/storage/pill_bottle/spaceacillin(src)
	new /obj/item/stack/medical/splint(src)
	return

/obj/item/weapon/storage/firstaid/surgery
	name = "surgery kit"
	desc = "Contains tools for surgery. Has precise foam fitting for safe transport."
	icon_state = "purplefirstaid"
	item_state = "firstaid-advanced"

/obj/item/weapon/storage/firstaid/surgery/fill()
	..()
	if (empty) return
	new /obj/item/weapon/bonesetter(src)
	new /obj/item/weapon/cautery(src)
	new /obj/item/weapon/circular_saw(src)
	new /obj/item/weapon/hemostat(src)
	new /obj/item/weapon/retractor(src)
	new /obj/item/weapon/scalpel(src)
	new /obj/item/weapon/surgicaldrill(src)
	new /obj/item/weapon/bonegel(src)
	new /obj/item/weapon/FixOVein(src)
	new /obj/item/stack/medical/advanced/bruise_pack(src)

	make_exact_fit()

/obj/item/weapon/storage/firstaid/brute
	name = "brute aid kit"
	desc = "A NanoTrasen care package for moderately injured miners."
	icon_state = "brute"

/obj/item/weapon/storage/firstaid/brute/fill()
		..()
		if (empty) return
		new /obj/item/stack/medical/bruise_pack(src)
		new /obj/item/stack/medical/bruise_pack(src)
		new /obj/item/stack/medical/bruise_pack(src)
		new /obj/item/stack/medical/bruise_pack(src)
		new /obj/item/stack/medical/advanced/bruise_pack(src)
		new /obj/item/stack/medical/advanced/bruise_pack(src)
		return

/*
 * Pill Bottles
 */
/obj/item/weapon/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	w_class = 2.0
	can_hold = list(/obj/item/weapon/reagent_containers/pill,/obj/item/weapon/dice,/obj/item/weapon/paper)
	allow_quick_gather = 1
	use_to_pickup = 1
	use_sound = null
	max_storage_space = 16

/obj/item/weapon/storage/pill_bottle/antitox
	name = "bottle of Dylovene pills"
	desc = "Contains pills used to counter toxins."

	fill()
		..()
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )
		new /obj/item/weapon/reagent_containers/pill/antitox( src )

/obj/item/weapon/storage/pill_bottle/bicaridine
	name = "bottle of Bicaridine pills"
	desc = "Contains pills used to stabilize the severely injured."

/obj/item/weapon/storage/pill_bottle/bicaridine/fill()
    ..()
    new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
    new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
    new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
    new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
    new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
    new /obj/item/weapon/reagent_containers/pill/bicaridine(src)
    new /obj/item/weapon/reagent_containers/pill/bicaridine(src)

/obj/item/weapon/storage/pill_bottle/dexalin_plus
	name = "bottle of Dexalin Plus pills"
	desc = "Contains pills used to treat extreme cases of oxygen deprivation."

/obj/item/weapon/storage/pill_bottle/dexalin_plus/fill()
    ..()
    new /obj/item/weapon/reagent_containers/pill/dexalin_plus(src)
    new /obj/item/weapon/reagent_containers/pill/dexalin_plus(src)
    new /obj/item/weapon/reagent_containers/pill/dexalin_plus(src)
    new /obj/item/weapon/reagent_containers/pill/dexalin_plus(src)
    new /obj/item/weapon/reagent_containers/pill/dexalin_plus(src)
    new /obj/item/weapon/reagent_containers/pill/dexalin_plus(src)
    new /obj/item/weapon/reagent_containers/pill/dexalin_plus(src)

/obj/item/weapon/storage/pill_bottle/dermaline
	name = "bottle of Dermaline pills"
	desc = "Contains pills used to treat burn wounds."

/obj/item/weapon/storage/pill_bottle/dermaline/fill()
    ..()
    new /obj/item/weapon/reagent_containers/pill/dermaline(src)
    new /obj/item/weapon/reagent_containers/pill/dermaline(src)
    new /obj/item/weapon/reagent_containers/pill/dermaline(src)
    new /obj/item/weapon/reagent_containers/pill/dermaline(src)
    new /obj/item/weapon/reagent_containers/pill/dermaline(src)
    new /obj/item/weapon/reagent_containers/pill/dermaline(src)
    new /obj/item/weapon/reagent_containers/pill/dermaline(src)

/obj/item/weapon/storage/pill_bottle/dylovene
	name = "bottle of Dylovene pills"
	desc = "Contains pills used to treat toxic substances in the blood."

/obj/item/weapon/storage/pill_bottle/dylovene/fill()
    ..()
    new /obj/item/weapon/reagent_containers/pill/dylovene(src)
    new /obj/item/weapon/reagent_containers/pill/dylovene(src)
    new /obj/item/weapon/reagent_containers/pill/dylovene(src)
    new /obj/item/weapon/reagent_containers/pill/dylovene(src)
    new /obj/item/weapon/reagent_containers/pill/dylovene(src)
    new /obj/item/weapon/reagent_containers/pill/dylovene(src)
    new /obj/item/weapon/reagent_containers/pill/dylovene(src)

/obj/item/weapon/storage/pill_bottle/inaprovaline
	name = "bottle of Inaprovaline pills"
	desc = "Contains pills used to stabilize patients."

	fill()
		..()
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )
		new /obj/item/weapon/reagent_containers/pill/inaprovaline( src )

/obj/item/weapon/storage/pill_bottle/kelotane
	name = "bottle of kelotane pills"
	desc = "Contains pills used to treat burns."

	fill()
		..()
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )
		new /obj/item/weapon/reagent_containers/pill/kelotane( src )

/obj/item/weapon/storage/pill_bottle/spaceacillin
	name = "bottle of Spaceacillin pills"
	desc = "A theta-lactam antibiotic. Effective against many diseases likely to be encountered in space."

/obj/item/weapon/storage/pill_bottle/spaceacillin/fill()
    ..()
    new /obj/item/weapon/reagent_containers/pill/spaceacillin(src)
    new /obj/item/weapon/reagent_containers/pill/spaceacillin(src)
    new /obj/item/weapon/reagent_containers/pill/spaceacillin(src)
    new /obj/item/weapon/reagent_containers/pill/spaceacillin(src)
    new /obj/item/weapon/reagent_containers/pill/spaceacillin(src)
    new /obj/item/weapon/reagent_containers/pill/spaceacillin(src)
    new /obj/item/weapon/reagent_containers/pill/spaceacillin(src)

/obj/item/weapon/storage/pill_bottle/tramadol
	name = "bottle of Tramadol pills"
	desc = "Contains pills used to relieve pain."

	fill()
		..()
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )
		new /obj/item/weapon/reagent_containers/pill/tramadol( src )

/obj/item/weapon/storage/pill_bottle/escitalopram
	name = "bottle of Escitalopram pills"
	desc = "Contains pills used to stabilize a patient's mood."

	fill()
		..()
		new /obj/item/weapon/reagent_containers/pill/escitalopram( src )
		new /obj/item/weapon/reagent_containers/pill/escitalopram( src )
		new /obj/item/weapon/reagent_containers/pill/escitalopram( src )
		new /obj/item/weapon/reagent_containers/pill/escitalopram( src )
		new /obj/item/weapon/reagent_containers/pill/escitalopram( src )
		new /obj/item/weapon/reagent_containers/pill/escitalopram( src )
		new /obj/item/weapon/reagent_containers/pill/escitalopram( src )
		
/obj/item/weapon/storage/pill_bottle/Qospivanadate
	name = "bottle of Qospivanadate pills"
	desc = "Used to loosen one's mind."

	fill()
		..()
		new /obj/item/weapon/reagent_containers/pill/Qospivanadate( src )
		new /obj/item/weapon/reagent_containers/pill/Qospivanadate( src )
		new /obj/item/weapon/reagent_containers/pill/Qospivanadate( src )
		new /obj/item/weapon/reagent_containers/pill/Qospivanadate( src )
		new /obj/item/weapon/reagent_containers/pill/Qospivanadate( src )
		new /obj/item/weapon/reagent_containers/pill/Qospivanadate( src )
		new /obj/item/weapon/reagent_containers/pill/Qospivanadate( src )
		
/obj/item/weapon/storage/pill_bottle/Rocriodide
	name = "bottle of Rocriodide pills"
	desc = "Pacification through medication."

	fill()
		..()
		new /obj/item/weapon/reagent_containers/pill/Rocriodide( src )
		new /obj/item/weapon/reagent_containers/pill/Rocriodide( src )
		new /obj/item/weapon/reagent_containers/pill/Rocriodide( src )
		new /obj/item/weapon/reagent_containers/pill/Rocriodide( src )
		new /obj/item/weapon/reagent_containers/pill/Rocriodide( src )
		new /obj/item/weapon/reagent_containers/pill/Rocriodide( src )
		new /obj/item/weapon/reagent_containers/pill/Rocriodide( src )
