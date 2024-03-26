import SwiftUI

struct ContentView: View {
    @State private var employees: [Employee]? = nil
    @State private var errorMessage: String?
    @State private var selectedEmployeeID: Int? // Added state variable to store selected employee ID
    @State private var isShowingDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 10) {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else if let employees = employees {
                        VStack(alignment: .center, spacing: 10) {
                            ForEach(employees) { employee in
                                EmployeeRow(employee: employee)
                                    .padding(.horizontal, 10)
                                    .onTapGesture {
                                        selectedEmployeeID = employee.id // Store selected employee ID
                                        isShowingDetail = true
                                        if let employeeID = selectedEmployeeID {
                                            print("Selected employee ID: \(employeeID)")
                                        } else {
                                            print("Selected employee ID is nil")
                                        }
                                    }
                            }
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }
                }
            }
            .navigationTitle("Employees")
            .sheet(isPresented: $isShowingDetail) {
                if let employeeID = selectedEmployeeID {
                    EmployeeDetailView(employeeID: employeeID, isPresented: $isShowingDetail)
                }
            }
        }
        .onAppear {
            // Load data in the background
            DispatchQueue.global().async {
                loadData()
            }
        }
    }
    
    func loadData() {
        // Read baseURL and API from plist
        guard let plistURL = Bundle.main.url(forResource: "APIInfo", withExtension: "plist"),
              let data = try? Data(contentsOf: plistURL),
              let apiInfo = try? PropertyListDecoder().decode(APIInfo.self, from: data) else {
            errorMessage = "Unable to read APIInfo.plist"
            return
        }
        
        let urlString = "\(apiInfo.baseURL)/\(apiInfo.apiEmployeesList)"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                    errorMessage = "Error: \(error.localizedDescription), JSON: \(jsonString)"
                } else {
                    errorMessage = "Error: \(error.localizedDescription)"
                }
                print(errorMessage!)
                return
            }
            
            guard let data = data else {
                errorMessage = "No data received"
                print(errorMessage!)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(EmployeesListResponseData.self, from: data)
                DispatchQueue.main.async {
                    if let employees = decodedResponse.data {
                        self.employees = employees
                    } else {
                        errorMessage = decodedResponse.message
                        print(errorMessage!)
                    }
                }
            } catch {
                if let jsonString = String(data: data, encoding: .utf8) {
                    if jsonString.contains("Too Many Requests") {
                        errorMessage = "Too Many Requests"
                    }
                    else {
                        errorMessage = "Error decoding JSON: \(error.localizedDescription), JSON: \(jsonString)"
                    }
                } else {
                    errorMessage = "Error decoding JSON: \(error.localizedDescription)"
                }
                print(errorMessage!)
            }
        }.resume()
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
