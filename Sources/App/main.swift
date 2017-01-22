import Vapor
import Foundation

let drop = Droplet()

let room = Room() //init chat room

drop.get("stats") { req in
    let stringArray = Array(room.connections.keys)
    return try JSON(["users":stringArray.makeNode(),"userCount":Node(room.connections.count)])
    
}

//MARK: - JSON

func convertToDictionary(string:String) -> [String:Any]? {
    if let textData = string.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: textData, options: []) as? [String:Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

//MARK: - Sockets

drop.socket("chat") { req, ws in
    var username:String? = nil
    
    print("new socket")
    
    try background {
        while ws.state == .open {
            try? ws.ping()
            drop.console.wait(seconds: 2) // every 2 seconds
        }
    }
    
    ws.onText = { ws,text in
        let json = convertToDictionary(string: text)
        if let user = json?["username"] as? String {
            username = user
            room.connections[user] = ws
            try room.bot(message: "\(user) has joined.")
        }
        
        if let message = json?["message"] {
            print("got message \(username!):\(message)")
            try room.sendMessage(user: username!, message: message as! String)
        }
    }
    
    ws.onClose = { ws, _ , _, _ in
        guard let user = username else {
            return
        }
        print("userleft:\(username!)")
        
        try room.bot(message: "\(user) has left.")
        room.connections.removeValue(forKey: user)
    }
    
}

drop.run()
