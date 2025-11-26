# iOS Project Architecture Guide

## Overview

This guide describes a modern iOS application architecture built with SwiftUI that follows a modular, feature-based structure with clear separation of concerns.

### Purpose

This architecture template handles:
- User authentication and session management
- Multi-step flows and form collection
- API integration with authentication
- State management across features
- Navigation and flow control

## Architecture Pattern

The recommended architecture uses **MVVM (Model-View-ViewModel) + Repository** pattern:

```
┌─────────────┐
│    View     │  (SwiftUI Views)
└──────┬──────┘
       │ @ObservedObject
       ▼
┌─────────────┐
│  ViewModel  │  (ObservableObject)
└──────┬──────┘
       │ uses
       ▼
┌─────────────┐
│  Repository │  (Business Logic)
└──────┬──────┘
       │ uses
       ▼
┌─────────────┐
│   Service   │  (API Communication)
└──────┬──────┘
       │ uses
       ▼
┌─────────────┐
│ APIManager  │  (Network Layer)
└─────────────┘
```

## Component Relationships

The following diagram illustrates the complete component relationships and data flow throughout the application:

```mermaid
graph TB
    subgraph "Presentation Layer"
        V1[View 1<br/>SwiftUI]
        V2[View 2<br/>SwiftUI]
        V3[View N<br/>SwiftUI]
        MV[MainView<br/>Navigation Orchestrator]
    end
    
    subgraph "View Model Layer"
        VM1[ViewModel 1<br/>ObservableObject]
        VM2[ViewModel 2<br/>ObservableObject]
        VM3[ViewModel N<br/>ObservableObject]
        FVM[FlowViewModel<br/>Singleton]
    end
    
    subgraph "Business Logic Layer"
        R1[Repository 1<br/>Business Logic]
        R2[Repository 2<br/>Business Logic]
        R3[Repository N<br/>Business Logic]
    end
    
    subgraph "Service Layer"
        S1[Service 1<br/>API Communication]
        S2[Service 2<br/>API Communication]
        S3[Service N<br/>API Communication]
    end
    
    subgraph "Network Layer"
        API[APIManager<br/>Actor-based Network]
    end
    
    subgraph "Global State"
        SM[SessionManager<br/>Singleton ObservableObject]
        DM[DataModel<br/>Central Data Structure]
    end
    
    subgraph "Core Features"
        ST[Storage Feature<br/>Keychain/UserDefaults]
        SC[Security Feature<br/>Encryption/Biometric]
    end
    
    subgraph "Navigation"
        NS[NavigationState<br/>Enum]
        NC[NavigationCoordinator<br/>Flow Control]
    end
    
    %% View to ViewModel relationships
    V1 -->|@ObservedObject| VM1
    V2 -->|@ObservedObject| VM2
    V3 -->|@ObservedObject| VM3
    MV -->|observes| SM
    MV -->|switches based on| NS
    
    %% ViewModel to Repository relationships
    VM1 -->|uses| R1
    VM2 -->|uses| R2
    VM3 -->|uses| R3
    FVM -->|tracks| NS
    
    %% Repository to Service relationships
    R1 -->|uses| S1
    R1 -->|coordinates| S2
    R2 -->|uses| S2
    R3 -->|uses| S3
    
    %% Service to APIManager relationships
    S1 -->|uses| API
    S2 -->|uses| API
    S3 -->|uses| API
    
    %% Repository to SessionManager relationships
    R1 -->|updates| SM
    R2 -->|updates| SM
    R3 -->|updates| SM
    
    %% SessionManager relationships
    SM -->|contains| DM
    SM -->|publishes| NS
    SM -->|@Published| VM1
    SM -->|@Published| VM2
    SM -->|@Published| VM3
    
    %% Core Features relationships
    R1 -->|uses| ST
    R1 -->|uses| SC
    R2 -->|uses| ST
    
    %% Navigation relationships
    NC -->|manages| NS
    SM -->|updates| NS
    NS -->|controls| MV
    
    style V1 fill:#e1f5ff
    style V2 fill:#e1f5ff
    style V3 fill:#e1f5ff
    style MV fill:#e1f5ff
    style VM1 fill:#fff4e1
    style VM2 fill:#fff4e1
    style VM3 fill:#fff4e1
    style FVM fill:#fff4e1
    style R1 fill:#e8f5e9
    style R2 fill:#e8f5e9
    style R3 fill:#e8f5e9
    style S1 fill:#f3e5f5
    style S2 fill:#f3e5f5
    style S3 fill:#f3e5f5
    style API fill:#ffebee
    style SM fill:#fff9c4
    style DM fill:#fff9c4
    style ST fill:#e0f2f1
    style SC fill:#e0f2f1
    style NS fill:#fce4ec
    style NC fill:#fce4ec
```

