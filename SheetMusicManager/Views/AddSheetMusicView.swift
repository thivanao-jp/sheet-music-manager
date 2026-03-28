import SwiftUI
import SwiftData

struct AddSheetMusicView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var allTags: [Tag]

    @State private var title = ""
    @State private var memo = ""
    @State private var selectedTags: Set<PersistentIdentifier> = []

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("タイトル（例: ベートーヴェン第九 Vn1）", text: $title)
                    TextField("メモ", text: $memo, axis: .vertical)
                        .lineLimit(3...6)
                }

                if !allTags.isEmpty {
                    Section("タグ") {
                        ForEach(TagCategory.allCases, id: \.self) { category in
                            let categoryTags = allTags.filter { $0.category == category }
                            if !categoryTags.isEmpty {
                                DisclosureGroup(category.rawValue) {
                                    ForEach(categoryTags) { tag in
                                        Toggle(tag.name, isOn: Binding(
                                            get: { selectedTags.contains(tag.persistentModelID) },
                                            set: { isOn in
                                                if isOn {
                                                    selectedTags.insert(tag.persistentModelID)
                                                } else {
                                                    selectedTags.remove(tag.persistentModelID)
                                                }
                                            }
                                        ))
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Section {
                        Text("タグがまだありません。「タグ管理」から先にタグを作成してください。")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("楽譜を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        addSheetMusic()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func addSheetMusic() {
        let tags = allTags.filter { selectedTags.contains($0.persistentModelID) }
        let sheetMusic = SheetMusic(title: title, memo: memo, tags: tags)
        modelContext.insert(sheetMusic)
        dismiss()
    }
}

#Preview {
    AddSheetMusicView()
        .modelContainer(for: [SheetMusic.self, Tag.self], inMemory: true)
}
