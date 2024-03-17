import Foundation
import HealthKit

// Manages interactions with Apple's HealthKit, including fetching health data
class HealthKitManager: ObservableObject
{
    private var healthStore: HKHealthStore? // The HealthKit store used to interact with health data
    
    // Published properties that will update the UI when changed
    @Published var dob: Date? = nil // Date of birth of the user
    @Published var userName: String = "" // User's name
    @Published var activeEnergyBurned: Double = 0 // Amount of active energy burned
    @Published var steps: Int = 0 // Number of steps taken

    // Initializes the HealthKitManager and sets up the health store if available
    init()
    {
        if HKHealthStore.isHealthDataAvailable()
        {
            healthStore = HKHealthStore()
        }
    }

    // Fetches the user name from UserDefaults and updates the published property
    func fetchUserName()
    {
        if let savedUserName = UserDefaults.standard.string(forKey: "UserName")
        {
            DispatchQueue.main.async
            {
                self.userName = savedUserName
            }
        }
    }

    // Saves the user name to UserDefaults and updates the published property
    func saveUserName(_ name: String)
    {
        UserDefaults.standard.set(name, forKey: "UserName")
        DispatchQueue.main.async
        {
            self.userName = name
        }
    }

    // Requests authorization to access HealthKit data
    func requestAuthorization()
    {
        // Health data types this app is interested in reading
        guard let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
              let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else
        {
            return
        }

        // Request authorization to read the specified health data types
        healthStore?.requestAuthorization(toShare: nil, read: Set([dateOfBirthType, stepsType, activeEnergyType])) { success, _ in
            if success
            {
                self.readDOB()
                self.readSteps()
                self.readActiveEnergyBurned()
            }
        }
    }

    // Reads the user's active energy burned from HealthKit and updates the published property
    func readActiveEnergyBurned()
    {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else
        {
            return
        }
        
        // Create a query to read today's active energy burned
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            DispatchQueue.main.async
            {
                guard let result = result, let sum = result.sumQuantity() else
                {
                    self.activeEnergyBurned = 0
                    return
                }
                self.activeEnergyBurned = sum.doubleValue(for: HKUnit.kilocalorie())
            }
        }
        
        healthStore?.execute(query)
    }

    // Reads the user's step count from HealthKit and updates the published property
    func readSteps()
    {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else
        {
            return
        }
        
        // Create a query to read today's steps
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            DispatchQueue.main.async
            {
                guard let result = result, let sum = result.sumQuantity() else
                {
                    self.steps = 0
                    return
                }
                self.steps = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore?.execute(query)
    }

    // Reads the user's date of birth from HealthKit and updates the published property
    func readDOB()
    {
        do
        {
            let dobComponents = try healthStore?.dateOfBirthComponents()
            let calendar = Calendar.current
            self.dob = calendar.date(from: dobComponents!)
        }
        catch
        {
            // Handle errors here if needed
        }
    }
}

