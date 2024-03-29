class QuickAbilityUse {
    static className := "Quick Ability Use"
    static enabled := 0
    static key := "MButton"
    static values = ["First Ability", "Second Ability", "Third Ability", "Fourth Ability", "Operator"]

    include() {
        this.button := FunctionsTab.controls.quickAbilityUseButton
        this.slider := FunctionsTab.controls.quickAbilityUseSlider
        this.valueLabel := FunctionsTab.controls.quickAbilityUseValueLabel

        this.bindFunctions()
    }

    bindFunctions() {
        function := ObjBindMethod(this, "setState", "toggle")
        guiControl, % Gui.hwnd ":+g", % this.button, % function

        function := ObjBindMethod(this, "refreshValueLabel")
        guiControl, % Gui.hwnd ":+g", % this.slider, % function
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

        guiControl, text, % this.button, % (this.enabled ? "On" : "Off")
        Gui, Font, % (this.enabled ? " cDefault " : " cGray ")
        GuiControl, Font, % this.valueLabel

        this.refreshValueLabel()
        this.setAction()
    }

    refreshValueLabel() {
        guiControl, text, % this.valueLabel, % this.values[Control.getContent(this.slider)]
        iniWrite, % Control.getContent(this.slider), % Ini.path, % this.className, % "value"
    }

    setAction() {
        function := ObjBindMethod(this, "doAction")

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
        Send, % "{Blind}{" WarframeValues.keys.abilities[Control.getContent(this.slider)] "}"
    }

    loadSettings() {
        this.enabled := Ini.readIni(this.className, "enabled")
        
        valLoaded := Ini.readIni(this.className, "value")
        guiControl, text, % this.slider, % (valLoaded < 1 OR valLoaded > this.values.Length() ? 1 : valLoaded)

        valLoaded := Ini.readIni(this.className, "key")
        this.key := (Settings.checkKeyValidity(valLoaded) = 1 ? valLoaded : this.key)

        this.setState(this.enabled)
    }
}