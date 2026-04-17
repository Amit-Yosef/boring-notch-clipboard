//
//  ClipboardView.swift
//  BoringClipboard
//
//  Shows clipboard history as a searchable, scrollable list.
//  Tap a row to copy back; right-click to delete.
//

import SwiftUI

struct ClipboardView: View {
    @ObservedObject private var monitor = ClipboardMonitor.shared
    @State private var searchText: String = ""
    @State private var copiedID: UUID? = nil

    private var filteredItems: [ClipboardItem] {
        if searchText.isEmpty { return monitor.items }
        return monitor.items.filter {
            $0.text.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            Divider().background(Color.white.opacity(0.12))
            content
        }
        .background(Color.black)
        .environment(\.colorScheme, .dark)
        .onAppear  { monitor.start() }
        .onDisappear { /* keep running in background so history continues */ }
    }

    // MARK: Search Bar

    private var searchBar: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
                .imageScale(.small)
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.06))
    }

    // MARK: Content

    @ViewBuilder
    private var content: some View {
        if filteredItems.isEmpty {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "clipboard")
                    .imageScale(.large)
                    .foregroundStyle(.gray)
                Text(monitor.items.isEmpty ? "Nothing copied yet" : "No matches")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
        } else {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    ForEach(filteredItems) { item in
                        ClipboardRow(
                            item: item,
                            isCopied: copiedID == item.id,
                            onCopy: { copy(item) },
                            onDelete: { monitor.delete(item) }
                        )
                        Divider().background(Color.white.opacity(0.08))
                    }
                }
            }
        }
    }

    private func copy(_ item: ClipboardItem) {
        monitor.copyToPasteboard(item)
        withAnimation(.easeIn(duration: 0.15)) { copiedID = item.id }
        Task {
            try? await Task.sleep(for: .milliseconds(1200))
            await MainActor.run {
                withAnimation { copiedID = nil }
            }
        }
    }
}

// MARK: - Row

struct ClipboardRow: View {
    let item: ClipboardItem
    let isCopied: Bool
    let onCopy: () -> Void
    let onDelete: () -> Void

    @State private var isHovering = false

    private static let dateFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.preview)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .truncationMode(.tail)

                Text(Self.dateFormatter.localizedString(for: item.date, relativeTo: Date()))
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if isCopied {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .imageScale(.small)
                    .transition(.scale.combined(with: .opacity))
            } else if isHovering {
                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc")
                        .foregroundStyle(.white.opacity(0.7))
                        .imageScale(.small)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(isHovering ? Color.white.opacity(0.06) : Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .onTapGesture { onCopy() }
        .contextMenu {
            Button("Copy", action: onCopy)
            Divider()
            Button("Delete", role: .destructive, action: onDelete)
        }
        .animation(.easeInOut(duration: 0.12), value: isHovering)
        .animation(.easeInOut(duration: 0.15), value: isCopied)
    }
}
