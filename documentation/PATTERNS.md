# Design Patterns Cookbook

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

### Performance Implications

**ViewModel Overhead**:
- Each ViewModel instance maintains state and observers
- `@Published` properties create Combine publishers (memory overhead)
- ViewModels should be released when views disappear to prevent memory leaks

**Memory Considerations**:
- ViewModels hold references to Repositories and Models
- Use `weak` references for delegates to avoid retain cycles
- Release ViewModels when not needed (e.g., when navigating away)

**UI Update Performance**:
- `@Published` triggers view updates on main thread
- Minimize `@Published` properties to essential state only
- Batch updates when possible to reduce view redraws

**Best Practices for Performance**:
```swift
class UserProfileViewModel: ObservableObject {
    // ✅ Only essential published properties
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // ✅ Use regular properties for non-UI state
    private var internalState: InternalState
    
    // ✅ Release resources in deinit
    deinit {
        // Cleanup
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
        
        if model.email.contains("@company.com") {
            // Complex business rules
            processCompanyEmail()
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

#### ❌ Anti-Pattern 3: ViewModel Holding UI References

**What NOT to do**:
```swift
class UserProfileViewModel: ObservableObject {
    var view: UserProfileView? // ❌ ViewModel should not reference View
    var navigationController: UINavigationController? // ❌ Wrong
    
    func navigate() {
        view?.navigationController?.pushViewController(...) // ❌ Wrong
    }
}
```

**Why it's problematic**:
- Creates tight coupling between ViewModel and View
- Makes ViewModels platform-specific
- Violates MVVM principles

**Correct approach**: Use state-based navigation or navigation coordinator.

#### ❌ Anti-Pattern 4: Model with Business Logic

**What NOT to do**:
```swift
struct UserProfileModel {
    var firstName: String
    
    func submitToAPI() async throws { // ❌ Model should not make API calls
        let apiManager = APIManager()
        return try await apiManager.request(...)
    }
    
    func processPayment() { // ❌ Model should not contain business logic
        // Complex payment processing
    }
}
```

**Why it's problematic**:
- Models should be pure data structures
- Makes models difficult to test
- Violates single responsibility principle

**Correct approach**: Models are data containers only, logic belongs in Repository.

---

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
- Final validation and business rule checks before service calls
- Decides which service to use (production vs mock)
- Transforms data between layers
- Updates `SessionManager`
- Handles logging and analytics
- **Service coordination** - Only Repository can coordinate between services (services cannot talk to each other)

**Example**:
```swift
class UserProfileRepo {
    private let userProfileService: UserProfileServiceProtocol
    private let authenticationService: AuthenticationServiceProtocol
    private let notificationService: NotificationServiceProtocol
    
    init() {
        // Environment-based service selection
        self.userProfileService = UserProfileService()
        self.authenticationService = AuthenticationService()
        self.notificationService = NotificationService()
    }
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> Bool {
        // Business logic: Final validation
        guard !data.firstName.isEmpty else {
            throw ValidationError.invalidFirstName
        }
        
        guard !data.lastName.isEmpty else {
            throw ValidationError.invalidLastName
        }
        
        // Business logic: Additional checks
        if data.age < 18 {
            throw BusinessError.minimumAgeRequired
        }
        
        // Verify authentication before submission (Repository coordinates services)
        let authStatus = try await authenticationService.checkAuthStatus()
        guard authStatus.isValid else {
            throw BusinessError.authenticationRequired
        }
        
        // Call service layer (handles endpoint and parameters)
        let response = try await userProfileService.submitUserProfile(data)
        
        // Business logic: Process response
        guard response.isSuccess else {
            throw BusinessError.submissionFailed
        }
        
        // Repository coordinates multiple services
        // Send notification after successful submission
        try await notificationService.sendNotification(
            type: .profileUpdated,
            userId: data.userId
        )
        
        // Update global state
        DispatchQueue.main.async {
            SessionManager.shared.userInfo.userData = data
        }
        
        // Logging
        AnalyticsService.track(event: .profileSubmitted)
        
        return true
    }
}
```

#### Service Layer
- **Protocol-based** for testability
- Handles API communication details (endpoints, parameters)
- Transforms models to API DTOs
- Error handling and response parsing
- No business logic - pure API communication
- **Cannot call other services** - Services are isolated and can only communicate through Repository
- **Must have mock data** - Each service must provide its own mock data for testing

**Example**:
```swift
protocol UserProfileServiceProtocol {
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse
}

