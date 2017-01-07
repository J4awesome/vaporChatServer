import Vapor
import Foundation
import HTTP

let drop = Droplet()

drop.get { req in
    return Response(status: .ok, headers: ["Content-Type": "text/html"], body: "<html><p>Looking for the wrong thing</p></html>")
}

//MARK: - JSON

func convertToDictionary(string:String) -> [String:Any]? {
    if let textData = string.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: textData, options: []) as! [String:Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

//MARK: - Sockets

let room = Room() //init chat room

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
            print(username!,message)
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
