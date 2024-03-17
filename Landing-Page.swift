import SwiftUI

struct ContentView: View {
    @State private var userName: String = UserDefaults.standard.string(forKey: "UserName") ?? ""
    @State private var boxes: [Box] = []
    private let persistenceManager = PersistenceManager()
    @StateObject private var healthKitManager = HealthKitManager()


    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.85).edgesIgnoringSafeArea(.all)
                VStack {
                    userInfoHeader

                    ScrollView {
                        boxesGrid
                    }
                    .padding(.bottom)
                }
                .padding()
            }
            .navigationBarHidden(false)
            .onAppear {
                loadBoxes()
            }
        }
        .onAppear {
            healthKitManager.requestAuthorization()
        }

    }

    private var userInfoHeader: some View {
        HStack {
            Text(userName.isEmpty ? "Tap to Enter Your Name" : userName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Spacer()

            Button(action: addBox) {
                Text("+").font(.title).foregroundColor(.white)
            }
        }
        .padding(.horizontal)
    }

    private var boxesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(boxes) { box in
                NavigationLink(destination: BoxDetailView(box: box, deleteAction: { deleteBox(box: box) }, healthKitManager: healthKitManager))  {
                    BoxView(content: Text(box.title).bold(), color: box.color)
                        .frame(height: 295) // Set a fixed height for the boxes
                }
            }
        }
    }

    private func loadBoxes() {
        boxes = persistenceManager.loadBoxes()
    }

    private func addBox() {
        let newBox = Box(title: "Box \(boxes.count + 1)", color: .random)
        boxes.append(newBox)
        persistenceManager.saveBoxes(boxes)
    }

    private func deleteBox(box: Box) {
        guard let index = boxes.firstIndex(where: { $0.id == box.id }) else { return }
        boxes.remove(at: index)
        persistenceManager.saveBoxes(boxes)
    }
}

// A generic view wrapper that applies consistent styling to its content
struct BoxView<Content: View>: View
{
    let content: Content // The content to display inside the BoxView
    var color: Color // The background color for the BoxView

    // Configures the view for a single box, setting up its appearance
    var body: some View
    {
        content
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color)
            .cornerRadius(10)
    }
}

// Represents a Box with a title and color
struct Box: Codable, Identifiable
{
    var id = UUID() // Unique identifier for each Box, conforming to Identifiable
    var title: String // Title of the Box
    var colorData: Data // Color of the Box, stored as Data for Codable conformance

    // Initializes a new Box with a title and color
    init(title: String, color: Color)
    {
        self.title = title
        self.colorData = NSKeyedArchiver.archivedData(withRootObject: UIColor(color))
    }

    // Computed property to convert stored Data back into a SwiftUI Color
    var color: Color
    {
        Color(NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor ?? UIColor.white)
    }
}


