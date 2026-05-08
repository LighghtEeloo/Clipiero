//
//  Collection+Safe.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Econa77 on 2017/03/01.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
