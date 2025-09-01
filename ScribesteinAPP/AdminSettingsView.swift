import SwiftUI

struct AdminSettingsView: View {
    @State private var email: String = ""
    @State private var selectedRole: String = "Brother"
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let roles = ["Brother", "Exec"]

    var body: some View {
        VStack {
            VStack(spacing: SSpace.m.rawValue) {
                TextField("User Email", text: $email)
                    .sInputStyle()
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)

                Picker("Select Role", selection: $selectedRole) {
                    ForEach(roles, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Button(action: {
                    // Hide keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    if !email.isEmpty {
                        authViewModel.setUserRole(email: email, role: selectedRole.lowercased())
                        email = "" // Clear the field
                    }
                }) {
                    Text("Set Role")
                }
                .buttonStyle(SButtonPrimary())
            }
            .padding(SSpace.m.rawValue)
            
            Spacer()
        }
        .background(SColor.background)
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("Admin Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AdminSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AdminSettingsView()
                .environmentObject(AuthViewModel())
        }
    }
}
