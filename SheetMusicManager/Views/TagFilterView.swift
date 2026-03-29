import SwiftUI
import SwiftData

struct TagFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @Binding var selectedTags: Set<PersistentIdentifier>

    var body: some View {
        NavigationStack {
            List {
                ForEach(TagCategory.allCases, id: \.self) { category in
                    let categoryTags = allTags.filter { $0.category == category }
                    if !categoryTags.isEmpty {
                        Section(category.rawValue) {
                            ForEach(categoryTags) { tag in
                                TagFilterRow(
                                    tag: tag,
                                    isSelected: selectedTags.contains(tag.persistentModelID),
                                    onToggle: {
                                        if selectedTags.contains(tag.persistentModelID) {
                                            selectedTags.remove(tag.persistentModelID)
                                        } else {
                                            selectedTags.insert(tag.persistentModelID)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .navigationTitle("タグで絞り込み")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !selectedTags.isEmpty {
                        Button("全解除") {
                            selectedTags.removeAll()
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }
}

private struct TagFilterRow: View {
    let tag: Tag
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(tag.name)
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(tag.sheetMusics.count)件")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
}
