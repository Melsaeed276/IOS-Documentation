# iOS Project Glossary

@Metadata {
    @DisplayName("Glossary")
    @PageKind(article)
}

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

## D

### DataModel
The central data structure that holds all application information, including authentication data, user data, flow data, and completion flags.

## F

### Feature Module
A self-contained module representing a specific feature or functionality. Each feature follows a consistent structure: Model, View, ViewModel, Repo, Services.

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

## O

### ObservableObject
A protocol that allows objects to publish changes to their properties. ViewModels conform to this protocol and use `@Published` properties.

### @ObservedObject
A SwiftUI property wrapper that creates a connection to an `ObservableObject`, allowing views to react to state changes.

### @Published
A property wrapper used in `ObservableObject` that automatically publishes changes to observers, triggering view updates.

## R

### Repository (Repo)
The business logic layer that coordinates between ViewModels and Services. Contains validation, data transformation, and business rules. Repositories can use multiple Services but Services cannot communicate directly.

## S

### Service
The API communication layer that handles network requests. Services transform models to/from API format and use `APIManager` for actual network calls.

### SessionManager
A singleton `ObservableObject` that manages the entire application state, including user information, navigation state, and session ID.

### Singleton
A design pattern where only one instance of a class exists. `SessionManager` and `FlowViewModel` are implemented as singletons.

## V

### View
SwiftUI views that display UI and handle user interactions. Views are passive and only observe ViewModels via `@ObservedObject` or `@StateObject`.

### ViewModel
An `ObservableObject` that manages view state and coordinates with Repositories. ViewModels handle user interactions, perform field-level validation, and update `@Published` properties to trigger view updates.

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

For more detailed information, see <doc:Architecture>, <doc:Patterns>, and <doc:DataFlow>.

