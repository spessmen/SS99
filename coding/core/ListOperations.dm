var/datum/ListOperations/ListOperations = new

/datum/ListOperations/proc/GetGridItem(list/list, y, x)
	if (y > 0 && list.len >= y)
		list = list[y]

		if (x > 0 && list.len >= x)
			return list[x]

	return null