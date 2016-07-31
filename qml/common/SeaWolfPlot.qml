import QtQuick 2.7
//import QtQuick.Controls 1.4
//import QtQuick.Controls.Styles 1.4
//import QtQuick.Dialogs 1.2
//import QtQuick.Extras 1.4
//import QtQuick.Layouts 1.2
//import QtMultimedia 5.6
//import QtQml 2.2
import QtCharts 2.1
Rectangle{
    id:hrPlot
    property var currentSession: {
        "sessionName":"TestSession",
                "when":"ChangeMe", //Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss"),
                "eventNames":myEventsNm2Nb,
                "event":[],
                "pulse":[]
    }
    property var myEventsNm2Nb:{"EndOfMeditativeZone":0, "EndOfComfortZone":1, "Contraction":2, "EndOfWalk":3, "brth":4 , "hold":5, "walk":6, "back":7}
    property LineSeries currentHrSeries
    property ChartView  currentChartView
    property ValueAxis  currentAxisX
    property ValueAxis  currentAxisY
    property real minHr:10
    property real maxHr:150
    property real sessionDuration:0.0
    //creates new series graph
    function setupCurrentHrSeries(){
        currentHrSeries = currentChartView.createSeries(ChartView.SeriesTypeLine, "", currentAxisX, currentAxisY);
        currentHrSeries.color = runColors[currentGauge.gaugeName]
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
    function saveSession() {
        var path=qfa.getAccessiblePath("sessions");
        console.log("Path = ", path);
        var fileName = currentSession.sessionName + "-" + currentSession.when;
        //qmlOpenFile will add path before fileName
        console.log("fileName=", fileName, "Open=" , qfa.qmlOpenFile(path + fileName));
        console.log("Wrote = ", qfa.qmlWrite(JSON.stringify(runSessionScene.currentSession)));
        //var qstr = qfa.qmlRead();
        //console.log("Read = ", qstr);
        qfa.qmlCloseFile();
        //var data = runSessionScene.currentSession
        //io.text = JSON.stringify(data, null, 4)
        //io.write()
    }

    function restoreSession(filePath) {
        console.log("filePath = ", filePath, "Open=" , qfa.qmlOpenFile(filePath));
        //console.log("Wrote = ", qfa.qmlWrite(JSON.stringify(runSessionScene.currentSession)));
        var qstr = qfa.qmlRead();
        console.log("Read = ", qstr);
        currentSession = JSON.parse(qstr);
        console.log("Close=", qfa.qmlCloseFile());
        showSessionGraph(currentSession,chartView)

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
//        var currentIndex = 0;
//        var evt;
//        p_chartView.removeAllSeries();
//        var evtStartTime = 0;
//        for (var i = 0; i < p_session.event.length; i++){
//            evt = p_session.event[i]
//            var evtName = myEventsNb2Nm[evt[0]]
//            //only use events like brth, hold, walk, back
//            if (!(runColors[evtName] === undefined)){
//                //console.log("step = ", evtName, "step duration = ", evt[1])
//                currentHrSeries = p_chartView.createSeries(ChartView.SeriesTypeLine, "", p_chartView.axisX, p_chartView.axisY);
//                //p_chartView.chart().setAxisX(axisX, currentHrSeries);
//                currentHrSeries.color = runColors[evtName]
//                for (var j = 0; j < evt[1]; j++){
//                    currentHrSeries.append( currentHrSeries.pulse[j])
//                    //AWDEBUG
//                    //currentHrSeries.append(Math.round(50 + j))
//                    p_chartView.update()

//                }
//                evtStartTime += evt[1]
//            }
//        }
        p_chartView.update()
    }

    width:parent.width // + dp(50)
    height: parent.height/3
    anchors.horizontalCenter: parent.horizontalCenter
    //anchors.top: runSessionScene.top
    //anchors.topMargin: sessionView.cellWidth * 3
    opacity:1.0
    z:50
    ChartView {
        id:chartView
        //                margins.bottom:dp(0)
        //                margins.left:  dp(0)
        //                margins.right: dp(0)
        //                margins.top:   dp(0)

        title: currentSession.sessionName + " " + currentSession.when
        anchors.fill: parent
        //to make visible part of the graph taking bigger part
        anchors.topMargin: dp(-30)
        antialiasing: true
        theme: ChartView.ChartThemeBlueIcy
        //legend:{visible: false}
        ValueAxis {
            id: axisX
            labelFormat:"%.0f"
            //labelsFont: Qt.font({pixelSize : sp(10)})
            min: 0
            max: sessionDuration
            tickCount: 7
        }
        ValueAxis {
            id: axisY
            labelFormat:"%.0f"
            //labelsFont: Qt.font({pixelSize : sp(10)})
            min: minHr
            max: maxHr
            tickCount:6

        }

        LineSeries {
            id: hrSeries
            name: "Heart Rate"
            opacity: 1
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

