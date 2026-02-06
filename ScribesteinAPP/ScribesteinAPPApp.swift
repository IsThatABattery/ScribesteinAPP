import SwiftUI
import Firebase
import UIKit

@main
struct ScribesteinAPPApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(Color("Surface/Default"))
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color("Text/Primary"))
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color("Text/Primary"))
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = UIColor(Color("Brand/Gold/600"))
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .tint(SColor.accent)
                .preferredColorScheme(.dark)
        }
    }
}

