//
//  UpdateService.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created on 2026/05/08.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Foundation
import Sparkle

final class UpdateService {

    // MARK: - Properties
    private enum Defaults {
        static let legacyEnableAutomaticCheck = "kCPYEnableAutomaticCheckKey"
        static let legacyCheckInterval = "kCPYUpdateCheckIntervalKey"
        static let sparkleEnableAutomaticChecks = "SUEnableAutomaticChecks"
        static let sparkleScheduledCheckInterval = "SUScheduledCheckInterval"
    }

    private let updaterController: SPUStandardUpdaterController
    private var isStarted = false

    var updater: SPUUpdater {
        return updaterController.updater
    }

    // MARK: - Initialize
    init(updaterController: SPUStandardUpdaterController = SPUStandardUpdaterController(startingUpdater: false,
                                                                                       updaterDelegate: nil,
                                                                                       userDriverDelegate: nil)) {
        self.updaterController = updaterController
    }

    // MARK: - Internal
    func start() {
        guard !isStarted else { return }
        migrateLegacyDefaults()
        _ = updater.clearFeedURLFromUserDefaults()
        updaterController.startUpdater()
        isStarted = true
    }

    func checkForUpdates(_ sender: Any?) {
        updaterController.checkForUpdates(sender)
    }

    // MARK: - Private
    private func migrateLegacyDefaults() {
        let defaults = AppEnvironment.current.defaults

        if defaults.object(forKey: Defaults.sparkleEnableAutomaticChecks) == nil && defaults.object(forKey: Defaults.legacyEnableAutomaticCheck) != nil {
            defaults.set(defaults.bool(forKey: Defaults.legacyEnableAutomaticCheck), forKey: Defaults.sparkleEnableAutomaticChecks)
        }

        if defaults.object(forKey: Defaults.sparkleScheduledCheckInterval) == nil, let legacyValue = defaults.object(forKey: Defaults.legacyCheckInterval) as? NSNumber {
            defaults.set(legacyValue.doubleValue, forKey: Defaults.sparkleScheduledCheckInterval)
        }

        defaults.removeObject(forKey: Defaults.legacyEnableAutomaticCheck)
        defaults.removeObject(forKey: Defaults.legacyCheckInterval)
    }

}
