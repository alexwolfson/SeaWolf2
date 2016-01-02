import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtMultimedia 5.0
import VPlay 2.0

CircularGauge {
    id: gauge
    property real valueChange: 0
    value: 0
    anchors.verticalCenter: parent.verticalCenter
    property string gaugeName: "brth"
    property GridView gridView
    property ListModel gaugeModel: gridView.model
    property CircularGauge nextGauge
    //property var gaugeModelElement: gaugeModel.get(modelIndex)
    property bool isCurrent: false
    property real minAngle: -45
    property real maxAngle:  45
    property color needleColor: runColors[gaugeName]
    property int modelIndex:0
    property int maximumValue:  gaugeModel.get(modelIndex).time
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
        needle: Rectangle {
            id: gaugeNeedle
            property color needleColor: color
            y: outerRadius * 0.15
            implicitWidth: outerRadius * 0.03
            implicitHeight: outerRadius * 0.9
            antialiasing: true
            color: gauge.needleColor
        }
        tickmark: Rectangle {
            implicitWidth: toPixels(0.06)
            antialiasing: true
            implicitHeight: toPixels(0.06)
            color: gauge.needleColor
            border.color: "black"
        }
        minorTickmark: Rectangle{
            implicitWidth: toPixels(0.03)
            antialiasing: true
            implicitHeight: toPixels(0.08)
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
    SoundEffectVPlay {
            id: breathsnd
            volume: 1.0
            source: "../../assets/sounds/breathe.wav"
    }
    SoundEffectVPlay {
            id: holdsnd
            volume: 1.0
            source: "../../assets/sounds/hold.wav"
    }
    SoundEffectVPlay {
            id: walksnd
            volume: 1.0
            source: "../../assets//walk.wav"
    }
    SoundEffectVPlay {
            id: thirtysnd
            volume: 1.0
            source: "../../assets/sounds/30sec.wav"
    }
    SoundEffectVPlay {
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

    transitions:[
        Transition {
            from: "*"
            to: "stateRun"
            // SpringAnimation { spring: 2; damping: 0.2; modulus: 360 }
            NumberAnimation{
                target: gauge
                property: "value"
                duration: (maximumValue - gauge.value) * 1000
            }
            onRunningChanged: {
                // the step is over - go to the next step
                if (running){
                    thirtyTimer.interval= maximumValue * 1000 - 30000
                    if (thirtyTimer.interval > 0){
                        thirtyTimer.start()
                    }
                    tenTimer.interval = maximumValue * 1000 - 10000
                    if (tenTimer.interval > 0){
                        tenTimer.start()
                    }
                    if (gauge.gaugeName == "brth"){
                        gaugeModel.get(modelIndex).maximumValue = gaugeModel.get(modelIndex).time
                        gaugeModel.get(modelIndex+1).maximumValue = gaugeModel.get(modelIndex+1).time
                        gaugeModel.get(modelIndex+2).maximumValue = gaugeModel.get(modelIndex+2).time

                       breathsnd.play()

                    } else if (gauge.gaugeName == "hold"){
                        holdsnd.play()
                        //gridView.delegate.border.color = "white"
                    }  else if (gauge.gaugeName == "walk"){
                        //gaugeWalkControl.enabled = true
                        walksnd.play()
                    }
                }

                if ((!running) /*&& (gaugeModelElement.typeName === gaugeName)*/) {
                    console.log("running=", running, "modelIndex=", modelIndex)
                    state = "initial";
                    gaugeModel.get(modelIndex).isCurrent = false
                    if (nextGauge.modelIndex < (gaugeModel.count -1)){
                        nextGauge.modelIndex = modelIndex + 1
                        gaugeModel.get(nextGauge.modelIndex).isCurrent = true
                        //seting up next gauge as current
                        nextGauge.state = "stateRun"
                    }
                }
                // we are here as part of the transaction to running, so in case of next serie
                // we change all times!
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
