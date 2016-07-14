//#import VPlay 2.0
import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "./scenes"
import "./common"

Window {
    id:window
    //AW: Duplication vs SceneBase - need to fix
    property real default_pix_density: 4  //pixel density of my current screen
    property real scale_factor: Screen.pixelDensity/default_pix_density
    function dp(pix){
        //console.log("Screen.pixelDensity = ", Screen.pixelDensity)
        return pix * scale_factor
    }
    visible:true
    width: dp(500)
    //for some reason dp(1920) created binding loop and dependence of NONNotifiable factor
    height: 900 *scale_factor

    TabView {
        id: tabView
        anchors.fill: parent
        anchors.margins: 4
        AboutScene{   title: "About"}
        HrmSetupScene{ title: "HRM"}
        RunSessionScene{ title: "Run"}
        Tab { title: "Finish"
            onLoaded: Qt.quit()
        }
        visible:true
        style: TabViewStyle {
            frameOverlap: 1
            tab: Rectangle {
                color: styleData.selected ? "steelblue" :"lightsteelblue"
                border.color:  "steelblue"
                implicitWidth: Math.max(text.width + dp(4), dp(80))
                implicitHeight: dp(30)
                radius: dp(2)
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
//       // property ListModel currentModel: apneaModel

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
//        // menu sceneapneaModel.get(view.currentIndex - view.currentIndex % typesDim + pr.type).ti
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


