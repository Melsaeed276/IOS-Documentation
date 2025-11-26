# Code Review Guidelines

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

#### Layer Separation
- Clear separation between View, ViewModel, Repository, and Service layers
- No circular dependencies
- Proper dependency injection
- Protocol-oriented design for services

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

#### SwiftUI Best Practices
- Use `@StateObject` for view-owned ViewModels
- Use `@ObservedObject` for passed ViewModels
- Avoid unnecessary view updates
- Proper use of `@Published` properties
- Environment objects for shared state

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

### State Management

#### SessionManager Usage
- Global state should be managed through `SessionManager.shared`
- State updates should happen on the main thread
- Avoid direct state mutations from multiple places
- Use `@Published` properties for reactive updates

#### ViewModel State
- ViewModels should use `@Published` for observable state
- State should be immutable where possible
- Clear separation between UI state and business state

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

#### Service Layer
- Services should implement protocols for testability
- Each service must have mock data for testing
- Services should not contain business logic
- Proper error transformation

### Testing Coverage

- Unit tests for ViewModels and Repositories
- Integration tests for service layer
- UI tests for critical user flows
- Mock services should be used in tests
- Test coverage for error scenarios

### Code Quality

#### Naming Conventions
- Clear, descriptive names
- Follow Swift naming conventions
- Avoid abbreviations
- Use meaningful variable and function names

#### Code Organization
- Files organized according to feature structure
- Related code grouped together
- Clear file naming conventions
- Proper use of extensions

#### Documentation
- Complex logic should have comments
- Public APIs should be documented
- README updates for significant changes

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
        
        // API call...
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
    // No error handling
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

### 4. Thread Safety Issues

**Anti-Pattern**:
```swift
class ViewModel: ObservableObject {
    var isLoading = false // ❌ Not thread-safe
    
    func loadData() async {
        // Background thread
        isLoading = true // ❌ Data race
    }
}
```

**Correct Pattern**:
```swift
@MainActor
class ViewModel: ObservableObject {
    @Published var isLoading = false // ✅ Thread-safe with @MainActor
    
    func loadData() async {
        isLoading = true // ✅ Safe on main actor
    }
}
```

### 5. Hardcoded Values

**Anti-Pattern**:
```swift
let apiURL = "https://api.production.com" // ❌ Hardcoded
let timeout: TimeInterval = 30 // ❌ Magic number
```

**Correct Pattern**:
```swift
let apiURL = AppConfig.baseURL // ✅ From configuration
let timeout = AppConstants.networkTimeout // ✅ From constants
```

### 6. Missing Localization

**Anti-Pattern**:
```swift
Text("Welcome") // ❌ Hardcoded string
Text("Error occurred") // ❌ Hardcoded string
```

**Correct Pattern**:
```swift
Text("welcome.title".localized()) // ✅ Localized
Text("error.generic".localized()) // ✅ Localized
```

### 7. Improper State Management

**Anti-Pattern**:
```swift
class ViewModel: ObservableObject {
    var data: DataModel? // ❌ Not published
    
    func updateData() {
        data = newData // ❌ View won't update
    }
}
```

**Correct Pattern**:
```swift
class ViewModel: ObservableObject {
    @Published var data: DataModel? // ✅ Published
    
    func updateData() {
        data = newData // ✅ View will update
    }
}
```

### 8. Direct API Calls Bypassing APIManager

**Anti-Pattern**:
```swift
let url = URL(string: "https://api.example.com/endpoint")!
let task = URLSession.shared.dataTask(with: url) { ... } // ❌ Direct call
```

**Correct Pattern**:
```swift
let apiManager = APIManager()
let response = try await apiManager.request(...) // ✅ Using APIManager
```

### 9. Missing Mock Data in Services

**Anti-Pattern**:
```swift
class UserProfileService: UserProfileServiceProtocol {
    // ❌ No mock implementation for testing
}
```

**Correct Pattern**:
```swift
class UserProfileService: UserProfileServiceProtocol {
    // Production implementation
}

class MockUserProfileService: UserProfileServiceProtocol {
    // ✅ Mock implementation with mock data
    private let mockData = UserProfileResponse(...)
}
```

### 10. Business Logic in Services

**Anti-Pattern**:
```swift
class UserProfileService {
    func submitUserProfile(_ data: UserProfileModel) async throws {
        // ❌ Business logic in service
        if data.age < 18 {
            throw ValidationError.minimumAgeRequired
        }
        // API call...
    }
}
```

