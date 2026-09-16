import { Request, Response } from "express";
import { ZodError } from "zod";
import { 
  createPostSchema, 
  postIdSchema, 
  updatePostParamsSchema, 
  updatePostSchema 
} from "../../validations/post.validations";
import { db } from "../../config/db";
import { categoriesTable, postsTable, usersTable } from "../../config/schema";
import { and, desc, eq, like, or } from "drizzle-orm";
import { 
  uploadToCloudinary, 
  deleteFromCloudinary 
} from "../../services/cloudinary.service";
import { AuthRequest } from "../../middleware/auth.middleware";


export class PostsController {
    createPost = async (req: AuthRequest, res: Response) => {
        try {
            // 1. validation
            const validatedData = createPostSchema.parse(req.body);
        const { title, content, categoryId } = validatedData;
        const userId = req.user?.id;

        if (!userId) {
          return res.status(401).json({
            success: false,
            message: "User belum terautentikasii",
          });
        }

            let imageUrl: string | undefined;
            let imagePublicId: string | undefined;
            // 2. Jika ada file yang di-upload, kirim ke Cloudinary
            if (req.file) {
                const uploadResult = await uploadToCloudinary(req.file.buffer);
                imageUrl = uploadResult.secure_url;
                imagePublicId = uploadResult.public_id;
            }
            // 3. Create New Post
            const [insertedPost] = await db.insert(postsTable).values({ userId, title, content, categoryId, imageUrl, imagePublicId, }).$returningId();
            // 4. Ambil Post yg baru di buat tadi
            const newPost = await db.query.postsTable.findFirst({ where: eq(postsTable.id, insertedPost.id) });
            // 5. Tampilkan dalam API
            return res.status(201).json({
                success: true,
                message: "Post created successfully",
                data: {
                    post: newPost,
                },
            });
        } catch (error) {
            console.error("Create post error:", error);

          if (error instanceof ZodError) {
            return res.status(400).json({
              success: false,
              message: "Data post tidak valid",
              errors: error.issues,
            });
          }

            return res.status(500).json({
                success: false,
                message:
                    "Terjadi kesalahan pada server",
                error: error instanceof Error
                    ? error.message
                    : error,
            });
        }
    };

    //READ
    //GUEST
    // GUEST

    getPosts = async (req: Request, res: Response) => {
    try {
        const posts = await db
          .select({
            id: postsTable.id,
            userId: postsTable.userId,
            title: postsTable.title,
            content: postsTable.content,
            categoryId: postsTable.categoryId,
            imageUrl: postsTable.imageUrl,
            imagePublicId: postsTable.imagePublicId,
            status: postsTable.status,
            createdAt: postsTable.createdAt,
            updatedAt: postsTable.updatedAt,
            authorId: usersTable.id,
            authorUsername: usersTable.username,
            categoryName: categoriesTable.name,
          })
          .from(postsTable)
          .leftJoin(usersTable, eq(postsTable.userId, usersTable.id))
          .leftJoin(categoriesTable, eq(postsTable.categoryId, categoriesTable.id))
          .where(and(
            eq(postsTable.status, "published"),
            req.query.search
              ? or(
                  like(postsTable.title, `%${String(req.query.search)}%`),
                  like(postsTable.content, `%${String(req.query.search)}%`),
                  like(usersTable.username, `%${String(req.query.search)}%`),
                )
              : undefined,
            req.query.category && req.query.category !== "All"
              ? eq(categoriesTable.name, String(req.query.category))
              : undefined,
          ))
          .orderBy(desc(postsTable.createdAt));

        const postsWithAuthors = posts.map(({ authorId, authorUsername, categoryName, ...post }) => ({
          ...post,
          author: authorId == null || authorUsername == null
            ? null
            : {
                id: authorId,
                username: authorUsername,
              },
                  category: categoryName == null ? null : { name: categoryName },
        }));

        return res.status(200).json({
        success: true,
        message: "Get Posts Successfully",
        data: {
            posts: postsWithAuthors
        }
        });
    } catch (error) {
        console.error("Create post error:", error);
        return res.status(500).json({
        success: false,
        message:
            "Terjadi kesalahan pada server",
        error: error instanceof Error
            ? error.message
            : error,
        });
    }
    };


    //GUEST : BY ID 
    // GUEST : Get Post By ID
    getPostById = async (req: Request, res: Response) => {
    try {
        const validatedParams = postIdSchema.parse(req.params);
        const { id } = validatedParams;

        const [post] = await db.select().from(postsTable).where(
        and(
            eq(postsTable.id, id),
            eq(postsTable.status, "published")
        )
        );

        if (!post) {
        return res.status(404).json({
            success: false,
            message: "Post not found"
        });
        }

        return res.status(200).json({
        success: true,
        message: "Post retrieved successfully",
        data: {
            post
        }
        });
    } catch (error) {
        console.error("Get post error:", error);
        return res.status(500).json({
        success: false,
        message: "Terjadi kesalahan pada server",
        error: error instanceof Error ? error.message : error
        });
    }
    };

    updatePost = async (req: AuthRequest, res: Response) => {
  try {
    const { id } = updatePostParamsSchema.parse(req.params);
    const body = updatePostSchema.parse(req.body);

    const existingPost = await db
      .select()
      .from(postsTable)
      .where(eq(postsTable.id, id));

    if (!existingPost[0]) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      });
    }

    if (existingPost[0].userId !== req.user?.id) {
      return res.status(403).json({
        success: false,
        message: "Unauthorized to update this post",
      });
    }

    let imageUrl = existingPost[0].imageUrl;
    let imagePublicId = existingPost[0].imagePublicId;

    if (req.file) {
      if (imagePublicId) {
        await deleteFromCloudinary(imagePublicId);
      }
      imageUrl = req.file.path;
      imagePublicId = req.file.filename;
    }

    await db
      .update(postsTable)
      .set({
        ...body,
        imageUrl,
        imagePublicId,
        updatedAt: new Date(),
      })
      .where(eq(postsTable.id, id));

    const updatedPost = await db
      .select()
      .from(postsTable)
      .where(eq(postsTable.id, id));

    // 8. RESPONSE
    return res.status(200).json({
      success: true,
      message: "Post updated successfully",
      data: {
        post: updatedPost,
      },
    });
  } catch (error: any) {
    console.error("Update post error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};


// DELETE
deletePost = async (req: AuthRequest, res: Response) => {
  try {
    // Validate the id before loading any post data.
    const validatedParams = postIdSchema.parse(req.params);
    const { id } = validatedParams;
    const userId = req.user?.id;

    if (!userId) {
      return res.status(401).json({
        success: false,
        message: "User belum terautentikasi",
      });
    }

    const existingPost = await db.query.postsTable.findFirst({
      where: eq(postsTable.id, id),
    });

    if (!existingPost) {
      return res.status(404).json({
        success: false,
        message: "Post not found",
      });
    }

    if (existingPost.userId !== userId) {
      return res.status(403).json({
        success: false,
        message: "Anda hanya dapat menghapus post milik sendiri",
      });
    }

    await db.delete(postsTable).where(eq(postsTable.id, id));

    if (existingPost.imagePublicId) {
      try {
        await deleteFromCloudinary(existingPost.imagePublicId);
      } catch (error) {
        console.error("Cloudinary cleanup error:", error);
      }
    }

    return res.status(200).json({
      success: true,
      message: "Post permanently deleted successfully",
    });
  } catch (error: any) {
    console.error("Delete post error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};
 
}



export default new PostsController();