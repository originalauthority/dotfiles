import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import QtQuick
import QtQuick.Effects

Scope {
    id: root
    property bool locked: false
    property bool failed: false
    property string currentText: ""

    // we have this when we're messing with stuff and don't want to get locked out if we fuck
    // something up
    property bool devFailsafe: false

    Timer {
        running: root.locked && root.devFailsafe
        interval: 60000
        onTriggered: root.locked = false
    }

    function lock() {
        failed = false
        locked = true
    }

    PamContext {
        id: pam
        configDirectory: "pam"
        config: "password.conf"
        onPamMessage: {
            if (this.responseRequired) this.respond(root.currentText)
        }
        onCompleted: result => {
            if (result === PamResult.Success) root.locked = false
            else root.failed = true
            root.currentText = ""
        }
    }

    WlSessionLock {
        locked: root.locked

        WlSessionLockSurface {
            color: "black"

            Image {
                id: wall
                anchors.fill: parent
                source: "file://" + Quickshell.env("HOME") + "/Pictures/wallpapers/Subaru_Desktop.jpg"
                fillMode: Image.PreserveAspectCrop
                visible: false
            }
            MultiEffect {
                anchors.fill: parent
                source: wall
                blurEnabled: true
                blur: 1.0
                blurMax: 64
                brightness: -0.15
            }

            Column {
                anchors.centerIn: parent
                spacing: 28

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "LOCKED"
                    color: Theme.fg
                    font.family: Theme.fontName
                    font.pixelSize: 16
                    font.letterSpacing: 18
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 340
                    height: 200

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -6
                        radius: 22
                        rotation: -4
                        color: Qt.rgba(1, 1, 1, 0.12)
                    }
                    Rectangle {
                        anchors.fill: parent
                        radius: 22
                        color: Theme.bg

                        Column {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                id: bigClock
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Qt.formatDateTime(new Date(), "hh:mm")
                                color: Theme.fg
                                font.pixelSize: 96
                                font.bold: true
                            }
                            Text {
                                id: bigDate
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Qt.formatDateTime(new Date(), "ddd, MMM d")
                                color: Theme.fg
                                font.family: Theme.fontName
                                font.pixelSize: 15
                            }
                        }

                        Timer {
                            interval: 1000; running: root.locked; repeat: true
                            onTriggered: {
                                bigClock.text = Qt.formatDateTime(new Date(), "hh:mm")
                                bigDate.text = Qt.formatDateTime(new Date(), "ddd, MMM d")
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 380
                    height: 88
                    radius: 18
                    color: Theme.bg

                    Text {
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.failed ? "Wrong password, try again." : "Type your password and press Enter."
                        color: root.failed ? "#f38ba8" : Theme.fg
                        font.family: Theme.fontName
                        font.pixelSize: 12
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 12
                        height: 38
                        radius: 10
                        color: "#11141f"
                        border.color: root.failed ? "#f38ba8" : Theme.accent
                        border.width: 1

                        TextInput {
                            id: password
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                            color: Theme.fg
                            font.pixelSize: 16
                            focus: true
                            enabled: !pam.active
                            onTextChanged: if (text !== "") root.failed = false
                            onAccepted: {
                                if (text === "" || pam.active) return
                                root.currentText = text
                                text = ""
                                pam.start()
                            }
                        }
                    }
                }
            }
        }
    }
}