import SwiftUI
import SwiftData

struct SheetMusicDetailView: View {
    @Bindable var sheetMusic: SheetMusic
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @State private var isEditingTitle = false
    @State private var editedTitle = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 楽譜画像
                if let imageData = sheetMusic.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 200)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "music.note")
                                    .font(.largeTitle)
                                Text("写真なし")
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }
                }

                // メモ
                VStack(alignment: .leading, spacing: 8) {
                    Text("メモ")
                        .font(.headline)
                    TextField("メモを入力", text: $sheetMusic.memo, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }

                // タグ
                VStack(alignment: .leading, spacing: 8) {
                    Text("タグ")
                        .font(.headline)

                    if sheetMusic.tags.isEmpty {
                        Text("タグなし")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        FlowLayout(spacing: 6) {
                            ForEach(sheetMusic.tags) { tag in
                                TagChip(tag: tag) {
                                    sheetMusic.tags.removeAll { $0.id == tag.id }
                                    sheetMusic.updatedAt = Date()
                                }
                            }
                        }
                    }

                    // タグ追加セクション
                    let unassignedTags = allTags.filter { tag in
                        !sheetMusic.tags.contains(where: { $0.id == tag.id })
                    }
                    if !unassignedTags.isEmpty {
                        Divider()
                        Text("タグを追加")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        FlowLayout(spacing: 6) {
                            ForEach(unassignedTags) { tag in
                                Button {
                                    sheetMusic.tags.append(tag)
                                    sheetMusic.updatedAt = Date()
                                } label: {
                                    Text("+ \(tag.name)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(sheetMusic.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct TagChip: View {
    let tag: Tag
    var onRemove: (() -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            Text(tag.name)
                .font(.caption)
            if onRemove != nil {
                Button(action: { onRemove?() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tagColor.opacity(0.15))
        .foregroundStyle(tagColor)
        .clipShape(Capsule())
    }

    private var tagColor: Color {
        switch tag.category {
        case .instrument: return .blue
        case .piece: return .orange
        case .concert: return .green
        case .other: return .gray
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
