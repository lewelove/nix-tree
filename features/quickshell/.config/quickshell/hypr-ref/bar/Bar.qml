import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "blocks" as Blocks
import "root:/"

Scope {
  Variants {
    model: Quickshell.screens
  
    PanelWindow {
      id: bar
      property var modelData
      screen: modelData

      color: "transparent"
      
      property int shadowSize: 6
      implicitHeight: Theme.get.barHeight + (Theme.get.onTop ? Theme.get.barMarginTop : Theme.get.barMarginBottom) + shadowSize
      
      exclusiveZone: Theme.get.barHeight + (Theme.get.onTop ? Theme.get.barMarginTop : Theme.get.barMarginBottom)
      
      visible: true 

      Item {
        id: barContainer
        
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: Theme.get.onTop ? parent.top : undefined
        anchors.bottom: !Theme.get.onTop ? parent.bottom : undefined
        anchors.leftMargin: Theme.get.barMarginLeft
        anchors.rightMargin: Theme.get.barMarginRight
        anchors.topMargin: Theme.get.onTop ? Theme.get.barMarginTop : 0
        anchors.bottomMargin: !Theme.get.onTop ? Theme.get.barMarginBottom : 0
        height: Theme.get.barHeight
        
        opacity: Theme.get.screensaverActive ? 0 : 1

        Behavior on opacity {
          NumberAnimation { 
            duration: Theme.get.screensaverFadeTime
            easing.type: Easing.InOutCubic
          }
        }

        RectangularShadow {
          anchors.fill: bgRect
          radius: bgRect.radius
          blur: bar.shadowSize
          spread: 0
          color: "#99000000"
        }

        Rectangle {
          id: bgRect
          anchors.fill: parent
          color: Theme.get.barBgColor
          radius: Theme.get.barRadius
        }

        RowLayout {
          id: allBlocks
          anchors.fill: parent
          spacing: 0
          anchors.leftMargin: Theme.get.barPaddingX
          anchors.rightMargin: Theme.get.barPaddingX
    
          Row {
            id: leftBlocks
            spacing: Theme.get.sectionSpacingLeft
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            Blocks.SpecialWorkspaces {}
            Blocks.Workspaces {}
          }

          Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
          }
    
          RowLayout {
            id: rightBlocks
            spacing: Theme.get.sectionSpacingRight
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Blocks.Date {}
            Blocks.Time {}
          }
        }
      }

      IpcHandler {
        target: "bar"
        function toggleVis(): void { barContainer.opacity = barContainer.opacity > 0 ? 0 : 1; }
      }
    
      anchors {
        top: Theme.get.onTop
        bottom: !Theme.get.onTop
        left: true
        right: true
      }
    }
  }
}
