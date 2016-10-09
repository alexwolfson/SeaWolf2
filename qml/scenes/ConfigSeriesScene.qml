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
    // had trouble with multidimension arrays in javascript function, so stated to use 1 dimension
    function get2DimIndex(dim0, dim1){
        return 3 * dim0 + dim1
    }
    // Create a JSON array representing the current session
    // Do we need to make it robust, check for ranges, etc. ?
    function generateO2Session (){
        var mySession = []
        sessionType = "O2"

        var cycles4Calculation = repeatLast ? numberOfCycles - 2 : numberOfCycles - 1;
        mySession.unshift( {"time" : 0, "typeName" :"back"});
        mySession.unshift( {"time" : 0, "typeName" :"walk"});
        mySession.unshift( {"time" : maxHoldTime, "typeName" :"hold"});
        mySession.unshift( {"time" : minBreathTime, "typeName" :"brth"});
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
            //console.log("***** mySession=", mySession[0].time, mySession[1].time, mySession[2].time, mySession[3].time)
            // we are adding to the beginning of the array so the previous time is always in element 2 (if starting from 0)
            mySession.unshift( {"time": mySession[3].time - holdIncrement, "typeName": "hold"});
            mySession.unshift( {"time": minBreathTime, "typeName": "brth"});
            //console.log("***** mySession=", mySession[0].time, mySession[1].time, mySession[2].time)
        }

        return mySession

    }

    // Create a JSON array representing the current session
    // Do we need to make it robust, check for ranges, etc. ?
    function generateCO2Session (){
        var mySession = []
        sessionType = "CO2"

        var cycles4Calculation = repeatLast ? numberOfCycles - 2 : numberOfCycles - 1;
        mySession.unshift( {"time" : 0, "typeName" :"back"});
        mySession.unshift( {"time" : 0, "typeName" :"walk"});
        mySession.unshift( {"time" : maxHoldTime, "typeName" :"hold"});
        mySession.unshift( {"time" : minBreathTime, "typeName" :"brth"});
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
            mySession.unshift( {"time": maxHoldTime, "typeName": "hold"});
            mySession.unshift( {"time": mySession[3].time + breathDecrement, "typeName": "brth"});
        }

        return mySession

    }

    // Create a JSON array representing the current session
    // Do we need to make it robust, check for ranges, etc. ?
    function generateWalkSession (){
        var mySession = []
        sessionType = "WALK"

        for (var i = 0; i < numberOfCycles; i++){
            // we are adding to the beginning of the array so the previous time is always in element 2 (if starting from 0)
            mySession.unshift( {"time": walkTime,   "typeName": "back"});
            mySession.unshift( {"time": walkTime,   "typeName": "walk"});
            mySession.unshift( {"time": maxHoldTime,   "typeName": "hold"});
            mySession.unshift( {"time": minBreathTime, "typeName": "brth"});
        }
        return mySession
    }


    Item{
        id: session
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
            RowLayout {
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
                    text: "Select"
                    onClicked: {
                        //AWDEBUG
//                        property string name
//                        //property alias numberOfCycles:nbOfCycles.result
//                        property bool repeatLast:false
//                        property int minBreathTime:5
//                        property int breathDecrement:5
//                        property int maxHoldTime:20
//                        property int holdIncrement:5
//                        property int walkTime:120
//                        property int walkBackTime:120
//                        property var currentSessionProperties
//                        property  string sessionType:"WALK"
//                        property string sessionName
//                        property int numberOfCycles
                        root.listByName("ConfigSeriesScene attached properites list", configSeriesScene, ["name", "repeatLast", "minBreathTime", "breathDecrement",
                                   "maxHoldTime", "holdIncrement", "walkTime", "walkBackTime", "sessionType", "sessionName", "numberOfCycles"] )
                        //console.log("minBreathTime =", minBreathTime, configSeriesScene["minBreathTime"], this["configSeriesScene"])

                        //root.listProperty(this)
                        //console.log(JSON.stringify(configSeriesScene))
                        if (sessionType == "CO2"){
                            currentSessionProperties = generateCO2Session()
                            //console.log(" **** generated CO2 session=", currentSessionProperties)
                       }
                        else if (sessionType == "O2"){
                            currentSessionProperties = generateO2Session()
                            //console.log(" **** generated O2 session=", currentSessionProperties)
                        }
                        else if (sessionType == "WALK"){
                            currentSessionProperties = generateWalkSession()
                            //console.log(" **** generated WALK session=", currentSessionProperties)
                        }
                        //sessionName = name
                        sessionSelected(sessionName, currentSessionProperties)
                      //  levelEditor.saveCurrentLevel( {levelMetaData: {levelName: name}, customData:currentSessionProperties} )
                    }
                }
            }

            //Label { text: qsTr("sessionName") }
            SeaWolfInput{ type:"str";   lbl: qsTr("sessionName");    sfv:"";        onResult: {sessionName=res}}
            SeaWolfInput{ type:"int";   lbl: qsTr("numberOfCycles"); ifv:"6";       onResult: {numberOfCycles=parseInt(res)}}
            SeaWolfInput{ type:"spinBox";   lbl: qsTr("numberOfCycles"); sbv:6; sbfrom:1; sbto: 10; sbstep: 1;  onResult: {numberOfCycles=intRes}}
            SeaWolfInput{ id: rLast; type:"switch";lbl: qsTr("repeatLast");         onResult: {repeatLast=swYesNo}}
            SeaWolfInput{ type:"int";   lbl: qsTr("minBreathTime");  ifv:"15";      onResult: {minBreathTime=parseInt(res)}}
            SeaWolfInput{ id:breathDecrementEdit; type:"int";   lbl: qsTr("breathDecrement");ifv:"15";      onResult: {breathDecrement=parseInt(res)}}
            SeaWolfInput{ type:"int";   lbl: qsTr("maxHoldTime");    ifv:"120";     onResult: {maxHoldTime=parseInt(res)}}
            SeaWolfInput{ type:"spinBox";   lbl: qsTr("maxHoldTime"); sbv:120; sbfrom:30; sbto: 600; sbstep: 5;  onResult: {maxHoldTime=intRes}}
            SeaWolfInput{ id:holdIncrementEdit; type:"int";   lbl: qsTr("holdIncrement");  ifv:"15";      onResult: {holdIncrement=parseInt(res)}}
            SeaWolfInput{ id:walkTimeEdit; type:"int";   lbl: qsTr("walkTime");       ifv:"120";     onResult: {walkTime=parseInt(res)}}
            SeaWolfInput{ id:backTimeEdit; type:"int";   lbl: qsTr("walkBackTime");   ifv:"120";     onResult: {walkBackTime=parseInt(res)}}
        }

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
