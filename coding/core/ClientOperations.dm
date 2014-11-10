var/datum/ClientOperations/ClientOperations = new

/datum/ClientOperations/proc/SendFile(var/client/client, var/F)
	client.Export("##action=load_rsc", F)