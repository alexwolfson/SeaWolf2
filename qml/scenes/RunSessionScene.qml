import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.2
import QtMultimedia 5.6
import QtQml 2.2
import QtCharts 2.1

//import VPlay 2.0
//import VPlayApps 1.0
import "../common"
//import com.seawolf.qmlfileaccess 1.0
//import "../common/draw.
SceneBase {

    id: runSessionScene
    signal setupSessionSignal(var sessionName, var selectedSession)
    onSetupSessionSignal: {setupSession(sessionName,selectedSession)}
    signal timeLeft(var tm)
    onTimeLeft: {currentStepLeft.text = tm}
    function enableWalkControl(){currentWalkControl.enabled=true}
    //anchors.fill: parent
    //anchors.top: runSessionScene.gameWindowAnchorItem.top
    //property alias walkControl: walkControl
    property int brthIndx: 0
    property int holdIndx: 1
    property int walkIndx: 2
    property int backIndx: 3
    property SeaWolfControls currentGauge
    property var runGauge
    //property alias hrPoints: hrSeries
    property int sessionTime: 0
    //The set of properties that are created to get around the
    // loading of the Tab. Not all of the Tab's elements are simultaniously available
    // so we create top level properties that are set by Component.onComplete() when lower level elements are created
    property MenuButton      currentWalkControl
    property SeaWolfPlot     currentHrPlot
    property ListModel       currentModel
    property SeaWolfControls currentGaugeBrth
    property SeaWolfControls currentGaugeHold
    property SeaWolfControls currentGaugeWalk
    property SeaWolfControls currentGaugeBack

    //called by onSessionSelected
    property int   timeFooterBrth
    property color borderColorFooterBrth
    property int   timeFooterHold
    property color borderColorFooterHold
    property int   timeFooterWalk
    property color borderColorFooterWalk
    property bool  noWalk: true


    function getSessionTime(){
        return sessionTime
    }
    function setupSession(sessionName, selectedSession){
        //console.log("**** In setupSession width ", sessionName, ":", selectedSession)
        var step;
        currentModel.clear();
        //hrPlot.sessionDuration = 0.0
        for (step in selectedSession){
            currentModel.append({"time": selectedSession[step].time, "typeName":selectedSession[step].typeName, "isCurrent": false});
            //hrPlot.sessionDuration += selectedSession[step].time;
        }
        currentGaugeBrth.maximumValue = currentModel.get(brthIndx).time
        currentGaugeHold.maximumValue = currentModel.get(holdIndx).time
        currentGaugeWalk.maximumValue = currentModel.get(walkIndx).time
        currentGaugeBack.maximumValue = currentModel.get(backIndx).time
        //currentSession.sessionName = sessionName
    }
    // List elements are created dynamically, when fillListModel is called
    ColumnLayout{  //top level Column
        id:runColumn
        anchors.top:parent.top
        //anchors.topMargin: 3 * sessionView.cellWidth -spacing //dp(120)
        width:parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: dp(8)
        Item {
            id: apneaTimes
            property int nbOfCellsInRow: 16
            property int nbOfRows: 2
            property real smallCellWidth: (parent.width - (nbOfCellsInRow +3)*apneaTimesLayout.spacing) /(nbOfCellsInRow +4)
            property real smallCellHeight: smallCellWidth *0.75

            Layout.preferredWidth:parent.width
            Layout.preferredHeight: (smallCellHeight + apneaTimesLayout.spacing) * nbOfRows
            ListModel {
                id: apneaModel
                //the following 3 properties will be used as indexes
                //added something so user will not be confused if runs before configuring
                //          ListElement { time: 3; typeName: "brth";    isCurrent: false }
                //          ListElement { time: 4; typeName: "hold";    isCurrent: false }
                //          ListElement { time: 5; typeName: "walk";    isCurrent: false }
                //          ListElement { time: 6; typeName: "brth";    isCurrent: false }
                //          ListElement { time: 7; typeName: "hold";    isCurrent: false }
                //          ListElement { time: 8; typeName: "walk";    isCurrent: false }
                //          ListElement { time: 9; typeName: "brth";    isCurrent: false }
                //          ListElement { time:10; typeName: "hold";    isCurrent: false }
                //          ListElement { time:11; typeName: "walk";    isCurrent: false }

                ListElement { time: 3; typeName: "brth";    isCurrent: false }
                ListElement { time: 4; typeName: "hold";    isCurrent: false }
                ListElement { time: 5; typeName: "walk";    isCurrent: false }
                ListElement { time: 5; typeName: "back";    isCurrent: false }
                ListElement { time: 6; typeName: "brth";    isCurrent: false }
                ListElement { time: 7; typeName: "hold";    isCurrent: false }
                ListElement { time: 8; typeName: "walk";    isCurrent: false }
                ListElement { time: 8; typeName: "back";    isCurrent: false }
                ListElement { time: 9; typeName: "brth";    isCurrent: false }
                ListElement { time:10; typeName: "hold";    isCurrent: false }
                ListElement { time:11; typeName: "walk";    isCurrent: false }
                ListElement { time:11; typeName: "back";    isCurrent: false }
                Component.onCompleted: {
                    currentModel = apneaModel
                }
            }

            RowLayout{
                id: apneaTimesLayout
                width: parent.width
                height: parent.height
                spacing: dp(4)
                Rectangle{
                    id: currentStepLeft
                    property alias text:txtLeft.text
                    z:1
                    Layout.preferredWidth:  apneaTimes.smallCellWidth * 2
                    Layout.preferredHeight: apneaTimes.smallCellHeight * 2
                    //8 cells + 2 double sized cell for that Rectangle in a row
                    radius: dp(8)
                    border.width: dp(4)
                    border.color: currentGauge.needleColor
                    Text{ id:txtLeft
                        anchors.centerIn: parent
                        font.pixelSize: Math.round(dp(0.75 * parent.height))
                        text: Math.round(currentGauge.maximumValue - currentGauge.value)
                    }
                }

                GridView {
                    //z:50
                    id: sessionView
                    cellWidth:  apneaTimes.smallCellWidth
                    cellHeight: apneaTimes.smallCellHeight
                    Layout.preferredWidth:  cellWidth  * apneaTimes.nbOfCellsInRow + (apneaTimes.nbOfCellsInRow +1) * apneaTimesLayout.spacing
                    Layout.preferredHeight: cellHeight * apneaTimes.nbOfRows + (apneaTimes.nbOfRows + 1) * apneaTimesLayout.spacing;
                    //clip: true
                    model: currentModel
                    delegate: Component {
                        Loader{
                            Rectangle {

                                property real myRadius: dp(5)
                                id: wrapper
                                z:      {var zdeep=isCurrent ? 100:95; /*console.log("isCurrent, index, zdeep", isCurrent, index, zdeep);*/return zdeep}
                                width:  /*isCurrent ? 2* sessionView.cellWidth :*/ sessionView.cellWidth - dp(4)
                                height: sessionView.cellHeight
                                //height: sessionView.cellHeihght - dp(4)
                                radius: /*isCurrent ? 2 * myRadius:*/ myRadius
                                border.color: { if (index == -1) return "grey";
                                    return hrPlot.runColors[currentModel.get(index).typeName];
                                }
                                color: index == -1 ? "grey" : "white" //{ if (index == -1) return "grey"; isCurrent? "white": "black"}
                                border.width: isCurrent? dp(6): dp(2)
                                function whatToShow() {

                                    var wts = /*isCurrent ? Math.round(time - runGauge[index % runGauge.length].value) :*/ time
                                    //timeLeft(wts)
                                    return wts
                                }
                                Text {
                                    id:timeText
                                    anchors.centerIn: parent
                                    //font.pointSize: Math.round(parent.height/4)
                                    font.pixelSize: Math.round(dp(0.7 * parent.height))
                                    text: "<b>" + parent.whatToShow() + "</b>"; color: "black"; /*style: Text.Raised; styleColor: "black"*/
                                    //text: index + ". " + typeName + " " + time + "sec."

                                }
                                Behavior on border.color {ColorAnimation{duration:500}}
                                Behavior on border.width {NumberAnimation{duration:500}}
                            }
                        }
                    }

                }
                Rectangle{
                    id: currentStepSpent
                    property alias text:txtSpent.text
                    Layout.preferredWidth:  apneaTimes.smallCellWidth * 2
                    Layout.preferredHeight: apneaTimes.smallCellHeight * 2
                    z:1
                    //8 cells + 2 double sized cell for that Rectangle in a row
                    //            width: (parent.width - 13 * anchors.margins) / 5
                    //            height: width
                    //            anchors.margins: dp(4)
                    //            anchors.top:parent.top
                    //            anchors.right:parent.right
                    radius: dp(8)
                    border.width: dp(4)
                    border.color: currentGauge.needleColor
                    Text{ id:txtSpent
                        anchors.centerIn: parent
                        font.pixelSize: Math.round(dp(0.5 * parent.height))
                        text: Math.round(currentGauge.value)
                    }
                }
            }
            // End Of Apnea Model and times grid
        }


        Timer{
            id: oneTimer
            interval:1000
            repeat:true

            onTriggered:{
                sessionTime++
                // update heart rate information
                hrPlot.currentSession.pulse.push( Math.round(heartRate.hr))
                hrPlot.markEvent(currentGauge.gaugeName)
                //hrPlot.currentHrSeries.append(sessionTime, Math.round(heartRate.hr))
                //hrPlot.showSessionGraph(hrPlot.currentSession, currentGauge.gaugeName)
                hrPlot.showSessionGraph(hrPlot.currentSession)
            }
        }
        Item{
            id: sessionPlot
            Layout.preferredWidth:runSessionScene.width
            Layout.preferredHeight:runSessionScene.height / 2


            SeaWolfPlot{
                id:hrPlot
                height: parent.height
                width:  parent.width
            }
        }
        RowLayout{

            ColumnLayout{
                id:col1
                Layout.preferredHeight: runSessionScene.height / 3
                Layout.preferredWidth: runSessionScene.width/4
                Layout.alignment: Qt.AlignHCenter

                spacing:dp(8)
                //anchors.horizontalCenter: parent.horizontalCenter
                MenuButton {
                    id: button1
                    z: 100
                    text: qsTr("Start")
                    enabled: true
                    clip: true
                    onClicked: {
                        currentGauge = currentGaugeBrth
                        currentModel.get(0).isCurrent = true

                        gaugeBrth.isCurrent = true
                        gaugeBrth.modelIndex = 0
                        gaugeHold.modelIndex = 1
                        gaugeWalk.modelIndex = 2
                        gaugeBack.modelIndex = 3                        //currentModel.get(0).isCurrent = true

                        gaugeBrth.maximumValue = currentModel.get(brthIndx).time
                        gaugeHold.maximumValue = currentModel.get(holdIndx).time
                        gaugeWalk.maximumValue = currentModel.get(walkIndx).time
                        gaugeBack.maximumValue = currentModel.get(backIndx).time
                        gaugeBrth.state = "stateRun"
                        gaugeBrth.value = 0
                        gaugeHold.state = "initial"
                        gaugeHold.value = 0
                        gaugeWalk.state = "initial"
                        gaugeWalk.value = 0
                        gaugeBack.state = "initial"
                        gaugeBack.value = 0
                        walkControl.enabled = true
                        walkControl.text= qsTr("Finish Step")
                        button2.enabled = true;
                        hrPlot.init()
                        oneTimer.start()
                        //console.log("Time=", Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss"))
                        console.log("Session:",hrPlot.currentSession.sessionName, "started:",hrPlot.currentSession.when)

                    }
                }

                MenuButton {
                    id: button2
                    z:100
                    text: qsTr("Stop")
                    onClicked: {
                        //timerBrth.sessionIsOver(timerBrth)
                        //fileDialog.open()
                        gaugeBrth.maximumValue = currentModel.get(brthIndx).time
                        gaugeHold.maximumValue = currentModel.get(holdIndx).time
                        gaugeWalk.maximumValue = currentModel.get(walkIndx).time
                        gaugeBack.maximumValue = currentModel.get(backIndx).time
                        gaugeBrth.state = "initial"
                        gaugeBrth.value = 0
                        gaugeHold.state = "initial"
                        gaugeHold.value = 0
                        gaugeWalk.state = "initial"
                        gaugeWalk.value = 0
                        gaugeBack.state = "initial"
                        gaugeBack.value = 0
                        //currentModel.get(currentModel.index).isCurrent = false
                        //currentModel.index = 0

                        walkControl.enabled = true
                        //button2.enabled = false
                    }
                }
                MenuButton {
                    id: walkControl
                    z:100
                    text: qsTr("Finish Step")
                    enabled: true
                    onClicked: {
                        currentGauge.stopVoiceTimers();
                        currentGauge.state = "initial";
                    }
                }
            }
            Item {
                id: gauges
                Layout.preferredHeight: runSessionScene.height / 3
                Layout.preferredWidth: runSessionScene.width * 0.5

                SoundEffect {
                    id: brthSnd
                    volume: 1.0
                    source: "../../assets/sounds/breathe.wav"
                }
                SeaWolfControls {
                    id:gaugeBrth
                    z:95
                    gaugeName: "brth"
                    enterStateSndEffect: brthSnd
                    //gridView: sessionView
                    modelIndex: brthIndx
                    minAngle:     185
                    // different angles, depenging if "walk" part is presented
                    maxAngle:     gaugeWalk.maximumValue === 0 ? 355 : 295
                    anchors.centerIn: parent
                    gaugeModel: currentModel
                    nextGauge:gaugeHold
                    width:height
                    height:parent.height
                }
                SoundEffect {
                    id: holdSnd
                    volume: 1.0
                    source: "../../assets/sounds/hold.wav"
                }
                SeaWolfControls {
                    id:gaugeHold
                    z:95
                    gaugeName:  "hold"
                    enterStateSndEffect: holdSnd
                    //gridView: sessionView
                    modelIndex: holdIndx
                    // different angles, depenging if "walk" part is presented
                    minAngle:     gaugeWalk.maximumValue === 0 ? 5 :-55
                    maxAngle:     gaugeWalk.maximumValue === 0 ? 175 : 55
                    anchors.centerIn: parent
                    gaugeModel: currentModel
                    nextGauge: gaugeWalk.maximumValue === 0 ? gaugeBrth : gaugeWalk
                    width:height
                    height:parent.height
                }

                SoundEffect {
                    id: walkSnd
                    volume: 1.0
                    source: "../../assets/sounds/walk.wav"
                }
                SeaWolfControls {
                    id:gaugeWalk
                    z:95
                    gaugeName: "walk"
                    enterStateSndEffect: walkSnd
                    //gridView: sessionView
                    modelIndex: walkIndx
                    minAngle:     65
                    maxAngle:     175
                    anchors.centerIn: parent
                    gaugeModel: currentModel
                    nextGauge: gaugeBack
                    //gaugeWalkControl: container.walkControl
                    width:height
                    height:parent.height
                }
                SoundEffect {
                    id: backSnd
                    volume: 1.0
                    source: "../../assets/sounds/back.wav"
                }
                SeaWolfControls {
                    id:gaugeBack
                    z:95
                    gaugeName: "back"
                    enterStateSndEffect: backSnd
                    //gridView: sessionView
                    modelIndex: backIndx
                    minAngle:     65
                    maxAngle:     175
                    anchors.centerIn: parent
                    gaugeModel: currentModel
                    nextGauge: gaugeBrth
                    //gaugeWalkControl: container.walkControl
                    width:height
                    height:parent.height
                    visible: false
                }
                Text {
                    id: hrValue
                    z:100
                    font.pixelSize: dp(45); font.bold: true
                    anchors.centerIn: parent
                    style: Text.Raised;
                    color: "white" //"#3870BA"
                    text: heartRate.hr
                    onTextChanged: {
                        //              if (heartRate.hr > 0 && updatei != null && heartRate.numDevices() > 0) {
                        //                  updatei.destroy()
                        //              }
                    }
                }
                Component.onCompleted: {
                    currentGaugeBrth=gaugeBrth
                    currentGaugeHold=gaugeHold
                    currentGaugeWalk=gaugeWalk
                    currentGaugeBack=gaugeBack
                    runGauge = [currentGaugeBrth, currentGaugeHold, currentGaugeWalk, currentGaugeBack];
                    root.typesDim = runGauge.length
                }

            } // End of gauges

            ColumnLayout{
                id:col2
                Layout.preferredHeight: runSessionScene.height / 3
                Layout.preferredWidth: runSessionScene.width/4
                Layout.alignment: Qt.AlignHCenter

                //anchors.horizontalCenter: parent.horizontalCenter
                spacing:dp(8)
                MenuButton{
                    id: note1
                    z:100
                    text: qsTr("-Medit")
                    onClicked: {
                        //hrPlot.currentSession.event.push([myEventsNm2Nb["EndOfMeditativeZone"], Math.round(currentGauge.value)])
                        hrPlot.markEvent("EndOfMeditativeZone")
                    }
                    enabled:true
                }
                MenuButton{
                    id: note2
                    z:100
                    text: qsTr("-Cmfrt")
                    onClicked: {
                        //console.log("value=", Math.round(currentGauge.value))
                        hrPlot.markEvent("EndOfComfortZone")
                        //AWDEDUG
                        //showSessionGraph(currentSession, chartView)

                    }
                    enabled:true
                }
                MenuButton{
                    id: note3
                    z:100
                    text: qsTr("Cntrct")
                    onClicked: {
                        //console.log("value=", Math.round(currentGauge.value))
                        hrPlot.markEvent("Contraction")
                    }
                    enabled:true
                }
            }
            Component.onCompleted:{
                currentWalkControl = walkControl
                currentGauge       = gaugeBrth
                currentHrPlot      = hrPlot
            }

        }
    }
}

