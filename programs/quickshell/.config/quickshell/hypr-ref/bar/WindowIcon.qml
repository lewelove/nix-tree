import QtQuick
import Quickshell
import Quickshell.Widgets
import "root:/"

Item {
    id: root

    width: Theme.get.iconSize
    height: Theme.get.iconSize

    implicitWidth: Theme.get.iconSize
    implicitHeight: Theme.get.iconSize

    property var client: null

    property string rawAppId: {
        if (!client) return "";
        if (typeof client === "string") return client;
        if (client.appId && client.appId !== "") return client.appId.toString();
        if (client["class"] && client["class"] !== "") return client["class"].toString();
        if (client.initialClass && client.initialClass !== "") return client.initialClass.toString();
        if (client.lastIpcObject) {
            if (client.lastIpcObject["class"]) return client.lastIpcObject["class"].toString();
            if (client.lastIpcObject.initialClass) return client.lastIpcObject.initialClass.toString();
        }
        if (client.wayland && client.wayland.appId) return client.wayland.appId.toString();
        return "";
    }

    property string windowTitle: {
        if (!client) return "";
        if (client.title) return client.title.toString();
        if (client.lastIpcObject && client.lastIpcObject.title) return client.lastIpcObject.title.toString();
        return "";
    }

    property string normalizedId: {
        var id = rawAppId;
        if (id.startsWith("chrome-") && id.endsWith("-Default")) {
            id = id.slice(7, -8);
            id = id.replace(/__.*$/, "").replace(/\..*$/, "");
        }
        return id.toLowerCase();
    }

    property string resolvedIconPath: IconResolver.resolve(rawAppId, normalizedId, windowTitle)

    onResolvedIconPathChanged: {
        if (normalizedId !== "") {
            console.log("[WindowIcon] rawAppId: '" + rawAppId + "' | normalizedId: '" + normalizedId + "' | title: '" + windowTitle + "' | resolvedIcon: '" + resolvedIconPath + "'");
        }
    }

    visible: rawAppId !== ""

    IconImage {
        id: icon
        anchors.fill: parent
        visible: root.resolvedIconPath !== ""
        source: root.resolvedIconPath
    }

    Rectangle {
        anchors.fill: parent
        visible: root.resolvedIconPath === ""
        color: "#333333"
        radius: 3

        Text {
            anchors.centerIn: parent
            text: {
                var display = root.normalizedId || root.rawAppId;
                return display.length > 0 ? display.charAt(0).toUpperCase() : "?";
            }
            color: "white"
            font.pixelSize: 10
            font.bold: true
        }
    }
}
