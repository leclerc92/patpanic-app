# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pat'Panic is an iOS party game built with SwiftUI. It's a timer-based card game where players must guess themes under time pressure across three different rounds with varying rules.

**Tech Stack**: Swift, SwiftUI, AVFoundation, Combine

## Building and Running

This is a standard Xcode project. Build and run using:

```bash
# Open in Xcode
open patpanic.xcodeproj

# Build from command line (if needed)
xcodebuild -project patpanic.xcodeproj -scheme patpanic -configuration Debug build

# Run on simulator
xcodebuild -project patpanic.xcodeproj -scheme patpanic -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## Architecture

### MVVM Pattern

The project follows MVVM with clear separation:
- **Models**: Player, Card, Theme (in `patpanic/models/`)
- **Views**: SwiftUI views (in `patpanic/views/`)
- **ViewModels**: Published properties and logic (in `patpanic/views Models/`)
- **Managers**: Centralized business logic marked with `@MainActor`

### Core Managers (patpanic/managers/)

All managers are `@MainActor` classes and `ObservableObject`:

- **GameManager**: Central game coordinator. Manages game state transitions, player management, and orchestrates other managers. Contains 556 lines (consider refactoring player logic into separate PlayerManager if needed).
- **CardManager**: Loads category JSON files from `Resources/Categories/`, generates cards filtered by round and selected categories, tracks used cards to avoid repetition.
- **AudioManager**: Modern iOS 26 audio system using `AVAudioEngine`, `@Observable`, and Swift Concurrency. Features: sound pools with `AVAudioPlayerNode`, async fade out, automatic interruption handling (calls, Siri), haptic feedback for timer ticks. See `AUDIO_REFACTOR.md` for migration details.
- **TimeManager**: Timer system with callbacks for `onTimeUp` and `onTick`.
- **GameSettingsManager**: Singleton that persists settings to UserDefaults (timers per round, selected categories).

### Game State Machine

GameManager uses an enum-based state machine (`GameState`):
1. `playersSetup` → 2. `roundInstruction` → 3. `playerInstruction` → 4. `playing` → 5. `playerTurnResult` → back to 3 or 6
6. `roundResult` → back to 2 or 7
7. `gameResult`

State transitions are explicit through methods like `goToPlayingView()`, `continueWithNextPlayer()`, `continueWithNextRound()`.

### Round Logic System (patpanic/logics/)

Uses Strategy pattern with a factory:
- **BaseRoundLogic**: Abstract base class implementing `RoundLogicProtocol`
- **FirstRoundLogic, SecondRoundLogic, ThirdRoundLogic**: Round-specific implementations
- **RoundLogicFactory**: Creates appropriate logic instance based on current round

Each logic handles: `setupRound()`, `prepareCards()`, `startTurn()`, `validateCard()`, `passCard()`, `timerFinished()`.

### Error Handling System

Professional typed error system in `utils/ErrorSystem.swift`:
- **PatPanicError**: Top-level enum wrapping specific error types
- Specific error enums: `GameManagerError`, `CardManagerError`, `AudioManagerError`, etc.
- **ErrorHandler**: Singleton with `@Published` properties for UI error alerts
- All errors implement `LocalizedError` with `errorDescription` and `recoverySuggestion`
- Use `Result<T, PatPanicError>` for failable operations
- Extension method: `result.handle(context: "ClassName.method")` logs and shows alerts

Never use `print()`. Use `ErrorHandler.shared.logInfo()`, `.logWarning()`, or `.handle()`.

### Theme and Card System

**Theme** (models/Theme.swift):
- Loaded from JSON files in `Resources/Categories/*.json`
- Properties: `category`, `title`, `colorName`, `excludedRounds: [Int]`
- Method `isAvailableForRound(_ round: Int)` checks if theme can be used in a round

**Card** (models/Card.swift):
- Simple wrapper around `Theme`
- Equality based on theme title only (note: potential collision if two categories have same title)

**CardManager**:
- Caches all category data on init (`initializeCategories()`)
- `generateGameCards(count:category:round:)` filters themes by round, selected categories, and excludes used cards
- Personal cards for Round 3 generated with `generatePlayerCard(for: category)`

### Player Model

**Player** class (reference type):
- Properties track: `name`, `score`, `currentRoundScore`, `currentTurnScore`, `personalCard`, `isMainPlayer`, `hasBeenMainPlayer`, `isEliminated`, `remainingTurn`
- Score methods: `addTurnScore()`, `validateTurn()` (commits turn score to round/total score)
- Identified by UUID for hashing/equality

### Constants

**GameConst** (utils/GameConst.swift):
- `MINPLAYERS = 2`, `MAXPLAYERS = 8` (note: code validates up to 9 in GameManager:184)
- `CARDPERPLAYER = 50` (high value for mobile, consider reducing)

### Round Configuration

Each `Round` enum case (.round1, .round2, .round3) has a `RoundConfig` with:
- `timer: Int` - loaded from GameSettingsManager (default: 45s, 30s, 20s)
- `nbTurns: Int` - number of turns per player
- `rules: [String]` - localized rule descriptions
- `getNbValidatedCardExpected() -> Int` - scoring expectations

## Development Guidelines

### Adding New Features

1. **New Round Logic**: Create subclass of `BaseRoundLogic`, add case to `RoundLogicFactory`
2. **New Manager**: Mark with `@MainActor`, inherit `ObservableObject`, use `@Published` for UI-bound state
3. **New Error Type**: Add case to `PatPanicError`, create specific error enum with `LocalizedError` conformance
4. **New Settings**: Add to `GameSettings` struct and `GameSettingsManager`, persist to UserDefaults

### State Management

- Use `@MainActor` for all UI-related classes
- GameManager methods should call `setState(state:)` explicitly
- Background music auto-manages based on game state (see `setupBackgroundMusic()`)
- Timers automatically clean up critical tick loops on state changes

### Audio System (iOS 26 Modern)

**Architecture:**
- Uses `AVAudioEngine` instead of `AVAudioPlayer` for better performance and control
- `@Observable` macro instead of `ObservableObject` for modern SwiftUI integration
- Async/await for fade effects and tick loops (no more Timer leaks)
- Automatic audio session interruption handling (calls, Siri, headphones)

**Audio Files:**
- Location: `Resources/Audio/`
- Format: MP3
- Preloaded in pools of `AVAudioPlayerNode` for zero-latency playback

**Timer Ticks:**
- Normal (>10s): Haptic feedback (light intensity)
- Urgent (6-10s): Double haptic taps
- Critical (1-5s): Continuous async loop with strong haptics
- Stop loop: `stopCriticalTicks()` cancels the async Task

**Background Music:**
- Plays in all states except `.playing`
- `fadeOutBackgroundMusic(duration:)` is **async** - wrap in Task:
  ```swift
  Task { await audioManager.fadeOutBackgroundMusic(duration: 1.0) }
  ```
- Auto-resumes after interruptions (if system permits)

**Sound Effects:**
- `playValidateCardSound()`, `playPassCardSound()`, `playEndTimer()`, `playRoundResultSound()`
- Volume control per sound
- Pooled players prevent audio cutoff

**Best Practices:**
- Always use Task wrapper for async audio methods
- Haptics are preferred over audio for timer ticks (modern iOS UX)
- Audio session category: `.playback` with `.mixWithOthers`

See `AUDIO_REFACTOR.md` for complete migration guide and performance metrics.

### Category Management

- JSON files in `Resources/Categories/` with structure: `{category, color, themes: [{title, color, excludedRounds}]}`
- CardManager caches all on init
- If adding/modifying categories, call `cardManager.reloadThemes()`
- Selected categories stored in `GameSettingsManager.currentSettings.selectedCategories` (Set<String>)

### Known Issues (from AUDIT_RAPPORT.md)

1. **MAXPLAYERS inconsistency**: GameConst says 8, validation allows 9 (see GameManager:184)
2. **Player init redundancy**: Constructor explicitly sets properties already initialized (Player.swift:34-38)
3. **Card equality**: Only compares theme titles, not categories (Card.swift:18-20)
4. **Large files**: GameManager (556 lines), ScoreCard component (490 lines) - consider splitting
5. **Rules hardcoded**: All rounds use `rules1`, should have distinct `rules2` and `rules3`

### Logging

Use ErrorHandler for all logging:
```swift
errorHandler.logInfo("Message", context: "ClassName.methodName")
errorHandler.logWarning("Message", context: "ClassName.methodName")
errorHandler.handle(error, context: "ClassName.methodName")
```

### Result Type Usage

For operations that can fail:
```swift
func operation() -> Result<ReturnType, PatPanicError> {
    guard condition else {
        return .failure(.cardManager(.noCardsAvailable))
    }
    return .success(value)
}

// Usage with automatic error handling:
let result = cardManager.generateGameCards(count: 10, category: nil, round: 1)
result.handle(context: "ClassName.method") // Logs and shows alert if failure
```

## File Structure

```
patpanic/
├── managers/          # Business logic coordinators (@MainActor)
├── models/            # Data models (Player, Card, Theme)
├── logics/            # Round-specific game logic (Strategy pattern)
├── views/             # SwiftUI view files
├── views Models/      # ViewModels for views
├── components/        # Reusable UI components
│   ├── buttons/
│   ├── game/
│   ├── texts/
│   ├── stats/
│   └── inputs/
├── utils/             # Error system, constants, keyboard utils
└── Resources/
    ├── Audio/         # Sound files
    └── Categories/    # Theme JSON files
```
