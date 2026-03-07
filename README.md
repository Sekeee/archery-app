# Archery Training App

A Flutter mobile application designed to help archery teams manage training sessions, record scores, and analyze performance across different training categories.

## Features

- **User Management** - Create and manage archer profiles
- **Match Management** - Organize training sessions with customizable settings
- **Score Recording** - Record arrow-by-arrow scores for each round (End)
- **Automatic Calculations** - End totals, match totals, and rankings
- **Match History** - View and analyze past training sessions
- **Category Rankings** - Compare performance across training types
- **Personal Analytics** - Track individual progress and statistics

## Getting Started

### Prerequisites

- Flutter SDK (^3.7.2)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

```bash
# Clone the repository
git clone <repository-url>

# Navigate to project directory
cd archery_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
lib/
├── main.dart          # App entry point
assets/
├── no-background.riv  # Rive animation assets
```

## Core Concepts

### Users
Archers participating in training sessions who can create/edit profiles and record scores.

### Matches
Training sessions containing:
- Match name & category
- Date/time
- Participating members
- Number of Ends (rounds)
- Arrows per End
- Scores and results

### Categories
Training types for performance comparison:
- Range
- Moving Object
- Horseback
- Long Distance
- Dynamic Shooting

### Scoring Structure
- **End**: One round where each archer shoots multiple arrows
- **End Total**: Sum of arrow scores in one End
- **Match Total**: Sum of all End totals

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Platforms**: iOS, Android

## License

This project is private and not published to pub.dev.
