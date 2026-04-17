//
//  ClipboardMonitor.swift
//  BoringClipboard
//
//  Polls NSPasteboard.general every 0.5 s for new text items.
//  Stores up to 50 unique entries (newest first).
//

import AppKit
import Combine

struct ClipboardItem: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let date: Date

    var preview: String {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstLine = cleaned.components(separatedBy: "\n").first ?? cleaned
        return firstLine
    }
}

@MainActor
class ClipboardMonitor: ObservableObject {
    static let shared = ClipboardMonitor()

    @Published var items: [ClipboardItem] = []

    private let maxItems = 50
    private var lastChangeCount: Int = -1
    private var pollTask: Task<Void, Never>?

    private init() {}

    func start() {
        guard pollTask == nil else { return }
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.check()
                try? await Task.sleep(for: .milliseconds(500))
            }
        }
    }

    func stop() {
        pollTask?.cancel()
        pollTask = nil
    }

    private func check() {
        let pb = NSPasteboard.general
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount

        guard let text = pb.string(forType: .string),
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }

        // Avoid exact duplicates — remove existing matching entry, then prepend
        items.removeAll { $0.text == text }
        items.insert(ClipboardItem(text: text, date: Date()), at: 0)

        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
    }

    func copyToPasteboard(_ item: ClipboardItem) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(item.text, forType: .string)
        // Prevent the monitor from re-adding the same item it just set
        lastChangeCount = pb.changeCount
    }

    func delete(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
    }

    func clear() {
        items.removeAll()
    }
}
