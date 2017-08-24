import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
//import QtQuick.Dialogs 1.2
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.3
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
    onSetupSessionSignal: {runSetupSession(sessionName,selectedSession)}
    signal timeLeft(var tm)
    signal sessionTimeUpdate(var tm)
    onTimeLeft: {currentStepLeft.text = tm}
    function enableWalkControl(){currentWalkControl.enabled=true}
    //anchors.fill: parent
    //anchors.top: runSessionScene.gameWindowAnchorItem.top
    //property alias finishStep: finishStep
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
    property int    timeFooterBrth
    property color  borderColorFooterBrth
    property int    timeFooterHold
    property color  borderColorFooterHold
    property int    timeFooterWalk
    property color  borderColorFooterWalk
    property bool   noWalk: true
    property string triggerStepEventMark: ""
    property string triggerPressEventMark: ""
    property string nextStepName: "brth"
    //    function gotMarkSignal(name){
    //        triggerMark = name
    //    }
    property var stepsArOrig:[0,0,0,0]
    property var stepsAr
    function getStepIdsText(){
        return "<pre>" +
                "Distance in steps 1:<b>" + stepsAr[0] +
                            "  </b>2:<b>" + stepsAr[1] +
                            "  </b>3:<b>" + stepsAr[2] +
                            "  </b>4:<b>" + stepsAr[3] +
                "</pre>";
    }

    function updateBackSteps(stNb){
        stepsAr[hrPlot.lastBackStepNb] = stNb
        hrPlot.currentSession.event[hrPlot.lastBackEvebtNb][2] = stNb
        stepsIdsText.text = getStepIdsText()
    }
    function getSessionTime(){
        return sessionTime
    }
    function runSetupSession(sessionName, selectedSession){
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
                                border.width: isCurrent? dp(2): dp(6)
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
                        font.pixelSize: Math.round(dp(0.75 * parent.height))
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
                //TODO does it make sence to synchronyze with ending steps in SeaWolfControls ? Mutex?
                // Is some sort of race condition is possible here?
                // May be call markEvent from here instead of from the gauges state change?
                sessionTime++
                sessionTimeUpdate(sessionTime)
                // update heart rate information
                var hrValue = Math.round(heartRate.hr)
                hrPlot.currentSession.pulse.push(hrValue)
                hrPlot.timerUpdate(sessionTime, hrValue)
                if (triggerStepEventMark !== ""){
                    hrPlot.markEvent(triggerStepEventMark, sessionTime -1)
                    triggerStepEventMark = ""
                    //hrPlot.addPointToPlot(sessionTime, Math.round(heartRate.hr))
                }
                if (triggerPressEventMark === "contraction"){
                    hrPlot.markEvent(triggerPressEventMark, sessionTime -1)
                    triggerPressEventMark = ""
                }
            }
        }

        Item{
            id: sessionPlot
            Layout.preferredWidth:runSessionScene.width - dp(8)
            Layout.preferredHeight:runSessionScene.height / 2 - stepsIds.height
            anchors.horizontalCenter: parent.horizontalCenter

            SeaWolfPlot{
                id:hrPlot
                height: parent.height
                width:  parent.width
            }
        }
        Row{
            visible: gaugeWalk.maximumValue !== 0
            id: stepsIds
            Layout.preferredWidth: runSessionScene.width
            Layout.preferredHeight: SeaWolfInput.height
            Text{
                id: stepsIdsText
                text: getStepIdsText()
                font.pixelSize: dp(40)
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
                    id: startButton
                    z: 95
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
                        finishStep.enabled = true
                        finishStep.text= qsTr("Finish Step")
                        stopButton.enabled = true;
                        nextStepName = "brth"

                        //update walk steps
                        stepsAr = stepsArOrig
                        stepsIdsText.text = getStepIdsText()
                        //
                        hrPlot.currentSession = hrPlot.currentSessionOrig
                        hrPlot.lastBackStepNb = -1
                        hrPlot.init()
                        hrPlot.timerUpdate(0, Math.round(heartRate.hr))
                        oneTimer.start()
                        //console.log("Time=", Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss"))
                        console.log("Session:",hrPlot.currentSession.sessionName, "started:",hrPlot.currentSession.when)

                    }
                }
                MenuButton {
                    id: finishStep
                    z:95
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
                    visible: gaugeWalk.maximumValue === 0 ? false : true
                    gaugeName: "walk"
                    enterStateSndEffect: walkSnd
                    //gridView: sessionView
                    modelIndex: walkIndx
                    minAngle:     65
                    maxAngle:     175
                    anchors.centerIn: parent
                    gaugeModel: currentModel
                    nextGauge: gaugeBack
                    //gaugeWalkControl: container.finishStep
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
                    //gaugeWalkControl: container.finishStep
                    width:height
                    height:parent.height
                    visible: false
                }
                Text {
                    id: hrValue
                    z:100
                    font.pixelSize: dp(60); //font.bold: true
                    anchors.centerIn: parent
                    style: Text.Raised;
                    //color: "#3870BA"
                    color: "black"
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
                MenuButton {
                    id: stopButton
                    z:95
                    text: qsTr("Stop")
                    onClicked: {
                        //timerBrth.cycleIsOver(timerBrth)
                        //fileDialog.open()
                        oneTimer.stop()
                        currentGauge.stopVoiceTimers();
                        currentGauge.state = "initial";
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

                        finishStep.enabled = true
                        //stopButton.enabled = false
                        hrPlot.saveSession()
                        sessionTime = 0;
                        currentGauge.cycleIsOver(gaugeBrth)
                    }
                }
                Rectangle{
                    id:col2
                    color: "transparent"
                    //border.color: "black"
                    Layout.preferredHeight: runSessionScene.height / 3
                    Layout.preferredWidth: runSessionScene.width/4 - dp(20)
                    Layout.alignment: Qt.AlignRight
                    Image {
                        id: seaWolfButton
                        source: "../../assets/img/SeaWolf.png"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height:width
                    }
                }

                Component.onCompleted:{
                    currentWalkControl = finishStep
                    currentGauge       = gaugeBrth
                    currentHrPlot      = hrPlot
                }

            }

        }
    }
}
