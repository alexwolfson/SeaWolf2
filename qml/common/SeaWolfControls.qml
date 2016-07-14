import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtMultimedia 5.6
import QtQuick.Dialogs 1.2
//import VPlay 2.0
import QtQuick.Particles 2.0
import QtCharts 2.1
import com.seawolf.qmlfileaccess 1.0
CircularGauge {
    id: gauge
    property real valueChange: 0
    value: 0
    anchors.verticalCenter: parent.verticalCenter
    property string gaugeName: "brth"
    property  SoundEffect enterStateSndEffect
    //property GridView gridView
    property ListModel gaugeModel //: runSessionScene.runSessionModel
    property CircularGauge nextGauge
    //property var gaugeModelElement: gaugeModel.get(modelIndex)
    property bool isCurrent: false
    property real minAngle: -45
    property real maxAngle:  45
    property color needleColor: runColors[gaugeName]
    property int modelIndex:0
    //Is set, whhen RunSessionScene is loaded
    property int typesDim
    //:runSessionScene.runGauge.length
    minimumValue: 0
    maximumValue: gaugeModel.get(0).time

    function startVoiceTimers(){
        thirtyTimer.interval= maximumValue * 1000 - 30000
        if (thirtyTimer.interval > 0){
            thirtyTimer.start()
        }
        tenTimer.interval = maximumValue * 1000 - 10000
        if (tenTimer.interval > 0){
            tenTimer.start()
        }
    }
    function stopVoiceTimers(){
            thirtyTimer.stop()
            tenTimer.stop()
    }

    function saveSession() {
        var path=qfa.getAccessiblePath("sessions");
        console.log("Path = ", path);
        var fileName = runSessionScene.currentSession.sessionName + runSessionScene.currentSession.when;
        //qmlOpenFile will add path before fileName
        console.log("fileName=", fileName, "Open=" , qfa.qmlOpenFile(path + fileName));
        console.log("Wrote = ", qfa.qmlWrite(JSON.stringify(runSessionScene.currentSession)));
        var qstr = qfa.qmlRead();
        console.log("Read = ", qstr);
        console.log("Close=", qfa.qmlCloseFile());
        //var data = runSessionScene.currentSession
        //io.text = JSON.stringify(data, null, 4)
        //io.write()
    }


    onModelIndexChanged:{
        if (gaugeModel != null ){
            maximumValue = gaugeModel.get(modelIndex).time
        }
    }
    style: CircularGaugeStyle {
        id: gaugeStyle
        minimumValueAngle: gauge.minAngle
        maximumValueAngle: gauge.maxAngle
        labelStepSize: ((maximumValue - minimumValue) /8 + 0.5).toFixed()
        tickmarkStepSize: labelStepSize
        minorTickmarkCount: 1
        function toPixels(percentage) {
            return percentage * outerRadius;
        }
//        needle: Rectangle {
//            id: gaugeNeedle
//            property color needleColor: color
//            y: outerRadius * 0.15
//            implicitWidth: outerRadius * 0.03
//            implicitHeight: outerRadius * 0.9
//            antialiasing: true
//            color: gauge.needleColor
//        }
//        needle: Canvas {
//            implicitWidth: needleBaseWidth
//            implicitHeight: needleLength

//            property real xCenter: width / 2
//            property real yCenter: height / 2

//            onPaint: {
//                var ctx = getContext("2d");
//                ctx.reset();

//                ctx.beginPath();
//                ctx.moveTo(xCenter, height);
//                ctx.lineTo(xCenter - needleBaseWidth / 2, height - needleBaseWidth / 2);
//                ctx.lineTo(xCenter - needleTipWidth / 2, 0);
//                ctx.lineTo(xCenter, yCenter - needleLength);
//                ctx.lineTo(xCenter, 0);
//                ctx.closePath();
//                ctx.fillStyle = Qt.rgba(0.66, 0, 0, 0.66);
//                ctx.fill();

//                ctx.beginPath();
//                ctx.moveTo(xCenter, height)
//                ctx.lineTo(width, height - needleBaseWidth / 2);
//                ctx.lineTo(xCenter + needleTipWidth / 2, 0);
//                ctx.lineTo(xCenter, 0);
//                ctx.closePath();
//                ctx.fillStyle = Qt.lighter(Qt.rgba(0.66, 0, 0, 0.66));
//                ctx.fill();
//            }
//        }
        foreground: Item {
            Image {
                id:heartImage
                property real pulseFactor: 1.0
                source:"../../assets/img/blue_heart.png"
                //source: "images/knob.png"
                anchors.centerIn: parent
                scale: {
                    var idealHeight = __protectedScope.toPixels(0.5);
                    var originalImageHeight = sourceSize.height;
                    idealHeight / originalImageHeight * pulseFactor;
                }
                SequentialAnimation on pulseFactor{
                    loops: Animation.Infinite
                    running: heartRate.hr > 0;
                    NumberAnimation{
                        duration: heartRate.hr/60*1500;
                        //easing.type: Easing.OutExpo;
                        from:0.9; to: 1.1;
                    }
                    //                    NumberAnimation {
                    //                        duration: heartRate.hr/60*1500;
                    //                        easing.type: Easing.OutExpo;
                    //                        from:1.1; to: 0.9;
                    //                    }
                }
                ParticleSystem {
                    id: systwo
                    anchors.fill: parent

                    ImageParticle {
                        system: systwo
                        id: cptwo
                        source: "../../assets/img/star.png"
                        colorVariation: 0.4
                        color: "#000000FF"
                    }

                    Emitter {
                        //burst on click
                        id: burstytwo
                        system: systwo
                        enabled: true
                        anchors.centerIn: parent
                        emitRate: heartRate.hr*100
                        maximumEmitted: 4000
                        acceleration: AngleDirection {angleVariation: 360; magnitude: 360; }
                        size: 4
                        endSize: 8
                        sizeVariation: 4
                    }


                }


            }
        }

        tickmark: Rectangle {
            implicitWidth: outerRadius * 0.06
            antialiasing: true
            implicitHeight: outerRadius * 0.06
            color: gauge.needleColor
            border.color: "black"
        }
        minorTickmark: Rectangle{
            implicitWidth: outerRadius * 0.03
            antialiasing: true
            implicitHeight: outerRadius * 0.08
            color: gauge.needleColor
            border.color: "black"
        }
        tickmarkLabel: Text {
            color: "white"
            text: styleData.value
            style: Text.Outline
            styleColor: gauge.needleColor
        }
    }
    SoundEffect {
        id: thirtysnd
        volume: 1.0
        source: "../../assets/sounds/30sec.wav"
    }
    SoundEffect {
        id: tensnd
        volume: 1.0
        source: "../../assets/sounds/10sec.wav"
    }
    states:[
        State {
            name: "stateRun"
            //when: isCurrent
            PropertyChanges {
                target: gauge
                value: maximumValue
                isCurrent: true
            }
        },
        State {
            name: "initial"
            //when: !isCurrent
            PropertyChanges {
                target: gauge
                value: 0
                isCurrent: false
            }
        }
    ]
    Timer{
        id: thirtyTimer
        interval:30000
        onTriggered:{
            //when timer expired set it to 20 sec to play 10 sec left
            thirtysnd.play()
        }
    }
    Timer{
        id: tenTimer
        interval:20000
        onTriggered:{
            tensnd.play()
        }
    }
    // It means that the next one is "brth"
    function isLastInCycle(){
        if (nextGauge.modelIndex % typesDim ===  0)
            return true
        else
            return false
    }
    //trick to pass by reference
    function loadNextCycleVal(gauge){
        console.log("gaugeModel.count=", gaugeModel.count, "gauge[0].modelIndex",gauge[0].modelIndex)
        if ((gauge[0].modelIndex + typesDim < gaugeModel.count))
        {
            gauge[0].modelIndex += typesDim;
            //gauge[0].maximumValue = gaugeModel.get(gauge[0].modelIndex).time

        }
    }
    function loadIfNot0(gauge, ind){
        //if (gauge[0] !== 0){
        gauge[0].modelIndex = ind
        //gauge[0].maximumValue = gaugeModel.get(gauge[0].modelIndex).time
        //}
    }

    function sessionIsOver(nextGauge){
        loadIfNot0([nextGauge], 0)
        loadIfNot0([nextGauge.nextGauge], 1)
        //if we have 2 gauges only (no "walk") we need to prevent updating "hold" twice
        if (nextGauge.nextGauge !== gauge){
            loadIfNot0([nextGauge.nextGauge.nextGauge], 2)
            loadIfNot0([nextGauge.nextGauge.nextGauge.nextGauge], 3)
            //make walk gauge visible
            nextGauge.nextGauge.nextGauge.nextGauge.visible=false
            nextGauge.nextGauge.nextGauge.visible=true
        }
    }
    transitions:[
        Transition {
            from: "*"
            to: "stateRun"
            // SpringAnimation { spring: 2; damping: 0.2; modulus: 360 }
            NumberAnimation{
                target: gauge
                property: "value"
                duration: Math.abs(target.maximumValue) * 1000
                from:0
                to: target.maximumValue
            }
            //onStarted: {
            // the step is over - go to the next step
            onRunningChanged: {
                if (running){
                    // Add start event with it's duration
                    //if (!gaugeName in ["walk", "back"] ){
                        var eventNb = runSessionScene.myEventsNm2Nb[gaugeName];
                        console.log("gaugeName=", gaugeName, "eventNb=", eventNb)
                        runSessionScene.currentSession.event.push([eventNb, maximumValue])
                    //}
                    runSessionScene.setupCurrentHrSeries()
                    startVoiceTimers()
                    enterStateSndEffect.play()
                }
                //onStopped:{
                if ((!running) /*&& (gaugeModelElement.typeName === gaugeName)*/) {
                    //console.log("running=", running, "modelIndex=", modelIndex, "index=", gridView.delegate.index)
                    state = "initial";
                    gaugeModel.get(modelIndex).isCurrent = false
                    // update all gauges if we are about to run the "breath"gauge
                    var bContinue = true
                    if (isLastInCycle()){
                        loadNextCycleVal([gauge])
                        var prevNextModelIndex = nextGauge.modelIndex
                        console.log("prevNextModelIndex=", prevNextModelIndex)
                        loadNextCycleVal([nextGauge])
                        console.log("******nextGauge.modelIndex=", nextGauge.modelIndex)
                        if (prevNextModelIndex === nextGauge.modelIndex)
                            bContinue = false
                        //if we have 2 gauges only (no "walk" we need to prevent updating "hold" twice
                        var n1 = String(nextGauge.nextGauge.gaugeName)
                        var n2 = String(gauge.gaugeName)
                        console.log("localCompare=", n1.localeCompare(n2))
                        if (0 !== n1.localeCompare(n2)){
                            loadNextCycleVal([nextGauge.nextGauge])
                            loadNextCycleVal([nextGauge.nextGauge.nextGauge])
                         }
                    }
                    console.log("bContinue=", bContinue)
                    //var nextActiveGauge = nextGauge.maximumValue != 0 ? nextGauge : nextGauge.nextGauge
                    if ((nextGauge.modelIndex < gaugeModel.count) && bContinue){
                        //nextGauge.modelIndex = modelIndex + 1
                        //skip the next gauge if it has 0 maximum value
                        gaugeModel.get(nextGauge.modelIndex).isCurrent = true
                        if (("hold" == runSessionScene.currentGauge.gaugeName) && ("walk" == nextGauge.gaugeName) ){
                            runSessionScene.enableWalkControl()
                        }
                        if ("walk" == runSessionScene.currentGauge.gaugeName){
                            runSessionScene.currentGauge.visible = false
                            runSessionScene.gauge[backIndx].visible = true
                        }
                        if ("back" == runSessionScene.currentGauge.gaugeName){
                            runSessionScene.currentGauge.visible = false
                            runSessionScene.gauge[walkIndx].visible = true
                        }

                        //emit signala
                        runSessionScene.currentGauge = nextGauge
                        //seting up next gauge as current if it's time is not 0
                        nextGauge.state = "stateRun"
                    }
                    else {
                        // The session is over
                        sessionIsOver(nextGauge)
                        // show the session results

                        //save the session results
                        //openDialog.open()
                        saveSession()
                        heartRate.disconnectService();
                        oneTimer.stop()
                        sessionTime = 0.0;
                        //pageLoader.source = "results.qml";


                    }
                    // we are here as part of the transaction to running, so in case of next serie
                    // we change all times!
                }
            }

        },
        Transition {
            from: "*"
            to: "initial"
            NumberAnimation{
                target: gauge
                property: "value"
                duration: 1000
            }
        }
    ]
    //Behavior on value { NumberAnimation { duration: gauge.valueChange * 1000 } }
    //style: IntervalGaugeStyle {}
}
