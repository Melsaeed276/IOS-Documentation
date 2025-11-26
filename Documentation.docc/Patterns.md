# Design Patterns Cookbook

@Metadata {
    @DisplayName("Patterns")
    @PageKind(article)
}

## Overview

This cookbook describes design patterns and architectural decisions for iOS applications. The patterns ensure maintainability, testability, and scalability.

## MVVM Pattern (Model-View-ViewModel)

### Structure

```
┌──────────────┐
│     View     │  SwiftUI Views
│  (SwiftUI)   │
└──────┬───────┘
       │ @ObservedObject
       │ @StateObject
       ▼
┌──────────────┐
│  ViewModel   │  ObservableObject
│  (State)     │  Business Logic
└──────┬───────┘
       │ uses
       ▼
┌──────────────┐
│    Model     │  Data Structures
│  (Data)      │  Validation
└──────────────┘
```

### Implementation Details

#### View Layer
- **Pure SwiftUI views** with minimal logic
- Observes ViewModels via `@ObservedObject` or `@StateObject`
- Handles user interactions and UI updates
- No direct API calls or business logic
- **Cannot call Repository directly** - Must go through ViewModel

**Example**:
```swift
struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    
    var body: some View {
        // UI implementation
        Button("Submit") {
            Task {
                // ✅ Correct: Call ViewModel method
                await viewModel.submit()
            }
        }
    }
}

// ❌ WRONG: Never call Repository directly from View
struct UserProfileViewWrong: View {
    private let repo = UserProfileRepo() // ❌ Don't do this!
    
    var body: some View {
        Button("Submit") {
            Task {
                // ❌ WRONG: View should not call Repository directly
                try await repo.submitUserProfile(data) // ❌ Don't do this!
            }
        }
    }
}
```

#### ViewModel Layer
- **ObservableObject** for reactive updates
- Manages UI state (`@Published` properties)
- Handles user interactions
- **Only layer that can call Repository** - Acts as bridge between View and Repository
- Coordinates with Repository layer
- Performs field-level validation
- Updates `SessionManager` on success

**Example**:
```swift
class UserProfileViewModel: ObservableObject {
    @Published var model: UserProfileModel
    @Published var isLoading: Bool = false
    @Published var validationErrors: [Error] = []
    
    private let repo: UserProfileRepo // ✅ ViewModel can have Repository
    
    init() {
        self.repo = UserProfileRepo()
    }
    
    func submit() async {
        // ✅ Correct: ViewModel calls Repository
        isLoading = true
        do {
            let success = try await repo.submitUserProfile(model)
            // Handle success
            isLoading = false
        } catch {
            // Handle error
            validationErrors.append(error)
            isLoading = false
        }
    }
}
```

#### Model Layer
- **Pure data structures** (structs, enums)
- Contains validation logic
- No dependencies on other layers
- Conforms to `Codable` for API serialization

**Example**:
```swift
struct UserProfileModel: Equatable {
    var firstName: String
    var lastName: String
    var email: String
    
    func validate() -> [ValidationError] {
        // Validation logic
    }
}
```

### MVVM Anti-Patterns

#### ❌ Anti-Pattern 1: View Calling Repository Directly

**What NOT to do**:
```swift
struct UserProfileView: View {
    private let repo = UserProfileRepo() // ❌ View should not have Repository
    
    var body: some View {
        Button("Submit") {
            Task {
                // ❌ WRONG: View calling Repository directly
                try await repo.submitUserProfile(data)
            }
        }
    }
}
```

**Why it's problematic**:
- Violates separation of concerns
- Makes views difficult to test
- Couples UI to business logic
- Breaks MVVM pattern

**Correct approach**: View should call ViewModel methods only.

#### ❌ Anti-Pattern 2: Business Logic in ViewModel

**What NOT to do**:
```swift
class UserProfileViewModel: ObservableObject {
    func submit() async {
        // ❌ WRONG: Complex business logic in ViewModel
        if model.age < 18 {
            throw BusinessError.minimumAgeRequired
        }
        
        // API call directly from ViewModel
        let response = try await apiManager.request(...) // ❌ Should use Repository
    }
}
```

**Why it's problematic**:
- ViewModels become bloated with business logic
- Difficult to test business rules in isolation
- Business logic should be in Repository layer

**Correct approach**: ViewModel coordinates, Repository contains business logic.

