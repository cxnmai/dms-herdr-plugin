import QtQuick
import Quickshell
import qs.Common
QtObject {
    id: root
    property bool serverRunning: false
    property bool actionPending: false
    property var agents: []
    property string lastError: ""
    property var _state: ({ polling: false, refreshQueued: false,
        pendingTarget: -1, branchCache: ({}), branchPending: ({}) })
    property Timer _pollTimer: Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
    function refresh() {
        if (_state.polling) {
            _state.refreshQueued = true
            return
        }
        _state.polling = true
        Proc.runCommand("herdr.status", ["herdr", "status", "server", "--json"],
            function(stdout, exitCode) {
                if (exitCode !== 0) {
                    root._failPoll("Unable to query the Herdr server")
                    return
                }
                var status = root._parseObject(stdout)
                if (!status || typeof status.running !== "boolean") {
                    root._failPoll("Herdr returned an invalid server status")
                    return
                }
                root._applyServerState(status.running)
                if (!status.running) {
                    root.lastError = ""
                    root._finishPoll()
                    return
                }
                root._readSnapshot()
            })
    }
    function startServer() {
        if (actionPending || serverRunning)
            return
        actionPending = true
        _state.pendingTarget = 1
        lastError = ""
        try {
            Quickshell.execDetached(["herdr", "server"])
            refresh()
        } catch (error) {
            actionPending = false
            _state.pendingTarget = -1
            lastError = "Unable to start the Herdr server"
        }
    }
    function stopServer() {
        if (actionPending || !serverRunning)
            return
        actionPending = true
        _state.pendingTarget = 0
        lastError = ""
        Proc.runCommand("herdr.stop", ["herdr", "server", "stop"],
            function(stdout, exitCode) {
                if (exitCode !== 0) {
                    root.actionPending = false
                    root._state.pendingTarget = -1
                    root.lastError = "Unable to stop the Herdr server"
                    return
                }
                root.refresh()
            })
    }
    function _readSnapshot() {
        Proc.runCommand("herdr.snapshot", ["herdr", "api", "snapshot"],
            function(stdout, exitCode) {
                if (exitCode !== 0) {
                    root._failPoll("Unable to read the Herdr snapshot")
                    return
                }
                var response = root._parseObject(stdout)
                var snapshot = response && response.result && response.result.snapshot
                if (!snapshot || !Array.isArray(snapshot.agents)
                        || !Array.isArray(snapshot.workspaces)) {
                    root._failPoll("Herdr returned an invalid snapshot")
                    return
                }
                root.lastError = ""
                root._applySnapshot(snapshot)
                root._finishPoll()
            })
    }
    function _applyServerState(running) {
        serverRunning = running
        if (!running)
            agents = []
        if ((_state.pendingTarget === 1 && running)
                || (_state.pendingTarget === 0 && !running)) {
            actionPending = false
            _state.pendingTarget = -1
        }
    }
    function _applySnapshot(snapshot) {
        var contexts = {}
        for (var i = 0; i < snapshot.workspaces.length; ++i) {
            var workspace = snapshot.workspaces[i]
            if (workspace && workspace.workspace_id !== undefined)
                contexts[String(workspace.workspace_id)] = workspace
        }
        var normalized = []
        for (var j = 0; j < snapshot.agents.length; ++j) {
            var raw = snapshot.agents[j]
            if (!raw || raw.pane_id === undefined)
                continue
            var context = contexts[String(raw.workspace_id)] || {}
            var tree = context.worktree && typeof context.worktree === "object"
                ? context.worktree : {}
            var directory = root._string(raw.foreground_cwd || raw.cwd
                || tree.checkout_path)
            var kind = root._string(raw.agent || raw.display_agent || "unknown")
            var cached = _state.branchCache[directory]
            normalized.push({
                paneId: root._string(raw.pane_id),
                name: root._string(raw.terminal_title_stripped || raw.terminal_title
                    || kind || raw.pane_id),
                kind: kind,
                status: root._status(raw.agent_status),
                workspace: root._string(context.label || raw.workspace_id),
                repository: root._string(tree.repo_name),
                worktree: root._string(tree.checkout_path),
                directory: directory,
                branch: cached ? cached.value : ""
            })
            root._refreshBranch(directory, cached)
        }
        agents = normalized
    }
    function _refreshBranch(directory, cached) {
        if (!directory || _state.branchPending[directory]
                || (cached && Date.now() - cached.checkedAt < 30000))
            return
        _state.branchPending[directory] = true
        Proc.runCommand("herdr.branch." + encodeURIComponent(directory),
            ["git", "-C", directory, "branch", "--show-current"],
            function(stdout, exitCode) {
                delete root._state.branchPending[directory]
                var branch = exitCode === 0 ? root._string(stdout).trim() : ""
                root._state.branchCache[directory] = {
                    value: branch, checkedAt: Date.now()
                }
                root._updateBranch(directory, branch)
            })
    }
    function _updateBranch(directory, branch) {
        var updated = []
        for (var i = 0; i < agents.length; ++i) {
            var agent = agents[i]
            if (agent.directory === directory)
                agent.branch = branch
            updated.push(agent)
        }
        agents = updated
    }
    function _parseObject(text) {
        try {
            var value = JSON.parse(root._string(text))
            return value && typeof value === "object" && !Array.isArray(value)
                ? value : null
        } catch (error) {
            return null
        }
    }
    function _status(value) {
        var statuses = ["idle", "working", "blocked", "done", "unknown"]
        return statuses.indexOf(value) >= 0 ? value : "unknown"
    }
    function _string(value) {
        return value === undefined || value === null ? "" : String(value)
    }
    function _failPoll(message) {
        serverRunning = false
        agents = []
        actionPending = false
        _state.pendingTarget = -1
        lastError = message
        _finishPoll()
    }
    function _finishPoll() {
        _state.polling = false
        if (_state.refreshQueued) {
            _state.refreshQueued = false
            refresh()
        }
    }
    Component.onCompleted: refresh()
}
