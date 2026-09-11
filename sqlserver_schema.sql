/* IT Help Desk - SQL Server 2019+ reference schema.
   Passwords are application-generated hashes; never insert plain passwords here. */
CREATE TABLE roles (id INT IDENTITY(1,1) PRIMARY KEY, name NVARCHAR(80) NOT NULL UNIQUE, description NVARCHAR(255));
CREATE TABLE permissions (id INT IDENTITY(1,1) PRIMARY KEY, code NVARCHAR(100) NOT NULL UNIQUE, description NVARCHAR(255));
CREATE TABLE role_permissions (role_id INT NOT NULL, permission_id INT NOT NULL, CONSTRAINT pk_role_permissions PRIMARY KEY(role_id,permission_id), CONSTRAINT fk_rp_role FOREIGN KEY(role_id) REFERENCES roles(id) ON DELETE CASCADE, CONSTRAINT fk_rp_permission FOREIGN KEY(permission_id) REFERENCES permissions(id) ON DELETE CASCADE);
CREATE TABLE departments (id INT IDENTITY(1,1) PRIMARY KEY, name NVARCHAR(120) NOT NULL UNIQUE, is_active BIT NOT NULL DEFAULT 1, created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME());
CREATE TABLE users (id INT IDENTITY(1,1) PRIMARY KEY, username NVARCHAR(80) NOT NULL UNIQUE, password_hash NVARCHAR(255) NOT NULL, full_name NVARCHAR(150) NOT NULL, email NVARCHAR(150), role_id INT NOT NULL, department_id INT NULL, is_active BIT NOT NULL DEFAULT 1, created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(), CONSTRAINT fk_users_role FOREIGN KEY(role_id) REFERENCES roles(id), CONSTRAINT fk_users_department FOREIGN KEY(department_id) REFERENCES departments(id));
CREATE TABLE categories (id INT IDENTITY(1,1) PRIMARY KEY, name NVARCHAR(80) NOT NULL UNIQUE, is_active BIT NOT NULL DEFAULT 1);
CREATE TABLE priorities (id INT IDENTITY(1,1) PRIMARY KEY, name NVARCHAR(30) NOT NULL UNIQUE, level INT NOT NULL UNIQUE, sla_minutes INT NOT NULL);
CREATE TABLE statuses (id INT IDENTITY(1,1) PRIMARY KEY, code NVARCHAR(30) NOT NULL UNIQUE, name NVARCHAR(60) NOT NULL, is_active BIT NOT NULL DEFAULT 1);
CREATE TABLE assets (id INT IDENTITY(1,1) PRIMARY KEY, asset_id NVARCHAR(40) NOT NULL UNIQUE, asset_code NVARCHAR(40) NOT NULL UNIQUE, device_type NVARCHAR(80) NOT NULL, brand NVARCHAR(80), model NVARCHAR(80), serial_number NVARCHAR(100), ip_address NVARCHAR(50), mac_address NVARCHAR(50), department_id INT NULL, assigned_user_id INT NULL, status NVARCHAR(40), purchase_date DATE, warranty NVARCHAR(120), notes NVARCHAR(MAX), FOREIGN KEY(department_id) REFERENCES departments(id), FOREIGN KEY(assigned_user_id) REFERENCES users(id));
CREATE TABLE tickets (id INT IDENTITY(1,1) PRIMARY KEY, ticket_number NVARCHAR(30) NOT NULL UNIQUE, title NVARCHAR(255) NOT NULL, description NVARCHAR(MAX) NOT NULL, requester_id INT NOT NULL, department_id INT NOT NULL, category_id INT NOT NULL, priority_id INT NOT NULL, status_id INT NOT NULL, asset_id INT NULL, technician_id INT NULL, resolution NVARCHAR(MAX), created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(), updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(), resolved_at DATETIME2 NULL, closed_at DATETIME2 NULL, FOREIGN KEY(requester_id) REFERENCES users(id), FOREIGN KEY(department_id) REFERENCES departments(id), FOREIGN KEY(category_id) REFERENCES categories(id), FOREIGN KEY(priority_id) REFERENCES priorities(id), FOREIGN KEY(status_id) REFERENCES statuses(id), FOREIGN KEY(asset_id) REFERENCES assets(id), FOREIGN KEY(technician_id) REFERENCES users(id));
CREATE TABLE ticket_history (id INT IDENTITY(1,1) PRIMARY KEY, ticket_id INT NOT NULL, user_id INT NOT NULL, action NVARCHAR(80) NOT NULL, old_value NVARCHAR(255), new_value NVARCHAR(255), created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(), FOREIGN KEY(ticket_id) REFERENCES tickets(id) ON DELETE CASCADE, FOREIGN KEY(user_id) REFERENCES users(id));
CREATE TABLE ticket_comments (id INT IDENTITY(1,1) PRIMARY KEY, ticket_id INT NOT NULL, user_id INT NOT NULL, comment NVARCHAR(MAX) NOT NULL, created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(), FOREIGN KEY(ticket_id) REFERENCES tickets(id) ON DELETE CASCADE, FOREIGN KEY(user_id) REFERENCES users(id));
CREATE TABLE audit_logs (id INT IDENTITY(1,1) PRIMARY KEY, user_id INT NULL, action NVARCHAR(100) NOT NULL, entity NVARCHAR(80), entity_id NVARCHAR(80), old_value NVARCHAR(MAX), new_value NVARCHAR(MAX), ip_address NVARCHAR(50), created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(), FOREIGN KEY(user_id) REFERENCES users(id));
CREATE TABLE notifications (id INT IDENTITY(1,1) PRIMARY KEY, user_id INT NOT NULL, message NVARCHAR(500) NOT NULL, link NVARCHAR(255), is_read BIT NOT NULL DEFAULT 0, created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(), FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE);
CREATE TABLE attachments (id INT IDENTITY(1,1) PRIMARY KEY, ticket_id INT NOT NULL, user_id INT NOT NULL, filename NVARCHAR(255) NOT NULL, stored_name NVARCHAR(255) NOT NULL UNIQUE, created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(), FOREIGN KEY(ticket_id) REFERENCES tickets(id) ON DELETE CASCADE, FOREIGN KEY(user_id) REFERENCES users(id));
CREATE TABLE sla_settings (id INT IDENTITY(1,1) PRIMARY KEY, priority_id INT NOT NULL UNIQUE, warning_percent INT NOT NULL DEFAULT 75, FOREIGN KEY(priority_id) REFERENCES priorities(id) ON DELETE CASCADE);
CREATE TABLE ratings (id INT IDENTITY(1,1) PRIMARY KEY, ticket_id INT NOT NULL UNIQUE, user_id INT NOT NULL, score INT NOT NULL, comment NVARCHAR(1000), created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(), FOREIGN KEY(ticket_id) REFERENCES tickets(id) ON DELETE CASCADE, FOREIGN KEY(user_id) REFERENCES users(id), CONSTRAINT ck_rating_score CHECK(score BETWEEN 1 AND 5));
CREATE INDEX ix_users_department ON users(department_id);
CREATE INDEX ix_users_role ON users(role_id);
CREATE INDEX ix_assets_department ON assets(department_id);
CREATE INDEX ix_assets_assigned_user ON assets(assigned_user_id);
CREATE INDEX ix_assets_serial ON assets(serial_number);
CREATE INDEX ix_tickets_requester ON tickets(requester_id);
CREATE INDEX ix_tickets_department ON tickets(department_id);
CREATE INDEX ix_tickets_category ON tickets(category_id);
CREATE INDEX ix_tickets_priority ON tickets(priority_id);
CREATE INDEX ix_tickets_status ON tickets(status_id);
CREATE INDEX ix_tickets_technician ON tickets(technician_id);
CREATE INDEX ix_tickets_asset ON tickets(asset_id);
CREATE INDEX ix_tickets_created ON tickets(created_at);
CREATE INDEX ix_ticket_history_ticket ON ticket_history(ticket_id);
CREATE INDEX ix_ticket_comments_ticket ON ticket_comments(ticket_id);
CREATE INDEX ix_audit_created ON audit_logs(created_at);
CREATE INDEX ix_notifications_user_read ON notifications(user_id,is_read);

-- V4: Arabic knowledge base
CREATE TABLE knowledge_articles (id INT IDENTITY(1,1) PRIMARY KEY, title NVARCHAR(255) NOT NULL, category_id INT NULL, problem NVARCHAR(MAX) NOT NULL, solution NVARCHAR(MAX) NOT NULL, keywords NVARCHAR(500), is_published BIT NOT NULL DEFAULT 1, created_by_id INT NOT NULL, updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(), created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(), FOREIGN KEY(category_id) REFERENCES categories(id), FOREIGN KEY(created_by_id) REFERENCES users(id));
CREATE INDEX ix_knowledge_title ON knowledge_articles(title);
CREATE INDEX ix_knowledge_category ON knowledge_articles(category_id);
CREATE INDEX ix_knowledge_published ON knowledge_articles(is_published);
