import express, { Application } from 'express';
import { Routes } from './interfaces/routes.interface';
import  logger  from './logger';
class App{
    public app: Application;
    public port: number;

    constructor(routes: Routes[]){
        this.app = express();
        this.port = 3000;
        this.initializeMiddlewares();
        this.initializeRoutes(routes);
        this.initializeErrorHandling();
    }
    initializeErrorHandling() {
        // TODO: Implement error handling
        
    }
    initializeRoutes(routes: Routes[]) {
        routes.forEach(route => {
            this.app.use('/', route.router);
        });
    }
    initializeMiddlewares() {
        this.app.use(express.json());        
    }

    public listen(){
        this.app.listen(this.port, () => {
            logger.debug("-------------------------")
            logger.info(`Server running at http://localhost:${this.port}`);
            logger.debug("-------------------------")
        });
    }

    public getServer(){
        return this.app;
    }
    
}
export default App;