# SUBSIDIA Cashier (POS Application)

Aplikasi POS / Kasir untuk ekosistem **SUBSIDIA (Smart Subsidized Fuel Ecosystem)**.

## 🛠️ Langkah Menjalankan Aplikasi

### 1. Sinkronisasi Port Android (ADB Reverse)
Sebelum menjalankan aplikasi di Emulator Android, sambungkan port local agar request localhost dapat diteruskan:
```bash
adb reverse tcp:8080 tcp:8080
```

### 2. Dapatkan Dependensi Flutter
```bash
flutter pub get
```

### 3. Jalankan Aplikasi (Pilihan Environment API)

*   **Mode Staging / Produksi (Default)**
    Menghubungkan secara otomatis ke server staging cloud:
    ```bash
    flutter run
    ```

*   **Mode Localhost (Development)**
    Gunakan flag `--dart-define=USE_LOCALHOST=true` untuk mengarahkan koneksi ke localhost backend (`http://localhost:8080/api/v1`):
    ```bash
    flutter run --dart-define=USE_LOCALHOST=true
    ```

*   **Custom API URL**
    Menggunakan custom IP atau port tertentu:
    ```bash
    flutter run --dart-define=SUBSIDIA_API_BASE_URL=http://10.0.2.2:8080/api/v1
    ```
