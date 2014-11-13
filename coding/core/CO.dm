var/datum/CommonOperations/CO = new

/datum/CommonOperations/var/CARDINAL_DIRECTIONS = list(NORTH, SOUTH, EAST, WEST)

/datum/CommonOperations/proc/sendFile(var/client/client, var/F)
	client.Export("##action=load_rsc", F)

/datum/CommonOperations/proc/getGridItem(list/list, y, x)
	if (y > 0 && list.len >= y)
		list = list[y]

		if (x > 0 && list.len >= x)
			return list[x]

	return null

/datum/CommonOperations/proc/startsWith(text, str, case_sensitive = 0)
	if (case_sensitive) return findtextEx(text, str, 1, lentext(str) + 1)
	else                return findtext(text, str, 1, lentext(str) + 1)

/datum/CommonOperations/proc/endsWith(text, str, case_sensitive = 0)
	if (case_sensitive) return findtextEx(text, str, -lentext(str))
	else                return findtext(text, str, -lentext(str))

/datum/CommonOperations/proc/reverseText(text)
	var/result = ""

	for (var/i = length(text), i > 0, i = i - 1)  result = result + ascii2text(text2ascii(text, i))

	return result

/datum/CommonOperations/proc/_left(text, pos)
	if (pos > 0)        return copytext(text, 1, pos)
	else                return text

/datum/CommonOperations/proc/_right(text, pos)
	if (pos > 0)        return copytext(text, pos + 1)
	else                return text

/datum/CommonOperations/proc/indexOf(text, str, case_sensitive = 0, start = 1)
	var/pos

	if (case_sensitive)  pos = findtextEx(text, str, start)
	else                 pos = findtext(text, str, start)

	return pos

/datum/CommonOperations/proc/toProperCase(text)
	if (length(text) > 1)
		var result           = uppertext(copytext(text, 1, 2))
		var old_pos          = 2
		var pos

		do
			pos              = CO.indexOf(text, " ", start = old_pos)

			if (pos > 0)
				result       = result + lowertext(copytext(text, old_pos, pos)) + uppertext(copytext(text, pos, pos + 2))
				old_pos      = pos + 2
			else
				result       = result + lowertext(copytext(text, old_pos))
		while (pos)

		return result
	else                     return uppertext(text)

/datum/CommonOperations/proc/left(text, str, case_sensitive = 0)            return _left(text, CO.indexOf(text, str, case_sensitive))
/datum/CommonOperations/proc/right(text, str, case_sensitive = 0)           return _right(text, CO.indexOf(text, str, case_sensitive))
/datum/CommonOperations/proc/backwardsLeft(text, str, case_sensitive = 0)   return _left(text, length(text) - CO.indexOf(CO.reverseText(text), str, case_sensitive) + 1)
/datum/CommonOperations/proc/backwardsRight(text, str, case_sensitive = 0)  return _right(text, length(text) - CO.indexOf(CO.reverseText(text), str, case_sensitive) + 1)

/datum/CommonOperations/var/const/NOMINATIVE = 1
/datum/CommonOperations/var/const/OBLIQUE = 2
/datum/CommonOperations/var/const/POSSESSIVE = 3
/datum/CommonOperations/var/const/REFLEXIVE = 4
/datum/CommonOperations/var/const/FORMAL = 5

/datum/CommonOperations/proc/getGenderPronoun(gender, subject = NOMINATIVE)
	switch (subject)
		if (NOMINATIVE)
			switch (gender)
				if (MALE)      return "He"
				if (FEMALE)    return "She"
				if (NEUTER)    return "It"
				if (PLURAL)    return "They"
		if (OBLIQUE)
			switch (gender)
				if (MALE)      return "Him"
				if (FEMALE)    return "Her"
				if (NEUTER)    return "It"
				if (PLURAL)    return "Them"
		if (POSSESSIVE)
			switch (gender)
				if (MALE)      return "His"
				if (FEMALE)    return "Hers"
				if (NEUTER)    return "Its"
				if (PLURAL)    return "Theirs"
		if (REFLEXIVE)
			switch (gender)
				if (MALE)      return "Himself"
				if (FEMALE)    return "Herself"
				if (NEUTER)    return "Itself"
				if (PLURAL)    return "Themselves"
		if (FORMAL)
			switch (gender)
				if (MALE)      return "Sir"
				if (FEMALE)    return "Ma'am"
				else           CRASH("Operation not supported: [gender] in combination with FORMAL subject.")

/*
	From Deadron.TextHandling
*/
/datum/CommonOperations/proc/replace(text, search_string, replacement_string, case_sensitive = 0)
	var/list/textList = CO.split(text, search_string, case_sensitive)
	return CO.join(textList, replacement_string)

/datum/CommonOperations/proc/split(text, separator, case_sensitive = 0)
	var/textlength      = lentext(text)
	var/separatorlength = lentext(separator)
	var/list/textList   = new /list()
	var/searchPosition  = 1
	var/findPosition    = 1
	var/buggyText
	while (1)
		findPosition = findtext(text, separator, searchPosition, 0)
		buggyText = copytext(text, searchPosition, findPosition)
		textList += "[buggyText]"

		searchPosition = findPosition + separatorlength
		if (findPosition == 0)
			return textList
		else
			if (searchPosition > textlength)
				textList += ""
				return textList

/datum/CommonOperations/proc/join(list/the_list, separator)
	var/total          = the_list.len
	if (total == 0)    return

	var/newText        = "[the_list[1]]"
	var/count
	for (count = 2, count <= total, count++)
		if (separator) newText += separator
		newText        += "[the_list[count]]"
	return newText

/datum/CommonOperations/proc/addZeros(n, amount)
	var/result = "[n]"

	while (length(result) < amount) result = "0[result]"

	return result

/datum/CommonOperations/proc/fixSpelling(text)
	var/result = "[text]"

	result     = regex_replace(result, "(?<!\\S)i(?!\\S)", "I")
	result     = regex_replace(result, "(?<!\\S)im(?!\\S)", "I'm")
	result     = regex_replace(result, "(?<!\\S)ur(?!\\S)", "You're")
	result     = regex_replace(result, "(?<!\\S)were(?!\\S)", "we're")
	result     = regex_replace(result, "(?<!\\S)rite(?!\\S)", "right")

	if (!result) result = text

	if (!(CO.endsWith(result, ".") || CO.endsWith(result, "?") || CO.endsWith(result, "!")))
		result = "[result]."

//	result     = TextOperations.Replace(result, " i ", " I ", 1)
//	result     = TextOperations.Replace(result, "i ", "I ", 1)

	return result

/datum/CommonOperations/proc/showMessage(recipients, message)
	if (recipients == world)
		for (var/client/client)           CO.showMessage(client, message)
	else if (istype(recipients, /list))
		var/client/client
		var/mob/mob

		for (var/recipient in recipients)
			client     = null

			if (istype(recipient, /mob))
				mob    = recipient
				client = mob.client
			else if (istype(recipient, /client))
				client = recipient

			if (client)                   CO.showMessage(client, message)
			else                          Log.warn("Unknown object passed to CO.showMessage: [recipient]")
	else if (istype(recipients, /mob))    recipients << message
	else if (istype(recipients, /client)) recipients << message
	else                                  Log.warn("Unknown object passed to CO.showMessage: [recipients]")

/datum/CommonOperations/proc/directionToString(dir)
	if (dir & NORTH) . = . + "north"
	if (dir & SOUTH) . = . + "south"
	if (dir & EAST)  . = . + "east"
	if (dir & WEST)  . = . + "west"

	return .