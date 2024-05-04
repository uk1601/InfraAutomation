import { PrismaClient } from "@prisma/client";
import generateVerificationToken from "./JWT.service";
import logger from "../logger";

const { PubSub } = require('@google-cloud/pubsub');
const pubSubClient = new PubSub();
async function publishVerificationMessage(email: string, userId: string) {
  if (process.env.NODE_ENV === 'test') {
    return;
  }
  const topicName = 'verify_email';

  logger.info(`Publishing message to topic ${topicName}`);
  const dataBuffer = Buffer.from(JSON.stringify({ email, userId }));
  try {
    await pubSubClient.topic(topicName).publish(dataBuffer);
    logger.info(`Message published to topic ${topicName} ${email}`);
  } catch (error) {
    console.error(`Failed to publish message to topic ${topicName}:`, error);
  }
}

export default publishVerificationMessage;