import { Request, Response, NextFunction, RequestHandler, ErrorRequestHandler } from 'express';

export class AppError extends Error {
  status: number;
  code: string;
  fields?: Record<string, string>;

  constructor(status: number, message: string, code: string, fields?: Record<string, string>) {
    super(message);
    this.name = 'AppError';
    this.status = status;
    this.code = code;
    this.fields = fields;
  }
}

export function asyncHandler(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<unknown>,
): RequestHandler {
  return (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

export const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof AppError) {
    const body: { code: string; error: string; fields?: Record<string, string> } = {
      code: err.code,
      error: err.message,
    };
    if (err.fields) body.fields = err.fields;
    res.status(err.status).json(body);
    return;
  }

  res.status(500).json({ code: 'server_error', error: 'Internal Server Error' });
};
