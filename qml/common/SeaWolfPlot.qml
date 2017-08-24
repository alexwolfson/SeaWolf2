import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
//import Qt.labs.platform 1.0
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.3
import QtMultimedia 5.6
//import QtQml 2.2
import QtCharts 2.1
import MyStuff 1.0
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
    property var currentSessionOrig: {
        "sessionName":"TestSession",
                "when":"ChangeMe", //Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss"),
                "eventNames":myEventsNm2Enum,
                "event":[],
                "pulse":[],
                "discomfort":[]
    }
    property var currentSession
    //property LineSeries    currentHrSeries
    property LineSeries    currentStepHrSeries
    property LineSeries    currentDiscomfortSeries
    property ScatterSeries currentContractionSeries
    property ChartView     currentChartView
    //property CategoryAxis  currentStepAxisX
    property alias currentStepAxisX:  chartView.plotAxisX
    //property CategoryAxis  currentEventAxisX
    property alias currentEventAxisX: chartView.eventAxisX
    property ValueAxis     currentAxisY
    property real discomfortValue: 0.0 //discomfortSlider.from + (discomfortSlider.to - discomfortSlider.from) * discomfortSlider.visualPosition
    //property int           currentStepEventEnum
    property real  minHr:                   10
    property real  maxHr:                   150
    property int   sessionDuration:         0
    property int   lastPressEventNb:       -1
    property int   currentStepEventNb:     -1
    property int   currentStepEventEnum:   -1
    property int   currentStepEventStartTm:-1
    property int   currentStepEventStopTm: -1
    property int   lastPulseOnPlotTm:      -1
    property int   lastStepEventToShowNb:  -1
    property int   lastStepEventOnPlotTm:  -1
    property int   lastStepEventTm:         0
    property string lastStepEventNm:       "brth"
    property alias plotRangeControl:        plotRangeControl
    // maximal number of steps on plot
    property int  maxStepsOnPlot:           1000
    property int  firstStepEventToPlotNb:  -1
    property string lastStepXLabel:         ""
    property int   xToShow:                 0  //TODO: for switching to showing
    property int   demoModePulseTm:         0
    property bool  showAbsoluteTm:          true //TODO: for switching to showing
    //  the relative to the step time
    property font  lblsFnt:Qt.font({
                                       //family: 'Encode Sans',
                                       //weight: Font.Black,
                                       bold: true,
                                       italic: true,
                                       //pixelSize: dp(10)
                                       pointSize: 10 //dp(10)
                                   })
    property bool canCreateSeriesFlag:      true
    property var additionalXLabels:         []
    property int totalXLabelsNb:       8
    property var stepXLabels:               []
    property int lastBackEvebtNb
    property int lastBackStepNb: -1
    function sessionTimeUpdateSlot(sessionTime){
        //TODO: update current time
    }

    function getLblTm(lbl){
        if (lbl === undefined){
            return 0
        }

        var tm = lbl.split("/")[1]
        //console.log("getLblTm", tm)
        return parseInt(tm, 10)
    }
    function restoreStepXLabels(){
        saveStepXLabels()
        // clean currentStepAxisX labels
        var cnt = currentStepAxisX.count
        var i
        for (i = 0; i < cnt; i++){
            //stepXLabels.push(currentStepAxisX.categoriesLabels[0])
            currentStepAxisX.remove(currentStepAxisX.categoriesLabels[0])
        }
        for (i = 0; i < stepXLabels.length; i++){
            var lbl = stepXLabels[i]
            var tm = getLblTm(lbl)
            if ((tm >= 0) && (tm <= currentSession.pulse.length)){
                currentStepAxisX.append(lbl, tm)
            }
        }
    }
    // This function adds additionalXLabels to the existing step labels
    //    this is done to support additional grid
    function updateAdditionalXLabels(){
        //        var neededLabelNb = Math.max(0, totalXLabelsNb - currentPlotAxisX.count)
        var i

        var lblTm
        var lbl
        //calculate indexes of labels that needs to be shown

        var savedDone       = false
        var stepXLabelsIndexStart = 0
        var stepXLabelsIndexStop  = 0
        var stepXLabelsIndex      = 0
        var additionalDone  = false
        var additionalIndex = 0
        var tmStepXLabel           = 10000
        var tmAdditional    = 10000
        // find the first index that is in the Axis X range
        var foundStepXStart = false
        var foundStepXStop  = false
        saveStepXLabels()

        for (stepXLabelsIndexStart = 0; stepXLabelsIndexStart < stepXLabels.length; stepXLabelsIndexStart++){
            if(getLblTm(stepXLabels[stepXLabelsIndexStart]) >= currentStepAxisX.min){
                foundStepXStart = true
                break
            }
        }
        // find the last index that is in the Axis X range
        for (stepXLabelsIndexStop = stepXLabelsIndexStart; stepXLabelsIndexStop < stepXLabels.length; stepXLabelsIndexStop++){
            if(getLblTm(stepXLabels[stepXLabelsIndexStop]) >= currentStepAxisX.max){
                stepXLabelsIndexStop--
                break
            }
        }
        if (stepXLabelsIndex >=0){
            foundStepXStop = true
        }
        var nbOfShownStepLabels = 0
        if (foundStepXStart && foundStepXStop){
            nbOfShownStepLabels = stepXLabelsIndexStop - stepXLabelsIndexStart + 1
        }
        var neededLabelNb = nbOfShownStepLabels >= totalXLabelsNb ? 0: totalXLabelsNb - nbOfShownStepLabels
        var cnt
        if (neededLabelNb <= 0){
            restoreStepXLabels()
            return
        }
        var interval = Math.floor((currentStepAxisX.max - currentStepAxisX.min)/(neededLabelNb + 1))
        if (interval === 0){
            restoreStepXLabels()
            return
        }

//        console.log("**** updateAdditionalXLabels interval = ", interval,
//                    "currentStepAxisX.min = ",  currentStepAxisX.min,
//                    "currentStepAxisX.max = ",  currentStepAxisX.max,
//                    "nbOfShownStepLabels=", nbOfShownStepLabels,
//                    "additionalXLabels.length = ", additionalXLabels.length,
//                    "currentStepAxisX.categoriesLabels.length = ", currentStepAxisX.categoriesLabels.length)
        // Calculate new additionalXLabels
        additionalXLabels = []
        for (lblTm = Math.floor(currentStepAxisX.min) + interval; lblTm <= currentStepAxisX.max -interval; lblTm += interval){
            lbl = (lblTm - getCurrentStepStartTm(lblTm)).toString() + "/" + (lblTm + demoModePulseTm).toString()
            additionalXLabels.push(lbl)
            // currentStepAxisX.append(lbl, lblTm)
            //console.log("AdditionaXLabels: Added ", lbl, "at [", lblTm, "]")
        }

        // clean currentStepAxisX labels
        cnt = currentStepAxisX.count
        for (i = 0; i < cnt; i++){
            //stepXLabels.push(currentStepAxisX.categoriesLabels[0])
            currentStepAxisX.remove(currentStepAxisX.categoriesLabels[0])
        }

        // Update Axis
        //AW TODO seems too complicated - it just to merge 2 lists
        if (foundStepXStart && foundStepXStop){
            stepXLabelsIndex = stepXLabelsIndexStart
        }else{
            stepXLabelsIndex = 0
        }

        additionalIndex  = 0
        while (! (savedDone && additionalDone)      &&
               (//stepXLabels are still in the range
                ((getLblTm(stepXLabels[stepXLabelsIndex]) >= currentStepAxisX.min) &&
                 (getLblTm(stepXLabels[stepXLabelsIndex]) <= currentStepAxisX.max)) ||               //additionalXLabels are still in the range
                ((getLblTm(additionalXLabels[additionalIndex]) >= currentStepAxisX.min) &&
                 (getLblTm(additionalXLabels[additionalIndex]) <= currentStepAxisX.max))
                ) &&
               ((stepXLabelsIndex < stepXLabels.length) || (additionalIndex < additionalXLabels.length))){
            if (stepXLabelsIndex < stepXLabels.length){
                tmStepXLabel = getLblTm(stepXLabels[stepXLabelsIndex])
            }
            else{
                savedDone = true
                tmStepXLabel     = 10000
            }

            if (additionalIndex < additionalXLabels.length){
                tmAdditional = getLblTm(additionalXLabels[additionalIndex])
            }
            else{
                additionalDone = true
                tmAdditional   = 10000
            }

            if (tmStepXLabel < tmAdditional){
                currentStepAxisX.append(stepXLabels[stepXLabelsIndex], tmStepXLabel)
                stepXLabelsIndex++
            }else if (tmStepXLabel > tmAdditional) {
                currentStepAxisX.append(additionalXLabels[additionalIndex], tmAdditional)
                additionalIndex++
            }else{
                //(tmStepXLabel == tmAdditional) {
                currentStepAxisX.append(additionalXLabels[stepXLabelsIndex], tmStepXLabel)
                additionalIndex++
                stepXLabelsIndex++
            }
        }

        //        for (lblTm = Math.floor(currentStepAxisX.min); lblTm < currentStepAxisX.max; lblTm += interval){
        //            lbl = (lblTm - getCurrentStepStartTm(lblTm)).toString() + "/" + (lblTm + demoModePulseTm).toString()
        //            additionalXLabels.push(lbl)
        //            // currentStepAxisX.append(lbl, lblTm)
        //            console.log("Added ", lbl, "at [", lblTm, "]")
        //        }
    }
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

    function getCurrentStepStartTm(tm){
        //console.log("currentSession.event.length = ", currentSession.event.length)
        if (currentSession.event.length === 0){
            return 0
        }

        var evt   = currentSession.event[0]
        var evtTm = 0
        var nextEvt
        for (var i = 0; (i < currentSession.event.length) && (currentSession.event[i][1] < currentStepAxisX.max); i++ ){
            nextEvt = currentSession.event[i]
            if (isNewSeriesEvent(nextEvt[0])){
                if ((nextEvt[1] >= tm) ){
                    return evtTm
                }
                evtTm = nextEvt[1]

            }
        }
        if (tm < evtTm){
            console.log("Event tm > tm", evtTm, tm)
        }
        //
        return evtTm
    }

    function resetShow(){
        sessionDuration = 0
        currentChartView.removeAllSeries()
        setupCurrentSeries()
        lastPulseOnPlotTm = -1;
        currentStepAxisX = chartView.plotAxisX
        currentStepAxisX.max = 0
        lastStepEventTm = 0;
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
        //timerUpdate(0, Math.round(heartRate.hr))
    }

    function init(){
        resetShow()
        currentSession = currentSessionOrig
        additionalXLabels         = []
        stepXLabels               = []
        sessionDuration           =  0
        lastPressEventNb          = -1
        currentStepEventEnum      = -1
        currentStepEventStartTm   = -1
        currentStepEventStopTm    = -1
        lastStepEventToShowNb     = -1
        currentSession.when = Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss");
        lastPressEventNb = -1;
        //runSessionScene.stepsAr = runSessionScene.stepsArOrig
        currentStepEventEnum  = -1;
        maxStepsOnPlot        = 1000;
        firstStepEventToPlotNb   = -1;
        currentChartView.title = currentSession.sessionName + " " + currentSession.when
    }

    //creates new series graph
    function setupCurrentSeries(){
        //currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "0", currentStepAxisX, currentAxisY);
        //currentHrSeries.color = runColors[currentGauge.gaugeName]
        currentContractionSeries = currentChartView.createSeries(ChartView.SeriesTypeScatter, "contraction", currentEventAxisX, currentAxisY);
        currentStepHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "0", currentStepAxisX, currentAxisY)
        currentStepHrSeries.width = dp(5)
        currentDiscomfortSeries    = currentChartView.createSeries(ChartView.SeriesTypeLine, "0", currentStepAxisX, discomfortAxisY)
        currentDiscomfortSeries.color = "darkred"
        currentDiscomfortSeries.width = dp(5)
        currentDiscomfortSeries.axisYRight = discomfortAxisY;
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
    function makeLabel(tm){
        return (tm - lastStepEventTm).toString() + "/" + (tm + demoModePulseTm).toString()
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

    function plotSetupSession(sessionName, selectedSession){
        //console.log("**** In setupSession width ", sessionName, ":", selectedSession)
        var step;
        init()
        sessionDuration = 0
        for (step in selectedSession){
            sessionDuration += selectedSession[step].time;
        }
        currentSession.sessionName = sessionName
    }
    Dialog {
        id:saveStepsDialog
        signal saveStepsSignal(int stNb)
        title: "Save Steps"
        property int backStepNb: 0
        standardButtons: StandardButton.Ok
        modality: Qt.ApplicationModal
        Tumbler {
            id: steps
//            style: TumblerStyle {
//                id: tumblerStyle
//                delegate: Item {
//                    implicitHeight: (tumbler.height - padding.top - padding.bottom) / tumblerStyle.visibleItemCount

//                    Text {
//                        id: label
//                        text: styleData.value
//                        color: styleData.current ? "#52E16D" : "#808285"
//                        font.bold: true
//                        opacity: 0.4 + Math.max(0, 1 - Math.abs(styleData.displacement)) * 0.6
//                        anchors.centerIn: parent
//                    }
//                }
//            }
            TumblerColumn{
               id: col100
               model: 10
            }
            TumblerColumn{
                id: col10
                model: 10
            }
            TumblerColumn{
                id:col1
                model: 10
            }
               anchors.horizontalCenter: parent.horizontalCenter

        }
        onAccepted: {
            saveStepsDialog.saveStepsSignal.connect(runSessionScene.updateBackSteps)
            saveStepsSignal(100 * col100.currentIndex + 10 * col10.currentIndex + col1.currentIndex)
        }
        //Component.onCompleted: visible = true
    }
    function saveSteps(){
        saveStepsDialog.open()
    }

    Dialog {
        id:saveSessionDialog
        title: "Save Session?"
        //icon: StandardIcon.Question
        modality: Qt.NonModal
        property alias sessionNm: sessionNm.text
        standardButtons: StandardButton.Yes  | StandardButton.No
        Text{
            id: sessionNm
            text: ""
            font.bold: true
        }
        //Component.onCompleted: visible = true
        //onYes: console.log("saving session")
        //onNo: console.log("didn't save")
        //onRejected: console.log("aborted")
    }
    function saveSession() {
        var path=qfa.getAccessiblePath("sessions");
        console.log("Path = ", path);
        var fileName = currentSession.sessionName + "-" + currentSession.when + ".json";
        saveSessionDialog.sessionNm = fileName
        saveSessionDialog.open()
        if (saveSessionDialog.clickedButton !== StandardButton.Yes) {

            //open will add path before fileName
            console.log("fileName=", fileName, "Open=" , qfa.open(path + fileName));
            var sessionString = JSON.stringify(currentSession);
            console.log("Wrote = ", qfa.write(sessionString));
            //var qstr = qfa.read();
            //console.log("read = ", qstr);
            qfa.close();
            //var data = runSessionScene.currentSessionhttps://community.wd.com/t/automatic-backup/147334/5
            //io.text = JSON.stringify(data, null, 4)
            //io.write()

        }
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
        rangeSliderUpdate()

    }
    function rangeSliderUpdate(){
        plotRangeControl.from = 0;
        plotRangeControl.to = currentSession.pulse.length
        // fixing range slider handle position to the max range for the first time
        // or to prevent stocking all the values in the end
        // first time is recognized by the second.value === 0)
        var oldFirstValue = plotRangeControl.first.value
        var oldSecondValue = plotRangeControl.second.value
        if ((oldFirstValue <= 0) || (oldFirstValue > plotRangeControl.to)) {
            plotRangeControl.first.value = plotRangeControl.from
        }
        if ((oldSecondValue <= 0) || (oldSecondValue > plotRangeControl.to)) {
            plotRangeControl.second.value = plotRangeControl.to
        }
        //        console.log(" second.value = ", plotRangeControl.to, "plotRangeControl.second.visualPosition = ", plotRangeControl.second.visualPosition)
        plotRangeControl.first.visualPositionChanged()
        plotRangeControl.second.visualPositionChanged()
        currentChartView.update()
        //        console.log(" second.value = ", plotRangeControl.to, "plotRangeControl.second.visualPosition = ", plotRangeControl.second.visualPosition)
    }

    function saveStepXLabels(){
        // save currentStepAxisX labels
        stepXLabels = []
        var tmStart = 0
        var tmStop  = 0
        var eventNb
        var eventName
        var lbl
        for (eventNb = 0; eventNb < currentSession.event.length; eventNb++){
            eventName = myEventsEnum2Nm[currentSession.event[eventNb][0]]
            // for step events only
            if (! (runColors[eventName] === undefined)){
                tmStart = tmStop
                tmStop = currentSession.event[eventNb][1]
                //run.nextStepName is used in onSeriesAdded
                // TODO: consolidate and make SeaWolfPlot self sofficient?
                // TODO review why +1 is needed !
                lbl = (tmStop - tmStart + 1).toString() + "/" + (tmStop + 1 + demoModePulseTm).toString()
                stepXLabels.push(lbl)
            }
        }
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
        var backEventCnt = 0
        currentAxisY.min = (hrMin - 1);
        currentAxisY.max = (hrMax + 1);

        //TODO does it make sence to synchronyze with ending steps in SeaWolfControls ? Mutex?
        // Is some sort of race condition is possible here?
        // May be call markEvent from here instead of from the gauges state change?
        console.log("In showSessionGraph: p_session.event.length", p_session.event.length)
        run.nextStepName = "brth"
        lastStepEventTm=0

        for (eventNb = 0; eventNb < p_session.event.length; eventNb++){
            eventName = myEventsEnum2Nm[p_session.event[eventNb][0]]
            // for step events only
            if (! (runColors[eventName] === undefined)){
                tmStart = tmStop
                tmStop = p_session.event[eventNb][1]
                //run.nextStepName is used in onSeriesAdded
                // TODO: consolidate and make SeaWolfPlot self sofficient?
                run.nextStepName = myEventsEnum2Nm[p_session.event[eventNb][0]]
                //markEvent(myEventsEnum2Nm[p_session.event[eventNb][0]], tmStop)
                currentStepHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, tmStop.toString(), currentStepAxisX, currentAxisY)
                for (var tm = tmStart; tm <= tmStop; tm ++){
                    //TODO review why + 1 is needed, change here and in addPoint to plot?
                    addPointToHrPlot(tm + 1, p_session.pulse[tm])
                    currentDiscomfortSeries.append(tm, p_session.discomfort[tm])
                }
                lastStepEventTm = tmStop
                if (eventName == "back"){
                    //show the number of steps
                    if (!(undefined === p_session.event[eventNb][2])){
                        runSessionScene.stepsAr[backEventCnt] = p_session.event[eventNb][2]
                        backEventCnt++
                    }
                }
            }else{
                var tmEvent = p_session.event[eventNb][1] + 1

                currentContractionSeries.append(tmEvent, p_session.pulse[tmEvent])
                var lastEventXLabel = makeLabel(tmEvent) //(tm + demoModePulseTm).toString()
                currentEventAxisX.append(lastEventXLabel, tmEvent)

            }

        }
        saveStepXLabels()
        rangeSliderUpdate()
        updateAdditionalXLabels()
        currentChartView.title = p_session.sessionName + " " + p_session.when
        chartView.update()

    }

    function markEvent(eventName, tm){
        canCreateSeriesFlag = false
        var eventEnum = myEventsNm2Enum[eventName];
        currentSession.event.push([eventEnum, tm])
        var eventNb = currentSession.event.length - 1
        var pulse = currentSession.pulse[currentSession.event[eventNb][1]]
        if ("back" === eventName){
            lastBackEvebtNb = eventNb
            lastBackStepNb  += 1
        }
        //console.log("*** markEvent Enter: time = ", tm, "eventName = ", eventName, "lastStepEventNm = ", lastStepEventNm, "eventNb = ", currentSession.event.length -1 )
        if (! (runColors[eventName] === undefined)){
            lastStepEventTm = tm
            lastStepEventNm = eventName
            // the rest of the setup will be done during onSeriesAdded signal processing
            currentStepHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, lastStepEventTm.toString(), currentStepAxisX, currentAxisY)
            //adding the last point from the previous series as a first point of the new series
            // TODO review why +1 is needed !
            addPointToHrPlot(lastStepEventTm +1, pulse )
            //console.log("added tm = ", lastStepEventTm, " pulse = ", pulse)
            //currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentStepAxisX, currentAxisY);
        }else{
            if (eventName === "contraction"){
                currentContractionSeries.append(tm + 1, pulse)
                var lastEventXLabel = makeLabel(tm + 1) //(tm + demoModePulseTm).toString()
                currentEventAxisX.append(lastEventXLabel, tm + 1)
            }
        }

        //console.log("*** markEvent Exit: time = ", tm, "eventName = ", eventName, "lastStepEventNm = ", lastStepEventNm, "eventNb = ", currentSession.event.length -1 )
    }
    function timerUpdate(tm, hrValue){
        hrPlot.addPointToHrPlot(tm, hrValue)
        // update discomfort information
        var disValue = hrPlot.discomfortValue
        hrPlot.currentSession.discomfort.push(disValue)
        hrPlot.currentDiscomfortSeries.append(tm, disValue)

    }
    function addPointToHrPlot(tm, y){
        currentStepHrSeries.append(tm,y)
        hrPlot.rangeSliderUpdate()
        currentAxisY.min = getSesssionHRMin(currentSession) - 5
        currentAxisY.max = getSesssionHRMax(currentSession) + 5
        // currentStepAxisX.min and max are set by the range slider
        //testing that the last X label was't end of step label

        //console.log( " In addPointToHrPlot: tm = ", tm,  "lastStepEventTm = ", lastStepEventTm,
        //            "currentStepAxisX.min =", currentStepAxisX.min, "currentStepAxisX.max = ", currentStepAxisX.max)
        if ( (tm - 1 ) !== lastStepEventTm ){
            currentStepAxisX.remove(lastStepXLabel)
            //console.log("removing [", lastStepXLabel, "] tm = ", tm)
        }else{
            stepXLabels.push(lastStepXLabel)
            //currentStepAxisX.append(lastStepXLabel, tm-1)
            //console.log("adding to stepXLabels[", lastStepXLabel, "]")
        }

        lastStepXLabel = makeLabel(tm) //(tm + demoModePulseTm).toString()
        currentStepAxisX.append(lastStepXLabel, tm)
        //console.log("adding [", lastStepXLabel, "]")

        //update if series creation is finished
        if (canCreateSeriesFlag){
            //console.log("tm = ", tm, "lastStepXLabel = ", lastStepXLabel, "currentStepAxisX.min =", currentStepAxisX.min, "currentStepAxisX.max =", currentStepAxisX.max)
            //updateAdditionalXLabels()
            currentChartView.update()
            //console.log("Plot Updated")
        }
    }


    ChartView {
        id:chartView
        title: currentSession.sessionName + " " + currentSession.when
        anchors.fill: parent
        margins{top:dp(60); bottom:dp(60); left:dp(40); right:(dp(60))}
        //to make visible part of the graph taking bigger part
        //anchors.topMargin: dp(-20)
        antialiasing: true
        theme: ChartView.ChartThemeBlueIcy
        legend.visible: false
        property CategoryAxis plotAxisX: plotAxisX
        property CategoryAxis eventAxisX: eventAxisX

        //Series is created we can work with it now
        onSeriesAdded:{
            //console.log ("in onSeriesAdded lastStepEventNm:", lastStepEventNm, "lastStepEventTm = ", lastStepEventTm, "pulse = ", currentSession.pulse[lastStepEventTm -1],
            //             "myEventsNm2Enum[lastStepEventNm]", myEventsNm2Enum[lastStepEventNm])
            series.color = runColors[run.nextStepName]
            series.width = dp(5)
            //console.log ("in onSeriesAdded series.color:", series.color)
            //addPointToHrPlot(lastStepEventTm, currentSession.pulse[lastStepEventTm - 1])
            //currentStepHrSeries.append(lastStepEventTm, currentSession.pulse[lastStepEventTm - 1])
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
            //labelFormat: "%8c"
            //count: 0
            gridLineColor:labelsColor

        }
        CategoryAxis {
            id: eventAxisX
            startValue:0
            min: 0
            max: sessionDuration
            labelsAngle: -90
            labelsPosition: CategoryAxis.AxisLabelsPositionOnValue
            labelsColor: "#FF7F50"
            labelsFont:lblsFnt
            //labelFormat: "%8c"
            //count: 0
            gridLineColor: labelsColor
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
            gridVisible: false
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
            axisYRight:discomfortAxisY
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
            markerSize: dp(8)
            axisXTop: eventAxisX
            axisY:plotAxisY
            //            XYPoint { x: 25;  y: 25 }
            //            XYPoint { x: 50; y: 50 }
        }
        Component.onCompleted:{
            console.log("In SeaWolfPlotComponent.onCompleted")
            currentChartView  = chartView
            //currentStepAxisX  = plotAxisX
            currentAxisY      = plotAxisY
            //currentEventAxisX = eventAxisX
            //currentEventAxisX.labelsPosition = CategoryAxis.AxisLabelsPositionOnValue
            currentDiscomfortSeries  = discomfortSeries
            currentContractionSeries = contractionSeries
        }
        MultiPointTouchArea {
            property real initialFirstVisualPosition
            property real initialLeftTouchX
            property real initialSecondVisualPosition
            property real initialRightTouchX
            property real initialScale
            property real initialTouchX0
            property real initialTouchXMax
            property real currentLeftTouchX
            property real currentRightTouchX
            anchors.fill: parent
            minimumTouchPoints: 1
            maximumTouchPoints: 2
            touchPoints: [
                TouchPoint { id: touch1 },
                TouchPoint { id: touch2 }
            ]
            function getPressedNumber(tp1, tp2){
                var count = 0
                if (tp1.pressed){
                    count++;
                }
                if (tp2.pressed){
                    count++
                }
                //console.log("pressedNumber = ", count)
                return count
            }

            onPressed:{
                //console.log("*** On Pressed touch numbet = ", touchPoints.length)
                if(getPressedNumber(touch1, touch2) < 2){
                    initialScale = (plotRangeControl.second.visualPosition - plotRangeControl.first.visualPosition)/parent.width
                    //minimumTouchPoints = 1
                    //maximumTouchPoints = 1
                }else{
                    //minimumTouchPoints = 2
                    //maximumTouchPoints = 2
                    initialLeftTouchX           = Math.min(touch1.x, touch2.x)
                    initialRightTouchX          = Math.max(touch1.x, touch2.x)
                    initialScale                = (plotRangeControl.second.visualPosition - plotRangeControl.first.visualPosition) /
                            (initialRightTouchX - initialLeftTouchX )
                    initialTouchX0              = initialLeftTouchX - initialFirstVisualPosition/initialScale
                    initialTouchXMax            = initialRightTouchX  + ( 1 - initialSecondVisualPosition)/initialScale
                }
                initialFirstVisualPosition  = plotRangeControl.first.visualPosition
                initialSecondVisualPosition = plotRangeControl.second.visualPosition
                console.log("***In onPressed:", initialFirstVisualPosition, initialSecondVisualPosition, initialLeftTouchX, initialRightTouchX,
                            initialScale, initialTouchX0, initialTouchXMax)
            }
            onUpdated:{
                var plotFirstVisual
                var plotSecondVisual
                //console.log("*** On Update touch number = ", touchPoints.length)
                if(getPressedNumber(touch1, touch2) < 2){
                    var visPosChange  = (touchPoints[0].x - touchPoints[0].previousX) * initialScale
                    initialFirstVisualPosition   = initialFirstVisualPosition - visPosChange
                    initialSecondVisualPosition  = initialSecondVisualPosition - visPosChange
                }else{
                    currentLeftTouchX           = Math.min(touch1.x, touch2.x)
                    currentRightTouchX          = Math.max(touch1.x, touch2.x)
                    initialFirstVisualPosition  = ( -currentLeftTouchX + initialLeftTouchX) * initialScale
                    initialSecondVisualPosition = initialSecondVisualPosition + (-currentRightTouchX + initialRightTouchX) * initialScale
                }
                //console.log("***In onUpdated:", visPosChange, plotFirstVisual, plotSecondVisual, currentLeftTouchX, currentRightTouchX,
                //            initialScale)
                plotRangeControl.first.value    = Math.round(plotRangeControl.from +  (plotRangeControl.to -  plotRangeControl.from )  * initialFirstVisualPosition)
                plotRangeControl.second.value   = Math.round(plotRangeControl.from +  (plotRangeControl.to -  plotRangeControl.from )  * initialSecondVisualPosition)

            }
            onReleased:{
                minimumTouchPoints = 1
                maximumTouchPoints = 2
            }
        }
    }

    RangeSlider{
        id: plotRangeControl
        anchors.left:   chartView.left
        anchors.right:  chartView.right
        anchors.bottom: chartView.bottom
        anchors.leftMargin: chartView.margins.left
        anchors.rightMargin: chartView.margins.right
        from: 0
        to:   0 //undefined === currentSession.pulse.length? 50 : currentSession.pulse.length
        stepSize: 1
        property bool needAdditionalXLabels:false
        //first.value: 10
        //second.value: 50
        first.onValueChanged:  {
            currentStepAxisX.min  = first.value;
            currentEventAxisX.min = first.value
            needAdditionalXLabels = true;
            //console.log("In first needAdditionalXLabels = ", needAdditionalXLabels)
        }
        second.onValueChanged: {
            currentStepAxisX.max  = second.value;
            currentEventAxisX.max = second.value
            needAdditionalXLabels = true;
            //console.log("In second needAdditionalXLabels = ", needAdditionalXLabels)
        }
        //For some reason the visual position change requires a manual value setup. A bug or wrong usage?
        first.onVisualPositionChanged:  { var v1 = Math.round(from +  (to -  from )  * first.visualPosition);  first.value =  v1;
            changeRay()
            //                             console.log(" In rangeSlider: first.from, to, value, visualPosition = " , from, to, first.value, first.visualPosition)
        }
        second.onVisualPositionChanged: { var v1 = Math.round(from + (to - from ) * second.visualPosition); second.value = v1;
            //                             console.log(" In rangeSlider: second.from, to, value, visualPoition = " , from, to, second.value, second.visualPosition)
            changeRay()
        }
        onNeedAdditionalXLabelsChanged: {
            if (needAdditionalXLabels){
                //console.log ("*** needAdditionalXLabels");
                needAdditionalXLabels = false
                updateAdditionalXLabels();
            }
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
        //anchors.bottom: chartView.bottom
        anchors.margins: {
            //left:   Math.max(2 * chartView.margins.top, (4 * plotRangeControl.second.handle.height))
            right:  discomfortSliderHandle.width/2;
            //top:    2 * plotRangeControl.second.handle.height
            //bottom: 2 * plotRangeControl.second.handle.height
            //right: 100//Math.max(2 * chartView.margins.bottom, (4 * plotRangeControl.second.handle.height))
            //bottom:    discomfortSliderHandle.width
        }
        value: 0.0
        from:0
        to:10
        //stepSize: 0.1
        implicitWidth: dp(40)
        implicitHeight: chartView.height - 3 *plotRangeControl.second.handle.height
        orientation:Qt.Vertical
        onPositionChanged:  { var v1 = from +  (to -  from )  * position;  value =  v1; discomfortValue = v1;
            //console.log(" In discomfortSlider: from, to, value, position = " , from, to, value, position)
        }
        onPressedChanged: {
            if(pressed){
                if (timer.running) {
                    timer.stop()
                }
                timer.start()
            } else {
                timer.stop()
                console.log("timer.elapsed = ", timer.elapsed)
                if (timer.elapsed < 400){
                    run.triggerPressEventMark = "contraction"
                }
            }
        }
        QMLElapsedTimer {
            id: timer
        }
        background:Rectangle {
            height: parent.height
            width: parent.width
            //color: "#21be2b"
            opacity:1.0
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
                text: qsTr("Slide -> Discomfort Level, Click -> Contraction")
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.HorizontalFit
                minimumPixelSize: parent.width -2*anchors.margins;
                //font.pixelSize: dp(72)
                font.bold: true
                rotation: -90
                horizontalAlignment: Text.AlignHCenter
                //anchors.verticalCenter: parent.verticalCenter
            }
            //            MouseArea {
            //                id: mouseArea
            ////                drag.target:discomfortSliderHandle
            ////                drag.axis: Drag.YAxis
            //                anchors.fill: parent
            //                hoverEnabled: true
            //                onClicked: markEvent("contraction", run.sessionTime)
            //            }
        }

        handle: Rectangle {
            id:discomfortSliderHandle
            Image {
                source: "../../assets/img/bubble.png"
                anchors.centerIn: parent
                width:parent.width
                height:parent.height
            }

            y: discomfortSlider.bottomPadding + discomfortSlider.visualPosition * (discomfortSlider.availableHeight - height)
            x: discomfortSlider.leftPadding + discomfortSlider.availableWidth / 2 - width / 2
            implicitWidth: dp(120)
            implicitHeight: dp(120)
            radius: dp(60)
            opacity: discomfortSlider.pressed ? 0.6 : 0.8
            //color: "orange"
            border.color: "#bdbebf"
        }
    }
    function changeRay() {
        var posOfChartView = chartView.mapToItem(null, chartView.x, chartView.y)
        var posOfPlotArea = chartView.mapToItem(null, chartView.plotArea.x, chartView.plotArea.y)
        var posOfPlotAreaInDetailSliderStart = detailSlider.mapFromItem(null, posOfPlotArea.x, posOfPlotArea.y)
        var posOfPlotAreaIndetailSliderStop  = detailSlider.mapFromItem(null, posOfPlotArea.x + chartView.plotArea.width, chartView.plotArea.y)
        detailSliderRay.y = posOfPlotAreaInDetailSliderStart.y
        detailSliderRay.height = Math.abs(chartView.plotArea.height) //- chartView.margins.top
        //        console.log("X=", chartView.x, posOfChartView.x, posOfPlotArea.x, posOfChartViewInDetailSlider.x, posOfPlotAreaIndetailSlider.x,
        //                    "Y=", chartView.y, posOfChartView.y, posOfPlotArea.y, posOfChartViewInDetailSlider.y, posOfPlotAreaIndetailSlider.y)

        var vPlotX = (posOfPlotAreaIndetailSliderStop.x - posOfPlotAreaInDetailSliderStart.x)  / (detailSlider.to - detailSlider.from) *
                (detailSlider.value - detailSlider.from) + posOfPlotAreaInDetailSliderStart.x
        detailSliderRay.x =  vPlotX
    }

    Slider {
        id: detailSlider
        anchors.left:   chartView.left
        anchors.right:  chartView.right
        anchors.top: chartView.top
        //anchors.bottom: chartView.bottom
        anchors.margins: {
            left: chartView.margins.left
            right: chartView.margins.right
            //left:   Math.max(2 * chartView.margins.top, (4 * plotRangeControl.second.handle.height))
            //right:  detailSliderHandle.width/2;
            //top:    2 * plotRangeControl.second.handle.height
            //bottom: 2 * plotRangeControl.second.handle.height
            //right: 100//Math.max(2 * chartView.margins.bottom, (4 * plotRangeControl.second.handle.height))
            //bottom:    detailSliderHandle.width
        }
        value: 0
        from:currentStepAxisX.min
        to:currentStepAxisX.max
        stepSize: 1
        implicitHeight: dp(40)
        implicitWidth: chartView.width// - 3 *plotRangeControl.second.handle.height
        orientation:Qt.Horizontal
        onPositionChanged:  { var v1 = from +  (to -  from )  * position;  value =  v1;
            //console.log(" In detailSlider: from, to, value, position = " , from, to, value, position)
        }
        background:Rectangle {
            height: parent.height
            width: parent.width
            //color: "#21be2b"
            opacity:1.0
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
                text: qsTr("Slide -> show details, Click -> TODO")
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.HorizontalFit
                minimumPixelSize: parent.width -2*anchors.margins;
                //font.pixelSize: dp(72)
                font.bold: true
                rotation: 0
                horizontalAlignment: Text.AlignHCenter
                //anchors.verticalCenter: parent.verticalCenter
            }
        }
        onValueChanged: changeRay()

        handle: Rectangle {
            Image {
                source: "../../assets/img/bubble.png"
                anchors.centerIn: parent
                width:parent.width
                height:parent.height
            }
            id:detailSliderHandle
            x: detailSlider.leftPadding + detailSlider.visualPosition * (detailSlider.availableWidth - width)
            y: detailSlider.topPadding + detailSlider.availableHeight / 2 - height / 2
            implicitWidth: dp(120)
            implicitHeight: dp(120)
            radius: dp(60)
            opacity: detailSlider.pressed ? 0.6 : 0.8
            //color: "orange"
            //border.color: "#bdbebf"
            Text{
                Layout.alignment: Qt.AlignCenter
                //topPadding: 0
                //bottomPadding: 0
                anchors.fill: parent
                //anchors.horizontalCenter: parent.horizontalCenter
                //anchors.margins: dp(2)
                color:"black"
                text: {var tm = Math.round(detailSlider.value);
                    var txt = (tm - getCurrentStepStartTm(tm)).toString() +
                            "/" + (tm + demoModePulseTm).toString() + "\n" +
                            currentSession.pulse[Math.round(detailSlider.value)].toString() + "\n" +
                            Math.round(currentSession.discomfort[Math.round(detailSlider.value)]).toString();
                    return txt
                }
                //verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
                minimumPixelSize: parent.height/4;
                //font.pixelSize: dp(72)
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                rotation: 0
                horizontalAlignment: Text.AlignHCenter
                //anchors.verticalCenter: parent.verticalCenter
            }
        }
        Rectangle{
            id:detailSliderRay
            x:0
            y: 0
            implicitWidth: dp(6)
            implicitHeight: chartView.height
            radius: dp(2)
            color: "white"
            border.width: 1
            border.color: "black"

        }
    }
    Row{
        visible: true //gaugeWalk.maximumValue !== 0
        id: stepsIds
        Layout.preferredWidth: runSessionScene.width
        Layout.preferredHeight: SeaWolfInput.height
        Text{
            id: stepsIdsText
            text: runSessionScene.getStepIdsText()
            font.pixelSize: dp(40)
        }
    }
    Component.onCompleted: {
        //var point = detailSlider.mapFromItem(null, chartView.plotArea.x, chartView.plotArea.y)
        var point = detailSlider.mapToItem(chartView, 0.0, 0.0)
        //var myPoint = mapFromItem(null, point.x, point.y)
        console.log("point = ", point.x, point.y)
        detailSliderRay.y = point.y
        detailSliderRay.height = Math.abs(point.y)
    }

} //End Of Plot

