import { Router } from "express";
import { Routes } from "../interfaces/routes.interface";
import UserController from "../controllers/user.controller";

class VerificationRoute implements Routes{
    public path = '/verification';
    public router = Router();
    public userController = new UserController();
    constructor() {
        this.initializeRoutes();
    }
    initializeRoutes() {
        this.router.get(this.path, this.userController.verifyAccount);
    }
}
export default VerificationRoute;