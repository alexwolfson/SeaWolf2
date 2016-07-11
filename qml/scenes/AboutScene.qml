//import VPlay 2.0
import QtQuick 2.5
import QtQuick.Controls 1.4
import "../common"
SceneBase{
    id: aboutScene

    Item{
        id: aboutText
        anchors.fill: parent
        anchors.topMargin:25 //TODO generalize

        Text {

            textFormat: Text.RichText
            onLinkActivated: Qt.openUrlExternally(link)

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            text: '
                   <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"

                  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
                  <html >

                  <head>
                  <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
                  <title>Untitled 1</title>
                  <style type="text/css">
                   .auto-style2 {
                   font-family: "Times New Roman", Times, serif;
                   font-size: small;
                   }
                   .auto-style3 {
                   background-color: #FFFF00;
                   }
                  </style>
                  </head>

                  <body>
                   <p><b>About The application</b><br/></p>
                   <span class="auto-style3">
                This project is created to provide <br>
                 an open source appliation<br> for
                the different aspects of Apnea training.
                <br>Qt/QML 5.5+ is used as a developmet toolkit.<br>
                I used this app as a way to become proficient with<br>
                 QML/Qt development
                <p><b> Apnea influences </b></p>
                   <span class="auto-style3">
                <i>Nick Fazah</i> <br>One of the owners of the
                <br><a href=\"http://www.ecdivers.com\">East Cost divers</a><br>
                and SSI international training director
                Nick was able to create a freediving comunity in New England (USA)<br>
                   which is located very far from the tropical waters <br>
                <br><i>Aharon Solomons</i>
                <br><a href=\"http://freedivers.net">freedivers.net</a> <br>
                with whom I trained for several days in Eilat<br>
                and whos concepts of Apnea walk <br>and empty longs training inspired me <br>
                to start that application
                   </span>
                   <hr />
                  </body>
                  </html>
            '
            //+ "See the <a href=\"http://qt-project.org\">Qt Project website</a>."
            //onLinkActivated: console.log(link + " link activated")
        }
    }
}
