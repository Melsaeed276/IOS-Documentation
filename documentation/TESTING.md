# Testing Guide

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
│   │   ├── Navigation/
│   │   │   ├── NavigationStateTests.swift
│   │   │   └── NavigationCoordinatorTests.swift
│   │   ├── Models/
│   │   │   ├── AppModelTests.swift
│   │   │   └── ConfigurationModelTests.swift
│   │   ├── Managers/
│   │   │   ├── SessionManagerTests.swift
│   │   │   └── APIManagerTests.swift
│   │   ├── Features/
│   │   │   ├── Storage/
│   │   │   │   ├── KeychainManagerTests.swift
│   │   │   │   └── UserDefaultsManagerTests.swift
│   │   │   └── Security/
│   │   │       ├── EncryptionManagerTests.swift
│   │   │       └── BiometricManagerTests.swift
│   │   └── Constants/
│   │       └── AppConstantsTests.swift
│   ├── Features/
│   │   ├── FeatureA/
│   │   │   ├── ViewModel/
│   │   │   │   └── FeatureAViewModelTests.swift
│   │   │   ├── Repository/
│   │   │   │   └── FeatureARepositoryTests.swift
│   │   │   └── Service/
│   │   │       └── FeatureAServiceTests.swift
│   │   ├── FeatureB/
│   │   └── FeatureC/
│   └── Utils/
│       ├── Extension/
│       ├── Helpers/
│       │   ├── ValidatorsTests.swift
│       │   └── FormattersTests.swift
│       └── View/
│
├── IntegrationTests/            # Integration tests (XCTest)
│   ├── APIIntegrationTests.swift
│   ├── StorageIntegrationTests.swift
│   └── FeatureIntegrationTests.swift
│
├── Mocks/                       # Mock implementations
│   ├── MockAPIManager.swift
│   ├── MockSessionManager.swift
│   ├── MockUserService.swift
│   └── MockData/
│       ├── UserMockData.swift
│       └── ResponseMockData.swift
│
└── Helpers/                     # Test utilities
    ├── TestHelpers.swift
    ├── XCTestExtensions.swift
    └── AsyncTestHelpers.swift

ProjectNameUITests/              # UI tests (XCTest/XCUITest)
├── Core/
│   ├── NavigationUITests.swift
│   └── MainViewUITests.swift
├── Features/
│   ├── FeatureAUITests.swift
│   ├── FeatureBUITests.swift
│   └── FeatureCUITests.swift
└── Helpers/
    ├── UITestHelpers.swift
    └── ScreenModels.swift
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
    
    func testUserLoadingFailure() async throws {
        // Given
        mockRepository.shouldFail = true
        mockRepository.error = APIError.networkError
        
        // When
        await viewModel.loadUser()
        
        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.user)
    }
}
```

#### Async Testing

```swift
func testAsyncOperation() async throws {
    let result = try await someAsyncFunction()
    XCTAssertNotNil(result)
}

// Or using expectations for older async patterns
func testAsyncWithExpectation() {
    let expectation = expectation(description: "Async operation completes")
    
    someAsyncFunction { result in
        XCTAssertNotNil(result)
        expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
}
```

#### Parameterized Tests

```swift
func testValidation(input: String, expected: Bool) {
    let result = Validator.isValidEmail(input)
    XCTAssertEqual(result, expected, "Email validation failed for: \(input)")
}

func testValidationSuite() {
    testValidation(input: "test@example.com", expected: true)
    testValidation(input: "invalid-email", expected: false)
    testValidation(input: "", expected: false)
    testValidation(input: "test@", expected: false)
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
    
    @Test("User loading should fail with network error")
    func testUserLoadingFailure() async throws {
        // Given
        let mockRepository = MockUserRepository()
        mockRepository.shouldFail = true
        mockRepository.error = APIError.networkError
        let viewModel = UserViewModel(repository: mockRepository)
        
        // When
        await viewModel.loadUser()
        
        // Then
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.user == nil)
    }
}
```

#### Parameterized Tests (Swift Testing)

```swift
@Test(arguments: [
    ("test@example.com", true),
    ("invalid-email", false),
    ("", false),
    ("test@", false)
])
func testEmailValidation(email: String, expected: Bool) {
    let result = Validator.isValidEmail(email)
    #expect(result == expected)
}
```

#### Test Organization (Swift Testing)

```swift
@Suite("UserViewModel Tests")
struct UserViewModelTestSuite {
    @Test("Loading user")
    func testLoading() async throws {
        // Test implementation
    }
    
