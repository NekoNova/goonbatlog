# goonbatlog
A replacement for the base float text carbine addon

#1.6

* SCTmode added to the /gbl mode command
** This mode emulates the scrolling behavior found in Mik's and Parrot does not have a way to change scrolling speed (working on it)
* Fixed the last number sticking OOC bug

#Features:

* Allows flood control for events (i.e. don't show anything below x)
* Damage shown in this format. Icon (if one) damage / healing (target / caster)
* Provides easy reference for hits/misses/armor hits (how much armor was removed etc)
* Allows custom text, provided it's within carbine's font system (see below for method)
* Allows custom colors (see below for method)

#Commands (as of v1.5 7/22/2014):

* /gbl show  -- shows addon if hidden and hides if shown
* /gbl lock -- locks main window (hides background) if unlocked and unlocks if locked
* /gbl hiden -- hides notification bar if shown and shows if hidden
* /gbl direction -- cycles through frame growth styles
* /gbl mode -- cycles between display modes (normal, SCTmode, tankmode)
* /gbl showtime -- shows / hides the time on the event display
* /gbl showtarget -- shows / hides the target on the event display
* /gbl showtargetfull - shows the full target name if showtarget is enabled.
* /gbl dfonts -- displays a (scrollable) frame with all in game fonts and index number
* /gbl setfont ## -- sets font to corresponding number seen in /gbl dfonts
* /gbl flood (damage | heal) ## -- sets minimum number seen in event window (e.g. "gbl flood damage 200" would set minimum number for damage events to 200)
* /gbl frametest -- forces each frame to id itself
* /gbl flip (windowname) -- flips the text fill direction on the indicated windowname (incoming, outgoing, innotification, outnotification) on the waterfall style
* /gbl reset -- resets back to default settings (needed to be done if modifying base values on the fly)

#Planned features:

* Options GUI
* custom table for skill icons

#Known Issues:

* Icons not showing up -- the events sometimes don't pass icons, resulting in a black square instead of a skill icon

#Split Window:

* type /gbl lock to unlock main frame
* find the window you'd like to move, click and hold to move, click and hold bottom right corner to resize (the incoming and outoging windows have fixed ratios so the text doesn't look cramped (hopefully))
* type /gbl lock again to lock frames
* /reloadui to save

#How to change display options

* Change typeface (font)
** type "/gbl dfonts" in game to show scrollable frame with all in game fonts
** find font you'd like to use, not the number on the left (e.g. ## FONTNAME)
** type "/gbl setfont ##" where the ## is the number on the left of the font you chose
** type "/gbl dfonts" again to destroy font frame
** type /reloadui to save

* Change text colors
** Open gSettings via text editor or houston
** find the "textColors" table
** each color is made of 4 values, red, green, blue, opacity
** variable names indicate where they are used ("oh" outgoing healing, mcrit for crits during MoOs etc)
** save file and /reloadui if in game
