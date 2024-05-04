import e, { RequestHandler } from "express";
import { UserDto } from "../dtos/user.dto";

const validationMiddleware = (type: any): RequestHandler => {
    if(type as UserDto) {
        return (req, res, next) => {
            try {                
                if(req.body == null || req.body == undefined){
                    return res.status(400).send('No body');
                }
                if(req.body['username'] == null || req.body['username'] == undefined){
                    return res.status(400).send('No username');
                }
                const regex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;
                if(!regex.test(req.body['username'])){
                    return res.status(400).send('Username is an email');
                }
                if(req.body['password'] == null || req.body['password'] == undefined){
                    return res.status(400).send('No password');
                }
                if(req.body['first_name'] == null || req.body['first_name'] == undefined){
                    return res.status(400).send('No first_name');
                }
                if(req.body['last_name'] == null || req.body['last_name'] == undefined){
                    return res.status(400).send('No last_name');
                }
                next();

            }catch(error: any){
                next(error);
            }
        }
    }else{
        throw new Error('Type not supported');
    }
}
export default validationMiddleware;