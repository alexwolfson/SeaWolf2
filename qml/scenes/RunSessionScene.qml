import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Window 2.2
import QtQuick.Layouts 1.2
import QtMultimedia 5.5
import QtQml 2.2
import QtCharts 2.1

import VPlay 2.0
import VPlayApps 1.0
import "../common"
import com.seawolf.qmlfileaccess 1.0
import "../common/draw.js" as DrawGraph


SceneBase {
    id: runSessionScene
    property var runColors: {"brth" : "tomato", "hold" : "green", "walk" : "steelblue", "back" : "yellow"}
    property int brthIndx: 0
    property int holdIndx: 1
    property int walkIndx: 2
    property int backIndx: 3
    property var myEvents:{"EndOfMeditativeZone":0, "EndOfComfortZone":1, "Contraction":2, "EndOfWalk":3, "brth":4 , "hold":5, "walk":6, "back":7}
    property SeaWolfControls currentGauge
    property var currentSession: {
        "sessionName":"TestSession",
                "when":"ChangeMe", //Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss"),
                "eventNames":myEvents,
                "event":[],
                "pulse":[]
    }
    property real sessionDuration:0.0
    property var gauge: [gaugeBrth, gaugeHold, gaugeWalk]
    //property alias hrPoints: hrSeries
    property real sessionTime: 0.0
    property alias currentHrView: chartView
    property alias axisX: axisX
    property alias axisY: axisY
    property LineSeries currentHrSeries
    property real minHr:10
    property real maxHr:150
    //property alias currentGauge:timerHold.currentGauge
    //===================================================
    // signal indicating that current session is selected
    signal sessionSelected(var selectedSession)
    //called by onSessionSelected
    function fillListModel(listModelSrc){
        console.log("**** In fillListModel width ", listModelSrc)
        var step;
        apneaModel.clear();
        sessionDuration = 0.0
        for (step in listModelSrc){
            apneaModel.append({"time": listModelSrc[step].time, "typeName":listModelSrc[step].typeName, "isCurrent": false});
            sessionDuration += listModelSrc[step].time;
        }
        gaugeBrth.maximumValue = apneaModel.get(brthIndx).time
        gaugeHold.maximumValue = apneaModel.get(holdIndx).time
        gaugeWalk.maximumValue = apneaModel.get(walkIndx).time
    }


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
        anchors.rightMargin: dp(10)
        anchors.top: runSessionScene.gameWindowAnchorItem.top
        anchors.topMargin: dp(10)
        onClicked: backButtonPressed()
    }
    //Apnea Model - top cells with times
    Item {
        id: apneaModelContainer
        Image {
            z:90
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
            ListElement { time: 0; typeName: "walk";    isCurrent: false }
            ListElement { time: 6; typeName: "brth";    isCurrent: false }
            ListElement { time: 7; typeName: "hold";    isCurrent: false }
            ListElement { time: 0; typeName: "walk";    isCurrent: false }
            ListElement { time: 9; typeName: "brth";    isCurrent: false }
            ListElement { time:10; typeName: "hold";    isCurrent: false }
            ListElement { time: 0; typeName: "walk";    isCurrent: false }
        }


        GridView {
            id: sessionView
            width: parent.width
            //height: parent.height
            anchors.margins: 1
            anchors.top: parent.top
            anchors.fill: apneaModelContainer

            cellWidth: (parent.width - 2 * anchors.margins) /12 - 3
            cellHeight: cellWidth
            clip: true
            model: apneaModel
            delegate: apneaDelegate
            //footer: viewFooter

            Component {
                id: apneaDelegate
                //property alias borderColor: wrapper.border.color
                Rectangle {

                    property real myRadius: dp(5)
                    id: wrapper
                    z:     isCurrent ? 100:95
                    width:  isCurrent ? 2* sessionView.cellWidth : sessionView.cellWidth
                    height: isCurrent ? 2* sessionView.cellWidth : sessionView.cellWidth
                    radius:isCurrent ? 2 * myRadius: myRadius
                    color: { if (index == -1) return "grey"; runColors[apneaModel.get(index).typeName]}
                    border.color: { if (index == -1) return "grey"; apneaModel.get(index).isCurrent? "white": "black"}
                    border.width: 2
                    property int whatToShow: isCurrent ? Math.round(time - gauge[index%3].value) : time
                    Text {
                        id:timeText
                        anchors.centerIn: parent
                        //font.pointSize: Math.round(parent.height/4)
                        font.pixelSize: Math.round(dp(parent.height/2))
                        text: "<b>" + whatToShow + "</b>"; color: "white"; style: Text.Raised; styleColor: "black"
                        //text: index + ". " + typeName + " " + time + "sec."

                    }
                    Behavior on width {NumberAnimation{duration:500}}
                    Behavior on height {NumberAnimation{duration:500}}
                }
            }

        }
    } // End Of Apnea Model and times grid

    Timer{
        id: oneTimer
        interval:1000
        repeat:true

        onTriggered:{
            sessionTime++
            // update heart rate information
            currentSession.pulse.push( Math.round(heartRate.hr))
            //hrPoints.append(100, 100)
            console.log("**HR:",currentGauge.value, heartRate.hr)
            currentHrSeries.append(sessionTime, heartRate.hr)
//            if (minHr > heartRate.hr){
//                minHr = heartRate.hr
//                axisY.min = minHr
//            }
//            if (maxHr < heartRate.hr){
//                maxHr = heartRate.hr
//                axisY.max = maxHr
//            }

            chartView.update()
            //hrPoints.append(sessionTime, heartRate.hr)
            //brthFooter.timerBrth.value
        }
    }
    // Plot
    Rectangle{
        id:hrPlot
        width:parent.width
        height: dp(200)
        anchors.top: runSessionScene.top
        anchors.topMargin:dp(50)
        opacity:1.0
        z:99
        ChartView {
            id:chartView
            //title: "Line"
            anchors.fill: parent
            antialiasing: true
            //width:parent.width/2
            //height:200
            legend.visible: false
            ValueAxis {
                id: axisX
                labelFormat:d
                min: 0
                max: sessionDuration
                tickCount: 7
            }

            ValueAxis {
                id: axisY
                min: minHr
                max: maxHr
                tickCount:7

            }

            LineSeries {
              id: hrSeries
              name: "Heart Rate"
              opacity: 1
              axisX:axisX
              axisY:axisY
              XYPoint { x: 0; y: 0 }
            //                  XYPoint { x: 50; y: 50 }
            }
        }
    } //End Of Plot

    // Gauges
    Item {
        id: gauges
        width: runSessionScene.width * 0.8
        height: width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:hrPlot.bottom
        anchors.topMargin: dp(8)

        SoundEffectVPlay {
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
            gaugeModel: apneaModel
            nextGauge:gaugeHold
            width:height
            height:parent.height
        }
        SoundEffectVPlay {
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
            gaugeModel: apneaModel
            nextGauge: gaugeWalk.maximumValue === 0 ? gaugeBrth : gaugeWalk
            width:height
            height:parent.height
        }

        SoundEffectVPlay {
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
            gaugeModel: apneaModel
            nextGauge: gaugeBrth
            //gaugeWalkControl: container.walkControl
            width:height
            height:parent.height
        }
        Text {
            id: hrValue
            z:100
            font.pixelSize: sp(36); font.bold: true
            anchors.centerIn: parent

            color: "white" //"#3870BA"
            text: heartRate.hr
            onTextChanged: {
                //              if (heartRate.hr > 0 && updatei != null && heartRate.numDevices() > 0) {
                //                  updatei.destroy()
                //              }
            }
        }
    } // End of gauges
    // Menu Buttons
    Column {
        id:buttons
        //anchors.leftMargin: dp(8)
        anchors.bottom: runSessionScene.bottom
        anchors.bottomMargin: dp(8)
        //anchors.left: gauges.left
        anchors.horizontalCenter: gauges.horizontalCenter
        spacing: dp(8)
        QMLFileAccess {
            id:qfa
        }


        Row{
            id:row1
            spacing:dp(8)
            MenuButton {
                id: button1
                z: 100
                text: qsTr("Start")
                enabled: true
                clip: true
                onClicked: {
                    gaugeBrth.modelIndex = 0
                    apneaModel.get(0).isCurrent = true

                    gaugeBrth.state = "stateRun";
                    gaugeBrth.isCurrent = true
                    //apneaModel.get(0).isCurrent = true
                    walkControl.enabled = false
                    button2.enabled = true;
                    runSessionScene.currentSession.when = Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss");
                    currentGauge = gaugeBrth
                    chartView.removeAllSeries()
                    currentHrSeries = chartView.createSeries(ChartView.SeriesTypeLine, "", axisX, axisY);
                    currentHrSeries.color = runColors[currentGauge.gaugeName]
                    oneTimer.start()
                    //console.log("Time=", Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss"))
                    console.log("Session:",runSessionScene.currentSession.sessionName, "started:",runSessionScene.currentSession.when)

                }
            }

            MenuButton {
                id: walkControl
                z:100
                text: qsTr("Finish Walk")
                enabled: false
                onClicked: {
                    if (walkControl.text === qsTr("Finish Walk")){
                        //enabled = false;
                        gaugeWalk.state = "initial";
                        gaugeWalk.maximumValue = gaugeWalk.value;
                        walkControl.text = qsTr("Breath")
                        walkControl.enabled = true
                    }
                }
            }
            FileDialog{
                id: fileDialog
                folder:qfa.getAccessiblePath("sessions")
            }

            MenuButton {
                id: button2
                z:100
                text: qsTr("Stop")
                onClicked: {
                    //timerBrth.sessionIsOver(timerBrth)
                    //fileDialog.open()
                    gaugeBrth.maximumValue = apneaModel.get(brthIndx).time
                    gaugeHold.maximumValue = apneaModel.get(holdIndx).time
                    gaugeWalk.maximumValue = apneaModel.get(walkIndx).time
                    gaugeBrth.state = "initial"
                    gaugeBrth.value = 0
                    gaugeHold.state = "initial"
                    gaugeHold.value = 0
                    gaugeWalk.state = "initial"
                    gaugeWalk.value = 0
                    //apneaModel.get(apneaModel.index).isCurrent = false
                    //apneaModel.index = 0

                    walkControl.enabled = true
                    //button2.enabled = false
                }
            }
        }
        Row{
            id:row2
            spacing:dp(8)
            MenuButton{
                id: note1
                z:100
                text: qsTr("-Medit")
                onClicked: {
                    console.log("value=", Math.round(currentGauge.value))
                    currentSession.event.push([myEvents["EndOfMeditativeZone"], Math.round(currentGauge.value)])
                }
                enabled:true
            }
            MenuButton{
                id: note2
                z:100
                text: qsTr("-Cmfrt")
                onClicked: {
                    console.log("value=", Math.round(currentGauge.value))
                    currentSession.event.push([myEvents["EndOfComfortZone"], Math.round(currentGauge.value)])
                }
                enabled:true
            }
            MenuButton{
                id: note3
                z:100
                text: qsTr("Cntrct")
                onClicked: {
                    console.log("value=", Math.round(currentGauge.value))
                    currentSession.event.push([myEvents["Contraction"], Math.round(currentGauge.value)])
                }
                enabled:true
            }
        }
    }
}
