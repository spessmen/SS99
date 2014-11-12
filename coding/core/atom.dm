atom/Click(location,control,params)
	if (istype(src, /screen) || bounds_dist(usr, src) <= 8)
		var/list/arguments = args.Copy()
		arguments.Insert(1, usr)

		src.onClick(arglist(arguments))

atom/proc/hiIsValidClient(datum/html_interface_client/hclient)
	return hclient.client && hclient.client.mob && bounds_dist(hclient.client.mob, src) <= 8

atom/proc/onClick(mob/user, location,control,params)