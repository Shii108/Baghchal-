require('dotenv').config();
const express = require('express');
const cors = require('cors');
const http = require('http');
const socketIO = require('socket.io');
const db = require('./database');
const authRoutes = require('./routes/auth');
const playerRoutes = require('./routes/players');
const friendRoutes = require('./routes/friends');
const gameRoutes = require('./routes/game');

const app = express();
const server = http.createServer(app);
const io = socketIO(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/players', playerRoutes);
app.use('/api/friends', friendRoutes);
app.use('/api/game', gameRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'Server is running' });
});

// Socket.IO for real-time game
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('join-game', (gameId, userId) => {
    socket.join(gameId);
    io.to(gameId).emit('player-joined', { userId, socketId: socket.id });
  });

  socket.on('game-move', (gameId, move) => {
    io.to(gameId).emit('opponent-move', move);
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Initialize database
db.initialize();

server.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
