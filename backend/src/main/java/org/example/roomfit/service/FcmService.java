package org.example.roomfit.service;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Notification;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.roomfit.domain.FcmToken;
import org.example.roomfit.repository.FcmRepository;
import org.example.roomfit.repository.UserRepository;
import org.springframework.stereotype.Service;
import com.google.firebase.messaging.Message;

@Service
@AllArgsConstructor
@Slf4j
public class FcmService {

    final FcmRepository fcmRepository;
    final UserRepository userRepository;
    final FirebaseMessaging firebaseMessaging;

    public void saveFcmToken(String username, String fcmToken) {
        // FCM 토큰 저장 로직 구현
        log.info("saveFcmToken called: username={}, fcmToken={}", username, fcmToken);
        userRepository.findByUsername(username).ifPresent(user -> {
            log.info("User found for username={}: userId={}", username, user.getUserId());
            FcmToken existingToken = null;
            try{
                existingToken = fcmRepository.findByUserId(user.getUserId());
            } catch (Exception e) {
                log.error("Error finding FCM token for userId={}: {}", user.getUserId(), e.getMessage());
            }
            if (existingToken != null) {
                log.info("FCM 토큰 업데이트: username={}, oldToken={}, newToken={}", username, existingToken.getToken(), fcmToken);
                existingToken.setToken(fcmToken);
                fcmRepository.save(existingToken);
            } else {
                log.info("FCM 토큰 신규 저장: username={}, fcmToken={}", username, fcmToken);
                fcmRepository.save(new FcmToken(user, fcmToken));
            }
        });
    }

    public void deleteFcmToken(String username) {
        // FCM 토큰 삭제 로직 구현
        userRepository.findByUsername(username).ifPresent(user -> {
            FcmToken existingToken = fcmRepository.findByUserId(user.getUserId());
            if (existingToken != null) {
                fcmRepository.delete(existingToken);
            }
        });
    }

    // FCM 알림 전송 메소드
    public void sendFcmNotification(String username, String title, String message) {
        // FCM 토큰 조회
        userRepository.findByUsername(username).ifPresent(user -> {
            FcmToken fcmToken = fcmRepository.findByUserId(user.getUserId());
            if (fcmToken != null && fcmToken.getToken() != null && !fcmToken.getToken().isEmpty()) {
                send(createMessage(title, message, fcmToken.getToken()));
            } else {
                log.warn("No FCM token for userId={}", user.getUserId());
            }
        });
    }

    private void send(Message message) {
        try {
            // 동기 전송 (비동기 사용 가능: firebaseMessaging.sendAsync(message).get();)
            String response = firebaseMessaging.send(message);
            log.info("Successfully sent notification, response={}", response);
        } catch (FirebaseMessagingException e) {
            // 전체 스택트레이스 로깅으로 원인 파악 도움
            log.error("Failed to send notification", e);
        } catch (Exception e) {
            log.error("Unexpected error while sending notification", e);
        }
    }

    private Message createMessage(String title, String body, String fcmToken) {
        Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(body)
                .build();

        return Message.builder()
                .setNotification(notification)
                .putData("title", title)
                .putData("body", body)
                .setToken(fcmToken)
                .build();
    }

}