class UserProfileService: UserProfileServiceProtocol {
    private let apiManager = APIManager()
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        // Service layer: API-specific details
        let endpoint = "users/profile"
        let parameters: [String: Any] = [
            "firstName": data.firstName,
            "lastName": data.lastName,
            "email": data.email,
            "age": data.age
        ]
        
        return try await apiManager.request(
            endpoint: endpoint,
            method: .post,
            parameters: parameters,
            responseType: UserProfileResponse.self
        )
        
        // ❌ DO NOT: Call other services from here
        // ❌ let authService = AuthenticationService()
        // ❌ try await authService.checkAuth() // Wrong!
        // ✅ Repository can coordinate multiple services
    }
}
```

### Repository Anti-Patterns

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
- Violates architecture layers
- Makes testing difficult
- Couples UI to business logic

**Correct approach**: View → ViewModel → Repository

#### ❌ Anti-Pattern 2: Repository Making Direct API Calls

**What NOT to do**:
```swift
class UserProfileRepo {
    private let apiManager = APIManager() // ❌ Repository should not have APIManager
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> Bool {
        // ❌ WRONG: Repository making direct API calls
        let response = try await apiManager.request(
            endpoint: "users/profile",
            method: .post,
            parameters: data.toDictionary(),
            responseType: UserProfileResponse.self
        )
        return response.isSuccess
    }
}
```

**Why it's problematic**:
- Repository should use Service layer for API calls
- Mixes business logic with API details
- Hard to test and maintain

**Correct approach**: Repository → Service → APIManager

#### ❌ Anti-Pattern 3: Service Calling Another Service

**What NOT to do**:
```swift
class UserProfileService: UserProfileServiceProtocol {
    private let authService = AuthenticationService() // ❌ Service should not call other services
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        // ❌ WRONG: Service calling another service
        let authStatus = try await authService.checkAuthStatus()
        guard authStatus.isValid else {
            throw BusinessError.authenticationRequired
        }
        
        // API call
        return try await apiManager.request(...)
    }
}
```

**Why it's problematic**:
- Services should be isolated
- Creates tight coupling between services
- Makes testing difficult
- Repository should coordinate services

**Correct approach**: Repository coordinates multiple services

#### ❌ Anti-Pattern 4: Repository Without Business Logic

**What NOT to do**:
```swift
class UserProfileRepo {
    private let service: UserProfileServiceProtocol
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> Bool {
        // ❌ WRONG: Repository is just a pass-through
        let response = try await service.submitUserProfile(data)
        return response.isSuccess
        // No business logic, validation, or coordination
    }
}
```

**Why it's problematic**:
- Repository becomes unnecessary layer
- Business logic ends up in ViewModel or Service
- Defeats purpose of Repository pattern

**Correct approach**: Repository should contain business logic, validation, and service coordination

### Performance Implications

**Coordination Overhead**:
- Repository coordinates multiple services, adding a layer of indirection
- Overhead is minimal and worth it for maintainability
- Consider caching frequently accessed data at Repository level

**Caching Strategies**:
- Repository-level caching reduces redundant API calls
- Cache expiration and invalidation strategies
- Memory vs. performance trade-offs

**Example - Repository Caching**:
```swift
class UserProfileRepo {
    private var cache: [String: CachedProfile] = [:]
    private let cacheExpiry: TimeInterval = 300
    
