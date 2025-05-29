# AppOrderServer

A Node.js RESTful API server using Express, MySQL, JWT authentication, bcrypt for password hashing, Winston for logging, and Prometheus for monitoring. This server allows users to register, log in, and place orders for various products and view them. Admin users can view all orders from all users with optional date filters.

---

## Features

- User registration and login with JWT authentication
- Passwords hashed using bcrypt
-  Role-based access control (admin vs regular users)
- Orders saved to MySQL RDS
- Prometheus metrics at `/metrics`
- Logs stored in `AppOrderServer.log` via Winston
- Admin route for viewing all orders with optional start/end date filtering

---

## Environment Variables

Ensure the following environment variables are set:

```env
RDS_ENDPOINT=your-rds-endpoint
RDS_USER=your-mysql-username
RDS_PASSWORD=your-mysql-password
RDS_NAME=your-database-name
SECRET_KEY=your-secret-key-for-jwt
```

---

## How to Use

1. **Install Node.js dependencies:**

   ```bash
   npm install

2. **Run the application:**

   ```bash
   node path/to/server.js

3. **Verify the server is running:**

   ```bash
   http://localhost:3000