**Correct Pattern**:
```swift
// ✅ Business logic in Repository
class UserProfileRepo {
    func submitUserProfile(_ data: UserProfileModel) async throws {
        if data.age < 18 {
            throw ValidationError.minimumAgeRequired
        }
        return try await service.submitUserProfile(data)
    }
}
```

## Code Review Checklist

Use this checklist when reviewing code to ensure all aspects are covered:

### Architecture Compliance

- [ ] Views only call ViewModels, never Repositories or Services
- [ ] ViewModels only call Repositories, never Services directly
- [ ] Repositories coordinate services and handle business logic
- [ ] Services only handle API communication, no business logic
- [ ] No service-to-service communication (only through Repository)
- [ ] Proper layer separation maintained
- [ ] No circular dependencies
- [ ] Protocol-oriented design for services

### Code Quality

- [ ] Follows Swift naming conventions
- [ ] Clear, descriptive names for variables, functions, and types
- [ ] Code is well-organized and follows project structure
- [ ] No code duplication (DRY principle)
- [ ] Functions are focused and single-purpose
- [ ] Appropriate use of access control (private, internal, public)
- [ ] Code is readable and maintainable

### Concurrency and Thread Safety

- [ ] Uses async/await for asynchronous operations
- [ ] UI updates are on MainActor
- [ ] Shared state is thread-safe (actors, MainActor)
- [ ] No data races or race conditions
- [ ] Proper use of Task and TaskGroup where needed
- [ ] No blocking operations on main thread

### Error Handling

- [ ] All async functions handle errors appropriately
- [ ] Structured error types are used
- [ ] User-friendly error messages are provided
- [ ] Errors are logged for debugging
- [ ] Error handling covers all failure scenarios
- [ ] Network errors are handled gracefully

### State Management

- [ ] Global state uses SessionManager.shared
- [ ] ViewModels use @Published for observable state
- [ ] State updates happen on main thread
- [ ] No direct state mutations from multiple places
- [ ] State is properly initialized
- [ ] State cleanup is handled (if needed)

### API Integration

- [ ] All API calls use APIManager
- [ ] No direct URLSession calls
- [ ] JWT token management is handled automatically
- [ ] Environment-aware endpoints
- [ ] Proper request/response models
- [ ] Error responses are handled

### Security

- [ ] No sensitive data in code or logs
- [ ] API keys and secrets are in configuration, not hardcoded
- [ ] Secure storage used for tokens and sensitive data
- [ ] Input validation is performed
- [ ] No SQL injection or similar vulnerabilities
- [ ] Proper authentication checks

### Testing

- [ ] Unit tests for ViewModels
- [ ] Unit tests for Repositories
- [ ] Integration tests for Services
- [ ] Mock services are implemented
- [ ] Test coverage for error scenarios
- [ ] Tests are maintainable and readable
- [ ] UI tests for critical flows (if applicable)

### Localization

- [ ] All user-facing strings are localized
- [ ] No hardcoded strings in UI
- [ ] Localization keys follow naming conventions
- [ ] Pluralization is handled correctly (if needed)

### Performance

- [ ] No unnecessary view updates
- [ ] Efficient data structures and algorithms
- [ ] Images and assets are optimized
- [ ] No memory leaks
- [ ] Proper resource cleanup
- [ ] Lazy loading where appropriate

### Documentation

- [ ] Complex logic has comments explaining why
- [ ] Public APIs are documented
- [ ] README updated for significant changes
- [ ] Code is self-documenting where possible

### SwiftUI Specific

- [ ] Proper use of @StateObject vs @ObservedObject
- [ ] Views are optimized to prevent unnecessary rebuilds
- [ ] Environment objects used appropriately
- [ ] Navigation is handled correctly
- [ ] Accessibility considerations

## Review Process

### Before Reviewing

1. Understand the context and purpose of the change
2. Review related documentation (ARCHITECTURE.md, PATTERNS.md)
3. Check if tests are included
4. Review the PR description and linked issues

### During Review

1. Start with architecture compliance
2. Check for common anti-patterns
3. Review code quality and readability
4. Verify error handling
5. Check testing coverage
6. Review security considerations
7. Use the checklist above

### Review Comments

