//
//  UnsavedChangesAlertResult.swift
//  Costume
//
//  Created by Matthew Regan Hadiwidjaja on 28/07/26.
//

import AppKit

enum UnsavedChangesAlertResult {
    case save
    case discardChanges
    case cancel
}

struct UnsavedChangesAlert {
    static func present() -> UnsavedChangesAlertResult {
        let alert = NSAlert()
        alert.messageText = "Save changes to your profile?"
        alert.informativeText = "Your changes will be lost if you don't save them."
        alert.alertStyle = .warning

        let saveButton = alert.addButton(withTitle: "Save")
        let discardButton = alert.addButton(withTitle: "Discard Changes")
        alert.addButton(withTitle: "Cancel")

        saveButton.bezelColor = .systemBlue
        discardButton.hasDestructiveAction = true

        switch alert.runModal() {
        case .alertFirstButtonReturn: return .save
        case .alertSecondButtonReturn: return .discardChanges
        default: return .cancel
        }
    }
}
