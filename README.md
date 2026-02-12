# Smart Campus Management System

Flutter (Web/macOS) frontend + Node.js/Express backend with MongoDB, JWT auth, RBAC, and Cloudinary file storage.

## Tech Stack

- **Frontend:** Flutter (Web, macOS)
- **Backend:** Node.js, Express
- **Database:** MongoDB (MongoDB Compass)
- **Auth:** JWT + Role-Based Access Control (RBAC)
- **File storage:** Cloudinary
- **Notifications:** In-app (stored in DB)

## Roles

- **Student:** Profile, attendance view, fee receipts, leave application, certificates upload, timetable, notices, notifications
- **Faculty:** Assigned subjects, mark attendance, timetable, salary slips, leave, notices, notifications
- **Admin:** Manage students/faculty, attendance records, fee receipts & salary slips upload, notices/events, leave approval, expenses, complaints, send notifications

## Setup

### 1. MongoDB

- Install MongoDB and start the service.
- Create database (auto-created on first run): `smartcampusapp`

### 2. Backend

```bash
cd backend
cp .env.example .env   # or use the provided .env with your credentials
npm install
npm run seed           # optional: creates admin, faculty, student test accounts
npm run dev            # or npm start
```

Server runs at `http://localhost:5000`.

**Seed accounts:**

- Admin: `admin@campus.com` / `admin123`
- Faculty: `faculty@campus.com` / `faculty123`
- Student: `student@campus.com` / `student123`

### 3. Frontend

```bash
cd frontend
flutter pub get
flutter run -d chrome   # or flutter run -d macos
```

For web, open `http://localhost:PORT` (Flutter will print the URL).  
API base URL is set to `http://localhost:5000/api` in `lib/core/config/api_config.dart`. Change it if your backend runs elsewhere.

### 4. Environment (backend)

In `backend/.env`:

- `MONGO_URI` – MongoDB connection string (e.g. `mongodb://127.0.0.1:27017/smartcampusapp`)
- `JWT_SECRET` – Secret for JWT signing
- `CLOUDINARY_*` – Cloud name, API key, API secret for file uploads
- `PORT` – Server port (default 5000)

## Project Structure

```
smart-campus-management/
├── frontend/          # Flutter app
│   └── lib/
│       ├── core/      # theme, config, models, services, providers, router
│       └── features/  # auth, student, faculty, admin, shared screens
└── backend/           # Node.js API
    ├── config/
    ├── controllers/
    ├── middleware/
    ├── models/
    ├── routes/
    ├── scripts/       # seed.js
    └── server.js
```

## API Overview

- `POST /api/auth/login` – Login (email, password)
- `GET /api/auth/me` – Current user + profile (requires auth)
- Students: `/api/attendance/my`, `/api/leaves/my`, `/api/files/fee-receipts`, `/api/files/certificates`, etc.
- Faculty: `/api/attendance/students`, `/api/attendance/mark`, `/api/attendance/mark/bulk`, `/api/files/salary-slips`, etc.
- Admin: `/api/users/students`, `/api/users/faculty`, `/api/attendance`, `/api/leaves/all`, `/api/notices`, `/api/files/fee-receipts`, `/api/files/salary-slips`, `/api/expenses`, `/api/complaints/all`, `/api/notifications/admin/*`, `/api/stats/dashboard`, etc.

All protected routes require header: `Authorization: Bearer <token>`.

## UI Theme

Rustic earthy palette:

- Primary: `#8B5E3C`
- Secondary: `#D8CFC4`
- Background: `#F3EADF`
- Accent: `#6B7A4A`
- Text: `#3F4A2C`
