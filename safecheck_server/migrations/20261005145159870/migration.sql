BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "simulated_sms" ADD COLUMN "channel" text NOT NULL DEFAULT 'sms'::text;
ALTER TABLE "simulated_sms" ADD COLUMN "status" text NOT NULL DEFAULT 'simulated'::text;
ALTER TABLE "simulated_sms" ADD COLUMN "statusUpdatedAt" timestamp without time zone;
ALTER TABLE "simulated_sms" ADD COLUMN "failureReason" text;
CREATE INDEX "simulated_sms_status_idx" ON "simulated_sms" USING btree ("status");
--
-- ACTION CREATE TABLE
--
CREATE TABLE "tracking_link" (
    "id" bigserial PRIMARY KEY,
    "token" text NOT NULL,
    "ownerId" text NOT NULL,
    "tripId" bigint NOT NULL,
    "contactName" text NOT NULL,
    "contactPhone" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "tracking_link_token_idx" ON "tracking_link" USING btree ("token");
CREATE INDEX "tracking_link_trip_idx" ON "tracking_link" USING btree ("tripId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "trip" ADD COLUMN "locationSharing" text NOT NULL DEFAULT 'off'::text;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "trip_location" (
    "id" bigserial PRIMARY KEY,
    "ownerId" text NOT NULL,
    "tripId" bigint NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "accuracyMeters" double precision,
    "recordedAt" timestamp without time zone NOT NULL,
    "receivedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "trip_location_trip_time_idx" ON "trip_location" USING btree ("tripId", "recordedAt");
CREATE INDEX "trip_location_received_idx" ON "trip_location" USING btree ("receivedAt");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "trusted_contact" ADD COLUMN "optInStatus" text NOT NULL DEFAULT 'pending'::text;
ALTER TABLE "trusted_contact" ADD COLUMN "optInRespondedAt" timestamp without time zone;
ALTER TABLE "trusted_contact" ADD COLUMN "inviteToken" text;
CREATE UNIQUE INDEX "trusted_contact_invite_token_idx" ON "trusted_contact" USING btree ("inviteToken");

--
-- MIGRATION VERSION FOR safecheck
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('safecheck', '20261005145159870', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261005145159870', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
