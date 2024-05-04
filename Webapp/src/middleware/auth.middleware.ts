import { Prisma, PrismaClient, User } from "@prisma/client";
import { compare, hash } from "bcrypt";
import { NextFunction, Request, Response } from "express";
import logger from "../logger";


const authMiddleware = async (req: Request, res: Response, next: NextFunction) => {
    logger.info("Auth middleware");
    const prismaUser = new PrismaClient().user;
    // Implements middleware for basic auth
    try {
        const Authorization = req.header('Authorization') ? (req.header('Authorization') as string).split('Basic ')[1] : null;
        if (!Authorization) {
            return res.status(401).send();
        }
        const credentials = Buffer.from(Authorization, 'base64').toString('utf-8').split(':');
        const username = credentials[0];
        const password = credentials[1];
        const user = await prismaUser.findUnique({
            where: {
                username: username
            }
        });
        if (!user) {
            logger.error('User not found: '+ username);
            return res.status(401).send();
        }
        logger.info(user.password);
        const hashedPassword = await hash(user.password, 10);
        logger.info(hashedPassword);
        logger.info(password);
        const isPwdMatched = await compare(password, user.password);
        if (!isPwdMatched) {
            logger.error('Password not matched: '+ username);
            return res.status(401).send();
        }
        res.locals.user = user;
        next();
    } catch (error) {
        logger.error(error);
        res.status(401).send();
    }    
}
export default authMiddleware;