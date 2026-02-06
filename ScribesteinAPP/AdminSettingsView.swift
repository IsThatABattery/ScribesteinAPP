import SwiftUI

struct AdminSettingsView: View {
    @State private var email: String = ""
    @State private var selectedRole: String = "Brother"
    @EnvironmentObject var authViewModel: AuthViewModel

    let roles = ["Brother", "Exec"]

    var body: some View {
        ZStack {
            Color.clear

            ScrollView {
                VStack(spacing: SSpace.m.rawValue) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: SSpace.m.rawValue) {
                            Text("Manage Roles")
                                .sectionHeaderStyle()

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

                            if let error = authViewModel.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(SColor.danger)
                            }

                            if let info = authViewModel.infoMessage {
                                Text(info)
                                    .font(.caption)
                                    .foregroundStyle(SColor.success)
                            }

                            Button(action: {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                if !email.isEmpty {
                                    authViewModel.setUserRole(email: email, role: selectedRole.lowercased())
                                    email = ""
                                }
                            }) {
                                Text("Set Role")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(SButtonPrimary())
                        }
                    }
                }
                .padding(SSpace.m.rawValue)
            }
        }
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
