# ScribesteinAPP

ScribesteinAPP is a read-only iOS application that displays a real-time feed of transcripts from a Google Firestore database.

## Features

-   **Real-time Transcript Feed**: Displays a live-updating list of transcripts.
-   **Firebase Integration**: Built on Firebase for a scalable and real-time backend.
-   **User Authentication**: Secure sign-in with Google.
-   **Role-Based Permissions**: Supports admin users with access to additional features.

## Architecture

The app is built with SwiftUI and follows the MVVM (Model-View-ViewModel) design pattern.

-   **Model**: `Transcript.swift`
-   **View**: `ContentView.swift`, `TranscriptFeedView.swift`, `LoginView.swift`
-   **ViewModel**: `TranscriptViewModel.swift`, `AuthViewModel.swift`

## Setup

1.  **Firebase Configuration**: 
    -   Set up a new Firebase project at [firebase.google.com](https://firebase.google.com).
    -   Create a new iOS app in your Firebase project.
    -   Download the `GoogleService-Info.plist` file and add it to the `ScribesteinAPP` directory in your Xcode project.
    -   Enable **Email/Password** Sign-In in the "Authentication" section of the Firebase console.
    -   Set up a Firestore database.

2.  **Xcode Configuration**:
    -   Add the following Swift packages to your project:
        -   `Firebase/Auth`
        -   `Firebase/Firestore`
        -   `Firebase/FirestoreSwift`

## Permissions

To grant a user admin privileges, you need to set a custom claim on their Firebase account. This must be done from a secure backend environment, such as a Cloud Function. See `PROJECT_SPEC.md` for more details.
