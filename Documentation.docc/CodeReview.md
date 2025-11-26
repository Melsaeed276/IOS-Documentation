# Code Review Guidelines

@Metadata {
    @DisplayName("Code Review")
    @PageKind(article)
}

## Overview

Code reviews are a critical part of maintaining code quality, ensuring architectural compliance, and sharing knowledge across the team. This guide outlines what to look for during code reviews, common anti-patterns to avoid, and provides a comprehensive checklist for reviewers.

## What to Look For in Reviews

### Architecture Compliance

#### MVVM + Repository Pattern
- **Views should only observe ViewModels**: Views must not directly call Repositories or Services
- **ViewModels coordinate with Repositories**: ViewModels are the only layer that should call Repositories
- **Repositories manage business logic**: Repositories coordinate between multiple services and handle business rules
- **Services handle API communication**: Services should only handle API calls, not business logic
- **No service-to-service communication**: Services cannot call other services directly - only Repository can coordinate

**Check for**:
```swift
// ✅ CORRECT: View calls ViewModel
struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    
    var body: some View {
        Button("Submit") {
            Task {
                await viewModel.submit()
            }
        }
    }
}

// ❌ WRONG: View calls Repository directly
struct UserProfileView: View {
    private let repo = UserProfileRepo() // ❌ Anti-pattern
    
    var body: some View {
        Button("Submit") {
            Task {
                try await repo.submitUserProfile(data) // ❌ Anti-pattern
            }
        }
    }
}
```

### Swift-Specific Best Practices

#### Concurrency and Thread Safety
- **Use async/await** for asynchronous operations instead of completion handlers
- **MainActor isolation** for UI updates
- **Actor pattern** for thread-safe shared state (e.g., APIManager)
- **Avoid data races** - ensure thread-safe access to shared state

**Check for**:
```swift
// ✅ CORRECT: MainActor for UI updates
@MainActor
func updateUI() {
    self.isLoading = false
}

// ✅ CORRECT: Actor for thread-safe API manager
actor APIManager {
    private var authToken: String?
    // Thread-safe by default
}

// ❌ WRONG: UI update without MainActor
func updateUI() {
    self.isLoading = false // ❌ Potential data race
}
```

#### Error Handling
- All async functions should handle errors appropriately
- Use structured error types (enums conforming to `Error`)
- Provide user-friendly error messages
- Log errors for debugging

**Check for**:
```swift
// ✅ CORRECT: Proper error handling
func submit() async {
    isLoading = true
    do {
        let result = try await repo.submitUserProfile(model)
        // Handle success
    } catch {
        await MainActor.run {
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }
    isLoading = false
}

// ❌ WRONG: Missing error handling
func submit() async {
    let result = try await repo.submitUserProfile(model) // ❌ Unhandled error
}
```

### API Integration Patterns

#### APIManager Usage
- All API calls must go through `APIManager`
- No direct `URLSession` calls
- Proper JWT token management
- Environment-aware endpoints

**Check for**:
```swift
// ✅ CORRECT: Using APIManager
let apiManager = APIManager()
let response = try await apiManager.request(
    endpoint: "users/profile",
    method: .post,
    parameters: params,
    responseType: UserProfileResponse.self
)

// ❌ WRONG: Direct URLSession call
let url = URL(string: "https://api.example.com/users/profile")!
let task = URLSession.shared.dataTask(with: url) { ... } // ❌ Anti-pattern
```

## Common Anti-Patterns to Avoid

### 1. View Calling Repository Directly

**Anti-Pattern**:
```swift
struct UserProfileView: View {
    private let repo = UserProfileRepo() // ❌ Wrong!
    
    var body: some View {
        Button("Submit") {
            Task {
                try await repo.submitUserProfile(data) // ❌ Wrong!
            }
        }
    }
}
```

**Correct Pattern**:
```swift
struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel() // ✅ Correct
    
    var body: some View {
        Button("Submit") {
            Task {
                await viewModel.submit() // ✅ Correct
            }
        }
    }
}
```

### 2. Services Calling Other Services

**Anti-Pattern**:
```swift
class UserProfileService {
    func submitUserProfile(_ data: UserProfileModel) async throws {
        // ❌ Wrong: Service calling another service
        let authService = AuthenticationService()
        let authStatus = try await authService.checkAuthStatus()
        // ...
    }
}
```

**Correct Pattern**:
```swift
// Repository coordinates services
class UserProfileRepo {
    func submitUserProfile(_ data: UserProfileModel) async throws {
        // ✅ Correct: Repository coordinates services
        let authStatus = try await authenticationService.checkAuthStatus()
        let response = try await userProfileService.submitUserProfile(data)
        // ...
    }
}
```

### 3. Missing Error Handling

**Anti-Pattern**:
```swift
func submit() async {
    let result = try await repo.submitUserProfile(model) // ❌ Unhandled error
}
```

**Correct Pattern**:
```swift
func submit() async {
    do {
        let result = try await repo.submitUserProfile(model)
        // Handle success
    } catch {
        // ✅ Handle error appropriately
        await MainActor.run {
            self.errorMessage = error.localizedDescription
        }
    }
}
```

## Review Checklist

### Architecture
- [ ] Views only call ViewModels
- [ ] ViewModels only call Repositories
- [ ] Repositories coordinate services
- [ ] Services don't call other services
- [ ] Clear layer separation

### Code Quality
- [ ] Proper error handling
- [ ] Thread safety (MainActor, actors)
- [ ] No hardcoded values
- [ ] Proper naming conventions
- [ ] Code organization follows structure

### Testing
- [ ] Unit tests for ViewModels and Repositories
- [ ] Mock services used in tests
- [ ] Error scenarios tested
- [ ] Test coverage adequate

For more information on patterns, see <doc:Patterns> and <doc:Testing>.

