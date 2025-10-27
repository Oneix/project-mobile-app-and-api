# User Stories en Epics - Messaging App

## Project Overzicht
Een moderne mobiele messaging app gebouwd met Flutter (frontend) en C# .NET 8 Web API (backend) met MySQL database.

## Epics Overzicht

### Epic 1: Gebruiker Authenticatie
### Epic 2: Vrienden Beheer
### Epic 3: Persoonlijk Chatten
### Epic 4: Groepschat Beheer
### Epic 5: Bericht Beheer
### Epic 6: Profiel Beheer

---

## Epic 1: Gebruiker Authenticatie
**Beschrijving:** Als gebruiker wil ik me kunnen registreren, inloggen en uitloggen zodat ik veilig toegang heb tot de app.

### User Stories - Backend (C# .NET API)

#### US1.1: Gebruiker Registratie API
**Als** backend ontwikkelaar
**Wil ik** een registratie endpoint maken
**Zodat** nieuwe gebruikers een account kunnen aanmaken

**Acceptance Criteria:**
- [ ] POST /api/auth/register endpoint is beschikbaar
- [ ] Vereiste velden: email, gebruikersnaam, wachtwoord
- [ ] Wachtwoord wordt gehashed opgeslagen in MySQL
- [ ] Email validatie controle
- [ ] Gebruikersnaam moet uniek zijn
- [ ] Geeft 201 status terug bij succes
- [ ] Geeft 400 status bij foutieve input
- [ ] Gebruiker wordt opgeslagen in MySQL database

#### US1.2: Gebruiker Inlog API
**Als** backend ontwikkelaar
**Wil ik** een inlog endpoint maken
**Zodat** bestaande gebruikers kunnen inloggen

**Acceptance Criteria:**
- [ ] POST /api/auth/login endpoint is beschikbaar
- [ ] Accepteert email/gebruikersnaam en wachtwoord
- [ ] Wachtwoord verificatie met gehashte versie
- [ ] JWT token wordt gegenereerd bij succesvol inloggen
- [ ] Token heeft 24 uur geldigheid
- [ ] Geeft 200 status + token bij succes
- [ ] Geeft 401 status bij verkeerde gegevens

#### US1.3: Token Validatie API
**Als** backend ontwikkelaar
**Wil ik** JWT tokens kunnen valideren
**Zodat** alleen ingelogde gebruikers toegang hebben

**Acceptance Criteria:**
- [ ] Middleware voor token validatie
- [ ] Controleert of token geldig en niet verlopen is
- [ ] Haalt gebruiker info uit token
- [ ] Geeft 401 status bij ongeldige token
- [ ] Zet gebruiker info in request context

### User Stories - Frontend (Flutter)

#### US1.4: Registratie Scherm
**Als** gebruiker
**Wil ik** me kunnen registreren
**Zodat** ik een nieuw account kan maken

**Acceptance Criteria:**
- [ ] Registratie scherm met velden: email, gebruikersnaam, wachtwoord, bevestig wachtwoord
- [ ] Input validatie (email format, wachtwoord lengte)
- [ ] Wachtwoord en bevestig wachtwoord moeten hetzelfde zijn
- [ ] Loading indicator tijdens registratie
- [ ] Success melding bij succesvol registreren
- [ ] Error meldingen bij foutieve input
- [ ] Link naar inlog scherm

#### US1.5: Inlog Scherm
**Als** gebruiker
**Wil ik** kunnen inloggen
**Zodat** ik toegang krijg tot de app

**Acceptance Criteria:**
- [ ] Inlog scherm met email/gebruikersnaam en wachtwoord velden
- [ ] "Onthoud mij" checkbox optie
- [ ] Loading indicator tijdens inloggen
- [ ] Navigatie naar hoofdscherm bij success
- [ ] Error meldingen bij verkeerde gegevens
- [ ] Link naar registratie scherm

#### US1.6: Automatisch Inloggen
**Als** gebruiker
**Wil ik** automatisch ingelogd worden
**Zodat** ik niet elke keer opnieuw hoef in te loggen

