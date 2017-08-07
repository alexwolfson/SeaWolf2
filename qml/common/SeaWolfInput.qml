import QtQuick 2.7
import QtQuick.Controls 2.0
//import QtQuick.Controls.Styles 1.4

Item {
    id: input
    width: parent.width //dp(720)
    height: dp(60)
    property alias lbl: lbl.text
    property string type: "str" //"str","int","switch", spinBox
    property string res
    property int    intRes
    property alias  ifv:   intField.text
    property alias  sfv:   strField.text
    property alias  swYesNo: swtch.checked
    property alias  sbv:   spinBox.value
    property alias  sbfrom: spinBox.from
    property alias  sbto: spinBox.to
    property alias  sbstep: spinBox.stepSize
//    property real  sbv:   spinBox.value
//    property real  sbfrom: spinBox.from
//    property real  sbto: spinBox.to
//    property real  sbstep: spinBox.stepSize
    signal result()
    Label {
        id:lbl
        verticalAlignment: Text.AlignVCenter
        width: parent.width/2
        height: parent.height
        text: "Label"
    }
    TextField {
        id:intField
        width: parent.width/2 - 2 * anchors.leftMargin//dp(300)
        enabled: type=="int"
        visible: type=="int"
        anchors.left:lbl.right
        anchors.leftMargin: dp(20)
        placeholderText: "0"
        text: "12"
        validator: IntValidator{}
        horizontalAlignment: TextInput.AlignHCenter
        inputMethodHints: Qt.ImhDigitsOnly
        implicitWidth: parent.width/2
        //style: TextFieldStyle {
        color: "black"
        background: Rectangle {
            radius: dp(20)
            color: "#F0EBEB"
            //implicitWidth: dp(120)
            //implicitHeight: dp(60)
            border.color: "#000000"
            border.width: dp(1)
        }
        //}
        //onEditingFinished: {res=text; result()}
        onTextChanged: {res=text; result()}
        //        Binding{
        //            target:textFieldInt
        //            property:"text"
        //            value:lbl.text
        //        }
    }

    TextField {
        id:strField
        width: parent.width/2 - 2 * anchors.leftMargin//dp(300)
        enabled: type=="str"
        visible: type=="str"
        anchors.left:lbl.right
        anchors.leftMargin: dp(20)
        placeholderText: ""
        text: ""
        //validator: IntValidator{}
        horizontalAlignment: TextInput.AlignHCenter
        //style: TextFieldStyle {
        color: "black"
        background: Rectangle {
            radius: dp(20)
            color: "#F0EBEB"
            //implicitWidth: dp(400)
            implicitHeight: dp(60)
            border.color: "#000000"
            border.width: dp(1)
        }
        //}
        //onEditingFinished: {res=text; result()}
       onTextChanged: {res=text; result()}
    }
    Switch {
        id:swtch
        anchors.left:lbl.right
        anchors.leftMargin: dp(10)
        enabled: type=="switch"
        visible: type=="switch"
        implicitWidth: dp(240)
        implicitHeight: dp(60)
        onCheckedChanged: {swYesNo=checked; result()}
        background: Rectangle {
            radius: dp(20)
            color: "#F0EBEB"
            border.color: "#000000"
            border.width: dp(1)
        }
        Component.onCompleted: result()
    }
    SpinBox{
        id: spinBox
        anchors.left:lbl.right
        anchors.leftMargin: dp(10)
        enabled: type=="spinBox"
        visible: type=="spinBox"
        width: parent.width/4 //dp(240)
        height: dp(60)
        from: 0  //sbfrom
        to:   10 //sbto
        value: 5 //sbv
        stepSize: 1 //sbstep
        background: Rectangle {
            radius: dp(20)
            color: "#F0EBEB"
            //implicitWidth: dp(240)
            implicitHeight: dp(60)
            border.color: "#000000"
            border.width: dp(1)
        }
        up.indicator: Rectangle{
            id:up
            Text { text : ">"; anchors.centerIn: parent }
            anchors.right: parent.right
            height: parent.height
            width: parent.height * 1.25
            radius: dp(20)
            color: "white"
            border.color: "#000000"
            border.width: dp(1)
            //onClicked: parent.value += stepSize
        }
        down.indicator: Rectangle{
            id:down
            Text {text : "<"; anchors.centerIn: parent }
            anchors.left: parent.left
            height: parent.height
            width: parent.height * 1.25
            radius: dp(20)
            color: "white"
            border.color: "#000000"
            border.width: dp(1)
            //onClicked: parent.value -= stepSize
        }
        onValueChanged: { intRes=value; result()}
    }
    Slider{
        id: slider
        anchors.left:spinBox.right
        anchors.leftMargin: dp(10)
        enabled: type=="spinBox"
        visible: type=="spinBox"
        width: parent.width/4 - 2 * anchors.leftMargin//dp(300)
        height: dp(60)
        from: sbfrom
        to:   sbto
        stepSize: sbstep
        value:    sbv
        //snapMode: Slider.SnapAlways
        background: Rectangle {
            id: bkgd
            radius: dp(20)
            color: "#F0EBEB"
            //implicitWidth: dp(240)
            implicitHeight: dp(60)
            border.color: "#000000"
            border.width: dp(1)
        }
        //For some reason the visual position requires a manual snap, even when snapMode is set
        onVisualPositionChanged: { var v1 = Math.round(from + (to - from ) * visualPosition); sbv = v1 -v1 % stepSize;
            /*console.log("sbv = ", Math.round(from + (to - from ) * visualPosition))*/
        }
        //onValueChanged: {sbv = value; intRes=value; result()}
    }
}

