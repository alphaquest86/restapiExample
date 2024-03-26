import SwiftUI

struct EmployeeRow: View {
    var employee: Employee
    
    var body: some View {
        HStack(spacing: 0) {
            Text("\(employee.id)")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(employee.employee_name)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("$\(employee.employee_salary)")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("\(employee.employee_age)")
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(employee.profile_image)
                .font(.caption)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 5)
        .background(Color.gray.opacity(0.1))
    }
}
