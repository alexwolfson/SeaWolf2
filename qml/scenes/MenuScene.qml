import VPlay 2.0
import QtQuick 2.0
import QtQuick.Layouts 1.2
import "../common"

SceneBase {
    id: menuScene
    // signal indicating that the selectLevelScene should be displayed
    signal selectLevelPressed
    // signal indicating that the creditsScene should be displayed
    signal creditsPressed
    // signal indicating that the aboutScene should be displayed
    signal aboutPressed
    // signal indicating that the configSeriesScene should be displayed
    signal configSeriesPressed
    // signal indicating that the RunSessionScene should be dislayed
    signal runSessionPressed

    // background
    Image {
        id: bkgImg
        source: "../../assets/img/SeaWolf.png"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.5
        anchors.fill: parent
    }

//    Rectangle {
//        anchors.fill: parent.gameWindowAnchorItem
//        color: "#47688e"
//    }

//    // use a BackgroundImage for performance improvements involving blending function and pixelFormat, especially important for Android!
//    BackgroundImage {
//        id:surfaceBackground
//        source: "../../assets/img/surface.png"

//        // use this if the image should be centered, which is the most common case
//        // if the image should be aligned at the bottom, probably the whole scene should be aligned at the bottom,
          //   and the image should be shited up by the delta between the imagesSize and the scene.y!
//        anchors.centerIn: parent
//    }
    // the "logo"
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: dp(30)
        font.pixelSize: dp(30)
        color: "#e9e9e9"
        text: "SeaWolf Apnea Training"
    }

    // menu
    Column {
        anchors.centerIn: parent
        spacing: dp(10)
        MenuButton {
            text: "About"
            onClicked: aboutPressed()
            anchors.horizontalCenter: parent.horizontalCenter
        }
        MenuButton {
            text: "Config Series"
            onClicked: configSeriesPressed()
            anchors.horizontalCenter: parent.horizontalCenter
        }
        MenuButton {
            text: "Run Session"
            onClicked: runSessionPressed()
            anchors.horizontalCenter: parent.horizontalCenter
        }
        MenuButton {
            text: "Levels"
            onClicked: selectLevelPressed()
            anchors.horizontalCenter: parent.horizontalCenter
        }
//        MenuButton {
//            text: "Credits"
//            onClicked: creditsPressed()
//            anchors.horizontalCenter: parent.horizontalCenter
//        }
        MenuButton {
            text: "Finish"
            onClicked: Qt.quit()
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // a little V-Play logo is always nice to have, right?
    Image {
//        source: "../../assets/img/vplay-logo.png"
        source: "../../assets/img/SeaWolf.png"
        width: dp(160)
        height: dp(160)
        anchors.right: menuScene.gameWindowAnchorItem.right
        anchors.rightMargin: 10
        anchors.bottom: menuScene.gameWindowAnchorItem.bottom
        anchors.bottomMargin: 10
    }
}
