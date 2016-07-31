import QtQuick 2.7
import QtQuick.Controls 1.4
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
    active: true
    function invert (obj) {

      var new_obj = {};

      for (var prop in obj) {
        if(obj.hasOwnProperty(prop)) {
          new_obj[obj[prop]] = prop;
        }
      }

      return new_obj;
    }
//    //creates new series graph
//    function setupCurrentHrSeries(){
//        currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentAxisX, currentAxisY);
//        currentHrSeries.color = runColors[currentGauge.gaugeName]
//    }

    function setupSession(sessionName, selectedSession){
        console.log("**** In setupSession width ", sessionName, ":", selectedSession)
        var step;
        currentModel.clear();
        sessionDuration = 0.0
        for (step in selectedSession){
            currentModel.append({"time": selectedSession[step].time, "typeName":selectedSession[step].typeName, "isCurrent": false});
            sessionDuration += selectedSession[step].time;
        }
        currentGaugeBrth.maximumValue = currentModel.get(brthIndx).time
        currentGaugeHold.maximumValue = currentModel.get(holdIndx).time
        currentGaugeWalk.maximumValue = currentModel.get(walkIndx).time
        currentGaugeBack.maximumValue = currentModel.get(backIndx).time
        currentSession.sessionName = sessionName
    }
//    function getSesssionHRMin(session){
//        var hrMin=999
//        var i
//        for (i = 0; i < session.pulse.length; i++ ){
//            if (session.pulse[i] < hrMin){
//                hrMin = session.pulse[i]
//            }
//        }
//        return hrMin
//    }
//    function getSesssionHRMax(session){
//        var hrMax=0
//        var i
//        for (i = 0; i < session.pulse.length; i++ ){
//            if (session.pulse[i] > hrMax){
//                hrMax = session.pulse[i]
//            }
//        }
//        return hrMax
//    }

//    function showSessionGraph(p_session, p_chartView){
//        var hrMin = getSesssionHRMin(p_session);
//        var hrMax = getSesssionHRMax(p_session);
//        var currentHrSeries
//        p_chartView.axes[1].min = (hrMin - 5);
//        p_chartView.axes[1].max = (hrMax + 5);
//        p_chartView.axes[0].min = 0;
//        p_chartView.axes[0].max = p_session.pulse.length
////        var currentIndex = 0;
////        var evt;
////        p_chartView.removeAllSeries();
////        var evtStartTime = 0;
////        for (var i = 0; i < p_session.event.length; i++){
////            evt = p_session.event[i]
////            var evtName = myEventsNb2Nm[evt[0]]
////            //only use events like brth, hold, walk, back
////            if (!(runColors[evtName] === undefined)){
////                //console.log("step = ", evtName, "step duration = ", evt[1])
////                currentHrSeries = p_chartView.createSeries(ChartView.SeriesTypeLine, "", p_chartView.axisX, p_chartView.axisY);
////                //p_chartView.chart().setAxisX(axisX, currentHrSeries);
////                currentHrSeries.color = runColors[evtName]
////                for (var j = 0; j < evt[1]; j++){
////                    currentHrSeries.append( currentHrSeries.pulse[j])
////                    //AWDEBUG
////                    //currentHrSeries.append(Math.round(50 + j))
////                    p_chartView.update()

////                }
////                evtStartTime += evt[1]
////            }
////        }
//        p_chartView.update()
//    }
    function enableWalkControl(){currentWalkControl.enabled=true}
    //anchors.fill: parent
    //anchors.top: runSessionScene.gameWindowAnchorItem.top
    //property alias walkControl: walkControl
    property var runColors: {"brth" : "green", "hold" : "tomato", "walk" : "navyblue", "back" : "orange"}
    property int brthIndx: 0
    property int holdIndx: 1
    property int walkIndx: 2
    property int backIndx: 3
//    property var myEventsNm2Nb:{"EndOfMeditativeZone":0, "EndOfComfortZone":1, "Contraction":2, "EndOfWalk":3, "brth":4 , "hold":5, "walk":6, "back":7}
//    property var myEventsNb2Nm:invert(myEventsNm2Nb)
//    property var sessionSteps: [myEventsNm2Nb["brth"], myEventsNm2Nb["brth"], myEventsNm2Nb["hold"], myEventsNm2Nb["walk"], myEventsNm2Nb["back"] ]
    property SeaWolfControls currentGauge
//    property var currentSession: {
//        "sessionName":"TestSession",
//                "when":"ChangeMe", //Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss"),
//                "eventNames":myEventsNm2Nb,
//                "event":[],
//                "pulse":[]
//    }
//    property real sessionDuration:0.0
    property var runGauge
    //property alias hrPoints: hrSeries
    property real sessionTime: 0.0
    //The set of properties that are created to get around the
    // loading of the Tab. Not all of the Tab's elements are simultaniously available
    // so we create top level properties that are set by Component.onComplete() when lower level elements are created
