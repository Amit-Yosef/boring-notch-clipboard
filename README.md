# Boring Notch — Clipboard History Extension

A searchable clipboard history panel for [Boring Notch](https://github.com/TheBoredTeam/boring.notch).

## Features

- Monitors `NSPasteboard` every 0.5 s automatically
- Stores up to 50 unique text entries (newest first)
- Inline search / filter
- Tap any row (or click the copy icon) to paste back to clipboard
- Right-click → Delete to remove individual entries
- Confirmation checkmark animation on copy
- Relative timestamps ("2 min ago")

## Install

In Boring Notch **Settings → Extensions**, paste:

```
https://github.com/<your-username>/boring-notch-clipboard
```

## Building from Source

### Prerequisites

- Xcode 16+
- macOS 14+

### Steps

1. Open `BoringClipboard.xcodeproj` in Xcode.
2. Select the **BoringClipboard** scheme with the **My Mac** destination.
3. Product → Build (`⌘B`).

### Xcode Project Setup (if creating from scratch)

1. **File → New → Project → macOS → Bundle**
2. Product Name: `BoringClipboard`
3. Language: Swift
4. Set deployment target to macOS 14.0
5. Add all files from `Sources/BoringClipboard/`
6. In `Info.plist`, add:
   ```xml
   <key>NSPrincipalClass</key>
   <string>BoringClipboardExtension</string>
   ```

### Release

Push a tag (`git tag v1.0.0 && git push --tags`).
The GitHub Actions workflow builds the bundle, ad-hoc signs it, zips it,
and attaches it to the release alongside `boring-extension.json`.

## Extension Protocol Contract

```swift
@objc(BoringClipboardExtension)
public class ClipboardExtension: NSObject, BoringExtensionProtocol {
    public static let extensionID = "dev.boringnotch.clipboard"
    public static let displayName = "Clipboard"
    public static let iconSymbol  = "clipboard"
    public static let version     = "1.0.0"

    public func makeContentView() -> NSView {
        NSHostingView(rootView: ClipboardView())
    }
}
```
