# API Integration Cookbook

@Metadata {
    @DisplayName("API Integration")
    @PageKind(article)
}

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

The environment is configured from Xcode build settings. See <doc:Architecture> for detailed setup.

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

## Best Practices

### 1. Thread Safety and Concurrency

Use Swift Actor (iOS 15+) for thread-safe API operations:

```swift
actor APIManager {
    // Thread-safe by default
    private static var authToken: String?
    private static var tokenExpiry: Date?
}
```

### 2. Token Management

Store tokens in Keychain, not UserDefaults or in-memory only:

```swift
// ✅ Good: Use Keychain
KeychainManager.save(token: token, forKey: "authToken")

// ❌ Bad: UserDefaults or hardcoded
UserDefaults.standard.set(token, forKey: "token")
```

### 3. Error Handling

Define comprehensive error types and handle errors properly:

```swift
// ✅ Good: Handle errors properly
do {
    let response = try await apiManager.request(...)
    // Handle success
} catch let error as ResponseErrorHandler {
    // Handle API error
    self.errorMessage = error.errorMsg
} catch {
    // Handle unknown error
    self.errorMessage = "An unexpected error occurred"
}
```

### 10. Always Use APIManager

Never make direct URLSession calls. Always use `APIManager`:

```swift
// ✅ Good
let response = try await apiManager.request(...)

// ❌ Bad
URLSession.shared.dataTask(...)
```

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

For more information on data flow, see <doc:DataFlow>.
