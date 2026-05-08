//
//  PasteService.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Econa77 on 2016/11/23.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Foundation
import Cocoa
import Sauce

final class PasteService {

    // MARK: - Properties
    fileprivate let lock = NSRecursiveLock(name: "com.clipiero.Clipiero.Pastable")
    fileprivate var isPastePlainText: Bool {
        guard AppEnvironment.current.defaults.bool(forKey: Constants.Beta.pastePlainText) else { return false }

        let modifierSetting = AppEnvironment.current.defaults.integer(forKey: Constants.Beta.pastePlainTextModifier)
        return isPressedModifier(modifierSetting)
    }
    fileprivate var isDeleteHistory: Bool {
        guard AppEnvironment.current.defaults.bool(forKey: Constants.Beta.deleteHistory) else { return false }

        let modifierSetting = AppEnvironment.current.defaults.integer(forKey: Constants.Beta.deleteHistoryModifier)
        return isPressedModifier(modifierSetting)
    }
    fileprivate var isPasteAndDeleteHistory: Bool {
        guard AppEnvironment.current.defaults.bool(forKey: Constants.Beta.pasteAndDeleteHistory) else { return false }

        let modifierSetting = AppEnvironment.current.defaults.integer(forKey: Constants.Beta.pasteAndDeleteHistoryModifier)
        return isPressedModifier(modifierSetting)
    }

    // MARK: - Modifiers
    private func isPressedModifier(_ flag: Int) -> Bool {
        let flags = NSEvent.modifierFlags
        if flag == 0 && flags.contains(.command) {
            return true
        } else if flag == 1 && flags.contains(.shift) {
            return true
        } else if flag == 2 && flags.contains(.control) {
            return true
        } else if flag == 3 && flags.contains(.option) {
            return true
        }
        return false
    }
}

// MARK: - Copy
extension PasteService {
    func paste(with clip: CPYClip) {
        guard !clip.isInvalidated else { return }
        guard let data = NSKeyedUnarchiver.clipieroUnarchiveObject(ofType: CPYClipData.self, fromFile: clip.dataPath) else { return }

        // Handling modifier actions
        let isPastePlainText = self.isPastePlainText
        let isPasteAndDeleteHistory = self.isPasteAndDeleteHistory
        let isDeleteHistory = self.isDeleteHistory
        guard isPastePlainText || isPasteAndDeleteHistory || isDeleteHistory else {
            copyToPasteboard(with: clip)
            paste()
            return
        }

        // Increment change count for don't copy paste item
        if isPasteAndDeleteHistory {
            AppEnvironment.current.clipService.incrementChangeCount()
        }
        // Paste history
        if isPastePlainText {
            copyToPasteboard(with: data.stringValue)
            paste()
        } else if isPasteAndDeleteHistory {
            copyToPasteboard(with: clip)
            paste()
        }
        // Delete clip
        if isDeleteHistory || isPasteAndDeleteHistory {
            AppEnvironment.current.clipService.delete(with: clip)
        }
    }

    func copyToPasteboard(with string: String) {
        lock.lock(); defer { lock.unlock() }

        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(string, forType: .string)
    }

    func copyToPasteboard(with clip: CPYClip) {
        lock.lock(); defer { lock.unlock() }

        guard let data = NSKeyedUnarchiver.clipieroUnarchiveObject(ofType: CPYClipData.self, fromFile: clip.dataPath) else { return }

        if isPastePlainText {
            copyToPasteboard(with: data.stringValue)
            return
        }

        let pasteboard = NSPasteboard.general
        let types = data.types
        switch types {
        case [.fileURL]:
            // writeObjects preserves multiple URL pasteboard items.
            // declareTypes below writes one item with several types.
            let urls = data.fileNames.map { NSURL(fileURLWithPath: $0) }
            pasteboard.clearContents()
            pasteboard.writeObjects(urls)
            return
        case [.URL]:
            let urls = data.URLs.compactMap { NSURL(string: $0) }
            pasteboard.clearContents()
            pasteboard.writeObjects(urls)
            return
        default:
            break
        }

        pasteboard.declareTypes(types, owner: nil)
        types.forEach { type in
            switch type {
            case .string:
                let pbString = data.stringValue
                pasteboard.setString(pbString, forType: .string)
            case .rtfd:
                guard let rtfData = data.RTFData else { return }
                pasteboard.setData(rtfData, forType: .rtfd)
            case .rtf:
                guard let rtfData = data.RTFData else { return }
                pasteboard.setData(rtfData, forType: .rtf)
            case .pdf:
                guard let pdfData = data.PDF, let pdfRep = NSPDFImageRep(data: pdfData) else { return }
                pasteboard.setData(pdfRep.pdfRepresentation, forType: .pdf)
            case .fileURL:
                guard let fileName = data.fileNames.first else { return }
                pasteboard.setString(URL(fileURLWithPath: fileName).absoluteString, forType: .fileURL)
            case .URL:
                guard let url = data.URLs.first else { return }
                pasteboard.setString(url, forType: .URL)
            case .tiff:
                guard let image = data.image, let imageData = image.tiffRepresentation else { return }
                pasteboard.setData(imageData, forType: .tiff)
            default: break
            }
        }
    }
}

// MARK: - Paste
extension PasteService {
    func paste() {
        guard AppEnvironment.current.defaults.bool(forKey: Constants.UserDefaults.inputPasteCommand) else { return }
        // Check Accessibility Permission
        guard AppEnvironment.current.accessibilityService.isAccessibilityEnabled(isPrompt: false) else {
            AppEnvironment.current.accessibilityService.showAccessibilityAuthenticationAlert()
            return
        }

        let vKeyCode = Sauce.shared.keyCode(for: .v)
        DispatchQueue.main.async {
            let source = CGEventSource(stateID: .combinedSessionState)
            // Disable local keyboard events while pasting
            source?.setLocalEventsFilterDuringSuppressionState([.permitLocalMouseEvents, .permitSystemDefinedEvents], state: .eventSuppressionStateSuppressionInterval)
            // Press Command + V
            let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
            keyVDown?.flags = .maskCommand
            // Release Command + V
            let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)
            keyVUp?.flags = .maskCommand
            // Post Paste Command
            keyVDown?.post(tap: .cgAnnotatedSessionEventTap)
            keyVUp?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }
}
