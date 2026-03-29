import SwiftUI
import SwiftData
import PhotosUI

struct AddSheetMusicView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var allTags: [Tag]

    @State private var title = ""
    @State private var memo = ""
    @State private var selectedTags: Set<PersistentIdentifier> = []
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showingCamera = false

    var body: some View {
        NavigationStack {
            Form {
                // 写真セクション
                Section("写真") {
                    if let imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(maxWidth: .infinity)

                        Button("写真を削除", role: .destructive) {
                            self.imageData = nil
                            self.selectedPhoto = nil
                        }
                    }

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("アルバムから選択", systemImage: "photo.on.rectangle")
                    }

                    Button {
                        showingCamera = true
                    } label: {
                        Label("カメラで撮影", systemImage: "camera")
                    }
                }

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
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(imageData: $imageData)
                    .ignoresSafeArea()
            }
        }
    }

    private func addSheetMusic() {
        let tags = allTags.filter { selectedTags.contains($0.persistentModelID) }
        let sheetMusic = SheetMusic(title: title, memo: memo, imageData: imageData, tags: tags)
        modelContext.insert(sheetMusic)
        dismiss()
    }
}

#Preview {
    AddSheetMusicView()
        .modelContainer(for: [SheetMusic.self, Tag.self], inMemory: true)
}
