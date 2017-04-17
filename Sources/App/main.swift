import Vapor
import VaporMongo
import Random
import Foundation

let drop = Droplet()

try drop.addProvider(VaporMongo.Provider.self)

drop.preparations.append(Observation.self)
    
drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.resource("observations", ObservationController())

drop.post("test") { req in
    
    //this will not compile on an actual server! remove before pushing up!
    var objs = [Observation]()
    
    let name1 = ["funny","scary","uncommon","fly","critical","superfluous","round","shy"]
    let name2 = ["Guy","Girl","Hamster","Master","Troll","Dwarf","Demon","Fox","Person","Hacker"]
    let name3 = ["Flex","Red","Blue","1987","The3rd","Junior","Esq", "1337","xXx"]
    
    let tag = ["bedbugs","potholes","rats","hipsters","babies","crime","noise"]
    for _ in 0...50{
        let num1 = Int(arc4random_uniform(UInt32(name1.count)))
        let num2 = Int(arc4random_uniform(UInt32(name2.count)))
        let num3 = Int(arc4random_uniform(UInt32(name3.count)))
        let num4 = Double(arc4random_uniform(9999)) * 0.0001
        let num5 = Double(arc4random_uniform(9999)) * -0.0001
        let num0 = (num1+num2+num3) % tag.count
        let user = "\(name1[num1])\(name2[num2])\(name3[num3])"
        let content = tag[num0]
        let lat = 40.8713 + num4
        let long = -73.9169 + num5
        var obj = Observation(user: user, content: content, lat: lat, long: long)
        objs.append(obj)
        try obj.save()
    }
    
    return try objs.makeJSON()
}

drop.run()


