//
//  BoringExtensionProtocol.swift
//  BoringClipboard
//
//  Must match the main app’s `BoringExtensionProtocol.swift` (same `@objc` name and `bn_*` selectors).
//

import AppKit

@objc(BoringExtensionProtocol)
public protocol BoringExtensionProtocol: NSObjectProtocol {
    @objc static func bn_extensionIdentifier() -> String
    @objc static func bn_displayName() -> String
    @objc static func bn_iconSymbol() -> String
    @objc static func bn_extensionVersion() -> String
    @objc func bn_makeContentView() -> NSView
}