    @Test("Error handling")
    func testErrorHandling() async throws {
        // Test implementation
    }
    
    @Suite("Validation Tests")
    struct ValidationTests {
        @Test("Email validation")
        func testEmail() {
            // Test implementation
        }
        
        @Test("Password validation")
        func testPassword() {
            // Test implementation
        }
    }
}
```

## Integration Testing

### API Integration Tests

```swift
import XCTest
@testable import ProjectName

final class APIIntegrationTests: XCTestCase {
    var apiManager: APIManager!
    
    override func setUpWithError() throws {
        apiManager = APIManager()
    }
    
    func testAPIConnection() async throws {
        // Test actual API connection (use staging/test environment)
        let response: UserResponse = try await apiManager.request(
            endpoint: "users/test",
            method: .get,
            responseType: UserResponse.self
        )
        
        XCTAssertNotNil(response)
    }
    
    func testTokenRefresh() async throws {
        // Test token refresh flow
        // Expire current token
        // Make request that triggers refresh
        // Verify new token is used
    }
}
```

### Storage Integration Tests

```swift
final class StorageIntegrationTests: XCTestCase {
    var keychainManager: KeychainManager!
    
    override func setUpWithError() throws {
        keychainManager = KeychainManager()
        // Clear test data
        try? keychainManager.delete(key: "testKey")
    }
    
    override func tearDownWithError() throws {
        // Cleanup test data
        try? keychainManager.delete(key: "testKey")
    }
    
    func testKeychainStorage() throws {
        // Given
        let testData = "testValue"
        
        // When
        try keychainManager.save(value: testData, forKey: "testKey")
        let retrieved = try keychainManager.get(key: "testKey")
        
        // Then
        XCTAssertEqual(retrieved, testData)
    }
}
```

## UI Testing

### XCUITest Basics

```swift
import XCTest

final class LoginUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testLoginFlow() {
        // Navigate to login
        let emailTextField = app.textFields["emailTextField"]
        XCTAssertTrue(emailTextField.exists)
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        
        let passwordSecureTextField = app.secureTextFields["passwordTextField"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("password123")
        
        // Tap login button
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        // Verify navigation to home
        let homeView = app.otherElements["homeView"]
        XCTAssertTrue(homeView.waitForExistence(timeout: 5.0))
    }
    
    func testLoginValidation() {
        // Test empty fields
        let loginButton = app.buttons["loginButton"]
        loginButton.tap()
        
        // Verify error message appears
        let errorAlert = app.alerts["Error"]
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 2.0))
    }
}
```

### UI Test Helpers

```swift
extension XCUIElement {
    func waitForExistence(timeout: TimeInterval = 5.0) -> Bool {
        return self.waitForExistence(timeout: timeout)
    }
    
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}

// Usage
emailTextField.clearText()
emailTextField.typeText("new@example.com")
```

### Screen Models Pattern

```swift
struct LoginScreen {
    let app: XCUIApplication
    
    var emailTextField: XCUIElement {
        app.textFields["emailTextField"]
    }
    
    var passwordTextField: XCUIElement {
        app.secureTextFields["passwordTextField"]
    }
    
    var loginButton: XCUIElement {
        app.buttons["loginButton"]
    }
    
    func login(email: String, password: String) {
        emailTextField.tap()
        emailTextField.typeText(email)
        passwordTextField.tap()
        passwordTextField.typeText(password)
        loginButton.tap()
    }
}

// Usage in tests
func testLogin() {
    let screen = LoginScreen(app: app)
    screen.login(email: "test@example.com", password: "password")
    
    let homeView = app.otherElements["homeView"]
    XCTAssertTrue(homeView.waitForExistence(timeout: 5.0))
}
```

### Accessibility Identifiers

Always use accessibility identifiers for UI testing:

```swift
// In your SwiftUI view
struct LoginView: View {
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .accessibilityIdentifier("emailTextField")
            
