import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string pluginId: "dankBitwarden"
    property string trigger: "@"
    property string defaultAction: "password"
    property var _entries: []
    property bool _loading: false
    property string _error: ""

    signal itemsChanged

    Component.onCompleted: {
        if (!pluginService)
            return;
        trigger = pluginService.loadPluginData(pluginId, "trigger", "@");
        defaultAction = pluginService.loadPluginData(pluginId, "defaultAction", "password");
        refreshEntries();
    }

    function refreshEntries() {
        _loading = true;
        _error = "";
        listProcess.running = true;
    }

    property Process listProcess: Process {
        command: ["rbw", "list", "--fields", "name,user,folder"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root._loading = false;
                root._entries = [];
                var lines = text.trim().split("\n");
                var entries = [];
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (line.length === 0)
                        continue;
                    var parts = line.split("\t");
                    entries.push({
                        name: parts[0] || "",
                        user: parts[1] || "",
                        folder: parts[2] || ""
                    });
                }
                root._entries = entries;
                root.itemsChanged();
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                root._loading = false;
                root._error = "rbw failed (exit " + exitCode + "). Is the vault unlocked?";
                root.itemsChanged();
            }
        }
    }

    function getItems(query) {
        if (_error) {
            return [{
                name: _error,
                icon: "material:error",
                comment: "Press Enter to retry",
                action: "retry:",
                categories: ["Bitwarden"]
            }];
        }

        if (_loading) {
            return [{
                name: "Loading vault...",
                icon: "material:hourglass_empty",
                comment: "Fetching entries from rbw",
                action: "none:",
                categories: ["Bitwarden"]
            }];
        }

        var lowerQuery = query ? query.toLowerCase().trim() : "";
        var results = [];

        for (var i = 0; i < _entries.length; i++) {
            var entry = _entries[i];
            var nameLower = entry.name.toLowerCase();
            var userLower = entry.user.toLowerCase();
            var folderLower = entry.folder.toLowerCase();

            if (lowerQuery.length === 0
                || nameLower.includes(lowerQuery)
                || userLower.includes(lowerQuery)
                || folderLower.includes(lowerQuery)) {

                var display = entry.name;
                if (entry.folder)
                    display = entry.folder + "/" + entry.name;

                var comment = entry.user || "No username";

                results.push({
                    name: display,
                    icon: "material:key",
                    comment: comment,
                    action: "copy:" + defaultAction + ":" + entry.name + "\t" + entry.user,
                    categories: ["Bitwarden"]
                });
            }

            if (results.length >= 50)
                break;
        }

        if (results.length === 0 && lowerQuery.length > 0) {
            return [{
                name: "No matching entries",
                icon: "material:search_off",
                comment: "Try a different query",
                action: "none:",
                categories: ["Bitwarden"]
            }];
        }

        return results;
    }

    function executeItem(item) {
        if (!item?.action)
            return;
        var colonIdx = item.action.indexOf(":");
        if (colonIdx === -1)
            return;
        var actionType = item.action.substring(0, colonIdx);
        var rest = item.action.substring(colonIdx + 1);

        if (actionType === "retry") {
            refreshEntries();
            return;
        }

        if (actionType !== "copy")
            return;

        // rest = "password:entryname\tuser" or "username:entryname\tuser" or "totp:entryname\tuser"
        var firstColon = rest.indexOf(":");
        var field = rest.substring(0, firstColon);
        var entryPart = rest.substring(firstColon + 1);
        var tabIdx = entryPart.indexOf("\t");
        var entryName = tabIdx !== -1 ? entryPart.substring(0, tabIdx) : entryPart;
        var entryUser = tabIdx !== -1 ? entryPart.substring(tabIdx + 1) : "";

        var cmd = ["rbw", "get"];
        if (field === "username")
            cmd = cmd.concat(["--field", "username"]);
        else if (field === "totp")
            cmd = cmd.concat(["--field", "totp"]);
        cmd.push(entryName);
        if (entryUser)
            cmd.push(entryUser);

        copyFieldProcess.command = cmd;
        copyFieldProcess._fieldName = field;
        copyFieldProcess.running = true;
    }

    property Process copyFieldProcess: Process {
        property string _fieldName: "password"
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                var value = text.trim();
                if (value.length > 0) {
                    Quickshell.execDetached(["sh", "-c",
                        "printf '%s' \"$1\" | wl-copy --paste-once --sensitive; " +
                        "(sleep 15 && wl-copy --clear) &",
                        "sh", value]);
                    if (typeof ToastService !== "undefined")
                        ToastService.showInfo("Bitwarden", "Copied " + copyFieldProcess._fieldName + " (clears in 15s)");
                }
            }
        }

        onExited: exitCode => {
            if (exitCode !== 0) {
                if (typeof ToastService !== "undefined")
                    ToastService.showInfo("Bitwarden", "Failed to get " + _fieldName);
            }
        }
    }

    function getContextMenuActions(item) {
        if (!item?.action || item.action.indexOf("copy:") !== 0)
            return [];

        var rest = item.action.substring(5);
        var firstColon = rest.indexOf(":");
        var entryRef = rest.substring(firstColon + 1);

        return [
            {
                icon: "key",
                text: "Copy Password",
                action: function() { executeItem({ action: "copy:password:" + entryRef }); }
            },
            {
                icon: "person",
                text: "Copy Username",
                action: function() { executeItem({ action: "copy:username:" + entryRef }); }
            },
            {
                icon: "pin",
                text: "Copy TOTP",
                action: function() { executeItem({ action: "copy:totp:" + entryRef }); }
            }
        ];
    }

    onTriggerChanged: {
        if (!pluginService)
            return;
        pluginService.savePluginData(pluginId, "trigger", trigger);
    }

    onDefaultActionChanged: {
        if (!pluginService)
            return;
        pluginService.savePluginData(pluginId, "defaultAction", defaultAction);
    }
}
