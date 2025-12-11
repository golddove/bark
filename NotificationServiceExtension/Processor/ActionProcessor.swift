//
//  ActionProcessor.swift
//  NotificationServiceExtension
//
//  Created by GitHub Copilot
//  Copyright © 2024 Fin. All rights reserved.
//

import Foundation
import UserNotifications

/// Processor for handling custom notification actions
/// Supports dynamic action buttons via push notification payload
class ActionProcessor: NotificationContentProcessor {
    func process(identifier: String, content bestAttemptContent: UNMutableNotificationContent) async throws -> UNMutableNotificationContent {
        // Check if actions are defined in the payload
        guard let actionsJson = bestAttemptContent.userInfo["actions"] as? String else {
            // No custom actions, use default category
            return bestAttemptContent
        }
        
        // Parse actions from JSON
        guard let actionsData = actionsJson.data(using: .utf8),
              let actionsArray = try? JSONSerialization.jsonObject(with: actionsData) as? [[String: Any]],
              !actionsArray.isEmpty else {
            return bestAttemptContent
        }
        
        // Create UNNotificationAction objects from the parsed data
        var actions: [UNNotificationAction] = []
        var actionIdentifiers: [String] = []
        
        for (index, actionDict) in actionsArray.enumerated() {
            guard let title = actionDict["title"] as? String else {
                continue
            }
            
            // Use provided identifier or generate one
            let actionId = (actionDict["id"] as? String) ?? "action_\(index)"
            actionIdentifiers.append(actionId)
            
            // Parse options
            var options: UNNotificationActionOptions = []
            if let destructive = actionDict["destructive"] as? Bool, destructive {
                options.insert(.destructive)
            }
            if let authenticationRequired = actionDict["authenticationRequired"] as? Bool, authenticationRequired {
                options.insert(.authenticationRequired)
            }
            if let foreground = actionDict["foreground"] as? Bool, foreground {
                options.insert(.foreground)
            }
            
            let action = UNNotificationAction(
                identifier: actionId,
                title: title,
                options: options
            )
            actions.append(action)
        }
        
        // Limit to 4 actions (iOS limit)
        if actions.count > 4 {
            actions = Array(actions.prefix(4))
        }
        
        // Add default copy and mute actions if there's room
        if actions.count < 4 {
            actions.append(UNNotificationAction(
                identifier: "copy",
                title: "Copy",
                options: .foreground
            ))
        }
        
        if #available(iOSApplicationExtension 15.0, *), actions.count < 4 {
            actions.append(UNNotificationAction(
                identifier: "mute",
                title: "Mute 1 Hour",
                options: .foreground
            ))
        }
        
        // Create a unique category identifier based on the actions
        let categoryId = "dynamic_actions_\(actionIdentifiers.joined(separator: "_"))"
        
        // Create and register the category
        let category = UNNotificationCategory(
            identifier: categoryId,
            actions: actions,
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        // Register the category synchronously
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            UNUserNotificationCenter.current().getNotificationCategories { existingCategories in
                var categories = existingCategories
                categories.insert(category)
                UNUserNotificationCenter.current().setNotificationCategories(categories)
                continuation.resume()
            }
        }
        
        // Set the category identifier on the notification
        bestAttemptContent.categoryIdentifier = categoryId
        
        return bestAttemptContent
    }
}
