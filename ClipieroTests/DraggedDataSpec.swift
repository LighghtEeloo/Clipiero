import Foundation
import Quick
import Nimble
@testable import Clipiero

class DraggedDataSpec: QuickSpec {
    override class func spec() {

        describe("NSCoding") {

            it("Archive data") {
                let draggedData = CPYDraggedData(type: .folder, folderIdentifier: NSUUID().uuidString, snippetIdentifier: nil, index: 10)
                let data = draggedData.archive()

                let unarchiveData = NSKeyedUnarchiver.clipieroUnarchiveObject(ofType: CPYDraggedData.self, from: data)
                expect(unarchiveData).toNot(beNil())
                expect(unarchiveData?.type) == draggedData.type
                expect(unarchiveData?.folderIdentifier) == draggedData.folderIdentifier
                expect(unarchiveData?.snippetIdentifier).to(beNil())
                expect(unarchiveData?.index) == draggedData.index
            }

        }

    }
}
