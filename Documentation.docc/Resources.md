# Resources Management Guide

@Metadata {
    @DisplayName("Resources")
    @PageKind(article)
}

## Overview

This guide describes how to organize and manage resources in iOS applications, including assets, colors, localization, and static content.

## Asset Catalog

### Location
`ProjectName/Resources/Assets.xcassets/`

### Image Assets

#### App Icon
- **Name**: `icon` (or `appIcon`)
- **Type**: PNG images
- **Access**: `Image.icon` or `UIImage.iconImage`

#### Logo
- **Name**: `logoImage`
- **Type**: SVG or PNG images
- **Access**: `Image.logo` or `UIImage.logoImage`

### Image Helper Extension

Location: `ProjectName/Resources/Image+Assets.swift`

Provides convenient access to images:

```swift
// SwiftUI
Image.logo
Image.icon
Image.logoLong

// UIKit
UIImage.logoImage
UIImage.iconImage
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

#### Semantic Colors

**app_Background**
- Background color
- Access: `Color(.appBackground)`

**app_Text**
- Primary text color
- Access: `Color(.appText)`

**app_ErrorColor**
- Error state color
- Access: `Color(.appErrorColor)`

**app_SuccessColor**
- Success state color
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
- **File**: `privacy.html`
- **Purpose**: Privacy policy consent form
- **Access**: Via `ContractModel(htmlFileName: "privacy")`

#### Terms of Service
- **File**: `terms.html`
- **Purpose**: Terms of service consent form
- **Access**: Via `ContractModel(htmlFileName: "terms")`

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

For more information on project structure, see <doc:FolderStructure>.