    func getUserProfile(id: String) async throws -> UserProfile {
        // Check cache first
        if let cached = cache[id],
           cached.timestamp.addingTimeInterval(cacheExpiry) > Date() {
            return cached.profile
        }
        
        // Fetch and cache
        let profile = try await service.getUserProfile(id: id)
        cache[id] = CachedProfile(profile: profile, timestamp: Date())
        return profile
    }
}
```

**Service Coordination Performance**:
- Coordinating multiple services adds sequential async calls
- Consider parallel execution when services are independent
- Use `async let` for parallel service calls when possible

### Benefits

1. **Testability**: Easy to mock services
2. **Flexibility**: Switch between mock and production services
3. **Separation**: Business logic (Repository) separate from API details (Service)
4. **Maintainability**: Changes to API endpoints/parameters only affect Service layer
5. **Clear Responsibilities**: Repository handles business rules, Service handles API communication

---

## Service Layer Architecture

### Protocol-Oriented Design

All services implement protocols for:
- **Testability**: Easy to create mock implementations
- **Flexibility**: Swap implementations without changing repositories
- **Dependency Injection**: Inject services into repositories

**Example**:
```swift
protocol UserProfileServiceProtocol {
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse
}

class UserProfileService: UserProfileServiceProtocol {
    // Production implementation
}

// Mock implementation for testing
class MockUserProfileService: UserProfileServiceProtocol {
    // Each service must have its own mock data
    private let mockData: UserProfileResponse = UserProfileResponse(
        userId: "mock-user-123",
        firstName: "Mohammed",
        lastName: "Elsaeed",
        email: "moahmed.elsaeed@example.com",
        isSuccess: true,
        message: "Profile updated successfully"
    )
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Return mock data
        return mockData
    }
}
```

### Mock Data Requirements

**Each service must provide its own mock data** for testing:

1. **Mock Service Implementation**: Create a `Mock[ServiceName]Service` class implementing the service protocol
2. **Mock Data Properties**: Define mock data as private properties within the mock service
3. **Realistic Data**: Mock data should be realistic and representative of actual API responses
4. **Multiple Scenarios**: Consider providing different mock data for success, error, and edge cases
5. **Isolation**: Each service's mock data should be independent and not depend on other services

**Example Structure**:
```swift
class MockUserProfileService: UserProfileServiceProtocol {
    // Success scenario mock data
    private let successMockData: UserProfileResponse = UserProfileResponse(
        userId: "mock-user-123",
        firstName: "Mohamed",
        lastName: "Elsaeed",
        email: "mohamed.elsaeed@example.com",
        isSuccess: true,
        message: "Profile updated successfully"
    )
    
    // Error scenario mock data
    private let errorMockData: UserProfileResponse = UserProfileResponse(
        userId: nil,
        firstName: nil,
        lastName: nil,
        email: nil,
        isSuccess: false,
        message: "Validation failed"
    )
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        // Return appropriate mock data based on test scenario
        return successMockData
    }
}
```

### Service Responsibilities

1. **API Communication**: Make network requests
2. **Endpoint Management**: Define API endpoints
3. **Parameter Mapping**: Transform models to API parameters
4. **Response Parsing**: Parse API responses to models
5. **Data Transformation**: Convert models to/from API format
6. **Error Handling**: Parse and throw structured errors
7. **Request Building**: Construct API requests with proper headers
8. **No Business Logic**: Services should not contain business rules or validation
9. **No Service-to-Service Communication**: Services cannot call other services directly - only Repository can coordinate between services
10. **Mock Data for Testing**: Each service must provide its own mock data implementation for testing purposes

### Service Layer Anti-Patterns

#### ❌ Anti-Pattern 1: Service with Business Logic

**What NOT to do**:
```swift
class UserProfileService: UserProfileServiceProtocol {
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        // ❌ WRONG: Business logic in Service
        if data.age < 18 {
            throw BusinessError.minimumAgeRequired
        }
        
        if data.email.contains("@company.com") {
            // Complex business rules
            processCompanyEmail(data)
        }
        
