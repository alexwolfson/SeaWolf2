import VPlay 2.0
import QtQuick 2.0
import "scenes"
import "common"

GameWindow {
    id: window
    width: dp(1080)
    height: dp(1920)
    property variant jsonTest
    property var currentSession
   // property ListModel currentModel: apneaModel

    // You get free licenseKeys from http://v-play.net/licenseKey
    // With a licenseKey you can:
    //  * Publish your games & apps for the app stores
    //  * Remove the V-Play Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)
    //licenseKey: "<generate one from http://v-play.net/licenseKey>"

    // create and remove entities at runtime
    EntityManager {
        id: entityManager
    }

    // menu sceneapneaModel.get(view.currentIndex - view.currentIndex % 3 + pr.type).ti
    MenuScene {
        id: menuScene
        // listen to the button signals of the scene and change the state according to it
        onAboutPressed: window.state = "about"
        onConfigSeriesPressed: window.state = "configSeries"
        onRunSessionPressed: window.state = "runSession"
        onHrmSetupPressed: window.state = "hrmSetup"
        onCreditsPressed: window.state = "credits"
        //onSessionCreated: configSeriesScene.generateCO2Session()
        // the menu scene is our start scene, so if back is pressed there we ask the user if he wants to quit the application
        onBackButtonPressed: {
            nativeUtils.displayMessageBox(qsTr("Really quit the training?"), "", 2);
        }
        // listen to the return value of the MessageBox
        Connections {
            target: nativeUtils
            onMessageBoxFinished: {
                // only quit, if the activeScene is menuScene - the messageBox might also get opened from other scenes in your code
                if(accepted && window.activeScene === menuScene)
                    Qt.quit()
            }
        }
    }

    // About the app scene
    AboutScene {
        id: aboutScene
        onBackButtonPressed: window.state = "menu"
    }
    // Configure Series scene
    ConfigSeriesScene {
        id: configSeriesScene
        onBackButtonPressed: window.state = "menu"
    }
    // Running Session Scene
    RunSessionScene {
        id: runSessionScene
        onSessionSelected: setupSession(sessionName, selectedSession)
        onNotifyFooter: updateFooter(currentIndex)
        onBackButtonPressed: window.state = "menu"
    }
    // scene for selecting levels
    HrmSetupScene {
        id: hrmSetupScene
//        onHrmSetupPressed: {
//            gameScene.setLevel(selectedLevel)
//            window.state = "hrmSetup"

//        }
        onBackButtonPressed: window.state = "menu"
    }

    // menuScene is our first scene, so set the state to menu initially
    state: "menu"
    activeScene: menuScene

    // state machine, takes care reversing the PropertyChanges when changing the state, like changing the opacity back to 0
    states: [
        State {
            name: "menu"
            PropertyChanges {target: menuScene; opacity: 1}
            PropertyChanges {target: window; activeScene: menuScene}
        },
        State {
            name: "about"
            PropertyChanges {target: aboutScene; opacity: 1}
            PropertyChanges {target: window; activeScene: aboutScene}
        },
        State {
            name: "runSession"
            PropertyChanges {target: runSessionScene; opacity: 1}
            PropertyChanges {target: window; activeScene: runSessionScene}
        },
        State {
            name: "configSeries"
            PropertyChanges {target: configSeriesScene; opacity: 1}
            PropertyChanges {target: window; activeScene: configSeriesScene}
        },
        State {
            name: "hrmSetup"
            PropertyChanges {target: hrmSetupScene; opacity: 1}
            PropertyChanges {target: window; activeScene: hrmSetupScene}
        }
    ]
    Loader {
        id: pageLoader
        anchors.fill: parent
    }

}
