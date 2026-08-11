import QtQuick

import qs.Common
import qs.Widgets

Item {
    id: root

    property int size: Theme.iconSize
    property color color: Theme.surfaceText

    implicitWidth: size
    implicitHeight: size

    Accessible.role: Accessible.Graphic
    Accessible.name: "Herdr"

    Image {
        id: assetProbe

        source: Qt.resolvedUrl("assets/herdr.svg")
        asynchronous: true
        visible: false
    }

    DankSVGIcon {
        anchors.centerIn: parent
        visible: assetProbe.status === Image.Ready
        source: Qt.resolvedUrl("assets/herdr.svg")
        size: root.size
        colorOverride: root.color
    }

    StyledText {
        anchors.fill: parent
        visible: assetProbe.status !== Image.Ready
        text: "\u{F1719}"
        color: root.color
        font.family: "FiraCode Nerd Font"
        font.pixelSize: root.size
        font.weight: Font.Normal
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.NoWrap
    }
}
