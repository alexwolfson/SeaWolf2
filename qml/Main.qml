//#import VPlay 2.0
import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
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
        var sfWidth = Screen.width / 1080
        var sfHeight  = Screen.height / 1776
        return Math.min(/*sfDen, */sfWidth, sfHeight)
    }
    property int firstTime:1
    property var runColors: {"brth" : "green", "hold" : "tomato", "walk" : "blue", "back" : "orange"}
    //will return "undefined" type if color is undefined
    function getStepColor(stepName){
        return runColors[stepName]
    }

    //for debugging
    function listProperty(item)
    {
        for (var p in item){
            console.log(p + ": " , item[p]);
        }
    }
    function listPropertiesByName(msg, item, nameList){
        var name
        console.log(" *** " + msg + ": print start " + " ***")
//        for (name in nameList){
//            console.log(name,": ", item[name])
//        }
        for (var i =0; i < nameList.length; i++){
            console.log(nameList[i],": ", item[nameList[i]])
        }
        console.log(" *** " + msg + ": print end " + " ***")
    }
    function listByName(that, msg, nameList){
        var name
        var val = "undefined"
        console.log(" *** " + msg + ": print start " + " ***")
        for (var i =0; i < nameList.length; i++){
            val = eval(nameList[i])
            if (typeof (val) === "undefined"){
                val = that[nameList[i]]
            }

            console.log(nameList[i], ": ", val)
        }
        console.log(" *** " + msg + ": print end " + " ***")
    }


    function dp(pix){
        if (firstTime){
            console.log("Screen.pixelDensity = ", Screen.pixelDensity, "scale_factor = ", scale_factor)
            firstTime = 0
        }
        return pix * scale_factor
    }
    function invert (obj) {
        var new_obj = {};
        for (var prop in obj) {
            if(obj.hasOwnProperty(prop)) {
                new_obj[obj[prop]] = prop;
            }
        }
        return new_obj;
    }

    property int brthIndx: 0
    property int holdIndx: 1
    property int walkIndx: 2
    property int backIndx: 3
    property var myEventsNm2Enum:{"brth":0 , "hold":1, "walk":2, "back":3, "EndOfMeditativeZone":4, "EndOfComfortZone":5, "Contraction":6, "EndOfWalk":7 }
    property var myEventsEnum2Nm: invert(myEventsNm2Enum)
    property var currentSessionOrig: {
                               "sessionName":"TestSession",
                               "sessionType":"ChangeMeu",
                                       "when":"ChangeMe", //Qt.formatDateTime(new Date(), "yyyy-MM-dd-hh-mm-ss"),
                                       "eventNames":myEventsNm2Enum,
                                       "event":[],
                                       "pulse":[],
                                       "discomfort":[],
                                       "stepsAr":StepsAr.stepsArOrig
                           }
    property var currentSession:currentSessionOrig
    //property string stepNbText:"StepNb"
    //Is set, when RunSessionScene is loaded
    property int typesDim
    visible:true
    //for some reason dp(1920) created binding loop and dependence of NONNotifiable factor
    height: Screen.height
    width: Screen.height > Screen.width ? Screen.width : Screen.height * 9/16
    header:TabBar {
        id: tabView
        position:TabBar.Header
        //anchors.fill: parent
        //anchors.margins: 4
        background: Rectangle {
            color: tabView.enabled ? "steelblue" :"lightsteelblue"
            border.color:  "steelblue"
            border.width: dp(4)
            implicitWidth: Math.max(text.width + dp(20), dp(100))
            implicitHeight: dp(100)
            radius: dp(4)
            Text {
                id: text
                anchors.centerIn: parent
                //text: styleData.title
                //color: styleData.selected ? "white" : "black"
            }
        }
        Component.onCompleted:  {
            //those 2 functions provide different functionslity
            conf.sessionSelected.connect( run.runSetupSession);
            conf.sessionSelected.connect(run.currentHrPlot.plotSetupSession)
            hrm.startHrmDemo.connect(run.currentHrPlot.demoHrm)
            hrm.startHrmSearch.connect(run.currentHrPlot.realHrm)
            run.sessionTimeUpdate.connect(run.currentHrPlot.sessionTimeUpdateSlot)
            currentSession = currentSessionOrig
        }
        //style: TabViewStyle {
            //frameOverlap: dp(0)
//            frame:     Image {
//                //z:90
//                id: bkgImg
//                source: "../../assets/img/surface.png"
//                fillMode: Image.PreserveAspectCrop
//                opacity: 0.4
//                anchors.fill: parent
//            }

        TabButton { id: browseSessionTypes; text: qsTr("Sessions")}
        TabButton { id: confTab; text: qsTr("Conf")}
        TabButton { id: runTab; text: qsTr("Run"); }
        TabButton { id: hrmTab; text: qsTr("HRM")}
        TabButton { id: browseResTab; text: qsTr("Results")}
        TabButton { id: prefTab; text: qsTr("Pref")}
        TabButton { id: aboutTab; text: qsTr("About")}
        TabButton { id: finishTab; text: qsTr("Finish")}
    }
    StackLayout {
        id:stackLayout
        width: parent.width
        currentIndex: tabView.currentIndex
        BrowseResultsScene{ id:browseSes;  }
        ConfigSeriesScene{ id:conf; }
        RunSessionScene{ id:run;  title: qsTr("Run the session")  }
        HrmSetupScene{  id:hrm;     }
        BrowseResultsScene{  id:browseRes; }
        ConfigPreferencesScene{ id: pref }
        AboutScene{  id:about;      }
        SceneBase {
            z:100
            id:finish;
            width: root.width
            height: root.height
            visible:true
            //anchors.leftMargin: dp(20)
            //Text {text:qsTr("Finish")}
           Item {
                id: quit
                visible:true
                anchors.fill: parent
                MenuButton{
                    z:95
                    id:quitButton
                    width:parent.width/4
                    height: width
                    //border.width: dp(4)
                    //border.color: "black"
                    text: qsTr("Quit")
                    anchors.centerIn: parent
                    onClicked: {
                        heartRate.disconnectService();
                        Qt.quit()
                    }
                }

                Image {
                    z:100
                   source: "../../assets/img/SeaWolf.png"
                   anchors.horizontalCenter: parent.horizontalCenter
                   anchors.top: quitButton.bottom
                   //anchors.bottom: parent.bottom
                   width:parent.width/2
                   height: width
               }
           }
        }
    }
    Component.onCompleted: {
        currentSession = currentSessionOrig
    }

    Loader {
        id: pageLoader
        anchors.fill: parent
    }
}


