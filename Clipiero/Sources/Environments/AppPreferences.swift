//
//  AppPreferences.swift
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
import RxCocoa
import RxSwift

struct AppPreferences {

    // MARK: - Properties
    private let defaults: UserDefaults

    // MARK: - Initialize
    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    // MARK: - Values
    var addClearHistoryMenuItem: Bool { bool(Constants.UserDefaults.addClearHistoryMenuItem) }
    var addNumericKeyEquivalents: Bool { bool(Constants.UserDefaults.addNumericKeyEquivalents) }
    var collectCrashReport: Bool { bool(Constants.UserDefaults.collectCrashReport) }
    var copySameHistory: Bool { bool(Constants.UserDefaults.copySameHistory) }
    var inputPasteCommand: Bool { bool(Constants.UserDefaults.inputPasteCommand) }
    var loginItem: Bool { bool(Constants.UserDefaults.loginItem) }
    var maxHistorySize: Int { integer(Constants.UserDefaults.maxHistorySize) }
    var maxLengthOfToolTip: Int { integer(Constants.UserDefaults.maxLengthOfToolTip) }
    var maxMenuItemTitleLength: Int { integer(Constants.UserDefaults.maxMenuItemTitleLength) }
    var menuItemsAreMarkedWithNumbers: Bool { bool(Constants.UserDefaults.menuItemsAreMarkedWithNumbers) }
    var menuItemsTitleStartWithZero: Bool { bool(Constants.UserDefaults.menuItemsTitleStartWithZero) }
    var numberOfItemsPlaceInline: Int { integer(Constants.UserDefaults.numberOfItemsPlaceInline) }
    var numberOfItemsPlaceInsideFolder: Int { integer(Constants.UserDefaults.numberOfItemsPlaceInsideFolder) }
    var overwriteSameHistory: Bool { bool(Constants.UserDefaults.overwriteSameHistory) }
    var reorderClipsAfterPasting: Bool { bool(Constants.UserDefaults.reorderClipsAfterPasting) }
    var showAlertBeforeClearHistory: Bool { bool(Constants.UserDefaults.showAlertBeforeClearHistory) }
    var showColorPreviewInTheMenu: Bool { bool(Constants.UserDefaults.showColorPreviewInTheMenu) }
    var showIconInTheMenu: Bool { bool(Constants.UserDefaults.showIconInTheMenu) }
    var showImageInTheMenu: Bool { bool(Constants.UserDefaults.showImageInTheMenu) }
    var showToolTipOnMenuItem: Bool { bool(Constants.UserDefaults.showToolTipOnMenuItem) }
    var suppressAlertForLoginItem: Bool { bool(Constants.UserDefaults.suppressAlertForLoginItem) }
    var thumbnailHeight: Int { integer(Constants.UserDefaults.thumbnailHeight) }
    var thumbnailWidth: Int { integer(Constants.UserDefaults.thumbnailWidth) }

    var pastePlainText: Bool { bool(Constants.Beta.pastePlainText) }
    var pastePlainTextModifier: Int { integer(Constants.Beta.pastePlainTextModifier) }
    var deleteHistory: Bool { bool(Constants.Beta.deleteHistory) }
    var deleteHistoryModifier: Int { integer(Constants.Beta.deleteHistoryModifier) }
    var pasteAndDeleteHistory: Bool { bool(Constants.Beta.pasteAndDeleteHistory) }
    var pasteAndDeleteHistoryModifier: Int { integer(Constants.Beta.pasteAndDeleteHistoryModifier) }

    var storeTypes: [String: NSNumber] {
        return defaults.object(forKey: Constants.UserDefaults.storeTypes) as? [String: NSNumber] ?? [:]
    }

    // MARK: - Observables
    var loginItemChanges: Observable<Bool> {
        return observe(Bool.self, forKey: Constants.UserDefaults.loginItem)
    }

    var observerScreenshotChanges: Observable<Bool> {
        return observe(Bool.self, forKey: Constants.Beta.observerScreenshot)
    }

    var reorderClipsAfterPastingChanges: Observable<Bool> {
        return observe(Bool.self, forKey: Constants.UserDefaults.reorderClipsAfterPasting, options: [.new])
    }

    var showStatusItemChanges: Observable<Int> {
        return observe(Int.self, forKey: Constants.UserDefaults.showStatusItem)
    }

    var storeTypesChanges: Observable<[String: NSNumber]> {
        return observe([String: NSNumber].self, forKey: Constants.UserDefaults.storeTypes)
    }

    var menuChanges: Observable<Void> {
        return Observable.merge([
            observeDistinct(Bool.self, forKey: Constants.UserDefaults.addClearHistoryMenuItem),
            observeDistinct(Int.self, forKey: Constants.UserDefaults.maxHistorySize),
            observeDistinct(Bool.self, forKey: Constants.UserDefaults.showIconInTheMenu),
            observeDistinct(Int.self, forKey: Constants.UserDefaults.numberOfItemsPlaceInline),
            observeDistinct(Int.self, forKey: Constants.UserDefaults.numberOfItemsPlaceInsideFolder),
            observeDistinct(Int.self, forKey: Constants.UserDefaults.maxMenuItemTitleLength),
            observeDistinct(Bool.self, forKey: Constants.UserDefaults.menuItemsTitleStartWithZero),
            observeDistinct(Bool.self, forKey: Constants.UserDefaults.menuItemsAreMarkedWithNumbers),
            observeDistinct(Bool.self, forKey: Constants.UserDefaults.showToolTipOnMenuItem),
            observeDistinct(Bool.self, forKey: Constants.UserDefaults.showImageInTheMenu),
            observeDistinct(Bool.self, forKey: Constants.UserDefaults.addNumericKeyEquivalents),
            observeDistinct(Int.self, forKey: Constants.UserDefaults.maxLengthOfToolTip),
            observeDistinct(Bool.self, forKey: Constants.UserDefaults.showColorPreviewInTheMenu)
        ])
    }

    // MARK: - Private
    private func bool(_ key: String) -> Bool {
        return defaults.bool(forKey: key)
    }

    private func integer(_ key: String) -> Int {
        return defaults.integer(forKey: key)
    }

    private func observe<Value>(_ type: Value.Type,
                                forKey key: String,
                                options: KeyValueObservingOptions = [.new, .initial]) -> Observable<Value> {
        return defaults.rx.observe(type, key, options: options, retainSelf: false)
            .compactMap { $0 }
    }

    private func observeDistinct<Value: Equatable>(_ type: Value.Type, forKey key: String) -> Observable<Void> {
        return observe(type, forKey: key, options: [.new])
            .distinctUntilChanged()
            .map { _ in }
    }
}

extension Environment {
    var preferences: AppPreferences {
        return AppPreferences(defaults: defaults)
    }
}
