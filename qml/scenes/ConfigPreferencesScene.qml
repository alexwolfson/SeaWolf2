//import VPlay 2.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import "../common"

SceneBase {
    id: configPreferencesScene
    //===================================================
    // Show a triangle by pure QML

    Item {
        id : component
        width: 100
        height: 100
        clip : true

        // The index of corner for the triangle to be attached
        property int corner : 0;
        //property alias color : rect.color

        Canvas {
                id: root
                // canvas size
                width: 200; height: 200
                // handler to override for drawing
                onPaint: {
                    // get context to draw with
                    var ctx = getContext("2d")
                    // setup the stroke
                    ctx.lineWidth = 4
                    ctx.strokeStyle = "blue"
                    // setup the fill
                    ctx.fillStyle = "steelblue"
                    // begin a new path to draw
                    ctx.beginPath()
                    // top-left start point
                    ctx.moveTo(50,50)
                    // upper line
                    ctx.lineTo(150,50)
                    // right line
                    ctx.lineTo(150,150)
                    // bottom line
                    ctx.lineTo(50,150)
                    // left line through path closing
                    ctx.closePath()
                    // fill using fill style
                    ctx.fill()
                    // stroke using line width and stroke style
                    ctx.stroke()
                }
            }
//    property string userName
//    property  bool music
//    property  bool useGauge
//    property  bool oneMinSignal
//    property  bool thirtySecSignal
//    property  bool tenSecSignal
//    property  var  language
//    // had trouble with multidimension arrays in javascript function, so stated to use 1 dimension
//    function get2DimIndex(dim0, dim1){
//        return 3 * dim0 + dim1
//    }
//    // Create a JSON array representing the current session
//    // Do we need to make it robust, check for ranges, etc. ?

//    Item{
//        id: propertyies
//        width: root.width
//        height: root.height
//        visible:true
//        anchors.leftMargin: dp(20)
//        //flags: Qt.Dialog
//        //modality: Qt.ApplicationModal

//        ColumnLayout {
//            //z:100
//            id: mainLayout
//            //columns: 2
//            spacing: dp(30)
//            //columnSpacing: 5
//            anchors {
//                top: parent.top;
//                left: parent.left
//                right: parent.right
//                leftMargin: dp(20)
//                topMargin: dp(20)
//            }
//            Text{
//                color: "darkred"
//                text: qsTr("THIS PAGE IS NOT IMPLEMENTED")
//                font.pixelSize: dp(40)
//            }

//            RowLayout {
//                id: buttonsRow
//                //                anchors.bottom: parent.bottom
//                //                anchors.left: parent.left
//                //                anchors.right: parent.right
//                spacing: dp(3)

//                MenuButton {
//                    text: qsTr("Choose User")
//                    onClicked: {
//                    }
//                }

//                MenuButton {
//                    text: qsTr("New User")
//                    onClicked: {
//                    }
//                }
//                MenuButton {
//                    text: qsTr("Select")
//                    onClicked: {
//                        //AWDEBUG
//                        root.listPropertiesByName("ConfigSeriesScene attached properites list", configPreferencesScene, ["userName", "music", "oneMinSignal", "thirtySecSignal",
//                                                                                                                         "tenSecSignal", "language"])
//                        //console.log("minBreathTime =", minBreathTime, configSeriesScene["minBreathTime"], this["configSeriesScene"])

//                        //root.listProperty(this)
//                        //console.log(JSON.stringify(configSeriesScene))
//                    }
//                }
//            }

//            SeaWolfInput{ type:"str";   lbl: qsTr("userName");    sfv:"";        onResult: {userName=res}}
//            SeaWolfInput{ id: backgroundMusic;  type:"switch";lbl: qsTr("backgroundMusic");         onResult: {music=swYesNo}}
//            SeaWolfInput{ id: gaugeSliders;  type:"switch";lbl: qsTr("gaugeOrSliders");         onResult: {useGauge=swYesNo}}
//            SeaWolfInput{ id: timer10;  type:"switch";lbl: qsTr("tenSecTimer");         onResult: {tenSecSignal=swYesNo}}
//            SeaWolfInput{ id: timer30;  type:"switch";lbl: qsTr("thirtySecTimer");      onResult: {thirtySecSignal=swYesNo}}
//            SeaWolfInput{ id: timer1min; type:"switch";lbl: qsTr("oneMinTimer");        onResult: {oneMinSignal=swYesNo}}
//            Image {
//                source: "../../assets/img/SeaWolf.png"
//                //anchors.horizontalCenter: parent.horizontalCenter
//                anchors.bottom: parent.bottom
//                anchors.right: parent.right
//                width: dp(150)
//                height:width
//            }
//        }
    }

}// end of Scene
