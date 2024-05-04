import { Router } from "express";
import { Routes } from "../interfaces/routes.interface";
import authMiddleware from "../middleware/auth.middleware";
import UserController from "../controllers/user.controller";
import validationMiddleware from "../middleware/validation.middlewasre";
import { UserDto } from "../dtos/user.dto";

class UserRoute implements Routes {
    public path = '/v1/user';
    public router = Router();
    public userController = new UserController();

    constructor() {
        this.initializeRoutes();
    }
    initializeRoutes() {
        // Unauthenticated and Create User. Returns JWT token and new user data
        this.router.head(`${this.path}/self`, (req, res) => {
            res.status(405).send();
        });
        this.router.head(this.path, (req, res) => {
            res.status(405).send();
        });
        this.router.post(this.path, validationMiddleware(UserDto),this.userController.createUser);
        // // This authenticated and get user data route
        this.router.get(`${this.path}/self`, authMiddleware, this.userController.getUser);
        this.router.put(`${this.path}/self`, authMiddleware, this.userController.updateUser);        
                
        this.router.all(this.path, (req, res) => {
            res.status(405).send();
        });
        this.router.all(`${this.path}/self`, (req, res) => {
            res.status(405).send();
        });
        
    }
}

export default UserRoute;