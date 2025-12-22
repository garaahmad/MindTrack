# 🧠 MindTrack: AI-Powered Mood & Journaling Assistant

[![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Gemini AI](https://img.shields.io/badge/AI-Google%20Gemini-8E75B2?logo=google-gemini&logoColor=white)](https://deepmind.google/technologies/gemini/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**MindTrack** is a premium, state-of-the-art mental well-being application designed to help users understand their emotional patterns through the power of Generative AI. It transforms traditional journaling into an interactive, data-driven journey toward self-awareness.

---

## 📥 Download

Ready to track your mood? Download the latest Android version here:

[**📲 Download MindTrack APK**](https://drive.google.com/file/d/1jewAg01KfBquNlniepsAAusCaAVdUU2d/view?usp=drive_link)

---

## ✨ Key Features

### 🤖 AI Sentiment Analysis
Every journal entry is processed by **Google Gemini AI** to extract:
- **Mood Title**: A concise 2-4 word summary of your emotional state.
- **Deep Insights**: Personalized AI-generated advice based on your entry content.
- **Sentiment Score**: A normalized metric (0.0 to 1.0) used to drive all visual analytics.

### 📊 Dynamic Mood Analytics
- **Wave Graph View**: A beautiful, custom-painted cubic Bezier curve that illustrates your mood trends over the last 7 days.
- **Percentage Indicators**: Real-time tracking of emotional shifts with positive/negative trending icons.

### 📅 Smart Mood Calendar
A visual heatmap of your month. Each day is color-coded based on your average sentiment:
- 🟢 **Green**: High positive sentiment (>= 0.6).
- 🔴 **Red**: Low/negative sentiment (<= 0.4).
- ⚪ **Neutral**: Balanced mood or no entry.

### 🧭 Explore & AI Assistant
- **AI Chat**: A dedicated space to talk with an AI companion for immediate emotional support.
- **Explore Hub**: Curated content including mindfulness exercises, energy management techniques, and professional mental health articles.

### 🎨 Visual Excellence
- **Premium Dark UI**: Built with a "Glassmorphism" aesthetic, featuring neon-green accents and sleek dark textures.
- **Custom Typography**: Powered by Google Fonts (Manrope & Outfit) for maximum readability.

---

## 🛠️ Technology Stack

- **Core**: Flutter / Dart
- **AI Engine**: Google Gemini Pro (via `flutter_gemini`)
- **Backend (Optional)**: Firebase Auth & Cloud Firestore (Scalable cloud sync enabled)
- **State Management**: Service-based singleton architecture
- **Design Pattern**: Custom Painter & Modular Widget composition

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- A Google Gemini API Key

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/mindtrack.git
    cd mindtrack
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Configure API Keys**
    In `lib/main.dart`, initialize Gemini with your key:
    ```dart
    Gemini.init(apiKey: 'YOUR_GEMINI_API_KEY');
    ```

4.  **Run the application**
    ```bash
    flutter run
    ```

---

## 📂 Project Structure

```text
lib/
├── screens/            # UI Layer (MoodHistory, JournalEntry, Explore, etc.)
├── services/           # Logic Layer (AI Analysis, Local/Cloud Sync)
├── widgets/            # Reusable UI Components & Custom Painters
├── models/             # Data structure for Journal Entries
└── main.dart           # App Entry point & Initialization
```

---

## 🗺️ Roadmap
- [ ] **Persistent Local Storage**: Integrating SQFlite for offline data persistence.
- [ ] **Cloud Backup**: Production-ready Firebase integration with Google Sign-In.
- [ ] **Mood Notifications**: Smart reminders to journal during specific emotional windows.
- [ ] **Voice-to-Journal**: AI-powered transcription for hands-free entries.

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Built with ❤️ for a healthier mind.
</p>