## Repository Pattern

### Purpose

The Repository pattern abstracts data access and provides a clean interface for ViewModels. It decouples business logic from data sources.

**Important Rule**: Repository can **only be called from ViewModels**, never directly from Views.

### Structure

```
ViewModel
    ↓
Repository (Business Logic & Service Coordination)
    ↓
    ├── Service A (API Communication)
    ├── Service B (API Communication)
    └── Service C (API Communication)
    ↓
APIManager (Network)
```

**Key Rules**:
- Repository can **only be called from ViewModels** - Never call Repository directly from Views
- Repository can manage **multiple services**
- Services **cannot communicate with each other** directly
- Only Repository can **coordinate between services**

### Implementation

#### Repository Layer
- **Business logic coordination**
- **Only accessible from ViewModels** - Views must never call Repository directly
- **Manages multiple services** - Can orchestrate multiple services for complex operations
- **Updates SessionManager** - Updates global state after operations
- **Error handling** - Transforms and handles errors appropriately

**Example**:
```swift
class UserProfileRepo {
    private let userService: UserServiceProtocol
    private let authService: AuthenticationServiceProtocol
    
    init(
        userService: UserServiceProtocol,
        authService: AuthenticationServiceProtocol
    ) {
        self.userService = userService
        self.authService = authService
    }
    
    func submitUserProfile(_ model: UserProfileModel) async throws -> Bool {
        // ✅ Repository coordinates multiple services
        // 1. Check authentication
        let isAuthenticated = try await authService.checkAuthStatus()
        guard isAuthenticated else {
            throw AuthenticationError.notAuthenticated
        }
        
        // 2. Submit user profile
        let response = try await userService.submitUserProfile(model)
        
        // 3. Update SessionManager
        await MainActor.run {
            SessionManager.shared.userInfo.userData = model
        }
        
        return response.success
    }
}
```

## Service Layer Pattern

### Purpose

Services handle API communication and data transformation. They are protocol-based for testability.

### Key Rules

- **Services cannot call other services** - Only Repository can coordinate services
- **Protocol-oriented** - All services implement protocols
- **No business logic** - Services only handle API communication
- **Error transformation** - Transform API errors to domain errors

**Example**:
```swift
protocol UserServiceProtocol {
    func getUserProfile(userId: String) async throws -> UserResponse
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserResponse
}

class UserService: UserServiceProtocol {
    private let apiManager = APIManager()
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserResponse {
        let endpoint = "users/profile"
        let parameters: [String: Any] = [
            "userId": data.userId,
            "name": data.name
        ]
        
        let response: UserResponse = try await apiManager.request(
            endpoint: endpoint,
            method: .post,
            parameters: parameters,
            responseType: UserResponse.self
        )
        
        // Validate response
        if response.errorCode != 0 {
            throw ResponseErrorHandler(
                errorMsg: response.errorMsg,
                errorCode: response.errorCode
            )
        }
        
        return response
    }
}
```

## Actor Pattern (APIManager)

### Purpose

Swift's `actor` type provides thread-safe access to shared mutable state. The `APIManager` uses this pattern for thread-safe API operations.

**Example**:
```swift
actor APIManager {
    private static var authToken: String?
    private static var tokenExpiry: Date?
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        responseType: T.Type
    ) async throws -> T {
        // Thread-safe by default
        let token = try await getValidToken()
        // ... make request
    }
    
    private func getValidToken() async throws -> String {
        // Thread-safe token management
    }
}
```

## Singleton Pattern

### Purpose

Singletons provide a single instance accessible throughout the application. Used for global state management.

**Example**:
```swift
public final class SessionManager: ObservableObject {
    public static let shared = SessionManager()
    
    @Published var userInfo: DataModel
    @Published var navigationState: NavigationState
    
    private init() {
        // Private initializer
    }
}
```

## Best Practices

1. **Follow MVVM pattern** consistently across features
2. **Repository only from ViewModels** - Never call Repository from Views
3. **Services don't communicate** - Only Repository coordinates services
4. **Use actors for thread safety** - APIManager uses actor pattern
5. **Protocol-oriented design** - All services implement protocols
6. **Error handling** - Handle errors at appropriate layers
7. **State management** - Use SessionManager for global state

For more information on architecture, see <doc:Architecture> and <doc:DataFlow>.

