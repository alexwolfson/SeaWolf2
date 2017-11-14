import QtQuick 2.7
import Qt.labs.folderlistmodel 2.1
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

import "../common"
SceneBase{
    id:presetSessionsScene
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
                width: presetSessionsScene.width;
                height: dp(500);
                FolderListModel {
                    id: folderModel
                    showHidden :true
                    folder:  "file://" +  qfa.getAccessiblePath("sessionTypes")
                    showDotAndDotDot:true
                    nameFilters: ["*.json"]
//                    onFolderChanged: {
//                        if ((folderModel.count == 0) && (browseMode == false)){
//                            messageDialog.open()
//                        }
//                    }
                }
                Component {
                    id: fileDelegate
                    Rectangle{
                        id: fileRect
                        width: presetSessionsScene.width
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
//            SeaWolfPlot{
//                id:hrPlot
//                height: browseScene.height/2
//            }

            RowLayout{
                id:browseSceneMenu
                height:dp(100)
                width:parent.width
                Layout.alignment: Qt.AlignCenter
                MenuButton {
                    id:browseSession
                    text: qsTr("Browse")
                    onClicked: {
                        folderModel.folder = "file://" +  qfa.getAccessiblePath("sessionTypes")
                    }
                    enabled: true
                }
                MenuButton {
                    id:importSession
                    text: qsTr("Import Session")
                    onClicked: {
                        folderModel.folder = "file://" +  qfa.getExportablePath()
                    }
                    enabled: true
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
