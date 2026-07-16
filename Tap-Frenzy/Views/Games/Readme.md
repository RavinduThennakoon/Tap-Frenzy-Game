Tap-Frenzy/
  App/
    Tap_FrenzyApp.swift        — entry point, tab bar setup, requests location permission on launch
  Models/
    Card.swift                 — grid cell for Light It Up
    Level.swift                 — difficulty levels for Light It Up
    GameMode.swift               — enum for the 3 game modes
    GameSession.swift            — one completed round (mode, score, time, location)
    TriviaQuestion.swift         — model matching opentdb API response
  ViewModels/
    QuizRushVM.swift             — handles fetching questions, scoring, streaks, loading/error states
  Services/
    TriviaService.swift          — calls opentdb API using async/await
    LocationService.swift        — wraps CLLocationManager
    NotificationService.swift    — wraps UNUserNotificationCenter for daily reminder
    SessionStore.swift            — saves game sessions as JSON file, reads them back
    String+HTMLDecode.swift       — fixes html entities (&quot; etc) coming from the API
  Views/
    Tabs/
      HomeTab.swift               — pick a game mode
      StatsTab.swift                — totals, best scores, chart, recent games
      MapTab.swift                  — shows pins for where I played each game
      SettingsTab.swift             — notification settings, reset data
    Games/
      TapFrenzyView.swift           — week 1 game
      LightItUpView.swift           — week 2 game
      QuizRushView.swift             — week 3 game
    Shared/
      ResultView.swift                — reusable result screen (not fully used yet, see limitations)