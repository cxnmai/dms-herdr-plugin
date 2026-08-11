import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "herdr"
    popoutWidth: 420
    popoutHeight: 320

    readonly property string agentSummary: {
        const count = herdr.agents.length;
        return count + (count === 1 ? " agent running" : " agents running");
    }

    HerdrModel {
        id: herdr
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            HerdrIcon {
                size: root.iconSize
                color: herdr.serverRunning ? Theme.widgetIconColor : Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                visible: herdr.serverRunning
                text: herdr.agents.length
                font.pixelSize: Theme.barTextSize(root.barThickness,
                    root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.widgetTextColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            HerdrIcon {
                size: root.iconSize
                color: herdr.serverRunning ? Theme.widgetIconColor : Theme.surfaceVariantText
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                visible: herdr.serverRunning
                text: herdr.agents.length
                font.pixelSize: Theme.barTextSize(root.barThickness,
                    root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                color: Theme.widgetTextColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout

            headerText: "Herdr"
            detailsText: herdr.serverRunning ? root.agentSummary : "Server is not running"
            showCloseButton: true

            Item {
                width: parent.width
                implicitHeight: root.popoutHeight - popout.headerHeight - popout.detailsHeight - Theme.spacingXL

                Loader {
                    anchors.fill: parent
                    sourceComponent: herdr.serverRunning ? runningState : stoppedState
                }
            }
        }
    }

    Component {
        id: stoppedState

        Column {
            spacing: Theme.spacingM

            StyledRect {
                width: parent.width
                height: stoppedContent.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh

                Column {
                    id: stoppedContent
                    width: parent.width - Theme.spacingL * 2
                    anchors.centerIn: parent
                    spacing: Theme.spacingXS

                    HerdrIcon {
                        size: Theme.iconSizeLarge
                        color: Theme.surfaceVariantText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        width: parent.width
                        text: "Start the Herdr server to see and manage coding agents."
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        color: Theme.surfaceVariantText
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }
            }

            StyledText {
                width: parent.width
                visible: herdr.lastError.length > 0
                text: herdr.lastError
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: Theme.error
                font.pixelSize: Theme.fontSizeSmall
            }

            DankButton {
                text: herdr.actionPending ? "Starting…" : "Start Herdr"
                iconName: "play_arrow"
                enabled: !herdr.actionPending
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: herdr.startServer()
            }
        }
    }

    Component {
        id: runningState

        Item {
            DankListView {
                id: agentList
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: stopButton.top
                anchors.bottomMargin: Theme.spacingXS
                clip: true
                spacing: Theme.spacingXS
                model: herdr.agents

                delegate: HerdrAgentCard {
                    required property var modelData
                    width: ListView.view.width
                    agent: modelData
                }

                StyledText {
                    anchors.centerIn: parent
                    visible: herdr.agents.length === 0
                    text: "No detected agents"
                    color: Theme.surfaceVariantText
                    font.pixelSize: Theme.fontSizeMedium
                }
            }

            DankButton {
                id: stopButton
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                text: herdr.actionPending ? "Stopping…" : "Stop Herdr"
                buttonHeight: 32
                horizontalPadding: Theme.spacingM
                enabled: !herdr.actionPending
                backgroundColor: Theme.error
                textColor: Theme.onPrimary
                onClicked: herdr.stopServer()
            }
        }
    }
}
