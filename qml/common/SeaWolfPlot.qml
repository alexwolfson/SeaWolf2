import QtQuick 2.7
import QtQuick.Controls 2.0
//import QtQuick.Controls.Styles 1.4
//import QtQuick.Dialogs 1.2
//import QtQuick.Extras 1.4
import QtQuick.Layouts 1.3
import QtMultimedia 5.6
//import QtQml 2.2
import QtCharts 2.1
// Events have Nb - number in currentSession.event, Enum Enum representation of type ("brth":0, "hold": 1),
//     Tm - time when it happened
Rectangle{
    id:hrPlot
    width:parent.width // + dp(50)
    height: parent.height/2.5
    anchors.horizontalCenter: parent.horizontalCenter
    //anchors.top: runSessionScene.top
    //anchors.topMargin: sessionView.cellWidth * 3
    opacity:1.0
    z:50
    property var myEventsNm2Enum:{"brth":0 , "hold":1, "walk":2, "back":3, "EndOfMeditativeZone":4, "EndOfComfortZone":5, "Contraction":6, "EndOfWalk":7 }
    property var myEventsEnum2Nm: invert(myEventsNm2Enum)
    property var runColors: {"brth" : "green", "hold" : "tomato", "walk" : "blue", "back" : "orange"}
    //property var eventsGraphProperty:{"Contraction":["red", "black", 6]}
    property var currentSession: {
        "sessionName":"TestSession",
                "when":"ChangeMe", //Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss"),
                "eventNames":myEventsNm2Enum,
                "event":[],
                "pulse":[],
                "discomfort":[]
    }
    //property LineSeries    currentHrSeries
    property LineSeries    currentStepHrSeries
    property LineSeries    currentDiscomfortSeries
    property ScatterSeries currentContractionSeries: contractionSeries
    property ChartView     currentChartView
    property CategoryAxis  currentStepAxisX
    property CategoryAxis  currentEventAxisX
    property ValueAxis     currentAxisY
    property real discomfortValue: 0.0 //discomfortSlider.from + (discomfortSlider.to - discomfortSlider.from) * discomfortSlider.visualPosition
    //property int           currentStepEventEnum
    property real  minHr:10
    property real  maxHr:150
    property int   sessionDuration:0
    property int   lastPressEventNb:-1
    property int   currentStepEventNb:-1
    property int   currentStepEventEnum:-1
    property int   currentStepEventStartTm: -1
    property int   currentStepEventStopTm: -1
    property int   lastPulseOnPlotTm:-1
    property int   lastStepEventToShowNb: -1
    property int   lastStepEventOnPlotTm: -1
    property int   lastStepEventTm: -1
    property string lastStepEventNm: "brth"
    // maximal number of steps on plot
    property int  maxStepsOnPlot:1000
    property int  firstStepEventToPlotNb:-1
    property string lastStepXLabel: ""
    property int   xToShow: 0  //TODO: for switching to showing
    property int   demoModePulseTm:0
    property bool  showAbsoluteTm:true //TODO: for switching to showing
    //  the relative to the step time
    property font  lblsFnt:Qt.font({
                                      //family: 'Encode Sans',
                                      //weight: Font.Black,
                                      italic: true,
                                      //pixelSize: dp(10)
                                      //pointSize: dp(15)
                                  })
    property bool canCreateSeriesFlag: true
    function demoHrm(){
        demoModePulseTm = 0 //1000
        console.log("demoModePulseTm = ", demoModePulseTm)
    }

    function realHrm(){
        demoModePulseTm = 0
        console.log("demoModePulseTm = ", demoModePulseTm)
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

    function resetShow(){
        sessionDuration = 0
        currentChartView.removeAllSeries()
        setupCurrentSeries()
        lastPulseOnPlotTm = -1;
        currentStepAxisX = chartView.plotAxisX
        currentStepAxisX.max = 0
        lastStepEventNm = "brth"
        var cnt = currentStepAxisX.count
        for (var i = 0; i < cnt; i++){
            currentStepAxisX.remove(currentStepAxisX.categoriesLabels[0])
        }
        currentEventAxisX = chartView.eventAxisX
        currentEventAxisX.max = 0
        cnt = currentEventAxisX.count
        for (var ev = 0; ev < cnt; ev++){
            currentEventAxisX.remove(eventAxisX.categoriesLabels[0])
        }
    }

    function init(){
        resetShow()
        currentSession.event=[]
        currentSession.pulse=[]
        currentSession.discomfort = []
        sessionDuration    = 0
        lastPressEventNb   = -1
        currentStepEventEnum    = -1
        currentStepEventStartTm = -1
        currentStepEventStopTm  = -1
        lastStepEventToShowNb = -1
        currentSession.when = Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss");
        lastPressEventNb = -1;
        currentStepEventEnum  = -1;
        maxStepsOnPlot        = 1000;
        firstStepEventToPlotNb   = -1;
    }


    function getStepEventsNb(){
        var result = 0;

        for (var i=0; i < currentSession.event.length; i++){
            var evt     = currentSession.event[i]
            var eventName = myEventsEnum2Nm[evt[0]]
            //listByName(this, "getStepEventNb", ["result", "eventName", "evt[1]"])
            //only use events like brth, hold, walk, back to fill the pulse data
            if (!(runColors[eventName] === undefined)){
                result++;
            }
        }
        return result
    }


    //creates new series graph
    function setupCurrentSeries(){
        //currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "0", currentStepAxisX, currentAxisY);
        //currentHrSeries.color = runColors[currentGauge.gaugeName]
        currentContractionSeries = currentChartView.createSeries(ChartView.SeriesTypeScatter, "contraction", currentEventAxisX, currentAxisY);
        currentStepHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "0", currentStepAxisX, currentAxisY)
        currentDiscomfortSeries    = currentChartView.createSeries(ChartView.SeriesTypeLine, "0", currentStepAxisX, discomfortAxisY)
        currentDiscomfortSeries.color = "red"
        currentDiscomfortSeries.width = dp(5)
    }

    function listByNameLocal(that, msg, nameList){
        var name
        var val = "undefined"
        console.log(" *** " + msg + ": print start " + " ***")
        for (var i =0; i < nameList.length; i++){
            name = nameList[i]
            var val1 = eval(name)
            if (val === undefined){
                val = that[name]
            }
            if (val === undefined){
                val = eval(that[name])
            }
            if (val === undefined){
                val ="still undefined"
            }

            console.log(nameList[i], ": ", val)
        }
        console.log(" *** " + msg + ": print end " + " ***")
    }

    function markEvent(eventName, tm){
        canCreateSeriesFlag = false
        var eventEnum = myEventsNm2Enum[eventName];
        currentSession.event.push([eventEnum, tm])
        if (! (runColors[eventName] === undefined)){
            lastStepEventTm = tm
            lastStepEventNm = eventName
            // the rest of the setup will be done during onSeriesAdded signal processing
            currentStepHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, lastStepEventTm.toString(), currentStepAxisX, currentAxisY)
            //currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentStepAxisX, currentAxisY);
        }
        console.log("markEvent: eventName = ", eventName, "lastStepEventNm = ", lastStepEventNm, "eventNb = ", currentSession.event.length)
    }
    function addPointToPlot(tm, y){
        currentStepHrSeries.append(tm,y)
//        currentStepAxisX.min = 0
//        currentStepAxisX.max = currentSession.pulse.length
        //currentStepAxisX.min = plotRangeControl.first.value
        //currentStepAxisX.max = plotRangeControl.second.value
        currentAxisY.min = getSesssionHRMin(currentSession)
        currentAxisY.max = getSesssionHRMax(currentSession)
        // currentStepAxisX.min and max are set by the range slider
        currentEventAxisX.min = currentStepAxisX.min
        currentEventAxisX.max = currentStepAxisX.max
        //testing that the last X label was't end of step label

        console.log( " In addPointToPlot: tm = ", tm,  "lastStepEventTm = ", lastStepEventTm,
                    "currentStepAxisX.min =", currentStepAxisX.min, "currentStepAxisX.max = ", currentStepAxisX.max)
        if ( (tm -1) !== lastStepEventTm ){
            currentStepAxisX.remove(lastStepXLabel)
            console.log("removing [", lastStepXLabel, "] tm = ", tm)
        }else{
            //currentStepAxisX.append(lastStepXLabel, tm-1)
            //console.log("addingg [", lastStepXLabel, "]")
        }

        lastStepXLabel = (tm + demoModePulseTm).toString()
        currentStepAxisX.append(lastStepXLabel, tm)
        console.log("addingg [", lastStepXLabel, "]")

        //update if series creation is finished
        if (canCreateSeriesFlag){
            //console.log("tm = ", tm, "lastStepXLabel = ", lastStepXLabel, "currentStepAxisX.min =", currentStepAxisX.min, "currentStepAxisX.max =", currentStepAxisX.max)
            currentChartView.update()
            //console.log("Plot Updated")
        }
    }
    function makeStepAxisXLabel(tm){

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
        //console.log("**** In setupSession width ", sessionName, ":", selectedSession)
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
    function rangeSliderUpdate(){
        plotRangeControl.from = 0;
        plotRangeControl.to = currentSession.pulse.length
        // fixing range slider handle position to the max range for the first time
        // first time is recognized by the second.value === 0)
        if (plotRangeControl.second.value === 0){
            plotRangeControl.second.value = 10000
        }
        plotRangeControl.first.visualPositionChanged()
        plotRangeControl.second.visualPositionChanged()
        currentChartView.update()
    }

    function showSessionGraph(p_session){
        console.log("*** Enetered showSessionGraph ")
        var tmStart = 0
        var tmStop  = 0
        var eventNb = -1
        var hrMin = getSesssionHRMin(p_session);
        var hrMax = getSesssionHRMax(p_session);
        var eventName = ""
        // var currentHrSeries
        //  the relative to the step time

        currentAxisY.min = (hrMin - 1);
        currentAxisY.max = (hrMax + 1);

        //TODO does it make sence to synchronyze with ending steps in SeaWolfControls ? Mutex?
        // Is some sort of race condition is possible here?
        // May be call markEvent from here instead of from the gauges state change?
        console.log("In showSessionGraph: p_session.event.length", p_session.event.length)
        run.nextStepName = "brth"
        for (eventNb = 0; eventNb < p_session.event.length; eventNb++){
            tmStart = tmStop
            tmStop = p_session.event[eventNb][1]
            eventName = myEventsEnum2Nm[p_session.event[eventNb][0]]
            // for step events only
            if (! (runColors[eventName] === undefined)){
                //run.nextStepName is used in onSeriesAdded
                // TODO: consolidate and make SeaWolfPlot self sofficient?
                run.nextStepName = myEventsEnum2Nm[p_session.event[eventNb][0]]
                lastStepEventTm = tmStart
               //markEvent(myEventsEnum2Nm[p_session.event[eventNb][0]], tmStop)
               currentStepHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, tmStop.toString(), currentStepAxisX, currentAxisY)
            }

            for (var tm = tmStart; tm <= tmStop; tm ++){
                addPointToPlot(tm, p_session.pulse[tm])
                currentDiscomfortSeries.append(tm, p_session.discomfort[tm])

            }
        }
        rangeSliderUpdate()
        currentChartView.title = p_session.sessionName + " " + p_session.when

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
        onSeriesAdded:{
            console.log ("in onSeriesAdded lastStepEventNm:", lastStepEventNm, "myEventsNm2Enum[lastStepEventNm]", myEventsNm2Enum[lastStepEventNm])
            series.color = runColors[run.nextStepName]
            console.log ("in onSeriesAdded series.color:", series.color)
            update()
            canCreateSeriesFlag = true;
        }

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
        ValueAxis {
            id: discomfortAxisY
            labelFormat:"%.0f"
            //labelsFont: Qt.font({pixelSize : sp(10)})
            min: 0
            max: 10
            gridLineColor:"grey"
            tickCount:10
         }

        LineSeries {
            id: hrSeries
            name: "Heart Rate"
            opacity: 1
            width: dp(5)
            axisX:plotAxisX
            axisY:plotAxisY
//            XYPoint { x: 0;  y: 0 }
//            XYPoint { x: 50; y: 50 }
        }
        LineSeries {
            id: discomfortSeries
            name: qsTr("Discomfort")
            opacity: 1
            width: dp(5)
            axisX:plotAxisX
            axisY:discomfortAxisY
//            XYPoint { x: 0;  y: 0 }
//            XYPoint { x: 50; y: 50 }
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
//            XYPoint { x: 25;  y: 25 }
//            XYPoint { x: 50; y: 50 }
        }
        Component.onCompleted:{
            console.log("In SeaWolfPlotComponent.onCompleted")
            currentChartView  = chartView
            currentStepAxisX  = plotAxisX
            currentAxisY      = plotAxisY
            currentEventAxisX = eventAxisX
            currentDiscomfortSeries  = discomfortSeries
        }
    }
    RangeSlider{
        id: plotRangeControl
        anchors.left:   chartView.left
        anchors.right:  chartView.right
        anchors.bottom: chartView.bottom
        from: 0
        to:   0 //undefined === currentSession.pulse.length? 50 : currentSession.pulse.length
        stepSize: 1
        //first.value: 10
        //second.value: 50
        first.onValueChanged:  {currentStepAxisX.min = first.value}
        second.onValueChanged: {currentStepAxisX.max = second.value}
        //For some reason the visual position change requires a manual value setup. A bug or wrong usage?
        first.onVisualPositionChanged:  { var v1 = Math.round(from +  (to -  from )  * first.visualPosition);  first.value =  v1;
            //                             console.log(" In rangeSlider: first.from, to, value, visualPosition = " , from, to, first.value, first.visualPosition)
            }
        second.onVisualPositionChanged: { var v1 = Math.round(from + (to - from ) * second.visualPosition); second.value = v1;
            //                             console.log(" In rangeSlider: second.from, to, value, visualPoition = " , from, to, second.value, second.visualPosition)
            }
        first.handle: Rectangle {
            x: parent.leftPadding + parent.first.visualPosition * (parent.availableWidth - width)
            y: parent.topPadding + parent.availableHeight / 2 - height / 2
            implicitWidth: dp(60)
            implicitHeight: dp(60)
            radius: dp(30)
            //color: parent.first.pressed ? "#f0f0f0" : "#f6f6f6"
            color: "orange"
            border.color: "#bdbebf"
            Text {
                id: leftRangeSliderText
                anchors.centerIn: parent
                font.pixelSize: dp (30)
                elide: Text.ElideMiddle
                //color: "#F0EBED"
                color: "black"
                text:  "<->"
            }

        }

        second.handle: Rectangle {
            x: parent.leftPadding + parent.second.visualPosition * (parent.availableWidth - width)
            y: parent.topPadding + parent.availableHeight / 2 - height / 2
            implicitWidth: dp(60)
            implicitHeight: dp(60)
            radius: dp(30)
            //color: parent.second.pressed ? "#f0f0f0" : "#f6f6f6"
            color:"orange"
            border.color: "#bdbebf"
            Text {
                id: rightRangeSliderText
                anchors.centerIn: parent
                font.pixelSize: dp (30)
                elide: Text.ElideMiddle
                //color: "#F0EBED"
                color: "black"
                text: "<->"
            }
        }
    }
    Slider {
        id: discomfortSlider
        //anchors.left:   chartView.left
        anchors.right:  chartView.right
        anchors.top: chartView.top
        anchors.bottom: chartView.bottom
        anchors.margins: {
            top:   chartView.margins.top;
            right: discomfortSliderHandle.width/2;
            bottom:chartView.margins.bottom
        }
        value: 0.0
        from:0
        to:10
        //stepSize: 0.1
        implicitWidth: dp(40)
        orientation:Qt.Vertical
        onPositionChanged:  { var v1 = from +  (to -  from )  * position;  value =  v1; discomfortValue = v1;
                                                 console.log(" In discomfortSlider: from, to, value, position = " , from, to, value, position)
                    }
        background:Rectangle {
            height: parent.height
            width: parent.width
            //color: "#21be2b"
            radius: dp(8)
            gradient: Gradient {
                GradientStop {
                    position: 1.00;
                    color: "blue";
                }
                GradientStop {
                    position: 0.00;
                    color: "red";
                }
            }
            Text{
                anchors.fill: parent
                anchors.margins: dp(2)
                color:"white"
                text: qsTr("Discomfort Level")
                verticalAlignment: Text.AlignVCenter
                rotation: -90
                horizontalAlignment: Text.AlignHCenter
                //anchors.verticalCenter: parent.verticalCenter
            }

        }

        handle: Rectangle {
            id:discomfortSliderHandle
            y: discomfortSlider.bottomPadding + discomfortSlider.visualPosition * (discomfortSlider.availableHeight - height)
            x: discomfortSlider.leftPadding + discomfortSlider.availableWidth / 2 - width / 2
            implicitWidth: dp(120)
            implicitHeight: dp(120)
            radius: dp(60)
            opacity: discomfortSlider.pressed ? 0.8 : 1.0
            color: "orange"
            border.color: "#bdbebf"
        }
   }
} //End Of Plot

