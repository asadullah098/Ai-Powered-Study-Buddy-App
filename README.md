# 📚 AI Study Buddy

An intelligent, AI-powered mobile study companion built with Flutter. Study Buddy leverages advanced AI models to provide personalized learning assistance, real-time explanations, and adaptive study support.

## ✨ Features

- **AI-Powered Learning**: Integration with multiple AI providers (Google Gemini, OpenAI, Anthropic, Ollama)
- **User Authentication**: Secure Firebase authentication system
- **Cloud Sync**: Real-time data synchronization with Firebase Firestore
- **File Storage**: Cloud-based document and resource storage via Firebase Storage
- **Analytics**: Track learning progress with Firebase Analytics
- **Beautiful UI**: Modern Material Design 3 interface
- **Multi-Provider Support**: Flexible AI backend selection for optimal performance
- **Environment Configuration**: Easy setup with environment variables

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.9.2+
- **Backend Services**: Firebase (Auth, Firestore, Storage, Analytics)
- **AI Integration**: 
  - Google Generative AI (Gemini)
  - OpenAI API
  - Anthropic Claude
  - Ollama (Local LLM support)
- **Additional**: HTTP client, Flutter DotEnv for configuration

## 📱 Platform Support

- ✅ iOS
- ✅ Android
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart 3.9.2 or higher
- Firebase account
- AI provider API key (Gemini, OpenAI, or Anthropic)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/study-buddy.git
   cd study-buddy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   Create a `.env` file in the project root:
   ```env
   AI_PROVIDER=gemini  # Options: gemini, openai, anthropic, ollama
   GEMINI_API_KEY=your_gemini_api_key
   OPENAI_API_KEY=your_openai_api_key
   ANTHROPIC_API_KEY=your_anthropic_api_key
   OLLAMA_BASE_URL=http://localhost:11434  # For Ollama
   ```

4. **Configure Firebase**
   - Download your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories:
     - Android: `android/app/`
     - iOS: `ios/Runner/`

5. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Project Structure

```
lib/
├── main.dart                 # App entry point & configuration
├── services/
│   ├── ai_service.dart      # AI provider integration & management
│   └── firebase_service.dart # Firebase backend operations
└── firebase_options.dart    # Firebase configuration

android/                      # Android-specific code
ios/                         # iOS-specific code
web/                         # Web deployment files
windows/                     # Windows desktop support
macos/                       # macOS desktop support
linux/                       # Linux desktop support
```

## 🔐 Security

- **Never commit sensitive data**: API keys and credentials are stored in `.env` files (add to `.gitignore`)
- **Firebase Security Rules**: Configure appropriate Firestore and Storage rules
- **Environment Variables**: Use `flutter_dotenv` for secure credential management

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues, questions, or suggestions, please open an [issue](https://github.com/yourusername/study-buddy/issues) on GitHub.

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Gemini API](https://ai.google.dev/docs)
- [OpenAI API](https://platform.openai.com/docs)

## 🎯 Roadmap

- [ ] Offline mode support
- [ ] Advanced study analytics dashboard
- [ ] Collaborative study sessions
- [ ] Text-to-speech functionality
- [ ] Study plan generation
- [ ] Progress tracking and notifications

---

Made with ❤️ by [Asad Shaikh]