### Key Relationships Explained

**View → ViewModel**:
- Views observe ViewModels via `@ObservedObject` or `@StateObject`
- Views are passive and only display data and handle user interactions
- Views never directly call Repositories or Services

**ViewModel → Repository**:
- ViewModels coordinate with Repositories for business logic
- ViewModels manage UI state and user interactions
- ViewModels update `@Published` properties to trigger view updates

**Repository → Service**:
- Repositories can use multiple Services for complex operations
- Repositories coordinate between Services (Services cannot communicate directly)
- Repositories contain business logic and validation

**Service → APIManager**:
- Services handle API-specific details (endpoints, parameters)
- Services transform models to/from API format
- All network calls go through the actor-based APIManager

**Repository → SessionManager**:
- Repositories update global state in SessionManager
- SessionManager holds the central DataModel
- SessionManager publishes state changes to observing ViewModels

**SessionManager → ViewModels**:
- SessionManager's `@Published` properties trigger updates in ViewModels
- ViewModels observe SessionManager for global state changes
- Navigation state changes propagate through SessionManager

**Core Features**:
- Storage and Security features are used by Repositories
- These features provide cross-cutting concerns
- Accessed through service abstractions

## Entry Points

### Primary Entry Point: AppStartService

The application is initialized through a start service, which provides methods for:

#### 1. UIKit Integration
Presents the main flow as a modal from a UIKit view controller.

```swift
AppStartService.startServices(
    from: viewController,
    onComplete: { result in
        // Handle completion
    }
)
```

#### 2. SwiftUI Integration
Returns a SwiftUI view for integration into SwiftUI apps.

```swift
let mainView = AppStartService.start { result in
    // Handle completion
}
```

### Session Initialization

Before starting the main flow, initialize a session:

```swift
AppStartService.startSession(
    endPointType: .test, // or .production
    completionHandler: { sessionResponse, error in
        // Handle session creation
    }
)
```

## State Management

### SessionManager (Singleton)

`SessionManager` is a singleton `ObservableObject` that manages the entire application state:

```swift
public final class SessionManager: ObservableObject {
    public static let shared = SessionManager()
    
    @Published var userInfo: DataModel
    @Published var navigationState: NavigationState
    public var sessionID: String?
}
```

**Key Responsibilities:**
- Stores application data (`DataModel`)
- Manages navigation state (`NavigationState`)
- Provides session ID for API calls
- Manages verification codes (in debug mode)

### Navigation States

The application uses a navigation state enum to control flow:

```swift
enum NavigationState {
    case splash     // Initial splash screen
    case feature1   // First feature
    case feature2   // Second feature
    case feature3   // Third feature
}
```

Navigation is handled by `MainView`, which observes `SessionManager.shared.navigationState` and displays the appropriate view.

## Main Components

### 1. MainView
Root SwiftUI view that orchestrates the entire flow:
- Observes `SessionManager.shared`
- Switches between views based on `navigationState`
- Handles transitions between screens

### 2. FlowMainView
Manages multi-step flow progression:
- Displays progress indicator
- Switches between flow steps based on `FlowViewModel.currentStep`
- Handles loading states

### 3. FlowViewModel
Singleton that tracks flow progression:
- Manages current step (`currentStep`)
- Handles loading states
- Controls dialog visibility
- Updates step status

## Environment Configuration

The application supports multiple environments:

```swift
public enum Environment {
    case production
    case testing
    case debug
}
```

### Setting Environment from Xcode Project Configuration

The environment can be configured from Xcode build settings, allowing different environments for Debug and Release builds.

#### 1. Add Build Configuration Variable

