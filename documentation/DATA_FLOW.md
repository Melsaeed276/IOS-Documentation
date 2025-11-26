# Data Flow Patterns Guide

## Overview

This document describes data flow patterns for iOS applications, from user interaction to API communication and state updates.

## User Journey Flow

```
┌─────────────┐
│  Welcome    │
└──────┬──────┘
       │ User action
       ▼
┌─────────────┐
│ Authentication│ → Credentials + Consents
└──────┬──────┘
       │ Authentication Success
       ▼
┌─────────────┐
│ Verification│ → Verification Code
└──────┬──────┘
       │ Verified
       ▼
┌─────────────┐
│  Main Flow  │
│  ┌────────┐ │
│  │ Step 1 │ │ → Data Collection
│  └───┬────┘ │
│      │      │
│  ┌───▼────┐ │
│  │ Step 2 │ │ → Additional Data
│  └───┬────┘ │
│      │      │
│  ┌───▼────┐ │
│  │ Step 3 │ │ → Final Data
│  └───┬────┘ │
│      │      │
│  ┌───▼────┐ │
│  │Complete│ │ → Completion
│  └────────┘ │
└─────────────┘
```

## Navigation State Flow

### NavigationState Enum

Controls top-level navigation:

```swift
enum NavigationState {
    case splash     // Initial splash screen
    case feature1   // First feature
    case feature2   // Second feature
    case feature3   // Third feature
}
```

### Navigation Transitions

```
SplashView
    ↓ (navigationState = .feature1)
Feature1View
    ↓ (navigationState = .feature2)
Feature2View
    ↓ (navigationState = .feature3)
Feature3View
    ↓ (Flow progression)
    ├── Step1View
    ├── Step2View
    ├── Step3View
    └── CompletionView
```

### State Updates

Navigation is controlled by updating `SessionManager.shared.navigationState`:

```swift
// In ViewModel after successful action
SessionManager.shared.navigationState = .feature2

// In ViewModel after verification
SessionManager.shared.navigationState = .feature3
```

## Data Flow

### DataModel Structure

All application data is stored in a single model:

```swift
struct DataModel {
    var authenticationData: AuthenticationModel        // Credentials, consents
    var userData: UserDataModel     // User information
    var flowData: FlowDataModel   // Flow-specific data
    var completionFlags: CompletionFlags   // Completion tracking
}
```

### Data Persistence

Data is stored in `SessionManager.shared.userInfo`:

```swift
// Access
let userData = SessionManager.shared.userInfo

// Update
SessionManager.shared.userInfo.userData = userDataModel
```

### Data Flow Through Steps

```
1. Authentication Step
   └── Updates: authenticationData (credentials, consents)
   
2. Verification Step
   └── Updates: completionFlags.isVerified = true
   
3. Step 1
   └── Updates: flowData.step1Data
   
4. Step 2
   └── Updates: flowData.step2Data
   
5. Step 3
   └── Updates: flowData.step3Data
   
6. Completion
   └── Updates: completionFlags.isCompleted = true
```

## API Communication Flow

### Request Flow

```
View
    ↓ User interaction
ViewModel
    ↓ Calls repository method
Repository
    ↓ Calls service method
Service
    ↓ Builds API request
APIManager
    ↓ Makes HTTP request
API Endpoint
```

### Response Flow

```
API Endpoint
    ↓ Returns response
APIManager
    ↓ Decodes response
Service
    ↓ Transforms to model
Repository
    ↓ Updates SessionManager
ViewModel
    ↓ Updates @Published properties
View
    ↓ UI updates automatically
```

### Example: Data Submission

```
1. User fills form in View
   └── ViewModel.model contains user input

2. User taps "Submit"
   └── ViewModel.submit() called

3. ViewModel validates data
   └── model.validate() returns errors or empty

4. ViewModel calls Repository
   └── repo.submitData(model)

5. Repository calls Service
   └── service.submitData(data)

6. Service builds API request
   └── Parameters: userId, data fields

7. APIManager makes request
   └── POST /api/endpoint
   └── Headers: Authorization: Bearer {token}

8. API returns response
   └── ResponseModel with success/error

9. Service returns response to Repository

10. Repository updates SessionManager
    └── userInfo.flowData = data
    └── completionFlags.isStepCompleted = true

11. Repository logs event (if needed)
    └── AnalyticsService.track(event: .dataSubmitted)

12. ViewModel updates state
    └── isSubmitted = true
    └── showNextStep = true

13. View updates UI
    └── Navigates to next step
```

## State Management Flow

### SessionManager Updates

All state updates flow through `SessionManager.shared`:

```swift
// Authentication
SessionManager.shared.userInfo.authenticationData = authDataModel

// User Data
SessionManager.shared.userInfo.userData = userDataModel

// Flow Data
SessionManager.shared.userInfo.flowData = flowDataModel

// Completion Flags
SessionManager.shared.userInfo.completionFlags.isVerified = true
SessionManager.shared.userInfo.completionFlags.isCompleted = true
```

### Reactive Updates

Views observe `SessionManager`:

```swift
struct MainView: View {
    @ObservedObject var viewModel = SessionManager.shared
    
    var body: some View {
        switch viewModel.navigationState {
        case .splash: SplashView()
        case .feature1: Feature1View()
        case .feature2: Feature2View()
        case .feature3: Feature3View()
        }
    }
}
```

