# iOS Project Architecture Guide

@Metadata {
    @DisplayName("Architecture")
    @PageKind(article)
}

## Overview

This guide describes a modern iOS application architecture built with SwiftUI that follows a modular, feature-based structure with clear separation of concerns.

### Purpose

This architecture template handles:
- User authentication and session management
- Multi-step flows and form collection
- API integration with authentication
- State management across features
- Navigation and flow control

## Architecture Pattern

The recommended architecture uses **MVVM (Model-View-ViewModel) + Repository** pattern:

```
┌─────────────┐
│    View     │  (SwiftUI Views)
└──────┬──────┘
       │ @ObservedObject
       ▼
┌─────────────┐
│  ViewModel  │  (ObservableObject)
└──────┬──────┘
       │ uses
       ▼
┌─────────────┐
│  Repository │  (Business Logic)
└──────┬──────┘
       │ uses
       ▼
┌─────────────┐
│   Service   │  (API Communication)
└──────┬──────┘
       │ uses
       ▼
┌─────────────┐
│ APIManager  │  (Network Layer)
└─────────────┘
```

## Component Relationships

### Key Relationships Explained

**View → ViewModel**:
- Views observe ViewModels via `@ObservedObject` or `@StateObject`
- Views are passive and only display data and handle user interactions
- Views never directly call Repositories or Services

**ViewModel → Repository**:
- ViewModels coordinate with Repositories for business logic
- ViewModels manage UI state and user interactions
- ViewModels update `@Published` properties to trigger view updates

**Repository → Service**:
- Repositories can use multiple Services for complex operations
- Repositories coordinate between Services (Services cannot communicate directly)
- Repositories contain business logic and validation

**Service → APIManager**:
- Services handle API-specific details (endpoints, parameters)
- Services transform models to/from API format
- All network calls go through the actor-based APIManager

**Repository → SessionManager**:
- Repositories update global state in SessionManager
- SessionManager holds the central DataModel
- SessionManager publishes state changes to observing ViewModels

**SessionManager → ViewModels**:
- SessionManager's `@Published` properties trigger updates in ViewModels
- ViewModels observe SessionManager for global state changes
- Navigation state changes propagate through SessionManager

**Core Features**:
- Storage and Security features are used by Repositories
- These features provide cross-cutting concerns
- Accessed through service abstractions

## Entry Points

### Primary Entry Point: AppStartService

The application is initialized through a start service, which provides methods for:

#### 1. UIKit Integration
Presents the main flow as a modal from a UIKit view controller.

```swift
AppStartService.startServices(
    from: viewController,
    onComplete: { result in
        // Handle completion
    }
)
```

#### 2. SwiftUI Integration
Returns a SwiftUI view for integration into SwiftUI apps.

```swift
let mainView = AppStartService.start { result in
    // Handle completion
}
```

### Session Initialization

Before starting the main flow, initialize a session:

```swift
AppStartService.startSession(
    endPointType: .test, // or .production
    completionHandler: { sessionResponse, error in
        // Handle session creation
    }
)
```

## State Management

### SessionManager (Singleton)

`SessionManager` is a singleton `ObservableObject` that manages the entire application state:

```swift
public final class SessionManager: ObservableObject {
    public static let shared = SessionManager()
    
    @Published var userInfo: DataModel
    @Published var navigationState: NavigationState
    public var sessionID: String?
}
```

**Key Responsibilities:**
- Stores application data (`DataModel`)
- Manages navigation state (`NavigationState`)
- Provides session ID for API calls
- Manages verification codes (in debug mode)

### Navigation States

The application uses a navigation state enum to control flow:

```swift
enum NavigationState {
    case splash     // Initial splash screen
    case feature1   // First feature
    case feature2   // Second feature
    case feature3   // Third feature
}
```

Navigation is handled by `MainView`, which observes `SessionManager.shared.navigationState` and displays the appropriate view.

## Main Components

### 1. MainView
Root SwiftUI view that orchestrates the entire flow:
- Observes `SessionManager.shared`
- Switches between views based on `navigationState`
- Handles transitions between screens

### 2. FlowMainView
Manages multi-step flow progression:
- Displays progress indicator
- Switches between flow steps based on `FlowViewModel.currentStep`
- Handles loading states

### 3. FlowViewModel
Singleton that tracks flow progression:
- Manages current step (`currentStep`)
- Handles loading states
- Controls dialog visibility
- Updates step status

## Environment Configuration

The application supports multiple environments:

```swift
public enum Environment {
    case production
    case testing
    case debug
}
```

### Setting Environment from Xcode Project Configuration

The environment can be configured from Xcode build settings, allowing different environments for Debug and Release builds.

#### 1. Add Build Configuration Variable