**Acceptance Criteria:**
- [ ] Token wordt lokaal opgeslagen (secure storage)
- [ ] App controleert bij opstarten of token geldig is
- [ ] Automatische navigatie naar hoofdscherm bij geldige token
- [ ] Navigatie naar inlog scherm bij ongeldige/geen token

#### US1.7: Uitlog Functionaliteit
**Als** gebruiker
**Wil ik** kunnen uitloggen
**Zodat** ik veilig kan afsluiten

**Acceptance Criteria:**
- [ ] Uitlog knop in app menu/profiel
- [ ] Token wordt verwijderd uit lokale opslag
- [ ] Navigatie terug naar inlog scherm
- [ ] Bevestiging dialog voor uitloggen

---

## Epic 2: Vrienden Beheer
**Beschrijving:** Als gebruiker wil ik vrienden kunnen toevoegen en verwijderen zodat ik kan chatten met mensen die ik ken.

### User Stories - Backend (C# .NET API)

#### US2.1: Vrienden Toevoegen API
**Als** backend ontwikkelaar
**Wil ik** vrienden kunnen toevoegen
**Zodat** gebruikers connecties kunnen maken

**Acceptance Criteria:**
- [ ] POST /api/friends/add endpoint
- [ ] Accepteert gebruiker ID of gebruikersnaam
- [ ] Controleert of gebruiker bestaat
- [ ] Voorkomt dubbele vriendschappen
- [ ] Voorkomt zichzelf als vriend toevoegen
- [ ] Vriendschap wordt opgeslagen in MySQL
- [ ] Geeft 201 status bij succes
- [ ] Geeft 400/404 status bij fouten

#### US2.2: Vrienden Lijst API
**Als** backend ontwikkelaar
**Wil ik** vrienden lijst kunnen ophalen
**Zodat** gebruikers hun vrienden kunnen zien

**Acceptance Criteria:**
- [ ] GET /api/friends endpoint
- [ ] Geeft lijst van vrienden terug
- [ ] Includeert: gebruiker ID, naam, online status
- [ ] Sorteert op naam (alfabetisch)
- [ ] Geeft lege lijst als geen vrienden
- [ ] Geeft 200 status

#### US2.3: Vrienden Verwijderen API
**Als** backend ontwikkelaar
**Wil ik** vrienden kunnen verwijderen
**Zodat** gebruikers connecties kunnen beëindigen

**Acceptance Criteria:**
- [ ] DELETE /api/friends/{friendId} endpoint
- [ ] Controleert of vriendschap bestaat
- [ ] Verwijdert vriendschap uit database
- [ ] Geeft 200 status bij succes
- [ ] Geeft 404 status als vriendschap niet bestaat

#### US2.4: Gebruikers Zoeken API
**Als** backend ontwikkelaar
**Wil ik** gebruikers kunnen zoeken
**Zodat** mensen nieuwe vrienden kunnen vinden

**Acceptance Criteria:**
- [ ] GET /api/users/search?q={query} endpoint
- [ ] Zoekt op gebruikersnaam en email
- [ ] Geeft lijst van gevonden gebruikers
- [ ] Excludeert huidige gebruiker uit resultaten
- [ ] Toont of gebruiker al vriend is
- [ ] Limiet van 20 resultaten
- [ ] Geeft 200 status

### User Stories - Frontend (Flutter)

#### US2.5: Vrienden Lijst Scherm
**Als** gebruiker
**Wil ik** mijn vrienden kunnen zien
**Zodat** ik weet met wie ik kan chatten

**Acceptance Criteria:**
- [ ] Lijst van alle vrienden
- [ ] Toont naam en online status
- [ ] Pull-to-refresh functionaliteit
- [ ] Zoekbalk om vrienden te filteren
- [ ] Tap op vriend opent chat
- [ ] Loading state tijdens laden
- [ ] Empty state als geen vrienden

#### US2.6: Vriend Toevoegen Scherm
**Als** gebruiker
**Wil ik** nieuwe vrienden kunnen toevoegen
**Zodat** ik met meer mensen kan chatten