        // API call
        return try await apiManager.request(...)
    }
}
```

**Why it's problematic**:
- Services should only handle API communication
- Business logic belongs in Repository
- Makes services difficult to test
- Violates single responsibility

**Correct approach**: Service handles API details only, Repository contains business logic

#### ❌ Anti-Pattern 2: Service Without Protocol

**What NOT to do**:
```swift
// ❌ WRONG: Service without protocol
class UserProfileService {
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        // Implementation
    }
}

// Repository directly depends on concrete class
class UserProfileRepo {
    private let service = UserProfileService() // ❌ Hard to test
}
```

**Why it's problematic**:
- Cannot mock for testing
- Tight coupling to implementation
- Difficult to swap implementations

**Correct approach**: Always use protocols for services

#### ❌ Anti-Pattern 3: Service Calling Other Services

**What NOT to do**:
```swift
class UserProfileService: UserProfileServiceProtocol {
    private let authService = AuthenticationService() // ❌ Service calling service
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        // ❌ WRONG: Service calling another service
        let authStatus = try await authService.checkAuthStatus()
        guard authStatus.isValid else {
            throw BusinessError.authenticationRequired
        }
        // API call
    }
}
```

**Why it's problematic**:
- Creates tight coupling
- Services should be isolated
- Repository should coordinate

**Correct approach**: Repository coordinates multiple services

#### ❌ Anti-Pattern 4: Service Without Mock Implementation

**What NOT to do**:
```swift
protocol UserProfileServiceProtocol {
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse
}

class UserProfileService: UserProfileServiceProtocol {
    // Production implementation
}

// ❌ WRONG: No mock implementation for testing
// Tests must use real API or cannot test properly
```

**Why it's problematic**:
- Tests depend on network
- Slow and unreliable tests
- Cannot test error scenarios easily

**Correct approach**: Always provide mock implementation for testing

### Performance Implications

**Network Optimization**:
- Services handle API-specific details, allowing optimization per endpoint
- Request/response transformation adds minimal overhead
- Consider request batching for multiple related calls

**Request Batching Example**:
```swift
class UserProfileService {
    func getMultipleProfiles(ids: [String]) async throws -> [UserProfile] {
        // Batch multiple requests
        return try await withThrowingTaskGroup(of: UserProfile.self) { group in
            for id in ids {
                group.addTask {
                    try await self.getUserProfile(id: id)
                }
            }
            
            var profiles: [UserProfile] = []
            for try await profile in group {
                profiles.append(profile)
            }
            return profiles
        }
    }
}
```

**Response Caching**:
- Services can implement response caching
- Reduces network calls for frequently accessed data
- Balance between freshness and performance

---

## APIManager Actor Pattern

### Why Actor?

Swift's `actor` type provides:
- **Thread Safety**: Automatic synchronization
- **Concurrency Safety**: Prevents data races
- **Isolation**: Protected mutable state

### Implementation

```swift
actor APIManager {
    private let baseURL: String
    private static var authToken: String?
    private static var tokenExpiry: Date?
    
    // Thread-safe token management
    private func getValidToken() async throws -> String {
        if let token = APIManager.authToken,
           let expiry = APIManager.tokenExpiry,
           expiry > Date() {
            return token
        }
        return try await refreshToken()
    }
    
    // Generic request method
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        responseType: T.Type
    ) async throws -> T {
        let token = try await getValidToken()
        // Make request with token
    }
}
```

### Features

1. **Automatic JWT Management**: Refreshes tokens when expired
2. **Generic Requests**: Type-safe API calls
3. **Error Handling**: Structured error responses
4. **Environment Awareness**: Switches endpoints based on environment

### Usage

```swift
let apiManager = APIManager()
let response: MyResponse = try await apiManager.request(
    endpoint: "users/endpoint",
    method: .post,
    parameters: ["key": "value"],
    responseType: MyResponse.self
)
```

### APIManager Anti-Patterns

#### ❌ Anti-Pattern 1: Using Class Instead of Actor

**What NOT to do**:
```swift
// ❌ WRONG: Class instead of actor for thread safety
class APIManager {
    private var authToken: String? // ❌ Not thread-safe
    private var tokenExpiry: Date? // ❌ Data race potential
    
