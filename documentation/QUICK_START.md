# iOS Project Quick Start Guide

This guide will help you set up a new iOS project following the architecture patterns and best practices outlined in this cookbook.

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Xcode** installed (version 14.0 or later recommended)
- [ ] **Swift** 5.7 or later
- [ ] **macOS** 12.0 or later
- [ ] **Apple Developer Account** (for device testing and App Store distribution)
- [ ] Basic understanding of **SwiftUI** and **Swift** programming

## Template/Starter Project

If a template/starter project is available, you can clone it from: `[Template Repository URL]`

**Note**: Update this section with the actual repository URL when a template project becomes available. Using a template can significantly reduce setup time.

## Step 1: Create New Xcode Project

1. Open **Xcode**
2. Select **File** → **New** → **Project**
3. Choose **iOS** → **App**
4. Configure project:
   - **Product Name**: Your project name
   - **Team**: Select your development team
   - **Organization Identifier**: Your bundle identifier prefix
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: Choose based on your needs
5. Choose project location and click **Create**

## Step 2: Create Folder Structure

Create the following folder structure in your project:

```
ProjectName/
├── AppStartService.swift
├── MainView.swift
├── Core/
│   ├── Navigation/
│   ├── Models/
│   ├── Managers/
│   ├── Features/
│   └── Constants/
├── Features/
├── Utils/
│   ├── Extension/
│   ├── Helpers/
│   └── View/
└── Resources/
    ├── Assets.xcassets/
    ├── Colors.xcassets/
    └── [language].lproj/
```

**How to create folders in Xcode:**
- Right-click in Project Navigator
- Select **New Group**
- Name the group
- For physical folders, create them in Finder and drag into Xcode

## Step 3: Essential Files to Create First

Create these core files in order:

### 3.1 Core Models

**Core/Models/AppModel.swift**
- Environment configuration
- App-wide settings

**Core/Models/DataModel.swift**
- Central data structure
- Application state container

### 3.2 Core Managers

**Core/Managers/SessionManager.swift**
- Singleton ObservableObject
- Global state management
- Navigation state handling

**Core/Managers/APIManager.swift**
- Actor-based API manager
- Network layer abstraction
- Token management

### 3.3 Navigation

**Core/Navigation/NavigationState.swift**
- Navigation state enum
- Flow control definitions

**Core/Navigation/NavigationCoordinator.swift**
- Navigation coordination logic

### 3.4 Constants

**Core/Constants/AppConstants.swift**
- App-wide constants

**Core/Constants/APIConstants.swift**
- API endpoints
- Network configuration

**Core/Constants/Configuration.swift**
- Feature flags
- App configuration

### 3.5 Entry Points

**AppStartService.swift**
- Application initialization
- Session management
- Entry point methods

**MainView.swift**
- Root SwiftUI view
- Navigation orchestrator
- State observation

## Step 4: Configure Project Settings

### 4.1 Build Configuration

1. Select project in Project Navigator
2. Select target
3. Go to **Build Settings**
4. Add User-Defined setting:
   - **Key**: `APP_ENVIRONMENT`
   - **Debug**: `debug`
   - **Release**: `production`

### 4.2 Info.plist Configuration

1. Open `Info.plist`
2. Add key: `AppEnvironment`
3. Set value: `$(APP_ENVIRONMENT)`

### 4.3 Dependencies (Swift Package Manager)

1. **File** → **Add Packages...**
2. Add required packages (if any)
3. Recommended: Use SPM over CocoaPods

## Step 5: Initialize Core Features

### 5.1 Storage Feature

Create `Core/Features/Storage/`:
- KeychainManager.swift
- UserDefaultsManager.swift
- StorageService.swift

### 5.2 Security Feature

Create `Core/Features/Security/`:
- EncryptionManager.swift
- BiometricManager.swift
- SecurityValidator.swift

## Step 6: Set Up Resources

### 6.1 Assets

1. Create `Assets.xcassets` (usually auto-created)
2. Create `Colors.xcassets` for semantic colors
3. Add image assets as needed

### 6.2 Localization

1. Create `.lproj` folders for each language
2. Create `Localizable.strings` files
3. Configure localization in project settings

## Step 7: Create First Feature Module

Follow the feature module structure:

```
FeatureName/
├── Model/
├── View/
├── ViewModel/
├── Repo/
└── Services/
```

**Example: Create a Splash feature**
1. Create `Features/Splash/` folder
2. Add basic View, ViewModel, Model files
3. Connect to navigation state

### Common First Feature: Splash Screen Example

