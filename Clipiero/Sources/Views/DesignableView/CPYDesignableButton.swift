//
//  CPYDesignableButton.swift
//
//  Clipiero
//  GitHub: https://github.com/LighghtEeloo/Clipiero
//  HP: https://github.com/LighghtEeloo/Clipiero
//
//  Created by Econa77 on 2016/02/26.
//
//  Copyright © 2015-2018 Clipiero Project.
//

import Cocoa

class CPYDesignableButton: NSButton {

    @IBInspectable var textColor: NSColor = .labelColor

    // MARK: - Initialize
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    private func initView() {
        let attributedString = NSAttributedString(string: title, attributes: [.foregroundColor: textColor])
        attributedTitle = attributedString
    }
}
