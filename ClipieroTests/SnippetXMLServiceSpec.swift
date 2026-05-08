import Foundation
import Quick
import Nimble
@testable import Clipiero

class SnippetXMLServiceSpec: QuickSpec {
    override class func spec() {
        describe("Snippet XML import and export") {
            let service = SnippetXMLService()

            it("imports folders and snippets with indexes") {
                let xml = """
                <folders>
                  <folder>
                    <title>Work</title>
                    <snippets>
                      <snippet>
                        <title>Email</title>
                        <content>Hello</content>
                      </snippet>
                      <snippet>
                        <title>Signature</title>
                        <content>Regards</content>
                      </snippet>
                    </snippets>
                  </folder>
                  <folder>
                    <title>Personal</title>
                    <snippets />
                  </folder>
                </folders>
                """

                let folders = try service.importedFolders(from: Data(xml.utf8), startingIndex: 4)

                expect(folders.count) == 2
                expect(folders[0].title) == "Work"
                expect(folders[0].index) == 4
                expect(folders[0].snippets.count) == 2
                expect(folders[0].snippets[0].title) == "Email"
                expect(folders[0].snippets[0].content) == "Hello"
                expect(folders[0].snippets[0].index) == 0
                expect(folders[0].snippets[1].title) == "Signature"
                expect(folders[0].snippets[1].index) == 1
                expect(folders[1].title) == "Personal"
                expect(folders[1].index) == 5
            }

            it("uses defaults for missing XML values") {
                let xml = """
                <folders>
                  <folder>
                    <snippets>
                      <snippet />
                    </snippets>
                  </folder>
                </folders>
                """

                let folders = try service.importedFolders(from: Data(xml.utf8), startingIndex: 0)

                expect(folders.first?.title) == "untitled folder"
                expect(folders.first?.snippets.first?.title) == "untitled snippet"
                expect(folders.first?.snippets.first?.content) == ""
            }

            it("exports snippets in index order") {
                let folder = CPYFolder()
                folder.title = "Ordered"

                let laterSnippet = CPYSnippet()
                laterSnippet.title = "Later"
                laterSnippet.content = "second"
                laterSnippet.index = 2

                let firstSnippet = CPYSnippet()
                firstSnippet.title = "First"
                firstSnippet.content = "first"
                firstSnippet.index = 0

                folder.snippets.append(objectsIn: [laterSnippet, firstSnippet])

                let exported = service.exportData(from: [folder])
                let imported = try service.importedFolders(from: exported!, startingIndex: 0)

                expect(imported.first?.title) == "Ordered"
                expect(imported.first?.snippets.count) == 2
                expect(imported.first?.snippets[0].title) == "First"
                expect(imported.first?.snippets[0].content) == "first"
                expect(imported.first?.snippets[1].title) == "Later"
                expect(imported.first?.snippets[1].content) == "second"
            }
        }
    }
}
