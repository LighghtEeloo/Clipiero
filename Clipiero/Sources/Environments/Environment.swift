//
//  Environment.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Econa77 on 2017/08/10.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Foundation

struct Environment {

    // MARK: - Properties
    let clipService: ClipService
    let hotKeyService: HotKeyService
    let dataCleanService: DataCleanService
    let pasteService: PasteService
    let excludeAppService: ExcludeAppService
    let accessibilityService: AccessibilityService
    let menuManager: MenuManager
    let updateService: UpdateService

    let defaults: UserDefaults

    // MARK: - Initialize
    init(clipService: ClipService = ClipService(),
         hotKeyService: HotKeyService = HotKeyService(),
         dataCleanService: DataCleanService = DataCleanService(),
         pasteService: PasteService = PasteService(),
         excludeAppService: ExcludeAppService = ExcludeAppService(applications: []),
         accessibilityService: AccessibilityService = AccessibilityService(),
         menuManager: MenuManager = MenuManager(),
         updateService: UpdateService = UpdateService(),
         defaults: UserDefaults = .standard) {

        self.clipService = clipService
        self.hotKeyService = hotKeyService
        self.dataCleanService = dataCleanService
        self.pasteService = pasteService
        self.excludeAppService = excludeAppService
        self.accessibilityService = accessibilityService
        self.menuManager = menuManager
        self.updateService = updateService
        self.defaults = defaults
    }

}
