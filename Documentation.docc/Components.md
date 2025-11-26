# Component Structure Guide

@Metadata {
    @DisplayName("Components")
    @PageKind(article)
}

## Core Components

### AppStartService

**Location**: `ProjectName/AppStartService.swift`

**Purpose**: Application entry point that initializes and presents the main flow.

**Key Methods**:

1. **`startServices(from:onComplete:)`**
   - Presents the main flow as a modal from a UIKit view controller
   - Creates a `UIHostingController` with `MainView`
   - Configures presentation style and safe area insets
   - Handles completion callback

2. **`start(onComplete:) -> MainView`**
   - Returns a SwiftUI `MainView` for SwiftUI integration
   - Sets up completion handler

**Usage**:
```swift
// UIKit integration
AppStartService.startServices(
    from: viewController,
    onComplete: { result in
        // Handle completion
    }
)

// SwiftUI integration
let mainView = AppStartService.start { result in
    // Handle completion
}
```

### MainView

**Location**: `ProjectName/MainView.swift`

**Purpose**: Root navigation view that orchestrates the entire application flow.

**Key Features**:
- Observes `SessionManager.shared.navigationState`
- Switches between views based on navigation state
- Handles smooth transitions between screens
- Supports light/dark mode configuration

**Navigation States**:
- `.splash` → `SplashView`
- `.feature1` → `Feature1View`
- `.feature2` → `Feature2View`
- `.feature3` → `Feature3View`

### SessionManager

**Location**: `ProjectName/Core/Managers/SessionManager.swift`

**Purpose**: Singleton state manager for the entire application.

**Type**: `ObservableObject` (singleton)

**Key Properties**:
- `@Published var userInfo: DataModel` - Complete application data
- `@Published var navigationState: NavigationState` - Current navigation state
- `sessionID: String?` - API session identifier
- `verificationCode: String?` - Verification code (debug mode only)

**Usage**:
```swift
// Access singleton
let session = SessionManager.shared

// Update navigation
session.navigationState = .feature1

// Update user data
session.userInfo.userData = userDataModel
```

## Feature Modules

### Feature Module Structure

Each feature follows a consistent structure:

```
FeatureName/
├── Model/          # Data models, DTOs, enums
├── View/           # SwiftUI views and subviews
├── ViewModel/      # ObservableObject view models
├── Repo/           # Repository layer (business logic)
└── Services/       # API service implementations
```

## Utility Components

### APIManager

**Location**: `ProjectName/Core/Managers/APIManager.swift`

**Type**: `actor` (thread-safe)

**Purpose**: Centralized API communication with automatic JWT token management.

**Key Features**:
- Automatic token refresh
- Generic request method
- Environment-aware endpoints
- Error response decoding
- JSON debugging

**Usage**:
```swift
let apiManager = APIManager()
let response: MyResponse = try await apiManager.request(
    endpoint: "users/endpoint",
    method: .post,
    parameters: ["key": "value"],
    responseType: MyResponse.self
)
```

For detailed API integration information, see <doc:APIIntegration>.

## Component Communication

1. **State Management**: All components access `SessionManager.shared`
2. **Navigation**: Update `navigationState` to navigate
3. **Flow Progression**: `FlowViewModel` manages steps
4. **API Calls**: ViewModels → Repositories → Services → APIManager
5. **Data Flow**: User input → ViewModel → Repository → Service → API → Update SessionManager

## Best Practices

1. **Single Responsibility**: Each component should have one clear purpose
2. **Reusability**: Extract common UI patterns into reusable components
3. **Testability**: Design components to be easily testable
4. **Documentation**: Document complex components with clear comments
5. **Consistency**: Follow the same structure across all feature modules

For more information on architecture, see <doc:Architecture> and <doc:Patterns>.
