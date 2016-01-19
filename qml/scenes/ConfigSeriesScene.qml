import VPlay 2.0
import QtQuick 2.0
import "../common"

  SceneBase {
    id: configSeriesScene
    property var currentSession
    property  string sessionType:"WALK"
    MenuButton {
        z:100
        text: "Back"
        // anchor the button to the gameWindowAnchorItem to be on the edge of the screen on any device
        anchors.right: configSeriesScene.gameWindowAnchorItem.right
        anchors.rightMargin: 10
        anchors.top: configSeriesScene.gameWindowAnchorItem.top
        anchors.topMargin: 10
        onClicked: backButtonPressed()
    }

    Item{
        id: session
        property string name
        property int numberOfCycles
        property bool repeatLast:false
        property int holdTime:20
        property int holdIncrement:1
        property int breathTime:5
        property int breathDecrement:1
        property int walkTime:120
    }
    LevelEditor {
      id: levelEditor
      anchors.fill: parent
      applicationJSONLevelsDirectory: "jsonSessions/"
//      toRemoveEntityTypes: [ "platform", "platformGoal", "stars", "obstacle" ]
//      toStoreEntityTypes: [ "platform", "platformGoal", "stars", "obstacle" ]
      Component.onCompleted: {
          loadAllLevelsFromStorageLocation(applicationJSONLevelsLocation)
      }
    }

    LevelSelectionList {
        id: levelSelectionList
        width: 150
        z: 3
        // at the beginning it is invisible, only gets visible after a click on the Levels button
        visible: false
        anchors.centerIn: parent
        levelMetaDataArray: levelEditor.authorGeneratedLevels
        //levelMetaDataArray: levelEditor.applicationJSONLevels

        onLevelSelected: {
            levelEditor.loadSingleLevel(levelData)
            // make invisible afterwards
            levelSelectionList.visible = false
        }
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

        var cycles4Calculation = session.repeatLast ? session.numberOfCycles -1 : session.numberOfCycles;
        mySession.unshift( {"time" : 0, "typeName" :"walk"});
        mySession.unshift( {"time" : session.holdTime, "typeName" :"hold"});
        mySession.unshift( {"time" : session.breathTime, "typeName" :"brth"});
        // copy the last group
        var currentSessionLength = mySession.length
        if (session.repeatLast){
            mySession.unshift( mySession[currentSessionLength -1]);
            mySession.unshift( mySession[currentSessionLength -2]);
            mySession.unshift( mySession[currentSessionLength -3]);
        }
        for (var i = 0; i < cycles4Calculation; i++){
            //mySession[i] = new Array (3)
             mySession.unshift( {"time": 0, "typeName": "walk"});
            console.log("***** mySession=", mySession[0].time, mySession[1].time, mySession[2].time)
            // we are adding to the beginning of the array so the previous time is always in element 2 (if starting from 0)
            mySession.unshift( {"time": mySession[2].time - session.holdIncrement, "typeName": "hold"});
            mySession.unshift( {"time": session.breathTime, "typeName": "brth"});
            console.log("***** mySession=", mySession[0].time, mySession[1].time, mySession[2].time)
        }

        return mySession

    }

    EditableComponent {
        id:o2
        editableType: "O2"
        editableComponentMetaData: {
          "displayname" : "O2 Session"
        }
        defaultGroup: "Session"
        target:session
        properties: {
            "name": {label:"Session name"},
            "numberOfCycles": {"min": 1, "max": 8, "stepsize": 1, "label": "Number of cycles" },
            "repeatLast":{label:"Repeat Last Cycle"},
            "breathTime":{"min":0, "max":600, "stepsize": 5, "label": "Breath time"},
            "holdTime":{"min":0, "max":600, "stepsize": 5, "label": "Maximum hold time"},
            "holdIncrement":{"min":0, "max":120, "stepsize": 5, "label": "Hold time increment"}
        }
    }
    // Create a JSON array representing the current session
    // Do we need to make it robust, check for ranges, etc. ?
    function generateCO2Session (){
        var mySession = []
        sessionType = "CO2"

        var cycles4Calculation = session.repeatLast ? session.numberOfCycles -1 : session.numberOfCycles;
        mySession.unshift( {"time" : 0, "typeName" :"walk"});
        mySession.unshift( {"time" : session.holdTime, "typeName" :"hold"});
        mySession.unshift( {"time" : session.breathTime, "typeName" :"brth"});
        // copy the last group
        var currentSessionLength = mySession.length
        if (session.repeatLast){
            mySession.unshift( mySession[currentSessionLength -1]);
            mySession.unshift( mySession[currentSessionLength -2]);
            mySession.unshift( mySession[currentSessionLength -3]);
        }
        for (var i = 0; i < cycles4Calculation; i++){
            // we are adding to the beginning of the array so the previous time is always in element 2 (if starting from 0)
            mySession.unshift( {"time": 0, "typeName": "walk"});
            mySession.unshift( {"time": session.holdTime, "typeName": "hold"});
            mySession.unshift( {"time": mySession[2].time + session.breathDecrement, "typeName": "brth"});
        }

        return mySession

    }

    EditableComponent {
        id:co2
        editableType: "CO2"
        editableComponentMetaData: {
          "displayname" : "CO2 Session"
        }
        defaultGroup: "Session"

        target:session
        properties: {
            "name": {label:"Session name"},
            "numberOfCycles": {"min": 1, "max": 8, "stepsize": 1, "label": "Number of cycles" },
            "repeatLast":{label:"Repeat Last Cycle"},
            "breathTime":{"min":0, "max":600, "stepsize": 5, "label": "Minimum breath time"},
            "breathDecrement":{"min":0, "max":120, "stepsize": 5, "label": "Breath time decrement"},
            "holdTime":{"min":0, "max":600, "stepsize": 5, "label": "Hold time"},
        }

    }
    // Create a JSON array representing the current session
    // Do we need to make it robust, check for ranges, etc. ?
    function generateWalkSession (){
        var mySession = []
        sessionType = "WALK"

        for (var i = 0; i < session.numberOfCycles; i++){
            // we are adding to the beginning of the array so the previous time is always in element 2 (if starting from 0)
            mySession.unshift( {"time": session.walkTime, "typeName": "walk"});
            mySession.unshift( {"time": session.holdTime, "typeName": "hold"});
            mySession.unshift( {"time": session.walkTime, "typeName": "brth"});
        }
        return mySession
    }
    EditableComponent {
        id:walk
        editableType: "WALK"
        editableComponentMetaData: {
          "displayname" : "Walk Session"
        }
        defaultGroup: "Session"
        target:session
        properties: {
            "name": {label:"Session name"},
            "numberOfCycles": {"min": 1, "max": 8, "stepsize": 1, "label": "Number of cycles" },
            "breathTime":{"min":0, "max":600, "stepsize": 5, "label": "Breath time"},
            "holdTime":{"min":0, "max":600, "stepsize": 5, "label": "Hold time"},
            "walkTime":{"min":0, "max":300, "stepsize": 5, "label": "Walk time"},

        }
    }
    ItemEditor {
      id: itemEditor // important to set the id to ItemEditor!
      anchors.fill: parent
      //anchors.bottomMargin: buttonsRow.height

    }

    Row {
        id: buttonsRow
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 3

        MenuButton {
            text: "New Session"
            onClicked: levelEditor.createNewLevel()
        }

        MenuButton {
            text: "Remove Session"
            onClicked: {

                levelEditor.removeCurrentLevel()
            }
        }
        MenuButton {
            text: "Save Session"
            onClicked: {

                ///AWdebug
                if (itemEditor.currentEditableType == "CO2"){
                    configSeriesScene.currentSession = generateCO2Session()
                    console.log(" **** generated CO2 session=", currentSession)
               }
                else if (itemEditor.currentEditableType == "O2"){
                    configSeriesScene.currentSession = generateO2Session()
                    console.log(" **** generated O2 session=", currentSession)
                }
                else if (itemEditor.currentEditableType == "WALK"){
                    configSeriesScene.currentSession = generateWalkSession()
                    console.log(" **** generated O2 session=", currentSession)
                }
                runSessionScene.sessionSelected(currentSession)
                levelEditor.saveCurrentLevel( {levelMetaData: {levelName: session.name}} )
                levelEditor.saveCurrentLevel()
            }
        }

        MenuButton {
            text: "Show All Session"
            onClicked: {
                levelEditor.loadAllLevelsFromStorageLocation(levelEditor.authorGeneratedLevelsLocation)
                levelSelectionList.visible = true
            }
        }
    }

//    LevelSelectionList {
//          id: levelSelectionList
//          // at the beginning it is invisible, only gets visible after a click on the Levels button
//          visible: false
//          anchors.right: parent.right // position on the right

//          // this connects the stored levels from the player with the level list
//          levelMetaDataArray: levelEditor.authorGeneratedLevels

//          onLevelSelected: {
//            levelEditor.loadSingleLevel(levelData)
//            // make invisible afterwards
//            levelSelectionList.visible = false
//          }

//      }
  }// end of Scene
