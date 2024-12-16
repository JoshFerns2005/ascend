const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const cors = require('cors');

const prisma = new PrismaClient();
const app = express();
const PORT = 3000;
const JWT_SECRET = "311f1e1490d39bf17bdbaf881ed26ecbb964c7559b6c997c6238dd2c05b75605";
app.use(cors()); // This allows your frontend to communicate with the backend

app.use(bodyParser.json());

// Root Route
app.get('/', (req, res) => {
  res.send('Server is running!');
});

// Middleware to verify JWT
const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1]; // Extract the token
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET); // Decode the token
    console.log('Decoded Token:', decoded); // Log the decoded token to check its contents
    req.userId = decoded.userId; // Attach userId to the request
    next();
  } catch (error) {
    console.error('JWT Verification Error:', error.message); // Log the error if decoding fails
    return res.status(403).json({ error: 'Invalid token' });
  }
};

// Endpoint to get user details
app.get('/user', verifyToken, async (req, res) => {
  try {
    console.log('Received User ID:', req.userId); // Log the userId before querying the database

    const user = await prisma.users.findUnique({
      where: { id: req.userId }, // Querying user based on userId
      select: { name: true },
    });

    if (!user) {
      console.error('User not found for ID:', req.userId); // Log if user is not found
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user); // Respond with user details
  } catch (error) {
    console.error('Error Fetching User Details:', error.message); // Log the error
    res.status(500).json({ error: 'Failed to fetch user details' });
  }
});



// Check if database connection is working
app.get('/check-db', async (req, res) => {
  try {
    // Check if the connection to the database works
    await prisma.$queryRaw`SELECT 1`;  // Raw SQL query to test DB connection
    res.status(200).json({ success: true, message: 'Database connected successfully!' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Database connection failed', error: error.message });
  }
});

// Signup Endpoint
app.post('/signup', async (req, res) => {
  const { name, email, password } = req.body; // Get name, email, and password from the request

  // Validate the request body
  if (!name || !email || !password) {
    return res.status(400).json({ error: "Name, email, and password are required" });
  }

  // Hash the password
  const hashedPassword = await bcrypt.hash(password, 10);

  try {
    // Create the user in the database (use 'Users' model)
    const user = await prisma.users.create({
      data: {
        name,
        email,
        password: hashedPassword,
      },
    });

    // Return a response with the user data
    res.json({ success: true, user });
  } catch (error) {
    // Handle error (e.g., duplicate email)
    res.status(400).json({ error: "Email already exists" });
  }
});

// Login Endpoint
app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await prisma.users.findUnique({ where: { email } });
  if (!user) return res.status(404).json({ error: "User not found" });

  const validPassword = await bcrypt.compare(password, user.password);
  if (!validPassword) return res.status(401).json({ error: "Invalid password" });

  const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '1h' });
  res.json({ success: true, token });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
