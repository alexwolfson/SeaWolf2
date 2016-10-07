//import VPlay 2.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

import "../common"

SceneBase {
    id: hrmSetupScene
    signal startHrmDemo()
    signal startHrmSearch()
    Item {
        id: screen
        width: parent.width
        height: parent.height
        anchors.fill: parent
        //anchors.topMargin:tabHeaderHight
        anchors.horizontalCenter: parent.horizontalCenter;

        //       ColumnLayout {
        //           id: screen
        //color: "#F0EBED"
        //            anchors.fill: parent
        //            anchors.horizontalCenter: parent.horizontalCenter;
        property string message: heartRate.message
        onMessageChanged: {
            if (heartRate.message != "Scanning for devices..." && heartRate.message != "Low Energy device found. Scanning for more...") {
                background.visible = true;
                //demoMode.visible = true;
            }
            else {
                //demoMode.visible = false;
                background.visible = true;
            }
        }
        ColumnLayout{

            id: hrmColumn
            Layout.fillHeight: true
            Layout.fillWidth:  true
            width: parent.width
            Rectangle {
                id:select
                width: parent.width - 2 * anchors.margins
                anchors{top: parent.top;left: parent.left;
                    right: parent.right; margins: dp(15)}
                height: dp(80)
                color: "#F0EBED"
                border.color: "#3870BA"
                border.width: dp(2)
                radius: dp(10)

                Text {
                    id: infotext
                    anchors.left: parent.left
                    anchors.top: parent.top
                    text: heartRate.message
                    color: "#8F8F8F"
                }
                Rectangle {
                    id: spinner
                    width: dp(100)
                    anchors.top: select.top
                    anchors.margins:  dp(15)
                    //anchors.bottomMargin: dp(15)
                    anchors.right: select.right
                    //anchors.bottom: demoMode.top
                    visible: false
                    color: "#F0EBED"
                    z: 100

                    Rectangle {
                        id: inside
                        anchors.centerIn: parent
                        Image {
                            id: background

                            width:dp(70)
                            height:dp(70)
                            anchors.horizontalCenter: parent.horizontalCenter

                            source: "../../assets/img/busy_dark.png"
                            fillMode: Image.PreserveAspectFit
                            NumberAnimation on rotation { duration: 3000; from:0; to: 360; loops: Animation.Infinite}
                        }

                    }
                }

            }

            Rectangle{
                id: hrmListView
                width:parent.width
                height: parent.height/2

                ListView {
                id: theListView
                width: parent.width
                onModelChanged: spinner.visible=false
                //anchors.fill: parent
                //anchors.top: select.bottom
                //anchors.bottom: demoMode.top
                model: heartRate.name

                delegate: Rectangle {
                    id: box
                    height:dp(140)
                    width: parent.width
                    color: "#3870BA"
                    border.color: "#F0EBED"
                    border.width: dp(5)
                    radius: dp(15)

                    MouseArea {
                        anchors.fill: parent
                        onPressed: { box.color= "#3265A7"; box.height=dp(110)}
                        onClicked: {
                            heartRate.connectToService(modelData.deviceAddress)
                            runSessionPressed()
                            //pageLoader.source="qrc:/qml/common/monitor.qml";
                        }
                    }

                    Text {
                        id: device
                        font.pixelSize: dp(20)
                        text: modelData.deviceName
                        anchors.top: parent.top
                        anchors.topMargin: dp(5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#F0EBED"
                    }

                    Text {
                        id: deviceAddress
                        font.pixelSize: dp(20)
                        text: modelData.deviceAddress
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: dp(5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#F0EBED"
                    }
                }
            }
            }

            RowLayout{
                id: hrmButtons
                MenuButton {
                    id:scanAgain
                    //z:100
                    //buttonWidth: parent.width /2 -10
                    //buttonHeight: 0.1*parent.height
                    //anchors.left: parent.left
                    //anchors.bottom: parent.bottom
                    text: "Scan Again"
                    visible:true
                    //onButtonClick: backButtonPressed()
                    onClicked: {
                        heartRate.disconnectService()
                        console.log("Started new BT device search")
                        heartRate.deviceSearch();
                        spinner.visible=true;
                        startHrmSearch()
                    }
                }
                MenuButton {
                    //z:100
                    id:startDemo
                    //buttonWidth: parent.width /2 - 10
                    //buttonHeight: 0.1*parent.height
                    //anchors.right: parent.right
                    //anchors.bottom: parent.bottom
                    text: "Demo Mode"
                    visible:true
                    //onButtonClick: backButtonPressed()
                    onClicked: {
                        heartRate.startDemo()
                        startHrmDemo()
                    }
                }
            }
        }
    }
}
