const express = require('express');
const app = express();
const mysql = require('mysql2');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const SECRET_KEY = process.env.SECRET_KEY;

const client = require('prom-client');
// יצירת אובייקט שמכיל את כל המדדים
const register = new client.Registry();

// מודד זמן תגובה לכל בקשה
const httpRequestDurationMicroseconds = new client.Histogram({
    name: 'http_request_duration_seconds',
    help: 'משך זמן תגובה לכל נתיב',
    labelNames: ['method', 'route', 'status_code'],
    buckets: [0.1, 0.3, 0.5, 1, 2, 5] // מדוד את הבקשות לפי משך זמן בשניות
});

// רשום את המדד ברשימה
register.registerMetric(httpRequestDurationMicroseconds);

// ברירת מחדל – שם האפליקציה
register.setDefaultLabels({
    app: 'node-api-server'
});

// אסוף מדדים בסיסיים כמו שימוש בזיכרון, CPU וכו'
client.collectDefaultMetrics({ register });


// התחברות לדטא בייס
const connection = mysql.createConnection({
    host: process.env.RDS_ENDPOINT,
    user: process.env.RDS_USER,
    password: process.env.RDS_PASSWORD,
    database: process.env.RDS_NAME
});

// התחברות ל-RDS
connection.connect((err) => {
    if (err) {
        console.error('שגיאה בהתחברות ל-RDS: ' + err.stack);
        return;
    }
    console.log('התחברנו ל-RDS כ-ID ' + connection.threadId);
});

app.use(express.json()); 

app.use((req, res, next) => {
    const end = httpRequestDurationMicroseconds.startTimer(); // התחלת מדידה

    res.on('finish', () => {
        end({
            route: req.route?.path || req.path, // הנתיב (למשל /login)
            method: req.method, // GET, POST וכו'
            status_code: res.statusCode // 200, 401, 500 וכו'
        });
    });

    next(); // ממשיך לבקשה עצמה
});


// יצירת טבלאות ב-RDS
const createUsersTable = `
    CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        username VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        firstname VARCHAR(255) NOT NULL,
        lastname VARCHAR(255) NOT NULL
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

connection.query(createUsersTable, (err, result) => {
    if (err) throw err;
    console.log("Table 'users' created or already exists");
});

connection.query(createOrdersTable, (err, result) => {
    if (err) throw err;
    console.log("Table 'orders' created or already exists");
});

// בדיקה שהשרת פועל
app.get('/', (req, res) => {
    res.send('השרת פועל!');
});

app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics()); // מחזיר את כל המדדים ל-Prometheus
});


// פונקציית אימות טוקן
function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (token == null) return res.sendStatus(401);

    jwt.verify(token, SECRET_KEY, (err, user) => {
        if (err) return res.sendStatus(403);
        req.user = user;
        next();
    });
}

// טיפול בהרשמה
app.post('/register', (req, res) => {
    const { email, username, password, firstname, lastname } = req.body;

    if (!email || !username || !password || !firstname || !lastname) {
        return res.status(400).json({ message: 'כל השדות חובה!' });
    }

    connection.query("SELECT * FROM users WHERE email = ? OR username = ?", [email, username], async (err, user) => {
        if (user.length > 0) {
            return res.status(400).json({ message: 'המשתמש או האימייל כבר קיים!' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        connection.query(
            "INSERT INTO users (email, username, password, firstname, lastname) VALUES (?, ?, ?, ?, ?)",
            [email, username, hashedPassword, firstname, lastname],
            (err, result) => {
                if (err) {
                    return res.status(500).json({ message: 'שגיאה בהרשמה', error: err.message });
                }
                res.json({ message: '✅ נרשמת בהצלחה!' });
            }
        );
    });
});

// טיפול בהתחברות
app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: 'חובה להזין אימייל וסיסמה!' });
    }

    connection.query("SELECT * FROM users WHERE email = ? OR username = ?", [email, email], async (err, user) => {
        if (err) {
            console.error("Database error:", err);
            return res.status(500).json({ message: 'שגיאת שרת. נסה שוב מאוחר יותר.' });
        }

        if (!user || user.length === 0) {
            return res.status(401).json({ message: 'שם משתמש, אימייל או סיסמא שגויים!' });
        }

        const isMatch = await bcrypt.compare(password, user[0].password);
        if (!isMatch) {
            return res.status(401).json({ message: 'שם משתמש, אימייל או סיסמא שגויים!' });
        }

        const token = jwt.sign({ id: user[0].id, email: user[0].email, firstname: user[0].firstname, lastname: user[0].lastname }, SECRET_KEY, { expiresIn: '1h' });
        res.json({ message: '✅ התחברת בהצלחה!', token, firstname: user[0].firstname, lastname: user[0].lastname });
    });
});

// טיפול בהזמנה
app.post('/order', authenticateToken, (req, res) => {
    const orderData = req.body;
    const userId = req.user.id;

    let now = new Date();
    let localDate = new Date(now.getTime() - now.getTimezoneOffset() * 60000);  // מתקן את השעה לפי אזור הזמן המקומי
    let formattedDate = localDate.toISOString().replace('T', ' ').substring(0, 16);

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
            console.error('שגיאה בהכנסת נתונים:', err.message);
            return res.status(500).json({ message: 'שגיאה בשמירה', error: err.message });
        }
        console.log(`ההזמנה נשמרה בהצלחה עם ID: ${result.insertId}`);
        res.json({ message: '✅ הזמנה התקבלה בהצלחה!', data: orderData });
    });
});

// טיפול בהצגת הזמנות
app.get('/orderlist', authenticateToken, (req, res) => {
    const userId = req.user.id;
    connection.query("SELECT * FROM orders WHERE userId = ?", [userId], (err, rows) => {
        if (err) {
            console.error(err.message);
            res.status(500).json({ error: err.message });
            return;
        }
        res.json(rows);
    });
});

// למה השרת מאזין
app.listen(3000, '0.0.0.0', () => {
    console.log(`השרת רץ על http://localhost:3000`);
});
