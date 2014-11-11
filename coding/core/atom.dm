atom/Click()
	if (bounds_dist(usr, src) <= 8) src.onClick(arglist(args))

atom/proc/hiIsValidClient(datum/html_interface_client/hclient)
	return hclient.client && hclient.client.mob && bounds_dist(hclient.client.mob, src) <= 8

atom/proc/onClick()