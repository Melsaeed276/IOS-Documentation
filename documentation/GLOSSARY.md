# iOS Project Glossary

This glossary defines key terms, concepts, and patterns used throughout the iOS project documentation.

## A

### Actor
A Swift concurrency feature that provides thread-safe access to shared mutable state. The `APIManager` is implemented as an actor to ensure thread-safe API operations.

### APIManager
A centralized actor-based network layer responsible for all API communication. Handles automatic JWT token management, environment-aware endpoints, and structured error handling.

### AppStartService
The application entry point that initializes and presents the main flow. Provides methods for both UIKit and SwiftUI integration.

### Architecture Pattern
The overall structural design of the application. This project uses **MVVM (Model-View-ViewModel) + Repository** pattern.

## B

### Base URL
The root URL for all API endpoints. Configured based on the current environment (production, testing, debug).

### BiometricManager
A component in the Security feature that manages biometric authentication (Face ID, Touch ID).

## C

### ChangeNotifier
A Combine framework protocol used for notifying observers of state changes. Not directly used in this architecture, but similar concept applies to `ObservableObject`.

### Codable
A Swift protocol that combines `Encodable` and `Decodable` for JSON serialization/deserialization.

### Combine
Apple's reactive programming framework. Used implicitly through `@Published` properties in `ObservableObject`.

### ConfigurationModel
A model holding application configuration settings, tokens, and environment flags.

### Core Features
Shared features used across the application, including Storage and Security features.

## D

### DataModel
The central data structure that holds all application information, including authentication data, user data, flow data, and completion flags.

### Data Transfer Object (DTO)
A data structure used to transfer data between layers or over the network. Often used in API request/response models.

### Debug Mode
A development environment mode that enables test data injection, detailed logging, and debugging features.

## E

### EncryptionManager
A component in the Security feature that handles data encryption and decryption operations.

### Endpoint
A specific API URL path used for making network requests. Combined with the base URL to form complete API URLs.

### Environment
The deployment environment configuration (production, testing, debug). Affects API endpoints, debug features, and error messages.

### Error Handling
The process of catching, processing, and responding to errors at multiple levels: validation errors, API errors, and system errors.

## F

### Feature Module
A self-contained module representing a specific feature or functionality. Each feature follows a consistent structure: Model, View, ViewModel, Repo, Services.

### FlowMainView
A container view for multi-step flow collection that displays progress indicators and manages flow step progression.

### FlowType
An enum representing different steps in a multi-step flow (e.g., `.step1`, `.step2`, `.step3`, `.completion`).

### FlowViewModel
A singleton `ObservableObject` that manages flow progression, loading states, and step status tracking.

## G

### Global State
Application-wide state managed by `SessionManager`. Includes user information, navigation state, and session data.

## H

### HTTP Method
The type of HTTP request: GET, POST, PUT, DELETE, PATCH. Defined in the `HTTPMethod` enum.

## I

### Info.plist
An iOS configuration file that contains app metadata, permissions, and configuration settings.

### Initialization
The process of setting up the application, including session creation, service configuration, and state management setup.

## J

### JWT (JSON Web Token)
A compact, URL-safe token format used for authentication. Automatically managed by `APIManager`.

## K

### Keychain
iOS secure storage system for sensitive data like tokens and credentials. Managed by `KeychainManager`.

### KeychainManager
A component in the Storage feature that provides secure credential storage using iOS Keychain.

## L

### Localization
The process of adapting the app for different languages and regions. Uses `.lproj` folders and `Localizable.strings` files.

## M

### MainView
The root SwiftUI view that orchestrates the entire application flow. Observes `SessionManager` and switches between views based on navigation state.

### Model
Pure data structures (structs, enums) that contain validation logic and conform to `Codable` for API serialization.

### MVVM (Model-View-ViewModel)
The architectural pattern used in this project. Separates concerns into three layers: Model (data), View (UI), and ViewModel (state and logic coordination).

## N

### NavigationState
An enum that represents the current navigation state of the application (e.g., `.splash`, `.feature1`, `.feature2`).

### NavigationCoordinator
A component that manages navigation flow and state transitions.

## O

### ObservableObject
A protocol that allows objects to publish changes to their properties. ViewModels conform to this protocol and use `@Published` properties.

