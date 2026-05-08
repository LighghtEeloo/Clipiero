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

            it("Normalizes legacy pasteboard types to modern stored types") {
                expect(NSPasteboard.PasteboardType.legacyString.clipyStoredType) == NSPasteboard.PasteboardType.string
                expect(NSPasteboard.PasteboardType.legacyRTF.clipyStoredType) == NSPasteboard.PasteboardType.rtf
                expect(NSPasteboard.PasteboardType.legacyRTFD.clipyStoredType) == NSPasteboard.PasteboardType.rtfd
                expect(NSPasteboard.PasteboardType.legacyPDF.clipyStoredType) == NSPasteboard.PasteboardType.pdf
                expect(NSPasteboard.PasteboardType.legacyFilenames.clipyStoredType) == NSPasteboard.PasteboardType.fileURL
                expect(NSPasteboard.PasteboardType.legacyURL.clipyStoredType) == NSPasteboard.PasteboardType.URL
                expect(NSPasteboard.PasteboardType.legacyTIFF.clipyStoredType) == NSPasteboard.PasteboardType.tiff
                expect(NSPasteboard.PasteboardType.string.clipyStoredType) == NSPasteboard.PasteboardType.string
            }

            it("Reads modern pasteboard data into modern Clipy fields") {
                let rtfData = Data("rtf".utf8)
                let pdfData = Data("pdf".utf8)
                let url = "https://clipy-app.com/"
                var pasteboard = MockPasteboard()
                pasteboard.strings[.string] = "hello"
                pasteboard.dataValues[.rtf] = rtfData
                pasteboard.dataValues[.pdf] = pdfData
                pasteboard.strings[.URL] = url

                let data = CPYClipData(pasteboard: pasteboard, types: [.string, .rtf, .pdf, .URL])

                expect(data.types) == [.string, .rtf, .pdf, .URL]
                expect(data.stringValue) == "hello"
                expect(data.RTFData) == rtfData
                expect(data.PDF) == pdfData
                expect(data.URLs) == [url]
            }

            it("Reads legacy pasteboard data into modern Clipy fields") {
                let rtfData = Data("rtf".utf8)
                let filenames = ["/tmp/example.txt"]
                var pasteboard = MockPasteboard()
                pasteboard.strings[.legacyString] = "hello"
                pasteboard.dataValues[.legacyRTF] = rtfData
                pasteboard.propertyLists[.legacyFilenames] = filenames

                let data = CPYClipData(pasteboard: pasteboard, types: [.legacyString, .legacyRTF, .legacyFilenames])

                expect(data.types) == [.string, .rtf, .fileURL]
                expect(data.stringValue) == "hello"
                expect(data.RTFData) == rtfData
                expect(data.fileNames) == filenames
            }

            it("Prefers RTFD data over RTF when both are present") {
                let rtfdData = Data("rtfd".utf8)
                let rtfData = Data("rtf".utf8)
                var pasteboard = MockPasteboard()
                pasteboard.dataValues[.rtfd] = rtfdData
                pasteboard.dataValues[.rtf] = rtfData

                let data = CPYClipData(pasteboard: pasteboard, types: [.rtfd, .rtf])

                expect(data.types) == [.rtfd, .rtf]
                expect(data.RTFData) == rtfdData
            }

        }

    }
}
