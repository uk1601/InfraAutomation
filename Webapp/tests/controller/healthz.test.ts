import request from 'supertest';
import App from '../../src/app';
import HealthRoute from '../../src/routes/healthz.routes';
import UserRoute from '../../src/routes/user.routes';
jest.mock('../../src/logger', () => {
    return {
      info: jest.fn(),
      warn: jest.fn(),
      error: jest.fn(),
      // Add other methods as needed
    };
  });
const app = new App([new HealthRoute(), new UserRoute()])
describe('/healthz endpoint', () => {
    it('should return 200 OK for a successful health check', async () => {
        const response = await request(app.app).get('/healthz');
        expect(response.status).toBe(200);
    });


    it('should return 400 Bad Request for invalid requests', async () => {

        const responseWithContentLength = await request(app.app)
            .get('/healthz')
            .set('Content-Length', '100');
        expect(responseWithContentLength.status).toBe(400);

        const responseWithQueryParams = await request(app.app)
            .get('/healthz?param=value');
        expect(responseWithQueryParams.status).toBe(400);
    });
    it('should return 405 Method Not Allowed for non-GET methods', async () => {
        const methods = ['post', 'put', 'delete', 'patch', 'head'];
        for (const method of methods) {
            console.log(`Testing ${method.toUpperCase()} method`);
            if (method === 'post') {
                const response = await request(app.app).post('/healthz');
                expect(response.status).toBe(405);
            } else if (method === 'put') {
                const response = await request(app.app).put('/healthz');
                expect(response.status).toBe(405);

            } else if (method === 'delete') {
                const response = await request(app.app).delete('/healthz');
                expect(response.status).toBe(405);

            } else if (method === 'patch') {
                const response = await request(app.app).patch('/healthz');
                expect(response.status).toBe(405);
            }
            else if (method === 'head') {
                const response = await request(app.app).head('/healthz');
                expect(response.status).toBe(405);
            }
        }
    })
});
