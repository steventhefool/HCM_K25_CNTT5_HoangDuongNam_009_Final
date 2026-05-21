-- Tạo database để bắt đầu làm bài
CREATE DATABASE Manage_employee_db;
USE Manage_employee_db;


-- Tạo bảng

-- Bảng nhân viên
CREATE TABLE Employees (
	Employee_id INT PRIMARY KEY AUTO_INCREMENT,
    Full_name VARCHAR (50) NOT NULL,
    Email VARCHAR (50) NOT NULL UNIQUE,
    Phone_number VARCHAR (15) UNIQUE,
    Hire_date DATE DEFAULT (CURRENT_DATE),
    Salary INT,
    CONSTRAINT ck_salary CHECK (Salary>0)
);

-- Bảng thông tin nhân viên
CREATE TABLE Employee_Details (
	Detail_id INT PRIMARY KEY AUTO_INCREMENT,
    Employee_id INT NOT NULL UNIQUE,
    Citizen_id VARCHAR (15) NOT NULL UNIQUE,
    Address VARCHAR (50) NOT NULL,
    Working_status ENUM ('ACTIVE', 'INACTIVE'),
    CONSTRAINT fk_employee_id_1
		FOREIGN KEY (Employee_id)
        REFERENCES Employees (Employee_id)
);

-- Bảng phòng ban
CREATE TABLE Departments (
	Department_id INT PRIMARY KEY AUTO_INCREMENT,
    Department_name VARCHAR (50) NOT NULL UNIQUE,
    Description TEXT 
);

-- Bảng dự án
CREATE TABLE Projects (
	Project_id INT PRIMARY KEY AUTO_INCREMENT,
    Project_name VARCHAR (50) NOT NULL,
    Department_id INT NOT NULL,
    Budget INT,
    Project_status ENUM ('PENDING', 'DOING', 'DONE'),
    CONSTRAINT fk_department_id
		FOREIGN KEY (Department_id)
        REFERENCES Departments (Department_id),
	CONSTRAINT ck_budget
		CHECK (budget>0)
);

-- Bảng phân công công việc
CREATE TABLE Work_Assignments (
	Assignment_id INT PRIMARY KEY,
    Employee_id INT NOT NULL,
    Project_id INT NOT NULL,
    Start_date DATE NOT NULL,
    Deadline Date NOT NULL,
    Completed_date DATE,
    CONSTRAINT fk_employee_id_2
		FOREIGN KEY (Employee_id)
        REFERENCES Employees (Employee_id)
);

-- Phần 2: Chèn dữ liệu cho các bảng, phần DML

-- Câu 1: Insert
-- Bảng Employees
INSERT INTO Employees (full_name, email, phone_number, hire_date, salary) VALUES 
('Nguyen Van A', 'anv@gmail.com', '0901234567', '2022-01-15', 12000000),
('Tran Thi B', 'btt@gmail.com', '0912345678', '2021-05-20', 18000000),
('Le Van C', 'cle@yahoo.com', '0922334455', '2023-01-10', 9500000),
('Pham Minh D', 'dpham@hotmail.com', '0933445566', '2020-11-05', 22000000),
('Hoang Anh E', 'ehoang@gmail.com', '0944556677', '2023-01-12', 15000000)
;

-- Bảng Employee_Details
INSERT INTO Employee_Details (employee_id, citizen_id, address, working_status) VALUES 
(1, '123456789', 'Ha Noi', 'Active'),
(2, '234567890', 'Hai Phong', 'Active'),
(3, '345678901', 'Da Nang', 'Inactive'),
(4, '456789012', 'Ho Chi Minh', 'Active'),
(5, '567890123', 'Can Tho', 'Active')
;

-- Bảng Departments
INSERT INTO Departments (Department_name, description) VALUES 
('IT', 'Phòng công nghệ thông tin'),
('HR', 'Phòng nhân sự'),
('Marketing', 'Phòng marketing'),
('Finance', 'Phòng tài chính'),
('Sales', 'Phòng kinh doanh')
;

-- Bảng Projects
INSERT INTO Projects (Project_name, department_id, budget, project_status) VALUES 
('Website Company', 1, 50000000, 'Doing'),
('Recruitment 2025', 2, 20000000, 'Pending'),
('Ads Campaign', 3, 30000000, 'Doing'),
('Accounting System', 4, 45000000, 'Done'),
('Customer Expansion', 5, 25000000, 'Pending')
;

