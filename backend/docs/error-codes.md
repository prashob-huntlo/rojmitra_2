# API error codes

Every error response has this shape:

```json
{ "code": "snake_case_id", "error": "English message", "fields": { "fieldName": "field_code" } }
```

`error` is a stable English string for logs/fallback. Flutter should map `code` (and optional `fields` values) to ARB strings. `fields` is only present for validation errors when the failing input is known.

| code | HTTP | When |
|---|---|---|
| `unauthorized` | 401 | Missing, malformed, invalid, or expired Bearer token; partner for token no longer exists |
| `not_accepted` | 403 | Authenticated partner `status` is not `accepted` |
| `validation_error` | 400 | Invalid or incomplete request body/query. See `fields` for which input failed |
| `not_found` | 404 | Worker not found (or not owned by the current partner) |
| `duplicate_phone` | 409 | Signup phone already registered |
| `duplicate_email` | 409 | Signup email already registered |
| `duplicate_worker` | 409 | Worker already registered for that `idType` + identity |
| `otp_invalid` | 400 | Wrong OTP, no OTP, or OTP already used |
| `otp_expired` | 400 | OTP exists but is past `expiresAt` |
| `otp_too_many_attempts` | 400 | OTP attempts reached `maxAttempts` (same HTTP status as before) |
| `otp_rate_limited` | 429 | Another OTP was created for the same phone+purpose within 30 seconds (signup / non-generic paths) |
| `catalog_item_rejected` | 422 | Skill or company resolve ended on a rejected catalog record |
| `server_error` | 500 | Unexpected failure (generic message; no internals leaked) |

## `fields` values (under `validation_error`)

| field code | Meaning |
|---|---|
| `invalid_phone` | Phone must be 10 digits |
| `invalid_email` | Email invalid (reserved for future checks) |
| `invalid_role` | Role not one of `csc` / `cmc` / `anganwadi` / `gov_ngo` |
| `missing_field` | Required field missing or empty |
| `invalid_id` | ObjectId missing, malformed, unknown, or rejected catalog ref |
| `invalid_number` | Number missing type or out of allowed range (e.g. `< 0`) |

## Privacy

- `POST /api/auth/request-otp` always returns the same success message whether or not the phone exists (and swallows OTP create errors including rate limits).
- Failed OTP verify does not reveal whether a phone is registered (`otp_invalid` / `otp_expired` only).
