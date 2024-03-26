import SwiftUI

struct EmployeeDetailView: View {
    let employeeID: Int // Accept employee ID
    @Binding var isPresented: Bool // Binding to dismiss the detail view
    
    @State private var employee: Employee? // Optional state variable to hold employee details
    @State private var errorMessage: String? // Optional state variable to hold error message
    @State private var isLoading = false // State variable to track loading state
    
    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                if let employee = employee {
                    displayEmployeeDetails(employee)
                } else {
                    Text("No data available")
                }
            } else {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    Text("Loading...")
                }
            }
        }
        .navigationTitle("Employee Details")
        .onAppear(perform: loadDataInBackground)
    }
    
    func displayEmployeeDetails(_ employee: Employee) -> some View {
        VStack {
            Text("ID: \(employee.id)")
            Text("Name: \(employee.employee_name)")
            Text("Salary: \(employee.employee_salary)")
            Text("Age: \(employee.employee_age)")
            Text("Profile Image: \(employee.profile_image)")
            Button("Dismiss") {
                isPresented = false // Dismiss the detail view
            }
        }
    }
    
    func loadDataInBackground() {
        // Load employee details using employeeID in the background
        DispatchQueue.global().async {
            isLoading = true
            loadData()
        }
    }
    
    func loadData() {
        // Load employee details using employeeID
        guard let plistURL = Bundle.main.url(forResource: "APIInfo", withExtension: "plist"),
              let data = try? Data(contentsOf: plistURL),
              let apiInfo = try? PropertyListDecoder().decode(APIInfo.self, from: data) else {
            errorMessage = "Unable to read APIInfo.plist"
            return
        }
        
        let urlString = "\(apiInfo.baseURL)/\(apiInfo.apiEmployeeDetails)/\(employeeID)"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            isLoading = false
            if let error = error {
                errorMessage = "Error: \(error.localizedDescription)"
                print(errorMessage!)
                return
            }
            
            guard let data = data else {
                errorMessage = "No data received"
                print(errorMessage!)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(EmployeeDetailsResponseData.self, from: data)
                DispatchQueue.main.async {
                    if let employee = decodedResponse.data {
                        self.employee = employee
                    } else {
                        errorMessage = decodedResponse.message
                        print(errorMessage!)
                    }
                }
            } catch {
                if let jsonString = String(data: data, encoding: .utf8) {
                    if jsonString.contains("Too Many Requests") {
                        errorMessage = "Too Many Requests"
                    } else {
                        errorMessage = "Error decoding JSON: \(error.localizedDescription), JSON: \(jsonString)"
                    }
                } else {
                    errorMessage = "Error decoding JSON: \(error.localizedDescription)"
                }
                print(errorMessage!)
            }
        }.resume()
    }
}