**Acceptance Criteria:**
- [ ] Zoekbalk voor gebruikers
- [ ] Lijst met zoekresultaten
- [ ] "Vriend toevoegen" knop per gebruiker
- [ ] Toont al toegevoegde vrienden anders
- [ ] Loading states tijdens zoeken en toevoegen
- [ ] Success/error meldingen
- [ ] Terug knop naar vrienden lijst

#### US2.7: Vriend Verwijderen
**Als** gebruiker
**Wil ik** vrienden kunnen verwijderen
**Zodat** ik mijn contactenlijst kan beheren

**Acceptance Criteria:**
- [ ] Swipe-to-delete op vrienden lijst
- [ ] Of context menu met verwijder optie
- [ ] Bevestiging dialog voor verwijderen
- [ ] Vriend wordt verwijderd uit lijst
- [ ] Error handling als verwijderen mislukt

---

## Epic 3: Persoonlijk Chatten
**Beschrijving:** Als gebruiker wil ik privé kunnen chatten met mijn vrienden zodat we berichten kunnen uitwisselen.

### User Stories - Backend (C# .NET API)

#### US3.1: Chat Aanmaken API
**Als** backend ontwikkelaar
**Wil ik** privé chats kunnen aanmaken
**Zodat** gebruikers kunnen beginnen met chatten

**Acceptance Criteria:**
- [ ] POST /api/chats endpoint
- [ ] Accepteert vriend gebruiker ID
- [ ] Controleert of vriendschap bestaat
- [ ] Maakt nieuwe chat aan of geeft bestaande terug
- [ ] Chat wordt opgeslagen in MySQL
- [ ] Geeft chat ID en details terug
- [ ] Geeft 201 status voor nieuwe chat
- [ ] Geeft 200 status voor bestaande chat

#### US3.2: Chat Lijst API
**Als** backend ontwikkelaar
**Wil ik** actieve chats kunnen ophalen
**Zodat** gebruikers hun gesprekken kunnen zien

**Acceptance Criteria:**
- [ ] GET /api/chats endpoint
- [ ] Geeft lijst van alle chats van gebruiker
- [ ] Includeert: chat ID, andere gebruiker info, laatste bericht, tijd
- [ ] Sorteert op laatste activiteit (nieuwste eerst)
- [ ] Toont ongelezen bericht teller
- [ ] Geeft 200 status

#### US3.3: Berichten Ophalen API
**Als** backend ontwikkelaar
**Wil ik** berichten van een chat kunnen ophalen
**Zodat** gebruikers hun gespreksgeschiedenis kunnen zien

**Acceptance Criteria:**
- [ ] GET /api/chats/{chatId}/messages endpoint
- [ ] Geeft berichten van specifieke chat
- [ ] Paginatie (20 berichten per keer)
- [ ] Sorteert op tijd (oudste eerst)
- [ ] Includeert: bericht ID, inhoud, verzender, tijd, gelezen status
- [ ] Geeft 200 status
- [ ] Geeft 404 als chat niet bestaat

#### US3.4: Bericht Verzenden API
**Als** backend ontwikkelaar
**Wil ik** berichten kunnen verzenden
**Zodat** gebruikers kunnen communiceren

**Acceptance Criteria:**
- [ ] POST /api/chats/{chatId}/messages endpoint
- [ ] Accepteert bericht tekst
- [ ] Valideert bericht lengte (max 1000 karakters)
- [ ] Slaat bericht op in MySQL
- [ ] Update laatste activiteit van chat
- [ ] Geeft bericht details terug
- [ ] Geeft 201 status bij succes
- [ ] SignalR notificatie naar andere gebruiker

### User Stories - Frontend (Flutter)

#### US3.5: Chat Lijst Scherm
**Als** gebruiker
**Wil ik** mijn actieve chats kunnen zien
**Zodat** ik snel gesprekken kan vinden

**Acceptance Criteria:**
- [ ] Lijst van alle chats
- [ ] Toont contact naam en laatste bericht
- [ ] Toont tijd van laatste bericht
- [ ] Ongelezen berichten badge
- [ ] Pull-to-refresh functionaliteit
- [ ] Tap op chat opent gesprek
- [ ] Loading state tijdens laden
- [ ] Empty state als geen chats

