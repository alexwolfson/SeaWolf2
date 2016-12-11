import QtQuick 2.7
//import QtGraphicalEffects 1.0


//import VPlay 2.0
Item {
    id: button
    // this will be the default size, it is same size as the contained text + some padding
    width: buttonText.width + paddingHorizontal * 2
    height: buttonText.height + paddingVertical * 2

    //color: "black" //mouseArea.pressed ? "red" : "orange" //"#3265A7" : "#3870BA"
    ////border.color: "#bdbebf"
    //border.color: "#F0EBED"
    ////border.width: dp(5)
    //radius: 10
    //color: "#e9e9e9"
    //border.color: "black"
    opacity: 1.0 //0.6
    // round edges
    //radius: Math.min(width, height)/2 //dp(20)

    // the horizontal margin from the Text element to the Rectangle at both the left and the right side.
    property int paddingHorizontal: dp(20)
    // the vertical margin from the Text element to the Rectangle at both the top and the bottom side.
    property int paddingVertical: dp(20)

    // access the text of the Text component
    property alias text: buttonText.text

    // this signal is emitted when the button is clicked.
    signal clicked
    Image {
        id: bubble
        width:  parent.width
        height: parent.height
        source: "../../assets/img/bubble.png"
    }

    Text {
        id: buttonText
        anchors.centerIn: parent
        font.pixelSize: dp (50)
        elide: Text.ElideMiddle
        //color: "#F0EBED"
        color: "black" //"white"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: button.clicked()
        onPressed: button.opacity =  0.8
        onReleased: button.opacity = 1.0
    }
//    DropShadow {
//        anchors.fill: button
//        horizontalOffset: 3
//        verticalOffset: 3
//        radius: 8.0
//        //samples: 17
//        color: "#80000000"
//        source: button
//    }

}
