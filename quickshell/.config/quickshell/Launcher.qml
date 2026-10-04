import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: launcher
    visible: false
    implicitWidth: 500
    implicitHeight: 420
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    function toggle() {
        launcher.visible = !launcher.visible
        if (launcher.visible) {
            search.text = ""
            search.forceActiveFocus()
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: Theme.bg
        border.color: Theme.accent
        border.width: 2

        TextInput {
            id: search
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
            color: Theme.fg
            font.family: Theme.fontName
            font.pixelSize: 18
            focus: true
            onTextChanged: list.currentIndex = 0
            Keys.onEscapePressed: launcher.visible = false
            Keys.onReturnPressed: list.launch(list.currentIndex)
            Keys.onDownPressed: list.incrementCurrentIndex()
            Keys.onUpPressed: list.decrementCurrentIndex()

            Text {
                text: "Search apps…"
                color: Theme.dim
                font: search.font
                visible: search.text === ""
            }
        }

        ListView {
            id: list
            anchors {
                top: search.bottom; left: parent.left; right: parent.right; bottom: parent.bottom
                margins: 12; topMargin: 14
            }
            clip: true
            model: DesktopEntries.applications.values
                .filter(a => !a.noDisplay && a.name.toLowerCase().includes(search.text.toLowerCase()))
                .sort((a, b) => a.name.localeCompare(b.name))
            highlight: Rectangle { color: "#313244"; radius: 8 }
            highlightMoveDuration: 100

            function launch(i) {
                const app = model[i]
                if (app) {
                    app.execute()
                    launcher.visible = false
                }
            }

            delegate: Item {
                required property var modelData
                required property int index
                width: ListView.view.width
                height: 38

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    x: 12
                    text: modelData.name
                    color: Theme.fg
                    font.family: Theme.fontName
                    font.pixelSize: 14
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: list.currentIndex = index
                    onClicked: list.launch(index)
                }
            }
        }
    }
}