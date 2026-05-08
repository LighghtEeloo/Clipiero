import Cocoa
import Quick
import Nimble
@testable import Clipiero

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
    override class func spec() {

        describe("Pasteboard type compatibility") {

            it("Normalizes legacy pasteboard types to modern stored types") {
                expect(NSPasteboard.PasteboardType.legacyString.clipieroStoredType) == NSPasteboard.PasteboardType.string
                expect(NSPasteboard.PasteboardType.legacyRTF.clipieroStoredType) == NSPasteboard.PasteboardType.rtf
                expect(NSPasteboard.PasteboardType.legacyRTFD.clipieroStoredType) == NSPasteboard.PasteboardType.rtfd
                expect(NSPasteboard.PasteboardType.legacyPDF.clipieroStoredType) == NSPasteboard.PasteboardType.pdf
                expect(NSPasteboard.PasteboardType.legacyFilenames.clipieroStoredType) == NSPasteboard.PasteboardType.fileURL
                expect(NSPasteboard.PasteboardType.legacyURL.clipieroStoredType) == NSPasteboard.PasteboardType.URL
                expect(NSPasteboard.PasteboardType.legacyTIFF.clipieroStoredType) == NSPasteboard.PasteboardType.tiff
                expect(NSPasteboard.PasteboardType.string.clipieroStoredType) == NSPasteboard.PasteboardType.string
            }

            it("Reads modern pasteboard data into modern Clipiero fields") {
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

            it("Reads legacy pasteboard data into modern Clipiero fields") {
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

            it("Writes stored string data back to the pasteboard") {
                var pasteboard = MockPasteboard()
                pasteboard.strings[.string] = "hello"
                let data = CPYClipData(pasteboard: pasteboard, types: [.string])
                let writablePasteboard = NSPasteboard(name: NSPasteboard.Name(UUID().uuidString))

                data.write(to: writablePasteboard)

                expect(writablePasteboard.string(forType: .string)) == "hello"
            }

        }

    }
}
