import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Controls.Styles 1.4

Item {
    id: input
    width: dp(720)
    height: dp(60)
    property alias lbl: lbl.text
    property string type: "str" //"str","int","switch", spinBox
    property string res
    property alias  ifv:   intField.text
    property alias  sfv:   strField.text
    property alias  swYesNo: swtch.checked
    property alias  sbv:   spinBox.value
    property alias  sbfrom: spinBox.from
    property alias  sbto: spinBox.to
    property alias  sbstep: spinBox.stepSize
    signal result()
    Label {
        id:lbl
        width: dp(360)
        text: "Label"
    }
    TextField {
        id:intField
        enabled: type=="int"
        visible: type=="int"
        anchors.left:lbl.right
        anchors.leftMargin: dp(20)
        placeholderText: "0"
        text: "12"
        validator: IntValidator{}
        horizontalAlignment: TextInput.AlignHCenter
        //style: TextFieldStyle {
            color: "black"
            background: Rectangle {
                radius: dp(20)
                color: "#F0EBEB"
                implicitWidth: dp(120)
                implicitHeight: dp(60)
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
                implicitWidth: dp(240)
                implicitHeight: dp(60)
                border.color: "#000000"
                border.width: dp(1)
            }
        //}
        onEditingFinished: {res=text; result()}
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
    }
    SpinBox{
        id: spinBox
        anchors.left:lbl.right
        anchors.leftMargin: dp(10)
        enabled: type=="spinBox"
        visible: type=="spinBox"
        width: dp(240)
        height: dp(60)
//        up.indicator: Rectangle{
//            id:up
//            Text: { text : " > " }
//            anchors.right: parent.right
//            height: parent.height
//            //onClicked: parent.value += stepSize
//        }
//        down.indicator: Rectangle{
//            id:down
//            Text: {text : " < " }
//            anchors.left: parent.left
//            height: parent.height
//            //onClicked: parent.value -= stepSize
//        }

//        background: Rectangle {
//            radius: dp(20)
//            color: "#F0EBEB"
//            implicitWidth: dp(240)
//            implicitHeight: dp(60)
//            border.color: "#000000"
//            border.width: dp(1)
//        }

        onValueChanged: {res=value; result()}

    }

}

