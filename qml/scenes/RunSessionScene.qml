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
  property int brthIndx: 0
  property int holdIndx: 1
  property int walkIndx: 2
  property SeaWolfControls timerHold:    timerHold

  //===================================================
  // signal indicating that current session is selected
  signal sessionSelected(var selectedSession)
  //called by onSessionSelected
  function fillListModel(listModelSrc){
      console.log("**** In fillListModel width ", listModelSrc)
      var step;
      apneaModel.clear();
      for (step in listModelSrc){
          apneaModel.append({"time": listModelSrc[step].time, "typeName":listModelSrc[step].typeName, "isCurrent": false});
      }
      timerBrth.maximumValue = apneaModel.get(brthIndx).time
      timerHold.maximumValue = apneaModel.get(holdIndx).time
      timerWalk.maximumValue = apneaModel.get(walkIndx).time
  }
  //---------------------------------------------------

  //===================================================
  // signal indicating that footer needs update shown time values
  signal notifyFooter(int currentIndex)
  property int   timeFooterBrth
  property color borderColorFooterBrth
  property int   timeFooterHold
  property color borderColorFooterHold
  property int   timeFooterWalk
  property color borderColorFooterWalk
  property bool  noWalk: true

  //called by onNotifyFooter signal hangler
  function updateFooter(index) {
      var timeIndex = index - index % 3
      timeFooterBrth = apneaModel.get(timeIndex).time
      borderColorFooterBrth = index % 3 === brthIndx ? "white" : "black"
      timeFooterHold = apneaModel.get(timeIndex+1).time
      borderColorFooterHold = index % 3 === holdIndx ? "white" : "black"
      timeFooterWalk = apneaModel.get(timeIndex+2).time
      borderColorFooterWalk = index % 3 === walkIndx ? "white" : "black"
  }
  //---------------------------------------------------
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
      anchors.horizontalCenter: parent.horizontalCenter;

      // List elements are created dynamically, when fillListModel is called
      ListModel {
          id: apneaModel
          //the following 3 properties will be used as indexes
          //added something so user will not be confused if runs before configuring
          ListElement { time: 3; typeName: "brth";    isCurrent: false }
          ListElement { time: 4; typeName: "hold";    isCurrent: false }
          ListElement { time: 5; typeName: "walk";    isCurrent: false }
          ListElement { time: 6; typeName: "brth";    isCurrent: false }
          ListElement { time: 7; typeName: "hold";    isCurrent: false }
          ListElement { time: 8; typeName: "walk";    isCurrent: false }

//          ListElement { time: 3; typeName: "brth";    isCurrent: false }
//          ListElement { time: 4; typeName: "hold";    isCurrent: false }
//          ListElement { time: 0; typeName: "walk";    isCurrent: false }
//          ListElement { time: 6; typeName: "brth";    isCurrent: false }
//          ListElement { time: 7; typeName: "hold";    isCurrent: false }
//          ListElement { time: 0; typeName: "walk";    isCurrent: false }
      }


      GridView {
          id: sessionView
          width: parent.width
          //height: parent.height
          anchors.margins: 1
          anchors.bottom:viewFooter.top
          anchors.fill: container

          cellWidth: (parent.width - 2 * anchors.margins) /12 - 3
          cellHeight: cellWidth
          clip: true
          model: apneaModel
          delegate: apneaDelegate
          footer: viewFooter

          Component {
              id: apneaDelegate
              //property alias borderColor: wrapper.border.color
              Rectangle {

                  // find if show that cell big and notifyFooter about changes if cell is "brth"
                  function cellIsCurrent(index){
                      if (index === -1) return false
                      if (apneaModel.get(index).isCurrent){
                          notifyFooter(index)
                          return true
                      } else return false
                  }
                  property real myRadius: dp(5)
                  id: wrapper
                  z:     cellIsCurrent(index) ? 100:10
                  width: cellIsCurrent(index) ? 2* sessionView.cellWidth  : sessionView.cellWidth
                  height:cellIsCurrent(index)? 2* sessionView.cellHeight + myRadius: sessionView.cellHeight
                  radius:cellIsCurrent(index) ? 2 * myRadius: myRadius
                  color: { if (index == -1) return "grey"; runColors[apneaModel.get(index).typeName]}
                  border.color: { if (index == -1) return "grey"; apneaModel.get(index).isCurrent? "white": "black"}
                  border.width: 2
                  Text {
                      id:timeText
                      anchors.centerIn: parent
                      //font.pixelSize: dp(parent.height)
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
                  spacing: dp(5)
                  width: container.width - dp(2)
                  height:dp(40)

                  Rectangle { id: brthFooter; width: (container.width )/3 ; height:  parent.height; radius: parent.spacing
                      color: runColors.brth
                      border.color: borderColorFooterBrth
                      border.width: dp(2)
                      Text { anchors.centerIn: parent
                                 font.pixelSize: sp(18); text: qsTr("Breathe <b>%1</b> Sec").arg(timeFooterBrth); color: "white"; style: Text.Raised; styleColor: "black"  }
                      Behavior on border.color {ColorAnimation{duration:500}}
                  }
                  Rectangle { id: holdFooter; width: (container.width )/3 ; height:  parent.height; radius: parent.spacing
                      color: runColors.hold
                      border.color: borderColorFooterHold
                      border.width: dp(2)
                      Text { anchors.centerIn: parent
                                 font.pixelSize: sp(18); text: qsTr("Hold <b>%1</b> Sec").arg(timeFooterHold); color: "white"; style: Text.Raised; styleColor: "black"  }
                      Behavior on border.color {ColorAnimation{duration:500}}
                  }
                  Rectangle { id: walkFooter; width: (container.width )/3 ; height:  parent.height; radius: parent.spacing
                      color: runColors.walk
                      border.color: borderColorFooterWalk
                      border.width: dp(2)
                      Text { anchors.centerIn: parent
                                 font.pixelSize: sp(18); text: qsTr("Walk <b>%1</b> Sec").arg(timeFooterWalk); color: "white"; style: Text.Raised; styleColor: "black"  }
                      Behavior on border.color {ColorAnimation{duration:500}}
                  }
              }
          }
      }
      MenuButton {
          id: button1
          z: 100
          text: qsTr("Start")
          anchors.leftMargin: dp(8)
          anchors.bottom: container.bottom
          anchors.bottomMargin: dp(60)
          anchors.left: container.left
          //isDefault: true
          //anchors.horizontalCenter: root.horizontalCenter
          enabled: true
          clip: true

          onClicked: {
              timerBrth.modelIndex = 0

              timerBrth.state = "stateRun";
              timerBrth.isCurrent = true
              //apneaModel.get(0).isCurrent = true
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
          anchors.bottomMargin: dp(60)
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
          anchors.bottomMargin: dp(60)
          onClicked: {
              timerBrth.state = "initial"
              timerHold.state = "initial"
              timerWalk.state = "initial"
              //apneaModel.get(apneaModel.index).isCurrent = false
              //apneaModel.index = 0

              walkControl.enabled = true
              button2.enabled = false
          }
      }
      SoundEffectVPlay {
              id: brthSnd
              volume: 1.0
              source: "../../assets/sounds/breathe.wav"
      }
      SeaWolfControls {
          id:timerBrth
          z:100
          gaugeName: "brth"
          enterStateSndEffect: brthSnd
          gridView: sessionView
          modelIndex: brthIndx
          minAngle:     185
          // different angles, depenging if "walk" part is presented
          maxAngle:     timerWalk.maximumValue === 0 ? 355 : 295
          anchors.centerIn: parent
          gaugeModel: apneaModel
          nextGauge:timerHold
      }
      SoundEffectVPlay {
              id: holdSnd
              volume: 1.0
              source: "../../assets/sounds/hold.wav"
      }
      SeaWolfControls {
          id:timerHold
          z:100
          gaugeName:  "hold"
          enterStateSndEffect: holdSnd
          gridView: sessionView
          modelIndex: holdIndx
          // different angles, depenging if "walk" part is presented
          minAngle:     timerWalk.maximumValue === 0 ? 5 :-55
          maxAngle:     timerWalk.maximumValue === 0 ? 175 : 55
          anchors.centerIn: parent
          gaugeModel: apneaModel
          nextGauge: timerWalk.maximumValue === 0 ? timerBrth : timerWalk
      }

      SoundEffectVPlay {
              id: walkSnd
              volume: 1.0
              source: "../../assets/sounds/walk.wav"
      }
      SeaWolfControls {
          id:timerWalk
          z:100
          gaugeName: "walk"
          enterStateSndEffect: walkSnd
          gridView: sessionView
          modelIndex: walkIndx
          minAngle:     65
          maxAngle:     175
          anchors.centerIn: parent
          gaugeModel: apneaModel
          nextGauge: timerBrth
          //gaugeWalkControl: container.walkControl
      }
  }
}
