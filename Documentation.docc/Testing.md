# Testing Guide

@Metadata {
    @DisplayName("Testing")
    @PageKind(article)
}

## Overview

This guide covers comprehensive testing strategies for iOS projects, including unit testing, integration testing, UI testing, and performance testing using both XCTest and Swift Testing frameworks.

## Testing Frameworks

### XCTest (Traditional Framework)

**XCTest** is Apple's traditional testing framework, available since iOS 7:
- Mature and stable
- Full Xcode integration
- Supports unit, integration, UI, and performance tests
- Works with all iOS versions
- Requires subclassing `XCTestCase`

**Use XCTest for:**
- UI Testing (XCUITest)
- Performance testing
- Integration testing
- Legacy codebases
- Projects requiring iOS 12 or earlier support

### Swift Testing (Modern Framework)

**Swift Testing** is Apple's new testing framework introduced in iOS 18+:
- Modern Swift-first API
- No subclassing required
- Better type safety
- More expressive test organization
- Built-in parameterized testing
- Better async/await support

**Use Swift Testing for:**
- Unit testing (iOS 18+)
- Modern Swift codebases
- Type-safe test scenarios
- Parameterized tests
- Better test organization

### Using Both Frameworks Together

You can use both frameworks in the same project, each for its own purpose:

```swift
// XCTest for UI and Performance tests
import XCTest
import XCUITest

class LoginUITests: XCTestCase {
    func testLoginFlow() {
        // UI test implementation
    }
}

// Swift Testing for unit tests
import Testing

@Test("User authentication should succeed with valid credentials")
func testUserAuthentication() async throws {
    // Unit test implementation
}
```

**Recommended Approach:**
- **XCTest**: UI Testing, Performance Testing, Integration Testing
- **Swift Testing**: Unit Testing (iOS 18+), Modern Swift code

## Test Structure

### Directory Organization

```
ProjectNameTests/
├── UnitTests/                    # Unit tests (Swift Testing or XCTest)
│   ├── Core/
│   ├── Features/
│   └── Utils/
├── IntegrationTests/            # Integration tests (XCTest)
├── Mocks/                       # Mock implementations
└── Helpers/                     # Test utilities

ProjectNameUITests/              # UI tests (XCTest/XCUITest)
├── Core/
├── Features/
└── Helpers/
```

## Unit Testing

### XCTest Unit Tests

#### Basic Structure

```swift
import XCTest
@testable import ProjectName

final class UserViewModelTests: XCTestCase {
    var viewModel: UserViewModel!
    var mockRepository: MockUserRepository!
    
    override func setUpWithError() throws {
        // Setup before each test
        mockRepository = MockUserRepository()
        viewModel = UserViewModel(repository: mockRepository)
    }
    
    override func tearDownWithError() throws {
        // Cleanup after each test
        viewModel = nil
        mockRepository = nil
    }
    
    func testUserLoading() async throws {
        // Given
        let expectedUser = User(id: "1", name: "Test User")
        mockRepository.mockUser = expectedUser
        
        // When
        await viewModel.loadUser()
        
        // Then
        XCTAssertEqual(viewModel.user?.id, "1")
        XCTAssertEqual(viewModel.user?.name, "Test User")
    }
}
```

### Swift Testing Unit Tests

#### Basic Structure

```swift
import Testing
@testable import ProjectName

struct UserViewModelTests {
    @Test("User should load successfully with valid data")
    func testUserLoading() async throws {
        // Given
        let mockRepository = MockUserRepository()
        let expectedUser = User(id: "1", name: "Test User")
        mockRepository.mockUser = expectedUser
        let viewModel = UserViewModel(repository: mockRepository)
        
        // When
        await viewModel.loadUser()
        
        // Then
        #expect(viewModel.user?.id == "1")
        #expect(viewModel.user?.name == "Test User")
    }
}
```

## Integration Testing

Integration tests verify that multiple components work together correctly:

```swift
import XCTest
@testable import ProjectName

final class APIIntegrationTests: XCTestCase {
    func testUserProfileFlow() async throws {
        // Test complete flow: ViewModel → Repository → Service → APIManager
        let viewModel = UserProfileViewModel()
        await viewModel.loadUserProfile(userId: "123")
        
        XCTAssertNotNil(viewModel.userProfile)
    }
}
```

## UI Testing

UI tests verify user interactions and visual elements:

```swift
import XCTest
import XCUITest

final class LoginUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testLoginFlow() {
        // Navigate to login
        let emailField = app.textFields["email"]
        emailField.tap()
        emailField.typeText("test@example.com")
        
        let passwordField = app.secureTextFields["password"]
        passwordField.tap()
        passwordField.typeText("password123")
        
        app.buttons["Login"].tap()
        
        // Verify navigation
        XCTAssertTrue(app.otherElements["homeView"].waitForExistence(timeout: 5))
    }
}
```

## Mocking

### Mock Services

Create mock implementations for testing:

```swift
class MockUserService: UserServiceProtocol {
    var mockUser: User?
    var shouldFail = false
    var error: Error?
    
    func getUserProfile(userId: String) async throws -> UserResponse {
        if shouldFail {
            throw error ?? APIError.networkError
        }
        
        return UserResponse(
            errorCode: 0,
            errorMsg: "",
            user: mockUser
        )
    }
}
```

## Best Practices

1. **Test isolation** - Each test should be independent
2. **Use mocks** - Mock external dependencies
3. **Test error cases** - Test both success and failure scenarios
4. **Async testing** - Use async/await for modern async code
5. **Test coverage** - Aim for high coverage of business logic
6. **Fast tests** - Unit tests should run quickly
7. **Clear test names** - Use descriptive test names

For more information on code review, see <doc:CodeReview>.

