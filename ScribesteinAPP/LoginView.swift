import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = false
    @State private var showingForgotPassword = false
    @State private var localError: String?
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                GlassBackgroundView()

                ScrollView {
                    VStack(spacing: SSpace.l.rawValue) {
                        Spacer(minLength: SSpace.xxxl.rawValue)

                        // App title
                        VStack(spacing: SSpace.xs.rawValue) {
                            Text("Scribestein")
                                .font(.system(size: 34, weight: .bold, design: .serif))
                                .foregroundStyle(SColor.text)
                            Text("Chapter Operations")
                                .font(.subheadline)
                                .foregroundStyle(SColor.textSecondary)
                        }

                        // Login card
                        GlassCard(cornerRadius: SRadius.loose.rawValue) {
                            VStack(spacing: SSpace.m.rawValue) {
                                // Sign In / Create Account toggle
                                HStack(spacing: 0) {
                                    Button(action: {
                                        isSignUp = false
                                        authViewModel.clearMessages()
                                        localError = nil
                                    }) {
                                        Text("Sign In")
                                            .font(.subheadline.weight(.semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .foregroundStyle(isSignUp ? SColor.textSecondary : SColor.accentOn)
                                            .background(isSignUp ? Color.clear : SColor.accent)
                                    }
                                    Button(action: {
                                        isSignUp = true
                                        authViewModel.clearMessages()
                                        localError = nil
                                    }) {
                                        Text("Create Account")
                                            .font(.subheadline.weight(.semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .foregroundStyle(isSignUp ? SColor.accentOn : SColor.textSecondary)
                                            .background(isSignUp ? SColor.accent : Color.clear)
                                    }
                                }
                                .glassBackground(cornerRadius: SRadius.tight.rawValue)

                                // Fields
                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .sInputStyle()

                                SecureField("Password", text: $password)
                                    .sInputStyle()

                                if isSignUp {
                                    SecureField("Confirm Password", text: $confirmPassword)
                                        .sInputStyle()
                                }

                                // Error / Info messages
                                if let errorMessage = authViewModel.errorMessage ?? localError {
                                    Text(errorMessage)
                                        .foregroundStyle(SColor.danger)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }

                                if let info = authViewModel.infoMessage {
                                    Text(info)
                                        .foregroundStyle(SColor.textSecondary)
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }

                                // Actions
                                VStack(spacing: SSpace.s.rawValue) {
                                    Button(action: {
                                        localError = nil
                                        if isSignUp {
                                            guard isValidEmail(email) else { localError = "Enter a valid email"; return }
                                            guard password.count >= 8 else { localError = "Password must be at least 8 characters"; return }
                                            guard password == confirmPassword else { localError = "Passwords do not match"; return }
                                            authViewModel.createUser(withEmail: email, password: password)
                                        } else {
                                            guard isValidEmail(email) else { localError = "Enter a valid email"; return }
                                            guard !password.isEmpty else { localError = "Enter your password"; return }
                                            authViewModel.signIn(withEmail: email, password: password)
                                        }
                                    }) {
                                        if authViewModel.isLoading {
                                            ProgressView()
                                                .frame(maxWidth: .infinity)
                                        } else {
                                            Text(isSignUp ? "Create Account" : "Sign In")
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .buttonStyle(SButtonPrimary())
                                    .disabled(authViewModel.isLoading)

                                    if !isSignUp {
                                        Button("Forgot Password?") {
                                            authViewModel.clearMessages()
                                            localError = nil
                                            showingForgotPassword = true
                                        }
                                        .buttonStyle(SButtonTertiary())
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }

                        Spacer(minLength: SSpace.xxxl.rawValue)
                    }
                    .padding(.horizontal, SSpace.l.rawValue)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView(isPresented: $showingForgotPassword)
                    .environmentObject(authViewModel)
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}

// MARK: - Forgot Password

struct ForgotPasswordView: View {
    @Binding var isPresented: Bool
    @State private var email: String = ""
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                GlassBackgroundView()

                VStack(spacing: SSpace.m.rawValue) {
                    GlassCard(cornerRadius: SRadius.loose.rawValue) {
                        VStack(spacing: SSpace.m.rawValue) {
                            Text("Enter your account email. We'll send a password reset link.")
                                .font(.subheadline)
                                .foregroundStyle(SColor.textSecondary)
                                .multilineTextAlignment(.center)

                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .sInputStyle()

                            if let error = authViewModel.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(SColor.danger)
                                    .multilineTextAlignment(.center)
                            }

                            if let info = authViewModel.infoMessage {
                                Text(info)
                                    .font(.caption)
                                    .foregroundStyle(SColor.textSecondary)
                                    .multilineTextAlignment(.center)
                            }

                            Button {
                                guard isValidEmail(email) else { return }
                                authViewModel.sendPasswordReset(to: email)
                            } label: {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("Send Reset Link")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(SButtonPrimary())
                        }
                    }
                    .padding(.horizontal, SSpace.l.rawValue)

                    Spacer()
                }
                .padding(.top, SSpace.l.rawValue)
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundStyle(SColor.accent)
                }
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}
