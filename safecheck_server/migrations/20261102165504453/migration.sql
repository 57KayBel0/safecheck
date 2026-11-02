BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "planning_quota" (
    "id" bigserial PRIMARY KEY,
    "ownerId" text NOT NULL,
    "windowStartedAt" timestamp without time zone NOT NULL,
    "windowCount" bigint NOT NULL,
    "dayStartedAt" timestamp without time zone NOT NULL,
    "dayCount" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "planning_quota_owner_idx" ON "planning_quota" USING btree ("ownerId");


--
-- MIGRATION VERSION FOR safecheck
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('safecheck', '20261102165504453', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261102165504453', "timestamp" = now();

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
