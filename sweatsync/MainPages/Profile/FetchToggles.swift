//
//  FetchToggles.swift
//  sweatsync
//
//  Created by Ashwin on 12/2/24.
//

import Foundation
import Firebase

func fetchNotificationsEnabled(userId: String) async -> Bool {
    let db = Firestore.firestore()
    do {
        let document = try await db.collection("users").document(userId).getDocument()
        if let data = document.data(), let notificationsEnabled = data["notificationsEnabled"] as? Bool {
            return notificationsEnabled
        }
    } catch {
        print("Error fetching notificationsEnabled: \(error)")
    }
    return true
}

func fetchCommentsDisabled(userId: String) async -> Bool {
    let db = Firestore.firestore()
    do {
        let document = try await db.collection("users").document(userId).getDocument()
        if let data = document.data(), let commentsDisabled = data["commentsDisabled"] as? Bool {
            return commentsDisabled
        }
    } catch {
        print("Error fetching commentsDisabled: \(error)")
    }
    return false 
}
