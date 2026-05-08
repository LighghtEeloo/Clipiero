import Cocoa
import Quick
import Nimble
@testable import Clipy

private struct MockPasteboard: CPYPasteboardReading {
    var strings = [NSPasteboard.PasteboardType: String]()
    var dataValues = [NSPasteboard.PasteboardType: Data]()
    var propertyLists = [NSPasteboard.PasteboardType: Any]()
    var objects = [Any]()

    func string(forType dataType: NSPasteboard.PasteboardType) -> String? {
        return strings[dataType]
    }

    func data(forType dataType: NSPasteboard.PasteboardType) -> Data? {
        return dataValues[dataType]
    }

    func propertyList(forType dataType: NSPasteboard.PasteboardType) -> Any? {
        return propertyLists[dataType]
    }

    func readObjects(forClasses classArray: [AnyClass], options: [NSPasteboard.ReadingOptionKey: Any]?) -> [Any]? {
        return objects
    }
}

class ClipDataSpec: QuickSpec {
    override func spec() {

        describe("Pasteboard type compatibility") {

            it("Normalizes modern pasteboard types to legacy stored types") {
                expect(NSPasteboard.PasteboardType.modernString.clipyLegacyType) == NSPasteboard.PasteboardType.deprecatedString
                expect(NSPasteboard.PasteboardType.modernRTF.clipyLegacyType) == NSPasteboard.PasteboardType.deprecatedRTF
                expect(NSPasteboard.PasteboardType.modernRTFD.clipyLegacyType) == NSPasteboard.PasteboardType.deprecatedRTFD
                expect(NSPasteboard.PasteboardType.modernPDF.clipyLegacyType) == NSPasteboard.PasteboardType.deprecatedPDF
                expect(NSPasteboard.PasteboardType.modernURL.clipyLegacyType) == NSPasteboard.PasteboardType.deprecatedURL
                expect(NSPasteboard.PasteboardType.modernTIFF.clipyLegacyType) == NSPasteboard.PasteboardType.deprecatedTIFF
                expect(NSPasteboard.PasteboardType.deprecatedString.clipyLegacyType) == NSPasteboard.PasteboardType.deprecatedString
            }

            it("Reads modern pasteboard data into legacy Clipy fields") {
                let rtfData = Data("rtf".utf8)
                let pdfData = Data("pdf".utf8)
                let url = "https://clipy-app.com/"
                var pasteboard = MockPasteboard()
                pasteboard.strings[.modernString] = "hello"
                pasteboard.dataValues[.modernRTF] = rtfData
                pasteboard.dataValues[.modernPDF] = pdfData
                pasteboard.strings[.modernURL] = url

                let data = CPYClipData(pasteboard: pasteboard, types: [.modernString, .modernRTF, .modernPDF, .modernURL])

                expect(data.types) == [.deprecatedString, .deprecatedRTF, .deprecatedPDF, .deprecatedURL]
                expect(data.stringValue) == "hello"
                expect(data.RTFData) == rtfData
                expect(data.PDF) == pdfData
                expect(data.URLs) == [url]
            }

            it("Prefers modern RTFD data over modern RTF when both are present") {
                let rtfdData = Data("rtfd".utf8)
                let rtfData = Data("rtf".utf8)
                var pasteboard = MockPasteboard()
                pasteboard.dataValues[.modernRTFD] = rtfdData
                pasteboard.dataValues[.modernRTF] = rtfData

                let data = CPYClipData(pasteboard: pasteboard, types: [.modernRTFD, .modernRTF])

                expect(data.types) == [.deprecatedRTFD, .deprecatedRTF]
                expect(data.RTFData) == rtfdData
            }

        }

    }
}