#### US3.6: Chat Scherm
**Als** gebruiker
**Wil ik** berichten kunnen zien en verzenden
**Zodat** ik kan communiceren met vrienden

**Acceptance Criteria:**
- [ ] Berichten lijst (scrollable)
- [ ] Eigen berichten rechts, anderen links
- [ ] Tijd stamps bij berichten
- [ ] Tekst input veld onderaan
- [ ] Verzend knop (alleen actief als tekst ingevuld)
- [ ] Auto-scroll naar nieuwste bericht
- [ ] Loading state bij verzenden
- [ ] Keyboard handling
- [ ] Real-time berichten ontvangen

#### US3.7: Real-time Berichten
**Als** gebruiker
**Wil ik** direct nieuwe berichten zien
**Zodat** het aanvoelt als een echt gesprek

**Acceptance Criteria:**
- [ ] SignalR/WebSocket connectie
- [ ] Nieuwe berichten verschijnen direct
- [ ] Typing indicator (optioneel)
- [ ] Online status van contact
- [ ] Gelezen bevestigingen (optioneel)
- [ ] Connectie herstart bij netwerkproblemen

---

## Epic 4: Groepschat Beheer
**Beschrijving:** Als gebruiker wil ik groepschats kunnen aanmaken en beheren zodat ik met meerdere mensen tegelijk kan chatten.

### User Stories - Backend (C# .NET API)

#### US4.1: Groep Aanmaken API
**Als** backend ontwikkelaar
**Wil ik** groepen kunnen aanmaken
**Zodat** gebruikers groepschats kunnen starten

**Acceptance Criteria:**
- [ ] POST /api/groups endpoint
- [ ] Accepteert groep naam en lijst van deelnemers
- [ ] Valideert groep naam (niet leeg, max 50 karakters)
- [ ] Controleert of alle deelnemers vrienden zijn
- [ ] Maker wordt automatisch admin
- [ ] Groep wordt opgeslagen in MySQL
- [ ] Geeft groep details terug
- [ ] Geeft 201 status bij succes

#### US4.2: Groep Leden Beheren API
**Als** backend ontwikkelaar
**Wil ik** groep leden kunnen toevoegen/verwijderen
**Zodat** groep admins groepen kunnen beheren

**Acceptance Criteria:**
- [ ] POST /api/groups/{groupId}/members endpoint (toevoegen)
- [ ] DELETE /api/groups/{groupId}/members/{userId} endpoint (verwijderen)
- [ ] Controleert admin rechten
- [ ] Controleert of toe te voegen gebruiker vriend is
- [ ] Update groep leden in database
- [ ] Geeft updated leden lijst terug
- [ ] Notificaties naar groep over wijzigingen

#### US4.3: Groep Details API
**Als** backend ontwikkelaar
**Wil ik** groep informatie kunnen ophalen
**Zodat** gebruikers groep details kunnen zien

**Acceptance Criteria:**
- [ ] GET /api/groups/{groupId} endpoint
- [ ] Geeft groep naam, leden, admins terug
- [ ] Controleert of gebruiker lid is van groep
- [ ] Includeert lid info (naam, online status)
- [ ] Geeft 200 status bij succes
- [ ] Geeft 403 als niet gemachtigd

#### US4.4: Groep Berichten API
**Als** backend ontwikkelaar
**Wil ik** groep berichten kunnen beheren
**Zodat** groepsleden kunnen communiceren

**Acceptance Criteria:**
- [ ] GET /api/groups/{groupId}/messages endpoint (ophalen)
- [ ] POST /api/groups/{groupId}/messages endpoint (verzenden)
- [ ] Paginatie voor berichten
- [ ] Valideert of gebruiker lid is van groep
- [ ] SignalR notificaties naar alle groepsleden
- [ ] Zelfde functionaliteit als privé berichten

### User Stories - Frontend (Flutter)

