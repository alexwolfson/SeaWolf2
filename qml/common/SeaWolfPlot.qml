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
    property CategoryAxis  currentStepAxisX
    property CategoryAxis  currentEventAxisX
    property ValueAxis     currentAxisY
    property real minHr:10
    property real maxHr:150
    property int sessionDuration:0
    property int lastShownPressEventNb
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
        lastShownPressEventNb = -1;
        lastShownStepEventNb = -1;
        lastShownPulseTm = -1;
        currentStepAxisX = chartView.plotAxisX
        currentStepAxisX.max = 0
        var cnt = currentStepAxisX.count
        for (var i = 0; i < cnt; i++){
            currentStepAxisX.remove(currentStepAxisX.categoriesLabels[0])
        }
        //currentEventAxisX = chartView.eventAxisX
        currentEventAxisX.max = 0
        cnt = currentEventAxisX.count
        for (var i = 0; i < cnt; i++){
            currentEventAxisX.remove(eventAxisX.categoriesLabels[0])
        }

    }
    //creates new series graph
    function setupCurrentSeries(){
        currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentStepAxisX, currentAxisY);
        //currentHrSeries.color = runColors[currentGauge.gaugeName]
        currentContractionSeries = currentChartView.createSeries(ChartView.SeriesTypeScatter, "", currentEventAxisX, currentAxisY);
        postEventHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentStepAxisX, currentAxisY)
    }
    function markEvent(eventName){
        var eventNb = myEventsNm2Nb[eventName];
        var tm      = runSessionScene.getSessionTime()//Math.round(currentGauge.value)
        currentSession.event.push([eventNb, tm])
//        if (eventName === "Contraction"){
//            console.log("Mark Contraction, tm=", tm, "Y =", currentSession.pulse[tm])
//            currentContractionSeries.append(tm, currentSession.pulse[tm])
//        }
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
//        postEventHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentStepAxisX, currentAxisY)
//        lastShownPressEventNb = -1;
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
        var lastShownPressEventTm = lastShownPressEventNb >= 0 ? p_session.event[lastShownPressEventNb][1]:0
        var lastShownStepEventTm = lastShownStepEventNb >= 0 ? p_session.event[lastShownStepEventNb][1]:0
        var hrMin = getSesssionHRMin(p_session);
        var hrMax = getSesssionHRMax(p_session);
        var currentHrSeries
        currentAxisY.min = (hrMin - 1);
        currentAxisY.max = (hrMax + 1);
        currentStepAxisX.min = 0;
        currentStepAxisX.max = p_session.pulse.length
        currentEventAxisX.min = currentStepAxisX.min
        currentEventAxisX.max = currentStepAxisX.max
        for (var i = lastShownStepEventNb + 1; i < p_session.event.length; i++){
            var evt     = p_session.event[i]
            var evtName = myEventsNb2Nm[evt[0]]
            lastShownStepEventTm = lastShownStepEventNb >= 0 ? p_session.event[lastShownStepEventNb][1]:0

            //only use events like brth, hold, walk, back to fill the pulse data
            if (!(runColors[evtName] === undefined)){
                if (postEventHrSeries.count > 0){
                    currentStepAxisX.remove(lastShownPulseTm.toString())
                    postEventHrSeries.removePoints(0, postEventHrSeries.count)
                }
                currentStepAxisX.append(evt[1].toString(), evt[1])
                currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentStepAxisX, currentAxisY);
                //currentView.chart().setAxisX(axisX, currentHrSeries);
                currentHrSeries.color = runColors[evtName]
                for (var j = lastShownStepEventTm; j <= evt[1]; j++){
                    currentHrSeries.append( j, currentSession.pulse[j])
                    lastShownPulseTm = j
                }
                lastShownStepEventNb = i
                lastShownStepEventTm = lastShownStepEventNb >= 0 ? p_session.event[lastShownStepEventNb][1]:0
                //evtStartTime += Math.round(evt[1])
                //p_chartView.axes[0].append("22", evtStartTime)
            }else{
                if (evtName === "Contraction"){
                    //currentView.chart().setAxisX(axisX, currentHrSeries);
                    currentEventAxisX.append(evt[1].toString(), evt[1])
                    currentContractionSeries.append( evt[1], p_session.pulse[evt[1]])
                    console.log("event = ", evtName, "X = ", evt[1], "Y = ", p_session.pulse[evt[1]])

                }
            }

            lastShownPressEventNb = i
            //currentStepAxisX.append((p_session.pulse[evt[1]]).toString(), p_session.pulse[evt[1]])
        }
        //the last unfinished lap if it exists
        if (lastShownPulseTm <= p_session.pulse.length){
            //console.log("currenGaugeName=", currentGaugeName)
            if (! (currentGaugeName === undefined)){
                postEventHrSeries.color = runColors[currentGaugeName]
            }
            //hrPlot.currentStepAxisX.remove((lastShownPressEventTm + 1).toString())
            if (lastShownPulseTm > lastShownStepEventTm){
                currentStepAxisX.remove(lastShownPulseTm.toString())
            }

            for (var k = lastShownPulseTm ; k < p_session.pulse.length; k++){
                postEventHrSeries.append( k , p_session.pulse[k])
                lastShownPulseTm = k
                //console.log("lastShownPressEventTm=", lastShownPressEventTm, "p_session.pulse.length=", currentSession.pulse.length, "k=", k)
            }
            currentStepAxisX.append(lastShownPulseTm.toString(), lastShownPulseTm)
        }
        //currentChartView.title = p_session.sessionName + " " + p_session.when
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
            labelsPosition: CategoryAxis.AxisLabelsPositionCenter
            //count: 0
            gridLineColor:"grey"
        }
        CategoryAxis {
            id: eventAxisX
            startValue:0
            min: 0
            max: sessionDuration
            labelsAngle: -90
            //count: 0
            gridLineColor:"#FF7F50"
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue
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
            markerSize: dp(6)
            axisX:plotAxisX
            axisY:plotAxisY
            XYPoint { x: 25;  y: 25 }
            XYPoint { x: 50; y: 50 }
        }
        Component.onCompleted:{
            currentChartView  = chartView
            currentStepAxisX      = plotAxisX
            currentAxisY      = plotAxisY
            currentEventAxisX = eventAxisX
        }
    }

} //End Of Plot

