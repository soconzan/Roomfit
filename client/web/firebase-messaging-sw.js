/* eslint-disable no-undef */

importScripts(
  "https://www.gstatic.com/firebasejs/10.8.1/firebase-app-compat.js",
);
importScripts(
  "https://www.gstatic.com/firebasejs/10.8.1/firebase-messaging-compat.js",
);

firebase.initializeApp({
  apiKey: "AIzaSyC02vdkGUDVtGSUZZuZ8pcspcFOXeXBlHc",
  appId: "1:737910084682:web:11cc8d3938c0715a2a82b3",
  messagingSenderId: "737910084682",
  projectId: "roomfit-dffa0",
  authDomain: "roomfit-dffa0.firebaseapp.com",
  storageBucket: "roomfit-dffa0.firebasestorage.app",
  measurementId: "G-83FH7ZPLQD",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  self.registration.showNotification(payload.notification?.title ?? "RoomFit", {
    body: payload.notification?.body ?? "",
  });
});
