//
//  Drive_LimitApp.swift
//  Drive Limit
//
//  Created by Alexander Torres on 6/2/23.
//

import SwiftUI

@main
struct Drive_LimitApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            TabView() {
                DriveView()
                    .tabItem {
                        Label("First", systemImage: "1.circle")
                    }
                SpeedViolationsView()
                    .tabItem{
                        Label("Second",systemImage: "2.circle")
                    }
            }
        }
    }
}