    func request(...) async throws -> T {
        // Multiple concurrent calls can cause data races
        if tokenExpiry < Date() {
            authToken = try await refreshToken() // ❌ Race condition
        }
    }
}
```

**Why it's problematic**:
- Data races in concurrent access
- Token management not thread-safe
- Potential crashes and unpredictable behavior

**Correct approach**: Use `actor` for thread-safe API management

#### ❌ Anti-Pattern 2: Direct URLSession Calls from Services

**What NOT to do**:
```swift
class UserProfileService {
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        // ❌ WRONG: Direct URLSession calls, bypassing APIManager
        let url = URL(string: "https://api.example.com/users/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(UserProfileResponse.self, from: data)
    }
}
```

**Why it's problematic**:
- No centralized token management
- No consistent error handling
- Duplicated network code
- Hard to test and maintain

**Correct approach**: All network calls go through APIManager

### Performance Implications

**Concurrency Benefits**:
- Actor isolation ensures thread-safe concurrent API calls
- Automatic serialization of mutable state access
- No need for manual locking or synchronization

**Isolation Costs**:
- Actor isolation adds small overhead for state access
- Benefits (thread safety) far outweigh minimal performance cost
- Modern Swift runtime optimizes actor access

**Token Management Performance**:
- Centralized token management prevents redundant refresh calls
- Token caching reduces authentication overhead
- Automatic refresh on expiry improves user experience

**Best Practices**:
```swift
actor APIManager {
    // ✅ Cache tokens to avoid redundant refreshes
    private static var authToken: String?
    private static var tokenExpiry: Date?
    
    // ✅ Batch token refresh requests
    private var refreshTask: Task<String, Error>?
    
    private func getValidToken() async throws -> String {
        // Reuse existing refresh task if in progress
        if let task = refreshTask {
            return try await task.value
        }
        
        // Create new refresh task
        refreshTask = Task {
            let token = try await refreshToken()
            refreshTask = nil
            return token
        }
        
        return try await refreshTask!.value
    }
}
```

---

## Singleton Pattern

### SessionManager

**Purpose**: Global state management

```swift
public final class SessionManager: ObservableObject {
    public static let shared = SessionManager()
    
    @Published var userInfo: DataModel
    @Published var navigationState: NavigationState
    
    private init() {} // Prevents external instantiation
}
```

**Usage**:
```swift
// Access singleton
let session = SessionManager.shared

// Update state
session.navigationState = .feature1
session.userInfo.userData = data
```

### FlowViewModel

**Purpose**: Flow progression tracking

```swift
class FlowViewModel: ObservableObject {
    static let shared = FlowViewModel()
    
    @Published var currentStep: FlowType
    @Published var isLoading: Bool
    
    private init() {}
}
```

### When to Use Singletons

✅ **Use for**:
- Global application state
- Shared resources (session, progress)
- Single source of truth

❌ **Avoid for**:
- Business logic
- Services (use dependency injection)
- Testable components

### Singleton Anti-Patterns

#### ❌ Anti-Pattern 1: Using Singleton for Services

**What NOT to do**:
```swift
// ❌ WRONG: Service as singleton
class UserProfileService {
    static let shared = UserProfileService()
    private init() {}
    
    func submitUserProfile(...) async throws { }
}

// Usage
UserProfileService.shared.submitUserProfile(...) // ❌ Hard to test
```

**Why it's problematic**:
- Cannot inject mock for testing
- Tight coupling
- Difficult to swap implementations

**Correct approach**: Use dependency injection with protocols

#### ❌ Anti-Pattern 2: Multiple Singleton Instances

**What NOT to do**:
```swift
class SessionManager: ObservableObject {
    static let shared = SessionManager()
    // ❌ WRONG: Also allows public init
    init() {} // Should be private
    
