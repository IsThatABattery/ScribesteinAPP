import Foundation
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var isAdmin: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var infoMessage: String?
    @Published var isEmailVerified: Bool = false

    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        self.userSession = Auth.auth().currentUser
        self.handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.userSession = user
            self?.updateEmailVerificationState(with: user)
            self?.checkAdminStatus()
        }
        self.updateEmailVerificationState(with: self.userSession)
    }

    func signIn(withEmail email: String, password pass: String) {
        isLoading = true
        errorMessage = nil
        infoMessage = nil
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] authResult, error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                let user = authResult?.user ?? Auth.auth().currentUser
                self?.updateEmailVerificationState(with: user)
                self?.checkAdminStatus()
            }
        }
    }
    
    func createUser(withEmail email: String, password pass: String) {
        isLoading = true
        errorMessage = nil
        infoMessage = nil
        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] authResult, error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                let user = authResult?.user ?? Auth.auth().currentUser
                self?.updateEmailVerificationState(with: user)
                // self?.sendEmailVerification()
                self?.checkAdminStatus()
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.isAdmin = false
            self.isEmailVerified = false
        } catch let signOutError as NSError {
            self.errorMessage = signOutError.localizedDescription
        }
    }

    func sendPasswordReset(to email: String) {
        isLoading = true
        errorMessage = nil
        infoMessage = nil
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                self?.infoMessage = "Password reset email sent to \(email)."
            }
        }
    }

    func sendEmailVerification() {
        // guard let user = Auth.auth().currentUser else {
        //     self.errorMessage = "No authenticated user found."
        //     return
        // }
        // isLoading = true
        // errorMessage = nil
        // infoMessage = nil
        // user.sendEmailVerification { [weak self] error in
        //     self?.isLoading = false
        //     if let error = error {
        //         self?.errorMessage = error.localizedDescription
        //     } else {
        //         self?.infoMessage = "Verification email sent to \(user.email ?? "your email")."
        //     }
        // }
    }

    func reloadUser(completion: ((Bool) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {
            completion?(false)
            return
        }
        isLoading = true
        errorMessage = nil
        user.reload { [weak self] error in
            self?.isLoading = false
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion?(false)
                return
            }
            let refreshedUser = Auth.auth().currentUser
            self?.userSession = refreshedUser
            self?.updateEmailVerificationState(with: refreshedUser)
            self?.checkAdminStatus()
            completion?(self?.isEmailVerified == true)
        }
    }

    private func checkAdminStatus() {
        guard let user = userSession else { 
            self.isAdmin = false
            return
        }
        
        user.getIDTokenResult(forcingRefresh: true) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isAdmin = false
                return
            }
            
            if let claims = result?.claims, let adminStatus = claims["admin"] as? Bool {
                self.isAdmin = adminStatus
            } else {
                self.isAdmin = false
            }
        }
    }

    private func updateEmailVerificationState(with user: FirebaseAuth.User?) {
        // self.isEmailVerified = user?.isEmailVerified ?? false
        self.isEmailVerified = user != nil
    }
}
