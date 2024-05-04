import { Router } from "express";
import { Routes } from "../interfaces/routes.interface";
import { PrismaClient } from "@prisma/client";
import logger from "../logger";
const prisma: PrismaClient = new PrismaClient();

class HealthRoute implements Routes {
    public path = '/healthz';
    public router = Router();

    constructor() {
        this.initializeRoutes();
    }
    initializeRoutes() {        
        this.router.head(this.path, (req, res) => {
            res.status(405).send();
        });
        this.router.get(this.path, (req, res) => {
            logger.info("Health check");
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Access-Control-Allow-Origin', '*');
            res.setHeader('Cache-Control', 'no-cache');
            try {
                if (req.get('Content-Length')) {
                    throw new Error("Invalid request");
                }
                if (Object.keys(req.query).length > 0) {
                    throw new Error("Invalid request");
                }
                prisma.$connect().then(() => {
                    res.status(200).send();
                    prisma.$disconnect();
                }).catch((e: Error) => {
                    logger.error(e);
                    res.status(503).send();
                });                
            } catch (e) {
                logger.error((e as Error).message);
                res.status(400).send();
            }
        });
        this.router.all(this.path, (req, res) => {
            res.status(405).send();
        });
    }        
}
export default HealthRoute;