- **Be constructive**: Focus on improvement, not criticism
- **Be specific**: Point to exact lines and explain why
- **Suggest solutions**: Don't just point out problems
- **Ask questions**: If something is unclear, ask for clarification
- **Praise good work**: Acknowledge well-written code

### Review Template

Use this template when leaving PR review comments. Copy and paste, then fill in the details:

```markdown
## Code Review

### Architecture
- [ ] Follows MVVM + Repository pattern
- [ ] Views only call ViewModels (not Repositories/Services)
- [ ] ViewModels only call Repositories (not Services directly)
- [ ] Repositories coordinate services properly
- [ ] No service-to-service communication
- [ ] Proper layer separation maintained

### Code Quality
- [ ] Follows Swift naming conventions
- [ ] Code is readable and maintainable
- [ ] No code duplication
- [ ] Functions are focused and single-purpose
- [ ] Appropriate access control used

### Concurrency & Thread Safety
- [ ] Uses async/await appropriately
- [ ] UI updates on MainActor
- [ ] Thread-safe shared state
- [ ] No data races

### Error Handling
- [ ] All async functions handle errors
- [ ] User-friendly error messages
- [ ] Errors are logged appropriately

### State Management
- [ ] Uses SessionManager for global state
- [ ] ViewModels use @Published correctly
- [ ] State updates on main thread

### API Integration
- [ ] Uses APIManager (no direct URLSession)
- [ ] Proper request/response models
- [ ] Error responses handled

### Testing
- [ ] Unit tests included
- [ ] Tests are passing
- [ ] Mock services implemented

### Suggestions
- [Specific suggestions with line numbers and code examples]

### Questions
- [Questions about implementation decisions or unclear code]

### Overall
[Overall assessment and approval status]
```

### Examples of Review Comments

#### Good Review Comments

**Example 1: Constructive and Specific**
```markdown
**Good**: 
In `UserProfileView.swift` line 45, the View is calling `UserProfileRepo()` directly. 
According to our MVVM pattern, Views should only call ViewModels. 

Could you refactor this to call `viewModel.submit()` instead? This maintains proper 
layer separation and makes the code more testable.

**Why it's good**: 
- Points to specific file and line
- Explains the problem (architecture violation)
- Suggests a solution
- Explains the benefit
```

**Example 2: Solution-Oriented**
```markdown
**Good**:
The error handling in `UserProfileViewModel.swift` (lines 78-85) could be improved. 
Currently, it only logs the error. Consider showing a user-friendly message:

```swift
catch {
    await MainActor.run {
        self.errorMessage = "Unable to save profile. Please try again."
        self.showErrorAlert = true
    }
    logger.error("Profile save failed: \(error)")
}
```

This provides better UX while still logging for debugging.

**Why it's good**:
- Identifies the issue clearly
- Provides concrete code solution
- Explains the benefit (better UX)
- Maintains existing functionality (logging)
```

**Example 3: Question-Based**
```markdown
**Good**:
I noticed that `APIManager` is being instantiated directly in the Service 
(`UserProfileService.swift` line 12). 

Could you clarify if this should be injected as a dependency instead? This would 
make testing easier and follow dependency injection principles. If there's a reason 
for the current approach, I'd be happy to discuss.

**Why it's good**:
- Asks a question rather than making demands
- Suggests an alternative approach
- Acknowledges there might be a valid reason
- Opens discussion
```

**Example 4: Positive Feedback**
```markdown
**Good**:
Great work on the error handling in `UserProfileRepo.swift`! The structured error 
types and comprehensive error coverage (lines 45-78) make debugging much easier. 
The way you've separated validation errors from API errors is exactly what we need.

**Why it's good**:
- Acknowledges good work
- Specific about what's good
- Reinforces positive patterns
```

#### Bad Review Comments

**Example 1: Vague and Unhelpful**
```markdown
**Bad**: 
This doesn't look right.

**Why it's bad**:
- No specific location
- No explanation of the problem
- No suggestion for improvement
- Not actionable
```

**Example 2: Critical Without Solution**
```markdown
**Bad**: 
This is wrong. Views shouldn't call repositories.

**Why it's bad**:
- Too brief, lacks context
- Doesn't point to specific code
- Doesn't explain why it's wrong
- No suggestion for how to fix it
```

**Example 3: Demanding Without Explanation**
```markdown
**Bad**: 
Change this to use async/await.

**Why it's bad**:
- Doesn't specify what "this" refers to
- Doesn't explain why the change is needed
- Doesn't provide example or guidance
- Sounds demanding rather than collaborative
```

