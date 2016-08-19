import QtQuick 2.6
import Qt.labs.folderlistmodel 2.1
import "../common"
SceneBase{
    id:browseScene
    property int chosenFileIndex:0
    property string chosenFile:""
    Item {
        Column {
            id:browseColumn
            spacing: dp(10)
            //padding: dp(10)
            ListView {
                //anchors.rightMargin: dp(20)
                id: folderListView
                width: browseScene.width;
                height: dp(500);
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
                                           hrPlot.restoreSession(qfa.urlToLocalFile(folderModel.folder + "/" + fileName))

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
                height: browseScene.height/2
            }

            Row{
                id:browseMenu
                height:dp(100)
                width:parent.width
                padding: dp(20)
                //anchors.topMargin: folderListView.height
                MenuButton{
                    id: show
                    text: qsTr("Show Session")
                    onClicked: {
                        console.log("chosen=", chosenFile)
                    }
                    enabled:true
                }
                MenuButton{
                    id: rm
                    text: qsTr("Remove File")
                    onClicked: {
                        console.log("delete=", chosenFile)
                        console.log(qfa.removeFile(qfa.urlToLocalFile(folderModel.folder + "/" + chosenFile)))
                    }
                    enabled:true
                }
            }
        }
    }
}
