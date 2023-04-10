/obj/machinery/appliance/cooker/oven
	name = "oven"
	desc = "Cookies are ready, dear."
	desc_info = "Control-click this to change its temperature. Alt-click to open or close the oven door."
	icon_state = "ovenopen"
	cook_type = "baked"
	appliancetype = OVEN
	food_color = "#a34719"
	can_burn_food = TRUE
	active_power_usage = 6 KILOWATTS
	heating_power = 6000
	//Based on a double deck electric convection oven
	resistance = 10000 // Approx. 4 minutes.
	idle_power_usage = 2 KILOWATTS
	//uses ~30% power to stay warm
	optimal_power = 1.2
	light_x = 2
	max_contents = 5
	stat = POWEROFF	//Starts turned off
	var/open = FALSE // Start closed so people don't heat up ovens with the door open
	///Looping sound for the oven
	var/datum/looping_sound/oven/oven_loop

	starts_with = list(
		/obj/item/reagent_containers/cooking_container/oven,
		/obj/item/reagent_containers/cooking_container/oven,
		/obj/item/reagent_containers/cooking_container/oven,
		/obj/item/reagent_containers/cooking_container/oven,
		/obj/item/reagent_containers/cooking_container/oven
	)

	output_options = list(
		"Pizza" = /obj/item/reagent_containers/food/snacks/variable/pizza,
		"Bread" = /obj/item/reagent_containers/food/snacks/variable/bread,
		"Pie" = /obj/item/reagent_containers/food/snacks/variable/pie,
		"Cake" = /obj/item/reagent_containers/food/snacks/variable/cake,
		"Hot Pocket" = /obj/item/reagent_containers/food/snacks/variable/pocket,
		"Kebab" = /obj/item/reagent_containers/food/snacks/variable/kebab,
		"Waffles" = /obj/item/reagent_containers/food/snacks/variable/waffles,
		"Cookie" = /obj/item/reagent_containers/food/snacks/variable/cookie,
		"Donut" = /obj/item/reagent_containers/food/snacks/variable/donut
	)

/obj/machinery/appliance/cooker/oven/Initialize()
	. = ..()
	oven_loop = new(src)

/obj/machinery/appliance/cooker/oven/Destroy()
	QDEL_NULL(oven_loop)
	. = ..()

/obj/machinery/appliance/cooker/oven/update_icon()
	if (!open)
		icon_state = "ovenclosed"
	else
		icon_state = "ovenopen"
	cut_overlays()
	if (!stat)
		var/glow = image('icons/obj/cooking_machines.dmi', "oven_on", EFFECTS_ABOVE_LIGHTING_LAYER)
		add_overlay(glow)
	..()

/obj/machinery/appliance/cooker/oven/AltClick(var/mob/user)
	try_toggle_door(user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

/obj/machinery/appliance/cooker/oven/verb/toggle_door()
	set src in oview(1)
	set category = "Object"
	set name = "Open/close oven door"

	try_toggle_door(usr)

/obj/machinery/appliance/cooker/oven/proc/try_toggle_door(mob/user)
	if(use_check_and_message(user))
		return
	open = !open
	loss = (heating_power / resistance) * (0.5 + open)
	//When the oven door is opened, oven slowly loses heat
	if(open)
		playsound(src, 'sound/machines/oven/oven_close.ogg', 75, TRUE)
	else
		playsound(src, 'sound/machines/oven/oven_open.ogg', 75, TRUE)
	update_icon()
	update_baking_audio()

/obj/machinery/appliance/cooker/oven/proc/update_baking_audio()
	if(!oven_loop)
		return
	var/obj/item/reagent_containers/cooking_container/C
	if(!open && C?.contents.len)
		oven_loop.start()
	else
		oven_loop.stop()

/obj/machinery/appliance/cooker/oven/proc/manip(var/obj/item/I)
	// check if someone's trying to manipulate the machine

	return I.iscrowbar() || I.isscrewdriver() || istype(I, /obj/item/storage/part_replacer) || istype(I, /obj/item/stock_parts)

/obj/machinery/appliance/cooker/oven/can_insert(var/obj/item/I, var/mob/user)
	if (!open && !manip(I, user))
		to_chat(user, SPAN_WARNING("You can't put anything in while the door is closed!"))
		return FALSE

	else
		return ..()

/obj/machinery/appliance/cooker/oven/can_remove_items(var/mob/user)
	if (!open)
		to_chat(user, SPAN_WARNING("You can't take anything out while the door is closed!"))
		return FALSE
	return ..()


//Oven has lots of recipes and combine options. The chance for interference is high, so
//If a combine target is set the oven will do it instead of checking recipes
/obj/machinery/appliance/cooker/oven/finish_cooking(var/datum/cooking_item/CI)
	if(CI.combine_target)
		visible_message("<b>[src]</b> pings!", intent_message = PING_SOUND)
		combination_cook(CI)
		return
	..()

/obj/machinery/appliance/cooker/oven/adhomai
	name = "adhomian oven"
	desc = "A heavy and rustic adhomian oven. Perfect for a Tajaran grandma"
	icon_state = "adhomai_oven_open"

/obj/machinery/appliance/cooker/oven/adhomai/update_icon()
	if(!open)
		if(!stat)
			icon_state = "adhomai_ovenclosed_on"
		else
			icon_state = "adhomai_ovenclosed_off"
	else
		icon_state = "adhomai_oven_open"
