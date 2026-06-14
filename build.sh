#!/bin/bash
set -e  # Kalau ada error, langsung stop biar nggak buang waktu

echo "Downloading Flutter SDK..."
git clone https://github.com/flutter.git -b stable --depth 1

echo "Set PATH..."
export PATH="$PATH:$(pwd)/flutter/bin"

echo "Flutter doctor..."
flutter doctor -v

echo "Get packages..."
flutter pub get

echo "Build Web..."
flutter build web --release --base-href /

echo "Build Selesai! Folder ada di build/web"
