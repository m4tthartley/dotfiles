// ~/.config/quickshell/shell.qml
// Polybar-style top bar recreated for Quickshell (Hyprland workspaces + PipeWire volume).
// Needs a Nerd Font (for the icons) and JetBrains Mono (or change `fontFamily`).

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

ShellRoot {
    id: root

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 17

    // Text shown next to the workspaces (static, edit to taste)
    readonly property string leftLabel: "Europa"

    // ---------- Live data ----------
    property int cpuPercent: 0
    property real _prevTotal: 0
    property real _prevIdle: 0

    property int ramPercent: 0
    property real ramUsedGiB: 0

    PwObjectTracker { objects: [Pipewire.defaultAudioSink] }
    readonly property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -n1 /proc/stat"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split(/\s+/).slice(1).map(Number);
                const idle = p[3] + (p[4] || 0);
                const total = p.reduce((a, b) => a + b, 0);
                if (root._prevTotal > 0) {
                    const dt = total - root._prevTotal;
                    const di = idle - root._prevIdle;
                    root.cpuPercent = dt > 0 ? Math.round(100 * (dt - di) / dt) : 0;
                }
                root._prevTotal = total;
                root._prevIdle = idle;
            }
        }
    }

    Process {
        id: memProc
        command: ["sh", "-c", "grep -E '^(MemTotal|MemAvailable):' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                let total = 0, avail = 0;
                for (const line of text.trim().split("\n")) {
                    const m = line.match(/^(\w+):\s+(\d+)/);
                    if (!m) continue;
                    if (m[1] === "MemTotal") total = Number(m[2]);
                    else avail = Number(m[2]);
                }
                const used = total - avail;
                root.ramPercent = total > 0 ? Math.round(100 * used / total) : 0;
                root.ramUsedGiB = used / 1024 / 1024;
            }
        }
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { cpuProc.running = true; memProc.running = true; }
    }

    // ---------- Bar ----------
    PanelWindow {
        id: bar
        anchors { top: true; left: true; right: true }
        margins { top: 16; left: 16; right: 16 }
        implicitHeight: 30
        exclusiveZone: 30
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Colors.base
            radius: 5
            // clip: true
            // contentInsideBorder: true

            // Rectangle {
            //     id: maskShape
            //     anchors.fill: parent
            //     radius: 5
            //     layer.enabled: true
            //     visible: false
            // }

            // ----- Left: workspaces + label -----
            Row {
                id: left
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                height: bar.height
                spacing: 0

                Repeater {
                    // model: console.log(Hyprland.workspaces.values[0].urgent) || Hyprland.workspaces.values.length
                    model: 8
                    // model: Hyprland.workspaces

                    // delegate: Rectangle {
                    //     required property var modelData
                    //     visible: modelData.id > 0
                    //     width: visible ? 50 : 0
                    //     height: left.height
                    //     color: modelData.focused ? root.activeBg : "transparent"

                    //     Text {
                    //         anchors.centerIn: parent
                    //         text: modelData.name
                    //         color: modelData.focused ? root.activeFg : root.dim
                    //         font.family: root.fontFamily
                    //         font.pixelSize: root.fontSize
                    //     }
                    //     MouseArea {
                    //         anchors.fill: parent
                    //         onClicked: modelData.activate()
                    //     }
                    // }

                    Rectangle {
                        property var ws: Hyprland.workspaces.values.find(w => w.id == index+1)
                        property bool isActive: Hyprland.focusedWorkspace?.id == (index+1)
                        property bool isUrgent: ws?.urgent ? true : false

                        visible: ws?.active ? true : false
                        width: 50
                        height: bar.height
                        radius: 5
                        color: isActive ? Colors.primary : (isUrgent ? Colors.warning : Colors.base)

                        Text {
                            text: index+1
                            color: isActive ? Colors.base : Colors.primary
                            font { pixelSize: root.fontSize; family: root.fontFamily; bold: true }
                            anchors.centerIn: parent
                        }

                        // MouseArea {
                        //     anchors.fill: parent
                        //     onClicked: Hyprland.dispatch("workspace " + (index+1))
                        // }
                    }
                }

                Item { width: 20; height: 1 }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.leftLabel
                    color: Colors.text
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }
            }

            // ----- Right: modules -----
            Row {
                anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                spacing: 40

                // Volume + slider
                Row {
                    spacing: 10
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "\uf028  " + Math.round(root.volume * 100) + "%"
                        color: Colors.text
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                    }

                    Item {
                        id: slider
                        width: 250; height: 20
                        anchors.verticalCenter: parent.verticalCenter

                        // rail
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width; height: 2
                            color: Colors.text
                        }
                        // filled part
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width * Math.min(1, root.volume); height: 2
                            color: Colors.primary
                        }
                        // knob
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: parent.width * Math.min(1, root.volume) - width / 2
                            width: 2; height: 16
                            color: Colors.primary
                        }

                        MouseArea {
                            anchors.fill: parent
                            function setVol(mx) {
                                const a = Pipewire.defaultAudioSink?.audio;
                                if (a) a.volume = Math.max(0, Math.min(1, mx / width));
                            }
                            onPressed: mouse => setVol(mouse.x)
                            onPositionChanged: mouse => { if (pressed) setVol(mouse.x); }
                            onWheel: wheel => {
                                const a = Pipewire.defaultAudioSink?.audio;
                                if (a) a.volume = Math.max(0, Math.min(1, a.volume + (wheel.angleDelta.y > 0 ? 0.02 : -0.02)));
                            }
                        }
                    }
                }

                // CPU
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uf2db  CPU " + root.cpuPercent + "%"
                    color: Colors.text
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                // RAM
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uefc5  RAM (" + root.ramPercent + "%) " + root.ramUsedGiB.toFixed(2) + " GiB"
                    color: Colors.text
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }

                // Clock
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "\uf017  " + Qt.formatDateTime(clock.date, "ddd dd MMM HH:mm")
                    color: Colors.text
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                }
            }
        }
    }
}
