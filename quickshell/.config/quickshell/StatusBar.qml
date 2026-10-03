import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import QtQuick

PanelWindow {
    id: bar
    anchors.top: true
    implicitWidth: screen.width * Theme.barWidth + Theme.fillet * 2
    implicitHeight: Theme.barHeight
    color: "transparent"

    property color bg: Theme.bg
    property color fg: Theme.fg
    property color accent: Theme.accent
    property color dim: Theme.dim
    property string fontName: Theme.fontName

    PwObjectTracker { objects: [ Pipewire.defaultAudioSink ] }
    Process { id: launcherProc; command: ["qs", "ipc", "call", "launcher", "toggle"] }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: Theme.fillet
        anchors.rightMargin: Theme.fillet
        color: bar.bg
        bottomLeftRadius: Theme.barRadius
        bottomRightRadius: Theme.barRadius
    }

    Canvas {
        x: 0
        y: 0
        width: Theme.fillet
        height: Theme.fillet
        onPaint: {
            const ctx = getContext("2d"), r = width
            ctx.reset()
            ctx.fillStyle = bar.bg
            ctx.beginPath()
            ctx.moveTo(0, 0); ctx.lineTo(r, 0); ctx.lineTo(r, r)
            ctx.arc(0, r, r, 0, -Math.PI / 2, true)
            ctx.closePath(); ctx.fill()
        }
    }

    // Right fillet: mirror image
    Canvas {
        x: parent.width - Theme.fillet
        y: 0
        width: Theme.fillet
        height: Theme.fillet
        onPaint: {
            const ctx = getContext("2d"), r = width
            ctx.reset()
            ctx.translate(r, 0); ctx.scale(-1, 1)
            ctx.fillStyle = bar.bg
            ctx.beginPath()
            ctx.moveTo(0, 0); ctx.lineTo(r, 0); ctx.lineTo(r, r)
            ctx.arc(0, r, r, 0, -Math.PI / 2, true)
            ctx.closePath(); ctx.fill()
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Theme.fillet
        anchors.rightMargin: Theme.fillet

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            text: "󰣇"
            color: bar.accent
            font.family: bar.fontName
            font.pixelSize: 14
            MouseArea { anchors.fill: parent; onClicked: launcherProc.running = true }
        }

        Row {
            anchors.centerIn: parent
            spacing: 18

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: bar.fg
                font.family: bar.fontName
                font.pixelSize: 12
                text: {
                    const dev = UPower.displayDevice
                    const p = dev.percentage
                    const pct = Math.round(p <= 1 ? p * 100 : p)
                    const charging = dev.state === UPowerDeviceState.Charging
                    const mode = PowerProfiles.profile === PowerProfile.PowerSaver ? " 󰌪"
                               : PowerProfiles.profile === PowerProfile.Performance ? " 󰓅" : ""
                    return (charging ? "󰂄 " : "󰁹 ") + pct + "%" + mode
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (PowerProfiles.profile === PowerProfile.PowerSaver)
                            PowerProfiles.profile = PowerProfile.Balanced
                        else if (PowerProfiles.profile === PowerProfile.Balanced && PowerProfiles.hasPerformanceProfile)
                            PowerProfiles.profile = PowerProfile.Performance
                        else
                            PowerProfiles.profile = PowerProfile.PowerSaver
                    }
                }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                Repeater {
                    model: Hyprland.workspaces.values.filter(w => w.id > 0)
                    Rectangle {
                        required property var modelData
                        property bool focused: Hyprland.focusedWorkspace?.id === modelData.id
                        anchors.verticalCenter: parent.verticalCenter
                        width: focused ? 34 : 7
                        height: focused ? 16 : 7
                        radius: height / 2
                        color: focused ? bar.accent : bar.dim
                        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

                        Text {
                            anchors.centerIn: parent
                            visible: parent.focused
                            text: parent.modelData.id
                            color: bar.bg
                            font.family: bar.fontName
                            font.pixelSize: 10
                            font.bold: true
                        }
                        MouseArea { anchors.fill: parent; onClicked: parent.modelData.activate() }
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                color: bar.fg
                font.family: bar.fontName
                font.pixelSize: 12
                text: {
                    const sink = Pipewire.defaultAudioSink
                    if (!sink || !sink.audio) return ""
                    return (sink.audio.muted ? "󰝟 " : "󰕾 ")
                        + Math.round(sink.audio.volume * 100) + "%"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        const a = Pipewire.defaultAudioSink?.audio
                        if (a) a.muted = !a.muted
                    }
                    onWheel: wheel => {
                        const a = Pipewire.defaultAudioSink?.audio
                        if (!a) return
                        const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                        a.volume = Math.max(0, Math.min(1, a.volume + step))
                    }
                }
            }
        }

        Text {
            id: clock
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            color: bar.fg
            font.family: bar.fontName
            font.pixelSize: 12
            text: Qt.formatDateTime(new Date(), "ddd, MMM d   hh:mm")
            Timer {
                interval: 1000; running: true; repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM d   hh:mm")
            }
        }
    }
}