match_results
	var
		list/matches

	New(params)
		ASSERT(params)

		var/list/temp = params2list(params)
		if(temp)
			matches = new
			for(var/i in temp)
				var/list/L = temp[i]
				matches += new/sub_match(L[1], L[2], L[3])