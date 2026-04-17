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
    public static let extensionID = "dev.boringnotch.clipboard"
    public static let displayName = "Clipboard"
    public static let iconSymbol  = "clipboard"
    public static let extensionVersion = "1.0.0"

    public func makeContentView() -> NSView {
        NSHostingView(rootView: ClipboardView())
    }
}
