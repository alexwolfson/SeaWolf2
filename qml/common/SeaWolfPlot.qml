import QtQuick 2.7
//import QtQuick.Controls 1.4
//import QtQuick.Controls.Styles 1.4
//import QtQuick.Dialogs 1.2
//import QtQuick.Extras 1.4
//import QtQuick.Layouts 1.2
import QtMultimedia 5.6
//import QtQml 2.2
import QtCharts 2.1
Rectangle{
    id:hrPlot
    width:parent.width // + dp(50)
    height: parent.height/2.5
    anchors.horizontalCenter: parent.horizontalCenter
    //anchors.top: runSessionScene.top
    //anchors.topMargin: sessionView.cellWidth * 3
    opacity:1.0
    z:50
    property var currentSession: {
        "sessionName":"TestSession",
                "when":"ChangeMe", //Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss"),
                "eventNames":myEventsNm2Nb,
                "event":[],
                "pulse":[]
    }
    property var myEventsNm2Nb:{"brth":0 , "hold":1, "walk":2, "back":3, "EndOfMeditativeZone":4, "EndOfComfortZone":5, "Contraction":6, "EndOfWalk":7 }
    property var myEventsNb2Nm: invert(myEventsNm2Nb)
    property var runColors: {"brth" : "green", "hold" : "tomato", "walk" : "navyblue", "back" : "orange"}
    //property var eventsGraphProperty:{"Contraction":["red", "black", 6]}
    property LineSeries currentHrSeries
    property ScatterSeries currentContractionSeries
    property ChartView  currentChartView
    property ValueAxis  currentAxisX
    property ValueAxis  currentAxisY
    property real minHr:10
    property real maxHr:150
    property real sessionDuration:0.0
    function invert (obj) {
        var new_obj = {};
        for (var prop in obj) {
            if(obj.hasOwnProperty(prop)) {
                new_obj[obj[prop]] = prop;
            }
        }
        return new_obj;
    }

    function isNewSeriesEvent(eventName){
       if (eventName in ["brth", "hold", "walk", "back"]){
           return true
       }else{
           return false
       }
    }
    function init(){
        currentSession.event=[]
        currentSession.pulse=[]
        currentSession.when = Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss");
        currentChartView.removeAllSeries()
        currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentAxisX, currentAxisY);
        currentHrSeries.color = runColors[currentGauge.gaugeName]
        currentContractionSeries = currentChartView.createSeries(ChartView.SeriesTypeScatter, "", currentAxisX, currentAxisY);

    }
    function markEvent(eventName){
        var eventNb = myEventsNm2Nb[eventName];
        var tm      = Math.round(currentGauge.value)
        currentSession.event.push([eventNb, tm])
        if (eventName === "Contraction"){
            currentContractionSeries.append(sessionTime, Math.round(heartRate.hr))
        }
    }

    //creates new series graph
    function setupCurrentSeries(){
        currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentAxisX, currentAxisY);
        currentHrSeries.color = runColors[currentGauge.gaugeName]
        currentContractionSeries = currentChartView.createSeries(ChartView.SeriesTypeScatter, "", currentAxisX, currentAxisY);
    }

    function getSesssionHRMin(session){
        var hrMin=999
        var i
        for (i = 0; i < session.pulse.length; i++ ){
            if (session.pulse[i] < hrMin){
                hrMin = session.pulse[i]
            }
        }
        return hrMin
    }
    function getSesssionHRMax(session){
        var hrMax=0
        var i
        for (i = 0; i < session.pulse.length; i++ ){
            if (session.pulse[i] > hrMax){
                hrMax = session.pulse[i]
            }
        }
        return hrMax
    }
    function setupSession(sessionName, selectedSession){
        console.log("**** In setupSession width ", sessionName, ":", selectedSession)
        var step;
        sessionDuration = 0.0
        for (step in selectedSession){
            sessionDuration += selectedSession[step].time;
        }
        currentSession.sessionName = sessionName
    }

    function saveSession() {
        var path=qfa.getAccessiblePath("sessions");
        console.log("Path = ", path);
        var fileName = currentSession.sessionName + "-" + currentSession.when;
        //open will add path before fileName
        console.log("fileName=", fileName, "Open=" , qfa.open(path + fileName));
        var sessionString = JSON.stringify(currentSession);
        console.log("Wrote = ", qfa.write(sessionString));
        //var qstr = qfa.read();
        //console.log("read = ", qstr);
        qfa.close();
        //var data = runSessionScene.currentSession
        //io.text = JSON.stringify(data, null, 4)
        //io.write()
    }

    function restoreSession(filePath) {
        console.log("filePath = ", filePath, "Open=" , qfa.open(filePath));
        //console.log("Wrote = ", qfa.write(JSON.stringify(runSessionScene.currentSession)));
        var qstr = qfa.read();
        console.log("read = ", qstr);
        currentSession = JSON.parse(qstr);
        qfa.close();
        var currentIndex = 0;
        currentChartView.removeAllSeries();
        var evtStartTime = 0;
        console.log("events.length=", currentSession.event.length)
        //for (var evt in currentSession.event){  ////Does that for loop type works?
        for (var i=0; i < currentSession.event.length; i++){
            var evt     = currentSession.event[i]
            var evtName = myEventsNb2Nm[evt[0]]
            //console.log("step = ", evtName, "step duration = ", evt[1])

            if (evtName === "Contraction"){
                currentContractionSeries = currentChartView.createSeries(ChartView.SeriesTypeScatter, "", currentChartView.axisX, currentChartView.axisY);
                //currentView.chart().setAxisX(axisX, currentHrSeries);
                currentContractionSeries.append( evtStartTime + evt[1], currentSession.pulse[evtStartTime + evt[1]])
            }

            //only use events like brth, hold, walk, back to fill the pulse data
            if (!(runColors[evtName] === undefined)){
                currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentChartView.axisX, currentChartView.axisY);
                //currentView.chart().setAxisX(axisX, currentHrSeries);
                currentHrSeries.color = runColors[evtName]
                for (var j = 0; j < evt[1]; j++){
                    currentHrSeries.append( evtStartTime + j, currentSession.pulse[evtStartTime + j])
                    //AWDEBUG
                    //currentHrSeries.append(Math.round(50 + j))
                    //currentView.update()

                }
                evtStartTime += evt[1]
            }
        }

        showSessionGraph(currentSession,currentChartView)

        //var data = runSessionScene.currentSession
        //io.text = JSON.stringify(data, null, 4)
        //io.write()
    }
    function showSessionGraph(p_session, p_chartView){
        var hrMin = getSesssionHRMin(p_session);
        var hrMax = getSesssionHRMax(p_session);
        var currentHrSeries
        p_chartView.axes[1].min = (hrMin - 5);
        p_chartView.axes[1].max = (hrMax + 5);
        p_chartView.axes[0].min = 0;
        p_chartView.axes[0].max = p_session.pulse.length
        currentChartView.title = p_session.sessionName + " " + p_session.when
        p_chartView.update()
    }
    ChartView {
        id:chartView
        //                margins.bottom:dp(0)
        //                margins.left:  dp(0)
        //                margins.right: dp(0)
        //                margins.top:   dp(0)

        title: currentSession.sessionName + " " + currentSession.when
        anchors.fill: parent
        //to make visible part of the graph taking bigger part
        //anchors.topMargin: dp(-20)
        antialiasing: true
        theme: ChartView.ChartThemeBlueIcy
        //legend:{visible: false}
        ValueAxis {
            id: axisX
            labelFormat:"%.0f"
            //labelsFont: Qt.font({pixelSize : sp(10)})
            min: 0
            max: sessionDuration
            gridLineColor:"black"
            tickCount: 7
        }
        ValueAxis {
            id: axisY
            labelFormat:"%.0f"
            //labelsFont: Qt.font({pixelSize : sp(10)})
            min: minHr
            max: maxHr
            gridLineColor:"black"
            tickCount:6

        }

        LineSeries {
            id: hrSeries
            name: "Heart Rate"
            opacity: 1
            width: dp(4)
            axisX:axisX
            axisY:axisY
            XYPoint { x: 0;  y: 0 }
            XYPoint { x: 50; y: 50 }
        }
        ScatterSeries {
            id: contractionSeries
            name: "Contraction"
            opacity: 1
            color: "red"
            borderColor: "black"
            markerShape: ScatterSeries.MarkerShapeCircle
            markerSize: dp(8)
            axisX:axisX
            axisY:axisY
            XYPoint { x: 0;  y: 0 }
            XYPoint { x: 50; y: 50 }
        }
        Component.onCompleted:{
            currentChartView = chartView
            currentAxisX     = axisX
            currentAxisY     = axisY
        }
    }

} //End Of Plot

