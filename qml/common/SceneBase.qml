//import VPlay 2.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Window 2.2
import "."
Page {
    id: sceneBase
    //active:true
    //anchors.topMargin: 60
    Image {
        //z:90
        id: bkgImg
        source: "../../assets/img/surface.png"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.4
        anchors.fill: parent
    }
    // every change in opacity will be done with an animation
    Behavior on opacity {
        NumberAnimation {property: "opacity"; easing.type: Easing.InOutQuad}
    }
}
