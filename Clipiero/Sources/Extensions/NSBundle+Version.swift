//
//  NSBundle+Version.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Econa77 on 2016/03/29.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Foundation

extension Bundle {
    var appVersion: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
