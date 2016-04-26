import VPlay 2.0
import QtQuick 2.0
import "../common"

SceneBase {
    id: hrmSetupScene


    // back button to leave scene
    MenuButton {
        z:100
        text: "Back"
        // anchor the button to the gameWindowAnchorItem to be on the edge of the screen on any device
        anchors.right: hrmSetupScene.gameWindowAnchorItem.right
        anchors.rightMargin: dp(10)
        anchors.top: hrmSetupScene.gameWindowAnchorItem.top
        anchors.topMargin: dp(10)
        onClicked: backButtonPressed()
    }

    Item {
        id: container
        Image {
            id: bkgImg
            source: "../../assets/img/surface.png"
            fillMode: Image.PreserveAspectCrop
            opacity: 0.4
            anchors.fill: parent
        }
        width: parent.width
        height: parent.height
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter;

        Rectangle {
            id: screen
            color: "#F0EBED"
            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter;
            property string message: heartRate.message
            onMessageChanged: {
                if (heartRate.message != "Scanning for devices..." && heartRate.message != "Low Energy device found. Scanning for more...") {
                    background.visible = false;
                    //demoMode.visible = true;
                }
                else {
                    //demoMode.visible = false;
                    background.visible = true;
                }
            }

            Rectangle {
                id:select
                width: parent.width
                anchors.top: parent.top
                height: dp(80)
                color: "#F0EBED"
                border.color: "#3870BA"
                border.width: 2
                radius: dp(10)

                Text {
                    id: selectText
                    color: "#3870BA"
                    font.pixelSize: dp(34)
                    anchors.centerIn: parent
                    text: "Select Device"
                }
            }

            Rectangle {
                id: spinner
                width: parent.width
                anchors.top: select.bottom
                //anchors.bottom: demoMode.top
                visible: false
                color: "#F0EBED"
                z: 100

                Rectangle {
                    id: inside
                    anchors.centerIn: parent
                    Image {
                        id: background

                        width:dp(100)
                        height:dp(100)
                        anchors.horizontalCenter: parent.horizontalCenter

                        source: "../../assets/img/busy_dark.png"
                        fillMode: Image.PreserveAspectFit
                        NumberAnimation on rotation { duration: 3000; from:0; to: 360; loops: Animation.Infinite}
                    }

                    Text {
                        id: infotext
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: background.bottom
                        text: heartRate.message
                        color: "#8F8F8F"
                    }
                }
            }

            Component.onCompleted: {
                heartRate.disconnectService()
                console.log("Started new BT device search")
                heartRate.deviceSearch();
                spinner.visible=true;
            }

            ListView {
                id: theListView
                width: parent.width
                onModelChanged: spinner.visible=false
                anchors.top: select.bottom
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
                        onPressed: { box.color= "#3265A7"; box.height=110}
                        onClicked: {
                            heartRate.connectToService(modelData.deviceAddress)
                            runSessionPressed()
                            //pageLoader.source="qrc:/qml/common/monitor.qml";
                        }
                    }

                    Text {
                        id: device
                        font.pixelSize: sp(30)
                        text: modelData.deviceName
                        anchors.top: parent.top
                        anchors.topMargin: dp(5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#F0EBED"
                    }

                    Text {
                        id: deviceAddress
                        font.pixelSize: sp(30)
                        text: modelData.deviceAddress
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: dp(5)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#F0EBED"
                    }
                }
            }

            Button {
                id:scanAgain
                buttonWidth: parent.width
                buttonHeight: 0.1*parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                text: "Scan Again"
                //onButtonClick: backButtonPressed()
                onButtonClick: {
                    heartRate.disconnectService()
                    console.log("Started new BT device search")
                    heartRate.deviceSearch();
                    spinner.visible=true;
                }
            }
        }
    }
}
