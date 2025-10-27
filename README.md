# Messaging Mobile App & API

Een moderne mobiele messaging applicatie gebouwd met Flutter (frontend) en C# .NET 8 Web API (backend) met MySQL database.

## 📱 Project Overzicht

Dit project bestaat uit een complete messaging app waarin gebruikers kunnen:
- Registreren en inloggen met JWT authenticatie
- Vrienden toevoegen en beheren
- Privé chatten met vrienden
- Groepschats aanmaken en beheren
- Berichten bewerken en verwijderen
- Profiel beheren en aanpassen

## 🛠️ Tech Stack

### Frontend (Mobile App)
- **Framework:** Flutter
- **Platforms:** Android & iOS
- **State Management:** Provider/Riverpod
- **HTTP Client:** Dio
- **Real-time:** SignalR Client
- **Storage:** Flutter Secure Storage

### Backend (API)
- **Framework:** .NET 8 Web API
- **Database:** MySQL
- **ORM:** Entity Framework Core
- **Authentication:** JWT Tokens
- **Real-time:** SignalR
- **Documentation:** Swagger/OpenAPI

### Database
- **Type:** MySQL
- **Key Tables:** Users, Chats, Messages, Friendships, ChatMembers

## 📁 Project Structure

```
project-mobile-app-and-api/
├── backend/                 # .NET 8 Web API
│   ├── Controllers/
│   ├── Models/
│   ├── Services/
│   ├── Data/
│   └── Program.cs
├── mobile/                  # Flutter App
│   ├── lib/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── models/
│   │   └── widgets/
│   └── pubspec.yaml
├── doc/                     # Documentatie
│   └── User-Stories-en-Epics.md
└── README.md
```

## 🚀 Getting Started

### Prerequisites
- [.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [MySQL Server](https://dev.mysql.com/downloads/mysql/)
- [Visual Studio Code](https://code.visualstudio.com/) of [Visual Studio](https://visualstudio.microsoft.com/)
- [Android Studio](https://developer.android.com/studio) (voor Android development)

### Backend Setup (.NET 8 API)

1. **Navigate naar backend folder:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   dotnet restore
   ```

3. **Database setup:**
   ```bash
   # Update connection string in appsettings.json
   # Run migrations
   dotnet ef database update
   ```

4. **Start de API:**
   ```bash
   dotnet run
   ```

De API draait op: `https://localhost:7000` (HTTPS) en `http://localhost:5000` (HTTP)

### Frontend Setup (Flutter)

1. **Navigate naar mobile folder:**
   ```bash
   cd mobile
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Update API base URL:**
   ```dart
   // In lib/services/api_service.dart
   static const String baseUrl = 'https://localhost:7000/api';
   ```

4. **Run de app:**
   ```bash
   # Voor Android
   flutter run

   # Voor iOS (alleen op macOS)
   flutter run -d ios
   ```

### Database Setup

1. **MySQL Database aanmaken:**
   ```sql
   CREATE DATABASE messaging_app;
   ```

2. **Connection string in appsettings.json:**
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=localhost;Database=messaging_app;Uid=root;Pwd=yourpassword;"
     }
   }
   ```

## 📖 API Documentation

Wanneer de backend draait, is de Swagger documentatie beschikbaar op:
- `https://localhost:7000/swagger`

## 🏗️ Development Workflow

### Branch Strategy
- `main` - Production ready code
- `develop` - Development branch
- `feature/feature-name` - Feature branches
- `bugfix/bug-name` - Bug fix branches

### Parallel Development
- **Backend Team:** Werkt aan API endpoints en database
- **Frontend Team:** Werkt aan UI en API integratie
- **Sync Points:** Wekelijkse meetings en gedeelde API contracts

## 📋 Development Phases

### Fase 1: Basis Setup (Week 1-2)
- [ ] Project structuur
- [ ] Database schema
- [ ] Authenticatie systeem
- [ ] Basis Flutter navigatie

### Fase 2: Core Functionaliteit (Week 3-4)
- [ ] Vrienden systeem
- [ ] Privé messaging
- [ ] Basis UI

### Fase 3: Uitgebreide Features (Week 5-6)
- [ ] Groepschats
- [ ] Real-time messaging
- [ ] Bericht beheer

### Fase 4: Polish & Testing (Week 7-8)
- [ ] Profiel beheer
- [ ] UI/UX improvements
- [ ] Testing en debugging

## 🧪 Testing

### Backend Tests
```bash
cd backend
dotnet test
```

### Frontend Tests
```bash
cd mobile
flutter test
```

## 🔧 Troubleshooting

### Veel voorkomende problemen:

**Backend start niet:**
- Controleer of MySQL server draait
- Controleer connection string
- Run `dotnet ef database update`

**Flutter app kan geen verbinding maken:**
- Controleer API base URL
- Controleer of backend draait
- Controleer firewall/network settings

**Database problemen:**
- Controleer MySQL service status
- Controleer database permissions
- Controleer connection string syntax

## 📚 Documentatie

- [User Stories & Epics](./doc/User-Stories-en-Epics.md)
- [API Documentation](https://localhost:7000/swagger) (tijdens development)
- [Flutter Documentation](https://flutter.dev/docs)
- [.NET 8 Documentation](https://docs.microsoft.com/en-us/dotnet/)

## 🤝 Contributing

1. Fork het project
2. Maak een feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit je changes (`git commit -m 'Add some AmazingFeature'`)
4. Push naar de branch (`git push origin feature/AmazingFeature`)
5. Open een Pull Request

## 👥 Team

- **Backend Developer:** [Naam] - C# .NET API
- **Frontend Developer:** [Naam] - Flutter Mobile App
- **Project Manager:** [Naam] - Planning & Coördinatie

## 📄 License

Dit project is gemaakt voor educatieve doeleinden als onderdeel van een school assignment.

## 🆘 Support

Voor vragen of problemen:
1. Check de documentatie
2. Zoek in bestaande issues
3. Maak een nieuwe issue aan
4. Contact het development team

---

**Happy Coding! 🚀**