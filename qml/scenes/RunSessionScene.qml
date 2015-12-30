import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Window 2.2
import QtQuick.Layouts 1.2
import QtMultimedia 5.5
import VPlay 2.0
import VPlayApps 1.0
import "../common"
SceneBase {
  id: runSessionScene
  property var runColors: {"brth" : "red", "hold" : "green", "walk" : "blue"}
  property SeaWolfControls timerHold:    timerHold
  //active: true
  //anchors.right: seriesConfig.left
  //anchors.bottom: parent.bottom
  //anchors.left: parent.left
  //anchors.top: parent.top
  //z: 5
  MenuButton {
      z:100
      text: "Back"
      // anchor the button to the gameWindowAnchorItem to be on the edge of the screen on any device
      anchors.right: runSessionScene.gameWindowAnchorItem.right
      anchors.rightMargin: 10
      anchors.top: runSessionScene.gameWindowAnchorItem.top
      anchors.topMargin: 10
      onClicked: backButtonPressed()
  }

  Item {
      id: container
      Image {
          id: bkgImg
          source: "../../assets/img/surface.png"
          fillMode: Image.PreserveAspectCrop
          opacity: 0.4
          anchors.fill: parent
      }
      width: parent.width
      height: parent.height
      anchors.fill: parent
//            anchors.rightMargin: 0
//            anchors.bottomMargin: 0
//            anchors.leftMargin: 0
//            //anchors.top: tocContainer.bottom
//            anchors.topMargin: 5
      anchors.horizontalCenter: parent.horizontalCenter;
      //property alias walkControl: walkControl
      //height: Math.min(root.width, root.height)
      ListModel {
          id: apneaModel
          //the following 3 properties will be used as indexes
          property int breathe: 0
          property int hold: 1
          property int walk: 2
          ListElement { time: 11; typeName: "brth";    myColor: "red";   isCurrent: false }
          ListElement { time: 12; typeName: "hold";    myColor: "blue";  isCurrent: false }
          ListElement { time: 13; typeName: "walk";    myColor: "green"; isCurrent: false }

          ListElement { time: 14; typeName: "brth";    myColor: "red";   isCurrent: false }
          ListElement { time: 11; typeName: "hold";    myColor: "blue";  isCurrent: false }
          ListElement { time: 12; typeName: "walk";    myColor: "green"; isCurrent: false }

          ListElement { time: 10; typeName: "brth";    myColor: "red";   isCurrent: false }
          ListElement { time: 16; typeName: "hold";    myColor: "blue";  isCurrent: false }
          ListElement { time: 18; typeName: "walk";    myColor: "green"; isCurrent: false }

          ListElement { time: 14; typeName: "brth";    myColor: "red";   isCurrent: false }
          ListElement { time: 18; typeName: "hold";    myColor: "blue";  isCurrent: false }
          ListElement { time: 12; typeName: "walk";    myColor: "green"; isCurrent: false }

          ListElement { time: 10; typeName: "brth";    myColor: "red";   isCurrent: false }
          ListElement { time: 16; typeName: "hold";    myColor: "blue";  isCurrent: false }
          ListElement { time: 18; typeName: "walk";    myColor: "green"; isCurrent: false }

          ListElement { time: 14; typeName: "brth";    myColor: "red";   isCurrent: false }
          ListElement { time: 11; typeName: "hold";    myColor: "blue";  isCurrent: false }
          ListElement { time: 12; typeName: "walk";    myColor: "green"; isCurrent: false }

          ListElement { time: 10; typeName: "brth";    myColor: "red";   isCurrent: false }
          ListElement { time: 16; typeName: "hold";    myColor: "blue";  isCurrent: false }
          ListElement { time: 18; typeName: "walk";    myColor: "green"; isCurrent: false }

          ListElement { time: 14; typeName: "brth";    myColor: "red";   isCurrent: false }
          ListElement { time: 11; typeName: "hold";    myColor: "blue";  isCurrent: false }
          ListElement { time: 12; typeName: "walk";    myColor: "green"; isCurrent: false }
      }


      GridView {
          id: view
          width: parent.width
          //height: parent.height
          anchors.rightMargin: 1
          anchors.bottomMargin: 1
          anchors.leftMargin: 1
          anchors.topMargin: 46
          anchors.bottom:viewFooter.top
          anchors.fill: parent

          cellWidth: dp((parent.width - 2 * anchors.margins) /12 - 3)
          cellHeight: dp(40)
          clip: true
          model: apneaModel
          delegate: apneaDelegate
          footer: viewFooter
          property int breatheFooterTime: model.get(0).time
          property int holdFooterTime:    model.get(1).time
          property int walkFooterTime:    model.get(2).time


          Component {
              id: apneaDelegate
              //property alias borderColor: wrapper.border.color
              Rectangle {

                  // find if show that cell big
                  function testCellIfCurrent(index){
                     if (apneaModel.get(index).isCurrent) return true
//                       if ((index > 1) && (index < apneaModel.count -1) && apneaModel.get(index - 1).isCurrent)
//                           return true
                     else
                         return false
                  }

                  property real myRadius: dp(5)
                  id: wrapper
                  z: testCellIfCurrent(index) ? 100:10
                  width: testCellIfCurrent(index) ? 2* view.cellWidth : view.cellWidth -myRadius
                  height: testCellIfCurrent(index)? 2* view.cellHeight + myRadius: view.cellHeight -myRadius
                  radius:testCellIfCurrent(index) ? 2 * myRadius: myRadius
                  color: apneaModel.get(index).myColor
                  border.color: apneaModel.get(index).isCurrent? "white": "black"
                  border.width: 2
                  //                    gradient: Gradient {
                  //                        GradientStop { position: 0.0; color: "#f8306a" }
                  //                        GradientStop { position: 1.0; color: "#fb5b40" }
                  //                    }

                  Text {
                      id:timeText
                      anchors.centerIn: parent
                      font.pixelSize: parent.height - 2
                      text: "<b>" + time + "</b>"; color: "white"; style: Text.Raised; styleColor: "black"
                      //text: index + ". " + typeName + " " + time + "sec."

                  }
                  Behavior on width {NumberAnimation{duration:500}}
                  Behavior on height {NumberAnimation{duration:500}}
              }
          }
          Component {
              //anchors.horizontalCenter: container.horizontalCenter
              id: viewFooter
              RowLayout {
                  id: viewFooterLayout
                  spacing: 5
                  width: container.width - 2
                  height:40

                  Rectangle { id: breatheFooter; width: (container.width )/3 ; height:  parent.height; radius: parent.spacing
                              color: "red"
                              border.color: "black"
                              border.width: 2
                              Text { anchors.centerIn: parent
                                         font.pointSize: 18; text: qsTr("Breathe <b>%1</b> Sec").arg(view.breatheFooterTime); color: "white"; style: Text.Raised; styleColor: "black"  }
                  }
                  Rectangle { id: holdFooter; width: (container.width )/3 ; height:  parent.height; radius: parent.spacing
                              color: "blue"
                              border.color: "black"
                              border.width: 2
                              Text { anchors.centerIn: parent
                                         font.pointSize: 18; text: qsTr("Hold <b>%1</b> Sec").arg(view.holdFooterTime); color: "white"; style: Text.Raised; styleColor: "black"  }
                  }
                  Rectangle { id: walkFooter; width: (container.width )/3 ; height:  parent.height; radius: parent.spacing
                              color: "green"
                              border.color: "black"
                              border.width: 2
                              Text { anchors.centerIn: parent
                                         font.pointSize: 18; text: qsTr("Walk <b>%1</b> Sec").arg(view.walkFooterTime); color: "white"; style: Text.Raised; styleColor: "black"  }
                  }
              }
          }
      }
      MenuButton {
          id: button1
          z: 100
          text: qsTr("Start")
          anchors.leftMargin: 8
          anchors.bottom: container.bottom
          anchors.bottomMargin: 60
          anchors.left: container.left
          //isDefault: true
          //anchors.horizontalCenter: root.horizontalCenter
          enabled: true
          clip: true

          onClicked: {
              timerBreathe.modelIndex = 0
              timerBreathe.state = "stateRun";
              timerBreathe.isCurrent = true
              apneaModel.get(0).isCurrent = true
              walkControl.enabled = false
              button2.enabled = true
          }
      }

      MenuButton {
          id: walkControl
          z:100
          text: qsTr("Finish Walk")
          enabled: true
          anchors.left: button1.right
          anchors.bottom: container.bottom
          anchors.bottomMargin: 60
          onClicked: {
              if (walkControl.text === qsTr("Finish Walk")){
                  //enabled = false;
                  timerWalk.state = "initial";
                  timerWalk.maximumValue = timerWalk.value;
                  walkControl.text = qsTr("Breath")
                  walkControl.enabled = true
              }
         }
      }
      MenuButton {
          id: button2
          z:100
          text: qsTr("Walk Back")
          anchors.left: walkControl.right
          anchors.bottom: container.bottom
          anchors.bottomMargin: 60
          onClicked: {
              timerBreathe.state = "initial"
              timerHold.state = "initial"
              timerWalk.state = "initial"
              //apneaModel.get(apneaModel.index).isCurrent = false
              //apneaModel.index = 0

              walkControl.enabled = true
              button2.enabled = false
          }
      }
      SeaWolfControls {
          id:timerBreathe
          z:100
          gaugeName: "brth"
          gridView: view
          modelIndex: apneaModel.breathe
          minAngle:     185
          maxAngle:     295
          anchors.centerIn: parent
          gaugeModel: apneaModel
          nextGauge:timerHold
      }
      SeaWolfControls {
          id:timerHold
          z:100
          gaugeName:  "hold"
          gridView: view
          modelIndex: apneaModel.hold
          minAngle:     -55
          maxAngle:     55
          anchors.centerIn: parent
          gaugeModel: apneaModel
          nextGauge: timerWalk
      }

      SeaWolfControls {
          id:timerWalk
          z:100
          gaugeName: "walk"
          gridView: view
          modelIndex: apneaModel.walk
          minAngle:     65
          maxAngle:     175
          anchors.centerIn: parent
          gaugeModel: apneaModel
          nextGauge: timerBreathe
          //gaugeWalkControl: container.walkControl
      }
  }
}