**Example 4: Nitpicking Without Value**
```markdown
**Bad**: 
You used `var` instead of `let` on line 23. Change it.

**Why it's bad**:
- Focuses on minor style issue
- Doesn't explain if there's a functional reason
- Could be handled by linter/formatter
- Doesn't add significant value
```

### Reviewing Large PRs

Large PRs (100+ files changed, 500+ lines of code) require a different review strategy to be effective and manageable.

#### When to Request PR Splitting

Consider requesting PR splitting when:
- **PR exceeds 1000 lines** of code changes
- **Multiple unrelated features** are combined
- **Refactoring and new features** are mixed
- **Review time exceeds 2-3 hours** for a single reviewer
- **Multiple architectural changes** are bundled together

**How to request splitting:**
```markdown
This PR is quite large (X files, Y lines). To ensure thorough review and maintain 
code quality, could we split this into smaller, focused PRs? 

Suggested split:
1. PR 1: [Feature A] - Core functionality
2. PR 2: [Feature B] - Additional features
3. PR 3: [Refactoring] - Code improvements

This will make reviews more manageable and reduce risk.
```

#### Strategies for Reviewing Large PRs

**1. Focus on Critical Paths First**
- Review entry points and initialization code
- Check architecture compliance in core components
- Verify error handling in critical flows
- Review security-sensitive code

**2. Use Incremental Review**
- Review in multiple sessions (don't try to review everything at once)
- Focus on one feature/module at a time
- Take breaks to maintain focus
- Document findings as you go

**3. Prioritize Architecture Compliance**
For large PRs, architecture violations have bigger impact:
- Verify layer separation is maintained
- Check that patterns are followed consistently
- Ensure no circular dependencies introduced
- Verify state management is correct

**4. Check for Consistency**
- Ensure naming conventions are consistent across new code
- Verify error handling patterns are uniform
- Check that similar features follow same structure
- Ensure testing approach is consistent

**5. Time Management Tips**
- **Set time limits**: Allocate 1-2 hours per review session
- **Use checklists**: Focus on checklist items systematically
- **Delegate**: If possible, have multiple reviewers focus on different areas
- **Communicate**: Let the author know if you need more time

**6. Review Checklist for Large PRs**

```markdown
## Large PR Review Checklist

### High Priority
- [ ] Architecture compliance (MVVM + Repository pattern)
- [ ] Critical path functionality works
- [ ] Error handling in key flows
- [ ] Security considerations
- [ ] Breaking changes identified

### Medium Priority
- [ ] Code quality and consistency
- [ ] Test coverage
- [ ] Performance implications
- [ ] Documentation updates

### Lower Priority (Can defer)
- [ ] Minor style issues
- [ ] Optimization opportunities
- [ ] Future refactoring suggestions
```

**7. Communication Strategy**

For large PRs, communicate clearly:
```markdown
I've started reviewing this PR. Given its size, I'm reviewing in sections:

✅ Reviewed: Core models and managers
🔄 In progress: Feature modules
⏳ Pending: Tests and documentation

I'll provide detailed feedback as I complete each section. Expect full review 
within [timeframe].
```

#### When Large PRs Are Acceptable

Large PRs may be acceptable when:
- **Single cohesive feature** that can't be logically split
- **Refactoring** that touches many files but is atomic
- **Migration** work that must be done together
- **Initial project setup** or boilerplate code

In these cases, ensure:
- PR description clearly explains why it's large
- Changes are well-organized and consistent
- Tests are comprehensive
- Documentation is updated

### Approval Criteria

Code should be approved when:
- ✅ All checklist items are satisfied
- ✅ Architecture patterns are followed
- ✅ No critical anti-patterns are present
- ✅ Tests are included and passing
- ✅ Code is readable and maintainable
- ✅ Security considerations are addressed

## Related Documentation

- [Architecture Guide](./ARCHITECTURE.md) - Project architecture overview
- [Design Patterns](./PATTERNS.md) - Architectural patterns and decisions
- [Testing Guide](./TESTING.md) - Testing strategies and best practices
- [API Integration](./API_INTEGRATION.md) - API integration patterns

---

**Remember**: Code reviews are a collaborative process. The goal is to improve code quality, share knowledge, and maintain consistency across the codebase.

