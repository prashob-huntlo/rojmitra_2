import { Schema, model } from 'mongoose';

const adminSchema = new Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true, lowercase: true },
    passwordHash: { type: String, select: false },
  },
  { timestamps: true },
);

export const Admin = model('Admin', adminSchema);
