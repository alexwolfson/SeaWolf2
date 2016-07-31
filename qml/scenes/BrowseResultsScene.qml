import QtQuick 2.6
import Qt.labs.folderlistmodel 2.1
import "../common"
SceneBase{
    id:browseScene
    property int chosenFileIndex:0
    property string chosenFile:""
//    function restoreSession(filePath) {
//        console.log("filePath = ", filePath, "Open=" , qfa.qmlOpenFile(filePath));
//        //console.log("Wrote = ", qfa.qmlWrite(JSON.stringify(runSessionScene.currentSession)));
//        var qstr = qfa.qmlRead();
//        console.log("Read = ", qstr);
//        tabView.runSessionScene.currentSession =
//                JSON.parse(qstr);
//         console.log("Close=", qfa.qmlCloseFile());
//        showSessionGraph(tabView.runSessionScene.currentSession,tabView.runSessionScene.chartView)

//        //var data = runSessionScene.currentSession
//        //io.text = JSON.stringify(data, null, 4)
//        //io.write()
//    }
    Item {
        Column {
            id:browseColumn
            spacing: dp(10)
            //padding: dp(10)
            ListView {
                //anchors.rightMargin: dp(20)
                id: folderListView
                width: browseScene.width;
                height: dp(400);
                FolderListModel {
                    id: folderModel
                    showHidden :true
                    folder:qfa.getAccessiblePath("sessions")
                    //                    folder: if (Qt.platform.os === "android"){
//                                return "file:///mnt/sdcard"
//                            } else {
//                                return "file://~"
//                            }

                    showDotAndDotDot:true
                }
                Component {
                    id: fileDelegate
                    Rectangle{
                        id: fileRect
                        width: browseScene.width
                        height: dp(40)
                        border.color: "black"
                        Text {
                            text: fileName
                            anchors.leftMargin: dp(20)
                            font.pixelSize: dp(30)
                            color:folderModel.isFolder(index)? "red":"black"

//                            onTextChanged: {
//                                console.log("fileindex=", index, "name=", fileName, "isFolder=",
//                                            folderModel.isFolder(index))
//                            }
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: if(folderModel.isFolder(index)) {
                                           folderModel.folder+=("/" + fileName)
                                       } else {
                                           chosenFileIndex = index
                                           chosenFile = fileName
                                           hrPlot.restoreSession(qfa.qmlToLocalFile(folderModel.folder + "/" + fileName))

                                       }
                            onPressed: { fileRect.border.color = "red"; fileRect.color = "lightblue"}
                            onReleased:{ fileRect.border.color = "black"; fileRect.color = "white"}
                        }
                    }
                }
                model: folderModel
                delegate: fileDelegate
            }
            SeaWolfPlot{
                id:hrPlot
            }

            Row{
                id:browseMenu
                height:dp(100)
                width:parent.width
                padding: dp(20)
                //anchors.topMargin: folderListView.height
                MenuButton{
                    id: note1
                    //width:parent.width/3
                    //height: parent.height/3
                    text: qsTr("Show Session")
                    onClicked: {
                        console.log("file=", chosenFile)
                        //currentSession.event.push([myEventsNm2Nb["EndOfMeditativeZone"], Math.round(currentGauge.value)])
                    }
                    enabled:true
                }
            }
        }
    }
}
