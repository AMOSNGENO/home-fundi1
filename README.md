# Home Fundi

Home Fundi is a Flutter, PHP and MySQL service platform for Tricom Technologies. It supports three roles:

- Customer: create, track, cancel and rate appliance repair requests.
- Technician: view available jobs, accept jobs, update job status and view ratings.
- Admin: manage users, technician approvals, appliances, repair requests and reports.

## Project Layout

- `lib/` - Flutter app source using Material 3, Provider, http and shared_preferences.
- `api/` - PHP REST API endpoints. Copy this folder to your web server as `home_fundi_api`.
- `database/home_fundi.sql` - MySQL schema, seed appliances, sample accounts and mock repair data.
- `docs/SETUP.md` - full setup and testing instructions.

## Sample Accounts

- Customer: `customer@test.com` / `password123`
- Technician: `tech@test.com` / `password123` (approved by default)
- Admin: `admin@test.com` / `admin123`

The database seed also includes mock requests across pending, accepted, in-progress, completed and cancelled states.

Update `lib/utils/constants.dart` to point the Flutter app to your API base URL.