In Xcode:
1. Select your project in the Project Navigator
2. Select your target
3. Go to **Build Settings** tab
4. Search for "User-Defined" or click the **+** button to add a new setting
5. Add a new setting named `APP_ENVIRONMENT` (or `ENVIRONMENT`)
6. Set values for each configuration:
   - **Debug**: `debug`
   - **Release**: `production`
   - **Testing** (if you have a custom scheme): `testing`

#### 2. Add to Info.plist (Optional)

Alternatively, you can add the environment to `Info.plist`:

1. Open `Info.plist`
2. Add a new key: `AppEnvironment` (or `Environment`)
3. Set the value to `$(APP_ENVIRONMENT)` to reference the build setting

#### 3. Read from Build Configuration in Code

Update `AppModel` to read from build configuration:

```swift
public class AppModel {
    public static var environment: Environment {
        #if DEBUG
        // Read from Info.plist or build setting
        if let envString = Bundle.main.infoDictionary?["AppEnvironment"] as? String {
            return Environment.from(string: envString)
        }
        return .debug
        #else
        // Read from Info.plist or build setting
        if let envString = Bundle.main.infoDictionary?["AppEnvironment"] as? String {
            return Environment.from(string: envString)
        }
        return .production
        #endif
    }
}

extension Environment {
    static func from(string: String) -> Environment {
        switch string.lowercased() {
        case "production", "prod":
            return .production
        case "testing", "test":
            return .testing
        case "debug", "debugging":
            return .debug
        default:
            return .production
        }
    }
}
```

#### 4. Using Build Configuration Schemes

Create different schemes for different environments:

1. **Product** → **Scheme** → **Manage Schemes**
2. Duplicate your main scheme
3. Name it appropriately (e.g., "Debug", "Testing", "Production")
4. Edit each scheme's **Run** configuration:
   - Set **Build Configuration** to match the environment
   - Configure **Arguments** if needed

### Programmatic Setting (Alternative)

You can also set the environment programmatically:

```swift
AppModel.environment = .production
```

### Environment Effects

Environment affects:
- API endpoints
- Debug features
- Error messages
- Logging levels

## Data Model

### DataModel
Central data structure that holds all application information:

```swift
struct DataModel {
    var authenticationData: AuthenticationModel
    var userData: UserDataModel
    var flowData: FlowDataModel
    var completionFlags: CompletionFlags
}
```

This model is stored in `SessionManager.shared.userInfo` and persists throughout the flow.

## Feature Module Structure

Each feature follows a consistent structure:

```
FeatureName/
├── Model/          # Data models and DTOs
├── View/           # SwiftUI views
├── ViewModel/      # ObservableObject view models
├── Repo/           # Repository layer (business logic)
└── Services/       # API service layer
```

**Example: UserProfileFeature**
- `Model/UserProfileModel.swift` - Data structure
- `View/UserProfileView.swift` - UI
- `ViewModel/UserProfileViewModel.swift` - State management
- `Repo/UserProfileRepo.swift` - Business logic
- `Services/UserProfileService.swift` - API calls

## Core Features

### Storage Feature (`Core/Features/Storage/`)

Provides storage abstraction for:
- **KeychainManager**: Secure credential storage
- **UserDefaultsManager**: User preferences and settings
- **StorageService**: Unified storage interface

### Security Feature (`Core/Features/Security/`)

Handles security-related functionality:
- **EncryptionManager**: Data encryption/decryption
- **BiometricManager**: Biometric authentication
- **SecurityValidator**: Security validation rules

### Constants (`Core/Constants/`)

Centralized application constants:
- **AppConstants**: General app-wide constants
- **APIConstants**: API endpoints and configuration
- **Configuration**: App configuration and feature flags

## API Architecture

### APIManager (Actor)

The application uses Swift's `actor` type for thread-safe API management:

- **Automatic Token Management**: Refreshes tokens when expired
- **Generic Request Method**: Type-safe API calls
- **Error Handling**: Decodes and throws structured errors
- **Environment-aware**: Switches endpoints based on environment

### API Flow

```
ViewModel → Repository → Service → APIManager → API Endpoint
                ↓
         Update SessionManager
                ↓
         Notify ViewModel (via @Published)
```

## Error Handling

Errors are handled at multiple levels:

1. **Validation Errors**: Field-level validation in ViewModels
2. **API Errors**: Structured error responses from `APIManager`
3. **System Errors**: Fixed error messages via configuration

## Utilities

### Helpers (`Utils/Helpers/`)

