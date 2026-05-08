//
//  NSPasteboard+Deprecated.swift
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

/**
 *  The contents of PasteboardType has been changed with swift 4.
 *  However, we will use the swift 3 style to keep compatibility with existing items
 *  Help wanted - If there is a good implementation I would like to replace it.
 **/
extension NSPasteboard.PasteboardType {

    static var modernString: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")
    }

    static var modernRTF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "public.rtf")
    }

    static var modernRTFD: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "com.apple.flat-rtfd")
    }

    static var modernPDF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "com.adobe.pdf")
    }

    static var modernURL: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "public.url")
    }

    static var modernTIFF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "public.tiff")
    }

    static var deprecatedString: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSStringPboardType")
    }

    static var deprecatedRTF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSRTFPboardType")
    }

    static var deprecatedRTFD: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSRTFDPboardType")
    }

    static var deprecatedPDF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSPDFPboardType")
    }

    static var deprecatedFilenames: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")
    }

    static var deprecatedURL: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSURLPboardType")
    }

    static var deprecatedTIFF: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSTIFFPboardType")
    }

    var clipyLegacyType: NSPasteboard.PasteboardType {
        switch self {
        case .modernString:
            return .deprecatedString
        case .modernRTF:
            return .deprecatedRTF
        case .modernRTFD:
            return .deprecatedRTFD
        case .modernPDF:
            return .deprecatedPDF
        case .modernURL:
            return .deprecatedURL
        case .modernTIFF:
            return .deprecatedTIFF
        default:
            return self
        }
    }

}
