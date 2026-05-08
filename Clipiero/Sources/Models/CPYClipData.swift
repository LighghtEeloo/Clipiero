//
//  CPYClipData.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Econa77 on 2015/06/21.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Cocoa
import SwiftHEXColors

protocol CPYPasteboardReading {
    func string(forType dataType: NSPasteboard.PasteboardType) -> String?
    func data(forType dataType: NSPasteboard.PasteboardType) -> Data?
    func propertyList(forType dataType: NSPasteboard.PasteboardType) -> Any?
    func readObjects(forClasses classArray: [AnyClass], options: [NSPasteboard.ReadingOptionKey: Any]?) -> [Any]?
}

extension NSPasteboard: CPYPasteboardReading {}

final class CPYClipData: NSObject, NSCoding {

    // MARK: - Properties
    fileprivate let kTypesKey       = "types"
    fileprivate let kStringValueKey = "stringValue"
    fileprivate let kRTFDataKey     = "RTFData"
    fileprivate let kPDFKey         = "PDF"
    fileprivate let kFileNamesKey   = "filenames"
    fileprivate let kURLsKey        = "URL"
    fileprivate let kImageKey       = "image"

    var types          = [NSPasteboard.PasteboardType]()
    var fileNames      = [String]()
    var URLs           = [String]()
    var stringValue    = ""
    var RTFData: Data?
    var PDF: Data?
    var image: NSImage?

