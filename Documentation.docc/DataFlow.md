# Data Flow Patterns Guide

@Metadata {
    @DisplayName("Data Flow")
    @PageKind(article)
}

## Overview

This document describes data flow patterns for iOS applications, from user interaction to API communication and state updates.

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

## Data Flow Summary

### Key Principles

1. **Single Source of Truth**: `SessionManager.shared.userInfo`
2. **Reactive Updates**: `@Published` properties trigger UI updates
3. **Unidirectional Flow**: View → ViewModel → Repository → Service → API
4. **Thread Safety**: Main thread for UI updates
5. **Error Propagation**: Errors bubble up through layers

For more detailed information, see <doc:Architecture> and <doc:APIIntegration>.
