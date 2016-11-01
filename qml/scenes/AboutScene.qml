//import VPlay 2.0
import QtQuick 2.7
import QtQuick.Controls 2.0
import "../common"
SceneBase{
    id: aboutScene

    Flickable{
        id: aboutText
        anchors.fill: parent
        anchors.margins: dp(20)

        TextArea.flickable: TextArea {
            textFormat: Text.RichText
            wrapMode: TextArea.Wrap
            readOnly: true
            onLinkActivated: Qt.openUrlExternally(link)

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            text: qsTr('
                   <p><b>About the application</b><br/></p>
                This project is created to provide <br>
                 an open source appliation for
                the different aspects of Apnea training.
                <br>Qt/QML 5.7+ is used as a developmet toolkit.<br>
                I used this app as a way to become proficient with
                 QML/Qt development.
                 <br >The source code is located at <br>
                 <a href=\"https://github.com/alexwolfson/SeaWolf2/tree/TabVersion"> GitHub</a><br>

                <p><b> Apnea influences </b></p>
                   <span class="auto-style3">
                <br><br>
                <i>Nick Fazah</i>
                <br><br>One of the owners of the<br>
                <br><a href=\"http://www.ecdivers.com\">East Cost divers</a><br>
                <br>and SSI international training director.<br>
                Nick was able to create an active  freediving comunity
                in New England (USA) which is located very far
                from the tropical waters <br>
                <br><i>Aharon Solomons</i>
                <br><br>From<br>
                <br><a href=\"http://freedivers.net">freedivers.net</a> <br>
                <br>with whom I trained for several days in Eilat
                and whos concepts of Apnea walk
                and empty longs training inspired me
                to start that application<br><br>
                <i>Alexander Bubenchikov</i>
                <br>
                <br><a href=\"https://www.facebook.com/a.bubenchikov">See his facebook page</a><br>
                <br> His seminar in Massachusetts USA explained to me the root of some of problems I had with statics.
                 As a result I added ability to record discomfort level to the app
            ')
        }
        ScrollBar.vertical: ScrollBar { }
    }
}