-- Để start_date phải nhỏ hơn deadline thì em sẽ viết một trigger để kiểm tra trước khi INSERT
DROP TRIGGER IF EXISTS check_date_bf_insert;
DELIMITER //
CREATE TRIGGER check_date_bf_insert
BEFORE INSERT ON Work_Assignments
FOR EACH ROW
BEGIN 
	IF (NEW.Start_date > NEW.Deadline) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngày bắt đầu phải nhỏ hơn deadline';
    END IF;
END//
DELIMITER ;

-- Bảng Work_Assignments
INSERT INTO Work_assignments (assignment_id, employee_id, project_id, start_date, deadline, completed_date) VALUES 
(101, 1, 1, '2024-01-10', '2024-02-10', NULL),
(102, 2, 2, '2024-02-01', '2024-03-01', '2024-02-25'),
(103, 3, 3, '2024-03-05', '2024-04-05', NULL),
(104, 4, 4, '2023-10-10', '2023-12-10', '2023-12-05'),
(105, 5, 5, '2024-04-01', '2024-05-01', NULL)
;

-- Cau 2: Update & Delelte
-- Update budget voi phong ban IT
UPDATE Projects p 
JOIN Departments d on p.department_id = d.department_id
SET budget = budget + 5000000
WHERE d.Department_name = 'IT'; 

-- Xoa ban ghi work_assignments ma completed is not null va ngay bat dau truoc 2024
DELETE FROM Work_assignments WHERE completed_date IS NOT NULL AND YEAR(START_DATE)<2024;

-- Phan 3: Truy van co ban
-- Cau 1: Truy van du lieu project cua phong ban IT va budget > 30000000
SELECT p.project_id, p.project_name, p.budget
FROM projects p
JOIN Departments d ON d.department_id = p.department_id
WHERE d.department_name = 'IT' AND budget > 30000000; 

-- Cau 2: Liet ke nhung nhan vien co ngay vao lam trong 2022 va email co ten mien la @gmail.com
SELECT employee_id, full_name, email
FROM Employees
WHERE YEAR(Hire_date) = 2022 AND Email LIKE '%@gmail.com';

-- Cau 3: Liet ke danh sach nhan vien duoc sap xpe theo luong giam dan va hien thi 3 nhan vien tu nguoi thu 2
SELECT employee_id, full_name, salary
FROM Employees
ORDER BY salary DESC
LIMIT 3 OFFSET 1;

-- Phan 4: Truy van nang cao
-- Cau 1: Lay cac thong tin phan cong voi du lieu duoc lay tu bang lien quan va chi hien cac cong viec chua hoan thanh
SELECT wa.assignment_id, e.full_name, p.project_name, wa.start_date, wa.deadline
FROM Work_Assignments wa
JOIN employees e ON e.employee_id = wa.employee_id
JOIN projects p ON p.project_id = wa.project_id
WHERE wa.completed_date IS NULL;

-- Cau 2: Liet ke tong ngan sach du an theo phong ban va chi hien thi nhung phong ban co tong ngan sach lon hon 40000000
SELECT d.department_name, SUM(p.budget) AS total_budget
FROM departments d
JOIN projects p ON d.department_id = p.department_id
GROUP BY d.department_name
HAVING total_budget > 40000000;

-- Cau 3: Liet ke thong tin nhan vien co trang thai lam viec la active nhung chua tham gia du an nao co budget lon hon 40000000
SELECT e.employee_id, e.full_name, ed.working_status
FROM Employees e
JOIN Employee_details ed ON e.employee_id = ed.employee_id
WHERE working_status = 'ACTIVE' 
AND e.employee_id NOT IN (SELECT wa.Employee_id FROM work_assignments wa JOIN Projects p WHERE p.budget <40000000);

