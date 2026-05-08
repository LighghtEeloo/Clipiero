//
//  Array+Remove.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Econa77 on 2016/07/06.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Foundation

extension Array {
    mutating func removeObject<T: Equatable>(_ element: T) {
        self = filter { $0 as? T != element }
    }
}

extension Array {
    mutating func removeObjects<T: Equatable>(_ elements: [T]) {
        elements.forEach { removeObject($0) }
    }
}