#### US4.5: Groep Aanmaken Scherm
**Als** gebruiker
**Wil ik** een groep kunnen aanmaken
**Zodat** ik met meerdere vrienden tegelijk kan chatten

**Acceptance Criteria:**
- [ ] Groep naam input veld
- [ ] Lijst van vrienden met checkboxes
- [ ] Minimaal 2 vrienden selecteren
- [ ] "Maak groep" knop
- [ ] Loading state tijdens aanmaken
- [ ] Navigatie naar groep chat bij succes
- [ ] Error handling

#### US4.6: Groep Chat Scherm
**Als** gebruiker
**Wil ik** in groepen kunnen chatten
**Zodat** ik met meerdere mensen tegelijk kan praten

**Acceptance Criteria:**
- [ ] Zelfde interface als privé chat
- [ ] Toont naam van bericht verzender
- [ ] Groep naam in header
- [ ] Deelnemers knop in header
- [ ] Real-time berichten van alle leden
- [ ] Alle basis chat functionaliteit

#### US4.7: Groep Leden Beheren Scherm
**Als** groep admin
**Wil ik** leden kunnen toevoegen en verwijderen
**Zodat** ik de groep kan beheren

**Acceptance Criteria:**
- [ ] Lijst van huidige groep leden
- [ ] "Lid toevoegen" knop (alleen voor admins)
- [ ] Verwijder optie per lid (alleen voor admins)
- [ ] Vrienden selectie voor toevoegen
- [ ] Bevestiging voor verwijderen
- [ ] Admin badge bij admin gebruikers
- [ ] Real-time updates bij wijzigingen

#### US4.8: Groep Instellingen
**Als** groep admin
**Wil ik** groep instellingen kunnen wijzigen
**Zodat** ik de groep kan aanpassen

**Acceptance Criteria:**
- [ ] Groep naam wijzigen
- [ ] Groep verwijderen optie
- [ ] Admin rechten overdragen
- [ ] Groep verlaten optie (voor alle leden)
- [ ] Bevestigingen voor belangrijke acties
- [ ] Alleen admin kan bepaalde acties uitvoeren

---

## Epic 5: Bericht Beheer
**Beschrijving:** Als gebruiker wil ik berichten kunnen bewerken en verwijderen zodat ik controle heb over mijn communicatie.

### User Stories - Backend (C# .NET API)

#### US5.1: Bericht Bewerken API
**Als** backend ontwikkelaar
**Wil ik** berichten kunnen bewerken
**Zodat** gebruikers hun berichten kunnen aanpassen

**Acceptance Criteria:**
- [ ] PUT /api/messages/{messageId} endpoint
- [ ] Accepteert nieuwe bericht tekst
- [ ] Controleert of gebruiker eigenaar is van bericht
- [ ] Controleert tijdslimiet (5 minuten na verzenden)
- [ ] Update bericht in database met "bewerkt" marker
- [ ] Geeft updated bericht terug
- [ ] SignalR notificatie over bewerking
- [ ] Geeft 200 status bij succes

#### US5.2: Bericht Verwijderen API
**Als** backend ontwikkelaar
**Wil ik** berichten kunnen verwijderen
**Zodat** gebruikers hun berichten kunnen wissen

**Acceptance Criteria:**
- [ ] DELETE /api/messages/{messageId} endpoint
- [ ] Controleert of gebruiker eigenaar is van bericht
- [ ] Soft delete (markeert als verwijderd)
- [ ] Bericht tekst wordt vervangen door "Bericht verwijderd"
- [ ] SignalR notificatie over verwijdering
- [ ] Geeft 200 status bij succes
- [ ] Geeft 404 als bericht niet bestaat

#### US5.3: Bericht Status API
**Als** backend ontwikkelaar
**Wil ik** bericht status kunnen bijhouden
**Zodat** gelezen/ongelezen status werkt

**Acceptance Criteria:**
- [ ] PUT /api/messages/{messageId}/read endpoint
- [ ] Markeert bericht als gelezen voor gebruiker
- [ ] Werkt voor zowel privé als groep chats
- [ ] Update database met gelezen tijd
- [ ] SignalR notificatie naar verzender (optioneel)
- [ ] Geeft 200 status

