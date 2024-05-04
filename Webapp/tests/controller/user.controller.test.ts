import { PrismaClient } from "@prisma/client";
import App from "../../src/app";
import UserRoute from "../../src/routes/user.routes";
import logger from "../../src/logger";

const request = require('supertest');
const app = new App([new UserRoute()])

function createAuthHeader(username: any, password: any) {
    return `Basic ${btoa(`${username}:${password}`)}`;
}
describe('User Routes Integration Tests', () => {
    let username: any = Math.random().toString(36).substring(7) + '@gmail.com';
    let password: any = 'password';

    // Test 1: Create a user and validate existence
    test('Create a user and validate', async () => {
        // Create user
        const createUserResponse = await request(app.app)
            .post('/v1/user')
            .send({
                first_name: "Jane",
                last_name: "Doe",
                password: password,
                username: username
            });
        expect(createUserResponse.statusCode).toBe(201);

        const userRepository = new PrismaClient().user;
        userRepository.update({where: {username: username}, data:{isVerified:true}}).then((user) => {
            logger.info('User verified: '+ user.isVerified);
        }).catch((error) => {
            logger.info('Error updating user: '+ error.message);
         });

        // Validate user exists 
        const getUserResponse = await request(app.app)
            .get(`/v1/user/self`)
            .set('Authorization', createAuthHeader(username, password));
        expect(getUserResponse.statusCode).toBe(200); 
        expect(getUserResponse.body).toMatchObject({
            first_name: "Jane",
            last_name: "Doe",
            username: username
        });
    });

    // Test 2: Update a user and validate
    test('Update a user and validate', async () => {
        // Update user
        await request(app.app)
            .put('/v1/user/self')
            .set('Content-Type', 'application/json')
            .set('Authorization', createAuthHeader(username, password))
            .send({
                last_name: "Janeeeeeee",                
            })
            .expect(204);

        const updatedUserResponse = await request(app.app)
            .get('/v1/user/self')
            .set('Authorization', createAuthHeader(username, password));
        expect(updatedUserResponse.statusCode).toBe(200);
        expect(updatedUserResponse.body).toMatchObject({
            last_name: "Janeeeeeee",            
        });
    });
});
