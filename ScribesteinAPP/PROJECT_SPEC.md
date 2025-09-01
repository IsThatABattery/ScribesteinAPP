# Project Specification: ScribesteinAPP

## 1. Overview

ScribesteinAPP is a read-only iOS application that displays a real-time feed of transcripts from a Google Firestore database. It is designed to be a lightweight, view-only client that listens for and displays data as it is added to the backend.

## 2. Architecture

The application follows a modern MVVM (Model-View-ViewModel) architecture, which is well-suited for SwiftUI development.

-   **Model**: The `Transcript` struct defines the data structure for the transcript entries. It is `Codable` for easy decoding from Firestore and `Identifiable` to be used in SwiftUI lists.
-   **View**: The `TranscriptFeedView` is the main UI component. It is responsible for presenting the list of transcripts to the user.
-   **ViewModel**: The `TranscriptViewModel` acts as the bridge between the Model and the View. It contains the business logic for fetching, listening to, and preparing data from Firestore for display.

## 3. Components

### 3.1. `Transcript.swift` (Model)

-   **Purpose**: To model the data retrieved from Firestore.
-   **Properties**:
    -   `id` (String?): The document ID from Firestore, mapped using `@DocumentID`.
    -   `transcript` (String): The content of the transcript.
    -   `timestamp` (Timestamp): The Firestore timestamp of the entry.
    -   `confidence` (Double): The confidence score of the transcript.
-   **Computed Properties**:
    -   `formattedTimestamp` (String): A formatted string representation of the `timestamp` for display in the UI.
    -   `formattedConfidence` (String): A formatted string representation of the `confidence` score.

### 3.2. `TranscriptViewModel.swift` (ViewModel)

-   **Purpose**: To manage the data and business logic of the application.
-   **Conformance**: `ObservableObject`.
-   **Properties**:
    -   `@Published var transcripts`: An array of `Transcript` objects that the view observes for changes.
    -   `db`: A private instance of the Firestore database.
-   **Methods**:
    -   `subscribeToTranscripts()`: Sets up a real-time listener on the `transcripts` Firestore collection. It orders the documents by `timestamp` in descending order and decodes them into `Transcript` objects. Any errors during fetching are printed to the console.

### 3.3. `TranscriptFeedView.swift` (View)

-   **Purpose**: To display the user interface.
-   **Properties**:
    -   `@StateObject private var viewModel`: An instance of `TranscriptViewModel` to provide data to the view.
-   **UI Structure**:
    -   A `NavigationView` to provide a navigation bar with the title "Transcripts".
    -   A `List` that iterates over the `transcripts` array from the `viewModel`.
    -   Each list item is a `VStack` displaying the `transcript` text, `formattedTimestamp`, and `formattedConfidence`.
    -   A "Sign Out" button in the navigation bar.
-   **Lifecycle**:
    -   The `.onAppear` modifier calls `viewModel.subscribeToTranscripts()` to begin listening for data as soon as the view is displayed.

### 3.4. `ScribesteinAPPApp.swift` (App Entry Point)

-   **Purpose**: The main entry point of the application.
-   **Initialization**:
    -   The `init()` method calls `FirebaseApp.configure()` to set up the connection to Firebase. This must be done before any other Firebase services are used.
-   **Root View**:
    -   The `body` of the app sets `ContentView` as the main window's root view and injects the `AuthViewModel` into the environment.

## 4. Data Flow

1.  The `ScribesteinAPPApp` initializes, creates an `AuthViewModel`, and loads the `ContentView`.
2.  `ContentView` checks the `userSession` in the `AuthViewModel`. If it's `nil`, it displays `LoginView`; otherwise, it displays `TranscriptFeedView`.
3.  The user enters their credentials in `LoginView` and taps "Sign In" or "Create Account".
4.  `LoginView` calls the appropriate method on the `AuthViewModel`.
5.  `AuthViewModel` communicates with Firebase to authenticate the user. On success, the `userSession` is updated.
6.  The change in `userSession` causes `ContentView` to switch to `TranscriptFeedView`.
7.  `TranscriptFeedView`'s `.onAppear` modifier triggers `subscribeToTranscripts()` in its `TranscriptViewModel`.
8.  The `TranscriptViewModel` fetches and listens for transcript data from Firestore.
9.  When the user taps "Sign Out", the `signOut` method is called on the `AuthViewModel`, clearing the session and returning the user to the `LoginView`.

## 5. Dependencies

-   **Firebase/Auth**: For user authentication.
-   **Firebase/Firestore**: The app relies on the `FirebaseFirestore` and `FirebaseFirestoreSwift` libraries to interact with the Firestore database. These are managed via Swift Package Manager.

This specification provides a complete technical overview of the ScribesteinAPP.

## User Authentication and Permissions

### Overview

The application uses Firebase Authentication to manage user access. Users can sign in with their email and password. The system is designed to support different permission levels, with an "admin" role for users who need access to restricted features.

### Key Components

-   **`AuthViewModel.swift`**: An `ObservableObject` that manages the user's authentication state, including sign-in, sign-up, sign-out, the current user session, and custom claims for roles.
-   **`LoginView.swift`**: A SwiftUI view that provides the user interface for signing in or creating an account with an email and password.
-   **`ContentView.swift`**: The root view that determines whether to show the `LoginView` or the main app content (`TranscriptFeedView`) based on the user's authentication state.

### Role-Based Access Control

User roles are managed using Firebase Custom Claims. A user with the `"admin": true` custom claim is considered an administrator and will have access to special features within the app.

#### Setting Admin Roles

Admin roles must be set on the backend for security. This can be done using the Firebase Admin SDK in a server environment or a Cloud Function.

Example (Cloud Function):

```javascript
// This is an example of how you might set a custom claim.
// This code would run in a Cloud Function, not in the app.
const admin = require('firebase-admin');
admin.initializeApp();

exports.setAdminRole = functions.https.onCall(async (data, context) => {
  // Ensure the caller is authenticated.
  if (context.auth.token.admin !== true) {
    return { error: 'Only admins can add other admins.' };
  }
  
  // Get user and set custom claim.
  const user = await admin.auth().getUserByEmail(data.email);
  await admin.auth().setCustomUserClaims(user.uid, { admin: true });
  
  return { message: `Success! ${data.email} has been made an admin.` };
});
```

The app will automatically pick up changes to a user's custom claims the next time their ID token is refreshed.