### User Stories - Frontend (Flutter)

#### US5.4: Bericht Bewerken Interface
**Als** gebruiker
**Wil ik** mijn berichten kunnen bewerken
**Zodat** ik fouten kan corrigeren

**Acceptance Criteria:**
- [ ] Long press op eigen bericht toont context menu
- [ ] "Bewerken" optie in menu (alleen eerste 5 minuten)
- [ ] Bericht wordt bewerkbaar in input veld
- [ ] "Opslaan" en "Annuleren" knoppen
- [ ] Bewerkt bericht toont "(bewerkt)" label
- [ ] Loading state tijdens opslaan
- [ ] Error handling

#### US5.5: Bericht Verwijderen Interface
**Als** gebruiker
**Wil ik** mijn berichten kunnen verwijderen
**Zodat** ik ongewenste berichten kan wissen

**Acceptance Criteria:**
- [ ] Long press op eigen bericht toont context menu
- [ ] "Verwijderen" optie in menu
- [ ] Bevestiging dialog
- [ ] Bericht wordt vervangen door "Bericht verwijderd"
- [ ] Andere gebruikers zien ook verwijderd bericht
- [ ] Loading state tijdens verwijderen
- [ ] Error handling

#### US5.6: Gelezen Status Weergave
**Als** gebruiker
**Wil ik** zien of mijn berichten gelezen zijn
**Zodat** ik weet of iemand mijn bericht heeft gezien

**Acceptance Criteria:**
- [ ] Vinkje iconen bij eigen berichten
- [ ] Enkel vinkje = verzonden
- [ ] Dubbel vinkje = gelezen
- [ ] Automatisch markeren als gelezen bij zien bericht
- [ ] Real-time updates van gelezen status

---

## Epic 6: Profiel Beheer
**Beschrijving:** Als gebruiker wil ik mijn profiel kunnen bekijken en aanpassen zodat ik mijn informatie kan bijwerken.

### User Stories - Backend (C# .NET API)

#### US6.1: Profiel Ophalen API
**Als** backend ontwikkelaar
**Wil ik** gebruiker profielen kunnen ophalen
**Zodat** profiel informatie getoond kan worden

**Acceptance Criteria:**
- [ ] GET /api/users/{userId} endpoint
- [ ] Geeft gebruiker informatie terug (naam, email, bio)
- [ ] Verbergt gevoelige info voor andere gebruikers
- [ ] Eigen profiel toont alle info
- [ ] Geeft 200 status bij succes
- [ ] Geeft 404 als gebruiker niet bestaat

#### US6.2: Profiel Bijwerken API
**Als** backend ontwikkelaar
**Wil ik** gebruiker profielen kunnen bijwerken
**Zodat** gebruikers hun info kunnen aanpassen

**Acceptance Criteria:**
- [ ] PUT /api/users/profile endpoint
- [ ] Accepteert naam, bio, email wijzigingen
- [ ] Valideert input (email format, naam lengte)
- [ ] Controleert unieke email
- [ ] Update database
- [ ] Geeft updated profiel terug
- [ ] Geeft 200 status bij succes

#### US6.3: Wachtwoord Wijzigen API
**Als** backend ontwikkelaar
**Wil ik** wachtwoorden kunnen wijzigen
**Zodat** gebruikers hun wachtwoord kunnen updaten

**Acceptance Criteria:**
- [ ] PUT /api/users/password endpoint
- [ ] Accepteert huidig wachtwoord en nieuw wachtwoord
- [ ] Valideert huidig wachtwoord
- [ ] Hash nieuw wachtwoord
- [ ] Update database
- [ ] Geeft 200 status bij succes
- [ ] Geeft 400 bij verkeerd huidig wachtwoord

### User Stories - Frontend (Flutter)

#### US6.4: Profiel Bekijken Scherm
**Als** gebruiker
**Wil ik** mijn profiel kunnen bekijken
**Zodat** ik mijn informatie kan zien

