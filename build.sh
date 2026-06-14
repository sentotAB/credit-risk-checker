#!/bin/bash
set -e
git clone https://github.com/flutter.git -b stable --depth 1
flutter/bin/flutter doctor -v
flutter/bin/flutter pub get
flutter/bin/flutter build web --release --base-href /
