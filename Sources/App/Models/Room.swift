import Vapor
import Foundation

class Room {
    
    var connections:[String:WebSocket] = [:]
    
    func bot(message:String) throws  {
        try sendMessage(user: "ChatBot", message: message)
    }
    
    func sendMessage(user:String,message:String) throws {
        let jsonText = ["username":user,"message":message]
        let error = NSError()
        do {
            let jsonData: Data = try JSONSerialization.data(withJSONObject: jsonText, options: JSONSerialization.WritingOptions.prettyPrinted) as Data
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            
            for (username,socket) in self.connections {
                try socket.send(jsonString)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
