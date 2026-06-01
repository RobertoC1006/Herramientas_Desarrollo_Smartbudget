DROP DATABASE IF EXISTS smartbudget_db;
CREATE DATABASE smartbudget_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smartbudget_db;

-- 1. Tabla de Usuarios
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Tabla de Presupuestos Mensuales
CREATE TABLE budgets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    mes INT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    anio INT NOT NULL,
    monto_base DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    ingresos_adicionales DECIMAL(10,2) DEFAULT 0.00,
    total_gastado DECIMAL(10,2) DEFAULT 0.00,
    saldo_disponible DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_budget FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT unique_budget UNIQUE (user_id, mes, anio)
) ENGINE=InnoDB;

-- 3. Tabla de Gastos
CREATE TABLE expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    budget_id INT NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    descripcion VARCHAR(255) NULL,
    comercio VARCHAR(150) NULL,
    fecha DATE NOT NULL,
    fuente ENUM('MANUAL', 'OCR', 'AUTOMATIC') DEFAULT 'MANUAL',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_expenses_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_expenses_budget FOREIGN KEY (budget_id) REFERENCES budgets(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. Tabla de Metas de Ahorro
CREATE TABLE goals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    monto_objetivo DECIMAL(10,2) NOT NULL,
    monto_actual DECIMAL(10,2) DEFAULT 0.00,
    fecha_limite DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_goals_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. Tabla de Contribuciones a Metas
CREATE TABLE goal_contributions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    goal_id INT NOT NULL,
    budget_id INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha DATE NOT NULL,
    CONSTRAINT fk_contrib_goal FOREIGN KEY (goal_id) REFERENCES goals(id) ON DELETE CASCADE,
    CONSTRAINT fk_contrib_budget FOREIGN KEY (budget_id) REFERENCES budgets(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 6. Tabla de Alertas
CREATE TABLE alerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    mensaje TEXT NOT NULL,
    tipo ENUM('INFO', 'WARNING', 'DANGER') DEFAULT 'INFO',
    leida TINYINT(1) NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_alerts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. Tabla de Historial SmartScore
CREATE TABLE smart_score_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    score INT NOT NULL CHECK (score BETWEEN 0 AND 100),
    mes INT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    anio INT NOT NULL,
    descripcion TEXT NULL,
    fecha_calculo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_score_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Triggers automáticos
DELIMITER $$

CREATE TRIGGER trg_budget_insert
BEFORE INSERT ON budgets
FOR EACH ROW
BEGIN
    SET NEW.saldo_disponible = NEW.monto_base + NEW.ingresos_adicionales - NEW.total_gastado;
END$$

CREATE TRIGGER trg_budget_update
BEFORE UPDATE ON budgets
FOR EACH ROW
BEGIN
    SET NEW.saldo_disponible = NEW.monto_base + NEW.ingresos_adicionales - NEW.total_gastado;
END$$

CREATE TRIGGER trg_expense_insert
AFTER INSERT ON expenses
FOR EACH ROW
BEGIN
    UPDATE budgets
    SET total_gastado = total_gastado + NEW.monto
    WHERE id = NEW.budget_id;
END$$

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