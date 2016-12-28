//import VPlay 2.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

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
    property var breathTime:[60,60,60,60]
    property var holdTime:  [60,60,60,60]
    property int walkTime:120
    property int walkBackTime:120
    property var currentSessionProperties
    property  string sessionType:"WALK"
    property string sessionName
    property int numberOfCycles
    property bool additionalBreath:true
    // had trouble with multidimension arrays in javascript function, so stated to use 1 dimension
    function get2DimIndex(dim0, dim1){
        return 3 * dim0 + dim1
    }
    // Create a JSON array representing the current session
    // Do we need to make it robust, check for ranges, etc. ?
    function generateO2Session (){
        var mySession = []
        sessionType = "O2"
        if (additionalBreath){
            // we are adding to the beginning of the array so the previous time is always in element 2 (if starting from 0)
            mySession.unshift( {"time": 0,   "typeName": "back"});
            mySession.unshift( {"time": 0,   "typeName": "walk"});
            mySession.unshift( {"time": 0,   "typeName": "hold"});
            mySession.unshift( {"time": 60, "typeName": "brth"});
        }
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

        if (additionalBreath){
            // we are adding to the beginning of the array so the previous time is always in element 2 (if starting from 0)
            mySession.unshift( {"time": 0,   "typeName": "back"});
            mySession.unshift( {"time": 0,   "typeName": "walk"});
            mySession.unshift( {"time": 0,   "typeName": "hold"});
            mySession.unshift( {"time": 60, "typeName": "brth"});
        }
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
        if (additionalBreath){
            // we are adding to the beginning of the array so the previous time is always in element 2 (if starting from 0)
            mySession.unshift( {"time": 0,   "typeName": "back"});
            mySession.unshift( {"time": 0,   "typeName": "walk"});
            mySession.unshift( {"time": 0,   "typeName": "hold"});
            mySession.unshift( {"time": 60,  "typeName": "brth"});
        }
        // we are adding to the beginning of the array so the previous time is always in element 2 (if starting from 0)
        for (var i = 0; i < breathTime.length; i++){
            if (breathTime[i] === 0){
                break;
            }else{
                mySession.unshift( {"time": walkTime,     "typeName": "back"});
                mySession.unshift( {"time": walkTime,     "typeName": "walk"});
                mySession.unshift( {"time": holdTime[i],  "typeName": "hold"});
                mySession.unshift( {"time": breathTime[i],"typeName": "brth"});
            }
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
                        maxHoldTimeId.visible        = true
                        minBreathTimeId.visible      = true
                        numberOfCyclesId.visible     = true
                        repeatLastId.visible         = true
                        holdIncrementId.visible  = false
                        breathDecrementId.visible= true
                        walkTimeEdit.visible       = false
                        backTimeEdit.visible       = false
                        sessionType                = "CO2"
                        breathTime1.visible        = false
                        breathTime2.visible        = false
                        breathTime3.visible        = false
                        breathTime4.visible        = false
                        holdTime1.visible          = false
                        holdTime2.visible          = false
                        holdTime3.visible          = false
                        holdTime4.visible          = false                    }
                }

                MenuButton {
                    text: "New O2"
                    onClicked: {
                        maxHoldTimeId.visible        = true
                        minBreathTimeId.visible      = true
                        numberOfCyclesId.visible     = true
                        repeatLastId.visible         = true
                        holdIncrementId.visible  = true
                        breathDecrementId.visible = false
                        walkTimeEdit.visible       = false
                        backTimeEdit.visible       = false
                        sessionType                = "O2"
                        breathTime1.visible        = false
                        breathTime2.visible        = false
                        breathTime3.visible        = false
                        breathTime4.visible        = false
                        holdTime1.visible          = false
                        holdTime2.visible          = false
                        holdTime3.visible          = false
                        holdTime4.visible          = false
                    }
                }
                MenuButton {
                    text: "New WALK"
                    onClicked: {
                        maxHoldTimeId.visible        = false
                        minBreathTimeId.visible      = false
                        numberOfCyclesId.visible     = false
                        repeatLastId.visible         = false
                        holdIncrementId.visible      = false
                        breathDecrementId.visible    = false
                        walkTimeEdit.visible       = true
                        backTimeEdit.visible       = true
                        sessionType                = "WALK"
                        breathTime1.visible        = true
                        breathTime2.visible        = true
                        breathTime3.visible        = true
                        breathTime4.visible        = true
                        holdTime1.visible          = true
                        holdTime2.visible          = true
                        holdTime3.visible          = true
                        holdTime4.visible          = true

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
                        root.listPropertiesByName("ConfigSeriesScene attached properites list", configSeriesScene, ["name", "repeatLast", "minBreathTime", "breathDecrement",
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
            SeaWolfInput{ id:sessionNameId; type:"str";   lbl: qsTr("sessionName");    sfv:"";        onResult: {sessionName=res}}
            SeaWolfInput{ id:numberOfCyclesId; type:"spinBox";   lbl: qsTr("numberOfCycles"); sbv:6; sbfrom:1; sbto: 10; sbstep: 1;  onResult: {numberOfCycles=intRes}}
            SeaWolfInput{ id: repeatLastId;    type:"switch";lbl: qsTr("repeatLast");         onResult: {repeatLast=swYesNo}}
            SeaWolfInput{ id: additionalBreathId;     type:"switch";lbl: qsTr("additional60SecRecord");         onResult: {additionalBreath=swYesNo}}
            SeaWolfInput{ id: minBreathTimeId; type:"spinBox";   lbl: qsTr("minBreathTime"); sbv:15; sbfrom:0; sbto: 180; sbstep: 5;  onResult: {minBreathTime=intRes}}
            SeaWolfInput{ id:breathDecrementId;type:"spinBox";   lbl: qsTr("breathDecrement"); sbv:15; sbfrom:0; sbto: 60; sbstep: 5;  onResult: {breathDecrement=intRes}}
            SeaWolfInput{ id:maxHoldTimeId;    type:"spinBox";   lbl: qsTr("maxHoldTime"); sbv:120; sbfrom:30; sbto: 600; sbstep: 5;  onResult: {maxHoldTime=intRes}}
            SeaWolfInput{ id:holdIncrementId;  type:"spinBox";   lbl: qsTr("holdIncrement"); sbv:15; sbfrom:0; sbto: 60; sbstep: 5;  onResult: {holdIncrement=intRes}}

            SeaWolfInput{ id: breathTime1; type:"spinBox";   lbl: qsTr("BreathTime1"); sbv:breathTime[0]; sbfrom:0; sbto: 180; sbstep: 5;  onResult: {breathTime[0]=intRes}}
            SeaWolfInput{ id: holdTime1;   type:"spinBox";   lbl: qsTr("HoldTime1");   sbv:holdTime[0]  ; sbfrom:0; sbto: 180; sbstep: 5;  onResult: {holdTime[0]  =intRes}}
            SeaWolfInput{ id: breathTime2; type:"spinBox";   lbl: qsTr("BreathTime2"); sbv:breathTime[1]; sbfrom:0; sbto: 180; sbstep: 5;  onResult: {breathTime[1]=intRes}}
            SeaWolfInput{ id: holdTime2;   type:"spinBox";   lbl: qsTr("HoldTime2");   sbv:holdTime[1]  ; sbfrom:0; sbto: 180; sbstep: 5;  onResult: {holdTime[1]  =intRes}}
            SeaWolfInput{ id: breathTime3; type:"spinBox";   lbl: qsTr("BreathTime3"); sbv:breathTime[2]; sbfrom:0; sbto: 180; sbstep: 5;  onResult: {breathTime[2]=intRes}}
            SeaWolfInput{ id: holdTime3;   type:"spinBox";   lbl: qsTr("HoldTime3");   sbv:holdTime[2]  ; sbfrom:0; sbto: 180; sbstep: 5;  onResult: {holdTime[2]  =intRes}}
            SeaWolfInput{ id: breathTime4; type:"spinBox";   lbl: qsTr("BreathTime4"); sbv:breathTime[3]; sbfrom:0; sbto: 180; sbstep: 5;  onResult: {breathTime[3]=intRes}}
            SeaWolfInput{ id: holdTime4;   type:"spinBox";   lbl: qsTr("HoldTime4");   sbv:holdTime[3]  ; sbfrom:0; sbto: 180; sbstep: 5;  onResult: {holdTime[3]  =intRes}}

            SeaWolfInput{ id:walkTimeEdit; type:"spinBox";   lbl: qsTr("maxWalkTime"); sbv:120; sbfrom:0; sbto: 200; sbstep: 5;  onResult: {walkTime=intRes}}
            SeaWolfInput{ id:backTimeEdit; type:"spinBox";   lbl: qsTr("maxWalkBackTime"); sbv:120; sbfrom:0; sbto: 200; sbstep: 5;  onResult: {walkBackTime=intRes}}
            Image {
               source: "../../assets/img/SeaWolf.png"
               anchors.right: parent.right
               anchors.bottom: parent.bottom
               width: dp(150)
               height:width
           }
        }
    }
}// end of Scene
