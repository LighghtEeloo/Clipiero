//
//  CPYPreferencesWindowController.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Econa77 on 2016/02/25.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Cocoa

final class CPYPreferencesWindowController: NSWindowController {

    // MARK: - Properties
    static let sharedController = CPYPreferencesWindowController(windowNibName: "CPYPreferencesWindowController")
    @IBOutlet private weak var toolBar: NSView!
    // ImageViews
    @IBOutlet private weak var generalImageView: NSImageView!
    @IBOutlet private weak var menuImageView: NSImageView!
    @IBOutlet private weak var typeImageView: NSImageView!
    @IBOutlet private weak var excludeImageView: NSImageView!
    @IBOutlet private weak var shortcutsImageView: NSImageView!
    @IBOutlet private weak var updatesImageView: NSImageView!
    @IBOutlet private weak var betaImageView: NSImageView!
    // Labels
    @IBOutlet private weak var generalTextField: NSTextField!
    @IBOutlet private weak var menuTextField: NSTextField!
    @IBOutlet private weak var typeTextField: NSTextField!
    @IBOutlet private weak var excludeTextField: NSTextField!
    @IBOutlet private weak var shortcutsTextField: NSTextField!
    @IBOutlet private weak var updatesTextField: NSTextField!
    @IBOutlet private weak var betaTextField: NSTextField!
    // Buttons
    @IBOutlet private weak var generalButton: NSButton!
    @IBOutlet private weak var menuButton: NSButton!
    @IBOutlet private weak var typeButton: NSButton!
    @IBOutlet private weak var excludeButton: NSButton!
    @IBOutlet private weak var shortcutsButton: NSButton!
    @IBOutlet private weak var updatesButton: NSButton!
    @IBOutlet private weak var betaButton: NSButton!
    // ViewController
    private let viewController = [NSViewController(nibName: "CPYGeneralPreferenceViewController", bundle: nil),
                                  NSViewController(nibName: "CPYMenuPreferenceViewController", bundle: nil),
                                  CPYTypePreferenceViewController(nibName: "CPYTypePreferenceViewController", bundle: nil),
                                  CPYExcludeAppPreferenceViewController(nibName: "CPYExcludeAppPreferenceViewController", bundle: nil),
                                  CPYShortcutsPreferenceViewController(nibName: "CPYShortcutsPreferenceViewController", bundle: nil),
                                  CPYUpdatesPreferenceViewController(nibName: "CPYUpdatesPreferenceViewController", bundle: nil),
                                  CPYBetaPreferenceViewController(nibName: "CPYBetaPreferenceViewController", bundle: nil)]

    private var tabItems: [(imageView: NSImageView, textField: NSTextField, symbolNames: [String])] {
        [
            (generalImageView, generalTextField, ["gearshape", "gear"]),
            (menuImageView, menuTextField, ["list.bullet.rectangle", "list.bullet"]),
            (typeImageView, typeTextField, ["doc.on.clipboard", "doc.text"]),
            (excludeImageView, excludeTextField, ["nosign", "xmark.circle"]),
            (shortcutsImageView, shortcutsTextField, ["keyboard"]),
            (updatesImageView, updatesTextField, ["arrow.triangle.2.circlepath", "arrow.clockwise"]),
            (betaImageView, betaTextField, ["sparkles", "star"])
        ]
    }

    // MARK: - Window Life Cycle
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.collectionBehavior = .canJoinAllSpaces
        self.window?.backgroundColor = .windowBackgroundColor
        self.window?.titlebarAppearsTransparent = true
        toolBarItemTapped(generalButton)
        generalButton.sendAction(on: .leftMouseDown)
        menuButton.sendAction(on: .leftMouseDown)
        typeButton.sendAction(on: .leftMouseDown)
        excludeButton.sendAction(on: .leftMouseDown)
        shortcutsButton.sendAction(on: .leftMouseDown)
        updatesButton.sendAction(on: .leftMouseDown)
        betaButton.sendAction(on: .leftMouseDown)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(self)
    }
}

// MARK: - IBActions
extension CPYPreferencesWindowController {
    @IBAction private func toolBarItemTapped(_ sender: NSButton) {
        selectedTab(sender.tag)
        switchView(sender.tag)
    }
}

// MARK: - NSWindow Delegate
extension CPYPreferencesWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let viewController = viewController[2] as? CPYTypePreferenceViewController {
            AppEnvironment.current.defaults.set(viewController.storeTypes, forKey: Constants.UserDefaults.storeTypes)
            AppEnvironment.current.defaults.synchronize()
        }
        if let window = window, !window.makeFirstResponder(window) {
            window.endEditing(for: nil)
        }
        NSApp.deactivate()
    }
}

// MARK: - Layout
private extension CPYPreferencesWindowController {
    func resetImages() {
        tabItems.forEach { item in
            updateTabIcon(item.imageView, symbolNames: item.symbolNames, color: .secondaryLabelColor)
            item.textField.textColor = .secondaryLabelColor
        }
    }

    func selectedTab(_ index: Int) {
        resetImages()

        guard tabItems.indices.contains(index) else {
            return
        }

        let selectedItem = tabItems[index]
        updateTabIcon(selectedItem.imageView, symbolNames: selectedItem.symbolNames, color: .controlAccentColor)
        selectTab(selectedItem.textField)
    }

    func selectTab(_ textField: NSTextField) {
        textField.textColor = .controlAccentColor
    }

    func updateTabIcon(_ imageView: NSImageView, symbolNames: [String], color: NSColor) {
        imageView.contentTintColor = color
        imageView.imageScaling = .scaleProportionallyDown
        imageView.image = symbolImage(named: symbolNames)
    }

    func symbolImage(named symbolNames: [String]) -> NSImage? {
        let configuration = NSImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = symbolNames
            .lazy
            .compactMap { NSImage(systemSymbolName: $0, accessibilityDescription: nil) }
            .first?
            .withSymbolConfiguration(configuration)
        image?.isTemplate = true
        return image
    }

    func switchView(_ index: Int) {
        let newView = viewController[index].view
        // Remove current views without toolbar
        window?.contentView?.subviews.forEach { view in
            if view != toolBar {
                view.removeFromSuperview()
            }
        }
        // Resize view
        let frame = window!.frame
        var newFrame = window!.frameRect(forContentRect: newView.frame)
        newFrame.origin = frame.origin
        newFrame.origin.y += frame.height - newFrame.height - toolBar.frame.height
        newFrame.size.height += toolBar.frame.height
        window?.setFrame(newFrame, display: false)
        window?.contentView?.addSubview(newView)
    }
}
