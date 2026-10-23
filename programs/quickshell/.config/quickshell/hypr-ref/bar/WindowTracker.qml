pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: root

    property int revision: 0

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            root.revision++;
        }
    }

    Connections {
        target: ToplevelManager.toplevels
        function onValuesChanged() {
            root.revision++;
        }
    }

    function getWindows(ws) {
        var _rev = root.revision;
        if (!ws) return [];
        
        var idStr = ws.id !== undefined ? ws.id.toString() : "";
        var nameStr = ws.name !== undefined ? ws.name.toString() : "";
        var result = [];

        if (ws.toplevels && ws.toplevels.values && ws.toplevels.values.length > 0) {
            var wtList = ws.toplevels.values;
            for (var k = 0; k < wtList.length; k++) {
                var wtl = wtList[k];
                if (!wtl) continue;
                var wClass = "";
                if (wtl.lastIpcObject && wtl.lastIpcObject["class"]) wClass = wtl.lastIpcObject["class"];
                else if (wtl.wayland && wtl.wayland.appId) wClass = wtl.wayland.appId;
                else if (wtl.lastIpcObject && wtl.lastIpcObject.initialClass) wClass = wtl.lastIpcObject.initialClass;
                else if (wtl.title) wClass = wtl.title;

                result.push({
                    "class": wClass,
                    "initialClass": wClass,
                    "title": wtl.title || "",
                    "appId": wClass
                });
            }
            if (result.length > 0) return result;
        }

        var list = ToplevelManager.toplevels ? ToplevelManager.toplevels.values : [];
        for (var i = 0; i < list.length; i++) {
            var tl = list[i];
            if (!tl) continue;

            var hl = tl.HyprlandToplevel;
            var matched = false;

            if (hl && hl.workspace) {
                if (idStr && hl.workspace.id !== undefined && hl.workspace.id.toString() === idStr) matched = true;
                if (nameStr && hl.workspace.name !== undefined && hl.workspace.name.toString() === nameStr) matched = true;
            } else if (hl && hl.lastIpcObject && hl.lastIpcObject.workspace) {
                var iws = hl.lastIpcObject.workspace;
                if (idStr && iws.id !== undefined && iws.id.toString() === idStr) matched = true;
                if (nameStr && iws.name !== undefined && iws.name.toString() === nameStr) matched = true;
            }

            if (matched) {
                var cls = tl.appId || "";
                if (hl && hl.lastIpcObject) {
                    if (!cls && hl.lastIpcObject["class"]) cls = hl.lastIpcObject["class"];
                    if (!cls && hl.lastIpcObject.initialClass) cls = hl.lastIpcObject.initialClass;
                }
                result.push({
                    "class": cls,
                    "initialClass": cls,
                    "title": tl.title || "",
                    "appId": cls
                });
            }
        }

        return result;
    }
}
