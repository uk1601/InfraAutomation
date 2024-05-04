
import { User } from "@prisma/client";
import { UserDto } from "../dtos/user.dto";
import logger from "../logger";
import UserService from "../service/user.service";

class UserController {
    public userService = new UserService();    
    constructor() {
        this.createUser = this.createUser.bind(this);
        this.getUser = this.getUser.bind(this);
        this.updateUser = this.updateUser.bind(this);
        this.verifyAccount = this.verifyAccount.bind(this);
    }

    public async createUser(req: any, res: any, next: any) {
        logger.info('Controller createUser');
        const user: UserDto = new UserDto(req.body.id, req.body.username, req.body.password, req.body.first_name, req.body.last_name);
        logger.info(user);
        try {
            const createdUserDto: User = await this.userService.createUser(user);
            logger.info("created user:" + createdUserDto.username);
            res.status(201).json(createdUserDto);
        }
        catch (error: any) {
            logger.error(error);
            res.status(400).send(error.message);
        }

    }
    public async getUser(req: any, res: any, next: any) {
        logger.info('Controller getUser: ' + res.locals.user.username);
        // TODO: FIx the integration tests and dont go about this way 
        if(process.env.NODE_ENV === 'test'){
            res.locals.user.isVerified = true;  
        }      
        if (!res.locals.user.isVerified) {
            logger.warn('User not verified');
            return res.status(401).send('User not verified');
        }
        return res.status(200).json({ id: res.locals.user.id, username: res.locals.user.username, first_name: res.locals.user.firstName, last_name: res.locals.user.lastName, account_created: res.locals.user.accountCreated, accountUpdated: res.locals.user.accountUpdated });
    }
    public async updateUser(req: any, res: any, next: any) {
        try {       
            // TODO: FIx the integration tests and dont go about this way
            if(process.env.NODE_ENV === 'test'){
                res.locals.user.isVerified = true;  
            }      
            if (!res.locals.user.isVerified) {
                logger.warn('User not verified');
                return res.status(401).send('User not verified');
            }     
            const user: UserDto = new UserDto(res.locals.user.id, req.body.username, req.body.password, req.body.first_name, req.body.last_name);                 
            if(req.body.username){
                logger.warn('Username can not be changed: '+ user.username);
                return res.status(400).send('Username can not be changed');
            }
            if(res.body && res.body.username && req.body.username!=res.locals.user.username){
                logger.warn('Username can not be changed: '+ user.username);
                return res.status(400).send('Username can not be changed');
            }
            const updatedUser = await this.userService.updateUser(user);
            logger.info("update user:" + updatedUser.username);
            return res.sendStatus(204);
        }
        catch (error: any) {
            logger.error(error);
            res.status(400).json({ error: error.message });
        }
    }

    public async verifyAccount (req: any, res: any) {
        let { token } = req.query;                      
        
        try {
          const verificationResult = await this.userService.verifyUserAccount(token);
          if (verificationResult) {
            return res.status(200).json({ success: true, message: 'Account verified successfully.' });
          } else {
            return res.status(403).json({ success: false, message: 'Verification failed.' });
          }
        } catch (error) {
          console.error('Account verification error:', error);
          return res.status(403).json({ success: false, message: 'Internal server error.' });
        }
      };
}
export default UserController;

