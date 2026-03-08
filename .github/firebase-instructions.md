# Firebase Architecture - Archery Training App

## Overview

This document outlines the Firebase architecture for the Archery Training App, including database structure, security rules, and implementation guidelines.

---

## Firebase Services

| Service | Purpose | Status |
|---------|---------|--------|
| **Authentication** | Phone auth | ✅ Implemented |
| **Cloud Firestore** | User profiles, matches, scores | ⏳ Pending |
| **Cloud Storage** | Profile images | ⏳ Pending |
| **Cloud Functions** | Rankings calculation, stats aggregation | ⏳ Pending |

---

## Firestore Database Structure

### Users Collection
```
users/{userId}
├── uid: string                  // Firebase Auth UID
├── phone: string                // Phone number (+976XXXXXXXX)
├── username: string             // Display name
├── photoUrl: string             // Cloud Storage URL
├── createdAt: timestamp         // Account creation date
├── totalMatches: number         // Total completed matches
├── avgAccuracy: number          // Overall average accuracy (%)
└── bestScore: number            // Highest single match score
```

### Matches Collection (Multiplayer Support)
```
matches/{matchId}
├── code: string                 // 6-character join code "A7X92K"
├── creatorId: string            // Who created the match
├── name: string                 // Match name
├── matchType: string            // 'Range', 'Moving Object', 'Horseback', 'Long Distance', 'Dynamic Shooting'
├── mode: string                 // 'solo' | 'multiplayer'
├── scoringMode: string          // 'self' | 'judge' (who enters scores)
├── ends: number                 // Number of ends
├── arrowsPerEnd: number         // Arrows per end
├── totalArrows: number          // Total arrows (ends × arrowsPerEnd)
├── maxPossibleScore: number     // totalArrows × 10
├── status: string               // 'waiting' | 'in_progress' | 'completed'
├── createdAt: timestamp         // Match creation time
├── startedAt: timestamp?        // When match started (null if waiting)
└── completedAt: timestamp?      // Match end time (null if not completed)

    └── participants/            // Subcollection for all participants
        └── {userId}
            ├── userId: string
            ├── username: string
            ├── photoUrl: string?
            ├── joinedAt: timestamp
            ├── scores: array<int>           // All arrow scores [10, 9, 8, ...]
            ├── endScores: array<int>        // Completed end totals [27, 25, ...]
            ├── currentEndArrows: array<int> // Arrows in current end (in progress)
            ├── totalScore: number
            ├── accuracy: number             // (totalScore / maxPossibleScore) × 100
            ├── currentEnd: number           // Which end they're on (1-indexed)
            ├── isComplete: bool             // Finished all ends?
            └── rank: number?                // Final ranking (set on completion)
```

### Rankings Collection (Denormalized for Performance)
```
rankings/{matchType}/users/{userId}
├── username: string
├── photoUrl: string
├── avgAccuracy: number          // Average accuracy for this match type
├── totalMatches: number         // Matches in this category
├── bestScore: number            // Best score in this category
└── lastUpdated: timestamp
```

---

## Cloud Storage Structure

```
users/
└── {userId}/
    └── profile.jpg              // Profile image (max 2MB)
```

---

