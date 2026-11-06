import mongoose from 'mongoose';
import { env } from './env';

/** Load models so their indexes are registered before sync. */
import '../models';

export async function connectToMongoDB(): Promise<typeof mongoose> {
  try {
    const conn = await mongoose.connect(env.mongoUri, { dbName: env.mongoDbName });
    console.log('Connected to MongoDB');
    // Create / update indexes from schema (e.g. email unique+sparse) on any DB —
    // including a brand-new Atlas cluster. Does not rely on manual Atlas clicks.
    await Promise.all(
      Object.values(mongoose.models).map((model) => model.syncIndexes()),
    );
    console.log('MongoDB indexes synced from models');
    return conn;
  } catch (err) {
    console.error('MongoDB connection failed', err);
    throw err; // let the caller decide (server.ts exits)
  }
}

// Call only when the application terminates
export async function disconnectFromMongoDB(): Promise<void> {
  await mongoose.disconnect();
}
