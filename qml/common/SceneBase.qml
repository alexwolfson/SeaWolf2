//import VPlay 2.0
import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import "."
Tab {
    id: sceneBase
    active:true
    // back button to leave scene
    property int default_pix_density: 4  //pixel density of my current screen
    property int scale_factor: Screen.pixelDensity/default_pix_density
    function dp(pix){
        return pix * scale_factor
    }
    property int tabHeaderHight:dp(30)
    // by default, set the opacity to 0 - this is changed from the main.qml with PropertyChanges
    //opacity: 0
    // we set the visible property to false if opacity is 0 because the renderer skips invisible items, this is an performance improvement
    //visible: opacity > 0
    // if the scene is invisible, we disable it. In Qt 5, components are also enabled if they are invisible.
    //   This means any MouseArea in the Scene would still be active even we hide the Scene,
    //   since we do not want this to happen, we disable the Scene (and therefore also its children) if it is hidden
    //active: visible

    // every change in opacity will be done with an animation
    Behavior on opacity {
        NumberAnimation {property: "opacity"; easing.type: Easing.InOutQuad}
    }

}
