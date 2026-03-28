import Foundation
import SwiftData

enum TagCategory: String, Codable, CaseIterable {
    case instrument = "楽器"
    case piece = "曲"
    case concert = "演奏会"
    case other = "その他"
}

@Model
final class Tag {
    var name: String
    var category: TagCategory
    var createdAt: Date
    @Relationship(inverse: \SheetMusic.tags)
    var sheetMusics: [SheetMusic]

    init(name: String, category: TagCategory) {
        self.name = name
        self.category = category
        self.createdAt = Date()
        self.sheetMusics = []
    }
}
