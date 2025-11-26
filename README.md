# iOS Project Documentation Cookbook

Welcome to the iOS project documentation cookbook. This documentation provides a comprehensive template and guide for structuring, organizing, and documenting iOS projects following best practices and modern architectural patterns.

## Table of Contents

- [Getting Started](#getting-started)
- [Architecture Overview](#architecture-overview)
- [Documentation Index](#documentation-index)
- [Project Structure Template](#project-structure-template)
- [Key Concepts](#key-concepts)
- [Common Tasks](#common-tasks)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)
- [Documentation Maintenance](#documentation-maintenance)
- [Changelog](#changelog)

## Getting Started

New to this project structure? Start here:

1. **[Quick Start Guide](./documentation/QUICK_START.md)** - Set up a new iOS project from scratch
   - Project setup checklist
   - Step-by-step project creation
   - Essential files to create first
   - Common setup tasks

2. **[Architecture Guide](./documentation/ARCHITECTURE.md)** - Understand the project architecture
   - MVVM + Repository pattern
   - State management approach
   - Entry points and initialization

3. **[Folder Structure](./documentation/FOLDER_STRUCTURE.md)** - Learn the project organization
   - Complete directory structure
   - File naming conventions
   - Feature module organization

4. **[Patterns](./documentation/PATTERNS.md)** - Review design patterns and architectural decisions

5. **[Data Flow](./documentation/DATA_FLOW.md)** - Understand how data moves through the application

## Architecture Overview

The project follows a **MVVM (Model-View-ViewModel) + Repository** pattern with clear separation of concerns:

```mermaid
graph TB
    subgraph "Presentation Layer"
        V[View<br/>SwiftUI Views]
    end
    
    subgraph "View Model Layer"
        VM[ViewModel<br/>ObservableObject]
    end
    
    subgraph "Business Logic Layer"
        R[Repository<br/>Business Logic]
    end
    
    subgraph "Service Layer"
        S[Service<br/>API Communication]
    end
    
    subgraph "Network Layer"
        API[APIManager<br/>Actor-based Network]
    end
    
    subgraph "State Management"
        SM[SessionManager<br/>Singleton ObservableObject]
    end
    
    V -->|@ObservedObject| VM
    VM -->|uses| R
    R -->|uses| S
    S -->|uses| API
    R -->|updates| SM
    SM -->|@Published| VM
    VM -->|updates| V
    
    style V fill:#e1f5ff
    style VM fill:#fff4e1
    style R fill:#e8f5e9
    style S fill:#f3e5f5
    style API fill:#ffebee
    style SM fill:#fff9c4
```

**Key Components:**
- **View**: SwiftUI views that display UI and handle user interactions
- **ViewModel**: ObservableObject that manages view state and business logic coordination
- **Repository**: Business logic layer that coordinates between ViewModels and Services
- **Service**: API communication layer that handles network requests
- **APIManager**: Actor-based network layer for thread-safe API calls
- **SessionManager**: Singleton managing global application state

## Documentation Index

### 🚀 [QUICK_START.md](./documentation/QUICK_START.md)
Quick start guide for setting up a new iOS project:
- Project setup checklist
- Step-by-step new project creation
- Essential files to create first
- Common setup tasks

**Start here** if you're setting up a new project.

---

### 📐 [ARCHITECTURE.md](./documentation/ARCHITECTURE.md)
Complete overview of project architecture, including:
- Project purpose and overview
- Architecture patterns (MVVM + Repository)
- Entry points and initialization
- State management approach
- Environment configuration
- Feature module structure
- API architecture overview

> Not all projects can be in the same structure but mostly this is a good way to keeo everything organized well.

---

### 📁 [FOLDER_STRUCTURE.md](./documentation/FOLDER_STRUCTURE.md)
Detailed directory structure and organization:
- Complete folder tree
- Purpose of each directory
- Feature module organization
- File naming conventions
- Separation of concerns

**Use this** to navigate the codebase and understand file organization.

---

### 🧩 [COMPONENTS.md](./documentation/COMPONENTS.md)
Comprehensive component documentation:
- Core components and entry points
- Feature modules structure
- ViewModels and their responsibilities
- Utility components
- Component relationships

**Reference this** when working with specific components or features.

---

### 🎨 [PATTERNS.md](./documentation/PATTERNS.md)
Design patterns and architectural decisions:
- MVVM pattern implementation
- Repository pattern usage
- Service layer architecture
- API Manager actor pattern
- Singleton pattern usage
- Error handling patterns
- State management patterns

**Read this** to understand the design decisions and patterns used throughout the project.

---

### 🔄 [DATA_FLOW.md](./documentation/DATA_FLOW.md)
Complete data flow documentation:
- User journey flow
- Navigation state management
- Data flow patterns
- API communication flow
- State management flow
- Error flow
- Session management

**Follow this** to understand how data moves through the application.

---

### 🌐 [API_INTEGRATION.md](./documentation/API_INTEGRATION.md)
API integration and communication:
- API Manager actor implementation
- JWT token management
- API endpoints structure
- Service layer implementation
- Error handling
- Request/response models
- Session management

**Use this** when working with API integration or adding new endpoints.

---

### 🎨 [RESOURCES.md](./documentation/RESOURCES.md)
Resources, assets, and localization:
- Image assets organization
- Color system
- Localization support
- HTML/static resources
- Resource organization
- Best practices

**Reference this** when working with UI resources, colors, or localization.

---

### 🧪 [TESTING.md](./documentation/TESTING.md)
Comprehensive testing guide:
- XCTest and Swift Testing frameworks
- Unit testing strategies
- Integration testing
- UI testing with XCUITest
- Performance testing
- Mocking strategies
- Test data management
- Best practices and patterns

**Use this** when writing tests, setting up test infrastructure, or understanding testing patterns.

---

### ✅ [CODE_REVIEW.md](./documentation/CODE_REVIEW.md)
Code review guidelines and best practices:
- What to look for in reviews
- Architecture compliance checks
- Swift-specific best practices
- Common anti-patterns to avoid
- Comprehensive review checklist
- Review process and approval criteria

**Reference this** when reviewing code or preparing code for review.

---

### 📖 [GLOSSARY.md](./documentation/GLOSSARY.md)
Comprehensive glossary of terms, concepts, and patterns used throughout the documentation:
- Architecture patterns and concepts
- Component definitions
- State management terms
- API and networking terminology
- Common patterns and anti-patterns

**Reference this** when you encounter unfamiliar terms or need clarification on concepts.

---

### 📝 [CHANGELOG.md](./documentation/CHANGELOG.md)
Changelog tracking all notable changes to the documentation:
- Documentation updates
- Architecture changes
- Breaking changes
- Version history

**Check this** to see what has changed in recent versions and track documentation evolution.

---

## Project Structure Template

```
ProjectName/
├── AppStartService.swift          # Entry point (root for visibility)
├── MainView.swift                  # Root navigation (root for visibility)
│
├── Core/                           # Core application layer
│   ├── Navigation/                # Navigation handling
│   │   ├── NavigationState.swift
│   │   └── NavigationCoordinator.swift
│   ├── Models/                    # Core data models
│   │   ├── AppModel.swift         # Configuration & environment
│   │   └── DataModel.swift        # Central data model
│   ├── Managers/                  # Core managers
│   │   ├── SessionManager.swift   # State management
│   │   └── APIManager.swift       # API layer
│   ├── Features/                  # Core feature modules
│   │   ├── Storage/              # Storage feature
│   │   └── Security/              # Security feature
│   └── Constants/                 # App-wide constants
│       ├── AppConstants.swift
│       ├── APIConstants.swift
│       └── Configuration.swift
│
├── Features/                      # Feature-based modules
│   ├── FeatureA/                  # Feature module example
│   ├── FeatureB/                  # Feature module example
│   └── FeatureC/                  # Feature module example
│
├── Utils/                         # Shared utilities
│   ├── Extension/                 # Swift extensions
│   │   ├── Alert+Ext.swift
│   │   ├── Date+Ext.swift
│   │   ├── String+Localization.swift
│   │   └── [other extensions]
│   ├── Helpers/                   # Helper functions
│   │   ├── Validators.swift
│   │   ├── Formatters.swift
│   │   └── DateHelpers.swift
│   └── View/                      # Reusable views
│
└── Resources/                      # Assets & localization
    ├── Assets.xcassets/
    ├── Colors.xcassets/
    └── [language].lproj/
```

## Key Concepts

### State Management
- **SessionManager**: Singleton managing global application state
- **DataModel**: Central data structure for application data
- **ProgressViewModel**: Multi-step flow progression tracking

### Navigation
- **NavigationState**: Top-level navigation states enum
- **FlowType**: Flow step progression enum
- **MainView**: Navigation orchestrator

### Architecture
- **MVVM**: Model-View-ViewModel pattern
- **Repository**: Business logic layer
- **Service**: API communication layer
- **Actor**: Thread-safe API manager

## Common Tasks

### Adding a New Feature Module

1. Create feature directory in `Features/`
2. Follow structure: Model, View, ViewModel, Repo, Services
3. Add feature to navigation state enum if needed
4. Update main navigation switch statement
5. Add to progress tracking if part of multi-step flow

### Adding a New API Endpoint

1. Add endpoint to service protocol
2. Implement in service class
3. Use `APIManager.request()` method
4. Handle errors appropriately
5. Update repository if needed
6. Add request/response models

### Adding Localization

1. Add key to `Localizable.strings` files for all supported languages
2. Use `.localized()` extension in code
3. Test in all supported languages
4. Ensure proper pluralization if needed

### Customizing UI

1. Modify colors in `Colors.xcassets`
2. Update images in `Assets.xcassets`
3. Customize views in respective feature modules
4. Use semantic colors for consistency
5. Follow design system guidelines

## Best Practices

1. **Always use APIManager** for API calls - never make direct URLSession calls
2. **Update SessionManager** for global state changes
3. **Handle errors** with user-friendly messages
4. **Use main actor** for UI updates
5. **Follow MVVM pattern** consistently across features
6. **Localize all strings** for user-facing text
7. **Use semantic colors** for maintainability
8. **Keep features modular** and self-contained
9. **Write tests** for business logic and repositories
10. **Document complex logic** with inline comments
11. **Follow code review guidelines** - See [CODE_REVIEW.md](./documentation/CODE_REVIEW.md) for detailed guidelines

## Troubleshooting

### Common Issues

**Issue**: Application doesn't start properly
- **Solution**: Ensure session/initialization is completed before starting main flow

**Issue**: API calls fail
- **Solution**: Check environment configuration and network connectivity, verify token management

**Issue**: Navigation doesn't work
- **Solution**: Ensure navigation state is updated on main thread, check state management

**Issue**: Localization not working
- **Solution**: Check `.lproj` folder structure and key names, verify bundle configuration

**Issue**: State not updating
- **Solution**: Verify `@Published` properties are used, ensure updates happen on main thread

### Debugging Techniques

#### Xcode Debugger

**Breakpoints**:
- **Regular Breakpoints**: Click in the gutter to set breakpoints
- **Conditional Breakpoints**: Right-click breakpoint → Edit Breakpoint → Add condition
- **Symbolic Breakpoints**: Debug → Breakpoints → Create Symbolic Breakpoint
- **Exception Breakpoints**: Automatically break on exceptions (Debug → Breakpoints → Exception Breakpoint)

**LLDB Commands**:
```lldb
# Print variable values
po variableName
p variableName

# Print object description
po object

# Continue execution
continue
c

# Step over
next
n

# Step into
step
s

# Step out
finish

# Print backtrace
bt

# Print register values
register read

# Set variable value
expr variableName = newValue
```

**View Debugging**:
- **View Hierarchy**: Debug → View Debugging → Capture View Hierarchy
- **Visualize constraints and view frames
- **Identify layout issues

#### Print Debugging and Logging

**OSLog (Recommended)**:
```swift
import os.log

let logger = Logger(subsystem: "com.yourapp", category: "APIManager")

logger.info("API request started")
logger.error("API request failed: \(error.localizedDescription)")
logger.debug("Response data: \(data)")
```

**Print Statements**:
```swift
// Use print for development
print("Debug: \(variable)")

// Use debugPrint for detailed output
debugPrint(object)

// Use dump for structured output
dump(object)
```

**Logging Best Practices**:
- Use different log levels (info, debug, error)
- Include context in log messages
- Remove or disable debug logs in production
- Use conditional compilation for debug-only logs:
  ```swift
  #if DEBUG
  print("Debug information")
  #endif
  ```

#### Runtime Inspection

**Dynamic Member Lookup**:
- Use `po` in LLDB to inspect objects at runtime
- Access private properties and methods in debug builds
- Inspect view hierarchies and constraints

**Memory Graph Debugger**:
- Debug → Memory Graph Debugger
- Visualize object relationships
- Identify retain cycles
- Inspect memory usage patterns

### Performance Profiling

#### Instruments

**Time Profiler**:
- **Purpose**: Identify performance bottlenecks
- **Usage**: Product → Profile → Time Profiler
- **Features**:
  - CPU usage over time
  - Function call tree
  - Hot spots identification
  - Thread analysis

**Allocations**:
- **Purpose**: Track memory allocations
- **Usage**: Product → Profile → Allocations
- **Features**:
  - Memory allocation over time
  - Object lifetime tracking
  - Memory growth patterns
  - Identify memory-heavy operations

**Leaks**:
- **Purpose**: Detect memory leaks
- **Usage**: Product → Profile → Leaks
- **Features**:
  - Automatic leak detection
  - Object retention analysis
  - Leak timeline

**Energy Log**:
- **Purpose**: Monitor battery usage
- **Usage**: Product → Profile → Energy Log
- **Features**:
  - CPU usage tracking
  - Network activity
  - Location services usage
  - Background activity

#### Performance Metrics

**Frame Rate**:
- Monitor FPS in Xcode debugger
- Target: 60 FPS for smooth UI
- Use Instruments to identify frame drops

**Memory Usage**:
- Monitor in Xcode debug navigator
- Set memory warnings in simulator
- Track peak memory usage

**Network Performance**:
- Monitor network requests in Instruments
- Track request/response times
- Identify slow API calls

**Best Practices**:
- Profile on real devices, not just simulator
- Test with different data sizes
- Profile under various conditions
- Compare before/after optimizations

### Memory Leak Detection

#### Instruments Leaks Tool

**Using Leaks Instrument**:
1. Product → Profile → Leaks
2. Run your app and interact with it
3. Leaks will be highlighted in red
4. Click on leaks to see object details
5. Use call tree to find where objects are retained

**Interpreting Results**:
- Red bars indicate memory leaks
- Check object retention count
- Review call tree for retain cycles
- Look for objects that should be deallocated

#### Retain Cycle Detection

**Common Causes**:
- Strong reference cycles between objects
- Closures capturing `self` strongly
- Delegate patterns with strong references
- Notification observers not removed

**Detection Techniques**:
```swift
// Use weak references
weak var delegate: SomeDelegate?

// Use unowned for non-optional references
unowned let parent: ParentClass

// Use [weak self] in closures
someAsyncOperation { [weak self] in
    guard let self = self else { return }
    // Use self safely
}

// Use [unowned self] when self cannot be nil
someOperation { [unowned self] in
    // Use self (guaranteed to exist)
}
```

**Memory Graph Debugger**:
- Debug → Memory Graph Debugger
- Visualize object relationships
- Identify unexpected strong references
- Check for circular references

#### Best Practices

1. **Use weak/unowned** for delegate patterns
2. **Remove observers** in deinit
3. **Break retain cycles** in closures
4. **Test memory management** regularly
5. **Use Instruments** to verify fixes
6. **Monitor memory growth** over time
7. **Profile on devices**, not just simulator

### Network Debugging Tools

#### Charles Proxy

**Setup**:
1. Install Charles Proxy
2. Configure iOS device proxy settings
3. Install Charles SSL certificate on device
4. Enable SSL proxying for your API domain

**Features**:
- Intercept HTTP/HTTPS requests
- View request/response headers and bodies
- Modify requests/responses
- Throttle network speed
- Map local files to remote URLs

**Usage**:
- Monitor all network traffic
- Debug API requests and responses
- Test error scenarios
- Simulate slow network conditions

#### Proxyman

**Setup**:
1. Install Proxyman
2. Configure device proxy
3. Install SSL certificate
4. Enable SSL proxying

**Features**:
- Modern UI for network inspection
- Request/response editing
- Breakpoints for requests
- Network timeline visualization
- Export/import requests

#### Network Logging

**Custom Logging**:
```swift
// Add logging to APIManager
actor APIManager {
    func request(_ endpoint: String) async throws -> Data {
        #if DEBUG
        print("🌐 Request: \(endpoint)")
        print("📤 Headers: \(headers)")
        #endif
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        #if DEBUG
        print("📥 Response: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
        print("📦 Data: \(String(data: data, encoding: .utf8) ?? "")")
        #endif
        
        return data
    }
}
```

**URLSession Configuration**:
```swift
let config = URLSessionConfiguration.default
config.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

// Enable detailed logging
config.waitsForConnectivity = true
config.timeoutIntervalForRequest = 30
```

#### API Response Inspection

**Response Validation**:
- Check status codes
- Validate response structure
- Inspect response headers
- Verify data format

**Error Handling**:
- Log error details
- Check error response bodies
- Verify error codes
- Test error scenarios

**Best Practices**:
1. **Use proxy tools** for development
2. **Log network requests** in debug builds
3. **Validate responses** before parsing
4. **Test with different network conditions**
5. **Monitor API performance**
6. **Document API contracts**
7. **Use network debugging** to understand API behavior

## Additional Resources

- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)

## Documentation Maintenance

This documentation should be maintained alongside the project. When making significant changes:

1. Update relevant documentation files
2. Update this README if structure changes
3. Add examples for new features
4. Keep diagrams and flow charts current
5. Update code examples to reflect current implementation
6. **Update [CHANGELOG.md](./documentation/CHANGELOG.md)** with all notable changes, including documentation updates, architecture changes, and breaking changes

## Changelog

All notable changes to this documentation cookbook are documented in [CHANGELOG.md](./documentation/CHANGELOG.md).

The changelog tracks:
- **Documentation Updates**: Changes to documentation files, new guides, updated examples
- **Architecture Changes**: Changes to architectural patterns, new patterns introduced
- **Breaking Changes**: Changes requiring code modifications or migration
- **Version History**: Version numbers, release dates, major milestones

Check the changelog to see what has changed in recent versions and understand the evolution of the documentation.

---

**Template Version**: 1.0

**Note**: This is a template documentation structure. Replace placeholders with your project-specific information.
