import Foundation
import UIKit

struct ChatMessage: Identifiable, Equatable {
    // 允许在创建时传入一个ID，如果没有则自动生成
    let id: UUID
    let text: String
    let type: MessageType
    var image: UIImage? = nil 
    
    init(id: UUID = UUID(), text: String, type: MessageType, image: UIImage? = nil) {
        self.id = id
        self.text = text
        self.type = type
        self.image = image
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        // 只比较 ID 就够了，效率高
        return lhs.id == rhs.id && lhs.text == rhs.text
    }
}

enum MessageType {
    case sent
    case received
}
