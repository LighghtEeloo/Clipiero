//
//  CPYUpdatesPreferenceViewController.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Econa77 on 2016/03/17.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Cocoa
import Sparkle

class CPYUpdatesPreferenceViewController: NSViewController {

    // MARK: - Properties
    @IBOutlet private weak var versionTextField: NSTextField!
    @objc dynamic var updater: SPUUpdater {
        return AppEnvironment.current.updateService.updater
    }

    // MARK: - Initialize
    override func loadView() {
        super.loadView()
        versionTextField.stringValue = "v\(Bundle.main.appVersion ?? "")"
    }

    // MARK: - Actions
    @IBAction func checkForUpdates(_ sender: Any?) {
        AppEnvironment.current.updateService.checkForUpdates(sender)
    }

}
