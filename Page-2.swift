import SwiftUI

struct BoxDetailView: View {
    let box: Box
    var deleteAction: () -> Void
    @ObservedObject var healthKitManager: HealthKitManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(box.title)
                    .font(.largeTitle)
                    .padding()

                // Display User's Name
                if !healthKitManager.userName.isEmpty {
                    Text("User: \(healthKitManager.userName)")
                        .padding()
                }

                // Display DOB
                if let dob = healthKitManager.dob {
                    Text("DOB: \(formattedDate(dob))")
                        .padding()
                }

                // Display Steps
                Text("Steps Today: \(healthKitManager.steps)")
                    .padding()

                // Display Active Energy Burned
                Text("Active Energy Burned: \(healthKitManager.activeEnergyBurned, specifier: "%.1f") kcal")
                    .padding()

                // Delete Box Button
                Button(action: deleteAction) {
                    Text("Delete Box")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
