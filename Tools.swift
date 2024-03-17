import SwiftUI

// Manages persistence of Boxes using UserDefaults
class PersistenceManager
{
    private let boxesKey = "boxes" // Key used to store boxes array in UserDefaults

    // Saves an array of boxes to UserDefaults
    func saveBoxes(_ boxes: [Box])
    {
        do
        {
            let data = try JSONEncoder().encode(boxes)
            UserDefaults.standard.set(data, forKey: boxesKey)
        }
        catch
        {
            print("Error saving boxes: \(error)")
        }
    }

    // Loads an array of boxes from UserDefaults
    func loadBoxes() -> [Box]
    {
        guard let data = UserDefaults.standard.data(forKey: boxesKey) else { return [] }
        do
        {
            return try JSONDecoder().decode([Box].self, from: data)
        }
        catch
        {
            print("Error loading boxes: \(error)")
            return []
        }
    }
}

// Extension to provide a random color functionality to the Color struct
extension Color {
    // Generates a random SwiftUI Color
    static var random: Color {
        Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
    }
}


