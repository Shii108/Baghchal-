const express = require('express');
const { v4: uuidv4 } = require('uuid');
const { verifyToken } = require('../middleware/auth');
const { run, get, all } = require('../database');

const router = express.Router();

// Send friend/game request
router.post('/request', verifyToken, async (req, res) => {
  try {
    const { receiver_id } = req.body;

    if (!receiver_id) {
      return res.status(400).json({ error: 'Receiver ID required' });
    }

    // Check if already requested
    const existingRequest = await get(
      'SELECT id FROM friend_requests WHERE sender_id = ? AND receiver_id = ?',
      [req.userId, receiver_id]
    );

    if (existingRequest) {
      return res.status(400).json({ error: 'Request already sent' });
    }

    // Check if already friends
    const alreadyFriends = await get(
      'SELECT id FROM friends WHERE (user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)',
      [req.userId, receiver_id, receiver_id, req.userId]
    );

    if (alreadyFriends) {
      return res.status(400).json({ error: 'Already friends' });
    }

    const requestId = uuidv4();
    await run(
      'INSERT INTO friend_requests (id, sender_id, receiver_id, status) VALUES (?, ?, ?, ?)',
      [requestId, req.userId, receiver_id, 'pending']
    );

    res.status(201).json({ message: 'Request sent', requestId });
  } catch (error) {
    console.error('Error sending request:', error);
    res.status(500).json({ error: 'Failed to send request' });
  }
});

// Get pending requests for current user
router.get('/requests', verifyToken, async (req, res) => {
  try {
    const requests = await all(
      `SELECT fr.id, fr.sender_id, u.username, u.wins, u.losses, fr.created_at
       FROM friend_requests fr
       JOIN users u ON fr.sender_id = u.id
       WHERE fr.receiver_id = ? AND fr.status = 'pending'
       ORDER BY fr.created_at DESC`,
      [req.userId]
    );
    res.json(requests);
  } catch (error) {
    console.error('Error getting requests:', error);
    res.status(500).json({ error: 'Failed to get requests' });
  }
});

// Accept request
router.post('/request/:requestId/accept', verifyToken, async (req, res) => {
  try {
    const { requestId } = req.params;

    const request = await get(
      'SELECT * FROM friend_requests WHERE id = ? AND receiver_id = ?',
      [requestId, req.userId]
    );

    if (!request) {
      return res.status(404).json({ error: 'Request not found' });
    }

    // Update request status
    await run(
      'UPDATE friend_requests SET status = ? WHERE id = ?',
      ['accepted', requestId]
    );

    // Create friendship both ways
    const friendshipId1 = uuidv4();
    const friendshipId2 = uuidv4();

    await run(
      'INSERT INTO friends (id, user_id, friend_id) VALUES (?, ?, ?)',
      [friendshipId1, req.userId, request.sender_id]
    );

    await run(
      'INSERT INTO friends (id, user_id, friend_id) VALUES (?, ?, ?)',
      [friendshipId2, request.sender_id, req.userId]
    );

    res.json({ message: 'Request accepted' });
  } catch (error) {
    console.error('Error accepting request:', error);
    res.status(500).json({ error: 'Failed to accept request' });
  }
});

// Reject request
router.post('/request/:requestId/reject', verifyToken, async (req, res) => {
  try {
    const { requestId } = req.params;

    const request = await get(
      'SELECT * FROM friend_requests WHERE id = ? AND receiver_id = ?',
      [requestId, req.userId]
    );

    if (!request) {
      return res.status(404).json({ error: 'Request not found' });
    }

    await run(
      'UPDATE friend_requests SET status = ? WHERE id = ?',
      ['rejected', requestId]
    );

    res.json({ message: 'Request rejected' });
  } catch (error) {
    console.error('Error rejecting request:', error);
    res.status(500).json({ error: 'Failed to reject request' });
  }
});

module.exports = router;
