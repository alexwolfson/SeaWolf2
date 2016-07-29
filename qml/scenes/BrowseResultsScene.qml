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
            ListView {
                //anchors.rightMargin: dp(20)
                id: folderListView
                width: browseScene.width;
                height: dp(400);
                FolderListModel {
                    id: folderModel
                    folder: if (Qt.platform.os === "android"){
                                return "file:///mnt/sdcard"
                            } else {
                                return "file://~"
                            }

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

                            onTextChanged: {
                                console.log("fileindex=", index, "name=", fileName, "isFolder=",
                                            folderModel.isFolder(index))
                            }
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: if(folderModel.isFolder(index)) {
                                           folderModel.folder+=("/" + fileName)
                                       } else {
                                           chosenFileIndex = index
                                           chosenFile = fileName
                                       }
                        }
                    }
                }
                model: folderModel
                delegate: fileDelegate
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
