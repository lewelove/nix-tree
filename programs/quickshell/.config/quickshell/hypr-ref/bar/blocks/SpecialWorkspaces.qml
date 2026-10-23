import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "root:/"
import "../" 

RowLayout {
    id: root
    spacing: Theme.get.workspaceInnerSpacing

    visible: repeater.count > 0

    Repeater {
        id: repeater
        model: ScriptModel {
            values: [...Hyprland.workspaces.values]
                .filter(ws => {
                    if (!ws || !ws.name || !ws.name.startsWith("special:")) return false;
                    const mon = Hyprland.monitorFor(screen);
                    if (mon && ws.monitor) return ws.monitor === mon || ws.monitor.name === mon.name;
                    if (screen && ws.monitor) return ws.monitor.name === screen.name;
                    return true;
                })
                .sort((a, b) => a.name.localeCompare(b.name))
        }

        BarBlock {
            property HyprlandWorkspace thisWorkspace: modelData
            property var myWindows: WindowTracker.getWindows(thisWorkspace)
            property bool isActive: Hyprland.focusedMonitor?.activeWorkspace?.id === thisWorkspace.id
            
            visible: myWindows.length > 0

            underline: isActive
            
            Layout.preferredWidth: content ? content.implicitWidth : 0

            onClicked: Hyprland.dispatch(`togglespecialworkspace ${thisWorkspace.name.replace("special:", "")}`)

            content: Row {
                spacing: Theme.get.workspaceInnerSpacing
                anchors.centerIn: parent

                Repeater {
                    model: ScriptModel {
                        values: myWindows
                    }

                    delegate: WindowIcon {
                        client: modelData
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
