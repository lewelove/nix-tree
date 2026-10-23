pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var iconMap: ({})

    FileView {
        id: mapFile
        path: Qt.resolvedUrl("./icons.jsonc")
        watchChanges: true
        blockLoading: true

        onFileChanged: root.reload()
        onLoaded: root.reload()
    }

    Component.onCompleted: reload()

    function stripJsonc(content) {
        return content
            .replace(/\/\*[\s\S]*?\*\//g, "")
            .replace(/\/\/.*$/gm, "")
            .replace(/,\s*([}\]])/g, "$1");
    }

    function reload() {
        try {
            var raw = mapFile.text().trim();
            if (raw !== "") {
                root.iconMap = JSON.parse(stripJsonc(raw));
            }
        } catch (e) {
            console.error("[IconResolver] Error parsing icons.jsonc:", e);
        }
    }

    function resolveAsset(iconRef) {
        if (!iconRef || iconRef === "") return "";
        if (iconRef.startsWith("/") || iconRef.startsWith("file://") || iconRef.startsWith("image://")) {
            return iconRef;
        }
        if (iconRef.endsWith(".svg") || iconRef.endsWith(".png")) {
            return Qt.resolvedUrl("../assets/icons/" + iconRef).toString();
        }
        return Quickshell.iconPath(iconRef, true);
    }

    function resolve(rawAppId, normalizedId, windowTitle) {
        if (rawAppId && root.iconMap[rawAppId]) {
            return resolveAsset(root.iconMap[rawAppId]);
        }

        if (normalizedId && root.iconMap[normalizedId]) {
            return resolveAsset(root.iconMap[normalizedId]);
        }

        if (windowTitle && root.iconMap[windowTitle]) {
            return resolveAsset(root.iconMap[windowTitle]);
        }

        for (var key in root.iconMap) {
            if (key.startsWith("/") && key.endsWith("/")) {
                var pattern = new RegExp(key.slice(1, -1), "i");
                if ((rawAppId && pattern.test(rawAppId)) ||
                    (normalizedId && pattern.test(normalizedId)) ||
                    (windowTitle && pattern.test(windowTitle))) {
                    return resolveAsset(root.iconMap[key]);
                }
            }
        }

        if (rawAppId && rawAppId.startsWith("steam_app_")) {
            var appId = rawAppId.replace("steam_app_", "");
            var steamIcon = "file://" + Quickshell.env("HOME") + "/.local/share/icons/hicolor/32x32/apps/steam_icon_" + appId + ".png";
            return steamIcon;
        }

        var entry = DesktopEntries.byId(rawAppId) || DesktopEntries.heuristicLookup(rawAppId);
        if (!entry && normalizedId) {
            entry = DesktopEntries.byId(normalizedId) || DesktopEntries.heuristicLookup(normalizedId);
        }
        if (!entry && windowTitle) {
            entry = DesktopEntries.heuristicLookup(windowTitle);
        }
        if (entry && entry.icon) {
            var iconFromDesktop = Quickshell.iconPath(entry.icon, true);
            if (iconFromDesktop) return iconFromDesktop;
        }

        if (normalizedId) {
            var fromNorm = Quickshell.iconPath(normalizedId, true) || Quickshell.iconPath(normalizedId.toLowerCase(), true);
            if (fromNorm) return fromNorm;
        }

        if (rawAppId) {
            var fromRaw = Quickshell.iconPath(rawAppId, true) || Quickshell.iconPath(rawAppId.toLowerCase(), true);
            if (fromRaw) return fromRaw;
        }

        return "";
    }
}