## Flow Progression Flow

### FlowViewModel

Manages flow step progression:

```swift
class FlowViewModel: ObservableObject {
    static let shared = FlowViewModel()
    
    // Flow management properties
    // Add your flow-specific properties here
}
```


### Step Progression

```swift
// After successful submission
// Update flow state and advance to next step
FlowViewModel.shared.advanceToNextStep()
```

## Error Flow

### Validation Errors

```
User Input
    ↓
ViewModel.validate()
    ↓
Validation Errors Found
    ↓
@Published validationErrors updated
    ↓
View displays field errors
```

### API Errors

```
API Request
    ↓
Error Response
    ↓
APIManager decodes error
    ↓
Throws ResponseErrorHandler
    ↓
Service re-throws
    ↓
Repository re-throws
    ↓
ViewModel catches error
    ↓
@Published errorMessage updated
    ↓
View displays error alert
```

### Error Handling Example

```swift
// In ViewModel
do {
    let success = try await repo.submitData(model)
    // Success handling
} catch let error as ResponseErrorHandler {
    // API error
    self.errorMessage = error.errorMsg
    self.showErrorAlert = true
} catch {
    // System error
    self.errorMessage = error.localizedDescription
    self.showErrorAlert = true
}
```

## Session Management Flow

### Session Initialization

```
App Start
    ↓
AppStartService.startSession()
    ↓
Creates DeviceRequest
    ├── deviceId (UUID)
    ├── ipAddress (public IP)
    ├── deviceName (model name)
    └── channel
    ↓
API: POST /Device/CreateDevice
    ↓
Returns SessionResponse
    ├── sessionId
    └── other session data
    ↓
Stored in SessionManager.sessionID
```

### Session Usage

Session ID is used in subsequent API calls:

```swift
// In API requests (if needed)
let sessionId = SessionManager.shared.sessionID
```

## Token Management Flow

### JWT Token Flow

```
API Request
    ↓
APIManager.getValidToken()
    ↓
Token exists and valid?
    ├── Yes → Use existing token
    └── No → refreshToken()
            ↓
        POST /Auth/GetToken
            ↓
        Returns TokenResponse
            ├── token
            └── expires_on
            ↓
        Store in APIManager.authToken
        Store expiry in APIManager.tokenExpiry
            ↓
        Use token in request
```

### Automatic Token Refresh

Tokens are automatically refreshed when expired:

```swift
actor APIManager {
    private func getValidToken() async throws -> String {
        if let token = APIManager.authToken,
           let expiry = APIManager.tokenExpiry,
           expiry > Date() {
            return token
        }
        return try await refreshToken()
    }
}
```

## Data Synchronization

### Thread Safety

All state updates are dispatched to main thread:

```swift
// In Repository
DispatchQueue.main.async {
    SessionManager.shared.userInfo.userData = data
}
```

### Main Actor Isolation

ViewModels use `@MainActor` for UI updates:

```swift
@MainActor
func submit() async {
    isLoading = true
    // ... API call
    isLoading = false
}
```

## Completion Flow

### Flow Completion

```
CompletionView (Last step)
    ↓
User completes flow
    ↓
AppStartService.onFlowComplete callback
    ├── result: CompletionResult
    └── data: DataModel
    ↓
Host app receives completion data
```

### Completion Data

```swift
AppStartService.startServices(
    from: viewController,
    onComplete: { result in
        // result: Completion result
        // All flow data available in SessionManager.shared.userInfo
    }
)
```

## Data Flow Summary

### Key Principles

1. **Single Source of Truth**: `SessionManager.shared.userInfo`
2. **Reactive Updates**: `@Published` properties trigger UI updates
3. **Unidirectional Flow**: View → ViewModel → Repository → Service → API
4. **Thread Safety**: Main thread for UI updates
5. **Error Propagation**: Errors bubble up through layers

### Data Flow Diagram

```
┌─────────────────────────────────────────┐
│           User Interaction               │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│              View (SwiftUI)             │
└───────────────┬─────────────────────────┘
                │ @ObservedObject
                ▼
┌─────────────────────────────────────────┐
│           ViewModel                      │
│  - Validates input                       │
│  - Manages UI state                      │
└───────────────┬─────────────────────────┘
                │ uses
                ▼
┌─────────────────────────────────────────┐
│          Repository                      │
│  - Business logic                        │
│  - Updates SessionManager                │
└───────────────┬─────────────────────────┘
                │ uses
                ▼
┌─────────────────────────────────────────┐
│           Service                        │
│  - API communication                     │
│  - Data transformation                   │
└───────────────┬─────────────────────────┘
                │ uses
                ▼
┌─────────────────────────────────────────┐
│         APIManager (Actor)               │
│  - Token management                      │
│  - HTTP requests                         │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│           API Endpoint                   │
└─────────────────────────────────────────┘
                │
                ▼ (Response flows back up)
┌─────────────────────────────────────────┐
│      SessionManager.shared              │
│      (State updated)                     │
└───────────────┬─────────────────────────┘
                │ @Published
                ▼
┌─────────────────────────────────────────┐
│              View Updates                │
└─────────────────────────────────────────┘
```
