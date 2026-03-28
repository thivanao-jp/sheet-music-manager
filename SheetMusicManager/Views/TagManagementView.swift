import SwiftUI
import SwiftData

struct TagManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var tags: [Tag]
    @State private var showingAddTag = false

    var body: some View {
        List {
            ForEach(TagCategory.allCases, id: \.self) { category in
                let categoryTags = tags.filter { $0.category == category }
                Section(category.rawValue) {
                    if categoryTags.isEmpty {
                        Text("タグなし")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(categoryTags) { tag in
                            HStack {
                                Text(tag.name)
                                Spacer()
                                Text("\(tag.sheetMusics.count)件")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                        }
                        .onDelete { offsets in
                            deleteTags(categoryTags: categoryTags, at: offsets)
                        }
                    }
                }
            }
        }
        .navigationTitle("タグ管理")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddTag = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTag) {
            AddTagView()
        }
    }

    private func deleteTags(categoryTags: [Tag], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(categoryTags[index])
        }
    }
}

struct AddTagView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var category: TagCategory = .instrument

    var body: some View {
        NavigationStack {
            Form {
                TextField("タグ名", text: $name)
                Picker("カテゴリ", selection: $category) {
                    ForEach(TagCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
            }
            .navigationTitle("タグを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        let tag = Tag(name: name, category: category)
                        modelContext.insert(tag)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TagManagementView()
    }
    .modelContainer(for: [SheetMusic.self, Tag.self], inMemory: true)
}
