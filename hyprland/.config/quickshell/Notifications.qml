import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Notifications

Scope {
    NotificationServer {
        id: server
        keepOnReload: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true
        onNotification: n => n.tracked = true   // keep it alive so we can show it
    }

    PanelWindow {
        visible: server.trackedNotifications.values.length > 0
        anchors { top: true; right: true }
        margins { top: 78; right: 32 }          // just below your bar
        implicitWidth: 380
        implicitHeight: col.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay

        Column {
            id: col
            width: parent.width
            spacing: 8

            Repeater {
                model: server.trackedNotifications

                delegate: Rectangle {
                    id: card
                    required property var modelData   // the Notification
                    readonly property bool critical:
                        modelData.urgency === NotificationUrgency.Critical

                    width: col.width
                    height: content.implicitHeight + 24
                    color: Colors.background
                    border.width: 2
                    border.color: critical ? Colors.warning : Colors.primary

                    // click anywhere to dismiss
                    MouseArea {
                        anchors.fill: parent
                        onClicked: card.modelData.dismiss()
                    }

                    // auto-expire (the server doesn't do this for you)
                    Timer {
                        running: !card.critical
                        interval: card.modelData.expireTimeout > 0
                                  ? card.modelData.expireTimeout * 1000 : 5000
                        onTriggered: card.modelData.expire()
                    }

                    Row {
                        id: content
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                        spacing: 12

                        IconImage {
                            implicitSize: 40
                            visible: source != ""
                            source: card.modelData.image
                                    || Quickshell.iconPath(card.modelData.appIcon, "dialog-information")
                        }

                        Column {
                            width: parent.width - 52
                            spacing: 4

                            Text {
                                width: parent.width
                                text: card.modelData.summary
                                color: Colors.text
                                font { family: Colors.font; pixelSize: Colors.fontSize; bold: true }
                                elide: Text.ElideRight
                            }
                            Text {
                                width: parent.width
                                visible: text !== ""
                                text: card.modelData.body
                                textFormat: Text.StyledText
                                wrapMode: Text.Wrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                                color: Colors.text
                                font { family: Colors.font; pixelSize: Colors.fontSize - 3 }
                            }
                            Row {
                                spacing: 12
                                Repeater {
                                    model: card.modelData.actions
                                    Text {
                                        required property var modelData
                                        text: "[" + modelData.text + "]"
                                        color: Colors.primary
                                        font { family: Colors.font; pixelSize: Colors.fontSize - 3 }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: parent.modelData.invoke()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}