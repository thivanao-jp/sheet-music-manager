import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            SheetMusicListView()
                .tabItem {
                    Label("楽譜", systemImage: "music.note.list")
                }

            NavigationStack {
                TagManagementView()
            }
            .tabItem {
                Label("タグ管理", systemImage: "tag")
            }
        }
    }
}

struct SheetMusicListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SheetMusic.updatedAt, order: .reverse) private var sheetMusics: [SheetMusic]
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @State private var showingAddSheet = false
    @State private var selectedTags: Set<PersistentIdentifier> = []
    @State private var showingFilter = false

    private var filteredSheetMusics: [SheetMusic] {
        if selectedTags.isEmpty {
            return sheetMusics
        }
        return sheetMusics.filter { sheet in
            selectedTags.allSatisfy { tagID in
                sheet.tags.contains(where: { $0.persistentModelID == tagID })
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // フィルターチップ表示
                if !selectedTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(allTags.filter { selectedTags.contains($0.persistentModelID) }) { tag in
                                HStack(spacing: 4) {
                                    Text(tag.name)
                                        .font(.caption)
                                    Button {
                                        selectedTags.remove(tag.persistentModelID)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption2)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.15))
                                .foregroundStyle(Color.accentColor)
                                .clipShape(Capsule())
                            }

                            Button("クリア") {
                                selectedTags.removeAll()
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemGroupedBackground))
                }

                // メインコンテンツ
                Group {
                    if filteredSheetMusics.isEmpty {
                        ContentUnavailableView(
                            selectedTags.isEmpty ? "楽譜がありません" : "該当する楽譜がありません",
                            systemImage: "music.note.list",
                            description: Text(selectedTags.isEmpty ? "＋ボタンから楽譜を追加しましょう" : "フィルター条件を変更してください")
                        )
                    } else {
                        List {
                            ForEach(filteredSheetMusics) { sheet in
                                NavigationLink(destination: SheetMusicDetailView(sheetMusic: sheet)) {
                                    SheetMusicRow(sheetMusic: sheet)
                                }
                            }
                            .onDelete(perform: deleteSheetMusics)
                        }
                    }
                }
            }
            .navigationTitle("楽譜一覧")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingFilter.toggle() }) {
                        Image(systemName: selectedTags.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    }
                    .disabled(allTags.isEmpty)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddSheetMusicView()
            }
            .sheet(isPresented: $showingFilter) {
                TagFilterView(selectedTags: $selectedTags)
            }
        }
    }

    private func deleteSheetMusics(at offsets: IndexSet) {
        let targets = filteredSheetMusics
        for index in offsets {
            modelContext.delete(targets[index])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [SheetMusic.self, Tag.self], inMemory: true)
}
