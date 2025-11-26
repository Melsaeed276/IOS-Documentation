# Resources Management Guide

## Overview

This guide describes how to organize and manage resources in iOS applications, including assets, colors, localization, and static content.

## Asset Catalog

### Location
`ProjectName/Resources/Assets.xcassets/`

### Image Assets

#### App Icon
- **Name**: `icon` (or `appIcon`)
- **Type**: PNG images
- **Files**: Multiple sizes for different devices
- **Usage**: App icon
- **Access**: `Image.icon` or `UIImage.iconImage`

#### Logo
- **Name**: `logoImage`
- **Type**: SVG or PNG images
- **Files**: Different sizes and variants
- **Usage**: Main logo displayed on screens
- **Access**: `Image.logo` or `UIImage.logoImage`

#### Long Logo
- **Name**: `logo_long`
- **Type**: SVG or PNG image
- **Usage**: Long format logo for headers and navigation bars
- **Access**: `Image.logoLong` or `UIImage.logoLong`

#### Warning/Confirmation Icons
- **Name**: `WarningConfirmation` (or similar)
- **Type**: PNG or SVG image
- **Usage**: Warning/confirmation dialogs
- **Access**: `Image.warningConfirmation` or `UIImage.warningIcon`

### Image Helper Extension

Location: `ProjectName/Resources/Image+Assets.swift`

Provides convenient access to images:

```swift
// SwiftUI
Image.logo
Image.icon
Image.logoLong
Image.warningConfirmation

// UIKit
UIImage.logoImage
UIImage.iconImage
UIImage.logoLong
UIImage.warningIcon
```

## Color System

### Location
`ProjectName/Resources/Colors.xcassets/`

### Color Assets

All colors follow a semantic naming convention: `app_*` or `brand_*`

#### Primary Colors

**app_primary** (or `brand_primary`)
- Primary brand color
- Usage: Buttons, primary actions, headers
- Access: `Color(.appPrimary)`

**app_secondary** (or `brand_secondary`)
- Secondary brand color
- Usage: Secondary actions, accents
- Access: `Color(.appSecondary)`

**app_tertiary** (or `brand_tertiary`)
- Tertiary color
- Usage: Backgrounds, borders
- Access: `Color(.appTertiary)`

#### On Colors (Text on colored backgrounds)

**app_OnPrimary**
- Text color on primary background
- Access: `Color(.appOnPrimary)`

**app_OnSecondary**
- Text color on secondary background
- Access: `Color(.appOnSecondary)`

**app_OnTertiary**
- Text color on tertiary background
- Access: `Color(.appOnTertiary)`

#### Semantic Colors

**app_Background**
- Background color
- Usage: Main background
- Access: `Color(.appBackground)`

**app_Text**
- Primary text color
- Usage: Body text, labels
- Access: `Color(.appText)`

**app_ErrorColor**
- Error state color
- Usage: Error messages, validation errors
- Access: `Color(.appErrorColor)`

**app_SuccessColor**
- Success state color
- Usage: Success messages, completed states
- Access: `Color(.appSuccessColor)`

### Color Usage

```swift
// In SwiftUI views
Text("Hello")
    .foregroundColor(Color(.appText))

Button("Submit") {
    // Action
}
.background(Color(.appPrimary))
.foregroundColor(Color(.appOnPrimary))
```

## Localization

### Location
`ProjectName/Resources/[language].lproj/Localizable.strings`

### Supported Languages

#### Primary Language
- **File**: `en.lproj/Localizable.strings` (or your primary language)
- **Primary language** for the application

#### Secondary Languages
- **File**: `[language].lproj/Localizable.strings`
- **Additional language** support (e.g., `fr.lproj`, `es.lproj`)

### Localization Helper

Location: `ProjectName/Utils/Extension/String+Localization.swift`

Provides easy access to localized strings:

```swift
extension String {
    func localized() -> String {
        // Returns localized string
    }
}
```

### Usage

```swift
// In code
let text = "welcome_title".localized()

// In SwiftUI
Text("welcome_title".localized())
```

### Localization Keys

#### UI Strings

- `welcome_title` - Welcome screen title
- `button_submit` - Submit button text
- `error_generic` - Generic error message
- `success_message` - Success message

#### API Configuration Keys (if needed)

**Test Environment**:
- `api_base_test_domain`
- `api_test_port`
- `api_test_ssl`

**Production Environment**:
- `api_base_domain`
- `api_port`
- `api_ssl`

### Adding New Localizations

1. Create new `.lproj` folder (e.g., `fr.lproj`)
2. Copy `Localizable.strings` file
3. Translate all keys
4. Use `.localized()` extension in code
5. Test in the new language

## HTML/Static Resources

### Location
`ProjectName/Resources/`

### HTML Files

#### Privacy Policy
- **File**: `privacy.html` (or `privacy_policy.html`)
- **Purpose**: Privacy policy consent form
- **Usage**: Displayed in web view for privacy policy acceptance
- **Access**: Via `ContractModel(htmlFileName: "privacy")`

#### Terms of Service
- **File**: `terms.html` (or `terms_of_service.html`)
- **Purpose**: Terms of service consent form
- **Usage**: Displayed in web view for terms acceptance
- **Access**: Via `ContractModel(htmlFileName: "terms")`

