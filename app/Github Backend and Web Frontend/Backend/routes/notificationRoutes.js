import express from 'express';

const router = express.Router();

router.post('/', addNewNotification);

router.get('/', getAllNotifications);

router.patch('/:notificationId', updateNotification);

export default router;