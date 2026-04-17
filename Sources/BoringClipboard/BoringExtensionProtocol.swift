//
//  BoringExtensionProtocol.swift
//  BoringClipboard
//
//  Copy of the shared protocol — must match the main app's declaration exactly.
//

import AppKit

@objc public protocol BoringExtensionProtocol: NSObjectProtocol {
    static var extensionID: String { get }
    static var displayName: String { get }
    static var iconSymbol: String { get }
    static var version: String { get }
    func makeContentView() -> NSView
}
