# API Integration Cookbook

## Overview

This cookbook describes how to implement a centralized API management system with automatic JWT token handling, environment-aware endpoints, and structured error handling.

## APIManager (Actor)

### Location
`ProjectName/Core/Managers/APIManager.swift`

### Type
Swift `actor` for thread-safe API operations

### Purpose
- Centralized API communication
- Automatic JWT token management
- Generic type-safe requests
- Environment-aware endpoints
- Error handling and decoding

### Key Features

#### 1. Automatic Token Management

```swift
actor APIManager {
    // Token storage - Consider using Keychain for production
    private static var authToken: String?
    private static var tokenExpiry: Date?
    
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

**Token Refresh Flow**:
1. Check if token exists and is valid
2. If expired or missing, call authentication endpoint
3. Store token and expiry time securely (use Keychain in production)
4. Use token in subsequent requests

**Security Best Practice**: For production apps, store tokens in Keychain instead of in-memory variables. See the [Token Management](#2-token-management) section in Best Practices for details.

#### 2. Generic Request Method

```swift
func request<T: Decodable>(
    endpoint: String,
    method: HTTPMethod = .get,
    parameters: [String: Any]? = nil,
    headers: [String: String]? = nil,
    responseType: T.Type
) async throws -> T
```

**Usage Example**:
```swift
let apiManager = APIManager()
let response: UserResponse = try await apiManager.request(
    endpoint: "users/profile",
    method: .post,
    parameters: [
        "userId": "123",
        "name": "Mohamed Elsaeed"
    ],
    responseType: UserResponse.self
)
```

#### 3. Environment Configuration

The environment is configured from Xcode build settings (see [Environment Configuration](#environment-configuration) in ARCHITECTURE.md for detailed setup).

```swift
private let baseURL: String {
    switch AppModel.environment {
    case .production:
        return "https://api.production.com/api"
    case .testing:
        return "https://api.staging.com/api"
    case .debug:
        return "https://api.debug.com/api"
    }
}
```

**Environments**:
- `.production` → Production API
- `.testing` → Test API
- `.debug` → Debug API (with test data injection)

**Note**: The environment is automatically set based on Xcode build configuration. See ARCHITECTURE.md for setup instructions.

#### 4. Automatic Authorization

All requests automatically include JWT token:

```swift
requestHeaders["Authorization"] = "Bearer \(token)"
```

### HTTP Methods

```swift
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
```

### Token Response Model

```swift
struct TokenResponse: Decodable {
    let token: String
    let expires_on: Int // Epoch seconds
}
```

## API Endpoints

### Base URLs

**Production**:
```
https://api.production.com/api
```

**Testing/Staging**:
```
https://api.staging.com/api
```

### Common Endpoint Patterns

#### Authentication

**Get Token**
- **Endpoint**: `/Auth/GetToken` (or similar)
- **Method**: `POST`
- **Body**: Credentials
- **Response**: `TokenResponse`

#### User Management

**Get User Profile**
- **Endpoint**: `/users/profile`
- **Method**: `GET`
- **Headers**: Authorization token
- **Response**: `UserResponse`

**Update User**
- **Endpoint**: `/users/update`
- **Method**: `POST`
- **Body**: User data model
- **Response**: Success response

## Service Layer Implementation

### Service Protocol Pattern

All services implement protocols for testability:

```swift
protocol UserServiceProtocol {
    func getUserProfile(userId: String) async throws -> UserResponse
    func updateUser(_ data: UserModel) async throws -> UserResponse
}
```

### Service Implementation

```swift
class UserService: UserServiceProtocol {
    private let apiManager = APIManager()
    
