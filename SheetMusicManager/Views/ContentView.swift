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
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if sheetMusics.isEmpty {
                    ContentUnavailableView(
                        "楽譜がありません",
                        systemImage: "music.note.list",
                        description: Text("＋ボタンから楽譜を追加しましょう")
                    )
                } else {
                    List {
                        ForEach(sheetMusics) { sheet in
                            NavigationLink(destination: SheetMusicDetailView(sheetMusic: sheet)) {
                                SheetMusicRow(sheetMusic: sheet)
                            }
                        }
                        .onDelete(perform: deleteSheetMusics)
                    }
                }
            }
            .navigationTitle("楽譜一覧")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddSheetMusicView()
            }
        }
    }

    private func deleteSheetMusics(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sheetMusics[index])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [SheetMusic.self, Tag.self], inMemory: true)
}
