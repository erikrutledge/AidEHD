//
//  ContentView.swift
//  Aid-EHD
//
//  Created by Erik Rutledge on 2/17/23.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    
    @State private var task = ""
    @State private var taskTime = 180
    @State private var maxBound = 90
    @State private var completionMinutes = 60.0
    @State private var reminderMinutes = 10.0
    @State private var isEditing = false
    @State private var notifications = [Int]()
    
    var body: some View {
        
        VStack() {
            Text("AID-EHD")
                .fontWeight(.bold)
            Spacer()
            
            // Create a Text Field for the user to input what their task is
            TextField("Enter your task here", text: $task)
            
            // Create a slider to allow the user to select how long the task is expected to take
            Slider(value: $completionMinutes,
                   in: 0...180,
                   step: 1,
                   onEditingChanged: { editing in
                isEditing = editing})
            Text("This should take \(String(format: "%.0f",completionMinutes)) minutes.")
            
            // Create a second slider for the user to select how often they would like to be reminded
            Slider(value: $reminderMinutes,
                   in: 0...Double(maxBound),
                   step: 1,
                   onEditingChanged: { editing in
                isEditing = editing})
            Text("Remind me every \(String(format: "%.0f", reminderMinutes)) minutes")
            
            Spacer()
            
            // Create a button to begin the notification cycle when pressed
            Button("Begin Focusing") {
                
                // Check if there are already notifications set to be run
                if (notifications.count == 0) {
                    
                    // Calculate how many notification need to be made
                    let notificationNum = floor(completionMinutes / reminderMinutes)
                    
                    while (notifications.count <= Int(notificationNum)) {
                        
                        // Get the current date and set the trigger for when the notifications are to be sent
                        let notificationTime = Double(notifications.count) * reminderMinutes * 60
                        let date = Date().addingTimeInterval(notificationTime)
                        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                        
                        // Ask the user for notification permission
                        let center = UNUserNotificationCenter.current()
                        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in}
                        
                        // Configure notification content
                        let content = UNMutableNotificationContent()
                        content.title = "Reminder to stay on task:"
                        content.body = "\(task)"
                        
                        // Create the notification request
                        let uuidString = UUID().uuidString
                        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                        
                        // Register the request with the notification center
                        center.add(request)
                        
                        // Append the notification to the "notifications"
                        notifications.append(Int(notificationTime))
                        print(notifications)
                    }
                }
            }
        }
        .padding()
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
