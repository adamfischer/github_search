import Foundation

class Repositories : Decodable {
    var items: [Repository]
    
    init(items: [Repository]) {
        self.items = items
    }
}

class Repository : Decodable {
    class Owner : Decodable {
        let name: String
        let avatarURLString: String
        
        enum CodingKeys: String, CodingKey {
            case name = "login"
            case avatarURLString = "avatarUrl"
        }
    }
    
    let urlString: String
    let name: String
    let fullName: String
    let owner: Owner?
    let description: String?
    let programmingLanguage: String?
    let stargazersCount: Int
    var cachedAvatarImageData: Data? = nil
        
    enum CodingKeys: String, CodingKey {
        case name, fullName, owner, description, stargazersCount
        case programmingLanguage = "language"
        case urlString = "htmlUrl"
    }
}
