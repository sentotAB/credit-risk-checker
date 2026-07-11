// web/firebase-messaging-sw.js
// Service worker untuk menerima push notification (FCM) saat tab browser
// tidak aktif/di-background. WAJIB pakai firebase-compat SDK (bukan modular),
// dan versi antara app-compat & messaging-compat harus sama.

importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js');

// PENTING: tanpa dua baris ini, service worker versi baru bisa "nyangkut"
// di state `waiting` selama masih ada tab lama yang terbuka / service
// worker versi sebelumnya tersimpan di browser. Ini bisa membuat
// getToken() di sisi Dart/Flutter menggantung tanpa error yang jelas,
// terutama di browser yang menyimpan cache lebih lama (mis. Edge).
self.addEventListener('install', () => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

// Ganti dengan config yang SAMA persis dengan yang ada di
// lib/firebase_options.dart -> DefaultFirebaseOptions.web
firebase.initializeApp({
  apiKey: 'AIzaSyAfSta5QLfVf_FTauYvYndnXg9UObnVJYs',
  authDomain: 'credit-risk-checker-v1.firebaseapp.com',
  projectId: 'credit-risk-checker-v1',
  storageBucket: 'credit-risk-checker-v1.firebasestorage.app',
  messagingSenderId: '623326298726',
  appId: '1:623326298726:web:16e35ac6eb85396d35a3a7',
});

const messaging = firebase.messaging();

// Handler untuk pesan yang datang saat tab di-background/ditutup.
messaging.onBackgroundMessage((payload) => {
  const notificationTitle =
    payload.notification?.title ?? 'Update Pengajuan Kredit';
  const notificationOptions = {
    body: payload.notification?.body ?? '',
    icon: '/icons/Icon-192.png',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});