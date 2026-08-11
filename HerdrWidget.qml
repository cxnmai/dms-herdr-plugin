import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "herdr"
    popoutWidth: 460
    popoutHeight: 560

    readonly property string agentSummary: {
        const count = herdr.agents.length;
        return count + (count === 1 ? " agent running" : " agents running");
    }

    HerdrModel {
        id: herdr
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            HerdrIcon {
                size: Theme.iconSize
                color: herdr.serverRunning ? Theme.primary : Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                visible: herdr.serverRunning
                text: root.agentSummary
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXXS

            HerdrIcon {
                size: Theme.iconSize
                color: herdr.serverRunning ? Theme.primary : Theme.surfaceVariantText
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                visible: herdr.serverRunning
                text: herdr.agents.length
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
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
            spacing: Theme.spacingL

            StyledRect {
                width: parent.width
                height: stoppedContent.implicitHeight + Theme.spacingXL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh

                Column {
                    id: stoppedContent
                    width: parent.width - Theme.spacingXL * 2
                    anchors.centerIn: parent
                    spacing: Theme.spacingS

                    HerdrIcon {
                        size: Theme.iconSizeLarge * 2
                        color: Theme.surfaceVariantText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    StyledText {
                        width: parent.width
                        text: "Start the Herdr server to see and manage coding agents."
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        color: Theme.surfaceVariantText
                        font.pixelSize: Theme.fontSizeMedium
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
                anchors.bottomMargin: Theme.spacingM
                clip: true
                spacing: Theme.spacingS
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
                iconName: "stop"
                enabled: !herdr.actionPending
                backgroundColor: Theme.error
                textColor: Theme.onPrimary
                onClicked: herdr.stopServer()
            }
        }
    }
}
