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

    /// Recreated when chat URL changes — previously a `let` frozen at first access.
    private var manager: SocketManager?
    private var handlersRegistered = false
    private var connectHandlerRegistered = false
    /// Remembers last connect mode so reconnect / connect callback joins the right room.
    private var isExchangeChat = false
    var delegate: SocketDelegate?

    /// Active socket client (always use this, not a stale manager).
    var socket: SocketIOClient {
        return currentManager().defaultSocket
    }

    override init() {
        super.init()
    }

    private func resolvedChatURL() -> URL {
        let raw = UserDefaultModule.shared.getchaturl()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let fallback = chatURL.isEmpty ? "https://batner.cz:2087" : chatURL
        let urlString = raw.isEmpty ? fallback : raw
        print("SocketIO → connecting to: \(urlString)")
        return URL(string: urlString) ?? URL(string: "https://batner.cz:2087")!
    }

    @discardableResult
    private func currentManager() -> SocketManager {
        let url = resolvedChatURL()
        if let existing = manager, existing.socketURL == url {
            return existing
        }

        // Tear down old connection if URL changed
        manager?.defaultSocket.disconnect()
        handlersRegistered = false
        connectHandlerRegistered = false

        // Server is socket.io 2.x (same as browser socket.io-client@2.5.0).
        // Do NOT force websockets-only — let Engine.IO poll then upgrade (more reliable on iOS).
        let newManager = SocketManager(
            socketURL: url,
            config: [
                .log(true),
                .compress,
                .secure(true),
                .reconnects(true),
                .reconnectAttempts(-1),
                .forceNew(true),
                .connectParams(["EIO": "3"])
            ]
        )
        manager = newManager
        return newManager
    }

    func connect(_ isExchange: Bool) {
        isExchangeChat = isExchange
        let client = socket

        if !handlersRegistered {
            addHandler()
            handlersRegistered = true
        }

        if !connectHandlerRegistered {
            client.on(clientEvent: .connect) { [weak self] (data, ack) in
                guard let self = self else { return }
                print("Socket Connected — id: \(client.sid ?? "nil")")
                self.joinSocket(exchage_type: self.isExchangeChat)
            }
            client.on(clientEvent: .error) { (data, ack) in
                print("Socket Error: \(data)")
            }
            client.on(clientEvent: .disconnect) { (data, ack) in
                print("Socket Disconnected: \(data)")
            }
            client.on(clientEvent: .reconnect) { (data, ack) in
                print("Socket Reconnecting: \(data)")
            }
            connectHandlerRegistered = true
        }

        switch client.status {
        case .connected:
            joinSocket(exchage_type: isExchange)
        case .connecting:
            print("Socket already connecting…")
        default:
            client.connect()
        }
    }

    func establishConnection() {
        disconnect()
        self.connect(false)
    }

    func sendMsg(requestDict:NSDictionary) {
        print("SEND MSG \(requestDict)")
    }

    func disconnect() {
        self.offSocketEvents()
        manager?.defaultSocket.disconnect()
        handlersRegistered = false
        connectHandlerRegistered = false
    }

    func offSocketEvents() {
        guard let client = manager?.defaultSocket else { return }
        client.off(MESSAGE_TYPEING_ON)
        client.off(MESSAGE_ON)
        client.off(EX_MESSAGE_TYPEING_ON)
        client.off(EX_MESSAGE_ON)
    }

    func addHandler() {
        let client = socket

        client.on("messageTyping") { (data, ack) in
            print(data)
            let json = JSON(data)
            if json.count > 0 {
                self.delegate?.getSocketInfo(dict: json[0], type: "messageTyping")
            }
        }
        client.on("message") { (data, ack) in
            print("hello: \(data)")
            let json = JSON(data)
            print(json)
            if json.count > 0 {
                self.delegate?.getSocketInfo(dict: json[0], type: "message")
            }
        }
        client.on(EX_MESSAGE_TYPEING_ON) { (data, ack) in
            print(data)
            let json = JSON(data)
            if json.count > 0 {
                self.delegate?.getSocketInfo(dict: json[0], type: "messageTyping")
            }
        }
        client.on(EX_MESSAGE_ON) { (data, ack) in
            print("hello: \(data)")
            let json = JSON(data)
            print(json)
            if json.count > 0 {
                self.delegate?.getSocketInfo(dict: json[0], type: "message")
            }
        }
    }

    func joinSocket(exchage_type: Bool) {
        let joinId = UserDefaultModule.shared.getUserData()?.userName ?? ""
        guard !joinId.isEmpty else {
            print("Socket join skipped — empty username")
            return
        }
        let dict = ["joinid": joinId]
        print("Socket join → \(joinId) exchange=\(exchage_type)")
        if !exchage_type {
            self.socket.emit("join", dict)
        }
        else {
            self.socket.emit("exchangejoin", dict)
        }
    }

    func joinSockets(_ join_id: String) {
        let dict = [["join_id": join_id]]
        self.socket.emit("join", dict)
    }

    func endCall(_ room_id: String) {
        let dict = ["room_id": room_id]
        self.socket.emit("bye", dict)
    }

    func RTCMessage(_ user_id: String, receiver_id: String, type: String, room_id: String) {
        let dict = ["user_id": user_id, "receiver_id":receiver_id, "type": type]
        let msgDict: [String : Any] = ["room": room_id, "message": dict]
        self.socket.emit("rtcmessage", msgDict)
    }

    func typingStatus(_ sender_id: String, receiver_id: String, type: String) {
        let dict = ["sender_id": sender_id, "receiver_id": receiver_id, "message": type]
        self.socket.emit("typing", dict)
    }

    func chatMessage(message: String, userImage: String, userName: String, type: String, messageContent: String, lat: String, lon: String, view_url: String, offerId: String, senderId: String, exchage_type: Bool, chatTime: Int, audio_duration: String, chatURL: String) {
        // Hitasoft socket server supports two client formats:
        // 1) Mobile (original): receiverId = ME, senderId = OTHER  → server routes via senderId
        // 2) Web:              receiver = OTHER, sender = ME       → server routes via receiver
        // Emit both so routing works with either branch.
        let myUserName = UserDefaultModule.shared.getUserData()?.userName ?? ""
        let otherUserName = senderId // caller passes chat-partner username here
        let photo = userImage.isEmpty ? (UserDefaultModule.shared.getUserData()?.photo ?? "") : userImage
        let normalizedChatURL = Self.normalizedChatPath(chatURL)

        let dict: [String : Any] = [
            "message": message,
            "userImage": photo,
            "userName": myUserName,
            "type": type,
            "messageContent": messageContent,
            "lat": lat,
            "lon": lon,
            "view_url": view_url,
            "chatTime": chatTime,
            "audio_duration": audio_duration,
            "chatURL": normalizedChatURL,
            "offer_id": ""
        ]

        let offerValue: Any = Int(offerId) ?? offerId

        if !exchage_type {
            let msgDict: [String : Any] = [
                "message": dict,
                // Web format
                "receiver": otherUserName,
                "sender": myUserName,
                // Original mobile format (required by Node join rooms)
                "receiverId": myUserName,
                "senderId": otherUserName,
                "offerId": offerValue,
                "type": type
            ]
            print("Socket emit message → receiver/sender=\(otherUserName)/\(myUserName) receiverId/senderId=\(myUserName)/\(otherUserName)")
            self.socket.emit("message", msgDict)
        }
        else {
            let msgDict: [String : Any] = [
                "message": dict,
                "receiver": otherUserName,
                "sender": myUserName,
                "receiverId": myUserName,
                "senderId": otherUserName,
                "sourceId": offerId,
                "type": type
            ]
            print("Socket emit exmessage → \(msgDict)")
            self.socket.emit("exmessage", msgDict)
        }
    }

    func messageTyping(message: String, senderId: String, exchage_type: Bool, sourceId: String = "") {
        let myUserName = UserDefaultModule.shared.getUserData()?.userName ?? ""
        let otherUserName = senderId
        var msgDict: [String : Any] = [
            "message": message,
            // Web
            "receiver": otherUserName,
            "sender": myUserName,
            // Mobile original
            "receiverId": myUserName,
            "senderId": otherUserName
        ]
        if !exchage_type {
            self.socket.emit(MESSAGE_TYPING_EMIT, msgDict)
        }
        else {
            msgDict["sourceId"] = sourceId
            self.socket.emit(EX_MESSAGE_TYPING_EMIT, msgDict)
        }
    }

    /// Web sends "/message/XXXX"; API may return a full URL — normalize to path.
    private static func normalizedChatPath(_ chatURL: String) -> String {
        let trimmed = chatURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }
        if trimmed.hasPrefix("/") {
            return trimmed
        }
        if let url = URL(string: trimmed) {
            let path = url.path
            if !path.isEmpty {
                return path
            }
        }
        if let range = trimmed.range(of: "/message/") {
            return String(trimmed[range.lowerBound...])
        }
        return trimmed
    }

}
