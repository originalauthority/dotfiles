import Quickshell
import Quickshell.Io

ShellRoot {
    Wallpaper {}
    StatusBar {}
    Launcher { id: launcher }

    IpcHandler {
        target: "launcher"
        function toggle(): void { launcher.toggle() }
    }
}