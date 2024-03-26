import Foundation

struct Employee: Codable, Identifiable {
    let id: Int
    let employee_name: String
    let employee_salary: Int
    let employee_age: Int
    let profile_image: String
}

struct EmployeesListResponseData: Codable {
    let status: String
    let data: [Employee]?
    let message: String
}

struct EmployeeDetailsResponseData: Codable {
    let status: String
    let data: Employee?
    let message: String
}

struct APIInfo: Codable {
    let baseURL: String
    let apiEmployeesList: String
    let apiEmployeeDetails: String
}
