//
//  Payload.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 01/10/2016.
//
//

import Foundation
import JSON

public class Payload: JSONRepresentable {
    /// The number to display as the badge of the app icon.
    var badge: Int?
    
    /// A short string describing the purpose of the notification. Apple Watch displays this string as part of the notification interface. This string is displayed only briefly and should be crafted so that it can be understood quickly. This key was added in iOS 8.2.
    var title: String?
    
    /// The text of the alert message. Can be nil if using titleLocKey
    var body: String?
    
    /// The key to a title string in the Localizable.strings file for the current localization. The key string can be formatted with %@ and %n$@ specifiers to take the variables specified in the titleLocArgs array.
    var titleLocKey: String?
    
    /// Variable string values to appear in place of the format specifiers in titleLocKey.
    var titleLocArgs: [String]?
    
    /// If a string is specified, the system displays an alert that includes the Close and View buttons. The string is used as a key to get a localized string in the current localization to use for the right button’s title instead of “View”.
    var actionLocKey: String?
    
    /// A key to an alert-message string in a Localizable.strings file for the current localization (which is set by the user’s language preference). The key string can be formatted with %@ and %n$@ specifiers to take the variables specified in the bodyLocArgs array.
    var bodyLocKey: String?
    
    /// Variable string values to appear in place of the format specifiers in bodyLocKey.
    var bodyLocArgs: [String]?
    
    /// The filename of an image file in the app bundle, with or without the filename extension. The image is used as the launch image when users tap the action button or move the action slider. If this property is not specified, the system either uses the previous snapshot, uses the image identified by the UILaunchImageFile key in the app’s Info.plist file, or falls back to Default.png.
    var launchImage: String?
    
    /// The name of a sound file in the app bundle or in the Library/Sounds folder of the app’s data container. The sound in this file is played as an alert. If the sound file doesn’t exist or default is specified as the value, the default alert sound is played. 
    var sound: String?
    
    /// Silent push notification. This automatically ignores any other push message keys (title, body, ect.) and only the extra key-value pairs are added to the final payload
    var contentAvailable: Bool = false
    
    /// When displaying notifications, the system visually groups notifications with the same thread identifier together.
    var threadId: String?

    // Any extra key-value pairs to add to the JSON
    var extra: [String: NodeRepresentable] = [:]
    
    public func makeJSON() throws -> JSON {
        var payloadData: [String: NodeRepresentable] = [:]
        var apsPayloadData: [String: NodeRepresentable] = [:]
        
        if contentAvailable {
            apsPayloadData["content-available"] = true
        } else {
        
        // Create alert dictionary
        var alert: [String: NodeRepresentable] = [:]

        if let title = title {
            alert["title"] = title
        }
        
        if let titleLocKey = titleLocKey {
            alert["title-loc-key"] = titleLocKey
            
            if let titleLocArgs = titleLocArgs {
                alert["title-loc-args"] = try titleLocArgs.makeNode()
            }
        }
        
        if let body = body {
            alert["body"] = body
        }else {
            if let bodyLocKey = bodyLocKey {
                alert["loc-key"] = bodyLocKey
                
                if let bodyLocArgs = bodyLocArgs {
                    alert["loc-args"] = try bodyLocArgs.makeNode()
                }
            }
        }
        
        if let actionLocKey = actionLocKey {
            alert["action-loc-key"] = actionLocKey
        }
        
        if let launchImage = launchImage {
            alert["launch-image"] = launchImage
        }
        // Alert dictionary created
        
        apsPayloadData["alert"] = try alert.makeNode()
        
        if let badge = badge {
            apsPayloadData["badge"] = badge
        }
        
        if let sound = sound {
            apsPayloadData["sound"] = sound
        }
        
        }
        
        payloadData["aps"] = try apsPayloadData.makeNode()
        for (key, value) in extra {
            payloadData[key] = value
        }
        
        let json = try JSON(node: try payloadData.makeNode())
        return json
    }
}

extension Payload {
    convenience init(message: String) {
        self.init()
        self.body = message
    }
    
    convenience init(title: String, body: String) {
        self.init()
        self.title = title
        self.body = body
    }
    
    convenience init(title: String, body: String, badge: Int) {
        self.init()
        self.title = title
        self.body = body
        self.badge = badge
    }
    
    
    /// A simple, already made, Content-Available payload
    static var contentAvailable: Payload = {
        let payload = Payload()
        payload.contentAvailable = true
        return payload
    }()
}