In Xcode:
1. Select your project in the Project Navigator
2. Select your target
3. Go to **Build Settings** tab
4. Search for "User-Defined" or click the **+** button to add a new setting
5. Add a new setting named `APP_ENVIRONMENT` (or `ENVIRONMENT`)
6. Set values for each configuration:
   - **Debug**: `debug`
   - **Release**: `production`
   - **Testing** (if you have a custom scheme): `testing`

#### 2. Add to Info.plist (Optional)

Alternatively, you can add the environment to `Info.plist`:

1. Open `Info.plist`
2. Add a new key: `AppEnvironment` (or `Environment`)
3. Set the value to `$(APP_ENVIRONMENT)` to reference the build setting

#### 3. Read from Build Configuration in Code

Update `AppModel` to read from build configuration:

```swift
public class AppModel {
    public static var environment: Environment {
        #if DEBUG
        // Read from Info.plist or build setting
        if let envString = Bundle.main.infoDictionary?["AppEnvironment"] as? String {
            return Environment.from(string: envString)
        }
        return .debug
        #else
        // Read from Info.plist or build setting
        if let envString = Bundle.main.infoDictionary?["AppEnvironment"] as? String {
            return Environment.from(string: envString)
        }
        return .production
        #endif
    }
}

extension Environment {
    static func from(string: String) -> Environment {
        switch string.lowercased() {
        case "production", "prod":
            return .production
        case "testing", "test":
            return .testing
        case "debug", "debugging":
            return .debug
        default:
            return .production
        }
    }
}
```

### Environment Effects

Environment affects:
- API endpoints
- Debug features
- Error messages
- Logging levels

## Data Model

### DataModel
Central data structure that holds all application information:

```swift
struct DataModel {
    var authenticationData: AuthenticationModel
    var userData: UserDataModel
    var flowData: FlowDataModel
    var completionFlags: CompletionFlags
}
```

This model is stored in `SessionManager.shared.userInfo` and persists throughout the flow.

## Feature Module Structure

Each feature follows a consistent structure:

```
FeatureName/
├── Model/          # Data models and DTOs
├── View/           # SwiftUI views
├── ViewModel/      # ObservableObject view models
├── Repo/           # Repository layer (business logic)
└── Services/       # API service layer
```

**Example: UserProfileFeature**
- `Model/UserProfileModel.swift` - Data structure
- `View/UserProfileView.swift` - UI
- `ViewModel/UserProfileViewModel.swift` - State management
- `Repo/UserProfileRepo.swift` - Business logic
- `Services/UserProfileService.swift` - API calls

## Core Features

### Storage Feature (`Core/Features/Storage/`)

Provides storage abstraction for:
- **KeychainManager**: Secure credential storage
- **UserDefaultsManager**: User preferences and settings
- **StorageService**: Unified storage interface

### Security Feature (`Core/Features/Security/`)

Handles security-related functionality:
- **EncryptionManager**: Data encryption/decryption
- **BiometricManager**: Biometric authentication
- **SecurityValidator**: Security validation rules

### Constants (`Core/Constants/`)

Centralized application constants:
- **AppConstants**: General app-wide constants
- **APIConstants**: API endpoints and configuration
- **Configuration**: App configuration and feature flags

## API Architecture

### APIManager (Actor)

The application uses Swift's `actor` type for thread-safe API management:

- **Automatic Token Management**: Refreshes tokens when expired
- **Generic Request Method**: Type-safe API calls
- **Error Handling**: Decodes and throws structured errors
- **Environment-aware**: Switches endpoints based on environment

### API Flow

```
ViewModel → Repository → Service → APIManager → API Endpoint
                ↓
         Update SessionManager
                ↓
         Notify ViewModel (via @Published)
```

For detailed API integration information, see <doc:APIIntegration>.

## Error Handling

Errors are handled at multiple levels:

1. **Validation Errors**: Field-level validation in ViewModels
2. **API Errors**: Structured error responses from `APIManager`
3. **System Errors**: Fixed error messages via configuration

## Utilities

### Helpers (`Utils/Helpers/`)

Reusable utility functions:
- **Validators**: Input validation helpers
- **Formatters**: Data formatting utilities
- **DateHelpers**: Date manipulation functions
- **StringHelpers**: String utility functions

## Thread Safety

- `APIManager` uses `actor` for thread-safe API calls
- UI updates are dispatched to `MainActor`
- `SessionManager` uses `@Published` for reactive updates

## Best Practices

1. **State Management**: Always use `SessionManager.shared` for global state
2. **Navigation**: Update `navigationState` to navigate between screens
3. **API Calls**: Use Repository layer, never call Services directly from ViewModels
4. **Error Handling**: Display user-friendly messages via alerts
5. **Testing**: Use environment `.debug` for test data injection
6. **Modularity**: Keep features self-contained and independent
7. **Documentation**: Document complex business logic

For more detailed information on patterns and best practices, see <doc:Patterns> and <doc:CodeReview>.

