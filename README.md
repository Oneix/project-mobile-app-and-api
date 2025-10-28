# Messaging Mobile App & API

Hallo! Ik ben **Mohammad Aldeeb** en dit is mijn schoolproject voor een moderne mobiele messaging applicatie. Ik bouw deze app met Flutter (frontend) en C# .NET 8 Web API (backend) met een MySQL database.

## 📱 Project Overzicht

Voor mijn school maak ik een complete messaging app waarin gebruikers kunnen:
- Registreren en inloggen met JWT authenticatie
- Vrienden toevoegen en beheren
- Privé chatten met vrienden
- Groepschats aanmaken en beheren
- Berichten bewerken en verwijderen
- Profiel beheren en aanpassen

## 🛠️ Technische Keuzes

Ik heb gekozen voor deze technologieën omdat ze betrouwbaar zijn en goed samenwerken:

### Frontend (Mobiele App)
- **Framework:** Flutter - Voor mooie apps op Android & iOS

### Backend (API)
- **Framework:** .NET 8 Web API - Krachtig en snel
- **Database:** MySQL - Betrouwbare database
- **ORM:** Entity Framework Core
- **Authenticatie:** JWT Tokens voor veiligheid
- **Real-time:** SignalR voor live communicatie
- **Documentatie:** Swagger

### Database
- **Type:** MySQL
- **Belangrijkste Tabellen:** Users, Chats, Messages, Friendships, ChatMembers

## 📁 Project Structuur

Zo wil ik mijn project organiseerd:

```
project-mobile-app-and-api/
├── backend/                 # .NET 8 Web API
│   ├── Controllers/         # API endpoints
│   ├── Models/              # Database modellen
│   ├── Services/            # Business logica
│   ├── Data/                # Database context
│   └── Program.cs           # App startup
├── mobile/                  # Flutter App
│   ├── lib/
│   │   ├── screens/         # App schermen
│   │   ├── services/        # API services
│   │   ├── models/          # Data modellen
│   │   └── widgets/         # Herbruikbare componenten
│   └── pubspec.yaml         # Flutter dependencies
├── doc/                     # Documentatie
│   └── User-Stories-en-Epics.md
└── README.md                # Dit bestand
```