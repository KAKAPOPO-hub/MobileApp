import { Router } from "express";
import UsersController from "../../controllers/users/users.controller";
import { authenticate } from "../../middleware/auth.middleware";

const router = Router();

// Get all registered users
router.get('/', authenticate, UsersController.getUsers);

// User : Get all data(posts)
router.get('/me/posts', authenticate, UsersController.getMyPosts);
router.get('/:userId', authenticate, UsersController.getPostsByUserId);

// User : Get data by Id
router.get('/:userId/posts/:postId', authenticate, UsersController.getPostByUser);

export default router;