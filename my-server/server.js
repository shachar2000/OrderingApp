const express = require('express');
const app = express();
const mysql = require('mysql2');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const client = require('prom-client');
const winston = require('winston');
const SECRET_KEY = process.env.SECRET_KEY;


// Winston logger setup
const logger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.printf(({ level, message, timestamp }) => {
            return `[${timestamp}] ${level.toUpperCase()}: ${message}`;
        })
    ),
    transports: [
        new winston.transports.Console(),
        new winston.transports.File({ filename: 'AppOrderServer.log' })
    ],
});

// Prometheus metrics
const register = new client.Registry();
const httpRequestDurationMicroseconds = new client.Histogram({
    name: 'http_request_duration_seconds',
    help: 'משך זמן תגובה לכל נתיב',
    labelNames: ['method', 'route', 'status_code'],
    buckets: [0.1, 0.3, 0.5, 1, 2, 5]
});
register.registerMetric(httpRequestDurationMicroseconds);
register.setDefaultLabels({ app: 'node-api-server' });
client.collectDefaultMetrics({ register });

// Database connection
const connection = mysql.createConnection({
    host: process.env.RDS_ENDPOINT,
    user: process.env.RDS_USER,
    password: process.env.RDS_PASSWORD,
    database: process.env.RDS_NAME
});

connection.connect((err) => {
    if (err) {
        logger.error('Failed to connect to RDS: ' + err.stack);
        return;
    }
    logger.info('Connected to RDS as ID ' + connection.threadId);
});

app.use(express.json());

app.use((req, res, next) => {
    const end = httpRequestDurationMicroseconds.startTimer();
    res.on('finish', () => {
        end({
            route: req.route?.path || req.path,
            method: req.method,
            status_code: res.statusCode
        });
    });
    next();
});

const createUsersTable = `
    CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        username VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        firstname VARCHAR(255) NOT NULL,
        lastname VARCHAR(255) NOT NULL,
        is_admin BOOLEAN DEFAULT FALSE
    );
`;

const createOrdersTable = `
    CREATE TABLE IF NOT EXISTS orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        computer VARCHAR(255),
        laptop VARCHAR(255),
        galaxy VARCHAR(255),
        iphone VARCHAR(255),
        xiaomi VARCHAR(255),
        watch VARCHAR(255),
        userId INT,
        date DATETIME,
        price DOUBLE,
        FOREIGN KEY (userId) REFERENCES users(id)
    );
`;

connection.query(createUsersTable, (err) => {
    if (err) {
        logger.error("Error creating users table: " + err.message);
        throw err;
    }
    logger.info("Users table created or already exists.");
});

connection.query(createOrdersTable, (err) => {
    if (err) {
        logger.error("Error creating orders table: " + err.message);
        throw err;
    }
    logger.info("Orders table created or already exists.");
});

app.get('/', (req, res) => {
    res.send('השרת פועל!');
});

app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
});

function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    jwt.verify(token, SECRET_KEY, (err, user) => {
        if (err) return res.sendStatus(403);
        req.user = user;
        next();
    });
}

// Middleware חדש לבדיקת הרשאת מנהל
function authorizeAdmin(req, res, next) {
    if (!req.user || !req.user.is_admin) {
        logger.warn(`Access denied for user ID ${req.user ? req.user.id : 'N/A'}: Admin privileges required.`);
        return res.status(403).json({ message: 'גישה נדחתה. נדרשת הרשאת מנהל.' });
    }
    next();
}

