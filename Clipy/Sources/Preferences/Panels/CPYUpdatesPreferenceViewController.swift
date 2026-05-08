//
//  CPYUpdatesPreferenceViewController.swift
//
//  Clipy
//  GitHub: https://github.com/clipy
//  HP: https://clipy-app.com
//
//  Created by Econa77 on 2016/03/17.
//
//  Copyright © 2015-2018 Clipy Project.
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
