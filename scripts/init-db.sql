-- Database initialization script for development environment
-- This follows base guidelines for database setup

-- Create development database if it doesn't exist
CREATE DATABASE IF NOT EXISTS example_app;
CREATE DATABASE IF NOT EXISTS example_app_test;

-- Create development user with appropriate permissions
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'developer') THEN

      CREATE ROLE developer LOGIN PASSWORD 'development';
   END IF;
END
$do$;

-- Grant permissions to developer user
GRANT ALL PRIVILEGES ON DATABASE example_app TO developer;
GRANT ALL PRIVILEGES ON DATABASE example_app_test TO developer;

-- Connect to the application database
\c example_app;

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create basic schema following base guidelines
CREATE SCHEMA IF NOT EXISTS app;
CREATE SCHEMA IF NOT EXISTS audit;

-- Grant schema permissions
GRANT ALL ON SCHEMA app TO developer;
GRANT ALL ON SCHEMA audit TO developer;

-- Example tables following base architecture patterns
CREATE TABLE IF NOT EXISTS app.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role VARCHAR(50) DEFAULT 'user',
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit table for compliance (base security requirement)
CREATE TABLE IF NOT EXISTS audit.user_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES app.users(id),
    event_type VARCHAR(50) NOT NULL,
    event_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance (base performance guidelines)
CREATE INDEX IF NOT EXISTS idx_users_email ON app.users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON app.users(created_at);
CREATE INDEX IF NOT EXISTS idx_user_events_user_id ON audit.user_events(user_id);
CREATE INDEX IF NOT EXISTS idx_user_events_created_at ON audit.user_events(created_at);

-- Update trigger for updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON app.users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (base security requirement)
ALTER TABLE app.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit.user_events ENABLE ROW LEVEL SECURITY;

-- Example RLS policies
CREATE POLICY users_own_data ON app.users 
    FOR ALL USING (id = current_setting('app.current_user_id')::UUID);

CREATE POLICY admin_full_access ON app.users 
    FOR ALL USING (current_setting('app.current_user_role') = 'admin');

-- Grant table permissions
GRANT ALL ON ALL TABLES IN SCHEMA app TO developer;
GRANT ALL ON ALL TABLES IN SCHEMA audit TO developer;
GRANT ALL ON ALL SEQUENCES IN SCHEMA app TO developer;
GRANT ALL ON ALL SEQUENCES IN SCHEMA audit TO developer;

-- Create test data for development
INSERT INTO app.users (email, password_hash, first_name, last_name, role) 
VALUES 
    ('admin@example.com', crypt('admin123', gen_salt('bf')), 'Admin', 'User', 'admin'),
    ('user@example.com', crypt('user123', gen_salt('bf')), 'Test', 'User', 'user')
ON CONFLICT (email) DO NOTHING;

-- Log initialization
INSERT INTO audit.user_events (user_id, event_type, event_data)
VALUES (
    (SELECT id FROM app.users WHERE email = 'admin@example.com'),
    'database_initialized',
    '{"message": "Development database initialized successfully"}'
);