    // Multiple instances can be created
    let manager1 = SessionManager()
    let manager2 = SessionManager() // ❌ Different instances
}
```

**Why it's problematic**:
- Multiple instances break singleton pattern
- State inconsistency
- Confusion about which instance to use

**Correct approach**: Private init() to prevent multiple instances

#### ❌ Anti-Pattern 3: Singleton with Business Logic

**What NOT to do**:
```swift
class SessionManager {
    static let shared = SessionManager()
    
    // ❌ WRONG: Business logic in singleton
    func validateUser(_ user: User) -> Bool {
        if user.age < 18 {
            return false
        }
        // Complex validation logic
    }
    
    func processPayment(_ amount: Double) { // ❌ Wrong
        // Payment processing
    }
}
```

**Why it's problematic**:
- Singletons should only manage state
- Business logic should be in Repository
- Makes testing difficult

**Correct approach**: Singleton for state only, Repository for business logic

### Performance Implications

**Memory Implications**:
- Singletons persist for app lifetime (memory held until app termination)
- Keep singleton state minimal to reduce memory footprint
- Avoid storing large data structures in singletons

**Testing Challenges**:
- Singletons are harder to test (shared state between tests)
- Reset singleton state in test setup/teardown
- Consider dependency injection for testability

**Best Practices**:
```swift
class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    // ✅ Minimal state
    @Published var userInfo: DataModel
    @Published var navigationState: NavigationState
    
    // ❌ Avoid: Large cached data
    // private var largeCache: [String: LargeData] = [:]
    
    // ✅ Use weak references for observers
    private var observers: [WeakObserver] = []
}
```

---

## Observer Pattern (Combine)

### Published Properties

ViewModels use `@Published` for reactive updates:

```swift
class UserProfileViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var validationErrors: [Error] = []
    @Published var isSubmitted: Bool = false
}
```

### View Observation

Views observe ViewModels:

```swift
struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
        }
        // ...
    }
}
```

### Custom Publishers

Extensions provide custom publishers:

```swift
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // Keyboard height publisher
    }
}
```

---

## Error Handling Pattern

### Error Types

1. **Validation Errors**: Field-level validation
2. **API Errors**: Structured server responses
3. **System Errors**: Network and system failures

### Error Structure

```swift
// API Error Response
struct ResponseErrorHandler: Decodable, Error, LocalizedError {
    var errorMsg: String
    let errorCode: Int
    var statusCode: Int?
    
    var errorDescription: String? {
        return errorMsg
    }
}

// API Errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(String)
    case serverError(code: Int, message: String)
}
```

### Error Handling Flow

```
Service throws error
    ↓
Repository catches and re-throws
    ↓
ViewModel catches error
    ↓
Updates @Published errorMessage
    ↓
View displays error alert
```

### Example

```swift
// In ViewModel
do {
    let success = try await repo.submitUserProfile(model)
    // Handle success
} catch {
    await MainActor.run {
        self.errorMessage = error.localizedDescription
        self.showErrorAlert = true
    }
}
```

---

## State Management Pattern

### Centralized State

`SessionManager` holds all application state:

```swift
SessionManager.shared.userInfo = DataModel()
```

### State Updates

1. **Direct Updates**: ViewModels update `SessionManager` directly
2. **Reactive Updates**: Views observe `@Published` properties
3. **Thread Safety**: Main thread updates via `DispatchQueue.main.async`

### State Flow

```
User Input
    ↓
ViewModel processes
    ↓
Repository updates SessionManager
    ↓
All observing views update
```

---

## Dependency Injection Pattern

### Repository Injection

ViewModels receive repositories via initializer:

```swift
class UserProfileViewModel: ObservableObject {
    private let repo: UserProfileRepo
    
    init(repo: UserProfileRepo = UserProfileRepo()) {
        self.repo = repo
    }
}
```

### Service Injection

Repositories receive services via initializer:

```swift
class UserProfileRepo {
    private let service: UserProfileServiceProtocol
    
