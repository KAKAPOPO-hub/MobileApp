import { Request, Response } from "express";
import { AuthRequest } from "../../middleware/auth.middleware";
import { userIdSchema, userPostParamsSchema } from "../../validations/post.validations";
import {db}from "../../config/db";
import { postsTable, usersTable } from "../../config/schema";
import { and, desc, eq } from "drizzle-orm";

export class UsersController {
  getMyPosts = async (req: AuthRequest, res: Response) => {
    try {
      const userId = req.user?.id;
      if (!userId) {
        return res.status(401).json({
          success: false,
          message: "User belum terautentikasi",
        });
      }

      const posts = await db
        .select()
        .from(postsTable)
        .where(eq(postsTable.userId, userId))
        .orderBy(desc(postsTable.createdAt));

      return res.status(200).json({
        success: true,
        message: "User posts retrieved successfully",
        data: { posts },
      });
    } catch (error) {
      console.error("Get my posts error:", error);
      return res.status(500).json({
        success: false,
        message: "Terjadi kesalahan pada server",
      });
    }
  };

  getUsers = async (_req: Request, res: Response) => {
    try {
      const users = await db
        .select({
          id: usersTable.id,
          username: usersTable.username,
          email: usersTable.email,
          role: usersTable.role,
          createdAt: usersTable.createdAt,
        })
        .from(usersTable);

      return res.status(200).json({
        success: true,
        message: "Users retrieved successfully",
        data: { users },
      });
    } catch (error) {
      console.error("Get users error:", error);
      return res.status(500).json({
        success: false,
        message: "Internal server error",
      });
    }
  };

  // Get all posts by user ID
  getPostByUser = async (req: Request, res: Response) => {
    try {
      const validateParams = userIdSchema.parse(req.params);
      const { userId } = validateParams;

      const posts = await db
        .select()
        .from(postsTable)
        .where(eq(postsTable.userId, userId))
        .orderBy(desc(postsTable.createdAt));

      return res.status(200).json({
        success: true,
        message: "Post fetched successfully",
        data: {
          posts,
        },
      });
    } catch (error) {
      console.error("Get posts error:", error);
      return res.status(500).json({
        success: false,
        message: "Terjadi kesalahan pada server",
        error: error instanceof Error ? error.message : error,
      });
    }
  };

  // Get post detail by user ID & post ID
  getPostsByUserId = async (req: Request, res: Response) => {
  try {
    const validatedParams = userIdSchema.parse(req.params);

    const { userId } = validatedParams;

    const posts = await db
      .select()
      .from(postsTable)
      .where(
        and(
          eq(postsTable.userId, userId),
          eq(postsTable.status, "published")
        )
      )
      .orderBy(desc(postsTable.createdAt));

    return res.status(200).json({
      success: true,
      message: "User posts retrieved successfully",
      data: {
        posts,
      },
    });
  } catch (error: any) {
    console.error(
      "Get posts by user ID error:",
      error
    );

    return res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};
}

export default new UsersController();