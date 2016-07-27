//#import VPlay 2.0
import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1

import "./scenes"
import "./common"

ApplicationWindow {
    id:root
    //AW: Duplication vs SceneBase - need to fix
    property real default_pix_density: 4  //pixel density of my current screen
    property real scale_factor: {
        var sfDen   = Screen.pixelDensity/default_pix_density
        var sfWidth = Screen.width / 720
        var sfHeight  = Screen.height / 1280
        return Math.min(/*sfDen, */sfWidth, sfHeight)
    }
    property int firstTime:1
    function dp(pix){
        if (firstTime){
            console.log("Screen.pixelDensity = ", Screen.pixelDensity, "scale_factor = ", scale_factor)
            firstTime = 0
        }
        return pix * scale_factor
    }
    //Is set, whhen RunSessionScene is loaded
    property int typesDim
    visible:true
    //for some reason dp(1920) created binding loop and dependence of NONNotifiable factor
    height: Screen.height
    width: Math.min(Screen.width, Screen.height*9/16)
    TabView {
        id: tabView
        anchors.fill: parent
        anchors.margins: 4
//        property Tab about
//        property Tab config
//        property Tab hrm
//        property Tab run
//        property Tab finish
        Component.onCompleted:  {
            conf.sessionSelected.connect(run.setupSession)
//            config = addTab("Config Ser", Qt.createComponent("qrc:/qml/scenes/ConfigSeriesScene.qml"))
//            config.visible = true
//            run = addTab("Run", Qt.createComponent("qrc:/qml/scenes/RunSessionScene.qml"))
//            run.visible = true
//            hrm = addTab("HRM", Qt.createComponent("qrc:/qml/scenes/HrmSetupScene.qml"))
//            hrm.visible = true
//            // About the app scene
//            about = addTab("About", Qt.createComponent("qrc:/qml/scenes/AboutScene.qml"))
//            about.visible = true
        }
        style: TabViewStyle {
            frameOverlap: dp(0)
            tab: Rectangle {
                color: styleData.selected ? "steelblue" :"lightsteelblue"
                border.color:  "steelblue"
                border.width: dp(4)
                implicitWidth: Math.max(text.width + dp(20), dp(100))
                implicitHeight: dp(80)
                radius: dp(4)
                Text {
                    id: text
                    anchors.centerIn: parent
                    text: styleData.title
                    color: styleData.selected ? "white" : "black"
                }
            }
            frame:     Image {
                //z:90
                id: bkgImg
                source: "../../assets/img/surface.png"
                fillMode: Image.PreserveAspectCrop
                opacity: 0.4
                anchors.fill: parent
            }

        }

        ConfigSeriesScene{ id:conf; title: qsTr("Conf")}
        RunSessionScene{ id:run;    title: qsTr("Run")}
        HrmSetupScene{  id:hrm;     title: qsTr("HRM")}
        AboutScene{  id:about;      title: qsTr("About")}
        Tab {
            id:finish;
            title: qsTr("Finish");
            Item {
                id: quit
                MenuButton{
                    id:quitButton
                    width:parent.width/3
                    height: parent.height/3
                    border.width: dp(4)
                    border.color: "black"
                    text: qsTr("Quit")
                    anchors.centerIn: parent
                    onClicked: {Qt.quit()}
                }
            }
        }
    }
//    TabView {
//          id: frame
//          anchors.fill: parent
//          anchors.margins: 4
//          property Tab about
//          property Tab config
//          property Tab hrm
//          property Tab run

//        //width: dp(1080)
//        //height: dp(1920)
//        property variant jsonTest
//        property var currentSession
//       // property ListModel currentModel: currentModel

//        // You get free licenseKeys from http://v-play.net/licenseKey
//        // With a licenseKey you can:
//        //  * Publish your games & apps for the app stores
//        //  * Remove the V-Play Splash Screen or set a custom one (available with the Pro Licenses)
//        //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
//        //licenseKey: "<generate one from http://v-play.net/licenseKey>"

//        // create and remove entities at runtime
//    //     EntityManager {
//    //        id: entityManager
//    //    }
//        // menu scenecurrentModel.get(view.currentIndex - view.currentIndex % typesDim + pr.type).ti
//        Component.onCompleted:  {
//            // About the app scene
//            about = addTab("About", Qt.createComponent("qrc:/qml/scenes/AboutScene.qml"))
//            about.visible = true
//            //config = addTab("Config Ser", Qt.createComponent("qrc:/qml/scenes/ConfigSeriesScene.qml"))
//            //config.visible = true
//            hrm = addTab("HRM", Qt.createComponent("qrc:/qml/scenes/HrmSetupScene.qml"))
//            hrm.visible = true
////        // Configure Series scene
////        ConfigSeriesScene {
////            id: configSeriesScene
////            title:"Config Ser"
////            //onBackButtonPressed: window.state = "menu"
////        }
////        // Running Session Scene
////    //    RunSessionScene {
////    //        id: runSessionScene
////    //        onSessionSelected: setupSession(sessionName, selectedSession)
////    //        onNotifyFooter: updateFooter(currentIndex)
////    //        onBackButtonPressed: window.state = "menu"
////    //    }
////        // scene for selecting levels
//        }


//    // menuScene is our first scene, so set the state to menu initially
//    state: "about"
//    //activeFocusItem: menuScene

//    // state machine, takes care reversing the PropertyChanges when changing the state, like changing the opacity back to 0
//    states: [
//        State {
//            name: "menu"
//            PropertyChanges {target: menuScene; opacity: 1; focus:true}
//            //PropertyChanges {target: window; activeFocusItem: menuScene}
//        },
//        State {
//            name: "about"
//            PropertyChanges {target: aboutScene; focus: true}
//            //PropertyChanges {target: window; activeFocusItem: aboutScene; focus:true}
//        },
//        State {
//            name: "runSession"
//            PropertyChanges {target: runSessionScene; opacity: 1; focus:true}
//            //PropertyChanges {target: window; activeFocusItem: runSessionScene}
//        },
//        State {
//            name: "configSeries"
//            PropertyChanges {target: configSeriesScene; opacity: 1; focus:true}
//            //PropertyChanges {target: window; activeFocusItem: configSeriesScene}
//        },
//        State {
//            name: "hrmSetup"
//            PropertyChanges {target: hrmSetupScene; opacity: 1; focus:true}
//            //PropertyChanges {target: window; activeFocusItem: hrmSetupScene}
//        }
//    ]
    Loader {
        id: pageLoader
        anchors.fill: parent
    }
}


