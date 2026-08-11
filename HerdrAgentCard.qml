import QtQuick
import QtQuick.Layouts

import qs.Common
import qs.Widgets

StyledRect {
    id: root

    property var agent

    implicitWidth: Theme.spacingXL * 16
    implicitHeight: content.implicitHeight + Theme.spacingM * 2
    color: Theme.surfaceContainerHigh
    radius: Theme.cornerRadius

    function statusColor(status) {
        switch (String(status || "").toLowerCase()) {
        case "working":
            return Theme.primary;
        case "blocked":
            return Theme.error;
        case "done":
            return Theme.secondary;
        default:
            return Theme.surfaceVariantText;
        }
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: Theme.spacingM
        spacing: Theme.spacingS

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingM

            DankIcon {
                name: "smart_toy"
                size: Theme.iconSize
                color: root.statusColor(root.agent && root.agent.status)
                Layout.alignment: Qt.AlignTop
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXXS

                StyledText {
                    Layout.fillWidth: true
                    text: (root.agent && root.agent.name) || "Unnamed agent"
                    color: Theme.surfaceText
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                }

                StyledText {
                    Layout.fillWidth: true
                    text: (root.agent && root.agent.kind) || "Unknown kind"
                    color: Theme.surfaceVariantText
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                }
            }

            StyledRect {
                implicitWidth: statusText.implicitWidth + Theme.spacingS * 2
                implicitHeight: statusText.implicitHeight + Theme.spacingXS * 2
                radius: height / 2
                color: Theme.withAlpha(
                    root.statusColor(root.agent && root.agent.status), 0.14)

                StyledText {
                    id: statusText

                    anchors.centerIn: parent
                    text: (root.agent && root.agent.status) || "unknown"
                    color: root.statusColor(root.agent && root.agent.status)
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    wrapMode: Text.NoWrap
                }
            }
        }

        StyledRect {
            Layout.fillWidth: true
            implicitHeight: Theme.spacingXXS
            color: Theme.outlineVariant
            opacity: 0.5
        }

        Repeater {
            model: [
                {
                    "label": "Workspace",
                    "value": (root.agent && root.agent.workspace) || "—"
                },
                {
                    "label": "Worktree",
                    "value": (root.agent && root.agent.worktree) || "—"
                },
                {
                    "label": "Directory",
                    "value": (root.agent && root.agent.directory) || "—"
                },
                {
                    "label": "Branch",
                    "value": (root.agent && root.agent.branch) || "—"
                }
            ]

            delegate: RowLayout {
                required property var modelData

                Layout.fillWidth: true
                spacing: Theme.spacingS

                StyledText {
                    Layout.preferredWidth: Math.max(
                        implicitWidth, Theme.spacingXL * 3)
                    text: modelData.label
                    color: Theme.surfaceVariantText
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.NoWrap
                }

                StyledText {
                    Layout.fillWidth: true
                    text: modelData.value
                    color: Theme.surfaceText
                    font.pixelSize: Theme.fontSizeSmall
                    isMonospace: modelData.label !== "Workspace"
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap
                    maximumLineCount: 1
                }
            }
        }
    }
}