Here's a complete, copy-paste ready example for creating a Splash screen feature:

#### 1. Create the Model

**Features/Splash/Model/SplashModel.swift**
```swift
import Foundation

struct SplashModel {
    var appName: String
    var version: String
    
    static let `default` = SplashModel(
        appName: "MyApp",
        version: "1.0.0"
    )
}
```

#### 2. Create the ViewModel

**Features/Splash/ViewModel/SplashViewModel.swift**
```swift
import Foundation
import Combine

@MainActor
class SplashViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var model: SplashModel = .default
    
    private let sessionManager = SessionManager.shared
    
    init() {
        // Initialize splash screen
        loadSplashData()
    }
    
    func loadSplashData() {
        // Simulate loading time (e.g., 2 seconds)
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            // After loading, navigate to next screen
            await MainActor.run {
                self.isLoading = false
                // Navigate to welcome or main feature
                sessionManager.navigationState = .feature1
            }
        }
    }
}
```

#### 3. Create the View

**Features/Splash/View/SplashView.swift**
```swift
import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel = SplashViewModel()
    
    var body: some View {
        ZStack {
            // Background color
            Color.blue
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App logo or icon
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                
                // App name
                Text(viewModel.model.appName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Version
                Text("Version \(viewModel.model.version)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                // Loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.top, 20)
                }
            }
        }
    }
}
```

#### 4. Update NavigationState

**Core/Navigation/NavigationState.swift**
```swift
enum NavigationState {
    case splash      // Add this case
    case feature1
    case feature2
    case feature3
}
```

#### 5. Update MainView

**MainView.swift**
```swift
import SwiftUI

struct MainView: View {
    @ObservedObject private var sessionManager = SessionManager.shared
    
    var body: some View {
        Group {
            switch sessionManager.navigationState {
            case .splash:
                SplashView()
            case .feature1:
                Feature1View()
            case .feature2:
                Feature2View()
            case .feature3:
                Feature3View()
            }
        }
    }
}
```

#### 6. Initialize Navigation State

In `AppStartService.swift` or your app initialization:
```swift
// Set initial navigation state to splash
SessionManager.shared.navigationState = .splash
```

This complete example provides:
- A working Splash screen with loading animation
- Automatic navigation after loading
- Proper MVVM architecture
- Integration with SessionManager
- Ready-to-use code that follows project patterns

## Step 8: Connect Everything

### 8.1 Update App Entry Point

In your `App` file:
```swift
@main
struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
```

### 8.2 Initialize Session

In `AppStartService.swift`, set up session initialization:
- Configure environment
- Initialize SessionManager
- Set up API endpoints

## Common Setup Tasks

### Environment Configuration

- [ ] Set up build configurations (Debug/Release)
- [ ] Configure API endpoints per environment
- [ ] Set up environment-specific constants

### Dependencies Setup

- [ ] Add Swift Package Manager dependencies
- [ ] Configure package versions
- [ ] Update Package.resolved

### Testing Setup

- [ ] Create test target (if not auto-created)
- [ ] Set up test folder structure
- [ ] Configure test schemes

### Code Signing

- [ ] Configure development team
- [ ] Set up provisioning profiles
- [ ] Configure code signing settings

### Localization Setup

- [ ] Add supported languages
- [ ] Create .lproj folders
- [ ] Add Localizable.strings files
- [ ] Test localization

## Verification Checklist

Before moving forward, verify:

- [ ] Project builds without errors
- [ ] Core folder structure is in place
- [ ] SessionManager initializes correctly
- [ ] Navigation state works
- [ ] API Manager is configured
- [ ] Environment configuration is set
- [ ] First feature module is created and connected

## Next Steps

Once setup is complete:

1. Read [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed architecture patterns
2. Review [FOLDER_STRUCTURE.md](./FOLDER_STRUCTURE.md) for complete structure details
3. Check [PATTERNS.md](./PATTERNS.md) for design patterns
4. Follow [DATA_FLOW.md](./DATA_FLOW.md) to understand data flow
5. Set up API integration using [API_INTEGRATION.md](./API_INTEGRATION.md)

## Troubleshooting

**Issue**: Project won't build
- Check Swift version compatibility
- Verify all required files are created
- Check for missing imports

**Issue**: Navigation not working
- Verify SessionManager is initialized
- Check NavigationState enum is properly defined
- Ensure MainView observes SessionManager

**Issue**: Environment configuration not working
- Verify build settings are configured
- Check Info.plist has correct key
- Ensure AppModel reads from correct source

For more detailed information, refer to the specific documentation files in this cookbook.

