//
//  ContentView.swift
//  FitnessMedia
//
//  Created by Sharik Mahmood on 2/13/24.
//

import SwiftUI
import SwiftData
import HealthKit


class HealthKitManager: ObservableObject {
    private var healthStore: HKHealthStore?
    
    @Published var dob: Date? = nil
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }
    
    @Published var userName: String = ""

        func fetchUserName() {
            // Check if the user name is already saved in UserDefaults
            if let savedUserName = UserDefaults.standard.string(forKey: "UserName") {
                DispatchQueue.main.async {
                    self.userName = savedUserName
                }
            }
        }

        func saveUserName(_ name: String) {
            // Save the user name to UserDefaults
            UserDefaults.standard.set(name, forKey: "UserName")
            // Notify any observers that the user name has updated
            DispatchQueue.main.async {
                self.userName = name
            }
        }
    
    func requestAuthorization() {
        guard let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
              let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }

        healthStore?.requestAuthorization(toShare: nil, read: Set([dateOfBirthType, stepsType, activeEnergyType])) { success, error in
            guard success else {
                // Handle the error or lack of permissions
                return
            }
            self.readDOB()
            self.readSteps()
            self.readActiveEnergyBurned()
        }
    }

    @Published var activeEnergyBurned: Double = 0

    func readActiveEnergyBurned() {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            DispatchQueue.main.async {
                guard let result = result, let sum = result.sumQuantity() else {
                    self.activeEnergyBurned = 0
                    return
                }
                self.activeEnergyBurned = sum.doubleValue(for: HKUnit.kilocalorie())
            }
        }
        
        healthStore?.execute(query)
    }

    @Published var steps: Int = 0

    func readSteps() {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            DispatchQueue.main.async {
                guard let result = result, let sum = result.sumQuantity() else {
                    self.steps = 0
                    return
                }
                self.steps = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore?.execute(query)
    }

    
    //this functions reads the DOB
    func readDOB() {
        do {
            let dobComponents = try healthStore?.dateOfBirthComponents()
            let calendar = Calendar.current
            self.dob = calendar.date(from: dobComponents!)
        } catch {
            // Handle errors
        }
    }
}

struct Box: Identifiable {
    let id = UUID()
    var title: String
    var color: Color
}


struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var showingNameEntryView = false
    @State private var userName: String = UserDefaults.standard.string(forKey: "UserName") ?? ""
    @State private var boxes: [Box] = [] // This will now track the boxes

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.black.opacity(0.85)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        HStack {
                            Text(userName.isEmpty ? "Tap to Enter Your Name" : userName)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Button(action: {
                                // Add a new box when the "+" button is pressed
                                let newBox = Box(title: "Box \(boxes.count + 1)", color: Color.random) // Using .random extension for Color
                                boxes.append(newBox)
                            }) {
                                Text("+")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                        
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(boxes) { box in
                                    BoxView(content: Text(box.title).bold(), color: box.color)
                                        .frame(height: (geometry.size.height - 100) / 2) // Adjust height based on the number of boxes
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                    .padding()
                }
                .navigationBarHidden(true)
                .onAppear {
                    showingNameEntryView = userName.isEmpty
                    healthKitManager.requestAuthorization()
                }
                .sheet(isPresented: $showingNameEntryView) {
                    NameEntryView(isPresented: $showingNameEntryView, userName: $userName)
                }
            }
        }
    }
}

// Assuming you have an extension for Color to generate random colors
extension Color {
    static var random: Color {
        Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
    }
}



struct BoxView<Content: View>: View {
    let content: Content
    var color: Color
    
    init(content: Content, color: Color) {
        self.content = content
        self.color = color
    }
    
    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(RoundedRectangle(cornerRadius: 25).fill(color))
    }
}

struct Page1: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var body: some View {
        
        if let dob = healthKitManager.dob {
            Text("DOB: \(dob.formatted(date: .abbreviated, time: .omitted))")
        }
        Text("Steps: \(healthKitManager.steps)")
        Text("Calories: \(String(format: "%.2f", healthKitManager.activeEnergyBurned)) kcal")
        Text("Page 1")
            .font(.title)
            .navigationBarTitle("Welcome to Page1", displayMode: .inline)
    }
}

struct Page2: View {
    var body: some View {
        Text("Page 2")
            .font(.title)
            .navigationBarTitle("Welcome to Page2 :)", displayMode: .inline)
    }
}

struct Page3: View {
    var body: some View {
        Text("Page 3")
            .font(.title)
            .navigationBarTitle("Welcome to Page3 :(", displayMode: .inline)
    }
}

struct Challenges: View {
    var body: some View {
        Text("Challenges")
            .font(.title)
            .navigationBarTitle("Challenge Page!!", displayMode: .inline)
    }
}



struct NameEntryView: View {
    @Binding var isPresented: Bool
    @Binding var userName: String

    var body: some View {
        ZStack {
            Color.clear
            VStack(spacing: 20) {
                Text("Welcome! Please enter your name:")
                
                TextField("Name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Continue") {
                    UserDefaults.standard.set(userName, forKey: "UserName")
                    isPresented = false
                }
                .padding() // Add padding around the button's text
                .foregroundColor(.white) // Set the text color to white
                .background(Color.black) // Set the background of the button to black
                .cornerRadius(10) // Round the corners of the background
            }
            .padding()

        }
    }
}





