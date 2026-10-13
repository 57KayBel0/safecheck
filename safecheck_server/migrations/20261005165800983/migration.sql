BEGIN;

--
-- ACTION ALTER TABLE
--
DROP INDEX "simulated_sms_alert_recipient_idx";
ALTER TABLE "simulated_sms" ALTER COLUMN "status" SET DEFAULT 'pending'::text;
CREATE UNIQUE INDEX "simulated_sms_alert_recipient_idx" ON "simulated_sms" USING btree ("alertId", "recipientPhone", "channel");

--
-- MIGRATION VERSION FOR safecheck
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('safecheck', '20261005165800983', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261005165800983', "timestamp" = now();

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
