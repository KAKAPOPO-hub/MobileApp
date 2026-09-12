import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth/auth.route";
import authRouter from './routes/auth/auth.route';
import postsRouter from './routes/posts/posts.route';
import userRouter from "./routes/users/users.route"


const app = express();
const port = 5000;
    
// CORS Configuration
app.use(cors({
  origin: "http://localhost:3000", // atau "*" untuk allow semua
  credentials: true,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(express.json()); 


app.use("/api/auth", authRoutes);
app.use('/api/v1/auth', authRouter);
app.use('/api/v1/posts', postsRouter);
app.use('/api/v1/users', userRouter);

app.get("/", (req, res) => {
    res.send("Hello, World!");
});

app.listen(port, () => {
    console.log(`⚡️[server]: Server is running at http://localhost:${port}`);
});










