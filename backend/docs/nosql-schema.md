# NoSQL (MongoDB) schema

## Rules (kept simple)

1. **Embed** data that is read together and stays small (documents, work experiences, addresses).
2. **Separate collection** only for data that grows without limit (availability logs) or needs its own lifecycle (OTPs, partners).
3. **One collection for partners**: the 4 `*_profiles` tables become a `role` field plus a `profile` sub-object.
4. Use what Mongo gives for free: TTL index for OTP cleanup, GeoJSON for location.

## Collections

```
workers                   ← Worker + embedded documents + workExperiences
  idType, identityHash, maskedIdentity, panNumber
  fullName, dateOfBirth, gender, phoneNumber
  permanentAddress {line, villageOrTown, district, state, pincode}
  presentAddress   {…}  presentSameAsPermanent
  isReadyToWork, statusUpdatedAt
  registeredBy {partnerId → sourcingpartners, role}
  registrationLocation  GeoJSON Point [lng, lat]
  documents {primaryIdFrontUrl, primaryIdBackUrl, panCardUrl, photoUrl}
  dailyWageExpected, primaryTrade → skills, skillIds[] → skills
  workExperiences[] {companyId → companies, skillId?, yearsOfExperience, addedBy}
  createdAt, updatedAt

worker_availability_logs ← WorkerAvailabilityLog (append-only)
  workerId → workers, previousStatus, newStatus
  updatedBy {partnerId, role}, createdAt

sourcingpartners               ← sourcing_partners + csc/cmc/anganwadi/gov_ngo profiles
  role: csc | cmc | anganwadi | gov_ngo
  fullName, phoneNumber (unique), email (unique), passwordHash (hidden by default)
  status: pending | accepted | rejected
  state, district, subDistrict, pincode
  profile: role-specific fields
    csc       {vleId, kioskName, kioskAddress, certificateDocUrl, location}
    cmc       {mobilizerId, agencyOrPartnerName, supervisorName, supervisorPhone, assignedPanchayat}
    anganwadi {awcCode, centerName, sectorCircle, cdpoOfficeName}
    gov_ngo   {organizationName, registrationOrDarpanId, designation, jurisdictionLevel}

partnerotps                    ← sourcing_partner_otps
  phoneNumber, purpose, otpHmac, attempts, maxAttempts, isUsed
  expiresAt   (TTL index: Mongo deletes expired docs)

admins, companies, skills      ← catalog + review workflow
```

## Indexes

| Collection | Index |
|---|---|
| workers | `{idType, identityHash}` unique · `{permanentAddress.state, .district}` · `{isReadyToWork, skillIds}` · `{skillIds}` · `{workExperiences.companyId}` · `{registeredBy.partnerId}` |
| worker_availability_logs | `{workerId, createdAt: -1}` |
| sourcingpartners | `phoneNumber`, `email` unique · `{role, state, district}` |
| partnerotps | `{phoneNumber, purpose, isUsed}` · TTL on `expiresAt` |
| skills | `{searchTerms}` unique (multikey) |
| companies | `{nameNormalized}` unique |

Add a `2dsphere` index on `registrationLocation` when the first "near me" query is built.

## Trade-offs

- No foreign-key enforcement: partner/worker references are checked in services.
- `partner.profile` is not schema-validated; validate per role in the signup service.
- `registeredBy.role` is a copy; roles don't change, so it's safe.
- Enum values for `idType`, `gender`, `purpose` are free strings until confirmed.
