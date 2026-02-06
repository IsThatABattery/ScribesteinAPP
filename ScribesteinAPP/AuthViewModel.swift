import Foundation
import Firebase
import FirebaseAuth
import FirebaseFunctions

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var isAdmin: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var infoMessage: String?
    @Published var isEmailVerified: Bool = false
    @Published var isExecUser: Bool = false

    private var handle: AuthStateDidChangeListenerHandle?
    private var tokenHandle: IDTokenDidChangeListenerHandle?

    lazy var functions = Functions.functions()

    init() {
        self.userSession = Auth.auth().currentUser
        self.handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.userSession = user
            self?.updateEmailVerificationState(with: user)
        }
        
        self.tokenHandle = Auth.auth().addIDTokenDidChangeListener { [weak self] (auth, user) in
            guard let user = user else {
                self?.isAdmin = false
                self?.isExecUser = false
                return
            }
            
            user.getIDTokenResult(forcingRefresh: false) { (result, error) in
                if let error = error {
                    print("Error getting ID token result: \(error.localizedDescription)")
                    self?.isAdmin = false
                    self?.isExecUser = false
                    return
                }
                
                if let claims = result?.claims {
                    self?.isAdmin = claims["admin"] as? Bool ?? false
                    self?.isExecUser = claims["exec"] as? Bool ?? false
                } else {
                    self?.isAdmin = false
                    self?.isExecUser = false
                }
            }
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
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.isAdmin = false
            self.isEmailVerified = false
            self.errorMessage = nil
            self.infoMessage = nil
            self.isExecUser = false
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

    func clearMessages() {
        errorMessage = nil
        infoMessage = nil
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
            completion?(self?.isEmailVerified == true)
        }
    }

    func setUserRole(email: String, role: String) {
        functions.httpsCallable("set_role").call(["email": email, "role": role]) { [weak self] result, error in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    print("Error: \(message), code: \(String(describing: code)), details: \(String(describing: details))")
                    self?.errorMessage = message
                }
            }
            if let data = result?.data as? [String: Any], let message = data["message"] as? String {
                print(message)
                self?.infoMessage = message
            }
        }
    }

    private func updateEmailVerificationState(with user: FirebaseAuth.User?) {
        // self.isEmailVerified = user?.isEmailVerified ?? false
        self.isEmailVerified = user != nil
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
        if let tokenHandle = tokenHandle {
            Auth.auth().removeIDTokenDidChangeListener(tokenHandle)
        }
    }
}
