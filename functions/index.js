const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendChatNotification = onDocumentCreated("chat/{messageId}", async (event) => {
  const chatMessage = event.data?.data();
  if (!chatMessage) return;

  const users = await admin.firestore().collection("users").get();
  const tokens = users.docs
    .filter((user) => user.id !== chatMessage.userId)
    .flatMap((user) => user.data().fcmTokens ?? [])
    .filter((token) => typeof token === "string" && token.length > 0);

  if (tokens.length === 0) {
    logger.info("No recipient FCM tokens found.");
    return;
  }

  // FCM accepts a maximum of 500 targets for each multicast request.
  for (let start = 0; start < tokens.length; start += 500) {
    const batch = tokens.slice(start, start + 500);
    await admin.messaging().sendEachForMulticast({
      tokens: batch,
      notification: {
        title: chatMessage.userName ?? "New chat message",
        body: chatMessage.text ?? "Sent a message",
      },
      data: {
        chatMessageId: event.params.messageId,
      },
    });
  }
});
