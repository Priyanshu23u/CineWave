# CineWave - Movie Booking App

CineWave is a Flutter-based movie booking application that allows users to browse movies, book tickets, and manage their bookings seamlessly. With an intuitive UI and a smooth booking process, CineWave enhances the movie-going experience.

## Features

- **User Authentication** (Sign Up, Login, Logout)
- **Movie Listings** with details
- **Ticket Booking** with QR Code verification
- **Booking History** for past bookings
- **User Profile Management**
- **Notifications & Alerts**
- **Payment Methods Integration**
- **Dark/Light Theme Support**

## Note
In lib/services/constant.dart file , Enter your publishable key and Secret key, which will be availiable on signing on "https://stripe.com/"

## Tech Stack

### Frontend:
- **Flutter** (Dart)
- **Provider** (State Management)

### Backend:
- **Firebase** (Authentication, Firestore)
- **Shared Preferences** (Local Storage)
- **QR Code Scanner** for ticket verification

## Installation & Setup

1. **Clone the repository:**
   ```sh
   git clone https://github.com/Priyanshu23u/CineWave.git
   ```
2. **Navigate to the project folder:**
   ```sh
   cd CineWave
   ```
3. **Install dependencies:**
   ```sh
   flutter pub get
   ```
4. **Run the app:**
   ```sh
   flutter run
   ```

## Usage

- Register/Login to the app.
- Browse available movies.
- Select a movie and book a ticket.
- Use the QR code for verification at the theater.
- View booking history and manage your profile.

## Screenshots

![Login Screen](images/signin.png)
![Movie Listings](images/icon.png)

