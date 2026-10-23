import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "root:/"
import "../" 

RowLayout {
    id: root
    spacing: Theme.get.workspaceSpacing

    Repeater {
        model: ScriptModel {
            values: [...Hyprland.workspaces.values]
                .filter(ws => {
                    if (!ws || !ws.name || ws.name.startsWith("special:")) return false;
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
            
            underline: isActive
            
            Layout.preferredWidth: Math.max(Theme.get.barHeight, content ? content.implicitWidth : 0)

            onClicked: Hyprland.dispatch(`workspace name:${thisWorkspace.name}`)

            content: Row {
                spacing: Theme.get.workspaceInnerSpacing
                leftPadding: 0
                
                Item {
                    width: numText.implicitWidth
                    height: numText.implicitHeight
                    anchors.verticalCenter: parent.verticalCenter
                    
                    BarText { 
                        id: numText
                        text: thisWorkspace.name
                        
                        fontFamily: Theme.get.fontFaceWorkspaces
                        fontWeight: Theme.get.fontWeightWorkspaces
                        fontSize: Theme.get.fontSizeWorkspaces
                        textColor: isActive ? Theme.get.workspaceColorActive : Theme.get.workspaceColorInactive
                        
                        shadowEnabled: Theme.get.shadowWorkspacesEnabled
                        shadowColor: Theme.get.shadowWorkspacesColor
                        shadowX: Theme.get.shadowWorkspacesX
                        shadowY: Theme.get.shadowWorkspacesY

                        anchors.centerIn: parent
                    }
                }

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