#### Additional Consent Forms
- **File**: `consent.html` (or specific consent type)
- **Purpose**: Additional consent forms as needed
- **Usage**: Displayed for specific consent types
- **Access**: Via `ContractModel(htmlFileName: "consent")`

### Contract Model

Location: `ProjectName/Utils/Contract/ContractModel.swift`

Manages HTML contract display:

```swift
struct ContractModel {
    let htmlFileName: String
    
    // Loads HTML from Resources folder
    func loadHTML() -> String? {
        // Loads HTML content
    }
}
```

### WebView Screen

Location: `ProjectName/Utils/Contract/WebViewScreen.swift`

SwiftUI view for displaying HTML contracts:

```swift
struct WebViewScreen: View {
    let contract: ContractModel
    
    var body: some View {
        // WebView displaying HTML
    }
}
```

### Usage

```swift
// In ViewModel
@Published var privacyContract: ContractModel? = ContractModel(htmlFileName: "privacy")
@Published var termsContract: ContractModel? = ContractModel(htmlFileName: "terms")

// Display in view
WebViewScreen(contract: privacyContract)
```

## Resource Organization

### Directory Structure

```
Resources/
├── Assets.xcassets/          # Image assets
│   ├── icon.imageset/
│   ├── logo.imageset/
│   ├── logo_long.imageset/
│   └── warning.imageset/
│
├── Colors.xcassets/           # Color definitions
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
├── Image+Assets.swift        # Image helper extension
│
├── en.lproj/                 # English localization
│   └── Localizable.strings
│
├── [language].lproj/         # Other languages
│   └── Localizable.strings
│
├── privacy.html              # Privacy policy
├── terms.html                # Terms of service
└── consent.html              # Additional consents
```

## Best Practices

### 1. Use Asset Helpers

Always use the provided extensions for assets:

```swift
// ✅ Good
Image.logo
Color(.appPrimary)

// ❌ Bad
Image("logoImage")
Color("app_primary")
```

### 2. Localize All Strings

Never hardcode user-facing strings:

```swift
// ✅ Good
Text("welcome_title".localized())

// ❌ Bad
Text("Welcome")
```

### 3. Use Semantic Colors

Use semantic color names for maintainability:

```swift
// ✅ Good
.foregroundColor(Color(.appText))
.background(Color(.appPrimary))

// ❌ Bad
.foregroundColor(.black)
.background(.blue)
```

### 4. Support Multiple Languages

Always provide translations for all supported languages:

```
en.lproj/Localizable.strings
fr.lproj/Localizable.strings
es.lproj/Localizable.strings
```

### 5. Use SVG for Scalable Images

Prefer SVG for logos and icons that need to scale:

- `logo` (SVG)
- `logoLong` (SVG)

Use PNG for complex images:

- `icon` (PNG)
- `warningConfirmation` (PNG)

### 6. Organize Assets by Category

Group related assets together:

- Icons: `icon_*`
- Logos: `logo_*`
- Illustrations: `illustration_*`
- Backgrounds: `background_*`

## Resource Loading

### Images

Images are loaded automatically by SwiftUI/UIKit when referenced:

```swift
// SwiftUI
Image.logo  // Loads from Assets.xcassets

// UIKit
UIImage.logoImage  // Loads from Assets.xcassets
```

### Colors

Colors are loaded from Colors.xcassets:

```swift
Color(.appPrimary)  // Loads from Colors.xcassets
```

### Localized Strings

Strings are loaded from `.lproj` folders:

```swift
"key".localized()  // Loads from appropriate .lproj folder
```

### HTML Files

HTML files are loaded from Resources folder:

```swift
let contract = ContractModel(htmlFileName: "privacy")
let html = contract.loadHTML()  // Loads from Resources/privacy.html
```

## Asset Catalog Structure

### Imageset Structure

Each image asset has its own folder:

```
icon.imageset/
├── Contents.json          # Asset metadata
├── icon@1x.png
├── icon@2x.png
└── icon@3x.png
```

### Colorset Structure

Each color has its own folder:

```
app_primary.colorset/
└── Contents.json          # Color definition (light/dark mode)
```

## Resource Access Patterns

### SwiftUI

```swift
// Images
Image.logo
Image.icon
Image.logoLong

// Colors
Color(.appPrimary)
Color(.appText)
Color(.appErrorColor)

// Localized Strings
Text("welcome_title".localized())
```

### UIKit

```swift
// Images
UIImage.logoImage
UIImage.iconImage
UIImage.logoLong

// Colors
UIColor(named: "app_primary")
UIColor(named: "app_text")
```

## Resource Summary

### Images
- App icon
- Logo variants
- UI icons and illustrations
- SVG format for scalable graphics
- PNG format for complex images

### Colors
- Semantic color system
- Primary, secondary, tertiary colors
- On-colors for text on colored backgrounds
- Semantic colors (background, text, error, success)
- Support for light/dark mode

### Localization
- Multiple language support
- API configuration keys (if needed)
- UI strings
- Consistent key naming

### HTML
- Privacy policy
- Terms of service
- Additional consent forms
- WebView display support
- Contract model management
