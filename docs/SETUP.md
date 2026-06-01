# Home Fundi Setup Guide

## 1. Install XAMPP or WAMP

1. Install XAMPP or WAMP with Apache, PHP 8+, and MySQL.
2. Start Apache and MySQL from the control panel.
3. Open phpMyAdmin at `http://localhost/phpmyadmin`.

## 2. Create the Database

1. In phpMyAdmin, choose Import.
2. Select `database/home_fundi.sql`.
3. Run the import. It creates the `home_fundi` database, tables, sample appliances, sample users and mock repair data.
4. If you imported the database before the appliance catalog was expanded, import `database/migrations/2026_05_31_seed_home_appliances.sql` too.
5. If you already imported the database before mock repair data was added, import `database/migrations/2026_06_01_seed_mock_repair_data.sql`.

Sample accounts:

- Customer: `customer@test.com` / `password123`
- Technician: `tech@test.com` / `password123`
- Admin: `admin@test.com` / `admin123`

The seeded technician account is approved so you can test automatic assignment immediately.
Mock requests are included across pending, accepted, in-progress, completed and cancelled states, with different preferred times for testing request lists and job screens.

## 3. Install the PHP API

1. Copy the `api` folder to your web root:
   - XAMPP: `C:\xampp\htdocs\home_fundi_api`
   - WAMP: `C:\wamp64\www\home_fundi_api`
2. Open `api/config.php` inside that copied folder.
3. Set your database credentials:

```php
const DB_HOST = '127.0.0.1';
const DB_NAME = 'home_fundi';
const DB_USER = 'root';
const DB_PASS = '';
```

4. Test in a browser: `http://localhost/home_fundi_api/appliances.php`.

Every endpoint returns JSON:

```json
{"status":"success","message":"...","data":{}}
```

Protected endpoints require the token returned by login:

```http
Authorization: Bearer YOUR_TOKEN
```

## 4. Configure Flutter

1. Install Flutter and Android Studio.
2. From the project root, run:

```powershell
C:\flutter\bin\flutter.bat pub get
```

3. Set the API URL only if the automatic default does not match your device:
   - Web, Windows, macOS, Linux, iOS simulator: `http://localhost/home_fundi_api`
   - Android emulator: `http://10.0.2.2/home_fundi_api`
   - Physical device: `http://YOUR_PC_LAN_IP/home_fundi_api`
   - Override at run time with `--dart-define=API_BASE_URL=http://YOUR_PC_LAN_IP/home_fundi_api`

4. Android internet permission is already included in `android/app/src/main/AndroidManifest.xml`.
5. The in-app map uses OpenStreetMap tiles through `flutter_map`, so no Google Maps API key is required. The device must have internet access for map tiles to load.

## 5. Run the App

```powershell
C:\flutter\bin\flutter.bat run
```

Login redirects by role:

- Customer opens the customer dashboard.
- Approved technician opens the technician dashboard.
- Admin opens the admin dashboard.

## 6. Test the Full Workflow

1. Login as customer and create a repair request.
2. The backend automatically assigns the least busy approved technician.
3. Login as technician and open My Jobs.
4. Update status to in progress, then completed.
5. Login as customer and rate the completed job.
6. Login as admin and review dashboard stats, all requests and reports.

## 7. API Endpoint List

Public:

- `POST /login.php`
- `POST /register.php`
- `GET /appliances.php`

Customer:

- `POST /repair_request.php`
- `GET /my_requests.php?customer_id=X`
- `GET /request_status.php?request_id=X`
- `POST /cancel_request.php`
- `POST /add_rating.php`
- `GET /technicians.php`

Technician:

- `GET /available_jobs.php`
- `POST /accept_job.php`
- `GET /my_jobs.php?technician_id=X`
- `POST /update_job_status.php`
- `GET /my_ratings.php`
- `POST /technician_profile.php`

Admin:

- `GET /admin/dashboard_stats.php`
- `GET /admin/users.php`
- `POST /admin/approve_technician.php`
- `DELETE /admin/delete_user.php`
- `GET /admin/repair_requests.php`
- `POST /admin/assign_technician.php`
- `POST /admin/add_appliance.php`
- `PUT /admin/update_appliance.php`
- `DELETE /admin/delete_appliance.php`
- `GET /admin/reports.php`
