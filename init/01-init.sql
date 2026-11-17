CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    role VARCHAR(20) DEFAULT 'student'
);
INSERT INTO users (name) VALUES ('Иван'), ('Мария');