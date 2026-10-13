BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "safety_alert" (
    "id" bigserial PRIMARY KEY,
    "ownerId" text NOT NULL,
    "tripId" bigint NOT NULL,
    "travellerName" text NOT NULL,
    "travellerPhone" text NOT NULL,
    "tripType" text NOT NULL,
    "tripDescription" text NOT NULL,
    "deadline" timestamp without time zone NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "contacts" json NOT NULL
);

-- Indexes
CREATE INDEX "safety_alert_owner_idx" ON "safety_alert" USING btree ("ownerId");
CREATE UNIQUE INDEX "safety_alert_trip_idx" ON "safety_alert" USING btree ("tripId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "simulated_sms" (
    "id" bigserial PRIMARY KEY,
    "ownerId" text NOT NULL,
    "alertId" bigint NOT NULL,
    "tripId" bigint NOT NULL,
    "recipientName" text NOT NULL,
    "recipientPhone" text NOT NULL,
    "body" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "simulated_sms_owner_idx" ON "simulated_sms" USING btree ("ownerId");
CREATE UNIQUE INDEX "simulated_sms_alert_recipient_idx" ON "simulated_sms" USING btree ("alertId", "recipientPhone");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "trip" (
    "id" bigserial PRIMARY KEY,
    "ownerId" text NOT NULL,
    "activeOwnerId" text,
    "tripType" text NOT NULL,
    "description" text NOT NULL,
    "durationMinutes" bigint NOT NULL,
    "startedAt" timestamp without time zone NOT NULL,
    "deadline" timestamp without time zone NOT NULL,
    "status" text NOT NULL,
    "endedAt" timestamp without time zone,
    "contacts" json NOT NULL
);

-- Indexes
CREATE INDEX "trip_owner_idx" ON "trip" USING btree ("ownerId");
CREATE UNIQUE INDEX "trip_active_owner_idx" ON "trip" USING btree ("activeOwnerId");
CREATE INDEX "trip_status_deadline_idx" ON "trip" USING btree ("status", "deadline");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "trusted_contact" (
    "id" bigserial PRIMARY KEY,
    "ownerId" text NOT NULL,
    "name" text NOT NULL,
    "phoneNumber" text NOT NULL,
    "relationship" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "trusted_contact_owner_idx" ON "trusted_contact" USING btree ("ownerId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_profile" (
    "id" bigserial PRIMARY KEY,
    "ownerId" text NOT NULL,
    "displayName" text NOT NULL,
    "phoneNumber" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_profile_owner_idx" ON "user_profile" USING btree ("ownerId");


--
-- MIGRATION VERSION FOR safecheck
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('safecheck', '20261001091450031', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261001091450031', "timestamp" = now();

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
