//
//  ClipboardExtension.swift
//  BoringClipboard
//
//  Principal class of the BoringClipboard bundle.
//  NSPrincipalClass in Info.plist must be "BoringClipboardExtension".
//

import AppKit
import SwiftUI

@objc(BoringClipboardExtension)
public class ClipboardExtension: NSObject, BoringExtensionProtocol {
    @objc public static func bn_extensionIdentifier() -> String { "dev.boringnotch.clipboard" }
    @objc public static func bn_displayName() -> String { "Clipboard" }
    @objc public static func bn_iconSymbol() -> String { "clipboard" }
    @objc public static func bn_extensionVersion() -> String { "1.0.3" }

    @objc public func bn_makeContentView() -> NSView {
        NSHostingView(rootView: ClipboardView())
    }
}
