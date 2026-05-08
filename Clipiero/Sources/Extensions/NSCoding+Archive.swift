//
//  NSCoding+Archive.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Econa77 on 2016/11/19.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Foundation

extension NSKeyedArchiver {
    static func clipieroArchivedData(withRootObject object: Any) -> Data {
        return try! archivedData(withRootObject: object, requiringSecureCoding: false)
    }

    static func clipieroArchiveRootObject(_ object: Any, toFile path: String) -> Bool {
        do {
            let data = clipieroArchivedData(withRootObject: object)
            try data.write(to: URL(fileURLWithPath: path), options: .atomic)
            return true
        } catch {
            return false
        }
    }
}

extension NSKeyedUnarchiver {
    static func clipieroUnarchiveObject<T>(ofType _: T.Type, from data: Data) -> T? {
        do {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = false
            defer { unarchiver.finishDecoding() }
            return unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? T
        } catch {
            return nil
        }
    }

    static func clipieroUnarchiveObject<T>(ofType type: T.Type, fromFile path: String) -> T? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        return clipieroUnarchiveObject(ofType: type, from: data)
    }
}

extension NSCoding {
    func archive() -> Data {
        return NSKeyedArchiver.clipieroArchivedData(withRootObject: self)
    }

    func archive(toFile path: String) -> Bool {
        return NSKeyedArchiver.clipieroArchiveRootObject(self, toFile: path)
    }
}

extension Array where Element: NSCoding {
    func archive() -> Data {
        return NSKeyedArchiver.clipieroArchivedData(withRootObject: self)
    }
}
