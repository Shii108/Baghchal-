# Baghchal Backend Server

Node.js/Express backend for multiplayer Baghchal game with real-time gameplay via WebSockets.

## Setup

1. **Install dependencies:**
   ```bash
   cd server
   npm install
   ```

2. **Create .env file:**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and change JWT_SECRET to a strong value.

3. **Start server:**
   ```bash
   npm start      # Production mode
   npm run dev    # Development mode with auto-reload
   ```

Server runs on `http://localhost:5000`

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user (requires token)
- `POST /api/auth/logout` - Logout user

### Players
- `GET /api/players/available` - List online players
- `GET /api/players/:playerId` - Get player profile

### Friend Requests
- `POST /api/friends/request` - Send game request
- `GET /api/friends/requests` - Get pending requests
- `POST /api/friends/request/:requestId/accept` - Accept request
- `POST /api/friends/request/:requestId/reject` - Reject request

### Games
- `POST /api/game/create` - Create game session
- `GET /api/game/my-games` - Get active games
- `POST /api/game/:gameId/join` - Join/accept game
- `POST /api/game/:gameId/move` - Record game move
- `POST /api/game/:gameId/end` - End game

## Database

SQLite database (`baghchal.db`) is automatically created with tables:
- `users` - Player accounts
- `friend_requests` - Game requests
- `friends` - Accepted friendships
- `game_sessions` - Active games
- `game_moves` - Game history

## Real-Time Events (WebSocket)

Connected via Socket.IO on same server:
- `join-game` - Join specific game
- `player-joined` - New player joined
- `game-move` - Opponent's move
- `disconnect` - Player disconnected
