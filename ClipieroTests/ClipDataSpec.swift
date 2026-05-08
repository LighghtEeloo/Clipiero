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

private func makeWritablePasteboard() -> NSPasteboard {
    let pasteboard = NSPasteboard(name: NSPasteboard.Name(UUID().uuidString))
    pasteboard.clearContents()
    return pasteboard
}

private func makePDFData() -> Data {
    let data = NSMutableData()
    var mediaBox = CGRect(x: 0, y: 0, width: 10, height: 10)
    guard let consumer = CGDataConsumer(data: data as CFMutableData),
          let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
        return Data()
    }
    context.beginPDFPage(nil)
    context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
    context.fill(mediaBox)
    context.endPDFPage()
    context.closePDF()
    return data as Data
}

private func makeTestImage() -> NSImage {
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil,
                                  pixelsWide: 1,
                                  pixelsHigh: 1,
                                  bitsPerSample: 8,
                                  samplesPerPixel: 4,
                                  hasAlpha: true,
                                  isPlanar: false,
                                  colorSpaceName: .deviceRGB,
                                  bytesPerRow: 0,
                                  bitsPerPixel: 0)!
    bitmap.setColor(.red, atX: 0, y: 0)
    let image = NSImage(size: NSSize(width: 1, height: 1))
    image.addRepresentation(bitmap)
    return image
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
                let writablePasteboard = makeWritablePasteboard()

                data.write(to: writablePasteboard)

                expect(writablePasteboard.string(forType: .string)) == "hello"
            }

            it("Writes rich text data back to the pasteboard") {
                let rtfData = Data("{\\rtf1 hello}".utf8)
                var pasteboard = MockPasteboard()
                pasteboard.dataValues[.rtf] = rtfData
                let data = CPYClipData(pasteboard: pasteboard, types: [.rtf])
                let writablePasteboard = makeWritablePasteboard()

                data.write(to: writablePasteboard)

                expect(writablePasteboard.data(forType: .rtf)) == rtfData
            }

            it("Writes PDF data back to the pasteboard") {
                let pdfData = makePDFData()
                var pasteboard = MockPasteboard()
                pasteboard.dataValues[.pdf] = pdfData
                let data = CPYClipData(pasteboard: pasteboard, types: [.pdf])
                let writablePasteboard = makeWritablePasteboard()

                data.write(to: writablePasteboard)

                expect(writablePasteboard.data(forType: .pdf)).toNot(beNil())
            }

            it("Writes image data back to the pasteboard") {
                var pasteboard = MockPasteboard()
                pasteboard.objects = [makeTestImage()]
                let data = CPYClipData(pasteboard: pasteboard, types: [.tiff])
                let writablePasteboard = makeWritablePasteboard()

                data.write(to: writablePasteboard)

                expect(writablePasteboard.data(forType: .tiff)).toNot(beNil())
            }

            it("Writes multiple file URLs back to the pasteboard as separate objects") {
                let fileNames = ["/tmp/clipiero-a.txt", "/tmp/clipiero-b.txt"]
                var pasteboard = MockPasteboard()
                pasteboard.propertyLists[.legacyFilenames] = fileNames
                let data = CPYClipData(pasteboard: pasteboard, types: [.fileURL])
                let writablePasteboard = makeWritablePasteboard()

                data.write(to: writablePasteboard)

                let urls = writablePasteboard.pasteboardItems?
                    .compactMap { $0.string(forType: .fileURL) }
                    .compactMap(URL.init(string:))
                expect(urls?.map { $0.path }) == fileNames
            }

            it("Writes URLs back to the pasteboard as URL objects") {
                let urlString = "https://clipy-app.com/"
                var pasteboard = MockPasteboard()
                pasteboard.strings[.URL] = urlString
                let data = CPYClipData(pasteboard: pasteboard, types: [.URL])
                let writablePasteboard = makeWritablePasteboard()

                data.write(to: writablePasteboard)

                let urls = writablePasteboard
                    .readObjects(forClasses: [NSURL.self], options: nil)?
                    .compactMap { object -> URL? in
                        if let url = object as? URL { return url }
                        return (object as? NSURL).map { $0 as URL }
                    }
                expect(urls?.first?.absoluteString) == urlString
            }

        }

    }
}
