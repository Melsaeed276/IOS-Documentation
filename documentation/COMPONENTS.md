# Component Structure Guide

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

---

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

**State Management**:
```swift
@ObservedObject var viewModel = SessionManager.shared
```

---

### SessionManager

**Location**: `ProjectName/Core/Managers/SessionManager.swift`

**Purpose**: Singleton state manager for the entire application.

**Type**: `ObservableObject` (singleton)

**Key Properties**:
- `@Published var userInfo: DataModel` - Complete application data
- `@Published var navigationState: NavigationState` - Current navigation state
- `sessionID: String?` - API session identifier
- `verificationCode: String?` - Verification code (debug mode only)

**Key Methods**:
- `updateSession(with:)` - Updates user information
- `clearSession()` - Resets session state

**Usage**:
```swift
// Access singleton
let session = SessionManager.shared

// Update navigation
session.navigationState = .feature1

// Update user data
session.userInfo.userData = userDataModel
```

---

### ConfigurationModel

**Location**: `ProjectName/Core/Models/ConfigurationModel.swift`

**Purpose**: Configuration model holding application configuration settings, tokens, and environment flags.

**Structure**:
```swift
struct ConfigurationModel {
    var token: String?
    var refreshToken: String?
    var isDebugging: Bool
    var endpoint: String
    var environment: Environment
    var sessionID: String?
    var apiBaseURL: String
}
```

**Key Properties**:
- `token` - Authentication token (JWT)
- `refreshToken` - Token refresh token
- `isDebugging` - Debug mode flag
- `endpoint` - API endpoint configuration
- `environment` - Current environment (production, testing, debug)
- `sessionID` - Session identifier
- `apiBaseURL` - Base URL for API calls

**Usage**:
```swift
// Access configuration
let config = ConfigurationModel.shared
config.token = "your-token"
config.isDebugging = true
config.endpoint = "https://api.example.com"
```

---

### FlowMainView

**Location**: `ProjectName/Features/Flow/MainView/FlowMainView.swift`

**Purpose**: Container view for multi-step flow collection.

**Key Features**:
- Displays progress indicator
- Manages flow step progression
- Handles loading states
- Shows dialog overlays

**Flow Steps** (via `FlowViewModel.currentStep`):
- `.step1` → `Step1View`
- `.step2` → `Step2View`
- `.step3` → `Step3View`
- `.completion` → `CompletionView`

---

### FlowViewModel

**Location**: `ProjectName/Features/Flow/ViewModel/FlowViewModel.swift`

**Purpose**: Singleton view model managing flow progression and progress state.

**Type**: `ObservableObject` (singleton)

**Key Properties**:
- `currentStep: FlowType` - Current flow step
- `isLoading: Bool` - Loading state
- `showDialog: Bool` - Dialog visibility
- Step status tracking

**Key Methods**:
- `updateCurrentStepStatus(status:)` - Updates step status
- Progress tracking and validation

---

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

### Example: UserProfileFeature

#### UserProfileViewModel

**Location**: `ProjectName/Features/UserProfile/ViewModel/UserProfileViewModel.swift`

**Key Properties**:
- `model: UserProfileModel` - User profile data
- `validationErrors: [ValidationError]` - Validation errors
- `isLoading: Bool` - Submission state
- Field-specific error flags

**Key Methods**:
- `submit()` - Validates and submits user profile
- `validateFields()` - Re-validates all fields

**Validation**:
- Required fields
- Format validation
- Business rule validation

#### UserProfileView

**Location**: `ProjectName/Features/UserProfile/View/UserProfileView.swift`

**Features**:
- Input fields
- Validation error indicators
- Submit button
- Loading states
- Error handling

---

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

---

### ProgressIndicator

**Location**: `ProjectName/Features/Flow/View/ProgressIndicator.swift`

**Purpose**: Progress indicator showing current flow step.

**Features**:
- Visual progress bar
- Step indicators
- Current step highlighting
- Completion status

---

### Reusable View Components

**Location**: `ProjectName/Utils/View/`

#### LabeledInputField
Standardized input field with label and error display.

#### OTPInputView
OTP input field component.

#### BaseLoadingView
Base loading indicator.

#### AlertItem
Alert presentation helper.

#### InputFieldModifier
Input field styling modifier.

#### ToolbarModifier
Keyboard toolbar modifier.

#### ExitConfirmationModifier
Exit confirmation dialog modifier.

---

## Core Feature Components

### Storage Components

**Location**: `ProjectName/Core/Features/Storage/`

#### KeychainManager
Secure storage for sensitive data like tokens and credentials.

#### UserDefaultsManager
User preferences and non-sensitive settings storage.

#### StorageService
Unified interface for storage operations, abstracting Keychain and UserDefaults.

---

### Security Components

**Location**: `ProjectName/Core/Features/Security/`

#### EncryptionManager
Handles data encryption and decryption operations.

#### BiometricManager
Manages biometric authentication (Face ID, Touch ID).

#### SecurityValidator
Validates security-related data and enforces security rules.

---

### Constants

**Location**: `ProjectName/Core/Constants/`

#### AppConstants
General application-wide constants.

#### APIConstants
API endpoints, base URLs, and API-related configuration.

#### Configuration
App configuration, feature flags, and environment settings.

---

## Extension Components

### String+Localization

**Location**: `ProjectName/Utils/Extension/String+Localization.swift`

**Purpose**: Localization helper for strings.

**Usage**:
```swift
let localized = "key".localized()
```

### Date+Ext

**Location**: `ProjectName/Utils/Extension/Date+Ext.swift`

**Purpose**: Date formatting utilities.

**Methods**:
- `formattedDate() -> String?` - Format for API
- `toISO8601String() -> String` - ISO8601 format

### Publisher+Ext

**Location**: `ProjectName/Utils/Extension/Publisher+Ext.swift`

**Purpose**: Combine publisher extensions.

**Features**:
- Keyboard height publisher
- Common publisher utilities

---

## Helper Components

**Location**: `ProjectName/Utils/Helpers/`

### Validators
Input validation helper functions for forms and user input.

### Formatters
Data formatting utilities for numbers, currencies, dates, etc.

### DateHelpers
Date manipulation and formatting helper functions.

### StringHelpers
String utility functions for common string operations.

---

## Component Relationships

```
AppStartService
    ↓
MainView
    ↓
SessionManager (shared state)
    ↓
┌─────────────────────────────────┐
│  WelcomeView                    │
│  AuthenticationView → AuthViewModel│
│  VerificationView → VerificationViewModel│
│  FlowMainView                   │
│    ├── Step1View                │
│    ├── Step2View                │
│    └── Step3View                │
└─────────────────────────────────┘
         ↓
    FlowViewModel
         ↓
    DataModel (in SessionManager)
```

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