app.post('/register', (req, res) => {
    const { email, username, password, firstname, lastname } = req.body;

    if (!email || !username || !password || !firstname || !lastname) {
        logger.warn('Registration failed: Missing required fields');
        return res.status(400).json({ message: 'כל השדות חובה!' });
    }

    connection.query("SELECT * FROM users WHERE email = ? OR username = ?", [email, username], async (err, user) => {
        if (user.length > 0) {
            logger.warn('Registration attempt with existing user/email');
            return res.status(400).json({ message: 'המשתמש או האימייל כבר קיים!' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        connection.query(
            "INSERT INTO users (email, username, password, firstname, lastname) VALUES (?, ?, ?, ?, ?)",
            [email, username, hashedPassword, firstname, lastname],
            (err) => {
                if (err) {
                    logger.error('Registration error: ' + err.message);
                    return res.status(500).json({ message: 'שגיאה בהרשמה', error: err.message });
                }
                logger.info(`User registered successfully: ${username}`);
                res.json({ message: '✅ נרשמת בהצלחה!' });
            }
        );
    });
});

app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        logger.warn('Login failed: Missing email or password');
        return res.status(400).json({ message: 'חובה להזין אימייל וסיסמה!' });
    }

    connection.query("SELECT * FROM users WHERE email = ? OR username = ?", [email, email], async (err, user) => {
        if (err) {
            logger.error("Database error during login: " + err.message);
            return res.status(500).json({ message: 'שגיאת שרת. נסה שוב מאוחר יותר.' });
        }

        if (!user || user.length === 0) {
            logger.warn('Login attempt failed: User not found');
            return res.status(401).json({ message: 'שם משתמש, אימייל או סיסמא שגויים!' });
        }

        const isMatch = await bcrypt.compare(password, user[0].password);
        if (!isMatch) {
            logger.warn('Login attempt failed: Incorrect password');
            return res.status(401).json({ message: 'שם משתמש, אימייל או סיסמא שגויים!' });
        }

        const token = jwt.sign({
            id: user[0].id,
            email: user[0].email,
            firstname: user[0].firstname,
            lastname: user[0].lastname,
            is_admin: user[0].is_admin
        }, SECRET_KEY, { expiresIn: '1h' });

        logger.info(`User logged in successfully: ${email}`);
        res.json({ message: '✅ התחברת בהצלחה!', token, firstname: user[0].firstname, lastname: user[0].lastname, is_admin: user[0].is_admin });
    });
});

app.post('/order', authenticateToken, (req, res) => {
    const orderData = req.body;
    const userId = req.user.id;

    const now = new Date();
    const localDate = new Date(now.getTime() - now.getTimezoneOffset() * 60000);
    const formattedDate = localDate.toISOString().replace('T', ' ').substring(0, 16);

    const query = `
        INSERT INTO orders (computer, laptop, galaxy, iphone, xiaomi, watch, userId, date, price)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const values = [
        orderData["מחשב"],
        orderData["מחשב נייד"],
        orderData["גלקסי"],
        orderData["אייפון"],
        orderData["שיאומי"],
        orderData["שעון"],
        userId,
        formattedDate,
        orderData["מחיר"]
    ];

    connection.query(query, values, (err, result) => {
        if (err) {
            logger.error('Error saving order: ' + err.message);
            return res.status(500).json({ message: 'שגיאה בשמירה', error: err.message });
        }
        logger.info(`Order saved successfully with ID: ${result.insertId}`);
        res.json({ message: '✅ הזמנה התקבלה בהצלחה!', data: orderData });
    });
});

app.get('/orderlist', authenticateToken, (req, res) => {
    const userId = req.user.id;
    connection.query("SELECT * FROM orders WHERE userId = ?", [userId], (err, rows) => {
        if (err) {
            logger.error("Error fetching orders: " + err.message);
            res.status(500).json({ error: err.message });
            return;
        }
        logger.info(`Fetched order list for user ID: ${userId}`);
        res.json(rows);
    });
});

app.get('/admin/all_orders', authenticateToken, authorizeAdmin, (req, res) => {
    const { startDate, endDate } = req.query;

    // 💡 הדפס את מה שהשרת מקבל מהאפליקציה!
    console.log('Received startDate from Flutter:', startDate);
    console.log('Received endDate from Flutter:', endDate);

    let query = "SELECT orders.*, users.username, users.firstname, users.lastname FROM orders JOIN users ON orders.userId = users.id";
    const queryParams = [];

    // בניית תנאי WHERE לסינון לפי תאריכים
    if (startDate && endDate) {
        query += " WHERE orders.date BETWEEN ? AND ?";
        queryParams.push(startDate + ' 00:00:00');
        queryParams.push(endDate + ' 23:59:59');
    } else if (startDate) {
        query += " WHERE orders.date >= ?";
        queryParams.push(startDate + ' 00:00:00'); // תחילת היום הנבחר
    } else if (endDate) {
        query += " WHERE orders.date <= ?";
        queryParams.push(endDate + ' 23:59:59'); // סוף היום הנבחר
    }

    query += " ORDER BY orders.date DESC";

    // 💡 הדפס את השאילתה המלאה והפרמטרים לפני ביצוע השאילתה
    console.log('SQL Query being executed:', query);
    console.log('SQL Query Parameters:', queryParams);

    connection.query(query, queryParams, (err, rows) => {
        if (err) {
            logger.error("Error fetching all orders for admin: " + err.message);
            return res.status(500).json({ error: err.message });
        }
        logger.info(`Admin fetched ${rows.length} orders successfully.`);
        // 💡 הדפס את מספר התוצאות שהוחזרו
        console.log('Number of orders returned by query:', rows.length);
        res.json(rows);
    });
});

app.listen(3000, '0.0.0.0', () => {
    logger.info('Server is running at http://localhost:3000');
});

