//
//  ContentView.swift
//  HabitTracker
//
//  Created by William Koonz on 3/19/24.
//

import SwiftUI

struct Activity: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    var completionCount: Int
    
    init(id: UUID = UUID(), title: String, description: String, completionCount: Int = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.completionCount = completionCount
    }
}

struct ContentView: View {
    @State private var activities: [Activity] = []
    @State private var showingAddActivity = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(activities) { activity in
                    NavigationLink(destination: ActivityDetailView(activity: activity, activities: $activities)) {
                        Text(activity.title)
                    }
                }
                .onDelete(perform: removeActivity)
            }
            .navigationTitle("Habit Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddActivity = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView(activities: $activities)
            }
        }
        .onAppear(perform: loadData)
    }
    
    func removeActivity(at offsets: IndexSet) {
        activities.remove(atOffsets: offsets)
        saveData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Activities") {
            if let decoded = try? JSONDecoder().decode([Activity].self, from: data) {
                activities = decoded
            }
        }
    }
    
    func saveData() {
        if let encoded = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(encoded, forKey: "Activities")
        }
    }
}

struct AddActivityView: View {
    @Binding var activities: [Activity]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
            }
            .navigationTitle("Add Activity")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newActivity = Activity(title: title, description: description)
                        activities.append(newActivity)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct ActivityDetailView: View {
    let activity: Activity
    @Binding var activities: [Activity]
    
    var body: some View {
        VStack {
            Text(activity.description)
                .padding()
            
            Text("Completion Count: \(activity.completionCount)")
                .font(.headline)
            
            Button("Mark as Completed") {
                if let index = activities.firstIndex(where: { $0.id == activity.id }) {
                    activities[index].completionCount += 1
                }
            }
            .padding()
        }
        .navigationTitle(activity.title)
    }
}

#Preview {
    ContentView()
}
