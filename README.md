# Home Fundi

Home Fundi is a Flutter service marketplace for Tricom Technologies backed by a PHP API and MySQL database. It supports three roles:

- Customer: create, track, cancel and rate appliance repair requests.
- Technician: view available jobs, accept jobs, update job status and view ratings.
- Admin: manage users, technician approvals, appliances, repair requests and reports.

## Project Layout

- `lib/` - Flutter app source using Material 3, Provider, and HTTP API services.
- `api/` - PHP endpoints for authentication, users, appliances, requests, jobs, ratings and reports.
- `database/home_fundi.sql` - MySQL schema and seed data.
- `docs/SETUP.md` - setup and testing instructions.

## MySQL Data

The app uses these MySQL tables:

- `users`
- `appliances`
- `repair_requests`
- `ratings`
- `notifications`

Run `database/home_fundi.sql` in MySQL to create the database and seed demo accounts, appliances, repair requests, ratings and notifications.

Customers can register themselves from the login screen. Technician accounts are created by admins from the Manage Technicians screen and stored in MySQL through the PHP API.

The Flutter app reads the API base URL from `HOME_FUNDI_API_URL` at build time. If unset, it uses `http://127.0.0.1/Home-Fundi/api`.
