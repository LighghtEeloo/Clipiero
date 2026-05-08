//
//  NSPasteboard+Clipy.swift
//
//  Clipy
//  GitHub: https://github.com/clipy
//  HP: https://clipy-app.com
//
//  Created by Econa77 on 2017/12/30.
//
//  Copyright © 2015-2018 Clipy Project.
//

import Cocoa

extension NSPasteboard.PasteboardType {

    static var legacyString: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSStringPboardType")
    }

    static var legacyRTF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSRTFPboardType")
    }

    static var legacyRTFD: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSRTFDPboardType")
    }

    static var legacyPDF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSPDFPboardType")
    }

    static var legacyFilenames: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")
    }

    static var legacyURL: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSURLPboardType")
    }

    static var legacyTIFF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSTIFFPboardType")
    }

    var clipyStoredType: NSPasteboard.PasteboardType {
        switch self {
        case .legacyString:
            return .string
        case .legacyRTF:
            return .rtf
        case .legacyRTFD:
            return .rtfd
        case .legacyPDF:
            return .pdf
        case .legacyFilenames:
            return .fileURL
        case .legacyURL:
            return .URL
        case .legacyTIFF:
            return .tiff
        default:
            return self
        }
    }

    var clipyReadableTypes: [NSPasteboard.PasteboardType] {
        switch clipyStoredType {
        case .string:
            return [.string, .legacyString]
        case .rtf:
            return [.rtf, .legacyRTF]
        case .rtfd:
            return [.rtfd, .legacyRTFD]
        case .pdf:
            return [.pdf, .legacyPDF]
        case .fileURL:
            return [.fileURL, .legacyFilenames]
        case .URL:
            return [.URL, .legacyURL]
        case .tiff:
            return [.tiff, .legacyTIFF]
        default:
            return [self]
        }
    }

}
