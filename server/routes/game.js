const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { verifyToken } = require('../middleware/auth');
const { run, get, all } = require('../database');

const router = express.Router();

// Create game session (invitation)
router.post('/create', verifyToken, async (req, res) => {
  try {
    const { opponent_id } = req.body;

    if (!opponent_id) {
      return res.status(400).json({ error: 'Opponent ID required' });
    }

    const gameId = uuidv4();
    const initialBoardState = JSON.stringify({
      goats: [],
      tigers: [],
      moveCount: 0
    });

    await run(
      `INSERT INTO game_sessions 
       (id, player1_id, player2_id, status, current_turn, board_state) 
       VALUES (?, ?, ?, ?, ?, ?)`,
      [gameId, req.userId, opponent_id, 'waiting', req.userId, initialBoardState]
    );

    res.status(201).json({
      message: 'Game created',
      gameId,
      status: 'waiting'
    });
  } catch (error) {
    console.error('Error creating game:', error);
    res.status(500).json({ error: 'Failed to create game' });
  }
});

// Get active games for current user
router.get('/my-games', verifyToken, async (req, res) => {
  try {
    const games = await all(
      `SELECT * FROM game_sessions 
       WHERE (player1_id = ? OR player2_id = ?) 
       AND status IN ('waiting', 'active')
       ORDER BY created_at DESC`,
      [req.userId, req.userId]
    );
    res.json(games);
  } catch (error) {
    console.error('Error getting games:', error);
    res.status(500).json({ error: 'Failed to get games' });
  }
});

// Join/Accept game
router.post('/:gameId/join', verifyToken, async (req, res) => {
  try {
    const { gameId } = req.params;

    const game = await get('SELECT * FROM game_sessions WHERE id = ?', [gameId]);

    if (!game) {
      return res.status(404).json({ error: 'Game not found' });
    }

    if (game.player2_id && game.player2_id !== req.userId) {
      return res.status(400).json({ error: 'Game already has both players' });
    }

    // Update game to start
    await run(
      'UPDATE game_sessions SET status = ?, player2_id = ?, current_turn = ? WHERE id = ?',
      ['active', req.userId, game.player1_id, gameId]
    );

    res.json({ message: 'Game joined', gameId, status: 'active' });
  } catch (error) {
    console.error('Error joining game:', error);
    res.status(500).json({ error: 'Failed to join game' });
  }
});

// Record game move
router.post('/:gameId/move', verifyToken, async (req, res) => {
  try {
    const { gameId } = req.params;
    const { move } = req.body;

    if (!move) {
      return res.status(400).json({ error: 'Move data required' });
    }

    const game = await get('SELECT * FROM game_sessions WHERE id = ?', [gameId]);

    if (!game) {
      return res.status(404).json({ error: 'Game not found' });
    }

    // Record move
    const moveId = uuidv4();
    await run(
      'INSERT INTO game_moves (id, game_id, player_id, move_data) VALUES (?, ?, ?, ?)',
      [moveId, gameId, req.userId, JSON.stringify(move)]
    );

    // Update board state
    const updatedBoardState = JSON.parse(game.board_state);
    updatedBoardState.moveCount += 1;

    // Toggle turn
    const nextTurn = game.current_turn === game.player1_id ? game.player2_id : game.player1_id;

    await run(
      'UPDATE game_sessions SET board_state = ?, current_turn = ? WHERE id = ?',
      [JSON.stringify(updatedBoardState), nextTurn, gameId]
    );

    res.json({ message: 'Move recorded', moveId });
  } catch (error) {
    console.error('Error recording move:', error);
    res.status(500).json({ error: 'Failed to record move' });
  }
});

// End game (declare winner)
router.post('/:gameId/end', verifyToken, async (req, res) => {
  try {
    const { gameId } = req.params;
    const { winner_id } = req.body;

    const game = await get('SELECT * FROM game_sessions WHERE id = ?', [gameId]);

    if (!game) {
      return res.status(404).json({ error: 'Game not found' });
    }

    // Update game status
    await run(
      'UPDATE game_sessions SET status = ?, winner_id = ? WHERE id = ?',
      ['finished', winner_id, gameId]
    );

    // Update stats
    if (winner_id) {
      await run('UPDATE users SET wins = wins + 1 WHERE id = ?', [winner_id]);

      const loserId = winner_id === game.player1_id ? game.player2_id : game.player1_id;
      await run('UPDATE users SET losses = losses + 1 WHERE id = ?', [loserId]);
    }

    res.json({ message: 'Game ended' });
  } catch (error) {
    console.error('Error ending game:', error);
    res.status(500).json({ error: 'Failed to end game' });
  }
});

module.exports = router;
