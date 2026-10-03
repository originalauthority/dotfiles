import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

PanelWindow {
	id: bar
	anchors { top: true; left: true; right: true }
	implicitHeight: 32
	color: "#1e1e2e"
	
	property color fg: "#cdd6f4"
	property color accent: "#89b4fa"
	property color dim: "#45475a"
	property string fontName: "JetBrainsMono Nerd Font"

	PwObjectTracker { objects: [ Pipewire.defaultAudioSink ] }

	Row {
		anchors.left: parent.left
		anchors.leftMargin: 10
		anchors.verticalCenter: parent.verticalCenter
		spacing: 6
		
		Repeater {
			model: Hyprland.workspaces
			Rectangle {
				required property var modelData
				property bool focused: Hyprland.focusedWorkspace?.id === modelData.id
				width: focused ? 30 : 20
				height: 20
				radius: 10
				color: focused ? bar.accent : bar.dim
				Behavior on width { NumberAnimation { duration: 150 } }
				
				Text {
					anchors.centerIn: parent
					text: modelData.id
					color: parent.focused ? "#1e1e2e" : bar.fg
					font.family: bar.fontName
					font.pixelSize: 11
				}
				MouseArea {
					anchors.fill: parent
					onClicked: modelData.activate()
				}
			}
		}
	}

	Text {	
		id: clock
		anchors.centerIn: parent
		color: "#cdd6f4"
		font.family: "JetBrainsMono Nerd Font"
		font.pixelSize: 14
		text: Qt.formatDateTime(new Date(), "ddd d MMM hh:mm")
	}

	Timer {
		interval: 1000; running: true; repeat: true
		onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd d MMM hh:mm")
	}

	Row {
		anchors.right: parent.right
		anchors.rightMargin: 12
		anchors.verticalCenter: parent.verticalCenter
		spacing: 16

		Text {
			color: bar.fg
			font.family: bar.fontName
			font.pixelSize: 13
			text: {
				const sink = Pipewire.defaultAudioSink
				if (!sink || !sink.audio) return ""
				return (sink.audio.muted ? "󰝟 " : "󰕾 ") + Math.round(sink.audio.volume * 100) + "%"
			}
		}
		
		Text {
			color: bar.fg
			font.family: bar.fontName
			font.pixelSize: 13
			text: {
				const dev = UPower.displayDevice
				const p = dev.percentage
				const pct = Math.round(p <= 1 ? p * 100 : p)
				const charging = dev.state === UPowerDeviceState.charging
				return (charging ? "󰂄 " : "󰁹 ") + pct + "%"
			}
		}
	}
}