    init(service: UserProfileServiceProtocol? = nil) {
        self.service = service ?? UserProfileService()
    }
}
```

### Benefits

- **Testability**: Inject mock dependencies
- **Flexibility**: Swap implementations
- **Loose Coupling**: Dependencies are explicit

---

## Async/Await Pattern

### Modern Concurrency

All async operations use Swift's async/await:

```swift
@MainActor
func submit() async {
    isLoading = true
    do {
        let result = try await repo.submitUserProfile(model)
        // Handle result
    } catch {
        // Handle error
    }
    isLoading = false
}
```

### Main Actor Isolation

UI updates are isolated to main actor:

```swift
@MainActor
func updateUI() {
    // UI updates are thread-safe
}
```

### Task Management

Views create tasks for async operations:

```swift
Button("Submit") {
    Task {
        await viewModel.submit()
    }
}
```

---

## Feature Module Pattern

### Consistent Structure

Each feature follows the same structure:

```
FeatureName/
├── Model/          # Data models
├── View/           # SwiftUI views
├── ViewModel/      # View models
├── Repo/           # Repositories
└── Services/       # API services
```

### Benefits

1. **Consistency**: Easy to navigate
2. **Modularity**: Features are self-contained
3. **Scalability**: Easy to add new features
4. **Testability**: Clear boundaries

---

## Migration Examples

This section provides step-by-step guides for migrating from anti-patterns to correct patterns.

### Migration 1: View Calling Repository → View → ViewModel → Repository

**Before (Anti-Pattern)**:
```swift
struct UserProfileView: View {
    private let repo = UserProfileRepo() // ❌ Wrong
    
    var body: some View {
        Button("Submit") {
            Task {
                try await repo.submitUserProfile(data) // ❌ Direct call
            }
        }
    }
}
```

**Step 1: Create ViewModel**:
```swift
class UserProfileViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repo: UserProfileRepo
    
    init(repo: UserProfileRepo = UserProfileRepo()) {
        self.repo = repo
    }
    
    func submit(_ data: UserProfileModel) async {
        isLoading = true
        do {
            try await repo.submitUserProfile(data)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
```

**Step 2: Update View**:
```swift
struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel() // ✅ Use ViewModel
    
    var body: some View {
        Button("Submit") {
            Task {
                await viewModel.submit(data) // ✅ Call ViewModel
            }
        }
    }
}
```

**Testing During Migration**:
1. Write tests for new ViewModel
2. Test both old and new implementations in parallel
3. Gradually migrate features
4. Remove old code after verification

### Migration 2: Repository Direct API Calls → Repository → Service → APIManager

**Before (Anti-Pattern)**:
```swift
class UserProfileRepo {
    private let apiManager = APIManager() // ❌ Wrong
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> Bool {
        // ❌ Direct API call
        let response = try await apiManager.request(
            endpoint: "users/profile",
            method: .post,
            parameters: data.toDictionary(),
            responseType: UserProfileResponse.self
        )
        return response.isSuccess
    }
}
```

**Step 1: Create Service Protocol**:
```swift
protocol UserProfileServiceProtocol {
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse
}
```

**Step 2: Implement Service**:
```swift
class UserProfileService: UserProfileServiceProtocol {
    private let apiManager = APIManager()
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        let endpoint = "users/profile"
        let parameters: [String: Any] = [
            "firstName": data.firstName,
            "lastName": data.lastName
        ]
        
        return try await apiManager.request(
            endpoint: endpoint,
            method: .post,
            parameters: parameters,
            responseType: UserProfileResponse.self
        )
    }
}
```

**Step 3: Update Repository**:
```swift
class UserProfileRepo {
    private let service: UserProfileServiceProtocol // ✅ Use Service
    
    init(service: UserProfileServiceProtocol = UserProfileService()) {
        self.service = service
    }
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> Bool {
        // ✅ Business logic in Repository
        guard !data.firstName.isEmpty else {
            throw ValidationError.invalidFirstName
        }
        
        // ✅ Call Service
        let response = try await service.submitUserProfile(data)
        return response.isSuccess
    }
}
```

**Testing During Migration**:
1. Create mock service for testing
2. Test Repository with mock service
3. Test Service separately
4. Integration test with real service

### Migration 3: Service Without Protocol → Protocol-Based Service

**Before (Anti-Pattern)**:
```swift
class UserProfileService {
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        // Implementation
    }
}

