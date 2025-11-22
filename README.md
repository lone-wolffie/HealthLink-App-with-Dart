# HealthLink App 🏥

A comprehensive mobile health management application that helps users track symptoms, manage medications, book appointments and stay informed about health alerts and health tips.

## SDG Alignment

- **SDG 3:** Good Health & Well-being ->
  Promotes:
  - Early symptom tracking.
  - Access to verified health tips.
  - Connection to nearby clinics and support centers.
  - Community awareness through alerts and tips.


- **SDG 11:** Sustainable Cities and Communities -> helps users locate clinics from anywhere.

## Deployment

**Pitch Deck Link** - https://www.canva.com/design/DAG1qHjYa6E/1lOxKj3Sq4Ckxm7l0M9a-A/edit?utm_content=DAG1qHjYa6E&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton

## Features

### 1. Authentication

- **User SignUp:**
  New users can create an account with their personal details.
- **User Login:** Existing users can securely log into their accounts.

### 2. User profile management

- View and edit your personal details.
- Manage account information.

### 3. Symptom tracking

- **Add symptoms:** Record current symptoms with severity levels (low, medium, high).
- **Symptom history:** View your logged symptoms with timestamps.
- **Delete symptoms:** Remove a symptom if required.

### 3. Appointment management

- **Browse Clinics:** View a list of top clinics with their details and the services they offer.
- **Book appointments:** Schedule appointments at your preferred clinics.
- **View appointments:** See all your booked, completed and cancelled appointments.
- **Reschedule appointments:** Change your appointments by date and time.
- **Cancel appointments:** Cancel appointments using a confirmation dialog.
- **Complete appointments:** Mark appointments as completed after a visit.
- **Clinic contact and location:** Call directly to the clinic and also view its location on the map.

### 4. Medication management

- Add and track your medications.
- Set medication reminders.
- Manage dosage information.

### 5. Health Information

- Health Alerts: View active health alerts and warnings based on severity (low, medium, high) and with their location.
- Health Tips: Access helpful health tips and best practices for better living.

### 6. Notifications

- Appointment reminders 24 hours before scheduled time.
- Medication reminders at scheduled times.

## Technology stack

### Frontend

- **Dart with Flutter:** Cross-platform mobile application framework.
- **Material Design:** Modern, responsive UI components.
- **State Management:** Stateless and StatefulWidget for reactive UI updates.

### Backend

- **Node.js:** JavaScript for server-side logic.
- **Express.js:** Web application framework.
- **RESTful API:** Clean API architecture for client-server communication.

### Database

- **PostgreSQL:** Relational database for data persistence.
- **pg:** PostgreSQL client for Node.js.

### Additional packages

- `shared_preferences`: Local storage for user session.
- `http`: Make REST API calls to your Node.js backend.
- `intl`: Date and time formatting.
- `url_launcher`: Make phone calls and open maps.
- `flutter_local_notifications`: Local notification system.
- `timezone`: Handle timezone conversions.
- `flutter_native_timezone`: Get the device's native timezone and ensures accurate local time detection.
- `image_picker`: Pick images from the gallery and upload a profile picture.
- `path`: For file and directory paths. Used when uploading profile images.
- `device_calendar`: Access the device calendar.

## Project structure

```bash
HEALTHLINK APP WITH DART/
├── backend/
│   ├── config/
│   │   └── db.js
│   ├── controllers/
│   │   ├── appointments.js
│   │   ├── clinics.js
│   │   ├── health_alerts.js
│   │   ├── health_tips.js
│   │   ├── medications.js
│   │   ├── signup_login.js
│   │   ├── symptoms.js
│   │   └── user.js
│   ├── database/
│   │   └── query.sql
│   ├── middleware/
│   │   └── profile_image_upload.js
│   ├── routes/
│   │   ├── appointments.js
│   │   ├── clinics.js
│   │   ├── health_alerts.js
│   │   ├── health_tips.js
│   │   ├── medications.js
│   │   ├── signup_login.js
│   │   ├── symptoms.js
│   │   └── user.js
│   ├── package.json
│   └── server.js
│
├── HealthLink_App_Frontend/
│   ├── lib/
│   │   ├── models/
│   │   │   ├── appointment.dart
│   │   │   ├── clinics.dart
│   │   │   ├── health_alerts.dart
│   │   │   ├── health_tips.dart
│   │   │   ├── medication.dart
│   │   │   ├── symptoms.dart
│   │   │   └── user.dart
│   │   ├── screens/
│   │   │   ├── add_medication_screen.dart
│   │   │   ├── add_symptom_screen.dart
│   │   │   ├── add_tip_screen.dart
│   │   │   ├── alerts_screen.dart
│   │   │   ├── book_appointment_screen.dart
│   │   │   ├── clinics_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── login.dart
│   │   │   ├── medications_screen.dart
│   │   │   ├── my_appointments_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   ├── signup.dart
│   │   │   ├── symptom_history_screen.dart
│   │   │   └── tips_screen.dart
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   └── notification_service.dart
│   │   ├── widgets/
│   │   │   ├── alert_card.dart
│   │   │   ├── clinic_card.dart
│   │   │   ├── custom_app_bar.dart
│   │   │   ├── error_message.dart
│   │   │   ├── loading_indicator.dart
│   │   │   ├── styled_reusable_button.dart
│   │   │   └── text_input_field.dart
│   │   └── main.dart
│   └── pubspec.yaml
│
├── .gitignore
└── README.md

```

## Requirements

### Prerequisites

- Flutter SDK
- Dart SDK
- Node.js
- PostgreSQL

### Backend Setup

1. Clone the repository

```bash
git clone https://github.com/lone-wolffie/HealthLink-App-with-Dart.git

cd HealthLink-App-with-Dart/backend
```

2. Open your code editor and install dependencies

```bash
npm install
```

3. Configure your database. Create a PostgreSQL database and update connection settings in `config/db.js`:

```bash
const db = new pg.Client({
  host: 'localhost',
  port: 5432,
  database: 'HealthCareLinkApp',
  user: 'your_username',
  password: 'your_password'
});
```

4. Run the database

```bash
# Execute SQL schema files to create tables
psql -U your_username -d HealthCareLinkApp -f query.sql
```

5. Start the server

```bash
npm start
# Server runs on http://localhost:3000
```

### Frontend Setup

1. Navigate to Flutter project

```bash
cd HealthLink_App_Frontend
```

2. Install dependencies

```bash
flutter pub get
```

3. Configure API endpoint.
   Update the base URL in `lib/services/api_service.dart`:

```bash
static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:3000/api'; // web
  } else if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api'; // android emulator
  } else if (Platform.isIOS) {
    return 'http://localhost:3000/api'; // iOS Simulator
  } else {
    return 'YOUR_IP:3000/api'; // physical device
  }
}
```

4. Run the app
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices
flutter run -d <device_id>
```

##  Contribution
Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a pull request.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author
Name: Karen Wanjiru.