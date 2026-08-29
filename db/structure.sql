CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "accounts" ("id" uuid NOT NULL PRIMARY KEY, "name" varchar NOT NULL, "slug" varchar NOT NULL, "phone" varchar, "email" varchar, "timezone" varchar DEFAULT 'America/Sao_Paulo' NOT NULL, "settings" json DEFAULT '{}' NOT NULL, "plan" varchar DEFAULT 'trial' NOT NULL, "trial_ends_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "stripe_customer_id" varchar /*application='AgendaAi'*/, "stripe_subscription_id" varchar /*application='AgendaAi'*/, "stripe_price_id" varchar /*application='AgendaAi'*/, "subscription_status" varchar DEFAULT 'trialing' NOT NULL /*application='AgendaAi'*/, "subscription_plan" varchar /*application='AgendaAi'*/, "subscription_current_period_end" datetime(6) /*application='AgendaAi'*/, "subscription_cancel_at_period_end" boolean DEFAULT FALSE NOT NULL /*application='AgendaAi'*/);
CREATE UNIQUE INDEX "index_accounts_on_slug" ON "accounts" ("slug") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "users" ("id" uuid NOT NULL PRIMARY KEY, "account_id" uuid NOT NULL, "name" varchar NOT NULL, "email" varchar DEFAULT '' NOT NULL, "encrypted_password" varchar DEFAULT '' NOT NULL, "reset_password_token" varchar, "reset_password_sent_at" datetime(6), "remember_created_at" datetime(6), "sign_in_count" integer DEFAULT 0 NOT NULL, "current_sign_in_at" datetime(6), "last_sign_in_at" datetime(6), "current_sign_in_ip" varchar, "last_sign_in_ip" varchar, "role" varchar DEFAULT 'owner' NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_61ac11da2b"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_users_on_account_id" ON "users" ("account_id") /*application='AgendaAi'*/;
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email") /*application='AgendaAi'*/;
CREATE UNIQUE INDEX "index_users_on_reset_password_token" ON "users" ("reset_password_token") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "professionals" ("id" uuid NOT NULL PRIMARY KEY, "account_id" uuid NOT NULL, "name" varchar NOT NULL, "email" varchar, "phone" varchar, "bio" text, "active" boolean DEFAULT TRUE NOT NULL, "position" integer DEFAULT 0 NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_4f370f7e2f"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_professionals_on_account_id" ON "professionals" ("account_id") /*application='AgendaAi'*/;
CREATE INDEX "index_professionals_on_account_id_and_position" ON "professionals" ("account_id", "position") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "services" ("id" uuid NOT NULL PRIMARY KEY, "account_id" uuid NOT NULL, "name" varchar NOT NULL, "description" text, "duration_minutes" integer NOT NULL, "price_cents" integer DEFAULT 0 NOT NULL, "currency" varchar DEFAULT 'BRL' NOT NULL, "active" boolean DEFAULT TRUE NOT NULL, "position" integer DEFAULT 0 NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_561fd4f186"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_services_on_account_id" ON "services" ("account_id") /*application='AgendaAi'*/;
CREATE INDEX "index_services_on_account_id_and_position" ON "services" ("account_id", "position") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "professional_services" ("id" uuid NOT NULL PRIMARY KEY, "professional_id" uuid NOT NULL, "service_id" uuid NOT NULL, "custom_duration_minutes" integer, "custom_price_cents" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_bbf2eb5b6c"
FOREIGN KEY ("professional_id")
  REFERENCES "professionals" ("id")
, CONSTRAINT "fk_rails_0df2633a97"
FOREIGN KEY ("service_id")
  REFERENCES "services" ("id")
);
CREATE INDEX "index_professional_services_on_professional_id" ON "professional_services" ("professional_id") /*application='AgendaAi'*/;
CREATE INDEX "index_professional_services_on_service_id" ON "professional_services" ("service_id") /*application='AgendaAi'*/;
CREATE UNIQUE INDEX "index_professional_services_on_professional_id_and_service_id" ON "professional_services" ("professional_id", "service_id") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "schedules" ("id" uuid NOT NULL PRIMARY KEY, "professional_id" uuid NOT NULL, "weekday" integer NOT NULL, "starts_at" time NOT NULL, "ends_at" time NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_3c2b89def2"
FOREIGN KEY ("professional_id")
  REFERENCES "professionals" ("id")
);
CREATE INDEX "index_schedules_on_professional_id" ON "schedules" ("professional_id") /*application='AgendaAi'*/;
CREATE INDEX "index_schedules_on_professional_id_and_weekday" ON "schedules" ("professional_id", "weekday") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "schedule_overrides" ("id" uuid NOT NULL PRIMARY KEY, "professional_id" uuid NOT NULL, "date" date NOT NULL, "starts_at" time, "ends_at" time, "reason" varchar, "blocked" boolean DEFAULT FALSE NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_02a5f9d60a"
FOREIGN KEY ("professional_id")
  REFERENCES "professionals" ("id")
);
CREATE INDEX "index_schedule_overrides_on_professional_id" ON "schedule_overrides" ("professional_id") /*application='AgendaAi'*/;
CREATE INDEX "index_schedule_overrides_on_professional_id_and_date" ON "schedule_overrides" ("professional_id", "date") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "clients" ("id" uuid NOT NULL PRIMARY KEY, "account_id" uuid NOT NULL, "name" varchar NOT NULL, "email" varchar, "phone" varchar, "notes" text, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_bed59fd791"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_clients_on_account_id" ON "clients" ("account_id") /*application='AgendaAi'*/;
CREATE INDEX "index_clients_on_account_id_and_email" ON "clients" ("account_id", "email") /*application='AgendaAi'*/;
CREATE INDEX "index_clients_on_account_id_and_phone" ON "clients" ("account_id", "phone") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "bookings" ("id" uuid NOT NULL PRIMARY KEY, "account_id" uuid NOT NULL, "professional_id" uuid NOT NULL, "service_id" uuid NOT NULL, "client_id" uuid NOT NULL, "starts_at" datetime(6) NOT NULL, "ends_at" datetime(6) NOT NULL, "status" varchar DEFAULT 'pending' NOT NULL, "price_cents" integer DEFAULT 0 NOT NULL, "currency" varchar DEFAULT 'BRL' NOT NULL, "notes" text, "source" varchar DEFAULT 'public_page' NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_31130abe16"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
, CONSTRAINT "fk_rails_807dd0f16d"
FOREIGN KEY ("professional_id")
  REFERENCES "professionals" ("id")
, CONSTRAINT "fk_rails_1707d5de0d"
FOREIGN KEY ("service_id")
  REFERENCES "services" ("id")
, CONSTRAINT "fk_rails_2c503ea743"
FOREIGN KEY ("client_id")
  REFERENCES "clients" ("id")
);
CREATE INDEX "index_bookings_on_account_id" ON "bookings" ("account_id") /*application='AgendaAi'*/;
CREATE INDEX "index_bookings_on_professional_id" ON "bookings" ("professional_id") /*application='AgendaAi'*/;
CREATE INDEX "index_bookings_on_service_id" ON "bookings" ("service_id") /*application='AgendaAi'*/;
CREATE INDEX "index_bookings_on_client_id" ON "bookings" ("client_id") /*application='AgendaAi'*/;
CREATE INDEX "index_bookings_on_professional_id_and_starts_at_and_ends_at" ON "bookings" ("professional_id", "starts_at", "ends_at") /*application='AgendaAi'*/;
CREATE INDEX "index_bookings_on_account_id_and_status" ON "bookings" ("account_id", "status") /*application='AgendaAi'*/;
CREATE INDEX "index_bookings_on_starts_at" ON "bookings" ("starts_at") /*application='AgendaAi'*/;
CREATE TABLE IF NOT EXISTS "booking_status_changes" ("id" uuid NOT NULL PRIMARY KEY, "booking_id" uuid NOT NULL, "from_status" varchar, "to_status" varchar NOT NULL, "changed_by" varchar, "reason" text, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_d6c601f1ad"
FOREIGN KEY ("booking_id")
  REFERENCES "bookings" ("id")
);
CREATE INDEX "index_booking_status_changes_on_booking_id" ON "booking_status_changes" ("booking_id") /*application='AgendaAi'*/;
CREATE INDEX "index_accounts_on_stripe_customer_id" ON "accounts" ("stripe_customer_id") /*application='AgendaAi'*/;
CREATE INDEX "index_accounts_on_stripe_subscription_id" ON "accounts" ("stripe_subscription_id") /*application='AgendaAi'*/;
CREATE INDEX "index_accounts_on_subscription_status" ON "accounts" ("subscription_status") /*application='AgendaAi'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20260829150000'),
('20260829140217'),
('20260829140216'),
('20260829140215'),
('20260829140214'),
('20260829140213'),
('20260829140212'),
('20260829140211'),
('20260829140210'),
('20260829140209'),
('20260829140208'),
('20260829140207');

