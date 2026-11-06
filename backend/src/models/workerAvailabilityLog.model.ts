import { Schema, model } from 'mongoose';

// Append-only history, kept out of `workers` because it grows without limit.
const logSchema = new Schema(
  {
    workerId: { type: Schema.Types.ObjectId, ref: 'Worker', required: true },
    previousStatus: Boolean,
    newStatus: { type: Boolean, required: true },
    updatedBy: { partnerId: Schema.Types.ObjectId, role: String },
  },
  { timestamps: { createdAt: true, updatedAt: false } },
);

logSchema.index({ workerId: 1, createdAt: -1 });

export const WorkerAvailabilityLog = model(
  'WorkerAvailabilityLog',
  logSchema,
  'worker_availability_logs',
);
