import App from './app';
import HealthRoute from './routes/healthz.routes';
import UserRoute from './routes/user.routes';
import VerificationRoute from './routes/verification.route';
const app = new App([new HealthRoute(), new UserRoute(), new VerificationRoute()]);
app.listen();