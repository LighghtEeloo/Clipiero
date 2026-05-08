//
//  NSUserDefaults+ArchiveData.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Econa77 on 2016/06/23.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Foundation
import Cocoa

extension UserDefaults {
    func setArchiveData<T: NSCoding>(_ object: T, forKey key: String) {
        let data = object.archive()
        set(data, forKey: key)
    }

    func archiveDataForKey<T: NSCoding>(_: T.Type, key: String) -> T? {
        guard let data = object(forKey: key) as? Data else { return nil }
        guard let object = NSKeyedUnarchiver.clipieroUnarchiveObject(ofType: T.self, from: data) else { return nil }
        return object
    }
}
