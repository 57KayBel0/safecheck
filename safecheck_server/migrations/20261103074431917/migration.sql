BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "incident_access" (
    "id" bigserial PRIMARY KEY,
    "tokenHash" text NOT NULL,
    "ownerId" text NOT NULL,
    "alertId" bigint NOT NULL,
    "contactName" text NOT NULL,
    "canResolve" boolean NOT NULL,
    "trackingUrl" text,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "incident_access_token_idx" ON "incident_access" USING btree ("tokenHash");
CREATE INDEX "incident_access_alert_idx" ON "incident_access" USING btree ("alertId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "safety_alert" ADD COLUMN "reason" text NOT NULL DEFAULT 'missedCheckIn'::text;
ALTER TABLE "safety_alert" ADD COLUMN "brief" json;
ALTER TABLE "safety_alert" ADD COLUMN "briefStatus" text NOT NULL DEFAULT 'fallback'::text;
ALTER TABLE "safety_alert" ADD COLUMN "briefAttemptedAt" timestamp without time zone;
ALTER TABLE "safety_alert" ADD COLUMN "resolvedAt" timestamp without time zone;
ALTER TABLE "safety_alert" ADD COLUMN "resolvedBy" text;
ALTER TABLE "safety_alert" ADD COLUMN "resolutionActor" text;
ALTER TABLE "safety_alert" ADD COLUMN "resolutionNote" text;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "trip" ADD COLUMN "companionMode" boolean NOT NULL DEFAULT false;
ALTER TABLE "trip" ADD COLUMN "graceMinutes" bigint NOT NULL DEFAULT 0;
ALTER TABLE "trip" ADD COLUMN "alertAt" timestamp without time zone;
ALTER TABLE "trip" ADD COLUMN "safetyPlanJson" text;
ALTER TABLE "trip" ADD COLUMN "useAiIncidentSummary" boolean NOT NULL DEFAULT false;
ALTER TABLE "trip" ADD COLUMN "helpRequestedAt" timestamp without time zone;

--
-- MIGRATION VERSION FOR safecheck
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('safecheck', '20261103074431917', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261103074431917', "timestamp" = now();

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
