pragma Singleton
import QtQuick
import Quickshell

Singleton {
	// Original colors
	// readonly property color bar: background
	// readonly property color background: "#1e1e2e"
	// readonly property color panel: "#11111b"
	// readonly property color primary: "#89b4fa"
	// readonly property color warning: "#fab387"
	// readonly property color text: "#cdd6f4"
	// readonly property color textSecondary: "#585b70"
	// readonly property color textInverted: background

	// Greyscale colors
	// readonly property color bar: background
	// readonly property color background: "#2e2e2e"
	// readonly property color panel: "#1a1a1a"
	// readonly property color primary: "#fafafa"
	// readonly property color warning: "#fab387"
	// readonly property color text: "#f2f2f2"
	// readonly property color textSecondary: "#6e6e6e"
	// readonly property color textInverted: background

	// Green colors
	readonly property color bar: "#080B05"
	readonly property color background: "#0D1108"
	readonly property color panel: "#161D0F"
	readonly property color primary: "#9DFF2E"
	readonly property color warning: "#FFB020"
	readonly property color text: primary
	readonly property color textSecondary: "#8A9E6E"
	readonly property color textInverted: background

	// Other constants
	// INFO: These should be in another file, not the Colors one,
	// but for the life of me I cannot get another Singleton to work
	readonly property string font: "JetBrainsMono Nerd Font"
	readonly property int fontSize: 15
}