**Acceptance Criteria:**
- [ ] Toont gebruikersnaam, email, bio
- [ ] Profielfoto placeholder
- [ ] "Bewerken" knop
- [ ] "Wachtwoord wijzigen" knop
- [ ] "Uitloggen" knop
- [ ] Loading state tijdens laden

#### US6.5: Profiel Bewerken Scherm
**Als** gebruiker
**Wil ik** mijn profiel kunnen aanpassen
**Zodat** ik mijn informatie kan bijwerken

**Acceptance Criteria:**
- [ ] Bewerkbare velden voor naam, email, bio
- [ ] Input validatie
- [ ] "Opslaan" en "Annuleren" knoppen
- [ ] Loading state tijdens opslaan
- [ ] Success melding bij opslaan
- [ ] Error handling
- [ ] Terug naar profiel scherm na opslaan

#### US6.6: Wachtwoord Wijzigen Scherm
**Als** gebruiker
**Wil ik** mijn wachtwoord kunnen wijzigen
**Zodat** ik mijn account veilig kan houden

**Acceptance Criteria:**
- [ ] Velden: huidig wachtwoord, nieuw wachtwoord, bevestig nieuw
- [ ] Wachtwoord sterkte indicator
- [ ] Alle velden moeten ingevuld zijn
- [ ] Nieuw wachtwoord en bevestiging moeten hetzelfde zijn
- [ ] "Opslaan" knop
- [ ] Loading state tijdens opslaan
- [ ] Success/error meldingen

---

## Technische Requirements

### Backend (.NET 8 Web API)
- **Database:** MySQL met Entity Framework Core
- **Authenticatie:** JWT tokens
- **Real-time:** SignalR voor live berichten
- **API:** RESTful endpoints
- **Beveiliging:** HTTPS, input validatie, rate limiting

### Frontend (Flutter)
- **Platforms:** Android en iOS
- **State Management:** Provider of Riverpod
- **HTTP Client:** Dio voor API calls
- **Real-time:** SignalR client
- **Storage:** Secure Storage voor tokens
- **UI:** Material Design

### Database Schema (MySQL)
**Belangrijkste tabellen:**
- Users (id, username, email, password_hash, bio, created_at)
- Chats (id, is_group, name, created_at, updated_at)
- ChatMembers (chat_id, user_id, is_admin, joined_at)
- Messages (id, chat_id, sender_id, content, is_edited, is_deleted, sent_at)
- Friendships (user_id, friend_id, created_at)

---

## Development Plan

### Fase 1: Basis Setup (Week 1-2)
- Project structuur opzetten
- Database schema implementeren
- Basis authenticatie (backend + frontend)
- Basis navigatie in Flutter app

### Fase 2: Core Functionaliteit (Week 3-4)
- Vrienden beheer
- Privé chat functionaliteit
- Basis bericht verzenden/ontvangen

### Fase 3: Uitgebreide Features (Week 5-6)
- Groepschats
- Bericht bewerken/verwijderen
- Real-time functionaliteit

### Fase 4: Polish & Testing (Week 7-8)
- Profiel beheer
- UI/UX verbeteren
- Testing en bug fixes
- Documentatie afmaken

---

## Definition of Done

Voor elke User Story:
- [ ] Code is geschreven en werkt
- [ ] Unit tests (waar nodig)
- [ ] API documentatie
- [ ] UI is responsive en gebruiksvriendelijk
- [ ] Error handling is geïmplementeerd
- [ ] Code review is gedaan
- [ ] Getest op beide platforms (Android/iOS)

---

## Risico's en Mitigatie

**Risico:** Real-time functionaliteit is complex
**Mitigatie:** Begin met basis polling, upgrade later naar SignalR

**Risico:** Parallel development sync problemen
**Mitigatie:** Duidelijke API contracts afspreken vooraf

**Risico:** Database performance bij veel berichten
**Mitigatie:** Paginatie en indexing implementeren

**Risico:** Mobile platform specifieke problemen
**Mitigatie:** Regelmatig testen op beide platforms

---

*Dit document is een levend document en wordt bijgewerkt tijdens de ontwikkeling van het project.*