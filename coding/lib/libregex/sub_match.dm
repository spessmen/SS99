sub_match
	var
		str
		start
		end
		matched

	New(str, start, end)
		src.str = str
		src.start = text2num(start)
		src.end = text2num(end)
		src.matched = (src.start != src.end)