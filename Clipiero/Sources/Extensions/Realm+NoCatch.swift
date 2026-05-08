//
//  Realm+NoCatch.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Econa77 on 2016/03/11.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Foundation
import RealmSwift

extension Realm {
    func transaction(_ block: (() throws -> Void)) {
        do {
            try write(block)
        } catch {}
    }
}