            SecureField("Password", text: $password)
                .accessibilityIdentifier("passwordTextField")
            
            Button("Login") {
                // Login action
            }
            .accessibilityIdentifier("loginButton")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("loginView")
    }
}
```

## Performance Testing

### XCTest Performance Tests

```swift
func testPerformanceExample() {
    measure {
        // Code to measure
        let largeArray = Array(0..<1000000)
        let sorted = largeArray.sorted()
        _ = sorted.filter { $0 % 2 == 0 }
    }
}
```

### Performance Metrics

```swift
func testAPIPerformance() {
    measure(metrics: [
        XCTClockMetric(),
        XCTCPUMetric(),
        XCTMemoryMetric()
    ]) {
        // API call or operation to measure
        let expectation = expectation(description: "API call")
        
        Task {
            let _ = try await apiManager.request(...)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
```

### Baseline Performance

```swift
func testPerformanceWithBaseline() {
    measure(metrics: [XCTClockMetric()]) {
        // Operation to measure
        performExpensiveOperation()
    }
}
// After first run, set baseline in Xcode:
// Editor → Add Performance Test Baseline
```

### Performance Test Best Practices

```swift
func testLargeDataSetProcessing() {
    let largeDataSet = generateLargeDataSet(count: 10000)
    
    measure {
        processData(largeDataSet)
    }
}

func testConcurrentOperations() {
    measure {
        let group = DispatchGroup()
        for _ in 0..<100 {
            group.enter()
            performAsyncOperation {
                group.leave()
            }
        }
        group.wait()
    }
}
```

## Mocking Strategies

### Protocol-Based Mocking

```swift
// Protocol
protocol UserServiceProtocol {
    func getUser(id: String) async throws -> User
    func updateUser(_ user: User) async throws -> User
}

// Mock implementation
class MockUserService: UserServiceProtocol {
    var mockUser: User?
    var shouldFail = false
    var error: Error?
    
    func getUser(id: String) async throws -> User {
        if shouldFail {
            throw error ?? APIError.networkError
        }
        return mockUser ?? User(id: id, name: "Mock User")
    }
    
    func updateUser(_ user: User) async throws -> User {
        if shouldFail {
            throw error ?? APIError.networkError
        }
        return user
    }
}
```

### Mock Data

```swift
struct MockData {
    static let validUser = User(
        id: "1",
        name: "Test User",
        email: "test@example.com"
    )
    
    static let invalidUser = User(
        id: "",
        name: "",
        email: "invalid"
    )
    
    static let userResponse = UserResponse(
        errorCode: 0,
        errorMsg: "",
        user: validUser
    )
    
    static let errorResponse = UserResponse(
        errorCode: 1001,
        errorMsg: "User not found",
        user: nil
    )
}
```

### Mock APIManager

```swift
actor MockAPIManager: APIManagerProtocol {
    var mockResponses: [String: Any] = [:]
    var shouldFail = false
    var error: Error?
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        responseType: T.Type
    ) async throws -> T {
        if shouldFail {
            throw error ?? APIError.networkError
        }
        
        if let mockResponse = mockResponses[endpoint] as? T {
            return mockResponse
        }
        
        throw APIError.invalidResponse
    }
    
    func setMockResponse<T>(_ response: T, for endpoint: String) {
        mockResponses[endpoint] = response
    }
}
```

## Test Data Management

### Test Fixtures

```swift
struct TestFixtures {
    static func createUser(id: String = "1", name: String = "Test") -> User {
        User(id: id, name: name, email: "\(name.lowercased())@example.com")
    }
    
    static func createUserResponse(user: User? = nil) -> UserResponse {
        UserResponse(
            errorCode: 0,
            errorMsg: "",
            user: user ?? createUser()
        )
    }
    
    static func createErrorResponse(code: Int = 1001, message: String = "Error") -> UserResponse {
        UserResponse(
            errorCode: code,
            errorMsg: message,
            user: nil
        )
    }
}
```

### JSON Test Data

```swift
extension Bundle {
    func loadJSON<T: Decodable>(_ filename: String, as type: T.Type) throws -> T {
        guard let url = self.url(forResource: filename, withExtension: "json") else {
            throw TestError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// Usage
let userResponse: UserResponse = try Bundle.test.loadJSON("user_response", as: UserResponse.self)
```

## Test Helpers and Utilities

### Async Test Helpers

```swift
extension XCTestCase {
    func waitForAsync(
        timeout: TimeInterval = 5.0,
        file: StaticString = #file,
        line: UInt = #line,
        _ block: @escaping () async throws -> Void
    ) {
        let expectation = expectation(description: "Async operation")
        
        Task {
            do {
                try await block()
                expectation.fulfill()
            } catch {
                XCTFail("Async operation failed: \(error)", file: file, line: line)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: timeout)
    }
}

// Usage
waitForAsync {
    try await viewModel.loadUser()
    XCTAssertNotNil(viewModel.user)
}
```

### Combine Test Helpers

```swift
extension XCTestCase {
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 5.0,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let expectation = expectation(description: "Publisher")
        
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    result = .failure(error)
                }
                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )
        
        wait(for: [expectation], timeout: timeout)
        cancellable.cancel()
        
        return try result!.get()
    }
}
```

## Best Practices

### 1. Test Organization

- **Mirror source structure** in test directories
- **Group related tests** together
- **Use descriptive test names** that explain what is being tested
- **Follow AAA pattern**: Arrange, Act, Assert

```swift
func testUserLogin_WithValidCredentials_ShouldSucceed() {
    // Arrange
    let email = "test@example.com"
    let password = "password123"
    
    // Act
    viewModel.login(email: email, password: password)
    
    // Assert
    XCTAssertTrue(viewModel.isLoggedIn)
}
```

### 2. Test Independence

- Each test should be **independent** and **isolated**
- Tests should not depend on execution order
- Clean up after each test

```swift
override func setUpWithError() throws {
    // Fresh state for each test
    viewModel = UserViewModel()
    mockService = MockUserService()
}

override func tearDownWithError() throws {
    // Cleanup
    viewModel = nil
    mockService = nil
}
```

### 3. Mock External Dependencies

- **Mock network calls** (use mock services)
- **Mock storage** (use in-memory storage for tests)
- **Mock time-dependent code** (use testable time providers)

```swift
protocol TimeProvider {
    var now: Date { get }
}

class TestTimeProvider: TimeProvider {
    var now: Date = Date()
    func advance(by interval: TimeInterval) {
        now = now.addingTimeInterval(interval)
    }
}
```

### 4. Test Coverage

- Aim for **high test coverage** (80%+ for critical paths)
- Focus on **business logic** and **critical paths**
- Don't test implementation details
- Test **edge cases** and **error scenarios**

### 5. Fast Tests

- Keep tests **fast** (< 1 second per test)
- Use **mocks** instead of real network calls
- Use **in-memory storage** instead of real storage
- Run tests **frequently** during development

### 6. Clear Assertions

- Use **descriptive assertion messages**
- Test **one thing per test**
- Use **appropriate assertion methods**

```swift
// ✅ Good
XCTAssertEqual(result, expected, "User ID should match")

// ❌ Bad
XCTAssert(result == expected)
```

### 7. Test Data

- Use **realistic test data**
- Create **reusable test fixtures**
- Use **factory methods** for complex objects

### 8. Continuous Integration

- Run tests **automatically** on CI/CD
- Fail builds on **test failures**
- Generate **test coverage reports**
- Run tests on **multiple iOS versions**

## Test Execution

### Running Tests in Xcode

1. **Run all tests**: `Cmd + U`
2. **Run specific test**: Click diamond icon next to test
3. **Run test class**: Click diamond icon next to class
4. **Run with coverage**: `Cmd + U` → Enable code coverage

### Test Schemes

Create separate schemes for different test configurations:

- **Unit Tests Scheme**: Fast unit tests only
- **Integration Tests Scheme**: Slower integration tests
- **UI Tests Scheme**: UI tests only
- **All Tests Scheme**: Run all tests

### Command Line Testing

```bash
# Run all tests
xcodebuild test -scheme ProjectName -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test
xcodebuild test -scheme ProjectName -only-testing:ProjectNameTests/UserViewModelTests/testUserLoading

# Run with coverage
xcodebuild test -scheme ProjectName -enableCodeCoverage YES
```

## Testing ViewModels with Async Code

ViewModels often contain async operations that need thorough testing. This section covers testing async ViewModel methods using both XCTest and Swift Testing.

### Testing with XCTest

#### Basic Async Testing

```swift
import XCTest
@testable import ProjectName

final class UserProfileViewModelTests: XCTestCase {
    var viewModel: UserProfileViewModel!
    var mockRepository: MockUserProfileRepository!
    
    override func setUpWithError() throws {
        mockRepository = MockUserProfileRepository()
        viewModel = UserProfileViewModel(repository: mockRepository)
    }
    
    func testLoadUser_Success() async throws {
        // Given
        let expectedUser = User(id: "1", name: "Test User")
        mockRepository.mockUser = expectedUser
        
        // When
        await viewModel.loadUser()
        
        // Then
        XCTAssertEqual(viewModel.user?.id, "1")
        XCTAssertEqual(viewModel.user?.name, "Test User")
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadUser_Failure() async throws {
        // Given
        mockRepository.shouldFail = true
        mockRepository.error = APIError.networkError
        
        // When
        await viewModel.loadUser()
        
        // Then
        XCTAssertNil(viewModel.user)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
}
```

#### Testing @Published Property Updates

```swift
func testSubmit_UpdatesLoadingState() async throws {
    // Given
    let expectation = XCTestExpectation(description: "Loading state updates")
    expectation.expectedFulfillmentCount = 2 // isLoading true, then false
    
    var loadingStates: [Bool] = []
    let cancellable = viewModel.$isLoading
        .sink { isLoading in
            loadingStates.append(isLoading)
            expectation.fulfill()
        }
    
    // When
    await viewModel.submit()
    
    // Then
    await fulfillment(of: [expectation], timeout: 2.0)
    XCTAssertEqual(loadingStates, [false, true, false])
    cancellable.cancel()
}
```

#### Testing MainActor Isolation

```swift
func testUpdateUI_OnMainActor() async throws {
    // Given
    let viewModel = UserProfileViewModel()
    
    // When
    await viewModel.updateUI()
    
    // Then - Verify updates happen on main thread
    XCTAssertTrue(Thread.isMainThread)
    // Or use MainActor.assumeIsolated in Swift 5.9+
}
```

#### Testing Task Cancellation

```swift
func testLoadUser_Cancellation() async throws {
    // Given
    let viewModel = UserProfileViewModel()
    let task = Task {
        await viewModel.loadUser()
    }
    
    // When
    task.cancel()
    
    // Then
    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
    XCTAssertTrue(task.isCancelled)
}
```

#### Testing Error Handling in Async Context

```swift
func testSubmit_HandlesError() async throws {
    // Given
    mockRepository.shouldFail = true
    mockRepository.error = ValidationError.invalidEmail
    
    // When
    await viewModel.submit()
    
    // Then
    await MainActor.run {
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.showErrorAlert)
        XCTAssertFalse(viewModel.isLoading)
    }
}
```

### Testing with Swift Testing

#### Basic Async Testing

```swift
import Testing
@testable import ProjectName

struct UserProfileViewModelTests {
    @Test("User should load successfully with valid data")
    func testLoadUser_Success() async throws {
        // Given
        let mockRepository = MockUserProfileRepository()
        let expectedUser = User(id: "1", name: "Test User")
        mockRepository.mockUser = expectedUser
        let viewModel = UserProfileViewModel(repository: mockRepository)
        
        // When
        await viewModel.loadUser()
        
        // Then
        #expect(viewModel.user?.id == "1")
        #expect(viewModel.user?.name == "Test User")
        #expect(viewModel.isLoading == false)
    }
    
    @Test("User loading should fail with network error")
    func testLoadUser_Failure() async throws {
        // Given
        let mockRepository = MockUserProfileRepository()
        mockRepository.shouldFail = true
        mockRepository.error = APIError.networkError
        let viewModel = UserProfileViewModel(repository: mockRepository)
        
        // When
        await viewModel.loadUser()
        
        // Then
        #expect(viewModel.user == nil)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }
}
```

#### Testing Multiple Async Operations

```swift
@Test("Should handle multiple concurrent operations")
func testConcurrentOperations() async throws {
    let viewModel = UserProfileViewModel()
    
    // When - Multiple concurrent operations
    async let user1 = viewModel.loadUser(id: "1")
    async let user2 = viewModel.loadUser(id: "2")
    async let user3 = viewModel.loadUser(id: "3")
    
    let results = try await [user1, user2, user3]
    
    // Then
    #expect(results.count == 3)
    #expect(results.allSatisfy { $0 != nil })
}
```

#### Testing with Timeouts

```swift
@Test("Should timeout after specified duration", .timeout(.seconds(5)))
func testLoadUser_Timeout() async throws {
    let mockRepository = MockUserProfileRepository()
    mockRepository.delay = 10.0 // 10 seconds delay
    let viewModel = UserProfileViewModel(repository: mockRepository)
    
    // This test should fail if operation takes longer than 5 seconds
    await viewModel.loadUser()
}
```

### Best Practices for Testing Async ViewModels

1. **Use async/await**: Prefer async test methods over expectations when possible
2. **Test state transitions**: Verify `@Published` properties update correctly
3. **Test error scenarios**: Ensure errors are handled and displayed
4. **Test cancellation**: Verify tasks can be cancelled properly
5. **Test MainActor isolation**: Ensure UI updates happen on main thread
6. **Use mocks**: Mock repositories and services for fast, reliable tests
7. **Test loading states**: Verify loading indicators work correctly
8. **Test concurrent operations**: Ensure thread safety

## Snapshot Testing for SwiftUI Views

Snapshot testing captures the visual output of SwiftUI views and compares it against stored reference images. This helps detect visual regressions and ensures UI consistency.

### Setup

#### 1. Add Snapshot Testing Library

Using Swift Package Manager, add a snapshot testing library:

**Option 1: swift-snapshot-testing (Recommended)**
```swift
// Package.swift or Xcode Package Dependencies
.package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.12.0")
```

**Option 2: iOSSnapshotTestCase**
```swift
.package(url: "https://github.com/uber/ios-snapshot-test-case.git", from: "8.0.0")
```

#### 2. Configure Test Target

Add the snapshot testing library to your test target dependencies.

### Basic Snapshot Testing

#### XCTest Example

```swift
import XCTest
import SnapshotTesting
import SwiftUI
@testable import ProjectName

final class UserProfileViewSnapshotTests: XCTestCase {
    func testUserProfileView_DefaultState() {
        // Given
        let viewModel = UserProfileViewModel()
        viewModel.user = User(id: "1", name: "John Doe", email: "john@example.com")
        let view = UserProfileView(viewModel: viewModel)
        
        // When/Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func testUserProfileView_LoadingState() {
        // Given
        let viewModel = UserProfileViewModel()
        viewModel.isLoading = true
        let view = UserProfileView(viewModel: viewModel)
        
        // When/Then
        assertSnapshot(matching: view, as: .image)
    }
    
    func testUserProfileView_ErrorState() {
        // Given
        let viewModel = UserProfileViewModel()
        viewModel.errorMessage = "Failed to load user"
        let view = UserProfileView(viewModel: viewModel)
        
        // When/Then
        assertSnapshot(matching: view, as: .image)
    }
}
```

#### Swift Testing Example

```swift
import Testing
import SnapshotTesting
import SwiftUI
@testable import ProjectName

struct UserProfileViewSnapshotTests {
    @Test("User profile view default state")
    func testDefaultState() {
        let viewModel = UserProfileViewModel()
        viewModel.user = User(id: "1", name: "John Doe")
        let view = UserProfileView(viewModel: viewModel)
        
        assertSnapshot(of: view, as: .image)
    }
}
```

### Testing Different View States

```swift
func testUserProfileView_AllStates() {
    let states: [(String, UserProfileViewModel)] = [
        ("loading", createLoadingViewModel()),
        ("success", createSuccessViewModel()),
        ("error", createErrorViewModel()),
        ("empty", createEmptyViewModel())
    ]
    
    for (stateName, viewModel) in states {
        let view = UserProfileView(viewModel: viewModel)
        assertSnapshot(matching: view, as: .image, named: stateName)
    }
}
```

### Testing with Different Data

```swift
func testUserProfileView_WithDifferentUsers() {
    let users = [
        User(id: "1", name: "Short Name"),
        User(id: "2", name: "Very Long Name That Might Wrap"),
        User(id: "3", name: "Name with Special Characters: @#$%")
    ]
    
    for user in users {
        let viewModel = UserProfileViewModel()
        viewModel.user = user
        let view = UserProfileView(viewModel: viewModel)
        
        assertSnapshot(matching: view, as: .image, named: "user_\(user.id)")
    }
}
```

### Testing Different Device Sizes

```swift
func testUserProfileView_DifferentDevices() {
    let viewModel = UserProfileViewModel()
    viewModel.user = User(id: "1", name: "Test User")
    let view = UserProfileView(viewModel: viewModel)
    
    // iPhone SE
    assertSnapshot(matching: view, as: .image(on: .iPhoneSe))
    
    // iPhone 15 Pro
    assertSnapshot(matching: view, as: .image(on: .iPhone15Pro))
    
    // iPad
    assertSnapshot(matching: view, as: .image(on: .iPadPro))
}
```

### Testing Dark Mode

```swift
func testUserProfileView_DarkMode() {
    let viewModel = UserProfileViewModel()
    viewModel.user = User(id: "1", name: "Test User")
    let view = UserProfileView(viewModel: viewModel)
    
    // Light mode
    assertSnapshot(matching: view, as: .image(traits: .init(userInterfaceStyle: .light)))
    
    // Dark mode
    assertSnapshot(matching: view, as: .image(traits: .init(userInterfaceStyle: .dark)))
}
```

### Updating Snapshots

When UI changes are intentional, update snapshots:

**Command Line**:
```bash
# Set environment variable to record new snapshots
RECORD_SNAPSHOTS=1 xcodebuild test -scheme ProjectName -destination 'platform=iOS Simulator,name=iPhone 15'
```

**In Code**:
```swift
// Temporarily enable recording
isRecording = true
assertSnapshot(matching: view, as: .image)
isRecording = false
```

### Best Practices

1. **Test all view states**: Loading, success, error, empty
2. **Test with realistic data**: Use production-like data
3. **Test different devices**: iPhone SE, iPhone 15 Pro, iPad
4. **Test both themes**: Light and dark mode
5. **Keep snapshots in version control**: Commit reference images
6. **Review snapshot diffs**: Understand what changed visually
7. **Don't snapshot everything**: Focus on critical views
8. **Update snapshots intentionally**: Don't auto-update on failures

### Limitations

- **Dynamic content**: Dates, timestamps, random data
- **Animations**: Animated views may not snapshot correctly
- **Network images**: Use placeholder images in tests
- **Platform differences**: Some views may differ between iOS versions

### Handling Dynamic Content

```swift
func testUserProfileView_WithDynamicDate() {
    // Given - Use fixed date for snapshot
    let fixedDate = Date(timeIntervalSince1970: 1609459200) // Jan 1, 2021
    let viewModel = UserProfileViewModel()
    viewModel.lastUpdated = fixedDate
    let view = UserProfileView(viewModel: viewModel)
    
    // When/Then
    assertSnapshot(matching: view, as: .image)
}
```

## Code Coverage

### Enable Code Coverage

1. Edit Scheme → Test → Options
2. Enable "Code Coverage"
3. Run tests
4. View coverage in Report Navigator

### Test Coverage Goals Per Layer

Different layers of the architecture have different testing priorities and coverage goals:

#### View Layer (SwiftUI Views)
**Target Coverage**: 60-70%

**Rationale**: 
- Views are primarily declarative UI code
- Focus on testing user interactions and state binding
- Use UI tests for complex user flows
- Snapshot tests for visual regression

**What to Test**:
- User interactions (button taps, text input)
- View state updates based on ViewModel
- Navigation triggers
- Accessibility

**What NOT to Test**:
- Implementation details of SwiftUI
- Exact layout positioning (use snapshot tests)
- Internal view state management

#### ViewModel Layer
**Target Coverage**: 80-90%

**Rationale**:
- ViewModels contain UI state management and coordination logic
- Critical for ensuring UI updates correctly
- High coverage prevents UI bugs

**What to Test**:
- State updates (`@Published` properties)
- User action handling
- Error state management
- Loading states
- Async operations and Task handling
- MainActor isolation

**Example Priority**:
- ✅ High: State management, error handling, async operations
- ✅ Medium: Validation, formatting
- ⚠️ Low: Simple property assignments

#### Repository Layer
**Target Coverage**: 85-95%

**Rationale**:
- Contains business logic and rules
- Highest priority for testing
- Bugs here affect entire application

**What to Test**:
- Business rule validation
- Service coordination
- Data transformation
- Error handling and retry logic
- State updates to SessionManager
- Edge cases and boundary conditions

**Example Priority**:
- ✅ Critical: Business rules, validation, service coordination
- ✅ High: Error handling, data transformation
- ✅ Medium: Logging, analytics

#### Service Layer
**Target Coverage**: 70-80%

**Rationale**:
- Primarily API communication code
- Test API request/response handling
- Mock APIManager for testing

**What to Test**:
- Request building (endpoints, parameters)
- Response parsing and decoding
- Error handling
- Request/response transformation

**What NOT to Test**:
- APIManager internals (test separately)
- Network layer details

#### APIManager (Network Layer)
**Target Coverage**: 90%+

**Rationale**:
- Critical infrastructure component
- Thread safety is essential
- Token management must be reliable

**What to Test**:
- Token management and refresh
- Thread safety (concurrent requests)
- Error handling
- Request/response handling
- Environment switching

#### Utilities Layer
**Target Coverage**: 80-90%

**Rationale**:
- Reusable code used throughout app
- Bugs affect multiple features
- Pure functions are easy to test

**What to Test**:
- All helper functions
- Validators
- Formatters
- Extensions
- Edge cases

#### Overall Project Coverage
**Target**: 75-85%

**Strategy**:
- Focus on high-value areas (Repository, ViewModel)
- Don't sacrifice quality for coverage numbers
- Use coverage to identify untested code, not as a goal itself

### Coverage Monitoring

**Tools**:
- Xcode Code Coverage
- CI/CD coverage reports
- Coverage trend tracking

**Best Practices**:
- Review coverage reports regularly
- Focus on critical paths first
- Don't write tests just to increase coverage
- Use coverage to find gaps, not as a target

## Testing Checklist

### Before Writing Tests

- [ ] Understand what needs to be tested
- [ ] Identify dependencies to mock
- [ ] Plan test scenarios (happy path, edge cases, errors)
- [ ] Set up test structure

### While Writing Tests

- [ ] Write clear, descriptive test names
- [ ] Follow AAA pattern (Arrange, Act, Assert)
- [ ] Test one thing per test
- [ ] Use appropriate assertions
- [ ] Mock external dependencies
- [ ] Test error scenarios

### After Writing Tests

- [ ] Verify tests pass
- [ ] Check test coverage
- [ ] Review test readability
- [ ] Ensure tests are fast
- [ ] Document complex test scenarios

## Summary

### Key Takeaways

1. **Use XCTest for**: UI Testing, Performance Testing, Integration Testing
2. **Use Swift Testing for**: Unit Testing (iOS 18+), Modern Swift code
3. **Organize tests** to mirror source structure
4. **Mock external dependencies** for fast, reliable tests
5. **Test critical paths** and edge cases
6. **Keep tests fast** and independent
7. **Use descriptive names** and clear assertions
8. **Aim for high coverage** on business logic

### Test Types Summary

| Test Type | Framework | Purpose | Speed |
|-----------|-----------|---------|-------|
| Unit Tests | Swift Testing / XCTest | Test individual components | Fast |
| Integration Tests | XCTest | Test component interactions | Medium |
| UI Tests | XCUITest | Test user interactions | Slow |
| Performance Tests | XCTest | Measure performance | Medium |

This testing guide provides a comprehensive foundation for testing iOS applications with both traditional and modern approaches.