## Security Rules

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check authentication
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users Collection
    match /users/{userId} {
      // Anyone authenticated can read user profiles
      allow read: if isAuthenticated();
      
      // Only the user can write their own profile
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if false; // No deletion allowed
    }
    
    // Matches Collection
    match /matches/{matchId} {
      // Anyone authenticated can read matches (for joining)
      allow read: if isAuthenticated();
      
      // Anyone can create a match
      allow create: if isAuthenticated() && 
                       request.resource.data.creatorId == request.auth.uid;
      
      // Only creator can update match settings (start, complete)
      allow update: if isAuthenticated() && 
                       resource.data.creatorId == request.auth.uid;
      
      // Only creator can delete match
      allow delete: if isAuthenticated() && 
                       resource.data.creatorId == request.auth.uid;
      
      // Participants Subcollection
      match /participants/{oderId} {
        // All authenticated users can read participants (for scoreboard)
        allow read: if isAuthenticated();
        
        // Can join if match is 'waiting'
        allow create: if isAuthenticated() && 
                         request.auth.uid == oderId &&
                         get(/databases/$(database)/documents/matches/$(matchId)).data.status == 'waiting';
        
        // Can update own scores OR creator can update all (judge mode)
        allow update: if isAuthenticated() && (
                         request.auth.uid == oderId ||
                         get(/databases/$(database)/documents/matches/$(matchId)).data.creatorId == request.auth.uid
                       );
        
        // Can leave if match hasn't started
        allow delete: if isAuthenticated() && 
                         request.auth.uid == oderId &&
                         get(/databases/$(database)/documents/matches/$(matchId)).data.status == 'waiting';
      }
    }
    
    // Rankings Collection (Read-only, updated by Cloud Functions)
    match /rankings/{matchType}/users/{userId} {
      allow read: if isAuthenticated();
      allow write: if false; // Only Cloud Functions can write
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{fileName} {
      // Users can read any profile image
      allow read: if request.auth != null;
      
      // Users can only write their own profile image
      allow write: if request.auth.uid == userId
                   && request.resource.size < 2 * 1024 * 1024  // Max 2MB
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## Multiplayer Match System

### Match Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| **Solo** | Single player, no join code | Personal training |
| **Multiplayer** | Multiple players, join code | Competitions |

### Scoring Modes

| Mode | Description | Who Enters Scores |
|------|-------------|-------------------|
| **Self** | Each participant enters own scores | Casual matches |
| **Judge** | Creator/Judge enters all scores | Official competitions |

### Match Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                      MATCH LIFECYCLE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. CREATE (status: 'waiting')                             │
│     • Creator sets match parameters                        │
│     • System generates 6-char JOIN CODE                    │
│     • Creator auto-joins as participant                    │
│                                                             │
│  2. WAITING                                                │
│     • Others join via code                                 │
│     • Real-time participant list updates                   │
│     • Creator sees all joined players                      │
│                                                             │
│  3. START (Creator clicks Start)                           │
│     • status → 'in_progress'                               │
│     • startedAt → serverTimestamp()                        │
│     • No more joins allowed                                │
│                                                             │
│  4. SCORING (Independent + Real-time Display)              │
│     • Each participant scores at their own pace            │
│     • No waiting for others - fully independent            │
│     • Everyone sees all end scores in real-time            │
│     • Live leaderboard updates via Firestore snapshots     │
│                                                             │
│  5. COMPLETE                                               │
│     • All participants finish all ends                     │
│     • status → 'completed'                                 │
│     • completedAt → serverTimestamp()                      │
│     • Final rankings calculated                            │
│     • Stats updated in user profiles                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Scoring Flow (Option 1: Independent with Real-time End Scores)

**How it works:**
- Everyone enters scores independently at their own pace
- No turns, no waiting for others
- All participants see everyone's end scores in real-time

**Live Scoreboard Example:**
```
┌──────────────────────────────────────────────────────────────────────┐
│                    LIVE MATCH SCOREBOARD                             │
│                    Match: Weekend Practice                           │
├──────────────────────────────────────────────────────────────────────┤
│                        End 1   End 2   End 3   End 4   End 5   TOTAL │
├──────────────────────────────────────────────────────────────────────┤
│  🥇 Player A           27      28      26      🏹...    -       81   │
│  🥈 Player C           25      29      25      24       -       103  │
│  🥉 Player B           24      26      🏹...    -        -       50   │
│  4. Player D           22      23      21      20       -       86   │
├──────────────────────────────────────────────────────────────────────┤
│  🏹 = Currently shooting    - = Not started yet                     │
└──────────────────────────────────────────────────────────────────────┘
```

**Data Structure for End Scores:**
```
participants/{userId}
├── endScores: [27, 28, 26, ...]     // Completed end totals
├── currentEndArrows: [10, 9, ...]   // Arrows in current end (in progress)
├── currentEnd: 4                     // Which end they're on (1-indexed)
└── isComplete: false                 // Finished all ends?
```

**Real-time Update Flow:**
```
Player A shoots arrow → Updates currentEndArrows → 
Completes end → Calculates end total → 
Moves to endScores array → Increments currentEnd →
All other players see update instantly via snapshot
```

### Join Code System

```dart
// Generate 6-character alphanumeric code (no ambiguous chars)
String generateJoinCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No I,O,0,1
  final random = Random();
  return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
}
```

### Real-time Listeners

```dart
// Listen to match status changes
Stream<MatchModel> watchMatch(String matchId) {
  return FirebaseFirestore.instance
    .collection('matches')
    .doc(matchId)
    .snapshots()
    .map((doc) => MatchModel.fromFirestore(doc));
}

// Listen to all participants (real-time scoreboard)
Stream<List<ParticipantModel>> watchParticipants(String matchId) {
  return FirebaseFirestore.instance
    .collection('matches')
    .doc(matchId)
    .collection('participants')
    .orderBy('totalScore', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => ParticipantModel.fromFirestore(doc))
      .toList());
}
```

---

## Implementation Phases

### Phase 1: User Profile ✅ Priority
1. Add `cloud_firestore` and `firebase_storage` packages
2. Create `FirestoreService` for database operations
3. Create `StorageService` for image uploads
4. Implement profile setup flow:
   - Upload profile image to Storage
   - Create user document in Firestore
   - Navigate to home screen

### Phase 2: Solo Match (Single Player)
1. Create match document when starting new match
2. Add creator as first participant
3. Update scores in real-time
4. Calculate accuracy on completion
5. Update user's total stats

### Phase 3: Multiplayer Match
1. Generate join code on match creation
2. Implement join by code flow
3. Real-time participant list (waiting room)
4. Start match (lock joining)
5. Real-time scoreboard with snapshots
6. Handle match completion

### Phase 4: History
1. Query user's participated matches
2. Filter by match type, date range
3. Display match details and rankings

### Phase 5: Global Rankings
1. Create Cloud Function triggered on match completion
2. Aggregate stats per match type
3. Update rankings collection
4. Query rankings with pagination

---

## Flutter Service Layer Structure

```
lib/
├── core/
│   └── services/
│       ├── auth_service.dart       // Firebase Auth wrapper
│       ├── firestore_service.dart  // Firestore operations
│       ├── storage_service.dart    // Cloud Storage operations
│       └── match_service.dart      // Match & multiplayer operations
├── models/
│   ├── user_model.dart
│   ├── match_model.dart
│   ├── participant_model.dart
│   └── ranking_model.dart
```

---

## Data Models

### UserModel
```dart
class UserModel {
  final String uid;
  final String phone;
  final String username;
  final String? photoUrl;
  final DateTime createdAt;
  final int totalMatches;
  final double avgAccuracy;
  final int bestScore;
}
```

### MatchModel
```dart
class MatchModel {
  final String id;
  final String code;              // Join code (null for solo)
  final String creatorId;
  final String name;
  final String matchType;
  final String mode;              // 'solo' | 'multiplayer'
  final String scoringMode;       // 'self' | 'judge'
  final int ends;
  final int arrowsPerEnd;
  final int totalArrows;
  final int maxPossibleScore;
  final String status;            // 'waiting' | 'in_progress' | 'completed'
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
}
```

### ParticipantModel
```dart
class ParticipantModel {
  final String userId;
  final String username;
  final String? photoUrl;
  final DateTime joinedAt;
  final List<int> scores;           // All arrow scores
  final List<int> endScores;        // Completed end totals
  final List<int> currentEndArrows; // Arrows in current end (in progress)
  final int totalScore;
  final double accuracy;
  final int currentEnd;             // Which end they're on (1-indexed)
  final bool isComplete;            // Finished all ends?
  final int? rank;                  // Final ranking
}
```

---

## Firebase Console Setup Checklist

- [ ] Enable Phone Authentication
- [ ] Add test phone numbers for development
- [ ] Create Firestore database (production mode)
- [ ] Deploy Firestore security rules
- [ ] Create Cloud Storage bucket
- [ ] Deploy Storage security rules
- [ ] Create composite index for matches (creatorId + status)
- [ ] Create composite index for participants (totalScore desc)
- [ ] (Phase 5) Deploy Cloud Functions

---

## Environment Setup

### Required Packages
```yaml
dependencies:
  firebase_core: ^4.5.0
  firebase_auth: ^6.2.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
```

### iOS Configuration
- Minimum deployment target: iOS 15.0
- URL Schemes configured in Info.plist

### Android Configuration
- google-services.json in android/app/
- SHA-1 fingerprint added to Firebase Console

---

## Security Best Practices

1. **Never commit** `google-services.json`, `GoogleService-Info.plist`, or `firebase_options.dart` to Git
2. **API Key Restrictions**: Restrict keys by app identifier and API in Google Cloud Console
3. **Test Numbers**: Use Firebase test phone numbers during development
4. **Validate Data**: Always validate input data before writing to Firestore
5. **Rate Limiting**: Implement rate limiting in Cloud Functions
