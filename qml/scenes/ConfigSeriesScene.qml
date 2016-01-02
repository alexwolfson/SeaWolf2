import VPlay 2.0
import QtQuick 2.0
import "../common"



  SceneBase {
    id: configSeriesScene
    property var currentSession

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
        property int holdTime:30
        property int holdIncrement:0
        property int breathTime:0
        property int breathDecrement:0
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
    // had trouble with multidimension arrays in javascript function, so stated to use 1 dimension
    function get2DimIndex(dim0, dim1){
        return 3 * dim0 + dim1
    }
    EditableComponent {
        id:o2
        editableType: "O2"
        defaultGroup: "Session"
        target:session
        properties: {
            "name": {label:"Session name"},
            "numberOfCycles": {"min": 1, "max": 8, "step": 1, "label": "Number of cycles" },
            "repeatLast":{label:"Repeat Last Cycle"},
            "holdTime":{"min":0, "max":600, "step": 5, "label": "Maximum hold time"},
            "holdIncrement":{"min":0, "max":120, "step": 5, "label": "Hold time increment"}
        }
    }
    // Create a JSON array representing the current session
    // Do we need to make it robust, check for ranges, etc. ?
    function generateCO2Session (){
        var mySession = []


        var cycles4Calculation = session.repeatLast ? session.numberOfCycles -1 : session.numberOfCycles;
        mySession.unshift( {"time" : 0, "typeName" :"walk"});
        mySession.unshift( {"time" : session.holdTime, "typeName" :"hold"});
        mySession.unshift( {"time" : session.breathTime, "typeName" :"brth"});
        // copy the last group
        if (session.repeatLast){
            mySession.unshift( mySession[mySession.length -1]);
            mySession.unshift( mySession[mySession.length -2]);
            mySession.unshift( mySession[mySession.length -3]);
        }
        for (var i = 0; i < cycles4Calculation - 1; i++){
            //mySession[i] = new Array (3)
            mySession.unshift( {"time": 0, "typeName": "walk"});
            mySession.unshift( {"time": session.holdTime, "typeName": "hold"});
            // we are adding to the beginning of the array so the previous time is always in element 3
            mySession.unshift( {"time": mySession[2].time + session.breathDecrement, "typeName": "brth"});
        }

        return mySession

    }

    EditableComponent {
        id:co2
        editableType: "CO2"
        defaultGroup: "Session"
        target:session
        properties: {
            "name": {label:"Session name"},
            "numberOfCycles": {"min": 1, "max": 8, "step": 1, "label": "Number of cycles" },
            "repeatLast":{label:"Repeat Last Cycle"},
            "breathTime":{"min":0, "max":600, "step": 5, "label": "Minimum breath time"},
            "breathDecrement":{"min":0, "max":120, "step": 5, "label": "Breath time decrement"},
            "holdTime":{"min":0, "max":600, "step": 5, "label": "Hold time"},
        }

    }
    EditableComponent {
        editableType: "Apnea Walk"
        defaultGroup: "Session"
        target:session
        properties: {
            "name": {label:"Session name"},
            "numberOfCycles": {"min": 1, "max": 8, "step": 1, "label": "Number of cycles" },
            "repeatLast":{label:"Repeat Last Cycle"},
            "breathTime":{"min":0, "max":600, "step": 5, "label": "Minimum breath time"}
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
            text: "Save Session"
            onClicked: {

                ///AWdebug
                currentSession = generateCO2Session()
                console.log(" **** generated CO2 session=", currentSession)
                runSessionScene.sessionSelected(currentSession)

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

    LevelSelectionList {
          id: levelSelectionList
          // at the beginning it is invisible, only gets visible after a click on the Levels button
          visible: false
          anchors.right: parent.right // position on the right

          // this connects the stored levels from the player with the level list
          levelMetaDataArray: levelEditor.authorGeneratedLevels

          onLevelSelected: {
            levelEditor.loadSingleLevel(levelData)
            // make invisible afterwards
            levelSelectionList.visible = false
          }

      }
  }// end of Scene
