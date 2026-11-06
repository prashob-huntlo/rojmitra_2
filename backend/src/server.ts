import { app } from './app';
import { env } from './config/env';
import { connectToMongoDB } from './config/db';

connectToMongoDB()
  .then(() => app.listen(env.port, () => console.log(`API listening on :${env.port}`)))
  .catch(() => process.exit(1));
