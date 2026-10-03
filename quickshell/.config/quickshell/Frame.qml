import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: frame
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    color: "transparent"
    mask: Region {}

    property int thickness: Theme.frame
    property int innerRadius: Theme.screenRadius
    property color frameColor: Theme.bg

    Rectangle {
        anchors.fill: parent
        anchors.margins: -frame.thickness
        color: "transparent"
        border.color: frame.frameColor
        border.width: frame.thickness * 2
        radius: frame.innerRadius + frame.thickness * 2
    }
}