### @ObservedObject
A SwiftUI property wrapper that creates a connection to an `ObservableObject`, allowing views to react to state changes.

### @Published
A property wrapper used in `ObservableObject` that automatically publishes changes to observers, triggering view updates.

## P

### Production Environment
The live, production deployment environment with production API endpoints and optimized settings.

## R

### Repository (Repo)
The business logic layer that coordinates between ViewModels and Services. Contains validation, data transformation, and business rules. Repositories can use multiple Services but Services cannot communicate directly.

### Response Model
A data structure that represents the response from an API endpoint. Conforms to `Decodable` for JSON parsing.

## S

### Security Feature
A core feature module that handles security-related functionality: encryption, biometric authentication, and security validation.

### Service
The API communication layer that handles network requests. Services transform models to/from API format and use `APIManager` for actual network calls.

### Session
A user session that maintains state throughout the application lifecycle. Managed by `SessionManager`.

### SessionManager
A singleton `ObservableObject` that manages the entire application state, including user information, navigation state, and session ID.

### Singleton
A design pattern where only one instance of a class exists. `SessionManager` and `FlowViewModel` are implemented as singletons.

### Splash View
The initial view displayed when the application starts, typically shown during initialization.

### State Management
The process of managing and updating application state. This project uses `SessionManager` for global state and `ObservableObject` for view-specific state.

### Storage Feature
A core feature module that provides storage abstraction for Keychain (secure storage) and UserDefaults (preferences).

### SwiftUI
Apple's declarative UI framework used for building user interfaces in this project.

### @StateObject
A SwiftUI property wrapper that creates and owns an `ObservableObject` instance, ensuring it persists across view updates.

## T

### Testing Environment
A deployment environment used for testing with staging API endpoints and test data.

### Thread Safety
Ensuring that concurrent access to shared resources doesn't cause data corruption. `APIManager` uses Swift actors for thread-safe operations.

### Token
An authentication token (JWT) used for API authorization. Automatically managed and refreshed by `APIManager`.

### Token Refresh
The automatic process of obtaining a new authentication token when the current token expires.

## U

### UIKit
Apple's older UI framework. This project can integrate with UIKit through `AppStartService.startServices(from:onComplete:)`.

### UserDefaults
iOS storage system for non-sensitive user preferences and settings. Managed by `UserDefaultsManager`.

### UserDefaultsManager
A component in the Storage feature that provides user preferences and settings storage.

## V

### Validation
The process of checking data for correctness, completeness, and compliance with business rules. Performed at multiple levels: field-level in ViewModels, business-level in Repositories.

### View
SwiftUI views that display UI and handle user interactions. Views are passive and only observe ViewModels via `@ObservedObject` or `@StateObject`.

### ViewModel
An `ObservableObject` that manages view state and coordinates with Repositories. ViewModels handle user interactions, perform field-level validation, and update `@Published` properties to trigger view updates.

## W

### Widget
A reusable SwiftUI view component. Can refer to both standard SwiftUI views and custom reusable components.

---

## Common Patterns and Concepts

### Data Flow
The path data takes through the application:
```
View → ViewModel → Repository → Service → APIManager → API
                ↓
         Update SessionManager
                ↓
         Notify ViewModel (via @Published)
                ↓
         Update View
```

### Layer Responsibilities

**View Layer**:
- Display UI
- Handle user interactions
- Observe ViewModels
- Cannot call Repository directly

**ViewModel Layer**:
- Manage UI state
- Handle user interactions
- Coordinate with Repository
- Perform field-level validation
- Only layer that can call Repository

**Repository Layer**:
- Business logic
- Data validation
- Coordinate between Services
- Update SessionManager

**Service Layer**:
- API communication
- Transform models
- Use APIManager

**APIManager**:
- Network operations
- Token management
- Error handling

### Anti-Patterns to Avoid

1. **View calling Repository directly** - Views should only call ViewModel methods
2. **Business logic in ViewModel** - Complex business logic belongs in Repository
3. **Services communicating directly** - Services should only communicate through Repositories
4. **Direct API calls from ViewModel** - All API calls must go through Repository → Service → APIManager

---

**Last Updated**: Template Version 1.0

