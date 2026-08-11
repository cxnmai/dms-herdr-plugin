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
        id: logo

        anchors.fill: parent
        source: Qt.resolvedUrl(Theme.isLightMode
            ? "assets/herdr.svg" : "assets/herdr-on-dark.svg")
        sourceSize.width: root.size * 2
        sourceSize.height: root.size * 2
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        cache: true
        mipmap: true
        smooth: true
        visible: status === Image.Ready
    }


    StyledText {
        anchors.fill: parent
        visible: logo.status !== Image.Ready
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
