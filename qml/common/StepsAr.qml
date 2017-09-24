import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
//import Qt.labs.platform 1.0
import QtQuick.Extras 1.4

Item {
    id:stepsArId
    property var stepsArOrig:[0,0,0,0]
    property var stepsAr:stepsArOrig
    property int stepsArInd: 0
    property alias stepsIdsText:stepsIdsText.text

    function getStepIdsText(){
        return "<pre>" +
                "Distance in steps 1:<b>" + stepsAr[0] +
                            "  </b>2:<b>" + stepsAr[1] +
                            "  </b>3:<b>" + stepsAr[2] +
                            "  </b>4:<b>" + stepsAr[3] +
                "</pre>";
    }
    function updateBackSteps(stNb){
        stepsAr[stepsArInd] = stNb
        stepsArInd++
        stepsIdsText.text = getStepIdsText()
    }
    function init(){
        stepsAr = stepsArOrig
        stepsArInd = 0
        stepsIdsText.text = getStepIdsText()

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
            updateBackSteps(100 * col100.currentIndex + 10 * col10.currentIndex + col1.currentIndex)
        }
        Component.onCompleted:{
            //saveeStepsDialog.saveStepsSignal.connect(updateBackSteps)
            //visible = true
        }
    }
    function saveSteps(){
        saveStepsDialog.open()
    }

    //property string stepNbText: "StepsNb"
    Text{
        id: stepsIdsText
        text: getStepIdsText()
        font.pixelSize: dp(40)
    }

}
