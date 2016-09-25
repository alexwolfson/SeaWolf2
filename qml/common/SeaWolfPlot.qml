import QtQuick 2.7
//import QtQuick.Controls 1.4
//import QtQuick.Controls.Styles 1.4
//import QtQuick.Dialogs 1.2
//import QtQuick.Extras 1.4
import QtQuick.Layouts 1.2
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
    property int  sessionDuration:0
    property int  lastPressEventNb:-1
    property int  lastStepEventNb:-1
    property int  lastPulseTm:-1
    property int  demoModePlusTm:0
    property bool showAbsoluteTm:true //TODO: for switching to showing
                                      //  the relative to the step time
    property font lblsFnt:Qt.font({
      //family: 'Encode Sans',
      //weight: Font.Black,
      italic: true,
      //pixelSize: dp(10)
      //pointSize: dp(15)
    })
    property Rectangle zoomRect:  Rectangle {
           //id: zoomRect
    }
    // number of steps on plot
    property int stepsOnPlot:1000
    property int firstStepNb:0
    function demoHrm(){
        demoModePlusTm = 1000
        console.log("demoModePlusTm = ", demoModePlusTm)
    }
    function realHrm(){
        demoModePlusTm = 0
        console.log("demoModePlusTm = ", demoModePlusTm)
    }

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
        lastPressEventNb = -1;
        lastStepEventNb = -1;
        stepsOnPlot = 1000;
        firstStepNb = 0;
        //prevStepEventNb = -1;
        lastPulseTm = -1;
        currentStepAxisX = chartView.plotAxisX
        currentStepAxisX.max = 0
        var cnt = currentStepAxisX.count
        for (var i = 0; i < cnt; i++){
            currentStepAxisX.remove(currentStepAxisX.categoriesLabels[0])
        }
        currentEventAxisX = chartView.eventAxisX
        currentEventAxisX.max = 0
        cnt = currentEventAxisX.count
        for (var i = 0; i < cnt; i++){
            currentEventAxisX.remove(eventAxisX.categoriesLabels[0])
        }
        //awdebug
        //zoomTimer.start()
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

        showSessionGraph(currentSession)

    }
    // currentGaugeName is passed in the case of the browsing previous sessions
    // if routine is called from the 1 sec timer currentGaugeName is undefined
    function showSessionGraph(p_session, currentGaugeName){
        var lastPressEventTm = lastPressEventNb >= 0 ? p_session.event[lastPressEventNb][1]:0
        var lastStepEventTm = lastStepEventNb >= 0 ? p_session.event[lastStepEventNb][1]:0
        //var prevStepEventTm = prevStepEventNb >= 0 ? p_session.event[prevStepEventNb][1]:0
        var hrMin = getSesssionHRMin(p_session);
        var hrMax = getSesssionHRMax(p_session);
        var currentHrSeries
        var xToShow  //TODO: for switching to showing
                     //  the relative to the step time

        currentAxisY.min = (hrMin - 1);
        currentAxisY.max = (hrMax + 1);
        currentStepAxisX.min = 0;
        currentStepAxisX.max = p_session.pulse.length
        currentEventAxisX.min = currentStepAxisX.min
        currentEventAxisX.max = currentStepAxisX.max

        // going over events that are still not part of the plot
        // if no step type events happened yet, the for loop will be skipped
        for (var i = lastStepEventNb + 1; i < p_session.event.length; i++){

            var evt     = p_session.event[i]
            var evtName = myEventsNb2Nm[evt[0]]
            lastStepEventTm = lastStepEventNb >= 0 ? p_session.event[lastStepEventNb][1]:0
            //prevStepEventTm = p_session.event[lastStepEventNb][1]
            //console.log("prevStepEventTm = ", prevStepEventTm, "lastStepEventNb = ", lastStepEventNb, "evt[1] = ", evt[1])

            //only use events like brth, hold, walk, back to fill the pulse data
            if (!(runColors[evtName] === undefined)){
                //xToShow is an event time so we add new category (in reality just sting with time to stepAxisX
                xToShow = showAbsoluteTm? evt[1]:evt[1] - lastStepEventTm
                currentStepAxisX.append((xToShow + demoModePlusTm).toString(), evt[1])
                currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentStepAxisX, currentAxisY);
                currentHrSeries.color = runColors[evtName]
                //console.log("prevStepEventTm = ", prevStepEventTm, "lastStepEventTm = ", lastStepEventTm, "evt[1] = ", evt[1])
                for (var j = lastStepEventTm; j <= evt[1]; j++){
                    currentHrSeries.append( j, currentSession.pulse[j])
                }

                // remove the category label created by the Last shown pulse time if needed
                if ((lastPulseTm !== lastStepEventTm) && (lastPulseTm !== lastStepEventTm)){
                    xToShow = showAbsoluteTm? lastPulseTm-1:lastPulseTm-1 - lastStepEventTm
                    currentStepAxisX.remove((xToShow + demoModePlusTm).toString())
                }
                lastStepEventNb = i
                lastStepEventTm = lastStepEventNb >= 0 ? p_session.event[lastStepEventNb][1]:0
                //evtStartTime += Math.round(evt[1])
                //p_chartView.axes[0].append("22", evtStartTime)
            }else{
                // non step (key press) events are only added to the plot. No need to remove labels
                if (evtName === "Contraction"){
                    //currentView.chart().setAxisX(axisX, currentHrSeries);
                    xToShow = showAbsoluteTm? evt[1]:evt[1] - lastStepEventTm
                    currentEventAxisX.append((xToShow + demoModePlusTm).toString(), evt[1])
                    currentContractionSeries.append( evt[1], p_session.pulse[evt[1]])
                    console.log("event = ", evtName, "X = ", xToShow, "Y = ", p_session.pulse[evt[1]])

                }
                lastPressEventNb = i
            }

        }
        //the last not fully shown lap if it exists
        if (lastStepEventTm <= p_session.pulse.length){
            //console.log("currenGaugeName=", currentGaugeName)
            if (! (currentGaugeName === undefined)){
                postEventHrSeries.color = runColors[currentGaugeName]
            }
            if (lastPulseTm !== lastStepEventTm){
                xToShow = showAbsoluteTm? lastPulseTm:lastPulseTm - lastStepEventTm
                currentStepAxisX.remove((xToShow + demoModePlusTm).toString())
            }

            for (var k = Math.max(lastPulseTm, lastStepEventTm) ; k < p_session.pulse.length; k++){
                postEventHrSeries.append( k , p_session.pulse[k])
                lastPulseTm = k
                //console.log("lastPressEventTm=", lastPressEventTm, "p_session.pulse.length=", currentSession.pulse.length, "k=", k)
            }
            xToShow = showAbsoluteTm? lastPulseTm:lastPulseTm - lastStepEventTm
            currentStepAxisX.append((xToShow + demoModePlusTm).toString(), lastPulseTm)
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
        margins{top:dp(50); bottom:dp(50)}
        //to make visible part of the graph taking bigger part
        //anchors.topMargin: dp(-20)
        antialiasing: true
        theme: ChartView.ChartThemeBlueIcy
        legend.visible: false
        property CategoryAxis plotAxisX: plotAxisX
        property CategoryAxis eventAxisX: eventAxisX
        CategoryAxis {
            id: plotAxisX
            startValue:0
            min: 0
            max: sessionDuration
            labelsAngle: -90
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue
            labelsColor: "navy"
            labelsFont:lblsFnt
            //count: 0
            gridLineColor:labelsColor

        }
        CategoryAxis {
            id: eventAxisX
            startValue:0
            min: 0
            max: sessionDuration
            labelsAngle: -90
            labelsColor: "#FF7F50"
            labelsFont:lblsFnt
            //count: 0
            gridLineColor: labelsColor
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
            axisXTop: eventAxisX
            axisY:plotAxisY
            XYPoint { x: 25;  y: 25 }
            XYPoint { x: 50; y: 50 }
        }
        Component.onCompleted:{
            currentChartView  = chartView
            currentStepAxisX  = plotAxisX
            currentAxisY      = plotAxisY
            currentEventAxisX = eventAxisX
        }
    }
    RowLayout {
        id: plotControls
        width:parent.width
        MenuButton {
            id: left
            text: "< "
            onClicked: {
                firstStepNb = Math.max(0, firstStepNb - stepsOnPlot)
            }
        }
        MenuButton {
            id: x1
            text: " x1 "
            onClicked: { stepsOnPlot = 1 }
        }
        MenuButton {
            id: x2
            text: " x2 "
            onClicked: { stepsOnPlot = 2 }
        }
        MenuButton {
            id: x4
            text: " x4 "
            onClicked: { stepsOnPlot = 4 }

        }
        MenuButton {
            id: xAll
            text: " x" + String.fromCharCode(0x221e) + " "  //infinity
            onClicked: { stepsOnPlot = 1000 }
        }
        MenuButton {
            id: right
            text: " >"
            onClicked: {
                var totalSteps = currentSession.event.length
                if (currentSession.event[lastStepEventNb][1] < lastPulseTm) {
                    ++totalSteps
                }
                firstStepNb = Math.min( firstStepNb - stepsOnPlot, totalSteps - stepsOnPlot)
            }
        }
    }

} //End Of Plot

