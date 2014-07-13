import QtQuick 2.2

Rectangle {
    width: 350; height: 400

    property var messages: null

    Item {
        anchors.fill: parent
        ListView {
            id: messageList
            anchors { top: parent.top; bottom: messageField.top }
            model: messages
            delegate: Text {
                text: modelData.body
            }
        }

        Rectangle {
            id: messageField
            border.width: 1
            height: messageInput.implicitHeight
            width: parent.width
            anchors.bottom: parent.bottom
            TextInput {
                id: messageInput
                focus: true
                anchors.fill: parent
                onAccepted: {
                    console.log(messageInput.text)
                    var doc = new XMLHttpRequest();
                    doc.onreadystatechange = function() {
                        if (doc.readyState == XMLHttpRequest.DONE) {
                            console.log(doc.responseText);
                        }
                    }

                    doc.open("POST", "http://localhost:3000/api/send");
                    doc.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
                    doc.send(JSON.stringify({ to: "johannes@nebulon.de", message: messageInput.text}));
                }
            }
        }

    }
    function fetchMessages() {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                console.log(doc.responseText);
                messages  = JSON.parse(doc.responseText).messages;
                pollTimer.start()
            }
        }

        doc.open("GET", "http://localhost:3000/api/messages");
        doc.send();
    }
    Timer {
        id: pollTimer
        running: true
        repeat: false
        interval: 1000
        onTriggered: fetchMessages()
    }
}
