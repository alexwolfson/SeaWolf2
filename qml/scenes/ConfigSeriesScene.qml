//import VPlay 2.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2

import "../common"

SceneBase {
    id: configSeriesScene
    //===================================================
    // signal indicating that current session is selected
    signal sessionSelected(var sessionName, var selectedSession)

    Item{
        id: session
        property string name
        //property alias numberOfCycles:nbOfCycles.result
        property bool repeatLast:false
        property int minBreathTime:5
        property int breathDecrement:5
        property int maxHoldTime:20
        property int holdIncrement:5
        property int walkTime:120
        property int walkBackTime:120
        property var currentSessionProperties
        property  string sessionType:"WALK"
        property string sessionName
        property int numberOfCycles
        width: root.width
        height: root.height
        visible:true
        anchors.leftMargin: dp(20)
        //flags: Qt.Dialog
        //modality: Qt.ApplicationModal

         ColumnLayout {
            //z:100
            id: mainLayout
            //columns: 2
            spacing: dp(30)
            //columnSpacing: 5
            anchors {
                top: parent.top;
                left: parent.left
                right: parent.right
                leftMargin: dp(20)
                topMargin: dp(20)
            }
            Row {
                id: buttonsRow
//                anchors.bottom: parent.bottom
//                anchors.left: parent.left
//                anchors.right: parent.right
                spacing: dp(3)

                MenuButton {
                    text: "New CO2"
                    onClicked: {
                        holdIncrementEdit.visible  = false
                        breathDecrementEdit.visible = true
                        walkTimeEdit.visible       = false
                        backTimeEdit.visible       = false
                        sessionType                = "CO2"
                    }
                }

                MenuButton {
                    text: "New O2"
                    onClicked: {
                        holdIncrementEdit.visible  = true
                        breathDecrementEdit.visible = false
                        walkTimeEdit.visible       = false
                        backTimeEdit.visible       = false
                        sessionType                = "O2"
                    }
                }
                MenuButton {
                    text: "New WALK"
                    onClicked: {
                        holdIncrementEdit.visible  = false
                        breathDecrementEdit.visible = false
                        walkTimeEdit.visible       = true
                        backTimeEdit.visible       = true
                        sessionType                = "WALK"
                    }
                }
                MenuButton {
                    text: "Save"
                    onClicked: {
                        if (sessionType == "CO2"){
                            currentSessionProperties = generateCO2Session()
                            console.log(" **** generated CO2 session=", currentSessionProperties)
                       }
                        else if (sessionType == "O2"){
                            currentSessionProperties = generateO2Session()
                            console.log(" **** generated O2 session=", currentSessionProperties)
                        }
                        else if (sessionType == "WALK"){
                            currentSessionProperties = generateWalkSession()
                            console.log(" **** generated WALK session=", currentSessionProperties)
                        }
                        sessionName = session.name
                        sessionSelected(sessionName, currentSessionProperties)
                      //  levelEditor.saveCurrentLevel( {levelMetaData: {levelName: session.name}, customData:currentSessionProperties} )
                    }
                }
            }

            //Label { text: qsTr("sessionName") }
            SeaWolfInput{ type:"str";   lbl: qsTr("sessionName");    sft:"";        onResult: {sessionName=res}}
            SeaWolfInput{ type:"int";   lbl: qsTr("numberOfCycles"); ift:"6";       onResult: {numberOfCycles=parseInt(res)}}
            SeaWolfInput{ id: rLast; type:"switch";lbl: qsTr("repeatLast");         onResult: {repeatLast=swYesNo}}
            SeaWolfInput{ type:"int";   lbl: qsTr("minBreathTime");  ift:"15";      onResult: {minBreathTime=parseInt(res)}}
            SeaWolfInput{ id:breathDecrementEdit; type:"int";   lbl: qsTr("breathDecrement");ift:"15";      onResult: {breathDecrement=parseInt(res)}}
            SeaWolfInput{ type:"int";   lbl: qsTr("maxHoldTime");    ift:"120";     onResult: {maxHoldTime=res}}
            SeaWolfInput{ id:holdIncrementEdit; type:"int";   lbl: qsTr("holdIncrement");  ift:"15";      onResult: {holdIncrement=parseInt(res)}}
            SeaWolfInput{ id:walkTimeEdit; type:"int";   lbl: qsTr("walkTime");       ift:"120";     onResult: {walkTime=parseInt(res)}}
            SeaWolfInput{ id:backTimeEdit; type:"int";   lbl: qsTr("walkBackTime");   ift:"120";     onResult: {walkBackTime=parseInt(res)}}
        }

    // had trouble with multidimension arrays in javascript function, so stated to use 1 dimension
    function get2DimIndex(dim0, dim1){
        return 3 * dim0 + dim1
    }
    // Create a JSON array representing the current session
    // Do we need to make it robust, check for ranges, etc. ?
    function generateO2Session (){
        var mySession = []
        sessionType = "O2"

        var cycles4Calculation = session.repeatLast ? session.numberOfCycles - 2 : session.numberOfCycles - 1;
        mySession.unshift( {"time" : 0, "typeName" :"back"});
        mySession.unshift( {"time" : 0, "typeName" :"walk"});
        mySession.unshift( {"time" : session.maxHoldTime, "typeName" :"hold"});
        mySession.unshift( {"time" : session.minBreathTime, "typeName" :"brth"});
        // copy the last group
        if (session.repeatLast){
            mySession.unshift( mySession[mySession.length -1]);
            mySession.unshift( mySession[mySession.length -2]);
            mySession.unshift( mySession[mySession.length -3]);
            mySession.unshift( mySession[mySession.length -4]);
        }
        for (var i = 0; i < cycles4Calculation; i++){
            //mySession[i] = new Array (3)
            mySession.unshift( {"time": 0, "typeName": "back"});
            mySession.unshift( {"time": 0, "typeName": "walk"});
            console.log("***** mySession=", mySession[0].time, mySession[1].time, mySession[2].time, mySession[3].time)
            // we are adding to the beginning of the array so the previous time is always in element 2 (if starting from 0)
            mySession.unshift( {"time": mySession[3].time - session.holdIncrement, "typeName": "hold"});
            mySession.unshift( {"time": session.minBreathTime, "typeName": "brth"});
            console.log("***** mySession=", mySession[0].time, mySession[1].time, mySession[2].time)
        }

        return mySession

    }


//    EditableComponent {
//        id:o2
//        editableType: "O2"
//        editableComponentMetaData: {
//          "displayname" : "O2 Session"
//        }
//        defaultGroup: "Click to choose Session"
//        target:session
//        properties: {
//            "name": {label:"Session name"},
//            "numberOfCycles": {"min": 1, "max": 8, "stepsize": 1, "label": "Number of cycles" },
//            "repeatLast":{label:"Repeat Last Cycle"},
//            "minBreathTime":{"min":0, "max":600, "stepsize": 5, "label": "Breath time"},
//            "maxHoldTime":{"min":0, "max":600, "stepsize": 5, "label": "Maximum hold time"},
//            "holdIncrement":{"min":0, "max":120, "stepsize": 5, "label": "Hold time increment"}
//        }
//    }
    // Create a JSON array representing the current session
    // Do we need to make it robust, check for ranges, etc. ?
    function generateCO2Session (){
        var mySession = []
        sessionType = "CO2"

        var cycles4Calculation = session.repeatLast ? session.numberOfCycles - 2 : session.numberOfCycles - 1;
        mySession.unshift( {"time" : 0, "typeName" :"back"});
        mySession.unshift( {"time" : 0, "typeName" :"walk"});
        mySession.unshift( {"time" : session.maxHoldTime, "typeName" :"hold"});
        mySession.unshift( {"time" : session.minBreathTime, "typeName" :"brth"});
        // copy the last group
        if (session.repeatLast){
            mySession.unshift( mySession[mySession.length -1]);
            mySession.unshift( mySession[mySession.length -2]);
            mySession.unshift( mySession[mySession.length -3]);
            mySession.unshift( mySession[mySession.length -4]);
        }
        for (var i = 0; i < cycles4Calculation; i++){
            // we are adding to the beginning of the array so the previous time is always in element 2 (if starting from 0)
            mySession.unshift( {"time": 0, "typeName": "back"});
            mySession.unshift( {"time": 0, "typeName": "walk"});
            mySession.unshift( {"time": session.maxHoldTime, "typeName": "hold"});
            mySession.unshift( {"time": mySession[3].time + session.breathDecrement, "typeName": "brth"});
        }

        return mySession

    }

//    EditableComponent {
//        id:co2
//        editableType: "CO2"
//        editableComponentMetaData: {
//          "displayname" : "CO2 Session"
//        }
//        defaultGroup: "Click to choose Session"

//        target:session
//        properties: {
//            "name": {label:"Session name"},
//            "numberOfCycles": {"min": 1, "max": 8, "stepsize": 1, "label": "Number of cycles" },
//            "repeatLast":{label:"Repeat Last Cycle"},
//            "minBreathTime":{"min":0, "max":600, "stepsize": 5, "label": "Minimum breath time"},
//            "breathDecrement":{"min":0, "max":120, "stepsize": 5, "label": "Breath time decrement"},
//            "maxHoldTime":{"min":0, "max":600, "stepsize": 5, "label": "Hold time"},
//        }

//    }
    // Create a JSON array representing the current session
    // Do we need to make it robust, check for ranges, etc. ?
    function generateWalkSession (gaugeName){
        var mySession = []
        sessionType = "WALK"

        for (var i = 0; i < session.numberOfCycles; i++){
            // we are adding to the beginning of the array so the previous time is always in element 2 (if starting from 0)
            mySession.unshift( {"time": session.walkTime,   "typeName": "back"});
            mySession.unshift( {"time": session.walkTime,   "typeName": "walk"});
            mySession.unshift( {"time": session.maxHoldTime,   "typeName": "hold"});
            mySession.unshift( {"time": session.minBreathTime, "typeName": "brth"});
        }
        return mySession
    }
//    EditableComponent {
//        id:walk
//        editableType: "WALK"
//        editableComponentMetaData: {
//          "displayname" : "Walk Session"
//        }
//        defaultGroup: "Click to choose Session"
//        target:session
//        properties: {
//            "name": {label:"Session name"},
//            "numberOfCycles": {"min": 1, "max": 8, "stepsize": 1, "label": "Number of cycles" },
//            "minBreathTime":{"min":0, "max":180, "stepsize": 5, "label": "Breath time"},
//            "maxHoldTime":{"min":0, "max":300, "stepsize": 5, "label": "Hold time"},
//            "walkTime":{"min":0, "max":300, "stepsize": 5, "label": "Walk time"},

//        }
//    }
//    ItemEditor {
//      id: itemEditor // important to set the id to ItemEditor!
//      anchors.fill: parent
//      //anchors.bottomMargin: buttonsRow.height

//    }


    }
//    Image {
//        source: "../../assets/img/SeaWolf.png"
//        width: dp(160)
//        height: dp(160)
////        anchors.right: parent.right
////        anchors.rightMargin: dp(10)
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin: dp(10)
//    }

}// end of Scene