-- Phan 5: INDEX & VIEW
-- Cau 1: Tao index voi start_date va completed_date
CREATE INDEX idx_assignment_dates ON Work_assignments (Start_date,completed_date);
-- Cau 2: tao view chua cac cong viec chua hoan thanh va da qua han
CREATE VIEW vw_overdue_assignments AS
SELECT wa.assignment_id, e.full_name, p.project_name, wa.start_date, wa.deadline 
FROM work_assignments wa
JOIN employees e ON wa.employee_id = e.employee_id
JOIN projects p ON p.project_id = wa.project_id
WHERE Completed_date IS NULL AND Deadline < CURDATE();

SELECT * FROM vw_overdue_assignments;

-- Phan 6: Trigger
-- Cau 1: Viet mot trigger khi them moi mot phan cong thi he thong tu dong cap nhat trang thai la doing

DROP TRIGGER IF EXISTS trg_after_assignment_insert;
DELIMITER //
CREATE TRIGGER trg_after_assignment_insert
AFTER INSERT ON Work_Assignments
FOR EACH ROW
BEGIN
	UPDATE Projects SET project_status = 'DOING' WHERE NEW.project_id = project_id;
END//
DELIMITER ;

INSERT INTO Work_assignments (assignment_id, employee_id, project_id, start_date, deadline, completed_date) VALUES 
(107, 4, 2, '2024-01-10', '2024-02-10', NULL);

-- Cau 2: viet mot trigger ngan chan viec xoa nhan vien neu van con cong viec chua hoan thanh
DROP TRIGGER IF EXISTS trg_prevent_delelte_employee;
DELIMITER //
CREATE TRIGGER trg_prevent_delelte_employee
BEFORE DELETE ON Employees
FOR EACH ROW
BEGIN
	IF EXISTS (SELECT 1 FROM work_assignments WHERE employee_id = OLD.employee_id AND Completed_date IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nhan vien con viec chua hoan thanh';
    END IF;
END//
DELIMITER ;

DELETE FROM Employees WHERE employee_id = 1;

-- Phan 7: Stored Procedure
-- Cau 1: Viet sp phan loai budget

DROP PROCEDURE IF EXISTS sp_check_project_budget;

DELIMITER //
CREATE PROCEDURE sp_check_project_budget (IN p_project_id INT, OUT p_message VARCHAR (50))
BEGIN
	-- Tao bien nhan ngan sach
	DECLARE p_budget int;
    SELECT budget INTO p_budget FROM projects WHERE p_project_id = project_id;
    IF (p_budget < 20000000) THEN
		SET p_message = 'Ngân sách thấp';
	ELSEIF (p_budget between 20000000 AND 40000000) THEN
		SET p_message = 'Ngân sách trung bình';
	ELSEIF (p_budget > 40000000) THEN
		SET p_message = 'Ngân sách cao';
    END IF;
END//
DELIMITER ;

CALL sp_check_project_budget (2, @msg);
SELECT @msg;

-- Cau 2: Viet sp xu ly cong viec bang transaction
-- B1: bdau gdich
-- B2: kiem tra cong viec hoan thanh chua
-- B3: cap nhat completed_date = curdate()
-- B4: Neu tat ca cong viec cua du an da hoan thanh -> cap nhat project_status = 'Done'
-- B5: Commit neu thanh cong, rollback neu co loi

DROP PROCEDURE IF EXISTS sp_complete_assignment_transaction;

DELIMITER //
CREATE PROCEDURE sp_complete_assignment_transaction (p_assignment_id INT, OUT p_message VARCHAR (50))
BEGIN
	START TRANSACTION;
    IF EXISTS(SELECT 1 FROM work_assignments 
				WHERE p_assignment_id = assignment_id 
                AND completed_date IS NOT NULL) THEN
				SET p_message = 'Công việc đã hoàn thành rồi';
                ROLLBACK;
	END IF;
	IF EXISTS(SELECT 1 FROM work_assignments 
				WHERE p_assignment_id = assignment_id 
                AND completed_date IS NULL) THEN
		UPDATE work_assignments SET completed_date = CURDATE() WHERE p_assignment_id = assignment_id;
        SET p_message = 'Đã xử lý hoàn thành công việc';
        COMMIT;
    END IF;
END//
DELIMITER ;

CALL sp_complete_assignment_transaction(102, @msg);
SELECT @msg;
CALL sp_complete_assignment_transaction(106, @msg);
SELECT @msg;

CALL sp_complete_assignment_transaction(107, @msg);
SELECT @msg;



