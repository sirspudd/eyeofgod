import QtQuick 2.2

Rectangle {
    id: root
    width: 350; height: 400

    ListModel {
        id: messageModel
        onCountChanged: messageList.positionViewAtEnd()
    }

    ListView {
        id: messageList
        anchors { top: parent.top; bottom: messageField.top; left: parent.left; right: parent.right }
        model: messageModel
        delegate: Text {
            text: model.body
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
                var doc = new XMLHttpRequest();
                doc.onreadystatechange = function() {
                    if (doc.readyState == XMLHttpRequest.DONE) {
                        console.log(doc.responseText);
                        messageInput.text = '';
                    }
                }

                doc.open("POST", "http://localhost:3000/api/send");
                doc.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
                doc.send(JSON.stringify({ to: "johannes@nebulon.de", message: messageInput.text}));
            }
        }

    }
    function fetchMessages() {
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function() {
            if (doc.readyState == XMLHttpRequest.DONE) {
                var messages  = JSON.parse(doc.responseText).messages;
                messages.forEach(function(neu) {
                    var found = false;
                    for (var i = 0; i < messageModel.count; ++i) {
                        if (messageModel.get(i).seqno === neu.seqno) {
                            found = true;
                            break;
                        }
                    }

                    if (!found) messageModel.append(neu);
                });
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
        interval: 500
        onTriggered: fetchMessages()
    }
}

