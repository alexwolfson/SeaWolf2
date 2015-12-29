import VPlay 2.0
import QtQuick 2.0
import "../common"

//GameWindow {
//    visible: true
//    landscape:false

//  EntityManager {
//    id: entityManager
//    entityContainer: configSeriesScene

//    // required for LevelEditor, so the entities can be created by entityType
//    dynamicCreationEntityList: [ Qt.resolvedUrl("qml/ConfgSeries.qml") ]

//  }


  SceneBase {
    id: configSeriesScene
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
        property int breathDecriment:0
        property int walkTime:120
/*
        property type name: value
        name: valueLabel { text: "sessionName" }
            TextField { id: sessionName; }
            Label { text: "numberOfCycles"}
            TextField { id: numberOfCycles}
            Label { text: "repeatLast"}
            Switch {checked:false}
            Label { text: "maxHoldTime"}
            TextField { id: maxHoldTime}
            Label { text: "holdIncrement"}
            TextField { id: holdIncrement}
            Label { text: "minBtratheTime"}
            TextField { id: minBtratheTime}
            Label { text: "breathDecrement"}
            TextField { id: breathDecrement}
*/
    }
    LevelEditor {
      id: levelEditor
      anchors.fill: parent
      applicationJSONLevelsDirectory: "JSONSessions/"
      toRemoveEntityTypes: [ "platform", "platformGoal", "stars", "obstacle" ]
      toStoreEntityTypes: [ "platform", "platformGoal", "stars", "obstacle" ]
      Component.onCompleted: {
          loadAllLevelsFromStorageLocation(applicationJSONLevelsLocation)
      }
    }


    EditableComponent {
        editableType: "O2"
        defaultGroup: "Session"
        target:session
        properties: {
            "name": {label:"Session name"},
            "numberOfCycles": {"min": 1, "max": 8, "step": 1, "label": "Number of cycles" },
            "repeatLast":{label:"Repeat Last Cycle"},
            "holdTime":{"min":0, "max":600, "step": 5, "label": "Maximum hold time"}
        }
    }
    EditableComponent {
        editableType: "CO2"
        defaultGroup: "Session"
        target:session
        properties: {
            "name": {label:"Session name"},
            "numberOfCycles": {"min": 1, "max": 8, "step": 1, "label": "Number of cycles" },
            "repeatLast":{label:"Repeat Last Cycle"},
            "breathTime":{"min":0, "max":600, "step": 5, "label": "Minimum breath time"}
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
      anchors.bottomMargin: buttonsRow.height
    }

    Row {
        id: buttonsRow
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 3

        SimpleButton {
            text: "New Session"
            onClicked: levelEditor.createNewLevel()
        }

        SimpleButton {
            text: "Save Session"
            onClicked: levelEditor.saveCurrentLevel()
        }

        SimpleButton {
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
