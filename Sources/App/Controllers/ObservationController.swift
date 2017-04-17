import Vapor
import HTTP

final class ObservationController: ResourceRepresentable {

    func create(request: Request) throws -> ResponseRepresentable {
        var observation = try request.observation()
        try observation.save()
        return observation
    }

    func show(request: Request, observation: Observation) throws -> ResponseRepresentable {
        return observation
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        print("show!")
//        if request.headers["all"] != nil {
//            return try Observation.all().makeNode().converted(to: JSON.self)
//        }
        let headerDict = request.headers
        let lat = valueAsDouble(HeaderKey.latKey, dict: headerDict)
        let latDelta = valueAsDouble(HeaderKey.latRangeKey, dict: headerDict)
        let long = valueAsDouble(HeaderKey.longKey, dict: headerDict)
        let longDelta = valueAsDouble(HeaderKey.longRangeKey, dict: headerDict)
        let content = headerDict[HeaderKey.tag]
        let user = headerDict[HeaderKey.user]
        let query = try Observation.query()
        if let lat = lat, let latDelta = latDelta,
           let long = long, let longDelta = longDelta{
             let maxLat = lat + latDelta
             let maxLong = long + longDelta
            print ("\(lat)->\(maxLat),\(long)->\(maxLong)")
            try query.filter("latitude", .in, [lat, maxLat])
            try query.filter("longitude", .in, [long, maxLong])
        }
        if let user = user{try query.filter("user", user)}
        if let content = content {try query.filter("content", content)}
        
        return try query.makeQuery().run().makeJSON()
    }

    func delete(request: Request, observation: Observation) throws -> ResponseRepresentable {
        let obs = observation
        try observation.delete()
        return try JSON(obs.makeNode())
    }

    func clear(request: Request) throws -> ResponseRepresentable {
        try Observation.query().delete()
        return JSON([:])
    }

    func update(request: Request, observation: Observation) throws -> ResponseRepresentable {
        var new = try request.observation()
        try new.save()
        return new
    }

    func replace(request: Request, observation: Observation) throws -> ResponseRepresentable {
        try observation.delete()
        return try create(request: request)
    }

    func makeResource() -> Resource<Observation> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: replace,
            modify: update,
            destroy: delete,
            clear: clear
        )
    }
    
    private func valueAsDouble(_ key: HeaderKey, dict: [HeaderKey: String])-> Double? {
        guard let value = dict[key] else { print("no key"); return nil}
        guard let myVal = Double(value) else { print("not number"); return nil}
        return myVal
    }
}

extension Request {
    func observation() throws -> Observation {
        guard let json = json else { throw Abort.badRequest }
        return try Observation(node: json)
    }
}

extension HeaderKey {
    
    static var latKey = HeaderKey.init("latitude")
    static var longKey = HeaderKey.init("longitude")
    static var latRangeKey = HeaderKey.init("lat_delta")
    static var longRangeKey = HeaderKey.init("long_delta")
    static var tag = HeaderKey.init("tag")
    static var user = HeaderKey.init("user")
    static var all = HeaderKey.init("all")
}

