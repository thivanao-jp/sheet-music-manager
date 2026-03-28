import SwiftUI

struct SheetMusicRow: View {
    let sheetMusic: SheetMusic

    var body: some View {
        HStack(spacing: 12) {
            // サムネイル
            if let imageData = sheetMusic.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "music.note")
                            .foregroundStyle(.gray)
                    }
            }

            // タイトルとタグ
            VStack(alignment: .leading, spacing: 4) {
                Text(sheetMusic.title)
                    .font(.body)
                    .lineLimit(1)

                if !sheetMusic.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(sheetMusic.tags.prefix(3)) { tag in
                            Text(tag.name)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(tagColor(for: tag.category).opacity(0.15))
                                .foregroundStyle(tagColor(for: tag.category))
                                .clipShape(Capsule())
                        }
                        if sheetMusic.tags.count > 3 {
                            Text("+\(sheetMusic.tags.count - 3)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func tagColor(for category: TagCategory) -> Color {
        switch category {
        case .instrument: return .blue
        case .piece: return .orange
        case .concert: return .green
        case .other: return .gray
        }
    }
}
