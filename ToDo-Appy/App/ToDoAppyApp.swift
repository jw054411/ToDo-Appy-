//
//  ToDoAppyApp.swift
//  ToDo-Appy
//
//  Created by Agent 1: Foundation & Setup Specialist
//  Main entry point for the ToDo-Appy application
//

import SwiftUI
import SwiftData

@main
struct ToDoAppyApp: App {
    // Connect AppDelegate for CloudKit notification handling
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) // Force dark mode as per requirements
        }
    }
}
