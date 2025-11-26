# Folder Structure Template

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

### Example: UserProfile Feature

```
UserProfile/
├── Model/
│   ├── UserProfileModel.swift
│   ├── UserProfileResponse.swift
│   └── UserProfileError.swift
│
├── View/
│   ├── UserProfileView.swift
│   └── SubViews/
│       ├── ProfileHeaderView.swift
│       └── ProfileFormView.swift
│
├── ViewModel/
│   └── UserProfileViewModel.swift
│
├── Repo/
│   └── UserProfileRepo.swift
│
└── Services/
    └── UserProfileService.swift
```

### Example: Authentication Feature

```
Authentication/
├── Model/
│   ├── AuthenticationModel.swift
│   ├── AuthenticationResponse.swift
│   └── AuthenticationError.swift
│
├── View/
│   ├── AuthenticationView.swift
│   └── SubViews/
│       ├── LoginView.swift
│       └── SignUpView.swift
│
├── ViewModel/
│   └── AuthenticationViewModel.swift
│
├── Repo/
│   └── AuthenticationRepo.swift
│
└── Services/
    └── AuthenticationService.swift
```

### Example: Multi-Step Flow Feature

```
Flow/
├── MainView/
│   └── FlowMainView.swift    # Main flow container
│
├── Step1/
│   ├── Model/
│   ├── View/
│   ├── ViewModel/
│   ├── Repo/
│   └── Services/
│
├── Step2/
│   ├── Model/
│   ├── View/
│   ├── ViewModel/
│   ├── Repo/
│   └── Services/
│
├── ProgressBar/              # Progress tracking
│   ├── Model/
│   │   ├── Enum/
│   │   │   ├── FlowType.swift
│   │   │   └── StepStatus.swift
│   │   └── ProgressData.swift
│   ├── View/
│   │   └── ProgressIndicator.swift
│   └── ViewModel/
│       └── FlowViewModel.swift
│
└── Completion/
    └── View/
        └── CompletionView.swift
```

## Utils Directory

```
Utils/
├── Extension/                # Swift extensions
│   ├── Alert+Ext.swift
│   ├── Date+Ext.swift
│   ├── NSNotification.swift
│   ├── Publisher+Ext.swift
│   ├── String+Localization.swift
│   └── UIViewController+Ext.swift
├── ScreenSizer.swift         # Screen size calculations (if needed)
├── Error/                    # Error handling
│   └── ErrorHandler.swift
├── Helpers/                  # Helper functions
│   ├── Validators.swift
│   ├── Formatters.swift
│   ├── DateHelpers.swift
│   └── StringHelpers.swift
└── View/                     # Reusable UI components
    ├── AlertItem.swift
    ├── BaseLoadingView.swift
    ├── ExitConfirmationModifier.swift
    ├── InputFieldModifier.swift
    ├── LabeledInputField.swift
    ├── OTPInputView.swift
    └── ToolbarModifier.swift
```

## Core/Features/Storage Directory

Storage functionality as a core feature module:

```
Core/Features/Storage/
├── Model/
│   └── StorageModel.swift
├── Services/
│   ├── KeychainManager.swift
│   ├── UserDefaultsManager.swift
│   └── StorageService.swift
└── Protocols/
    └── StorageProtocol.swift
```

## Core/Features/Security Directory

Security functionality as a core feature module:

```
Core/Features/Security/
├── Model/
│   └── SecurityModel.swift
├── Services/
│   ├── EncryptionManager.swift
│   ├── BiometricManager.swift
│   └── SecurityService.swift
└── Protocols/
    └── SecurityProtocol.swift
```

## Core/Constants Directory

App-wide constants and configuration:

```
Core/Constants/
├── AppConstants.swift        # General app constants
├── APIConstants.swift        # API endpoints and configuration
└── Configuration.swift       # App configuration and feature flags
```

## Utils/Helpers Directory

Helper functions and utilities:

```
Utils/Helpers/
├── Validators.swift          # Validation helpers
├── Formatters.swift          # Data formatters
├── DateHelpers.swift         # Date utility functions
└── StringHelpers.swift       # String utility functions
```

## Test Structure

```
ProjectNameTests/
├── UnitTests/
│   ├── Core/
│   │   ├── Navigation/
│   │   ├── Models/
│   │   ├── Managers/
│   │   ├── Features/
│   │   │   ├── Storage/
│   │   │   └── Security/
│   │   └── Constants/
│   ├── Features/
│   │   ├── FeatureA/
│   │   ├── FeatureB/
│   │   └── FeatureC/
│   └── Utils/
│       ├── Extension/
│       ├── Helpers/
│       └── View/
├── IntegrationTests/
│   └── [Integration test files]
└── UITests/
    └── [UI test files]
```

