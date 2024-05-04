import logger from "../logger";

const jwt = require('jsonwebtoken');

function generateVerificationToken(userEmail:string) {
  const secret = process.env.JWT_SECRET;
  const expiresIn = '24h';
  const payload = {
    email: userEmail,    
    createdAt: Date.now(),
  };
  const token = jwt.sign(payload, secret, { expiresIn });
  logger.info('Generated verification token for email: ' + userEmail);
  logger.debug('Generated verification token: ' + token);
  return token;
}
export default generateVerificationToken;