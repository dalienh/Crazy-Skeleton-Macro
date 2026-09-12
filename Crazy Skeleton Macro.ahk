;this code is very easy to read
;not easy to write tho
;fuck ahk
;you can easily change or make your own shit here
;its open sourced :innocent:

;VARIABLES
global canusemisc := false
global canstart := true
global ability := 0
global defaultws := 25
global plrws := 25
global walkpattern := 0
global misccd := 0
global dead := 0
global shiftlocked := false
global weebhookurl := " "
global userid := 0
global url := " "
global discordid := " "

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
	10000
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



;FUNCTIONS

;thank god for ai cause this is really not easy
;its the same in C i agree but bro i hate this syntax
LoadSettings() {
    global ability, plrws, walkpattern, canusemisc, misccd, url, discordid

    if !FileExist("data.txt")
        return

    raw := FileRead("data.txt")
    lines := StrSplit(raw, "`n")

    for line in lines {
        if line = ""
            continue

        parts := StrSplit(line, "=")
        key := Trim(parts[1])
        val := Trim(parts[2])

        ; numeric values
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
        }
    }
}


SaveSettings() {
    global ability, plrws, walkpattern, canusemisc, misccd, url, discordid

    text :=
    (
    "ability = " ability "`n"
    "plrws = " plrws "`n"
    "walkpattern = " walkpattern "`n"
    "canusemisc = " canusemisc "`n"
    "misccd = " misccd "`n"
	"url =  " url "`n"
	"discordid = " discordid
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
	color := PixelGetColor(11, 919)
	if (color = 0xff0000){
		global dead := true
	}
}
engisanscheck(*){
	color := PixelGetColor(955, 135)
	if (color = 0xB37804){
		PingDiscord("<@" discordid "> FOUND ENGI")
	}
}

rocheck(*){
	color := PixelGetColor(955, 135)
	if (color = 0x5b3d00){
		PingDiscord("<@" discordid "> FOUND RO")

	}
}

virus404check(*){
	color := PixelGetColor(900, 777)
	target := 0xBC1213
	if (ColorClose(color, target, 10)){
		PingDiscord(discordid " FOUND VIRUS404")
	}
}

parasitefreshcheck(*){
	color := PixelGetColor(25, 950)
	if (color = 0xAA00FF){
		PingDiscord(discordid " FOUND PARASITIC FRESH")
	}
}

raresanscheck(*){
	engisanscheck()
	rocheck()
	parasitefreshcheck()
	virus404check()
}

spamm1(*){
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
changeallsleeps(*){
	for i, v in basesleeps{
		realsleeps[i] := v * (defaultws/plrws)
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
		if (dead = 1){
			Sleep 10000
			start()
			break
		}
		if (!runpattern(leftrightloop)){
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
			snakecompleted := 0
			Sleep 9000
			start()
			break
			
		}
		snakecompleted++
	}
}

runpattern(pattern) {
	global realsleeps, dead

	for _, step in pattern {
        if (dead = 1)
            return false

        key := step[1]
        dur := step[2]

        Send "{" key " down}"
        Sleep realsleeps[dur]   ; original math untouched
        Send "{" key " up}"
    }
    return true
}





start(*){
	Send "{1}"
	global dead := 0
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
	MsgBox "k to start v to exit"
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

abilitydropdown.Value := ability
updownedit.Value := plrws
miscbox.Value := canusemisc
misccdedit.Value := misccd / 1000
patterndropdown.Value := walkpattern
webhookedit.Value := url
discordidedit.Value := discordid


mygui.Show("w300 h300")


k::{
	start()
}

v::{
	ExitApp()
}