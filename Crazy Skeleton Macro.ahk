;this code is very easy to read
;not easy to write tho
;fuck ahk
;you can easily change or make your own shit here
;its open sourced :innocent:

CoordMode "Pixel", "Screen"


;VARIABLES
global canusemisc := false
global canstart := true
global ability := 0
global defaultws := 25
global plrws := 25
global walkpattern := 0
global misccd := 0
global dead := false
global shiftlocked := false
global weebhookurl := " "
global userid := 0
global url := " "
global discordid := " "
global pslink := " "
global paused := false
global rejoined := false ;change for testing purposes rn


;newTime := oldTime * (oldSpeed / newSpeed)
;ARRAYS
basesleeps := [
	1000,
	2000,
	3000,
	4000,
	5000,
	6000,
	7000,
	8000,
	9000,
	10000,
	1500,
	2500,
	3500,
	500
]
global realsleeps := basesleeps.Clone()


snakestart := [
	["s", 2],
	["a", 3],
	["w", 1]
]
snakeloop := [
	["d", 4],
	["w", 1],
	["a", 4],
	["w", 1]
]

snakeloopback := [
	["s", 1],
	["d", 4],
	["s", 1],
	["a", 4]
]

leftrightstart := [
	["s", 4],
]

leftrightloop := [
	["a", 3],
	["d", 6],
	["a", 3]
]


getcloverspattern := [
	[ ["s","space",],10],
	[ ["s","space",],3],
	[ ["w"],		 13],
    [ ["d"],		 12],
    [ ["e"],		 1],
	[ ["e"],		 1],
	[ ["e"],		 1],
	[ ["e"],		 1],
	[ ["w"],		 7],
	[ ["a"],		 2],
	[ ["w"],		 2],
	[ ["e"],		 1],
	[ ["e"],		 1],
	[ ["e"],		 1],
	[ ["e"],		 1],
	[ ["e"],		 1],
	[ ["e"],		 1],
	[ ["e"],		 1],
	[ ["e"],		 1],
]



;FUNCTIONS

;thank god for ai cause this is really not easy
;its the same in C i agree but bro i hate this syntax

LoadSettings() {
	global ability, plrws, walkpattern, canusemisc, misccd, url, discordid, pslink

	if !FileExist("data.txt")
		return

	raw := FileRead("data.txt")
	lines := StrSplit(raw, "`n")

	for line in lines {
		if line = ""
			continue

		parts := StrSplit(line, "=",, 2)
		key := Trim(parts[1])
		val := Trim(parts[2])

		if IsNumber(val)
			val := Integer(val)

		switch key {
			case "ability":       ability := val
			case "plrws":         plrws := val
			case "walkpattern":   walkpattern := val
			case "canusemisc":    canusemisc := val
			case "misccd":        misccd := val
			case "url":           url := val
			case "discordid":     discordid := val
			case "pslink":        pslink := val
        }
    }
}



SaveSettings() {
    global ability, plrws, walkpattern, canusemisc, misccd, url, discordid, pslink

    text :=
    (
    "ability = " ability "`n"
    "plrws = " plrws "`n"
    "walkpattern = " walkpattern "`n"
    "canusemisc = " canusemisc "`n"
    "misccd = " misccd "`n"
	"url =  " url "`n"
	"discordid = " discordid "`n"
	"pslink = " pslink
    )

    FileDelete("data.txt") ; optional but clean
    FileAppend(text, "data.txt")
}



ColorClose(color, target, tol) {
    r1 := (color >> 16) & 0xFF
    g1 := (color >> 8)  & 0xFF
    b1 :=  color        & 0xFF

    r2 := (target >> 16) & 0xFF
    g2 := (target >> 8)  & 0xFF
    b2 :=  target        & 0xFF

    return (Abs(r1 - r2) <= tol)
        && (Abs(g1 - g2) <= tol)
        && (Abs(b1 - b2) <= tol)
}


PingDiscord(msg) {
    q := Chr(34)
	global url

    body := "{" q "content" q ":" q msg q "}"

    http := ComObject("WinHttp.WinHttpRequest.5.1")
    http.Open("POST", url, false)
    http.SetRequestHeader("Content-Type", "application/json")
    http.Send(body)
}

deathcheck(*){
	color := PixelGetColor(11, 919, "RGB")
	if (color = 0xff0000){
		global dead := true
	}
}
engisanscheck(*){
	color := PixelGetColor(955, 135, "RGB")
	if (color = 0xB37804){
		PingDiscord("<@" discordid "> FOUND ENGI")
		pausemacro()
	}
}

rocheck(*){
	color := PixelGetColor(955, 135, "RGB")
	if (color = 0x5b3d00){
		PingDiscord("<@" discordid "> FOUND RO")
		pausemacro()
	}
}

virus404check(*) {
	;wont be used, too innacurate
	;psure u cant even get a sans that knocks u back if the tree spawns
	;idk i'll see
    target := 0xBC1213

    for outer, _ in [1,2,3] {
        for inner, _ in [1,2,3] {

            x := 665 + (outer - 2)
            y := 1025 + (inner - 2)

            color := PixelGetColor(x, y, "RGB")

            if (ColorClose(color, target, 15)) {
                PingDiscord("<@" discordid "> FOUND VIRUS404")
                pausemacro() ; or ExitApp
                return
            }
        }
    }
}