    override var hash: Int {
        var hash = types.map { $0.rawValue }.joined().hash
        if let image = self.image, let imageData = image.tiffRepresentation {
            hash ^= imageData.count
        } else if let image = self.image {
            hash ^= image.hash
        }
        if !fileNames.isEmpty {
            fileNames.forEach { hash ^= $0.hash }
        } else if !self.URLs.isEmpty {
            URLs.forEach { hash ^= $0.hash }
        } else if let pdf = PDF {
            hash ^= pdf.count
        } else if !stringValue.isEmpty {
            hash ^= stringValue.hash
        }
        if let data = RTFData {
            hash ^= data.count
        }
        return hash
    }
    var primaryType: NSPasteboard.PasteboardType? {
        return types.first
    }
    var isOnlyStringType: Bool {
        return types == [.string]
    }
    var thumbnailImage: NSImage? {
        let preferences = AppEnvironment.current.preferences
        let width = preferences.thumbnailWidth
        let height = preferences.thumbnailHeight

        if let image = image, fileNames.isEmpty {
            // Image only data
            return image.resizeImage(CGFloat(width), CGFloat(height))
        } else if let fileName = fileNames.first, let path = fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: path) {
             // In the case of the local file correct data is not included in the image variable
             // Judge the image from the path and create a thumbnail
            switch url.pathExtension.lowercased() {
            case "jpg", "jpeg", "png", "bmp", "tiff":
                return NSImage(contentsOfFile: fileName)?.resizeImage(CGFloat(width), CGFloat(height))
            default: break
            }
        }
        return nil
    }
    var colorCodeImage: NSImage? {
        guard let color = NSColor(hexString: stringValue) else { return nil }
        return NSImage.create(with: color, size: NSSize(width: 20, height: 20))
    }

    static var availableTypes: [NSPasteboard.PasteboardType] {
        return [.string,
                .rtf,
                .rtfd,
                .pdf,
                .fileURL,
                .URL,
                .tiff]
    }
    static var availableTypesString: [String] {
        return ["String",
                "RTF",
                "RTFD",
                "PDF",
                "Filenames",
                "URL",
                "TIFF"]
    }
    static var availableTypesDictinary: [NSPasteboard.PasteboardType: String] {
        var availableTypes = [NSPasteboard.PasteboardType: String]()
        zip(CPYClipData.availableTypes, CPYClipData.availableTypesString).forEach { availableTypes[$0] = $1 }
        return availableTypes
    }

    // MARK: - Init
    init(pasteboard: CPYPasteboardReading, types: [NSPasteboard.PasteboardType]) {
        super.init()
        self.types = NSOrderedSet(array: types.map { $0.clipieroStoredType }).array as? [NSPasteboard.PasteboardType] ?? []
        self.types.forEach { type in
            switch type {
            case .string:
                guard let string = pasteboard.string(forTypes: type.clipieroReadableTypes) else { return }
                stringValue = string
            case .rtfd:
                RTFData = pasteboard.data(forTypes: type.clipieroReadableTypes)
            case .rtf where RTFData == nil:
                RTFData = pasteboard.data(forTypes: type.clipieroReadableTypes)
            case .pdf:
                PDF = pasteboard.data(forTypes: type.clipieroReadableTypes)
            case .fileURL:
                guard let filenames = pasteboard.clipieroFileNames() else { return }
                self.fileNames = filenames
            case .URL:
                guard let urls = pasteboard.clipieroURLs() else { return }
                URLs = urls
            case .tiff:
                image = pasteboard.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage
                if image == nil, let data = pasteboard.data(forTypes: type.clipieroReadableTypes) {
                    image = NSImage(data: data)
                }
            default: break
            }
        }
    }

    init(image: NSImage) {
        self.types = [.tiff]
        self.image = image
    }

    deinit {
        self.RTFData = nil
        self.PDF = nil
        self.image = nil
    }

    // MARK: - Pasteboard Writing
    func write(to pasteboard: NSPasteboard) {
        switch types {
        case [.fileURL]:
            let urls = fileNames.map { NSURL(fileURLWithPath: $0) }
            pasteboard.clearContents()
            pasteboard.writeObjects(urls)
            return
        case [.URL]:
            let urls = URLs.compactMap { NSURL(string: $0) }
            pasteboard.clearContents()
            pasteboard.writeObjects(urls)
            return
        default:
            break
        }

        pasteboard.declareTypes(types, owner: nil)
        types.forEach { type in
            switch type {
            case .string:
                pasteboard.setString(stringValue, forType: .string)
            case .rtfd:
                guard let rtfData = RTFData else { return }
                pasteboard.setData(rtfData, forType: .rtfd)
            case .rtf:
                guard let rtfData = RTFData else { return }
                pasteboard.setData(rtfData, forType: .rtf)
            case .pdf:
                guard let pdfData = PDF, let pdfRep = NSPDFImageRep(data: pdfData) else { return }
                pasteboard.setData(pdfRep.pdfRepresentation, forType: .pdf)
            case .fileURL:
                guard let fileName = fileNames.first else { return }
                pasteboard.setString(URL(fileURLWithPath: fileName).absoluteString, forType: .fileURL)
            case .URL:
                guard let url = URLs.first else { return }
                pasteboard.setString(url, forType: .URL)
            case .tiff:
                guard let image = image, let imageData = image.tiffRepresentation else { return }
                pasteboard.setData(imageData, forType: .tiff)
            default: break
            }
        }
    }

    // MARK: - NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(types.map { $0.rawValue }, forKey: kTypesKey)
        aCoder.encode(stringValue, forKey: kStringValueKey)
        aCoder.encode(RTFData, forKey: kRTFDataKey)
        aCoder.encode(PDF, forKey: kPDFKey)
        aCoder.encode(fileNames, forKey: kFileNamesKey)
        aCoder.encode(URLs, forKey: kURLsKey)
        aCoder.encode(image, forKey: kImageKey)
    }

    required init?(coder aDecoder: NSCoder) {
        types = (aDecoder.decodeObject(forKey: kTypesKey) as? [String])?
            .compactMap { NSPasteboard.PasteboardType(rawValue: $0).clipieroStoredType } ?? []
        fileNames = aDecoder.decodeObject(forKey: kFileNamesKey) as? [String] ?? [String]()
        URLs = aDecoder.decodeObject(forKey: kURLsKey) as? [String] ?? [String]()
        stringValue = aDecoder.decodeObject(forKey: kStringValueKey) as? String ?? ""
        RTFData = aDecoder.decodeObject(forKey: kRTFDataKey) as? Data
        PDF = aDecoder.decodeObject(forKey: kPDFKey) as? Data
        image = aDecoder.decodeObject(forKey: kImageKey) as? NSImage
        super.init()
    }
}

private extension CPYPasteboardReading {
    func string(forTypes types: [NSPasteboard.PasteboardType]) -> String? {
        for type in types {
            if let string = string(forType: type) {
                return string
            }
        }
        return nil
    }

    func data(forTypes types: [NSPasteboard.PasteboardType]) -> Data? {
        for type in types {
            if let data = data(forType: type) {
                return data
            }
        }
        return nil
    }

    func clipieroFileNames() -> [String]? {
        if let filenames = propertyList(forType: .legacyFilenames) as? [String] {
            return filenames
        }
        let urls = readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true])?.compactMap { object -> String? in
            if let url = object as? URL {
                return url.path
            }
            return (object as? NSURL)?.path
        }
        return urls?.isEmpty == false ? urls : nil
    }

    func clipieroURLs() -> [String]? {
        if let urls = propertyList(forType: .legacyURL) as? [String] {
            return urls
        }
        if let url = string(forType: .URL) {
            return [url]
        }
        let urls = readObjects(forClasses: [NSURL.self], options: nil)?.compactMap { object -> String? in
            if let url = object as? URL {
                return url.absoluteString
            }
            return (object as? NSURL)?.absoluteString
        }
        return urls?.isEmpty == false ? urls : nil
    }
}