    func getUserProfile(userId: String) async throws -> UserResponse {
        let endpoint = "users/profile"
        let parameters: [String: Any] = [
            "userId": userId.trimmingCharacters(in: .whitespaces)
        ]
        
        let response: UserResponse = try await apiManager.request(
            endpoint: endpoint,
            method: .get,
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

## Error Handling

### Error Types

#### ResponseErrorHandler

Structured error response from API:

```swift
struct ResponseErrorHandler: Decodable, Error, LocalizedError {
    var errorMsg: String
    let errorCode: Int
    var statusCode: Int?
    
    var errorDescription: String? {
        return errorMsg
    }
}
```

#### APIError

System-level API errors:

```swift
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(String)
    case serverError(code: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid response from server."
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .serverError(let code, let message):
            return "Server Error (\(code)): \(message)"
        }
    }
}
```

### Error Handling Flow

```
API Request
    ↓
HTTP Error Response (non-2xx)
    ↓
APIManager decodes ResponseErrorHandler
    ↓
Throws ResponseErrorHandler
    ↓
Service re-throws
    ↓
Repository re-throws
    ↓
ViewModel catches
    ↓
Updates @Published errorMessage
    ↓
View displays error alert
```

### Error Response Format

API error responses follow this structure:

```json
{
    "errorMsg": "Error message text",
    "errorCode": 1001
}
```

## Request/Response Models

### Request Models

All request models conform to `Codable`:

```swift
struct UserUpdateRequest: Codable {
    var userId: String
    var name: String
    var email: String
}
```

### Response Models

Response models decode API responses:

```swift
struct UserResponse: Decodable {
    let errorCode: Int
    let errorMsg: String
    let user: UserData?
    let metadata: ResponseMetadata?
}
```

### Date Formatting

Dates are formatted as ISO8601 strings:

```swift
extension Date {
    func toISO8601String() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}
```

## Session Management

### Session Initialization

Sessions are created via start service:

```swift
AppStartService.startSession(
    endPointType: .test,
    completionHandler: { sessionResponse, error in
        if let session = sessionResponse {
            SessionManager.shared.sessionID = session.sessionId
        }
    }
)
```

### Device Request

```swift
struct CreateDeviceRequest {
    let deviceId: String        // UIDevice.current.identifierForVendor!.uuidString
    let macAddress: String
    let ipAddress: String       // Public IP address
    let deviceName: String      // UIDevice.modelName
    let channel: String
}
```

### Session Response

```swift
struct SessionResponse: Decodable {
    let sessionId: String
    // Other session data
}
```

## Best Practices

### 1. Thread Safety and Concurrency

#### Use Swift Actor (iOS 15+)
- **Use `actor` for thread-safe API operations** - Prevents data races and ensures isolation
- Your current implementation already uses this pattern

```swift
actor APIManager {
    // Thread-safe by default
    private static var authToken: String?
    private static var tokenExpiry: Date?
}
```

#### Alternative for Older iOS Versions
- Use serial `DispatchQueue` or lock-based approach
- Consider `@MainActor` for UI-related operations

### 2. Token Management

#### Secure Token Storage
- **Store tokens in Keychain**, not UserDefaults or in-memory only
- Never hardcode credentials in code
- Implement token revocation handling

```swift
// ✅ Good: Use Keychain
KeychainManager.save(token: token, forKey: "authToken")

// ❌ Bad: UserDefaults or hardcoded
UserDefaults.standard.set(token, forKey: "token")
let token = "hardcoded-token" // Never do this!
```

#### Automatic Token Refresh
- Check token expiry before each request
- Refresh automatically when expired
- Handle concurrent refresh requests (deduplicate refresh calls)

```swift
private func getValidToken() async throws -> String {
    // Check if token exists and is valid
    if let token = APIManager.authToken,
       let expiry = APIManager.tokenExpiry,
       expiry > Date() {
        return token
    }
    // Refresh if expired
    return try await refreshToken()
}
```

### 3. Error Handling

#### Structured Error Types
Define comprehensive error types:

```swift
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case tokenExpired
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .httpError(let code, let message):
            return "HTTP Error (\(code)): \(message)"
        case .tokenExpired:
            return "Session expired. Please login again."
        // ... other cases
        }
    }
}
```

#### Error Response Parsing
- Parse API error responses consistently
- Provide user-friendly error messages
- Log errors for debugging

```swift
// ✅ Good: Handle errors properly
do {
    let response = try await apiManager.request(...)
    // Handle success
} catch let error as ResponseErrorHandler {
    // Handle API error
    self.errorMessage = error.errorMsg
} catch let error as APIError {
    // Handle system error
    self.errorMessage = error.localizedDescription
} catch {
    // Handle unknown error
    self.errorMessage = "An unexpected error occurred"
}
```

### 4. Request/Response Handling

#### Generic Type-Safe Requests
- Use generics with `Decodable` for type safety
- Validate responses before decoding
- Handle empty responses gracefully

```swift
// ✅ Good: Type-safe generic request
func request<T: Decodable>(
    endpoint: String,
    method: HTTPMethod,
    parameters: [String: Any]?,
    responseType: T.Type
) async throws -> T {
    // Implementation
}

// Usage
let response: UserResponse = try await apiManager.request(
    endpoint: "users/profile",
    method: .get,
    parameters: nil,
    responseType: UserResponse.self
)
```

#### Request Configuration
- Set appropriate timeouts (30-60 seconds)
- Configure retry logic for transient failures
- Support request cancellation
- Add request/response logging in debug mode

```swift
let configuration = URLSessionConfiguration.default
configuration.timeoutIntervalForRequest = 30.0
configuration.timeoutIntervalForResource = 60.0
let session = URLSession(configuration: configuration)
```

### 5. Configuration and Environment

#### Environment-Aware Endpoints
- Support multiple environments (dev, staging, production)
- Use build configuration or Info.plist for environment settings
- Validate base URLs

```swift
private let baseURL: String {
    switch AppModel.environment {
    case .production:
        return "https://api.production.com/api"
    case .testing:
        return "https://api.staging.com/api"
    case .debug:
        return "https://api.debug.com/api"
    }
}
```

#### Configuration Management
- Centralize API configuration
- Use constants for endpoints
- Support feature flags for API versions

### 6. Security

#### Certificate Pinning
- Implement SSL pinning for production
- Handle certificate validation errors

```swift
// Certificate pinning example
func urlSession(
    _ session: URLSession,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
) {
    // Validate certificate
    // Implement pinning logic
}
```

#### Request Security
- Validate all inputs
- Sanitize user data before sending
- Use HTTPS only
- Implement request signing if required

```swift
// ✅ Good: Validate and sanitize input
let sanitizedUserId = userId.trimmingCharacters(in: .whitespaces)
guard !sanitizedUserId.isEmpty else {
    throw ValidationError.invalidInput
}
```

### 7. Performance

#### URLSession Configuration
- Use custom `URLSessionConfiguration` with appropriate settings
- Consider caching policies
- Implement request queuing for rate limiting

```swift
let configuration = URLSessionConfiguration.default
configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0)
```

#### Request Optimization
- Compress request bodies when appropriate
- Use appropriate HTTP methods (GET for reads, POST/PUT for writes)
- Implement pagination for large datasets

### 8. Testing

#### Mockability
- Use protocols for testability
- Provide mock implementations for unit tests
- Support dependency injection

```swift
protocol APIManagerProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]?,
        responseType: T.Type
    ) async throws -> T
}

actor APIManager: APIManagerProtocol {
    // Implementation
}

// Mock for testing
class MockAPIManager: APIManagerProtocol {
    func request<T: Decodable>(...) async throws -> T {
        // Return mock data
    }
}
```

#### Test Scenarios
- Test token refresh flow
- Test error handling
- Test network failures
- Test concurrent requests

### 9. Logging and Debugging

#### Request/Response Logging
- Log requests in debug mode (hide sensitive data in production)
- Log response times
- Log errors with context

```swift
#if DEBUG
private func logRequest(endpoint: String, method: HTTPMethod, parameters: [String: Any]?) {
    print("🌐 [API Request] \(method.rawValue) \(endpoint)")
    if let params = parameters {
        print("📦 Parameters: \(params)")
    }
}

private func logResponse(endpoint: String, duration: TimeInterval, success: Bool) {
    print("✅ [API Response] \(endpoint) - \(success ? "Success" : "Failed") - \(duration)s")
}
#endif
```

#### Debugging Tools
- Support network inspection tools
- Provide clear error messages
- Include request IDs for tracking

### 10. Always Use APIManager

Never make direct URLSession calls. Always use `APIManager`:

```swift
// ✅ Good
let response = try await apiManager.request(...)

// ❌ Bad
URLSession.shared.dataTask(...)
```

### 11. Validate Responses

Check error codes in responses:

```swift
if response.errorCode != 0 {
    throw ResponseErrorHandler(
        errorMsg: response.errorMsg,
        errorCode: response.errorCode
    )
}
```

### 12. Trim Input Strings

Always trim whitespace from user input:

```swift
"userId": data.userId.trimmingCharacters(in: .whitespaces)
```

### 13. Use Main Actor for UI Updates

Update UI on main thread:

```swift
DispatchQueue.main.async {
    SessionManager.shared.userInfo = data
}
```

### 14. Environment Configuration

The environment is configured from Xcode build settings. See [Environment Configuration](#environment-configuration) in ARCHITECTURE.md for detailed setup instructions.

For programmatic override (not recommended for production):

```swift
AppModel.environment = .production
```

### 15. Additional Recommendations

#### Request Interceptors
- Support request/response interceptors for logging, analytics, etc.
- Implement request modification hooks

#### Response Caching
- Implement appropriate caching strategies
- Respect cache headers from server
- Clear cache when needed

#### Network Reachability
- Check network availability before requests
- Handle offline scenarios gracefully
- Provide user feedback for network issues

```swift
import Network

let monitor = NWPathMonitor()
monitor.pathUpdateHandler = { path in
    if path.status == .satisfied {
        // Network available
    } else {
        // Network unavailable
    }
}
```

## Debugging

### JSON Debugging

APIManager can print request and response JSON in debug mode:

```swift
private func debugPrintJSON(data: Data) {
    if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
       let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
       let prettyString = String(data: prettyData, encoding: .utf8) {
        print("Response JSON:\n\(prettyString)")
    }
}
```

### Debug Mode

In `.debug` environment:
- Additional debug logging
- Test data can be pre-filled
- Verbose error messages

## API Integration Summary

### Key Components

1. **APIManager**: Centralized API communication
2. **Services**: Protocol-based API services
3. **Repositories**: Business logic coordination
4. **ViewModels**: UI state management

### Request Flow

```
ViewModel → Repository → Service → APIManager → API
```

### Response Flow

```
API → APIManager → Service → Repository → SessionManager → ViewModel → View
```

### Token Management

- Automatic token refresh
- Thread-safe token storage
- Environment-aware endpoints

### Error Handling

- Structured error responses
- User-friendly error messages
- Centralized error handling