Reusable utility functions:
- **Validators**: Input validation helpers
- **Formatters**: Data formatting utilities
- **DateHelpers**: Date manipulation functions
- **StringHelpers**: String utility functions

## Dependencies

- **SwiftUI**: UI framework
- **Combine**: Reactive programming
- **Foundation**: Core functionality

External dependencies:
- **Swift Package Manager (SPM)** - Recommended: Native Xcode integration, no additional tools required
- **CocoaPods** - Optional (not recommended): Requires additional setup and maintenance

Dependencies may include:
- Animation libraries (if needed)
- Networking libraries (if needed)
- Other third-party dependencies

## Thread Safety

- `APIManager` uses `actor` for thread-safe API calls
- UI updates are dispatched to `MainActor`
- `SessionManager` uses `@Published` for reactive updates

## When to Deviate from the Pattern

While the MVVM + Repository pattern is recommended for most iOS applications, there are legitimate scenarios where deviating from this architecture is acceptable or even necessary:

### Small Projects or Prototypes

**When**: Building proof-of-concept apps, demos, or very small applications (< 5 screens)

**Deviation**: 
- Skip Repository layer for simple CRUD operations
- Combine ViewModel and Service for straightforward features
- Use direct API calls from ViewModels for prototypes

**Example**:
```swift
// Acceptable for small projects
class SimpleViewModel: ObservableObject {
    private let apiManager = APIManager()
    
    func loadData() async {
        // Direct API call without Repository
        let data = try? await apiManager.request(...)
    }
}
```

**Trade-off**: Faster development, but harder to scale if project grows

### Legacy Code Integration

**When**: Integrating with existing UIKit/Objective-C codebases

**Deviation**:
- Use adapters/bridges between old and new architecture
- Maintain legacy patterns in legacy modules
- Gradually migrate to new architecture

**Example**:
```swift
// Adapter pattern for legacy integration
class LegacyAdapter {
    func bridgeToNewArchitecture() {
        // Convert legacy patterns to new architecture
    }
}
```

**Trade-off**: Maintains compatibility while allowing gradual migration

### Third-Party SDK Requirements

**When**: SDKs require specific initialization or lifecycle management

**Deviation**:
- Create wrapper services that follow SDK requirements
- Isolate SDK-specific code in dedicated modules
- Maintain architecture boundaries around SDK usage

**Example**:
```swift
// SDK wrapper that fits architecture
class ThirdPartySDKWrapper: ServiceProtocol {
    private let sdk = ThirdPartySDK()
    
    func initialize() {
        // SDK-specific initialization
        sdk.setup(required: configuration)
    }
}
```

**Trade-off**: SDK integration may require architectural compromises, but keep them isolated

### Performance-Critical Sections

**When**: Real-time processing, high-frequency updates, or memory-constrained scenarios

**Deviation**:
- Bypass layers for performance-critical paths
- Use direct data access for time-sensitive operations
- Optimize hot paths while maintaining architecture elsewhere

**Example**:
```swift
// Performance-critical path
func processRealTimeData() {
    // Direct processing without full architecture stack
    processDirectly(data)
}
```

**Trade-off**: Performance gains vs. architectural consistency

### Team Expertise Considerations

**When**: Team members are learning SwiftUI or modern Swift patterns

**Deviation**:
- Start with simpler patterns and evolve
- Use more familiar patterns initially
- Gradually introduce architectural patterns

**Trade-off**: Easier onboarding vs. long-term maintainability

### When NOT to Deviate

**Avoid deviating when**:
- Building production applications
- Working with teams larger than 2-3 developers
- Planning for long-term maintenance
- Need for comprehensive testing
- Multiple features sharing common logic

**Reason**: The architecture provides structure, testability, and maintainability that becomes critical as projects grow.

## Scalability Considerations

As your application grows, consider these scalability aspects of the architecture:

### Handling Large Codebases

**Feature Module Organization**:
- Keep features self-contained and independent
- Use clear boundaries between features
- Avoid cross-feature dependencies

**Code Organization**:
```
Features/
├── FeatureA/          # Independent feature
│   ├── Model/
│   ├── View/
│   ├── ViewModel/
│   ├── Repo/
│   └── Services/
├── FeatureB/          # Independent feature
└── FeatureC/          # Independent feature
```

