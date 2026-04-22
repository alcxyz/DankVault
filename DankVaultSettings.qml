import QtQuick
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "dankVault"

    StyledText {
        width: parent.width
        text: I18n.tr("Vault Settings")
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: I18n.tr("Search and copy credentials from your password vault")
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    StyledRect {
        width: parent.width
        height: settingsColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: settingsColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
                text: I18n.tr("Backend")
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            SelectionSetting {
                settingKey: "backend"
                label: I18n.tr("Password Manager")
                description: I18n.tr("Auto detects the first available backend")
                options: [
                    { value: "auto", label: "Auto-detect" },
                    { value: "rbw", label: "rbw (Bitwarden)" },
                    { value: "pass", label: "pass" },
                    { value: "gopass", label: "gopass" },
                    { value: "op", label: "1Password CLI" }
                ]
                defaultValue: "auto"
            }

            StyledText {
                text: I18n.tr("Activation")
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            StringSetting {
                settingKey: "trigger"
                label: I18n.tr("Trigger Prefix")
                description: I18n.tr("Type this prefix to search your vault")
                placeholder: "@"
                defaultValue: "@"
            }

            SelectionSetting {
                settingKey: "defaultAction"
                label: I18n.tr("Default Action")
                description: I18n.tr("What to copy when selecting an entry")
                options: [
                    { value: "password", label: "Password" },
                    { value: "username", label: "Username" },
                    { value: "totp", label: "TOTP Code" }
                ]
                defaultValue: "password"
            }
        }
    }

    StyledRect {
        width: parent.width
        height: infoColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surface

        Column {
            id: infoColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            Row {
                spacing: Theme.spacingM

                DankIcon {
                    name: "info"
                    size: Theme.iconSize
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: I18n.tr("Usage")
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            StyledText {
                text: I18n.tr("Search entries by name, username, or folder.\n\nDefault action copies the selected field.\nRight-click for options: copy password, username, or TOTP.\n\nSupported backends: rbw, pass, gopass, op.\nRequires wl-copy for clipboard access.")
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: parent.width
                lineHeight: 1.4
            }
        }
    }
}
