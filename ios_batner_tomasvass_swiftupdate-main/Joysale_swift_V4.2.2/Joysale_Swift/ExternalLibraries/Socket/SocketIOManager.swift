//
//  SocketIOManager.swift
//  Howzu_swift
//
//  Created by Hitasoft on 26/04/20.
//  Copyright © 2020 Hitasoft. All rights reserved.
//

import SocketIO
import SwiftyJSON

protocol SocketDelegate {
    func getSocketInfo(dict:JSON, type: String)
}

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    let socket = SocketManager(socketURL: URL(string: UserDefaultModule.shared.getchaturl() ?? "https://batner.com:2087")!, config: [.log(true), .compress])
    var delegate: SocketDelegate?
    
    override init() {
        super.init()
    }
    func connect(_ isExchange: Bool) {
        
        if socket.status == .notConnected || socket.status == .disconnected{
            
            addHandler()
            socket.defaultSocket.connect()
            socket.defaultSocket.on(clientEvent: .connect) { (data, ack) in
                print("Socket Connected")
                SocketIOManager.sharedInstance.joinSocket(exchage_type: isExchange)
            }
        }
        else {
            
            SocketIOManager.sharedInstance.joinSocket(exchage_type: isExchange)
        }
     }
    func establishConnection() {
        disconnect()
        self.connect(false)
    }
    func sendMsg(requestDict:NSDictionary) {
        print("SEND MSG \(requestDict)")
       // Socket.defaultSocket.emit("message", requestDict)
    }
    
    //disconnect socet
    func disconnect()  {
        self.offSocketEvents()
        socket.defaultSocket.disconnect()
    }
    //off all sockets
    func offSocketEvents()  {
        socket.defaultSocket.off(MESSAGE_TYPEING_ON)
        socket.defaultSocket.off(MESSAGE_ON)
        socket.defaultSocket.off(EX_MESSAGE_TYPEING_ON)
        socket.defaultSocket.off(EX_MESSAGE_ON)
    }
    func addHandler() {
        

        self.socket.defaultSocket.on("messageTyping") { (data, ack) in
            print(data)
            let json = JSON(data)
            if json.count > 0 {
                self.delegate?.getSocketInfo(dict: json[0], type: "messageTyping")
            }
        }
        self.socket.defaultSocket.on("message") { (data, ack) in
            print("hello: \(data)")
            let json = JSON(data)
            print(json)
            if json.count > 0 {
                self.delegate?.getSocketInfo(dict: json[0], type: "message")
            }
        }
        self.socket.defaultSocket.on(EX_MESSAGE_TYPEING_ON) { (data, ack) in
            print(data)
            let json = JSON(data)
            if json.count > 0 {
                self.delegate?.getSocketInfo(dict: json[0], type: "messageTyping")
            }
        }
        self.socket.defaultSocket.on(EX_MESSAGE_ON) { (data, ack) in
            print("hello: \(data)")
            let json = JSON(data)
            print(json)
            if json.count > 0 {
                self.delegate?.getSocketInfo(dict: json[0], type: "message")
            }
        }
    }
    
    func joinSocket(exchage_type: Bool) {
        let dict = ["joinid": (UserDefaultModule.shared.getUserData()?.userName ?? "")]
        if !exchage_type {
            self.socket.defaultSocket.emit("join", dict)
        }
        else {
            self.socket.defaultSocket.emit("exchangejoin", dict)
        }
    }
    func joinSockets(_ join_id: String) {
        let dict = [["join_id": join_id]]
        self.socket.defaultSocket.emit("join", dict)
    }
    func endCall(_ room_id: String) {
        let dict = ["room_id": room_id]
        self.socket.defaultSocket.emit("bye", dict)
    }
    func RTCMessage(_ user_id: String, receiver_id: String, type: String, room_id: String) {
        let dict = ["user_id": user_id, "receiver_id":receiver_id, "type": type]
        let msgDict: [String : Any] = ["room": room_id, "message": dict]
        self.socket.defaultSocket.emit("rtcmessage", msgDict)
    }
    func typingStatus(_ sender_id: String, receiver_id: String, type: String) {
        let dict = ["sender_id": sender_id, "receiver_id": receiver_id, "message": type]
        self.socket.defaultSocket.emit("typing", dict)
    }
    func chatMessage(message: String, userImage: String, userName: String, type: String, messageContent: String, lat: String, lon: String, view_url: String, offerId: String, senderId: String, exchage_type: Bool, chatTime: Int, audio_duration: String, chatURL: String) {
        let dict: [String : Any] = ["message": message, "userImage":(UserDefaultModule.shared.getUserData()?.photo ?? ""), "userName": (UserDefaultModule.shared.getUserData()?.userName ?? ""), "type": type, "messageContent": messageContent, "lat": lat, "lon": lon, "view_url": view_url, "chatTime": chatTime, "audio_duration": audio_duration, "chatURL": chatURL]
        if !exchage_type {
            let msgDict: [String : Any] = ["message": dict, "receiverId": (UserDefaultModule.shared.getUserData()?.userName ?? ""), "senderId": senderId, "offerId": offerId,"type": type]
            self.socket.defaultSocket.emit("message", msgDict)
        }
        else {
            let msgDict: [String : Any] = ["message": dict, "receiverId": (UserDefaultModule.shared.getUserData()?.userName ?? ""), "senderId": senderId, "sourceId": offerId,"type": type]
            self.socket.defaultSocket.emit("exmessage", msgDict)
        }
    }
    func messageTyping(message: String, senderId: String, exchage_type: Bool, sourceId: String = "") {
        var msgDict: [String : Any] = ["message": message, "receiverId": (UserDefaultModule.shared.getUserData()?.userName ?? ""), "senderId": senderId]
        if !exchage_type {
            self.socket.defaultSocket.emit(MESSAGE_TYPING_EMIT, msgDict)
        }
        else {
            msgDict["sourceId"] = sourceId
            self.socket.defaultSocket.emit(EX_MESSAGE_TYPING_EMIT, msgDict)
        }
    }

}
