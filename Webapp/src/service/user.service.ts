import { PrismaClient, User } from "@prisma/client";
import { UserDto } from "../dtos/user.dto";
import { hash } from "bcrypt";
import Utils from "../utils";
import logger from "../logger";
import publishVerificationMessage from "./pubsub";
const jwt = require('jsonwebtoken');

class UserService {
    private userRepository = new PrismaClient().user;
    private maillogRepository = new PrismaClient().mailLog;

    async createUser(userDto: UserDto): Promise<any | void> {
        logger.info('Service createUser');
        const user: User = userDto.toPrisma();
        const hashedPassword = await hash(user.password, 10);
        user.password = hashedPassword;
        logger.info(user);
        return this.userRepository.create({ data: Utils.filterNonNullValues(user) }).then((user: User) => {
            const createUserDto = new UserDto(user.id, user.username, user.password, user.firstName, user.lastName, user.accountCreated, user.accountUpdated);
            publishVerificationMessage(createUserDto.username, createUserDto.id).then(() => {
                logger.info('Verification message published for username:' + createUserDto.username);
            }).catch((error: any) => {
                logger.error('Failed to publish verification message for username:' + createUserDto.username);
            });
            return createUserDto.toResponse();
        }).catch((error: any) => {
            if (error.message && error.message.includes('database')) {
                logger.error(error.message);
                throw new Error('Error with database');
            }
            else if (error.message && error.message.includes('Unique constraint failed on the constraint: `users_username_key')) {
                logger.warn(error.message);
                throw new Error('Username already exists');
            } else {
                logger.error(error.message);
                throw new Error(error.message);
            }
        });
    }
    async updateUser(userDto: UserDto): Promise<any | void> {
        const user: User = userDto.toPrisma();
        if (user.username != null || user.username != undefined) {
            logger.error('Username can not be changed');
            return new Error('Username can not be changed');
        }
        if (user.password != null || user.password != undefined) {
            user.password = await hash(user.password, 10);
        }
        return this.userRepository.update({ where: { id: user.id }, data: Utils.filterNonNullValues(user) }).then((user: User) => {
            const updateUserDto = new UserDto(user.id, user.username, user.password, user.firstName, user.lastName, user.accountCreated, user.accountUpdated);
            return updateUserDto.toResponse();
        }).catch((error: any) => {
            logger.error(error.message);
            throw new Error(error.message);
        });
    }

    verifyUserAccount = async (token: string) => {
        try {
            // Find the user by email
            const user = await this.userRepository.findUnique({ where: { id: token } });
            logger.info('User found:', user?.username || 'Unknown');
            if (!user) {
                return false;
            }
            if (user.isVerified) {
                logger.info('User verified:', user?.username || 'Unknown');
            }
            // Check if the sent mail link is expired, which is 2 minutes from sending it
            try {
                const mailLog = await this.maillogRepository.findFirst({ where: { userId: user.id } });
                if (!mailLog) {
                    logger.warn('Mail log not found for user:', user.username);
                    return false;
                }
                const now = new Date();
                const diff = now.getTime() - mailLog.sentAt.getTime();
                if (diff > 120000) {
                    logger.warn('Mail link expired for user:', user.username);
                    return false;
                }
            } catch (error) {
                logger.error('Error checking mail log:', error);                
            }
            // Update the user's verification status
            await this.userRepository.update({ where: { id: user.id }, data: { isVerified: true } });
            return true;
        } catch (error) {
            logger.error('Error verifying user account:', error);
            return false;
        }
    };


}
export default UserService;
