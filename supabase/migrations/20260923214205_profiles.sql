-- btree_gist extension provides a specialized set of
-- GiST (Generalized Search Tree) classes. allows common
-- data types like integers & text to be included in GiST
-- indexes as well as defining exclusion restraints for them.

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA extensions;


CREATE TABLE public.profiles (
    profile_id  UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    first_name  TEXT NOT NULL,
    last_name   TEXT NOT NULL,
    is_admin    BOOLEAN NOT NULL DEFAULT FALSE,
    is_banned   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW (),

    CONSTRAINT profiles_first_name_len CHECK (char_length(btrim(first_name)) BETWEEN 1 AND 40),
    CONSTRAINT profiles_last_name_len CHECK (char_length(btrim(last_name)) BETWEEN 1 AND 40),

    -- formats names like "John S." for display in site
    display_name TEXT GENERATED ALWAYS AS (
        btrim(first_name) || ' ' || UPPER(LEFT(btrim(last_name), 1)) || '.'
    ) STORED -- ensures display_name is immutable
);

-- this table is only public-facing user data
-- emails are kept in auth.users