**Best Practices**:
- One feature per module
- Clear public interfaces
- Minimal shared dependencies
- Feature-specific constants and utilities

### Team Size and Collaboration

**For Small Teams (1-3 developers)**:
- Shared understanding of architecture
- Direct communication for decisions
- Flexible implementation details

**For Medium Teams (4-8 developers)**:
- Document architectural decisions
- Code review for pattern compliance
- Feature ownership model
- Regular architecture discussions

**For Large Teams (9+ developers)**:
- Strict architectural guidelines
- Architecture review process
- Automated pattern checking (linters)
- Clear ownership boundaries
- Regular architecture sync meetings

**Collaboration Strategies**:
- Use feature branches aligned with feature modules
- Document architectural decisions in ADRs (Architecture Decision Records)
- Maintain coding standards and patterns documentation
- Regular code reviews focusing on architecture compliance

### Feature Module Growth

**Managing Growing Features**:
- Split large features into sub-features when they exceed ~10 files
- Extract shared logic into Core features
- Use composition over inheritance

**Example - Splitting a Large Feature**:
```
// Before: Single large feature
UserProfile/
├── Model/ (15 files)
├── View/ (20 files)
└── ViewModel/ (10 files)

// After: Split into sub-features
UserProfile/
├── ProfileInfo/
│   ├── Model/
│   ├── View/
│   └── ViewModel/
├── Settings/
│   ├── Model/
│   ├── View/
│   └── ViewModel/
└── Preferences/
    ├── Model/
    ├── View/
    └── ViewModel/
```

**Signs a Feature Needs Splitting**:
- Feature module exceeds 20-30 files
- Multiple developers working on same feature
- Feature has distinct sub-domains
- Testing becomes difficult due to size

### Performance Optimization Strategies

**Lazy Loading**:
- Load features on-demand
- Defer heavy initialization
- Use lazy properties for expensive operations

**Caching Strategies**:
- Repository-level caching for frequently accessed data
- Service-level response caching
- ViewModel state caching for navigation

**Memory Management**:
- Release ViewModels when views disappear
- Clear caches when memory pressure occurs
- Use weak references for observers

**Example - Repository Caching**:
```swift
class UserProfileRepo {
    private var cache: [String: UserProfile] = [:]
    private let cacheExpiry: TimeInterval = 300 // 5 minutes
    
    func getUserProfile(id: String) async throws -> UserProfile {
        // Check cache first
        if let cached = cache[id],
           cached.timestamp.addingTimeInterval(cacheExpiry) > Date() {
            return cached.profile
        }
        
        // Fetch from service
        let profile = try await service.getUserProfile(id: id)
        cache[id] = CachedProfile(profile: profile, timestamp: Date())
        return profile
    }
}
```

### Code Organization at Scale

**Layered Organization**:
- Clear separation between layers
- Consistent naming conventions
- Documented layer responsibilities

**Shared Code Management**:
- Core utilities in `Utils/`
- Common models in `Core/Models/`
- Shared services in `Core/Services/`
- Avoid feature-specific code in shared locations

**Dependency Management**:
- Minimize dependencies between features
- Use protocols for feature communication
- Event-driven communication for loose coupling

**Example - Feature Communication**:
```swift
// Protocol-based feature communication
protocol FeatureAProtocol {
    func handleAction() -> Result
}

// Feature B uses Feature A through protocol
class FeatureBViewModel {
    private let featureA: FeatureAProtocol
    
    func interactWithFeatureA() {
        let result = featureA.handleAction()
        // Handle result
    }
}
```

### Testing at Scale

**Test Organization**:
- Mirror source structure in test directories
- Feature-specific test suites
- Shared test utilities

**Test Performance**:
- Fast unit tests (< 1 second each)
- Parallel test execution
- Test isolation and independence

**Continuous Integration**:
- Run tests on every commit
- Test on multiple iOS versions
- Performance regression testing

## Best Practices

1. **State Management**: Always use `SessionManager.shared` for global state
2. **Navigation**: Update `navigationState` to navigate between screens
3. **API Calls**: Use Repository layer, never call Services directly from ViewModels
4. **Error Handling**: Display user-friendly messages via alerts
5. **Testing**: Use environment `.debug` for test data injection
6. **Modularity**: Keep features self-contained and independent
7. **Documentation**: Document complex business logic