exitroblox(*){
	try ProcessClose("RobloxPlayerBeta.exe")
	RunWait("taskkill /IM RobloxPlayerBeta.exe /F", , "Hide")
}

robloxrunning(*){
	return ProcessExist("RobloxPlayerBeta.exe")
}

disconnected(*) {
	global pslink
	global shiftlocked := false

	pausemacro()
	exitroblox()
	Sleep 500

	;wait until roblox fully closes
	while robloxrunning() {
		Sleep 300
	}

	Run(pslink)

	;wait for roblox to start
	while !robloxrunning() {
		Sleep 300
	}

	;wait for roblox window to exist
	WinWait("Roblox", , 10)

	;give roblox focus
	WinActivate("Roblox")
	Sleep 200
	WinWaitActive("Roblox", , 5)

	;force windowed mode
	Send "!{Enter}"
	Sleep 500
	Send "!{Enter}"

	;loading sleep
	Sleep 5000

	global rejoined := true
	resumemacro()
	start()
}

disconnectcheck(*){
	coords := [
		[765, 420],
		[1145, 420],
		[765, 640],
		[1145, 640]
	]

	colors := []

	for i, pos in coords {
		x := pos[1]
		y := pos[2]
		color := PixelGetColor(x, y, "RGB")
		if (color = 0x393b3d){
			disconnected()
		}
	}

}

parasitefreshcheck(*){
	color := PixelGetColor(25, 950, "RGB")
	if (color = 0xAA00FF){
		PingDiscord("<@" discordid ">  FOUND PARASITIC FRESH")
		pausemacro()
	}
}

grusanscheck(*){
	color := PixelGetColor(955, 135, "RGB")
	if (color = 0xc6c6c6){
		PingDiscord("<@" discordid ">  FOUND GRU")
		pausemacro()
	}
}

raresanscheck(*){
	engisanscheck()
	rocheck()
	parasitefreshcheck()
	;virus404check()
}

pausemacro() {
	global paused := true
	;stop timers
	stopm1ing()
	stopmisc()

	;release movement keys
	Send "{w up}{a up}{s up}{d up}"

	;MsgBox "Macro paused, rare sans found"
}

;why? idk
resumemacro(*){
	global paused := false
}

;this fucking function became a check for everything
;i honestly dont care since it works
spamm1(*){
	disconnectcheck()
	deathcheck()
	raresanscheck()
	Send "{LButton}"
	Switch ability{
	Case 1:
		Send "{y}"
		Send "{z}"
	Case 2:
		Send "{x}"
	Case 3:
		Send "{x}"
		Send "{y}"
		Send "{z}"
	}
}

startm1ing(*){ ;also will spam abilities
	SetTimer spamm1, 10
}

stopm1ing(*){
	SetTimer spamm1, 0
}

usemisc(*){
	Send "{2}"
	Send "{LButton}"
	Sleep 100
	Send "{LButton}"
	Sleep 100
	Send "{1}"
}

stopmisc(*){
	SetTimer usemisc, 0
}

infmisc(*){
	SetTimer usemisc, misccd
}


reset(*){
	stopm1ing
	Send "{Esc}"
	Sleep 100
	Send "{r}"
	Sleep 100
	Send "{Enter}"
}

LoadSettings()

changeallsleeps() {
	global realsleeps, plrws

	ratio := 25 / plrws

	for i, v in realsleeps {
		realsleeps[i] := v * ratio
	}
}

miscchanged(ctrl, info) { ;ctrl ig is true or false wether its checked or na
	misccdedit.Visible := !misccdedit.Visible
	misctext.Visible := !misctext.Visible
	misccdud.Visible := !misccdud.Visible
    if (ctrl.Value = 1) {
        global canusemisc := true
    }else{
        global canusemisc := false
	}
	SaveSettings()
}

abddchanged(ctrl, info){
	global ability := ctrl.Value ;stores the index of the chosen option
	SaveSettings()
	;MsgBox "Picked:" ability
}

plrwschanged(ctrl, info){
	if (!IsNumber(ctrl.Value)){
		return
	}
	global plrws := ctrl.Value
	if (plrws >= 1){
		changeallsleeps()
	}
	SaveSettings()
}

misccdchanged(ctrl, info){
	global misccd := ctrl.Value*1000
	SaveSettings()
	;MsgBox misccd
}

patternchanged(ctrl, info){
	global walkpattern := ctrl.Value
	SaveSettings() ; so stupid
	;MsgBox "Pattern:" walkpattern
}

webhookurlchanged(ctrl, info){
	global url := ctrl.Value
	SaveSettings()
}

discordideditchanged(ctrl, info){
    global discordid := ctrl.Value
    SaveSettings()
}

pslinkchanged(ctrl, info){
	global pslink := ctrl.Value
	SaveSettings()
}


