import Foundation
import SwiftData

@Model
final class SheetMusic {
    var title: String
    var memo: String
    var imageData: Data?
    var createdAt: Date
    var updatedAt: Date
    var tags: [Tag]

    init(title: String, memo: String = "", imageData: Data? = nil, tags: [Tag] = []) {
        self.title = title
        self.memo = memo
        self.imageData = imageData
        self.createdAt = Date()
        self.updatedAt = Date()
        self.tags = tags
    }
}