## Resources Directory

```
Resources/
├── Assets.xcassets/          # Image assets
│   ├── Contents.json
│   ├── icon.imageset/
│   ├── logo.imageset/
│   ├── logo_long.imageset/
│   └── warning.imageset/
│
├── Colors.xcassets/          # Color system
│   ├── Contents.json
│   ├── app_Background.colorset/
│   ├── app_ErrorColor.colorset/
│   ├── app_OnPrimary.colorset/
│   ├── app_OnSecondary.colorset/
│   ├── app_OnTertiary.colorset/
│   ├── app_primary.colorset/
│   ├── app_secondary.colorset/
│   ├── app_SuccessColor.colorset/
│   ├── app_Text.colorset/
│   └── app_tertiary.colorset/
│
├── Image+Assets.swift       # Asset helper extension
├── en.lproj/                 # English localization
│   └── Localizable.strings
├── [language].lproj/         # Other languages
│   └── Localizable.strings
├── privacy.html              # Privacy policy HTML (if needed)
├── terms.html                # Terms of service HTML (if needed)
└── consent.html              # Consent forms HTML (if needed)
```

## Extension Directory

All Swift extensions for common types:

- `Alert+Ext.swift` - Alert view extensions
- `Date+Ext.swift` - Date formatting utilities
- `NSNotification.swift` - Notification extensions
- `Publisher+Ext.swift` - Combine publisher utilities
- `String+Localization.swift` - Localization helpers
- `UIViewController+Ext.swift` - UIKit view controller extensions

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

## Project Organization

### Xcode Project Structure

Xcode project configuration:
- Build settings
- Target configurations
- Scheme definitions
- Build phases

### Workspace Structure

Workspace for managing:
- Main project
- Dependencies (CocoaPods/SPM)
- Multiple targets
- Shared schemes

### Dependencies

#### Swift Package Manager (Recommended)
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

#### CocoaPods (Optional, Not Recommended)
**CocoaPods** is optional and not recommended for new projects:
- Requires Ruby and CocoaPods gem installation
- Requires `pod install` command after dependency changes
- Creates workspace file that must be used instead of project file
- Additional maintenance overhead

If using CocoaPods (legacy projects only):
- `Pods/` - Managed dependencies directory
- `Podfile` - Dependency configuration file
- `Podfile.lock` - Dependency lock file
- `ProjectName.xcworkspace` - Must use workspace instead of project file

**Note**: For new projects, prefer Swift Package Manager for better integration and maintenance.

## Test Structure

```
ProjectNameTests/
├── ProjectNameTests.swift         # General application tests
├── FeatureATests.swift            # Feature A tests
├── FeatureBTests.swift            # Feature B tests
└── ServicesTest.swift             # Service layer tests

ProjectNameUITests/
├── ProjectNameUITests.swift       # UI tests
└── ProjectNameUITestsLaunchTests.swift  # Launch tests
```

## Demo Application (Optional)

```
ProjectNameDemo/
├── ProjectNameDemoApp.swift       # App entry point
├── ContentView.swift             # Demo content view
└── Resources/                    # Demo resources
    ├── Assets.xcassets/
    ├── en.lproj/
    └── [language].lproj/
```

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

## Directory Naming Guidelines

### Use PascalCase for:
- Feature directories: `UserProfile/`, `Authentication/`
- Model directories: `Model/`, `View/`, `ViewModel/`

### Use camelCase for:
- File names: `userProfileModel.swift`, `authenticationView.swift`

### Use lowercase for:
- Resource directories: `resources/`, `assets/`
- Extension directories: `extension/`, `utils/`

## File Naming Guidelines

### Models
- `UserProfileModel.swift`
- `AuthenticationResponse.swift`
- `ValidationError.swift`

### Views
- `UserProfileView.swift`
- `AuthenticationFormView.swift`
- `ProfileHeaderView.swift`

### ViewModels
- `UserProfileViewModel.swift`
- `AuthenticationViewModel.swift`

### Repositories
- `UserProfileRepo.swift`
- `AuthenticationRepo.swift`

### Services
- `UserProfileService.swift`
- `AuthenticationService.swift`

## Summary

This folder structure template provides:

1. **Clear Organization**: Features are self-contained and easy to navigate
2. **Consistency**: Same structure across all features
3. **Scalability**: Easy to add new features following the pattern
4. **Maintainability**: Clear separation of concerns
5. **Testability**: Tests mirror source structure

Follow this template when creating new projects or features to maintain consistency and organization.