class UserProfileRepo {
    private let service = UserProfileService() // ❌ Concrete dependency
}
```

**Step 1: Create Protocol**:
```swift
protocol UserProfileServiceProtocol {
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse
}
```

**Step 2: Make Service Conform**:
```swift
class UserProfileService: UserProfileServiceProtocol {
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        // Same implementation
    }
}
```

**Step 3: Update Repository**:
```swift
class UserProfileRepo {
    private let service: UserProfileServiceProtocol // ✅ Protocol
    
    init(service: UserProfileServiceProtocol = UserProfileService()) {
        self.service = service
    }
}
```

**Step 4: Create Mock for Testing**:
```swift
class MockUserProfileService: UserProfileServiceProtocol {
    var mockResponse: UserProfileResponse?
    var shouldFail = false
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        if shouldFail {
            throw APIError.networkError
        }
        return mockResponse ?? UserProfileResponse(isSuccess: true)
    }
}
```

### Migration 4: Class-Based APIManager → Actor-Based APIManager

**Before (Anti-Pattern)**:
```swift
class APIManager {
    private var authToken: String? // ❌ Not thread-safe
    
    func request(...) async throws -> T {
        if tokenExpiry < Date() {
            authToken = try await refreshToken() // ❌ Race condition
        }
    }
}
```

**Step 1: Convert to Actor**:
```swift
actor APIManager {
    private var authToken: String? // ✅ Thread-safe
    private var tokenExpiry: Date?
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        responseType: T.Type
    ) async throws -> T {
        let token = try await getValidToken() // ✅ Thread-safe
        // Make request
    }
    
    private func getValidToken() async throws -> String {
        if let token = authToken,
           let expiry = tokenExpiry,
           expiry > Date() {
            return token
        }
        return try await refreshToken()
    }
}
```

**Step 2: Update Service Calls**:
```swift
class UserProfileService {
    private let apiManager = APIManager() // ✅ Actor
    
    func submitUserProfile(_ data: UserProfileModel) async throws -> UserProfileResponse {
        // ✅ All calls are thread-safe
        return try await apiManager.request(
            endpoint: "users/profile",
            method: .post,
            parameters: data.toDictionary(),
            responseType: UserProfileResponse.self
        )
    }
}
```

**Testing During Migration**:
1. Test concurrent API calls
2. Verify thread safety
3. Test token refresh behavior
4. Performance testing

### Migration Best Practices

1. **Incremental Migration**: Migrate one feature at a time
2. **Parallel Implementation**: Keep old and new code running in parallel
3. **Comprehensive Testing**: Test each migration step
4. **Documentation**: Document migration decisions
5. **Code Review**: Review migrations carefully
6. **Rollback Plan**: Have a plan to rollback if needed

---

## Best Practices

### 1. Separation of Concerns
- Views: UI only
- ViewModels: UI state and coordination
- Repositories: Business logic
- Services: API communication

### 2. Protocol-Oriented Design
- Use protocols for services
- Enable testing and flexibility

### 3. Error Handling
- Structured error types
- User-friendly error messages
- Centralized error handling

### 4. State Management
- Single source of truth (`SessionManager`)
- Reactive updates via Combine
- Thread-safe updates

### 5. Async Operations
- Use async/await throughout
- Main actor isolation for UI
- Proper error handling

### 6. Testing
- Mock services via protocols
- Inject dependencies
- Test business logic in isolation

---

## Pattern Summary

| Pattern | Purpose | Location |
|---------|---------|----------|
| MVVM | UI architecture | ViewModels, Views |
| Repository | Data abstraction | Repo/ folders |
| Service | API communication | Services/ folders |
| Actor | Thread-safe API | APIManager |
| Singleton | Global state | SessionManager, FlowViewModel |
| Observer | Reactive updates | @Published properties |
| Dependency Injection | Testability | Initializers |
| Async/Await | Concurrency | All async methods |
