import QtQuick
import QtQuick.Layouts

import qs.Common
import qs.Widgets

StyledRect {
    id: root

    property var agent

    readonly property string agentKind:
        String((agent && agent.kind) || "unknown")
    readonly property string promptTitle:
        String((agent && agent.name) || "Untitled thread")
    readonly property string agentStatus:
        String((agent && agent.status) || "unknown")
    readonly property string contextText:
        String((agent && agent.workspace) || "—") + " • "
        + worktreeBasename(agent && agent.worktree) + " • "
        + String((agent && agent.branch) || "—")

    implicitWidth: Theme.spacingXL * 16
    implicitHeight: content.implicitHeight + Theme.spacingXS * 2
    color: Theme.surfaceContainerHigh
    radius: Theme.cornerRadius

    function worktreeBasename(path) {
        const normalized = String(path || "").replace(/\\/g, "/")
            .replace(/\/+$/, "");
        if (!normalized)
            return "—";
        const separator = normalized.lastIndexOf("/");
        return separator >= 0 ? normalized.slice(separator + 1) : normalized;
    }

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
        anchors.margins: Theme.spacingXS
        spacing: Theme.spacingXXS

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.maximumWidth: Theme.spacingXL * 4
                text: root.agentKind + " | "
                color: Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
                maximumLineCount: 1
            }

            StyledText {
                Layout.fillWidth: true
                text: root.promptTitle
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                elide: Text.ElideRight
                wrapMode: Text.NoWrap
                maximumLineCount: 1
            }

            StyledText {
                text: " | "
                color: Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.NoWrap
            }

            StyledText {
                text: root.agentStatus
                color: root.statusColor(root.agentStatus)
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                wrapMode: Text.NoWrap
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: root.contextText
            color: Theme.surfaceVariantText
            font.pixelSize: Theme.fontSizeSmall
            elide: Text.ElideMiddle
            wrapMode: Text.NoWrap
            maximumLineCount: 1
        }
    }
}
