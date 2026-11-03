# SkillSphere AI 🚀
### AI-Powered Learning & Skill Development Platform

SkillSphere AI is a modern cross-platform Flutter application engineered for continuous self-directed learning. Inspired by leading UI paradigms like *Lumina AI* and *StudyZen*, SkillSphere combines real-time generative AI assistance, adaptive skill roadmap generation, dynamic quizzes, and gamified progress tracking.

---

## ✨ Core Highlights & AI Features

1. **🤖 Lumina AI Learning Companion**
   - Interactive conversational assistant powered by Google Gemini 1.5 Flash (`generativelanguage.googleapis.com`).
   - Markdown rendering with code syntax blocks.
   - Quick one-tap suggested prompt pills ("Explain StatefulWidget", "Clean Architecture in Flutter", etc.).
   - **Zero-Key Offline Fallback**: Works completely offline out of the box with an embedded intelligent engine.

2. **🗺️ Dynamic AI Roadmap Generator**
   - Personalizes a step-by-step career milestones trajectory based on user's target goal, experience level, and committed weekly hours.
   - Interactive checkable milestones with progress percentage computation.

3. **⚡ Adaptive Smart Quizzes**
   - Generates topical multiple-choice questions on demand.
   - Instant response grading with explanation breakdowns.
   - Gamified XP rewards (+50 XP per quiz) and Level progression.

4. **📚 Course Catalog & Curriculum Tracking**
   - Interactive lesson checklists with completed status and duration.
   - Category filtering (AI & ML, Mobile, Frontend, Cloud, Data).
   - Real-time search by skills, title, or keywords.

5. **🎨 Modern UI & Responsive Design**
   - Glassmorphism & gradient accents (Indigo, Cyan, Emerald).
   - Instant Dark Mode & Light Mode switching.
   - Built with Material 3 and Google Fonts (Plus Jakarta Sans).

---

## 🏗️ Architecture & Project Structure

```
skillsphere_ai/
├── pubspec.yaml                 # Dependencies (provider, google_fonts, http, shared_preferences, flutter_markdown)
├── analysis_options.yaml        # Modern Flutter lint rules
├── web/
│   ├── index.html               # Web runner scaffolding
│   └── manifest.json            # PWA manifest
├── test/
│   └── widget_test.dart         # Smoke test suite
└── lib/
    ├── main.dart                # App entry & MultiProvider wiring
    ├── core/
    │   ├── constants/
    │   │   ├── app_colors.dart  # Theme palettes and gradients
    │   │   └── app_theme.dart   # Light and Dark theme specifications
    │   └── services/
    │       ├── gemini_service.dart   # Gemini 1.5 Flash client + offline smart fallback
    │       └── storage_service.dart  # SharedPreferences persistence
    ├── models/
    │   ├── course.dart          # Course and lesson models
    │   ├── roadmap.dart         # Roadmap and milestone models
    │   ├── chat_message.dart    # AI tutor messages & suggestions
    │   ├── quiz.dart            # Quiz questions and evaluations
    │   └── user_profile.dart    # XP, streak, badges, and user stats
    ├── providers/
    │   ├── user_provider.dart   # Profile, XP leveling, theme mode
    │   ├── course_provider.dart # Catalog, search, curriculum checks
    │   ├── roadmap_provider.dart# AI roadmap generation & step tracking
    │   ├── ai_tutor_provider.dart# Conversational chat state
    │   └── quiz_provider.dart   # Active quiz session and score calculation
    ├── screens/
    │   ├── main_nav_screen.dart # 5-tab navigation bar
    │   ├── home/
    │   │   └── home_screen.dart # Daily AI recommendation, hero card, streak
    │   ├── explore/
    │   │   └── explore_screen.dart # Course search & category filter
    │   ├── ai_tutor/
    │   │   └── ai_tutor_screen.dart# Lumina AI tutor with Markdown
    │   ├── roadmap/
    │   │   └── roadmap_screen.dart # Custom career roadmap timeline
    │   ├── quiz/
    │   │   └── quiz_screen.dart # Interactive quiz player & scorecard
    │   └── profile/
    │       └── profile_screen.dart # Badges, stats, Gemini API key switcher
    └── widgets/
        ├── ai_badge.dart        # Glowing AI pill badge
        ├── course_card.dart     # Course card with progress indicator
        └── api_key_dialog.dart  # Modal for free Gemini API key entry
```

---

## 🚀 How to Run the App

### Option A: Run Locally (When Flutter is Installed)

1. Open a terminal in the project root:
   ```bash
   cd skillsphere_ai
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run on your preferred target:
   - **Chrome (Web)**:
     ```bash
     flutter run -d chrome
     ```
   - **Android Device / Emulator**:
     ```bash
     flutter run -d android
     ```
   - **Windows Desktop**:
     ```bash
     flutter run -d windows
     ```

---

### Option B: Run in Online IDEs (No Local Setup Required)

If you don't have Flutter installed on your local PC, you can run this instantly in the cloud:

1. **Google Project IDX** (Recommended):
   - Go to [idx.google.com](https://idx.google.com)
   - Create a Flutter workspace and upload this folder.
   - Project IDX will provide an in-browser Android emulator and web preview instantly.

2. **FlutLab**:
   - Go to [flutlab.io](https://flutlab.io)
   - Click **Create Project** -> **Upload ZIP** of this folder.
   - Click the **Build & Run** button to test the web or APK build online.

---

## 🔑 AI Backend Configuration (Free Google Gemini API)

SkillSphere AI is designed to work **100% offline out-of-the-box** without any configuration. 

To activate live Gemini 1.5 Flash AI generation:
1. Get a free API key at [Google AI Studio](https://aistudio.google.com).
2. Inside the app, tap the **Key Icon** in the top-right of the Dashboard or go to **Profile > Settings > Gemini API Integration**.
3. Paste your key and tap **Save**. The app will immediately switch to live AI streaming!
