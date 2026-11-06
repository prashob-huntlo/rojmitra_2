-- PostgreSQL schema reconstructed from the DrawSQL diagram.
-- Import in DrawSQL: File → Import → PostgreSQL, then paste this.
-- Types marked (guess) were truncated in the screenshot; check them.

CREATE TABLE sourcing_partners (
  id           uuid PRIMARY KEY,
  role         varchar(20) NOT NULL,
  full_name    varchar(150) NOT NULL,
  phone_number varchar(15) NOT NULL UNIQUE,
  email        varchar(255) NOT NULL UNIQUE,
  password_hash varchar(255),
  status       varchar(30) NOT NULL,
  state        varchar(100) NOT NULL,
  district     varchar(100) NOT NULL,
  sub_district varchar(100),
  pincode      varchar(10) NOT NULL,
  created_at   timestamptz NOT NULL,
  updated_at   timestamptz NOT NULL,
  UNIQUE (id, role)
);

CREATE TABLE sourcing_partner_otps (
  id           uuid PRIMARY KEY,
  phone_number varchar(15) NOT NULL,
  otp_hmac     varchar(255) NOT NULL,
  purpose      varchar(20) NOT NULL,
  attempts     int NOT NULL,
  max_attempts int NOT NULL,
  expires_at   timestamptz NOT NULL,
  is_used      boolean NOT NULL,
  created_at   timestamptz NOT NULL
);
CREATE INDEX idx_otps_lookup ON sourcing_partner_otps (phone_number, purpose, is_used);

CREATE TABLE csc_profiles (
  sourcing_partner_id uuid PRIMARY KEY REFERENCES sourcing_partners(id),
  role                varchar(20) NOT NULL,
  vle_id              varchar(50) NOT NULL UNIQUE,
  kiosk_name          varchar(200),
  kiosk_address       text,
  certificate_doc_url text,
  gps_latitude        decimal(10,7),
  gps_longitude       decimal(10,7)
);

CREATE TABLE cmc_profiles (
  sourcing_partner_id uuid PRIMARY KEY REFERENCES sourcing_partners(id),
  role                varchar(20) NOT NULL,
  mobilizer_id        varchar(50) NOT NULL UNIQUE,
  agency_or_partner_name varchar(200),   -- (guess)
  supervisor_name     varchar(150),
  supervisor_phone    varchar(15),
  assigned_panchayat  varchar(150)       -- (guess)
);

CREATE TABLE anganwadi_profiles (
  sourcing_partner_id uuid PRIMARY KEY REFERENCES sourcing_partners(id),
  role                varchar(20) NOT NULL,
  center_name         varchar(200),
  awc_code            varchar(50) UNIQUE,
  sector_circle       varchar(100),
  cdpo_office_name    varchar(150)       -- (guess)
);

CREATE TABLE gov_ngo_profiles (
  sourcing_partner_id uuid PRIMARY KEY REFERENCES sourcing_partners(id),
  role                varchar(20) NOT NULL,
  organization_name   varchar(200),      -- (guess)
  registration_or_darpan_id varchar(100),-- (guess)
  designation         varchar(100),
  jurisdiction_level  varchar(50)
);

CREATE TABLE workers (
  id               uuid PRIMARY KEY,
  id_type          varchar(30) NOT NULL,
  identity_hash    char(64) NOT NULL,
  masked_identity  varchar(16) NOT NULL,
  pan_number       varchar(10) UNIQUE,
  full_name        varchar(150) NOT NULL,
  date_of_birth    date,
  gender           varchar(20),
  phone_number     varchar(15),
  perm_address_line text,
  perm_village_or_town varchar(100),
  perm_district    varchar(100),
  perm_state       varchar(100),
  perm_pincode     varchar(10),
  is_present_same_as_perm boolean,
  pres_address_line text,
  pres_village_or_town varchar(100),
  pres_district    varchar(100),
  pres_state       varchar(100),
  pres_pincode     varchar(10),
  is_ready_to_work boolean,
  status_updated_at timestamptz,
  registered_by_partner_id uuid REFERENCES sourcing_partners(id),
  registered_by_role varchar(20),
  registration_lat decimal(10,7),
  registration_lng decimal(10,7),
  created_at       timestamptz NOT NULL,
  updated_at       timestamptz NOT NULL
);
CREATE UNIQUE INDEX idx_workers_identity ON workers (id_type, identity_hash);
CREATE INDEX idx_workers_region ON workers (perm_state, perm_district);

CREATE TABLE worker_documents (
  id                 uuid PRIMARY KEY,
  worker_id    uuid NOT NULL REFERENCES workers(id),
  primary_id_front_url text,
  primary_id_back_url  text,
  pan_card_url       text,
  photo_url          text,
  created_at         timestamptz NOT NULL
);

CREATE TABLE worker_work_experiences (
  id                    uuid PRIMARY KEY,
  worker_id       uuid NOT NULL REFERENCES workers(id),
  primary_trade         varchar(100) NOT NULL,
  sub_skills            text,
  years_of_experience   int,
  daily_wage_expected   decimal(10,2),
  created_at            timestamptz NOT NULL
);

CREATE TABLE worker_availability_logs (
  id                    uuid PRIMARY KEY,
  worker_id       uuid NOT NULL REFERENCES workers(id),
  previous_status       boolean,
  new_status            boolean NOT NULL,
  updated_by_partner_id uuid REFERENCES sourcing_partners(id),
  updated_by_role       varchar(20),
  created_at            timestamptz NOT NULL
);
CREATE INDEX idx_avail_worker_time ON worker_availability_logs (worker_id, created_at);
