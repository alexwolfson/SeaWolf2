import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
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
    property int    timeFooterBrth
    property color  borderColorFooterBrth
    property int    timeFooterHold
    property color  borderColorFooterHold
    property int    timeFooterWalk
    property color  borderColorFooterWalk
    property bool   noWalk: true
    property string triggerMark: ""
    property string nextStepName: "brth"
    //    function gotMarkSignal(name){
    //        triggerMark = name
    //    }


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
                // update heart rate information
                hrPlot.currentSession.pulse.push( Math.round(heartRate.hr))
                //hrPlot.lastStepEventTm = sessionTime

                hrPlot.addPointToPlot(sessionTime, Math.round(heartRate.hr))
                hrPlot.rangeSliderUpdate()

                if (triggerMark !== ""){
                    hrPlot.markEvent(triggerMark, sessionTime)
                    triggerMark = ""
                    //hrPlot.addPointToPlot(sessionTime, Math.round(heartRate.hr))
                }

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
                        nextStepName = "brth"
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

            Rectangle{
                id:col2
                color: "transparent"
                //border.color: "black"
                Layout.preferredHeight: runSessionScene.height / 3
                Layout.preferredWidth: runSessionScene.width/4 - dp(20)
                Layout.alignment: Qt.AlignRight

//                Slider {
//                    id: discomfortSlider
//                    value: 0.5
//                    from:0
//                    to:10
//                    implicitHeight: dp(20)
//                    background: Rectangle {
//                        x: discomfortSlider.leftPadding
//                        y: discomfortSlider.topPadding + discomfortSlider.availableHeight / 2 - height / 2
//                        implicitWidth: dp(200)
//                        implicitHeight: dp(20)
//                        width: discomfortSlider.availableWidth
//                        height: implicitHeight
//                        radius: dp(4)
//                        //color: "#bdbebf"

//                        Rectangle {
//                            width: discomfortSlider.visualPosition * parent.width
//                            height: parent.height
//                            color: "#21be2b"
//                            radius: 2
//                            gradient: Gradient {
//                                GradientStop {
//                                    position: 0.00;
//                                    color: "blue";
//                                }
//                                GradientStop {
//                                    position: 1.00;
//                                    color: "red";
//                                }
//                            }
//                        }
//                    }

//                    handle: Rectangle {
//                        x: discomfortSlider.leftPadding + discomfortSlider.visualPosition * (discomfortSlider.availableWidth - width)
//                        y: discomfortSlider.topPadding + discomfortSlider.availableHeight / 2 - height / 2
//                        implicitWidth: dp(120)
//                        implicitHeight: dp(120)
//                        radius: dp(60)
//                        color: discomfortSlider.pressed ? "red" : "orange"
//                        border.color: "#bdbebf"
//                    }
//                }
                //                Slider{
                //                    id: discomfortSlider
                //                    enabled: true
                //                    visible: true
                //                    //anchors.left:spinBox.right
                //                    //anchors.leftMargin: dp(10)
                //                    //enabled: type=="spinBox"
                //                    //visible: type=="spinBox"
                //                    anchors.horizontalCenter: parent.horizontalCenter
                //                    width: dp(20)
                //                    height: parent.height
                //                    //Layout.preferredHeight: parent.height
                //                    //Layout.preferredWidth:  dp(20)
                //                    //Layout.alignment: Qt.AlignHCenter
                //                    orientation: Qt.Vertical
                //                    from: 0
                //                    to:   10
                //                    stepSize: 1
                //                    value:    3
                //                    //snapMode: Slider.SnapAlways
                //                    background:  Rectangle{
                //                        //anchors.right: parent.right
                //                        //height:parent.height
                //                        //radius: dp(20)

                //                        //width:dp(40)
                //                        gradient: Gradient {
                //                            GradientStop {
                //                                position: 0.00;
                //                                color: "blue";
                //                            }
                //                            GradientStop {
                //                                position: 1.00;
                //                                color: "red";
                //                            }
                //                        }
                //                        Text{
                //                            anchors.fill: parent
                //                            color:"white"
                //                            text: qsTr("Discomfort Level")
                //                            verticalAlignment: Text.AlignVCenter
                //                            rotation: -90
                //                            horizontalAlignment: Text.AlignHCenter
                //                            //anchors.verticalCenter: parent.verticalCenter
                //                        }

                //                    }

                //                    //For some reason the visual position requires a manual snap, even when snapMode is set
                //                    //onVisualPositionChanged: { var v1 = Math.round(from + (to - from ) * visualPosition); sbv = v1 -v1 % stepSize;
                //                        /*console.log("sbv = ", Math.round(from + (to - from ) * visualPosition))*/
                //                    //}
                //                    handle: Rectangle{
                //                        id: contr
                //                        color: "orange"
                //                        width: dp(80)
                //                        height: dp(80)
                //                        radius: dp(24)
                //                        //enabled: true
                //                        anchors.horizontalCenter: parent.horizontalCenter
                //                        z:100
                //                        Image {
                //                            id: seaWolHandleImage
                //                            source: "../../assets/img/SeaWolf.png"
                //                            anchors.horizontalCenter: parent.horizontalCenter
                //                            width: parent.width
                //                            height:width
                //                        }

                //                        //                        text: qsTr("Cntrct")
                ////                        onClicked: {
                ////                            //console.log("value=", Math.round(currentGauge.value))
                ////                            hrPlot.markEvent(getSessionTime(), "Contraction")
                ////                        }
                ////                        enabled:true
                //                    }


                ////                        Rectangle {
                ////                                x: parent.leftPadding + parent.first.visualPosition * (parent.availableWidth - width)
                ////                                y: parent.topPadding + parent.availableHeight / 2 - height / 2
                ////                                implicitWidth: dp(60)
                ////                                implicitHeight: dp(60)
                ////                                radius: dp(30)
                ////                                //color: parent.first.pressed ? "#f0f0f0" : "#f6f6f6"
                ////                                color: "orange"
                ////                                border.color: "#bdbebf"
                ////                                Text {
                ////                                    id: leftRangeSliderText
                ////                                    anchors.centerIn: parent
                ////                                    font.pixelSize: dp (30)
                ////                                    elide: Text.ElideMiddle
                ////                                    //color: "#F0EBED"
                ////                                    color: "black"
                ////                                    text: "Contraction"
                ////                                }
                ////                    }
                //                    //onValueChanged: {sbv = value; intRes=value; result()}
                //                }

                //            }
                Component.onCompleted:{
                    currentWalkControl = walkControl
                    currentGauge       = gaugeBrth
                    currentHrPlot      = hrPlot
                }

            }
        }
    }
 }
