#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Copy Mail Deeplink
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ../images/mail.png
# @raycast.packageName Productivity

# Documentation:
# @raycast.description Copy the selected Mail message(s) as Markdown deeplinks
# @raycast.author egposadas
# @raycast.authorURL https://github.com/egposadas

on cleanSender(rawSender)
	-- "Ada Lovelace <ada@example.com>" ? "Ada Lovelace"
	-- "<ada@example.com>" ? "ada@example.com"
	set senderText to rawSender as text
	try
		if senderText contains "<" then
			set AppleScript's text item delimiters to "<"
			set namePart to text item 1 of senderText
			set AppleScript's text item delimiters to ""
			set namePart to my trimText(namePart)
			if namePart is not "" then return namePart
			set AppleScript's text item delimiters to ">"
			set emailPart to text item 1 of (text item 2 of senderText)
			set AppleScript's text item delimiters to ""
			return my trimText(emailPart)
		end if
	end try
	return senderText
end cleanSender

on trimText(theText)
	set theText to theText as text
	repeat while theText starts with " " or theText starts with tab
		if (count of theText) is 0 then exit repeat
		set theText to text 2 thru -1 of theText
	end repeat
	repeat while theText ends with " " or theText ends with tab
		if (count of theText) is 0 then exit repeat
		set theText to text 1 thru -2 of theText
	end repeat
	return theText
end trimText

tell application "System Events"
	set frontmostApp to name of first application process whose frontmost is true
end tell

if frontmostApp is not "Mail" then
	log "Bring Mail to the front and select a message first (frontmost was " & frontmostApp & ")"
	return
end if

# https://daringfireball.net/2007/12/message_urls_leopard_mail
tell application "Mail"
	set _sel to get selection
	if (count of _sel) is 0 then
		log "Select one or more messages in Mail first"
		return
	end if

	set _links to {}
	repeat with _msg in _sel
		set _messageURL to "message://%3c" & _msg's message id & "%3e"
		set _subject to _msg's subject
		set _sender to my cleanSender(_msg's sender)
		set _markdownLink to "[" & _sender & " Ñ " & _subject & "](" & _messageURL & ")"
		set end of _links to _markdownLink
	end repeat

	set oldTID to AppleScript's text item delimiters
	set AppleScript's text item delimiters to return
	set the clipboard to (_links as string)
	set AppleScript's text item delimiters to oldTID

	set linkCount to count of _links
	if linkCount is 1 then
		log "Copied 1 Mail deeplink"
	else
		log "Copied " & linkCount & " Mail deeplinks"
	end if
end tell
