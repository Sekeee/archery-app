# Flutter LAS Vegas Architecture Pattern

## Overview
Flutter LAS Vegas is a structured architecture pattern that separates concerns into distinct layers: Logic, Architecture, State, and View. This pattern promotes clean code organization, maintainability, and scalability.

## Directory Structure
```
lib/
├── pages/
│   ├── feature_name/
│   │   ├── controller/         # Business logic
│   │   │   └── feature_controller.dart
│   │   ├── state/             # State management
│   │   │   └── feature_state.dart
│   │   ├── view/              # UI components
│   │   │   └── feature_view.dart
│   │   └── suite/             # Reusable components
│   │       └── components/
│   │           └── custom_widget.dart
```

## Layer Responsibilities

### 1. Controller (Logic)
- Contains all business logic
- Handles data processing and manipulation
- Manages API calls and data fetching
- Implements business rules and validations
- Extends GetX Controller

```dart
class FeatureController extends GetxController {
  final state = FeatureState();
  
  // Business logic methods
  void processData() {
    // Implementation
  }
}
```

### 2. State (State Management)
- Declares all variables and observables
- Manages state variables using GetX
- Contains form controllers and validation states
- Defines data models and their states

```dart
class FeatureState {
  final RxBool isLoading = false.obs;
  final TextEditingController inputController = TextEditingController(); 
  
  // Other state variables
}
```

### 3. View (UI)
- Contains only UI-related code
- Uses GetView for controller access
- Implements layout and styling
- Handles user interactions
- Delegates business logic to controller

```dart
class FeatureView extends GetView<FeatureController> {
  const FeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // UI implementation
    );
  }
}
```

### 4. Suite (Components)
- Contains reusable widgets specific to the feature
- Implements custom components
- Follows atomic design principles
- Maintains feature-specific styling

```dart
class CustomWidget extends StatelessWidget {
  const CustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Component implementation
    );
  }
}
```

## Best Practices

1. **Separation of Concerns**
   - Keep business logic in controllers
   - Store state variables in state classes
   - Maintain UI code in view files
   - Place reusable components in suite

2. **Naming Conventions**
   - Use clear, descriptive names
   - Follow feature_name_controller.dart pattern
   - Maintain consistent naming across layers

3. **State Management**
   - Use GetX for state management
   - Declare all state variables in state class
   - Use .obs for reactive variables

4. **Code Organization**
   - Keep files focused and single-responsibility
   - Use proper imports and exports
   - Maintain consistent file structure

5. **Component Reusability**
   - Create reusable components in suite
   - Follow atomic design principles
   - Maintain component documentation

## Example Implementation

```dart
// controller/feature_controller.dart
class FeatureController extends GetxController {
  final state = FeatureState();
  
  void handleUserAction() {
    // Business logic
  }
}

// state/feature_state.dart
class FeatureState {
  final RxBool isLoading = false.obs;
  final TextEditingController inputController = TextEditingController();
}

// view/feature_view.dart
class FeatureView extends GetView<FeatureController> {
  const FeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // UI implementation
        ],
      ),
    );
  }
}

// suite/components/custom_widget.dart
class CustomWidget extends StatelessWidget {
  const CustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Component implementation
    );
  }
}
```

## Benefits
- Clear separation of concerns
- Improved code maintainability
- Better testability
- Scalable architecture
- Consistent code organization
- Reusable components
- Easy to understand and follow 