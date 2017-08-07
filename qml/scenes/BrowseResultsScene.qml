import QtQuick 2.7
import Qt.labs.folderlistmodel 2.1
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

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
//            MessageDialog {
//                id: messageDialog
//                title: "May I have your attention please"
//                text: "There are no session files in the " + qfa.getExportablePath() + "directory \n Switch to browse mode?"
//                onAccepted: {
//                    browseMode = true
//                }
//                Component.onCompleted: visible = true
//            }
            ListView {
                //anchors.rightMargin: dp(20)
                id: folderListView
                width: browseScene.width;
                height: dp(500);
                FolderListModel {
                    id: folderModel
                    showHidden :true
                    folder:  "file://" +  qfa.getAccessiblePath("sessions")
//                    {
//                        var f = "file://" +  browseMode ? qfa.getAccessiblePath("sessions"): qfa.getExportablePath()
//                        console.log("folder = ", f)
//                        return f
//                    }
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
                //                MenuButton{
                //                    id: show
                //                    text: qsTr("Email Session")
                //                    onClicked: {
                //                        console.log("chosen=", chosenFile)
                //                    }
                //                    enabled:true
                //                }
                MenuButton {
                    id:browseSession
                    text: qsTr("Browse")
                    onClicked: {
                        folderModel.folder = "file://" +  qfa.getAccessiblePath("sessions")
                    }
                    enabled: true
                }
                MenuButton {
                    id:emailSession
                    text: qsTr("Email Session")
                    onClicked: {
                        // ALl this mess is needed for Android, because it prevents access to almost any loaction
                        //var attachURL = folderModel.folder + "/" + chosenFile
                        var localFile = qfa.urlToLocalFile(folderModel.folder + "/" + chosenFile)
                        var exportablePath = qfa.getExportablePath();
                        var attachURL = exportablePath + chosenFile;
                        var cpRes = qfa.copyFile(localFile, attachURL);
                        Qt.openUrlExternally("mailto:alexwolfson@gmail.com" +
                                             "?subject=FreedivingSession" +
                                             "&attach=" + attachURL +
                                             "&body=This is a session, that I want you to look at")
                        console.log("localFile=", localFile, "cpRes=", cpRes, "Attachment=", attachURL)
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
