import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    color: "black"

    Image {
        anchors.fill: parent
        source: "file://" + Quickshell.env("HOME") + "/Pictures/wallpapers/Subaru_Desktop.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
}