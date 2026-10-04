import Quickshell
import Quickshell.Io

ShellRoot {
    Wallpaper {}
    StatusBar {}
    Launcher { id: launcher }
    Lock { id: lockScreen }

    IpcHandler {
        target: "launcher"
        function toggle(): void { launcher.toggle() }
    }

    IpcHandler {
        target: "lock"
        function lock(): void { lockScreen.lock() }
    }
}