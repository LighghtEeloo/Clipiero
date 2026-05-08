//
//  SnippetXMLService.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Codex on 2026/05/08.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Foundation
import AEXML
import RealmSwift

struct SnippetXMLService {

    // MARK: - Import
    func importedFolders(from data: Data, startingIndex: Int) throws -> [CPYFolder] {
        var options = AEXMLOptions()
        options.parserSettings.shouldTrimWhitespace = false
        let xmlDocument = try AEXMLDocument(xml: data, options: options)

        return xmlDocument[Constants.Xml.rootElement]
            .children
            .enumerated()
            .map { offset, folderElement in
                makeFolder(from: folderElement, index: startingIndex + offset)
            }
    }

    // MARK: - Export
    func exportData<FolderSequence: Sequence>(from folders: FolderSequence) -> Data? where FolderSequence.Element == CPYFolder {
        let xmlDocument = AEXMLDocument()
        let rootElement = xmlDocument.addChild(name: Constants.Xml.rootElement)

        folders.forEach { folder in
            let folderElement = rootElement.addChild(name: Constants.Xml.folderElement)
            folderElement.addChild(name: Constants.Xml.titleElement, value: folder.title)

            let snippetsElement = folderElement.addChild(name: Constants.Xml.snippetsElement)
            folder.snippets
                .sorted(byKeyPath: #keyPath(CPYSnippet.index), ascending: true)
                .forEach { snippet in
                    let snippetElement = snippetsElement.addChild(name: Constants.Xml.snippetElement)
                    snippetElement.addChild(name: Constants.Xml.titleElement, value: snippet.title)
                    snippetElement.addChild(name: Constants.Xml.contentElement, value: snippet.content)
                }
        }

        return xmlDocument.xml.data(using: .utf8)
    }

    // MARK: - Private
    private func makeFolder(from folderElement: AEXMLElement, index: Int) -> CPYFolder {
        let folder = CPYFolder()
        folder.title = folderElement[Constants.Xml.titleElement].value ?? "untitled folder"
        folder.index = index

        folderElement[Constants.Xml.snippetsElement][Constants.Xml.snippetElement]
            .all?
            .enumerated()
            .forEach { snippetIndex, snippetElement in
                let snippet = CPYSnippet()
                snippet.title = snippetElement[Constants.Xml.titleElement].value ?? "untitled snippet"
                snippet.content = snippetElement[Constants.Xml.contentElement].value ?? ""
                snippet.index = snippetIndex
                folder.snippets.append(snippet)
            }

        return folder
    }
}
