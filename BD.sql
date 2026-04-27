 
DROP DATABASE IF EXISTS smartbudget_db;
CREATE DATABASE smartbudget_db;
USE smartbudget_db;

 
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

 
CREATE TABLE budgets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    mes INT NOT NULL,
    anio INT NOT NULL,
    monto_base DECIMAL(10,2) NOT NULL,
    ingresos_adicionales DECIMAL(10,2) DEFAULT 0,
    total_gastado DECIMAL(10,2) DEFAULT 0,
    saldo_disponible DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_budget
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT unique_budget
        UNIQUE (user_id, mes, anio)
);

 
CREATE TABLE expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    budget_id INT NOT NULL,
    categoria VARCHAR(100),
    monto DECIMAL(10,2) NOT NULL,
    fecha DATE NOT NULL,
    descripcion TEXT,
    origen ENUM('manual', 'ocr') DEFAULT 'manual',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (budget_id) REFERENCES budgets(id) ON DELETE CASCADE
);

 
CREATE TABLE goals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    monto_objetivo DECIMAL(10,2) NOT NULL,
    monto_actual DECIMAL(10,2) DEFAULT 0,
    fecha_limite DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

 
CREATE TABLE goal_contributions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    goal_id INT NOT NULL,
    budget_id INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha DATE NOT NULL,

    FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    FOREIGN KEY (budget_id) REFERENCES budgets(id) ON DELETE CASCADE
);

 
CREATE TABLE alerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    tipo VARCHAR(50),
    mensaje TEXT,
    nivel ENUM('info', 'warning', 'danger') DEFAULT 'info',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

 
CREATE TABLE smart_score_snapshots (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    score INT,
    descripcion TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

 
DELIMITER $$

-- 🔹 Calcular saldo automáticamente
CREATE TRIGGER trg_budget_insert
BEFORE INSERT ON budgets
FOR EACH ROW
BEGIN
    SET NEW.saldo_disponible = 
        NEW.monto_base + NEW.ingresos_adicionales - NEW.total_gastado;
END$$

CREATE TRIGGER trg_budget_update
BEFORE UPDATE ON budgets
FOR EACH ROW
BEGIN
    SET NEW.saldo_disponible = 
        NEW.monto_base + NEW.ingresos_adicionales - NEW.total_gastado;
END$$

-- 🔹 Actualizar gasto total al insertar gasto
CREATE TRIGGER trg_expense_insert
AFTER INSERT ON expenses
FOR EACH ROW
BEGIN
    UPDATE budgets
    SET total_gastado = total_gastado + NEW.monto
    WHERE id = NEW.budget_id;
END$$

-- 🔹 Restar presupuesto al aportar a meta
CREATE TRIGGER trg_goal_contribution
AFTER INSERT ON goal_contributions
FOR EACH ROW
BEGIN
    UPDATE goals
    SET monto_actual = monto_actual + NEW.monto
    WHERE id = NEW.goal_id;

    UPDATE budgets
    SET total_gastado = total_gastado + NEW.monto
    WHERE id = NEW.budget_id;
END$$

DELIMITER ;

 
CREATE INDEX idx_expenses_user ON expenses(user_id);
CREATE INDEX idx_expenses_budget ON expenses(budget_id);
CREATE INDEX idx_goals_user ON goals(user_id);
CREATE INDEX idx_alerts_user ON alerts(user_id);

 
INSERT INTO users (nombre, email, hashed_password)
VALUES ('Gabriel', 'gabriel@test.com', '123456');

INSERT INTO budgets (user_id, mes, anio, monto_base, ingresos_adicionales)
VALUES (1, 4, 2026, 1500, 300);

INSERT INTO expenses (user_id, budget_id, categoria, monto, fecha, descripcion)
VALUES (1, 1, 'Comida', 50, '2026-04-20', 'Almuerzo');

INSERT INTO goals (user_id, nombre, monto_objetivo)
VALUES (1, 'Viaje a la playa', 500);

INSERT INTO goal_contributions (goal_id, budget_id, monto, fecha)
VALUES (1, 1, 100, '2026-04-21');

 
SELECT * FROM users;
SELECT * FROM budgets;
SELECT * FROM expenses;
SELECT * FROM goals;
SELECT * FROM goal_contributions;
SELECT * FROM alerts;
SELECT * FROM smart_score_snapshots;