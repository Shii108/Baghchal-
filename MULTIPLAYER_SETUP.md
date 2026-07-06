# Baghchal Multiplayer Setup Guide

## ✅ Backend Setup Complete!

All backend files have been created in `/server` folder.

### Quick Start - Backend

1. **Install Node.js & npm** (if not installed)
   ```bash
   # macOS (using Homebrew)
   brew install node
   
   # Ubuntu/Debian
   sudo apt-get install nodejs npm
   
   # Windows
   # Download from https://nodejs.org/
   ```

2. **Install backend dependencies:**
   ```bash
   cd server
   npm install
   ```

3. **Setup environment:**
   ```bash
   cp .env.example .env
   # Edit .env and change JWT_SECRET to a strong value
   ```

4. **Run server:**
   ```bash
   npm start              # Production
   npm run dev            # Development with auto-reload (requires nodemon)
   ```

Server will run on `http://localhost:5000`

---

## ✅ Flutter Frontend Updated!

Updated pubspec.yaml with necessary packages.

### Quick Start - Flutter

1. **Update dependencies:**
   ```bash
   flutter pub get
   ```

2. **Connect to backend:**
   - Make sure backend is running on `http://localhost:5000`
   - Update `ApiService.baseUrl` in `lib/services/api_service.dart` if using different URL

3. **Run app:**
   ```bash
   flutter run
   ```

---

## Features Implemented

### Authentication
- ✅ Sign up with username, email, password
- ✅ Login with email & password
- ✅ JWT token storage (secure)
- ✅ Auto logout on app close

### Play with Friend System
- ✅ **Available Players List**: Shows online players with stats (wins/losses)
- ✅ **Challenge Button**: Send game request to any player
- ✅ **Requests Tab**: See incoming challenges
- ✅ **Accept/Deny**: Players can accept or reject requests
- ✅ **Real-time updates**: List refreshes after action

### Game Features
- ✅ Create game sessions
- ✅ Join accepted games
- ✅ Record game moves
- ✅ Track wins/losses

### Home Screen
- ✅ Player profile with stats
- ✅ Game mode selection (AI, Friend, Stats, Settings)
- ✅ Logout button

---

## API Endpoints Reference

### Auth
```
POST   /api/auth/signup         - Create account
POST   /api/auth/login          - Login
GET    /api/auth/me             - Get current user
POST   /api/auth/logout         - Logout
```

### Players
```
GET    /api/players/available   - List online players
GET    /api/players/:playerId   - Get player profile
```

### Friends/Requests
```
POST   /api/friends/request                     - Send challenge
GET    /api/friends/requests                    - Get pending requests
POST   /api/friends/request/:requestId/accept   - Accept challenge
POST   /api/friends/request/:requestId/reject   - Reject challenge
```

### Games
```
POST   /api/game/create              - Create game
GET    /api/game/my-games            - Get active games
POST   /api/game/:gameId/join        - Accept game
POST   /api/game/:gameId/move        - Record move
POST   /api/game/:gameId/end         - End game
```

---

## File Structure

### Backend (`/server`)
```
server/
├── server.js              # Main server file
├── database.js            # SQLite setup
├── package.json           # Dependencies
├── .env.example           # Environment template
├── middleware/
│   └── auth.js            # JWT verification
├── routes/
│   ├── auth.js            # Signup/login
│   ├── players.js         # Available players
│   ├── friends.js         # Request management
│   └── game.js            # Game sessions
└── baghchal.db           # SQLite database (created at runtime)
```

### Flutter (`/lib`)
```
lib/
├── services/
│   └── api_service.dart        # API client
├── screens/
│   ├── login_screen.dart       # Login UI
│   ├── signup_screen.dart      # Signup UI
│   ├── home_screen.dart        # Main menu
│   └── play_with_friend_screen.dart  # Friend requests & player list
└── (existing files)
```

---

## Next Steps (Optional Enhancements)

1. **Real-time game moves** - Use WebSocket (already set up in server)
2. **Game replay** - Record and replay game moves
3. **Leaderboard** - Show top players
4. **Chat** - Message other players
5. **Tournaments** - Organize matches
6. **Mobile notifications** - Alert on incoming requests

---

## Troubleshooting

### Backend won't start
- Check Node.js is installed: `node --version`
- Check port 5000 is not in use: `lsof -i :5000`
- Ensure all dependencies installed: `npm install`

### Flutter can't connect to backend
- Check backend is running: `curl http://localhost:5000/health`
- Update API URL in `api_service.dart` for production
- On Android emulator, use `http://10.0.2.2:5000` instead of localhost

### Database errors
- Delete `server/baghchal.db` to reset
- Check SQLite is installed (included with most systems)

---

## Testing the System

1. **Open 2 browser windows/apps**
2. **First user**: Sign up with "player1@test.com"
3. **Second user**: Sign up with "player2@test.com"
4. **User 1**: Go to "Play with Friend" → see User 2 in Available Players
5. **User 1**: Click "Challenge" button
6. **User 2**: Go to "Requests" tab → see User 1's challenge
7. **User 2**: Click "Accept" or "Deny"
8. **Both**: Now can start playing!

---

Enjoy your multiplayer Baghchal! 🎮
