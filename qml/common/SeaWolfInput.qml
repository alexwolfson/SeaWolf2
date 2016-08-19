import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id: input
    width: dp(720)
    height: dp(60)
    property alias lbl: lbl.text
    property string type: "str" //"str","int","switch"
    property string res
    property alias  ift: intField.text
    property alias  sft: strField.text
    property alias  swYesNo: swtch.checked
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
        style: TextFieldStyle {
            textColor: "black"
            background: Rectangle {
                radius: dp(20)
                color: "#F0EBEB"
                implicitWidth: dp(120)
                implicitHeight: dp(60)
                border.color: "#000000"
                border.width: dp(1)
            }
        }
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
        style: TextFieldStyle {
            textColor: "black"
            background: Rectangle {
                radius: dp(20)
                color: "#F0EBEB"
                implicitWidth: dp(240)
                implicitHeight: dp(60)
                border.color: "#000000"
                border.width: dp(1)
            }
        }
        onEditingFinished: {res=text; result()}
    }
    Switch {
        id:swtch
        anchors.left:lbl.right
        anchors.leftMargin: dp(10)
        enabled: type=="switch"
        visible: type=="switch"
        onCheckedChanged: {swYesNo=checked; result()}
    }

}

