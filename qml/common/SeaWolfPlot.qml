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
    property var myEventsNm2Nb:{"brth":0 , "hold":1, "walk":2, "back":3, "EndOfMeditativeZone":4, "EndOfComfortZone":5, "Contraction":6, "EndOfWalk":7 }
    property var myEventsNb2Nm: invert(myEventsNm2Nb)
    property var runColors: {"brth" : "green", "hold" : "tomato", "walk" : "blue", "back" : "orange"}
    //property var eventsGraphProperty:{"Contraction":["red", "black", 6]}
    property var currentSession: {
        "sessionName":"TestSession",
                "when":"ChangeMe", //Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss"),
                "eventNames":myEventsNm2Nb,
                "event":[],
                "pulse":[]
    }
    property LineSeries    currentHrSeries
    property LineSeries    postEventHrSeries
    property ScatterSeries currentContractionSeries: contractionSeries
    property ChartView     currentChartView
    property CategoryAxis  currentAxisX
    property ValueAxis     currentAxisY
    property real minHr:10
    property real maxHr:150
    property int sessionDuration:0
    property int lastShownAnyEventNb
    property int lastShownStepEventNb
    property int lastShownPulseTm
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
        sessionDuration = 0
        currentSession.event=[]
        currentSession.pulse=[]
        currentSession.when = Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss");
        currentChartView.removeAllSeries()
        setupCurrentSeries()
        lastShownAnyEventNb = -1;
        lastShownStepEventNb = -1;
        lastShownPulseTm = -1;
        currentAxisX = chartView.plotAxisX
    }
    //creates new series graph
    function setupCurrentSeries(){
        currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentAxisX, currentAxisY);
        //currentHrSeries.color = runColors[currentGauge.gaugeName]
        currentContractionSeries = currentChartView.createSeries(ChartView.SeriesTypeScatter, "", currentAxisX, currentAxisY);
        postEventHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentAxisX, currentAxisY)
    }
    function markEvent(eventName){
        var eventNb = myEventsNm2Nb[eventName];
        var tm      = runSessionScene.getSessionTime()//Math.round(currentGauge.value)
        currentSession.event.push([eventNb, tm])
        if (eventName === "Contraction"){
            console.log("Mark Contraction, tm=", tm, "Y =", Math.round(heartRate.hr))
            currentContractionSeries.append(tm, Math.round(heartRate.hr))
        }
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
        init()
        sessionDuration = 0
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
        qfa.open(filePath)
        console.log("restored = ", filePath);
        init()
        var qstr = qfa.read();
        console.log("read = ", qstr);
        currentSession = JSON.parse(qstr);
        qfa.close();
//        var currentIndex = 0;
//        currentChartView.removeAllSeries();
//        currentContractionSeries = currentChartView.createSeries(ChartView.SeriesTypeScatter, "", currentChartView.axisX, currentChartView.axisY);
//        //there is no post event here just creating to avoid runtime error in showSessionPlot
//        postEventHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentAxisX, currentAxisY)
//        lastShownAnyEventNb = -1;
//        for (var i = 0; i < currentSession.event.length; i++){
//            var evt     = currentSession.event[i]
//            var evtName = myEventsNb2Nm[evt[0]]
//            //console.log("step = ", evtName, "step duration = ", evt[1])

//            if (evtName === "Contraction"){
//                //currentView.chart().setAxisX(axisX, currentHrSeries);
//                currentContractionSeries.append( evt[1], currentSession.pulse[evt[1]])
//            }

//            //only use events like brth, hold, walk, back to fill the pulse data
//            if (!(runColors[evtName] === undefined)){
//                currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentChartView.axisX, currentChartView.axisY);
//                //currentView.chart().setAxisX(axisX, currentHrSeries);
//                currentHrSeries.color = runColors[evtName]
//                for (var j = 0; j < evt[1]; j++){
//                    currentHrSeries.append( j, currentSession.pulse[j])

//                }
//            }
//        }

        showSessionGraph(currentSession)

    }
    // currentGaugeName is passed in the case of the browsing previous sessions
    // if routine is called from the 1 sec timer currentGaugeName is undefined
    function showSessionGraph(p_session, currentGaugeName){
        var lastShownAnyEventTm = lastShownAnyEventNb >= 0 ? p_session.event[lastShownAnyEventNb][1]:0
        var lastShownStepEventTm = lastShownStepEventNb >= 0 ? p_session.event[lastShownStepEventNb][1]:0
        var hrMin = getSesssionHRMin(p_session);
        var hrMax = getSesssionHRMax(p_session);
        var currentHrSeries
        currentAxisY.min = (hrMin - 1);
        currentAxisY.max = (hrMax + 1);
        currentAxisX.min = 0;
        currentAxisX.max = p_session.pulse.length
        //remove all points. We will add new ones later
        //currentContractionSeries.removePoints(0, currentContractionSeries.count)
        //currentContractionSeries = currentChartView.createSeries(ChartView.SeriesTypeScatter, "", currentAxisX, currentAxisY);
        for (var i = lastShownAnyEventNb + 1; i < p_session.event.length; i++){
            var evt     = p_session.event[i]
            var evtName = myEventsNb2Nm[evt[0]]
            //var prevEventStop = i == 0? 0: p_session.event[i-1][1]
            //console.log("event = ", evtName, "step duration = ", evt[1], "color=", runColors[evtName])
            //evtStartTime = evt[1]
            currentAxisX.append(evt[1].toString(), evt[1])
            lastShownAnyEventTm = lastShownAnyEventNb >= 0 ? p_session.event[lastShownAnyEventNb][1]:0
            if (evtName === "Contraction"){
                //currentView.chart().setAxisX(axisX, currentHrSeries);
                currentContractionSeries.append( evt[1], p_session.pulse[evt[1]])
                //console.log("event = ", evtName, "X = ", evt[1], "Y = ", p_session.pulse[evtStartTime + evt[1]])

            }

            //only use events like brth, hold, walk, back to fill the pulse data
            if (!(runColors[evtName] === undefined)){
                postEventHrSeries.removePoints(0, postEventHrSeries.count)
                currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentAxisX, currentAxisY);
                //currentView.chart().setAxisX(axisX, currentHrSeries);
                currentHrSeries.color = runColors[evtName]
                for (var j = lastShownStepEventTm; j < evt[1]; j++){
                    currentHrSeries.append( j, currentSession.pulse[j])
                    lastShownPulseTm = j
                }
                lastShownStepEventNb = i
                lastShownStepEventTm = lastShownStepEventNb >= 0 ? p_session.event[lastShownStepEventNb][1]:0
                //evtStartTime += Math.round(evt[1])
                //p_chartView.axes[0].append("22", evtStartTime)
            }
            lastShownAnyEventNb = i
        }
        //the last unfinished lap if it exists
        if (lastShownPulseTm <= p_session.pulse.length){
            //console.log("currenGaugeName=", currentGaugeName)
            if (! (currentGaugeName === undefined)){
                postEventHrSeries.color = runColors[currentGaugeName]
            }
            //hrPlot.currentAxisX.remove((lastShownAnyEventTm + 1).toString())
            if (lastShownPulseTm > lastShownAnyEventTm){
                currentAxisX.remove(lastShownPulseTm.toString())
            }

            for (var i = lastShownPulseTm + 1; i < p_session.pulse.length; i++){
                //remove previous post event labels
                postEventHrSeries.append( i , p_session.pulse[i])
                lastShownPulseTm = i
                //console.log("lastShownAnyEventTm=", lastShownAnyEventTm, "p_session.pulse.length=", currentSession.pulse.length, "i=", i)
            }
            currentAxisX.append((p_session.pulse.length -1).toString(), p_session.pulse.length - 1)
        }
        currentChartView.title = p_session.sessionName + " " + p_session.when
        currentChartView.update()
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
        legend.visible: false
        property CategoryAxis plotAxisX: plotAxisX
        CategoryAxis {
            id: plotAxisX
            startValue:0
            min: 0
            max: sessionDuration
            labelsAngle: -90
            //count: 0
            gridLineColor:"grey"
        }
        ValueAxis {
            id: plotAxisY
            labelFormat:"%.0f"
            //labelsFont: Qt.font({pixelSize : sp(10)})
            min: minHr
            max: maxHr
            gridLineColor:"blue"
            tickCount:6
        }

        LineSeries {
            id: hrSeries
            name: "Heart Rate"
            opacity: 1
            width: dp(5)
            axisX:plotAxisX
            axisY:plotAxisY
            XYPoint { x: 0;  y: 0 }
        }
        ScatterSeries {
            id: contractionSeries
            name: "Contraction"
            opacity: 1
            color: "red"
            borderColor: "black"
            markerShape: ScatterSeries.MarkerShapeCircle
            markerSize: dp(8)
            axisX:plotAxisX
            axisY:plotAxisY
            XYPoint { x: 25;  y: 25 }
            XYPoint { x: 50; y: 50 }
        }
        Component.onCompleted:{
            currentChartView  = chartView
            currentAxisX      = plotAxisX
            currentAxisY      = plotAxisY
        }
    }

} //End Of Plot

