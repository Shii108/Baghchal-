const express = require('express');
const { verifyToken } = require('../middleware/auth');
const { all, get } = require('../database');

const router = express.Router();

// Get all available players (online users excluding current user)
router.get('/available', verifyToken, async (req, res) => {
  try {
    const players = await all(
      `SELECT id, username, wins, losses, status 
       FROM users 
       WHERE id != ? AND status = 'online'
       ORDER BY wins DESC`,
      [req.userId]
    );
    res.json(players);
  } catch (error) {
    console.error('Error getting players:', error);
    res.status(500).json({ error: 'Failed to get players' });
  }
});

// Get player profile
router.get('/:playerId', verifyToken, async (req, res) => {
  try {
    const player = await get(
      'SELECT id, username, wins, losses, status FROM users WHERE id = ?',
      [req.params.playerId]
    );
    if (!player) return res.status(404).json({ error: 'Player not found' });
    res.json(player);
  } catch (error) {
    res.status(500).json({ error: 'Failed to get player' });
  }
});

module.exports = router;
