/// iOS Project Documentation Cookbook
/// 
/// This package provides comprehensive documentation for iOS project structure,
/// architecture patterns, and best practices following MVVM + Repository pattern.
///
/// ## Overview
///
/// This documentation cookbook provides a comprehensive template and guide for structuring,
/// organizing, and documenting iOS projects following best practices and modern architectural patterns.
///
/// The documentation covers:
///
/// - Project setup and quick start
/// - Architecture patterns (MVVM + Repository)
/// - Component structure and organization
/// - Design patterns and best practices
/// - API integration
/// - Testing strategies
/// - Code review guidelines
///
/// ## Getting Started
///
/// New to this project structure? Start here:
///
/// 1. **<doc:QuickStartGuide>** - Set up a new iOS project from scratch
///    - Project setup checklist
///    - Step-by-step project creation
///    - Essential files to create first
///    - Common setup tasks
///
/// 2. **<doc:Architecture>** - Understand the project architecture
///    - MVVM + Repository pattern
///    - State management approach
///    - Entry points and initialization
///
/// 3. **<doc:FolderStructure>** - Learn the project organization
///    - Complete directory structure
///    - File naming conventions
///    - Feature module organization
///
/// 4. **<doc:Patterns>** - Review design patterns and architectural decisions
///
/// 5. **<doc:DataFlow>** - Understand how data moves through the application
///
/// ## Architecture Overview
///
/// The project follows a **MVVM (Model-View-ViewModel) + Repository** pattern with clear separation of concerns:
///
/// ```
/// Presentation Layer:     View (SwiftUI Views)
///                            ↓ @ObservedObject
/// View Model Layer:       ViewModel (ObservableObject)
///                            ↓ uses
/// Business Logic Layer:   Repository (Business Logic)
///                            ↓ uses
/// Service Layer:          Service (API Communication)
///                            ↓ uses
/// Network Layer:          APIManager (Actor-based Network)
///
/// State Management:       SessionManager (Singleton ObservableObject)
/// ```
///
/// **Key Components:**
///
/// - **View**: SwiftUI views that display UI and handle user interactions
/// - **ViewModel**: ObservableObject that manages view state and business logic coordination
/// - **Repository**: Business logic layer that coordinates between ViewModels and Services
/// - **Service**: API communication layer that handles network requests
/// - **APIManager**: Actor-based network layer for thread-safe API calls
/// - **SessionManager**: Singleton managing global application state
///
/// ## Documentation Index
///
/// ### Quick Start Guide
///
/// **<doc:QuickStartGuide>**
///
/// Quick start guide for setting up a new iOS project:
///
/// - Project setup checklist
/// - Step-by-step new project creation
/// - Essential files to create first
/// - Common setup tasks
///
/// **Start here** if you're setting up a new project.
///
/// ### Architecture
///
/// **<doc:Architecture>**
///
/// Complete overview of project architecture, including:
///
/// - Project purpose and overview
/// - Architecture patterns (MVVM + Repository)
/// - Entry points and initialization
/// - State management approach
/// - Environment configuration
/// - Feature module structure
/// - API architecture overview
///
/// > Not all projects can be in the same structure but mostly this is a good way to keep everything organized well.
///
/// ### Folder Structure
///
/// **<doc:FolderStructure>**
///
/// Detailed directory structure and organization:
///
/// - Complete folder tree
/// - Purpose of each directory
/// - Feature module organization
/// - File naming conventions
/// - Separation of concerns
///
/// **Use this** to navigate the codebase and understand file organization.
///
/// ### Components
///
/// **<doc:Components>**
///
/// Comprehensive component documentation:
///
/// - Core components and entry points
/// - Feature modules structure
/// - ViewModels and their responsibilities
/// - Utility components
/// - Component relationships
///
/// **Reference this** when working with specific components or features.
///
/// ### Patterns
///
/// **<doc:Patterns>**
///
/// Design patterns and architectural decisions:
///
/// - MVVM pattern implementation
/// - Repository pattern usage
/// - Service layer architecture
/// - API Manager actor pattern
/// - Singleton pattern usage
/// - Error handling patterns
/// - State management patterns
///
/// **Read this** to understand the design decisions and patterns used throughout the project.
///
/// ### Data Flow
///
/// **<doc:DataFlow>**
///
/// Complete data flow documentation:
///
/// - User journey flow
/// - Navigation state management
/// - Data flow patterns
/// - API communication flow
/// - State management flow
/// - Error flow
/// - Session management
///
/// **Follow this** to understand how data moves through the application.
///
/// ### API Integration
///
/// **<doc:APIIntegration>**
///
/// API integration and communication:
///
/// - API Manager actor implementation
/// - JWT token management
/// - API endpoints structure
/// - Service layer implementation
/// - Error handling
/// - Request/response models
/// - Session management
///
/// **Use this** when working with API integration or adding new endpoints.
///
/// ### Resources
///
/// **<doc:Resources>**
///
/// Resources, assets, and localization:
///
/// - Image assets organization
/// - Color system
/// - Localization support
/// - HTML/static resources
/// - Resource organization
/// - Best practices
///
/// **Reference this** when working with UI resources, colors, or localization.
///
/// ### Testing
///
/// **<doc:Testing>**
///
/// Comprehensive testing guide:
///
/// - XCTest and Swift Testing frameworks
/// - Unit testing strategies
/// - Integration testing
/// - UI testing with XCUITest
/// - Performance testing
/// - Mocking strategies
/// - Test data management
/// - Best practices and patterns
///
/// **Use this** when writing tests, setting up test infrastructure, or understanding testing patterns.
///
/// ### Code Review
///
/// **<doc:CodeReview>**
///
/// Code review guidelines and best practices:
///
/// - What to look for in reviews
/// - Architecture compliance checks
/// - Swift-specific best practices
/// - Common anti-patterns to avoid
/// - Comprehensive review checklist
/// - Review process and approval criteria
///
/// **Reference this** when reviewing code or preparing code for review.
///
/// ### Glossary
///
/// **<doc:Glossary>**
///
/// Comprehensive glossary of terms, concepts, and patterns used throughout the documentation:
///
/// - Architecture patterns and concepts
/// - Component definitions
/// - State management terms
/// - API and networking terminology
/// - Common patterns and anti-patterns
///
/// **Reference this** when you encounter unfamiliar terms or need clarification on concepts.
///
/// ### Changelog
///
/// **<doc:Changelog>**
///
/// Changelog tracking all notable changes to the documentation:
///
/// - Documentation updates
/// - Architecture changes
/// - Breaking changes
/// - Version history
///
/// **Check this** to see what has changed in recent versions and track documentation evolution.
///
/// ## Project Structure Template
///
/// ```
/// ProjectName/
/// ├── AppStartService.swift          # Entry point (root for visibility)
/// ├── MainView.swift                  # Root navigation (root for visibility)
/// │
/// ├── Core/                           # Core application layer
/// │   ├── Navigation/                # Navigation handling
/// │   │   ├── NavigationState.swift
/// │   │   └── NavigationCoordinator.swift
/// │   ├── Models/                    # Core data models
/// │   │   ├── AppModel.swift         # Configuration & environment
/// │   │   └── DataModel.swift        # Central data model
/// │   ├── Managers/                  # Core managers
/// │   │   ├── SessionManager.swift   # State management
/// │   │   └── APIManager.swift       # API layer
/// │   ├── Features/                  # Core feature modules
/// │   │   ├── Storage/              # Storage feature
/// │   │   └── Security/              # Security feature
/// │   └── Constants/                 # App-wide constants
/// │       ├── AppConstants.swift
/// │       ├── APIConstants.swift
/// │       └── Configuration.swift
/// │
/// ├── Features/                      # Feature-based modules
/// │   ├── FeatureA/                  # Feature module example
/// │   ├── FeatureB/                  # Feature module example
/// │   └── FeatureC/                  # Feature module example
/// │
/// ├── Utils/                         # Shared utilities
/// │   ├── Extension/                 # Swift extensions
/// │   │   ├── Alert+Ext.swift
/// │   │   ├── Date+Ext.swift
/// │   │   ├── String+Localization.swift
/// │   │   └── [other extensions]
/// │   ├── Helpers/                   # Helper functions
/// │   │   ├── Validators.swift
/// │   │   ├── Formatters.swift
/// │   │   └── DateHelpers.swift
/// │   └── View/                      # Reusable views
/// │
/// └── Resources/                      # Assets & localization
///     ├── Assets.xcassets/
///     ├── Colors.xcassets/
///     └── [language].lproj/
/// ```
///
/// ## Key Concepts
///
/// ### State Management
///
/// - **SessionManager**: Singleton managing global application state
/// - **DataModel**: Central data structure for application data
/// - **ProgressViewModel**: Multi-step flow progression tracking
///
/// ### Navigation
///
/// - **NavigationState**: Top-level navigation states enum
/// - **FlowType**: Flow step progression enum
/// - **MainView**: Navigation orchestrator
///
/// ### Architecture
///
/// - **MVVM**: Model-View-ViewModel pattern
/// - **Repository**: Business logic layer
/// - **Service**: API communication layer
/// - **Actor**: Thread-safe API manager
///
/// ## Common Tasks
///
/// ### Adding a New Feature Module
///
/// 1. Create feature directory in `Features/`
/// 2. Follow structure: Model, View, ViewModel, Repo, Services
/// 3. Add feature to navigation state enum if needed
/// 4. Update main navigation switch statement
/// 5. Add to progress tracking if part of multi-step flow
///
/// ### Adding a New API Endpoint
///
/// 1. Add endpoint to service protocol
/// 2. Implement in service class
/// 3. Use `APIManager.request()` method
/// 4. Handle errors appropriately
/// 5. Update repository if needed
/// 6. Add request/response models
///
/// ### Adding Localization
///
/// 1. Add key to `Localizable.strings` files for all supported languages
/// 2. Use `.localized()` extension in code
/// 3. Test in all supported languages
/// 4. Ensure proper pluralization if needed
///
/// ### Customizing UI
///
/// 1. Modify colors in `Colors.xcassets`
/// 2. Update images in `Assets.xcassets`
/// 3. Customize views in respective feature modules
/// 4. Use semantic colors for consistency
/// 5. Follow design system guidelines
///
/// ## Best Practices
///
/// 1. **Always use APIManager** for API calls - never make direct URLSession calls
/// 2. **Update SessionManager** for global state changes
/// 3. **Handle errors** with user-friendly messages
/// 4. **Use main actor** for UI updates
/// 5. **Follow MVVM pattern** consistently across features
/// 6. **Localize all strings** for user-facing text
/// 7. **Use semantic colors** for maintainability
/// 8. **Keep features modular** and self-contained
/// 9. **Write tests** for business logic and repositories
/// 10. **Document complex logic** with inline comments
/// 11. **Follow code review guidelines** - See <doc:CodeReview> for detailed guidelines
///
/// ## Additional Resources
///
/// - [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
/// - [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
/// - [Combine Framework](https://developer.apple.com/documentation/combine)
/// - [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)
///
/// ## Documentation Maintenance
///
/// This documentation should be maintained alongside the project. When making significant changes:
///
/// 1. Update relevant documentation files
/// 2. Update this guide if structure changes
/// 3. Add examples for new features
/// 4. Keep diagrams and flow charts current
/// 5. Update code examples to reflect current implementation
/// 6. **Update <doc:Changelog>** with all notable changes, including documentation updates, architecture changes, and breaking changes
///
/// ---
///
/// **Template Version**: 1.0
///
/// **Note**: This is a template documentation structure. Replace placeholders with your project-specific information.
