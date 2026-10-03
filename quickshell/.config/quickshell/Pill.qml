import QtQuick

Rectangle {
    default property alias content: row.children
    implicitWidth: row.implicitWidth + 24
    implicitHeight: 28
    radius: 14
    color: "#313244"

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 12
    }
}