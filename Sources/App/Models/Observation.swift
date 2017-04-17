import Vapor
import FluentMongo
import VaporMongo
import Fluent
import Foundation

final class Observation: Model {
    var id: Node?
    var user: String
    var content: String
    var latitude: Double
    var longitude: Double
    var exists: Bool = false
    
    
    init(user: String, content: String, lat: Double, long: Double) {
        self.content = content
        self.user = user
        self.latitude = lat
        self.longitude = long
    }

    init(node: Node, in context: Context) throws {
        user = try node.extract("user")
        content = try node.extract("content")
        latitude = try node.extract("latitude")
        longitude = try node.extract("longitude")
        
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": self.id.extract(),
            "user" : user,
            "content": content,
            "latitude": latitude,
            "longitude": longitude
        ])
    }
}
extension Observation: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self.entity) { observation in
            observation.id()
            observation.string("user")
            observation.string("content")
            observation.string("latitude")
            observation.string("longitude")
        }
    }

    static func revert(_ database: Database) throws {
//        try database.delete(self.entity)
    }
}
