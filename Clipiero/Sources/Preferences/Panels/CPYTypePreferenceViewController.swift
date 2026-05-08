//
//  CPYTypePreferenceViewController.swift
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

class CPYTypePreferenceViewController: NSViewController {

    // MARK: - Properties
    @objc var storeTypes: NSMutableDictionary!

    // MARK: - Initialize
    override func loadView() {
        storeTypes = NSMutableDictionary(dictionary: AppEnvironment.current.preferences.storeTypes)
        super.loadView()
    }

}
