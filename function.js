const functions = require("firebase-functions");
const admin = require('firebase-admin');
const moment = require('moment-timezone');


  

exports.scheduledNotifications = functions.pubsub.schedule('every 1 minutes').onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const notificationRef = admin.firestore().collection('scheduled_notifications');
    const sentNotificationRef = admin.firestore().collection('notifications');

    const snapshot = await notificationRef.where('next_send_date', '<=', now).get();

    for (let i = 0; i < snapshot.size; i++) {
        const doc = snapshot.docs[i];
        const { notification_title, notification_description, repeat_in_mins ,user_ref} = doc.data();



        await sendFFPushNotification(notification_title, notification_description , user_ref);

        // Log the sent notification and axios response or error
        await sentNotificationRef.doc().set({
          received_by:user_ref,
            title: notification_title,
            content: notification_description,
            created_time: new Date()  // The current timestamp
        });

        // Calculate nextNotificationTime
        const nextNotificationTime = moment(doc.data().next_send_date.toDate())
            .add(repeat_in_mins, 'minutes')
            .toDate();

        // Update Firestore document
        await notificationRef.doc(doc.id).update({
            next_send_date: admin.firestore.Timestamp.fromDate(nextNotificationTime)
        });
    }
    // res.sendStatus(200);

});
async function sendFFPushNotification(title, content, userRef) {
    try {
        // Fetch user's FCM tokens from Firestore based on userId
        const userTokensSnapshot = await userRef
            .collection('fcm_tokens')
            .get();

        if (userTokensSnapshot.empty) {
            console.log('No FCM tokens found for user.');
            return;
        }

        const tokens = userTokensSnapshot.docs.map(doc => doc.data().fcm_token);

        // Construct the message payload
        const messagePayload = {
            notification: {
                title: title,
                body: content,
            },
            android: {
                notification: {
                    sound: 'default'
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default'
                    },
                },
            },
            tokens: tokens
        };

        // Send the notification
        const response = await admin.messaging().sendEachForMulticast(messagePayload);

        console.log('Notification sent successfully:', response);
    } catch (error) {
        console.error('Error sending notification:', error);
    }
}