//    property LineSeries currentHrSeries
//    property ChartView  currentChartView
//    property ValueAxis  currentAxisX
//    property ValueAxis  currentAxisY
    property MenuButton currentWalkControl
    property ListModel  currentModel
    property SeaWolfControls currentGaugeBrth
    property SeaWolfControls currentGaugeHold
    property SeaWolfControls currentGaugeWalk
    property SeaWolfControls currentGaugeBack

//    property real minHr:10
//    property real maxHr:150
    //property alias currentGauge:timerHold.currentGauge
    //called by onSessionSelected
    property int   timeFooterBrth
    property color borderColorFooterBrth
    property int   timeFooterHold
    property color borderColorFooterHold
    property int   timeFooterWalk
    property color borderColorFooterWalk
    property bool  noWalk: true

    Item {
        id: currentModelContainer
        width: parent.width
        //hight:50
        anchors.top:parent.top
        //anchors.topMargin:tabHeaderHight
        //height: parent.height
        //anchors.fill: parent
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
        Rectangle{
            id: currentStepLeft
            property alias text:txt.text
            z:1
            //12 cells + 1 double sized cell for that Rectangle in a row
            width: (parent.width - 3 * anchors.margins) / 7
            height: width
            anchors.margins: dp(2)
            anchors.top:parent.top
            anchors.left:parent.left
            radius: dp(8)
            border.width: dp(4)
            border.color: "black"
            Text{ id:txt
                anchors.centerIn: parent
                font.pixelSize: Math.round(dp(0.4 * parent.height))
                text: Math.round(currentGauge.maximumValue - currentGauge.value)
            }
        }

        GridView {
            //z:50
            id: sessionView
            //height: parent.height
            anchors.leftMargin: currentStepLeft.width
            //anchors.top: parent.top
            anchors.fill: parent
            cellWidth: (parent.width - 2 * anchors.margins) /14 - 3
            cellHeight: cellWidth
            clip: true
            model: currentModel
            delegate: Component {
                Loader{
                    Rectangle {

                        property real myRadius: dp(5)
                        id: wrapper
                        z:      {var zdeep=isCurrent ? 100:95; /*console.log("isCurrent, index, zdeep", isCurrent, index, zdeep);*/return zdeep}
                        width:  /*isCurrent ? 2* sessionView.cellWidth :*/ sessionView.cellWidth - dp(2)
                        height: width
                        radius: /*isCurrent ? 2 * myRadius:*/ myRadius
                        color: { if (index == -1) return "grey"; runColors[currentModel.get(index).typeName]}
                        border.color: { if (index == -1) return "grey"; isCurrent? "white": "black"}
                        border.width: isCurrent? dp(4): dp(2)
                        function whatToShow() {

                           var wts = /*isCurrent ? Math.round(time - runGauge[index % runGauge.length].value) :*/ time
                           //timeLeft(wts)
                           return wts
                        }
                        Text {
                            id:timeText
                            anchors.centerIn: parent
                            //font.pointSize: Math.round(parent.height/4)
                            font.pixelSize: Math.round(dp(0.4 * parent.height))
                            text: "<b>" + parent.whatToShow() + "</b>"; color: "white"; style: Text.Raised; styleColor: "black"
                            //text: index + ". " + typeName + " " + time + "sec."

                        }
                        Behavior on border.color {ColorAnimation{duration:500}}
                        Behavior on border.width {NumberAnimation{duration:500}}
                    }
                }
            }

        }
        // End Of Apnea Model and times grid

        Column{
        anchors.top:parent.top
        anchors.topMargin: 3 * sessionView.cellWidth -spacing //dp(120)
        id:runColumn
        width:parent.width
        //height:parent.height
        //anchors.leftMargin: dp(8)
        //anchors.bottom: runSessionScene.bottom
        //anchors.bottomMargin: dp(8)
        //anchors.left: gauges.left
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: dp(8)


        Timer{
            id: oneTimer
            interval:1000
            repeat:true

            onTriggered:{
                sessionTime++
                // update heart rate information
                hrPlot.currentSession.pulse.push( Math.round(heartRate.hr))
                //hrPoints.append(100, 100)
                //console.log("**HR:",currentGauge.value, heartRate.hr)
                hrPlot.currentHrSeries.append(sessionTime, heartRate.hr)
                hrPlot.showSessionGraph(hrPlot.currentSession,hrPlot.currentChartView)
                //chartView.update()
            }
        }

//        Rectangle{
//            id:hrPlot
//            width:parent.width // + dp(50)
//            height: runSessionScene.height/3
//            anchors.horizontalCenter: parent.horizontalCenter
//            //anchors.top: runSessionScene.top
//            //anchors.topMargin: sessionView.cellWidth * 3
//            opacity:1.0
//            z:50
//            ChartView {
//                id:chartView
////                margins.bottom:dp(0)
////                margins.left:  dp(0)
////                margins.right: dp(0)
////                margins.top:   dp(0)

//                title: currentSession.sessionName + " " + currentSession.when
//                anchors.fill: parent
//                //to make visible part of the graph taking bigger part
//                anchors.topMargin: dp(-30)
//                antialiasing: true
//                theme: ChartView.ChartThemeBlueIcy
//                //legend:{visible: false}
//                ValueAxis {
//                    id: axisX
//                    labelFormat:"%.0f"
//                    //labelsFont: Qt.font({pixelSize : sp(10)})
//                    min: 0
//                    max: sessionDuration
//                    tickCount: 7
//                }
//                ValueAxis {
//                    id: axisY
//                    labelFormat:"%.0f"
//                    //labelsFont: Qt.font({pixelSize : sp(10)})
//                    min: minHr
//                    max: maxHr
//                    tickCount:6

//                }

//                LineSeries {
//                  id: hrSeries
//                  name: "Heart Rate"
//                  opacity: 1
//                  axisX:axisX
//                  axisY:axisY
//                  XYPoint { x: 0;  y: 0 }
//                  XYPoint { x: 50; y: 50 }
//                }
//                Component.onCompleted:{
//                    currentChartView = chartView
//                    currentAxisX     = axisX
//                    currentAxisY     = axisY
//                }
//            }

//        } //End Of Plot
        SeaWolfPlot{
            id:hrPlot
        }

        Item {
            id: gauges
            width: runSessionScene.width * 0.6
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            //anchors.top:hrPlot.bottom
            //anchors.topMargin: dp(20)

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
                font.pixelSize: dp(36); font.bold: true
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


//        QMLFileAccess {
//            id:qfa
//        }


        Row{
            id:row1
            spacing:dp(8)
            anchors.horizontalCenter: parent.horizontalCenter
            MenuButton {
                id: button1
                z: 100
                text: qsTr("Start")
                enabled: true
                clip: true
                onClicked: {
                    currentGaugeBrth.modelIndex = 0
                    currentGauge = currentGaugeBrth
                    currentModel.get(0).isCurrent = true

                    currentGaugeBrth.state = "stateRun";
                    currentGaugeBrth.isCurrent = true
                    //currentModel.get(0).isCurrent = true
                    walkControl.enabled = false
                    button2.enabled = true;
                    hrPlot.currentSession.event=[]
                    hrPlot.currentSession.pulse=[]
                    walkControl.text= qsTr("Finish Walk")
                    hrPlot.currentSession.when = Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss");
                    hrPlot.currentChartView.removeAllSeries()
                    hrPlot.currentHrSeries = hrPlot.currentChartView.createSeries(ChartView.SeriesTypeLine, "", hrPlot.currentAxisX, hrPlot.currentAxisY);
                    hrPlot.currentHrSeries.color = runColors[currentGauge.gaugeName]
                    oneTimer.start()
                    //console.log("Time=", Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss"))
                    console.log("Session:",hrPlot.currentSession.sessionName, "started:",hrPlot.currentSession.when)

                }
            }

            MenuButton {
                id: walkControl
                z:100
                text: qsTr("Finish Walk")
                enabled: true
                onClicked: {
                    if (walkControl.text === qsTr("Finish Walk")){
                        //enabled = false;
                        currentGauge.state = "initial";
                        //currentgaugeWalk.maximumValue = currentgaugeWalk.value;
                        walkControl.text = qsTr("Finish Back")
                        walkControl.enabled = true
                        currentGauge.stopVoiceTimers();
                    } else if(walkControl.text === qsTr("Finish Back")){
                        currentGauge.state = "initial"
                        walkControl.text = qsTr("Finish Walk");
                        walkControl.enabled = false
                        currentGauge.stopVoiceTimers();
                    }
                }
            }
//            FileDialog{
//                id: fileDialog
//                folder:qfa.getAccessiblePath("sessions")
//            }

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
        }
        Row{
            id:row2
            anchors.horizontalCenter: parent.horizontalCenter
            spacing:dp(8)
            MenuButton{
                id: note1
                z:100
                text: qsTr("-Medit")
                onClicked: {
                    //console.log("value=", Math.round(currentGauge.value))
                    currentSession.event.push([myEventsNm2Nb["EndOfMeditativeZone"], Math.round(currentGauge.value)])
                }
                enabled:true
            }
            MenuButton{
                id: note2
                z:100
                text: qsTr("-Cmfrt")
                onClicked: {
                    //console.log("value=", Math.round(currentGauge.value))
                    currentSession.event.push([myEventsNm2Nb["EndOfComfortZone"], Math.round(currentGauge.value)])
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
                    currentSession.event.push([myEventsNm2Nb["Contraction"], Math.round(currentGauge.value)])
                }
                enabled:true
            }
        }
        Component.onCompleted:{
            currentWalkControl = walkControl
            currentGauge       = gaugeBrth
        }

      }
   }
}

