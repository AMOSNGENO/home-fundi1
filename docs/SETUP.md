# Home Fundi MySQL Setup Guide

## 1. Database

1. Create the MySQL database and seed data:

```sql
SOURCE database/home_fundi.sql;
```

2. Confirm the credentials in `api/config.php` match your local MySQL server:

```php
const DB_HOST = '127.0.0.1';
const DB_NAME = 'home_fundi';
const DB_USER = 'root';
const DB_PASS = '';
```

## 2. PHP API

Serve the `api/` folder with Apache, Nginx, XAMPP, WAMP, Laragon or PHP's built-in server.

The Flutter app defaults to:

```text
http://127.0.0.1/Home-Fundi/api
```

That default works when Apache/XAMPP/WAMP serves this project at `Home-Fundi` under the web root, for example `htdocs/Home-Fundi/api`.

If you run PHP's built-in server from the project root instead, the API URL is different:

```powershell
php -S 127.0.0.1:8000
C:\flutter\bin\flutter.bat run --dart-define=HOME_FUNDI_API_URL=http://127.0.0.1:8000/api
```

Override it at run/build time when needed:

```powershell
C:\flutter\bin\flutter.bat run --dart-define=HOME_FUNDI_API_URL=http://127.0.0.1/Home-Fundi/api
```

For Android emulator testing, use your machine address, commonly:

```powershell
C:\flutter\bin\flutter.bat run --dart-define=HOME_FUNDI_API_URL=http://10.0.2.2/Home-Fundi/api
```

If you are using PHP's built-in server with the Android emulator, use:

```powershell
C:\flutter\bin\flutter.bat run --dart-define=HOME_FUNDI_API_URL=http://10.0.2.2:8000/api
```

## 3. Demo Accounts

- Customer: `customer@test.com` / `password123`
- Technician: `tech@test.com` / `password123`
- Admin: `admin@test.com` / `admin123`
- Vendor: `vendor@test.com` / `password123`

## 4. Run Flutter

From the project root:

```powershell
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat run
```

## 5. Workflow

1. Register or log in as a customer.
2. Create a repair request.
3. If an approved available technician exists, the API assigns the least busy technician.
4. Log in as the technician to accept available jobs or update assigned job status.
5. Complete the job, then log in as customer to rate the technician.
6. Log in as admin to review stats, users, technicians, appliances, requests and reports.