leftrightpattern(*){
	if (shiftlocked = false){
		stopm1ing()
		Send "{Shift}"

		global shiftlocked := true
	}
	Sleep 1000
	DllCall("mouse_event", "UInt", 0x0001, "UInt", 0, "UInt", -180, "UInt", 0, "UPtr", 0)
	; literally how was i meant to  find this out without ai
	; aids bro aids
	startm1ing()
	if (canusemisc){
		infmisc()
	}
	startm1ing()
	runpattern(leftrightstart)
	while true{
		if (dead = true){
			Sleep 10000
			start()
			break
		}
		if (!runpattern(leftrightloop)){
			if (paused){
				return
			}
			Sleep 9000
			start()
			break
		}
	}
}

snakepattern(*){
	startm1ing()
	if (canusemisc){
		infmisc()
	}
	snakecompleted := 0
	while true{
		if (snakecompleted = 2){
			snakecompleted := 0
			runpattern(snakeloopback)
			runpattern(snakeloopback)
			continue
		}
		if (!runpattern(snakeloop)){
			if (paused){
				return
			}
			snakecompleted := 0
			Sleep 9000
			start()
			break
			
		}
		snakecompleted++
	}
}

runpattern(pattern) {
    global realsleeps, paused, dead

    for step in pattern {

        if (paused or dead)
            return false

        keys := step[1]
        dur  := step[2]

        ; convert single key → array
        if !IsObject(keys)
            keys := [keys]

        ; press all keys
        for k in keys
            Send "{" k " down}"

        Sleep realsleeps[dur]

        ; release all keys
        for k in keys
            Send "{" k " up}"
    }

    return true
}





declineupdate(*){
	;im unsure if it changes per update
	;if it does i'll add a pixel check
	MouseMove(1450, 240, 0)
	Sleep 200
	Click 2
	Sleep 200
	MouseMove(1452, 242, 0)
	Sleep 200
	Click 2
}

getclovers(*){
	declineupdate()
	runpattern(getcloverspattern)
	global rejoined := false
	reset()
	Sleep 10000
	start()
}





start(*){
	changeallsleeps()
	if (rejoined = true){
		getclovers()
	}
	Send "{1}"
	global dead := false
	Switch walkpattern{
		Case 1:
			runpattern(snakestart)
			snakepattern()
		Case 2:
			leftrightpattern()
		Case 3:
			;x pattern
	}
}



;GUI
mygui := Gui()
exitbtn := mygui.Add("Button", "x250 y270 w50 h30", "Exit")
exitbtn.OnEvent("Click", (*) => ExitApp())


keybinds(*){
	MsgBox "k to start, v to exit, n to resume macro"
}
startbtn := mygui.Add("Button", "x125 y20 w50 h30", "keybinds")
startbtn.OnEvent("Click", keybinds)

abilitydropdown := mygui.Add("DropDownList", "x80 y50 w50", ["Y", "X", "XY", "NIL"])
abilitydropdown.OnEvent("Change", abddchanged)
abilitytext := mygui.Add("Text", "x20 y55" ,"Ability usage:")

updownedit := mygui.Add("Edit", "x80 y80", "0")
;updownws := mygui.Add("UpDown", "Range1-70", 25)
updowntext := mygui.Add("Text", "x20 y80", "Walkspeed:")
updownedit.OnEvent("LoseFocus", plrwschanged)

miscbox := mygui.Add("Checkbox","x20 y100 w70", "Use misc?")
miscbox.OnEvent("Click", miscchanged)
misctext := mygui.Add("Text", "x100 y105", "Cooldown:")
misccdedit := mygui.Add("Edit", "x160 y100", "0")
misccdud := mygui.Add("UpDown", "Range1-70", 1)
misccdedit.Visible := false
misctext.Visible := false
misccdud.Visible := false
misccdedit.OnEvent("LoseFocus", misccdchanged)

patterntext := mygui.Add("Text", "x20 y120", "Walk pattern:")
patterndropdown := mygui.Add("DropDownList", "x80 y120 w100", ["snake", "leftright", "Nil"])
patterndropdown.OnEvent("Change", patternchanged)

webhooktext := mygui.Add("Text", "x20 y153", "Webhook:")
webhookedit := mygui.Add("Edit", "x80 y150 w200", "nil")
webhookedit.OnEvent("LoseFocus", webhookurlchanged)

discordidtext := mygui.Add("Text", "x20 y185", "Discordid:")
discordidedit := mygui.Add("Edit", "x80 y180 w200", 0)
discordidedit.OnEvent("LoseFocus", discordideditchanged)

pslinktext := mygui.Add("Text", "x20 y210", "Private server:")
pslinkedit := mygui.Add("Edit", "x90 y205 w200", "nil")
pslinkedit.OnEvent("LoseFocus", pslinkchanged)

abilitydropdown.Value := ability
updownedit.Value := plrws
miscbox.Value := canusemisc
misccdedit.Value := misccd / 1000
patterndropdown.Value := walkpattern
webhookedit.Value := url
discordidedit.Value := discordid
pslinkedit.Value := pslink


mygui.Show("w300 h300")


k::{
	start()
}

v::{
	ExitApp()
}

n::{
	resumemacro()
} 
