import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if let _ = authViewModel.userSession {
                if authViewModel.isEmailVerified {
                    TranscriptFeedView()
                } else {
                    EmailVerificationView()
                }
            } else {
                LoginView()
            }
        }
        .background(SColor.background.ignoresSafeArea())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}

struct EmailVerificationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: SSpace.l.rawValue) {
                Image(systemName: "envelope.badge")
                    .font(.system(size: 52))
                    .foregroundStyle(SColor.accent)

                Text("Verify your email")
                    .font(.title2)
                    .bold()

                Text("We sent a verification link to your email. Please tap the link to verify your account, then return to the app.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(SColor.textSecondary)

                if let message = authViewModel.infoMessage {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(SColor.textSecondary)
                }

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(SColor.danger)
                }

                VStack(spacing: SSpace.s.rawValue) {
                    Button {
                        authViewModel.sendEmailVerification()
                    } label: {
                        Text("Resend verification email")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SButtonSecondary())
                    .disabled(authViewModel.isLoading)

                    Button {
                        authViewModel.reloadUser()
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("I have verified – Check again")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(SButtonPrimary())
                    .disabled(authViewModel.isLoading)
                }

                Spacer()

                Button(role: .destructive) {
                    authViewModel.signOut()
                } label: {
                    Text("Sign Out")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SButtonSecondary())
            }
            .padding(SSpace.l.rawValue)
            .background(SColor.background.ignoresSafeArea())
            .navigationTitle("Email Verification")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
