pragma Singleton
import Quickshell
import QtQuick

Singleton {
    readonly property color bg: "#1b1f2e"
    readonly property color fg: "#c8d3f5"
    readonly property color accent: "#82aaff"
    readonly property color dim: "#4a5070"
    readonly property string fontName: "JetBrainsMono Nerd Font"

    readonly property real barWidth: 0.8
    readonly property int barHeight: 30
    readonly property int barRadius: 14
    readonly property int fillet: 20
}