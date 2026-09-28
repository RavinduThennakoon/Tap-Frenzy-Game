# Tap-Frenzy (PlayHub) - Tutorial 4

This is my iOS App Development coursework app. The brief calls it PlayHub, but my Xcode project is named Tap-Frenzy. It combines three game modes (Tap Frenzy, Light It Up and Quiz Rush) inside a tab bar app with Stats, Map and Settings.

**How to run:** Open the project in Xcode [Xcode version], choose an iPhone simulator and press Run. Quiz Rush needs an internet connection. To see pins on the Map tab in the simulator, set Features > Location > Custom Location first.

## Architecture Overview

I used SwiftUI with a `TabView` (Home, Stats, Map, Settings) as the main shell. I split the code into folders so each file has one job:

- **App:** `Tap_FrenzyApp.swift` starts the app, sets the notification delegate, asks for location permission and creates the four tabs.
- **Models:** `GameMode`, `GameSession`, `TriviaQuestion`, `Card` and `Level`. `GameSession` stores the mode, score, time, duration and location. `TriviaQuestion` decodes the Open Trivia DB JSON and shuffles the answers. `Level` holds the grid size and timing for Light It Up.
- **ViewModels:** `QuizRushVM` loads the questions, tracks the question number, score and streak, and decides when the quiz is finished. I kept this logic out of `QuizRushView` so the view only shows the state and the ViewModel owns the rules.
- **Services:** `SessionStore` saves and loads sessions as JSON, `LocationService` handles location permission and the current location, `TriviaService` calls the API, and `NotificationService` and `NotificationDelegate` handle the daily reminder. `String+HTMLDecode` cleans up HTML characters in the questions.
- **Views/Tabs:** `HomeTab`, `StatsTab`, `MapTab` and `SettingsTab`.
- **Views/Games:** `TapFrenzyView`, `LightItUpView` and `QuizRushView`.
- **Views/Shared:** `ResultView`. I created it for the Result screen, but each game currently has its own result screen, so it isn't used in the main flow.

**Data flow:** When a round ends, the game creates a `GameSession` with the mode, score and current location (from `LocationService`) and saves it with `SessionStore.shared.add(...)`. `SessionStore` writes the whole array as JSON to a file in the app's Documents folder. `StatsTab` and `MapTab` both read `SessionStore.shared.sessions`, so they always show the latest results. Best scores for Tap Frenzy and Light It Up and the notification settings are stored with `@AppStorage`.

**Frameworks used:** SwiftUI (all screens), Charts (`Chart` and `BarMark` in `StatsTab`), MapKit (`Map` in `MapTab`), Core Location (`LocationService`), UserNotifications (`NotificationService`), and `ShareLink` (on the result screens for sharing a score).

## Features List

**Game modes**
- **Tap Frenzy:** 10 second round. The button switches between bonus and penalty states, and the score goes up or down depending on which one I tap. It has a best score, a share button and a play again option.
- **Light It Up:** 60 second round with 3 lives. Tiles light up and I tap the lit ones. The level goes up over time with more tiles and shorter lit windows. It has a best score, a share button and retry / home buttons.
- **Quiz Rush:** 10 multiple-choice questions from Open Trivia DB, with a loading state and a retry button if the fetch fails. It shows the question number, score and streak, gives bonus points for streaks of 3 or more, and shows whether each answer was right or wrong.

**Tabs**
- **Home:** cards to open each of the three games.
- **Stats:** total games played, best score per mode, a bar chart of score history and a list of recent games.
- **Map:** pins for every saved session. Tapping a pin or a row shows the mode, score and date. There is an empty state when there are no sessions.
- **Settings:** a switch for the daily challenge notification, a time picker, and a button to reset saved sessions and high scores.

## Known Limitations

- Only Quiz Rush has a proper ViewModel, because that was the Week 3 requirement. The logic for Tap Frenzy and Light It Up is still inside their views. If I had more time I would move it into ViewModels as well.
- If location permission is denied or the location request fails, the session is saved with latitude and longitude 0, 0, so its pin appears in the wrong place on the map.
- Sessions are stored as a JSON file, not in a database. If the file is corrupted, the app prints an error and starts with an empty list.
- Quiz Rush needs internet. Without it the user only gets the error screen and the retry button.
- The HTML decoding only handles a few entities, so some questions may still show odd characters.
- Timer lengths, the number of quiz questions and the Light It Up level settings are hard-coded and can't be changed in the app.
- `ResultView` is not used by the main game flow.

## Reflection

This project taught me how a real iOS app fits together, not just single screens. The hardest part for me was working with the device features, especially Core Location and notifications, because they depend on permissions and the location comes back asynchronously. At first my sessions were saved before the location had arrived, so the map pins showed the wrong place. I fixed it by saving the session inside the location callback. I also learned how async/await works while loading the Quiz Rush questions, and how saving sessions as JSON lets the Stats and Map tabs share the same data. If I did it again, I would use a ViewModel for all three games, not just Quiz Rush, and I would handle the case where location is denied so no wrong pin is saved. I would also test on a real device earlier.