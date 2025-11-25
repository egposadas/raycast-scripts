#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Mail Deeplink
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ??
# @raycast.packageName Mail

# Documentation:
# @raycast.description Copies the foreground Mail deeplink as Markdown
# @raycast.author Jesse Claven
# @raycast.authorURL https://github.com/jesse-c

tell application "System Events"
	set frontmostApp to name of first application process whose frontmost is true
end tell

if frontmostApp is "Mail" then
	# https://daringfireball.net/2007/12/message_urls_leopard_mail
	tell application "Mail"
		set _sel to get selection
		set _links to {}
		repeat with _msg in _sel
			set _messageURL to "message://%3c" & _msg's message id & "%3e"
			set _subject to _msg's subject
			set _sender to _msg's sender
			set _markdownLink to "[" & _sender & " - " & _subject & "](" & _messageURL & ")"
			set end of _links to _markdownLink
		end repeat
		set oldTID to AppleScript's text item delimiters
		set AppleScript's text item delimiters to return
		set the clipboard to (_links as string)
		set AppleScript's text item delimiters to oldTID

		log "Copied email deeplink"
	end tell
else
	log "Foreground app was " & frontmostApp & ", not Mail"
end if
