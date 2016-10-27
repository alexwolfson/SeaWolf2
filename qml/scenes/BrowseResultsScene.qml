import QtQuick 2.7
import Qt.labs.folderlistmodel 2.1
import QtQuick.Layouts 1.3
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
                        height: dp(60)
                        border.color: "black"
                        Text {
                            text: fileIsDir ? fileName : fileName + "(" + fileSize + ")"
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

            RowLayout{
                id:browseMenu
                height:dp(100)
                width:parent.width
                Layout.alignment: Qt.AlignCenter
                //padding: dp(20)
                //anchors.bottom: browseScene.bottom
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
