FunctionsTab.classes.Push(FireMode)

class FireMode {
    static className := "Fire Mode"
    static enabled := 0
    static key := "LButton"
    static values = ["Auto", "Burst 3", "Semi-auto"]

    include() {
        this.label := FunctionsTab.controls.fireModeLabel
        this.button := FunctionsTab.controls.fireModeButton
        this.slider := FunctionsTab.controls.fireModeSlider
        this.valueLabel := FunctionsTab.controls.fireModeValueLabel

        this.bindFunctions()
    }

    bindFunctions() {
        function := ObjBindMethod(this, "tutorial")
        guiControl, % Gui.hwnd ":+g", % this.label.getHwnd(), % function

        function := ObjBindMethod(this, "setState", "toggle")
        guiControl, % Gui.hwnd ":+g", % this.button.getHwnd(), % function

        function := ObjBindMethod(this, "refreshValueLabel")
        guiControl, % Gui.hwnd ":+g", % this.slider.getHwnd(), % function
    }

    tutorial() {
        new Message("The ""Fire Mode"" Function can set special fire rates (for istance if you want a semi-automatic weapon to be full automatic)`nDue to these functions not be in sync with Warframe some inconsistent behaviour may be noticed (like the burst 3 mode won't work well on weapons with slow rate of fire")
    }

    setState(state := "toggle") {
        switch state {
            case "on", case 1:      this.enabled := 1
            case "off", case 0:     this.enabled := 0
            case "toggle":          this.enabled := !this.enabled

            default:
                this.enabled := 0  
        }
        iniWrite, % this.enabled, % Ini.path, % this.className, % "enabled"

        this.button.setText(this.enabled ? "On" : "Off")
        this.valueLabel.setTextColor(this.enabled ? " cDefault " : " cGray ")

        this.refreshValueLabel()
        this.setAction()
    }

    refreshValueLabel() {
        this.valueLabel.setText(this.values[this.slider.getContent()])
        iniWrite, % this.slider.getContent(), % Ini.path, % this.className, % "value"
    }

    setAction() {
        if (this.enabled = 0) {
            this.disableHotkeys()
        } else {
            this.enableHotkeys()
        }

        iniWrite, % this.key, % Ini.path, % this.className, % "key"
    }

    disableHotkeys() {
        function := ObjBindMethod(this, "doAction")

        hotkey, ifWinActive, ahk_exe Warframe.x64.exe
        hotkey, % "*" this.key, % function, off
        
        hotkey, ifWinActive, ahk_exe Warframe.exe
        hotkey, % "*" this.key, % function, off

        function := ""
    }

    enableHotkeys() {
        function := ObjBindMethod(this, "doAction")

        hotkey, ifWinActive, ahk_exe Warframe.x64.exe
        hotkey, % "*" this.key, % function, on

        hotkey, ifWinActive, ahk_exe Warframe.exe
        hotkey, % "*" this.key, % function, on

        function := ""
    }

    doAction() {
        switch this.slider.getContent() {
            case 1:
                while getKeyState(this.key, "p") {
                    Send % "{Blind}{" WarframeValues.keys.fireWeapon "}"
                    sleep, 50
                }
            case 2:
                while getKeyState(this.key, "p") {
                    Send % "{Blind}{" WarframeValues.keys.fireWeapon "}"
                    sleep, 50
                    Send % "{Blind}{" WarframeValues.keys.fireWeapon "}"
                    sleep, 50
                    Send % "{Blind}{" WarframeValues.keys.fireWeapon "}"
                    sleep, 50
                    keyWait, % this.key
                }
            case 3:
                while getKeyState(this.key, "p") {
                    Send % "{Blind}{" WarframeValues.keys.fireWeapon "}"
                    sleep, 50
                    keyWait, % this.key
                }

            default:
                msgbox % "Action not yet programmed"
        }
    }

    loadSettings() {
        valLoaded := Ini.readIni(this.className, "enabled")
        if !(valLoaded = 0 OR valLoaded = 1) {
            valLoaded := 0
        }
        this.enabled := valLoaded
        
        valLoaded := Ini.readIni(this.className, "value")
        this.slider.setText(valLoaded < 1 OR valLoaded > this.values.Length() ? 1 : valLoaded)

        valLoaded := Ini.readIni(this.className, "key")
        this.key := (Settings.checkKeyValidity(valLoaded) = 1 ? valLoaded : this.key)

        this.setState(this.enabled)
    }
}