import QtQuick 2.7
import QtQuick.Layouts 1.3

Item {
    id: walkStepsCounter
    property var stepsAr:[0,0,0,0]
    Row {
        //z:100
        id: mainLayout
        //columns: 2
        //spacing: dp(30)
        //columnSpacing: 5
//        anchors {
//            top: parent.top;
//            left: parent.left
//            right: parent.right
//            leftMargin: dp(20)
//            topMargin: dp(20)
//        }
        SeaWolfInput{ id: walkSteps1; type:"int";   lbl: qsTr("Stps1:"); onResult: {stepsAr[0]=intRes}}
        SeaWolfInput{ id: walkSteps2; type:"int";   lbl: qsTr("Stps2:"); onResult: {stepsAr[1]=intRes}}
        SeaWolfInput{ id: walkSteps3; type:"int";   lbl: qsTr("Stps3:"); onResult: {stepsAr[2]=intRes}}
        SeaWolfInput{ id: walkSteps4; type:"int";   lbl: qsTr("Stps4:"); onResult: {stepsAr[3]=intRes}}
    }
}
