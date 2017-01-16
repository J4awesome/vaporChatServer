import Vapor
import Foundation

class Room {
    
    var connections:[String:WebSocket] = [:]
    
    func bot(message:String) throws  {
        try sendMessage(user: "ChatBot", message: message)
    }
    
    func sendMessage(user:String,message:String) throws {
        let jsonText = ["username":user,"message":message]
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: jsonText, options: JSONSerialization.WritingOptions.prettyPrinted) as Data
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            
            for (username,socket) in self.connections {
                try socket.send(jsonString!)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
