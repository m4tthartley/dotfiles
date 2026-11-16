// ~/.config/quickshell/Launcher.qml
// Rofi-style drun launcher. Toggle with:  quickshell ipc call launcher toggle
// Uses Colors.base / Colors.primary from your Colors singleton; the rest are local.

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    readonly property string prompt: "launch: "

    // ---------- State ----------
    property bool shown: false
    property string query: ""

    readonly property var allApps: DesktopEntries.applications.values
        .filter(a => !a.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))

    readonly property var results: {
        const q = query.toLowerCase();
        if (!q) return allApps;
        const hits = allApps.filter(a =>
            a.name.toLowerCase().includes(q) ||
            (a.genericName || "").toLowerCase().includes(q));
        hits.sort((a, b) => {
            const as = a.name.toLowerCase().startsWith(q);
            const bs = b.name.toLowerCase().startsWith(q);
            if (as !== bs) return as ? -1 : 1;
            return a.name.localeCompare(b.name);
        });
        return hits;
    }

    function esc(s) {
        return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    }

    // Underline + bold the part of the name that matches the query
    function highlight(name, q) {
        if (!q) return esc(name);
        const i = name.toLowerCase().indexOf(q.toLowerCase());
        if (i < 0) return esc(name);
        return esc(name.slice(0, i))
            + "<u><b>" + esc(name.slice(i, i + q.length)) + "</b></u>"
            + esc(name.slice(i + q.length));
    }

    function launch(entry) {
        entry.execute();
        root.shown = false;
    }

    // ---------- IPC: quickshell ipc call launcher toggle ----------
    IpcHandler {
        target: "launcher"
        function toggle(): void { root.shown = !root.shown }
        function open(): void   { root.shown = true }
        function close(): void  { root.shown = false }
    }

    // ---------- Window ----------
    PanelWindow {
        id: win
        visible: root.shown

        // open on whichever monitor is focused
        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)
                ?? Quickshell.screens[0]

        implicitWidth: 720
        implicitHeight: 480
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        // close when clicking outside
        HyprlandFocusGrab {
            windows: [win]
            active: root.shown
            onCleared: root.shown = false
        }

        onVisibleChanged: {
            if (visible) {
                input.text = "";
                list.currentIndex = 0;
                Qt.callLater(() => input.forceActiveFocus());
            }
        }

        Rectangle {
            id: frame
            anchors.fill: parent
            color: Colors.base
            radius: 5
            border.width: 2
            border.color: Colors.primary

            // WrapperRectangle {
            //     anchors.fill: parent
            //     border.width: 2
            //     border.color: Colors.primary

                // ----- Input row -----
                Rectangle {
                    id: inputRow
                    anchors {
                        top: parent.top; left: parent.left; right: parent.right
                        margins: frame.border.width
                    }
                    height: 62
                    color: Colors.baseDark
                    radius: 5

                    Row {
                        anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }

                        Text {
                            text: root.prompt
                            color: Colors.text
                            font.family: Colors.font
                            font.pixelSize: Colors.fontSize
                        }

                        TextInput {
                            id: input
                            width: 800
                            color: Colors.text
                            font.family: Colors.font
                            font.pixelSize: Colors.fontSize
                            cursorDelegate: Rectangle { width: 2; color: Colors.text }
                            selectionColor: Colors.primary
                            selectedTextColor: Colors.base

                            onTextChanged: {
                                root.query = text;
                                list.currentIndex = 0;
                            }

                            Keys.onPressed: event => {
                                const ctrl = event.modifiers & Qt.ControlModifier;
                                if (event.key === Qt.Key_Escape) {
                                    root.shown = false;
                                } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab
                                        || (ctrl && (event.key === Qt.Key_J || event.key === Qt.Key_N))) {
                                    list.currentIndex = Math.min(list.currentIndex + 1, list.count - 1);
                                } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab
                                        || (ctrl && (event.key === Qt.Key_K || event.key === Qt.Key_P))) {
                                    list.currentIndex = Math.max(list.currentIndex - 1, 0);
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    if (list.count > 0) root.launch(root.results[list.currentIndex]);
                                } else {
                                    return;
                                }
                                event.accepted = true;
                            }
                        }
                    }

                    // match count, e.g. 2/114
                    Text {
                        anchors { right: parent.right; rightMargin: 30; verticalCenter: parent.verticalCenter }
                        text: root.results.length + "/" + root.allApps.length
                        color: Colors.textAlt
                        font.family: Colors.font
                        font.pixelSize: Colors.fontSize - 1
                    }
                }

                // ----- Results -----
                ListView {
                    id: list
                    anchors { top: inputRow.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
                    clip: true
                    model: root.results
                    boundsBehavior: Flickable.StopAtBounds
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                    // ScrollBar.vertical: ScrollBar {
                    //     policy: ScrollBar.AsNeeded
                    //     contentItem: Rectangle { implicitWidth: 8; color: Colors.primary }
                    //     background: Item {}
                    // }

                    delegate: Rectangle {
                        id: row
                        required property var modelData
                        required property int index
                        readonly property bool selected: ListView.isCurrentItem

                        width: list.width
                        height: 42
                        color: selected ? Colors.primary : "transparent"

                        Row {
                            anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                            spacing: 10

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                textFormat: Text.StyledText
                                text: root.highlight(row.modelData.name, root.query)
                                color: row.selected ? Colors.base : Colors.text
                                font.family: Colors.font
                                font.pixelSize: Colors.fontSize - 1
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: text !== ""
                                text: row.modelData.genericName ? "(" + row.modelData.genericName + ")" : ""
                                color: row.selected ? Colors.base : Colors.textAlt
                                font.family: Colors.font
                                font.pixelSize: Colors.fontSize - 4
                                font.italic: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onPositionChanged: list.currentIndex = row.index
                            onClicked: root.launch(row.modelData)
                        }
                    }
                }
            // }
        }
    }
}
