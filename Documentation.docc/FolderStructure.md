# Folder Structure Template

@Metadata {
    @DisplayName("Folder Structure")
    @PageKind(article)
}

## Root Directory Structure

```
ProjectName/
├── ProjectName/              # Main application source code
├── ProjectNameDemo/          # Demo/test application (optional)
├── ProjectNameTests/         # Unit tests
├── ProjectNameUITests/       # UI tests
├── ProjectName.xcodeproj/    # Xcode project
├── ProjectName.xcworkspace/  # Xcode workspace (if using CocoaPods - not recommended)
├── Package.resolved          # Swift Package Manager lock file (recommended)
├── Pods/                     # CocoaPods dependencies (optional, not recommended)
├── Podfile                   # CocoaPods configuration (optional, not recommended)
└── Podfile.lock              # CocoaPods dependency lock file (optional, not recommended)
```

## Main Application Structure

```
ProjectName/
├── AppStartService.swift     # Application entry point
├── MainView.swift            # Root navigation view
│
├── Core/                     # Core application layer
│   ├── Navigation/          # Navigation handling
│   │   ├── NavigationState.swift
│   │   └── NavigationCoordinator.swift
│   ├── Models/               # Core data models
│   │   ├── AppModel.swift    # Configuration & environment
│   │   └── DataModel.swift   # Central data model
│   ├── Managers/             # Core managers
│   │   ├── SessionManager.swift
│   │   └── APIManager.swift  # Network layer
│   ├── Features/             # Core feature modules
│   │   ├── Storage/          # Storage feature
│   │   └── Security/         # Security feature
│   └── Constants/            # App-wide constants
│       ├── AppConstants.swift
│       ├── APIConstants.swift
│       └── Configuration.swift
│
├── Features/                # Feature-based modules
│   ├── FeatureA/             # Feature module example
│   ├── FeatureB/             # Feature module example
│   └── FeatureC/             # Feature module example
│
├── Resources/                # Assets and resources
│   ├── Assets.xcassets/      # Image assets
│   ├── Colors.xcassets/      # Color definitions
│   ├── en.lproj/            # English localization
│   ├── [language].lproj/    # Other languages
│   ├── Image+Assets.swift   # Asset helper
│   └── [static files].html   # HTML/static resources
│
└── Utils/                    # Shared utilities
    ├── Extension/            # Swift extensions
    │   ├── Alert+Ext.swift
    │   ├── Date+Ext.swift
    │   ├── NSNotification.swift
    │   ├── Publisher+Ext.swift
    │   ├── String+Localization.swift
    │   └── UIViewController+Ext.swift
    ├── Helpers/              # Helper functions
    │   ├── Validators.swift
    │   ├── Formatters.swift
    │   ├── DateHelpers.swift
    │   └── StringHelpers.swift
    ├── ScreenSizer.swift     # Screen size utilities (if needed)
    ├── Contract/            # Contract/legal views (if needed)
    ├── Error/               # Error handling
    └── View/                # Reusable view components
```

## Features Directory

### Feature Module Structure

Each feature follows a consistent structure:

```
FeatureName/
├── Model/          # Data models, DTOs, enums
│   ├── FeatureModel.swift
│   ├── FeatureResponse.swift
│   └── FeatureError.swift
│
├── View/           # SwiftUI views
│   ├── FeatureView.swift
│   └── SubViews/  # Subviews (if needed)
│       └── FeatureSubView.swift
│
├── ViewModel/      # ObservableObject view models
│   └── FeatureViewModel.swift
│
├── Repo/           # Repository layer (business logic)
│   └── FeatureRepo.swift
│
└── Services/       # API service layer
    └── FeatureService.swift
```

## File Organization Patterns

### Feature Module Pattern

Each feature follows this consistent structure:

```
FeatureName/
├── Model/          # Data models, DTOs, enums
├── View/           # SwiftUI views and subviews
├── ViewModel/      # ObservableObject view models
├── Repo/           # Repository layer (business logic)
└── Services/       # API service implementations
    (or Service/ for singular)
```

### Naming Conventions

- **Models**: `*Model.swift`, `*Response.swift`, `*Error.swift`
- **Views**: `*View.swift`, `*FormView.swift`
- **ViewModels**: `*ViewModel.swift`
- **Repositories**: `*Repo.swift`
- **Services**: `*Service.swift`, `*Services.swift`
- **Protocols**: `*Protocol.swift` (implied by naming)

### Separation of Concerns

1. **Model Layer**: Pure data structures, validation logic
2. **View Layer**: SwiftUI views, UI components only
3. **ViewModel Layer**: UI state, user interactions, validation feedback
4. **Repository Layer**: Business logic, data coordination
5. **Service Layer**: API communication, external dependencies

## Dependencies

### Swift Package Manager (Recommended)
**Swift Package Manager (SPM)** is the recommended dependency manager:
- Native Xcode integration
- No additional tools or setup required
- Managed directly in Xcode project settings
- `Package.resolved` - Dependency lock file (automatically generated)
- Dependencies are resolved and managed by Xcode

**Setup**:
1. In Xcode: **File** → **Add Package Dependencies...**
2. Enter package URL or search for packages
3. Select version requirements
4. Xcode automatically manages dependencies

### CocoaPods (Optional, Not Recommended)
**CocoaPods** is optional and not recommended for new projects:
- Requires Ruby and CocoaPods gem installation
- Requires `pod install` command after dependency changes
- Creates workspace file that must be used instead of project file
- Additional maintenance overhead

**Note**: For new projects, prefer Swift Package Manager for better integration and maintenance.

## Best Practices

### 1. Feature-Based Organization
- Group related functionality together
- Keep features self-contained
- Minimize dependencies between features

### 2. Consistent Structure
- Follow the same structure across all features
- Use consistent naming conventions
- Maintain clear separation of concerns

### 3. Resource Organization
- Group assets logically
- Use semantic naming for colors
- Organize localization files by language

### 4. Utility Organization
- Keep utilities generic and reusable
- Group related utilities together
- Document complex utilities

### 5. Test Organization
- Mirror source structure in tests
- Group tests by feature
- Keep test files close to source files

## Summary

This folder structure template provides:

1. **Clear Organization**: Features are self-contained and easy to navigate
2. **Consistency**: Same structure across all features
3. **Scalability**: Easy to add new features following the pattern
4. **Maintainability**: Clear separation of concerns
5. **Testability**: Tests mirror source structure

Follow this template when creating new projects or features to maintain consistency and organization.

For more information on architecture patterns, see <doc:Architecture> and <doc:Patterns>.

