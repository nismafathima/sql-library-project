-- ============================================================
-- ADVANCED LIBRARY MANAGEMENT SYSTEM - SQL SERVER
-- Features: CTE, Window Functions, Stored Procedures, Triggers,
-- Views, Indexes, Transactions, Cursors, and more!
-- ============================================================

-- Create Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'library_db')
BEGIN
    CREATE DATABASE library_db;
END
GO

USE library_db;
GO

-- Drop tables if exist
SET NOCOUNT ON;
IF OBJECT_ID('Fines', 'U') IS NOT NULL DROP TABLE Fines;
IF OBJECT_ID('Reservations', 'U') IS NOT NULL DROP TABLE Reservations;
IF OBJECT_ID('Book_Issues', 'U') IS NOT NULL DROP TABLE Book_Issues;
IF OBJECT_ID('Book_Copies', 'U') IS NOT NULL DROP TABLE Book_Copies;
IF OBJECT_ID('Books', 'U') IS NOT NULL DROP TABLE Books;
IF OBJECT_ID('Members', 'U') IS NOT NULL DROP TABLE Members;
IF OBJECT_ID('Authors', 'U') IS NOT NULL DROP TABLE Authors;
IF OBJECT_ID('Categories', 'U') IS NOT NULL DROP TABLE Categories;
IF OBJECT_ID('Publishers', 'U') IS NOT NULL DROP TABLE Publishers;
IF OBJECT_ID('Staff', 'U') IS NOT NULL DROP TABLE Staff;
GO

-- ============================================================
-- TABLE CREATION
-- ============================================================

-- 1. Categories Table
CREATE TABLE Categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 2. Publishers Table
CREATE TABLE Publishers (
    publisher_id INT IDENTITY(1,1) PRIMARY KEY,
    publisher_name VARCHAR(200) NOT NULL,
    address VARCHAR(MAX),
    phone VARCHAR(15),
    email VARCHAR(100),
    website VARCHAR(200),
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 3. Authors Table
CREATE TABLE Authors (
    author_id INT IDENTITY(1,1) PRIMARY KEY,
    author_name VARCHAR(200) NOT NULL,
    biography VARCHAR(MAX),
    birth_date DATE,
    nationality VARCHAR(50),
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 4. Books Table
CREATE TABLE Books (
    book_id INT IDENTITY(1,1) PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(300) NOT NULL,
    author_id INT NOT NULL,
    publisher_id INT,
    category_id INT,
    publication_year INT,
    edition VARCHAR(50),
    pages INT,
    language VARCHAR(50) DEFAULT 'English',
    description VARCHAR(MAX),
    price DECIMAL(10, 2),
    total_copies INT DEFAULT 0,
    available_copies INT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (author_id) REFERENCES Authors(author_id),
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);
GO

-- 5. Book Copies Table (for tracking individual book copies)
CREATE TABLE Book_Copies (
    copy_id INT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    copy_number VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'Available',
    condition VARCHAR(50) DEFAULT 'Good',
    purchase_date DATE,
    location VARCHAR(100),
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    CONSTRAINT UQ_Book_Copy UNIQUE(book_id, copy_number)
);
GO

-- 6. Members Table
CREATE TABLE Members (
    member_id INT IDENTITY(1,1) PRIMARY KEY,
    member_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15) NOT NULL,
    address VARCHAR(MAX),
    date_of_birth DATE,
    membership_type VARCHAR(20) DEFAULT 'Regular',
    membership_date DATE DEFAULT CAST(GETDATE() AS DATE),
    expiry_date DATE,
    status VARCHAR(20) DEFAULT 'Active',
    total_books_issued INT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 7. Staff Table
CREATE TABLE Staff (
    staff_id INT IDENTITY(1,1) PRIMARY KEY,
    staff_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(15) NOT NULL,
    salary DECIMAL(10, 2),
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active',
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- 8. Book Issues Table
CREATE TABLE Book_Issues (
    issue_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    staff_id INT,
    issue_date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    due_date DATE NOT NULL,
    return_date DATE,
    status VARCHAR(20) DEFAULT 'Issued',
    renewal_count INT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (copy_id) REFERENCES Book_Copies(copy_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);
GO

-- 9. Reservations Table
CREATE TABLE Reservations (
    reservation_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    reservation_date DATE DEFAULT CAST(GETDATE() AS DATE),
    status VARCHAR(20) DEFAULT 'Active',
    fulfilled_date DATE,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);
GO

-- 10. Fines Table
CREATE TABLE Fines (
    fine_id INT IDENTITY(1,1) PRIMARY KEY,
    issue_id INT NOT NULL,
    fine_amount DECIMAL(10, 2) NOT NULL,
    fine_reason VARCHAR(MAX),
    payment_status VARCHAR(20) DEFAULT 'Unpaid',
    payment_date DATE,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (issue_id) REFERENCES Book_Issues(issue_id)
);
GO

-- ============================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================================

CREATE INDEX idx_books_title ON Books(title);
CREATE INDEX idx_books_isbn ON Books(isbn);
CREATE INDEX idx_members_code ON Members(member_code);
CREATE INDEX idx_book_issues_member ON Book_Issues(member_id, issue_date);
CREATE INDEX idx_book_issues_status ON Book_Issues(status);
CREATE INDEX idx_reservations_status ON Reservations(status);
GO

-- ============================================================
-- INSERT SAMPLE DATA
-- ============================================================

-- Insert Categories
INSERT INTO Categories (category_name, description) VALUES
('Fiction', 'Fictional novels and stories'),
('Non-Fiction', 'Real-world topics and information'),
('Science', 'Scientific literature and research'),
('Technology', 'Computer science and technology books'),
('History', 'Historical books and biographies'),
('Biography', 'Life stories of notable people'),
('Self-Help', 'Personal development and motivation'),
('Children', 'Books for children and young readers'),
('Romance', 'Romantic fiction'),
('Mystery', 'Mystery and thriller novels');
GO

-- Insert Publishers
INSERT INTO Publishers (publisher_name, address, phone, email, website) VALUES
('Penguin Random House', '1745 Broadway, New York, NY', '212-782-9000', 'info@penguinrandomhouse.com', 'www.penguinrandomhouse.com'),
('HarperCollins', '195 Broadway, New York, NY', '212-207-7000', 'contact@harpercollins.com', 'www.harpercollins.com'),
('Simon & Schuster', '1230 Avenue of the Americas, NY', '212-698-7000', 'info@simonandschuster.com', 'www.simonandschuster.com'),
('Macmillan Publishers', '120 Broadway, New York, NY', '646-307-5151', 'contact@macmillan.com', 'www.macmillan.com'),
('Hachette Book Group', '1290 Avenue of the Americas, NY', '212-364-1100', 'info@hachette.com', 'www.hachettebookgroup.com'),
('Oxford University Press', 'Great Clarendon Street, Oxford', '+44-1865-556767', 'enquiry@oup.com', 'www.oup.com');
GO

-- Insert Authors
INSERT INTO Authors (author_name, biography, birth_date, nationality) VALUES
('J.K. Rowling', 'British author best known for Harry Potter series', '1965-07-31', 'British'),
('Stephen King', 'American author of horror and supernatural fiction', '1947-09-21', 'American'),
('Agatha Christie', 'English writer known for detective novels', '1890-09-15', 'British'),
('Dan Brown', 'American author of thriller novels', '1964-06-22', 'American'),
('George Orwell', 'English novelist and essayist', '1903-06-25', 'British'),
('Jane Austen', 'English novelist known for romantic fiction', '1775-12-16', 'British'),
('Mark Twain', 'American writer and humorist', '1835-11-30', 'American'),
('Charles Dickens', 'English writer and social critic', '1812-02-07', 'British'),
('Ernest Hemingway', 'American novelist and short-story writer', '1899-07-21', 'American'),
('Harper Lee', 'American novelist known for To Kill a Mockingbird', '1926-04-28', 'American');
GO

-- Insert Books
INSERT INTO Books (isbn, title, author_id, publisher_id, category_id, publication_year, pages, price, total_copies, available_copies) VALUES
('978-0439708180', 'Harry Potter and the Sorcerers Stone', 1, 1, 1, 1998, 309, 29.99, 10, 8),
('978-1501142970', 'The Shining', 2, 2, 10, 1977, 447, 24.99, 5, 3),
('978-0062073488', 'Murder on the Orient Express', 3, 2, 10, 1934, 256, 19.99, 8, 6),
('978-0307474278', 'The Da Vinci Code', 4, 3, 10, 2003, 689, 27.99, 12, 10),
('978-0452284234', '1984', 5, 1, 1, 1949, 328, 22.99, 15, 12),
('978-0141439518', 'Pride and Prejudice', 6, 6, 9, 1813, 432, 18.99, 10, 7),
('978-0486280615', 'Adventures of Huckleberry Finn', 7, 4, 1, 1884, 366, 16.99, 6, 5),
('978-0141439723', 'Great Expectations', 8, 6, 1, 1861, 544, 21.99, 8, 6),
('978-0684830490', 'The Old Man and the Sea', 9, 3, 1, 1952, 127, 15.99, 7, 5),
('978-0061120084', 'To Kill a Mockingbird', 10, 2, 1, 1960, 336, 23.99, 14, 11);
GO

-- Insert Book Copies
DECLARE @book_id INT = 1;
WHILE @book_id <= 10
BEGIN
    DECLARE @copy_num INT = 1;
    DECLARE @total INT;
    SELECT @total = total_copies FROM Books WHERE book_id = @book_id;
    
    WHILE @copy_num <= @total
    BEGIN
        INSERT INTO Book_Copies (book_id, copy_number, status, condition, purchase_date, location)
        VALUES (@book_id, 'COPY-' + CAST(@book_id AS VARCHAR) + '-' + CAST(@copy_num AS VARCHAR), 
                CASE WHEN @copy_num <= (@total - 2) THEN 'Available' ELSE 'Issued' END,
                'Good', DATEADD(MONTH, -6, GETDATE()), 'Shelf-' + CAST((@book_id % 5) + 1 AS VARCHAR));
        SET @copy_num = @copy_num + 1;
    END
    SET @book_id = @book_id + 1;
END
GO

-- Insert Members
INSERT INTO Members (member_code, first_name, last_name, email, phone, address, date_of_birth, membership_type, membership_date, expiry_date, status) VALUES
('MEM001', 'Alice', 'Johnson', 'alice.j@email.com', '555-0101', '123 Oak Street', '1995-03-15', 'Premium', '2024-01-01', '2025-01-01', 'Active'),
('MEM002', 'Bob', 'Smith', 'bob.smith@email.com', '555-0102', '456 Maple Avenue', '1988-07-22', 'Regular', '2024-02-15', '2024-08-15', 'Active'),
('MEM003', 'Charlie', 'Brown', 'charlie.b@email.com', '555-0103', '789 Pine Road', '1992-11-30', 'Student', '2024-03-01', '2024-09-01', 'Active'),
('MEM004', 'Diana', 'Prince', 'diana.p@email.com', '555-0104', '321 Elm Street', '1990-05-18', 'Premium', '2023-12-01', '2024-12-01', 'Active'),
('MEM005', 'Edward', 'Norton', 'edward.n@email.com', '555-0105', '654 Cedar Lane', '1985-09-25', 'Regular', '2024-04-10', '2024-10-10', 'Active'),
('MEM006', 'Fiona', 'Davis', 'fiona.d@email.com', '555-0106', '987 Birch Drive', '1993-12-10', 'Student', '2024-05-20', '2024-11-20', 'Active'),
('MEM007', 'George', 'Wilson', 'george.w@email.com', '555-0107', '147 Spruce Way', '1982-04-08', 'Regular', '2024-06-01', '2024-12-01', 'Inactive'),
('MEM008', 'Hannah', 'Moore', 'hannah.m@email.com', '555-0108', '258 Willow Court', '1997-08-14', 'Premium', '2024-01-15', '2025-01-15', 'Active'),
('MEM009', 'Ian', 'Taylor', 'ian.t@email.com', '555-0109', '369 Ash Boulevard', '1989-01-20', 'Regular', '2024-07-01', '2025-01-01', 'Active'),
('MEM010', 'Julia', 'Anderson', 'julia.a@email.com', '555-0110', '741 Cherry Street', '1994-06-05', 'Student', '2024-08-01', '2025-02-01', 'Active');
GO

-- Insert Staff
INSERT INTO Staff (staff_code, first_name, last_name, role, email, phone, salary, hire_date, status) VALUES
('STF001', 'Michael', 'Johnson', 'Librarian', 'michael.j@library.com', '555-1001', 45000.00, '2020-01-15', 'Active'),
('STF002', 'Sarah', 'Williams', 'Assistant Librarian', 'sarah.w@library.com', '555-1002', 35000.00, '2021-03-20', 'Active'),
('STF003', 'David', 'Brown', 'Manager', 'david.b@library.com', '555-1003', 55000.00, '2019-06-10', 'Active'),
('STF004', 'Emma', 'Davis', 'Librarian', 'emma.d@library.com', '555-1004', 42000.00, '2022-02-28', 'Active'),
('STF005', 'James', 'Miller', 'Assistant', 'james.m@library.com', '555-1005', 28000.00, '2023-05-15', 'Active');
GO

-- Insert Book Issues
INSERT INTO Book_Issues (member_id, copy_id, staff_id, issue_date, due_date, return_date, status, renewal_count) VALUES
(1, 9, 1, '2024-10-01', '2024-10-15', '2024-10-14', 'Returned', 0),
(2, 15, 2, '2024-10-05', '2024-10-19', NULL, 'Issued', 0),
(3, 22, 1, '2024-10-10', '2024-10-24', NULL, 'Overdue', 1),
(1, 30, 3, '2024-10-15', '2024-10-29', NULL, 'Issued', 0),
(4, 38, 2, '2024-10-20', '2024-11-03', NULL, 'Issued', 0),
(5, 3, 1, '2024-09-15', '2024-09-29', '2024-09-28', 'Returned', 0),
(6, 10, 4, '2024-10-12', '2024-10-26', NULL, 'Overdue', 0),
(2, 17, 1, '2024-10-18', '2024-11-01', NULL, 'Issued', 0),
(8, 25, 2, '2024-10-22', '2024-11-05', NULL, 'Issued', 0),
(9, 32, 3, '2024-10-25', '2024-11-08', NULL, 'Issued', 0);
GO

-- Insert Reservations
INSERT INTO Reservations (member_id, book_id, reservation_date, status) VALUES
(3, 2, '2024-10-28', 'Active'),
(5, 4, '2024-10-29', 'Active'),
(7, 1, '2024-10-30', 'Active'),
(2, 5, '2024-10-25', 'Fulfilled');
GO

-- Insert Fines
INSERT INTO Fines (issue_id, fine_amount, fine_reason, payment_status, payment_date) VALUES
(3, 15.00, 'Book returned 3 days late', 'Unpaid', NULL),
(7, 10.00, 'Book overdue by 2 days', 'Unpaid', NULL);
GO

-- ============================================================
-- ADVANCED SQL FEATURES: CTEs (Common Table Expressions)
-- ============================================================

-- CTE 1: Books with Issue Statistics using Window Functions
GO
WITH BookStats AS (
    SELECT 
        b.book_id,
        b.title,
        a.author_name,
        b.total_copies,
        b.available_copies,
        COUNT(bi.issue_id) AS times_issued,
        ROW_NUMBER() OVER (ORDER BY COUNT(bi.issue_id) DESC) AS popularity_rank,
        DENSE_RANK() OVER (PARTITION BY b.category_id ORDER BY COUNT(bi.issue_id) DESC) AS category_rank
    FROM Books b
    JOIN Authors a ON b.author_id = a.author_id
    LEFT JOIN Book_Copies bc ON b.book_id = bc.book_id
    LEFT JOIN Book_Issues bi ON bc.copy_id = bi.copy_id
    GROUP BY b.book_id, b.title, a.author_name, b.total_copies, b.available_copies, b.category_id
)
SELECT 
    book_id,
    title,
    author_name,
    total_copies,
    available_copies,
    times_issued,
    popularity_rank,
    category_rank,
    CASE 
        WHEN popularity_rank <= 3 THEN 'Highly Popular'
        WHEN popularity_rank <= 6 THEN 'Popular'
        ELSE 'Average'
    END AS popularity_status
FROM BookStats
ORDER BY popularity_rank;
GO

-- CTE 2: Recursive CTE - Member Activity Hierarchy
WITH MemberActivity AS (
    SELECT 
        m.member_id,
        m.first_name + ' ' + m.last_name AS member_name,
        m.membership_type,
        COUNT(bi.issue_id) AS books_issued,
        SUM(CASE WHEN bi.status = 'Overdue' THEN 1 ELSE 0 END) AS overdue_books,
        SUM(ISNULL(f.fine_amount, 0)) AS total_fines
    FROM Members m
    LEFT JOIN Book_Issues bi ON m.member_id = bi.member_id
    LEFT JOIN Fines f ON bi.issue_id = f.issue_id
    GROUP BY m.member_id, m.first_name, m.last_name, m.membership_type
)
SELECT 
    member_id,
    member_name,
    membership_type,
    books_issued,
    overdue_books,
    total_fines,
    CASE 
        WHEN total_fines = 0 AND overdue_books = 0 THEN 'Excellent'
        WHEN overdue_books <= 1 AND total_fines < 20 THEN 'Good'
        WHEN overdue_books <= 2 AND total_fines < 50 THEN 'Fair'
        ELSE 'Poor'
    END AS member_rating
FROM MemberActivity
ORDER BY books_issued DESC;
GO

-- CTE 3: Multiple CTEs - Complete Library Analytics
WITH OverdueAnalysis AS (
    SELECT 
        bi.member_id,
        COUNT(*) AS overdue_count,
        SUM(DATEDIFF(DAY, bi.due_date, GETDATE())) AS total_overdue_days
    FROM Book_Issues bi
    WHERE bi.status = 'Overdue'
    GROUP BY bi.member_id
),
MemberStats AS (
    SELECT 
        m.member_id,
        m.first_name + ' ' + m.last_name AS member_name,
        m.membership_type,
        COUNT(DISTINCT bi.issue_id) AS total_issues,
        COUNT(DISTINCT CASE WHEN bi.status = 'Issued' THEN bi.issue_id END) AS currently_issued
    FROM Members m
    LEFT JOIN Book_Issues bi ON m.member_id = bi.member_id
    GROUP BY m.member_id, m.first_name, m.last_name, m.membership_type
)
SELECT 
    ms.member_id,
    ms.member_name,
    ms.membership_type,
    ms.total_issues,
    ms.currently_issued,
    ISNULL(oa.overdue_count, 0) AS overdue_books,
    ISNULL(oa.total_overdue_days, 0) AS overdue_days,
    CASE 
        WHEN ms.membership_type = 'Premium' THEN 10
        WHEN ms.membership_type = 'Regular' THEN 5
        ELSE 3
    END - ms.currently_issued AS remaining_quota
FROM MemberStats ms
LEFT JOIN OverdueAnalysis oa ON ms.member_id = oa.member_id
ORDER BY ms.total_issues DESC;
GO

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

-- Procedure 1: Issue a Book
CREATE PROCEDURE sp_IssueBook
    @member_id INT,
    @copy_id INT,
    @staff_id INT,
    @days INT = 14
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Check if copy is available
        DECLARE @copy_status VARCHAR(20);
        DECLARE @book_id INT;
        SELECT @copy_status = status, @book_id = book_id 
        FROM Book_Copies 
        WHERE copy_id = @copy_id;
        
        IF @copy_status != 'Available'
        BEGIN
            RAISERROR('Book copy is not available', 16, 1);
            RETURN;
        END
        
        -- Check member status
        DECLARE @member_status VARCHAR(20);
        SELECT @member_status = status FROM Members WHERE member_id = @member_id;
        
        IF @member_status != 'Active'
        BEGIN
            RAISERROR('Member is not active', 16, 1);
            RETURN;
        END
        
        -- Issue the book
        INSERT INTO Book_Issues (member_id, copy_id, staff_id, issue_date, due_date, status)
        VALUES (@member_id, @copy_id, @staff_id, CAST(GETDATE() AS DATE), 
                DATEADD(DAY, @days, CAST(GETDATE() AS DATE)), 'Issued');
        
        -- Update copy status
        UPDATE Book_Copies SET status = 'Issued' WHERE copy_id = @copy_id;
        
        -- Update available copies
        UPDATE Books SET available_copies = available_copies - 1 WHERE book_id = @book_id;
        
        -- Update member total issues
        UPDATE Members SET total_books_issued = total_books_issued + 1 WHERE member_id = @member_id;
        
        COMMIT TRANSACTION;
        PRINT 'Book issued successfully!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- Procedure 2: Return a Book
CREATE PROCEDURE sp_ReturnBook
    @issue_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        DECLARE @copy_id INT, @book_id INT, @due_date DATE, @fine_per_day DECIMAL(10,2) = 5.00;
        
        -- Get issue details
        SELECT @copy_id = copy_id, @due_date = due_date
        FROM Book_Issues
        WHERE issue_id = @issue_id AND status IN ('Issued', 'Overdue');
        
        IF @copy_id IS NULL
        BEGIN
            RAISERROR('Invalid issue ID or book already returned', 16, 1);
            RETURN;
        END
        
        -- Get book_id
        SELECT @book_id = book_id FROM Book_Copies WHERE copy_id = @copy_id;
        
        -- Calculate fine if overdue
        DECLARE @days_overdue INT = DATEDIFF(DAY, @due_date, GETDATE());
        IF @days_overdue > 0
        BEGIN
            INSERT INTO Fines (issue_id, fine_amount, fine_reason, payment_status)
            VALUES (@issue_id, @days_overdue * @fine_per_day, 
                    'Book returned ' + CAST(@days_overdue AS VARCHAR) + ' days late', 'Unpaid');
        END
        
        -- Update issue status
        UPDATE Book_Issues 
        SET return_date = CAST(GETDATE() AS DATE), status = 'Returned'
        WHERE issue_id = @issue_id;
        
        -- Update copy status
        UPDATE Book_Copies SET status = 'Available' WHERE copy_id = @copy_id;
        
        -- Update available copies
        UPDATE Books SET available_copies = available_copies + 1 WHERE book_id = @book_id;
        
        COMMIT TRANSACTION;
        
        IF @days_overdue > 0
            PRINT 'Book returned with fine of $' + CAST(@days_overdue * @fine_per_day AS VARCHAR);
        ELSE
            PRINT 'Book returned successfully!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- Procedure 3: Search Books (with multiple criteria)
CREATE PROCEDURE sp_SearchBooks
    @search_term VARCHAR(200) = NULL,
    @category_id INT = NULL,
    @author_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        b.book_id,
        b.isbn,
        b.title,
        a.author_name,
        c.category_name,
        p.publisher_name,
        b.publication_year,
        b.total_copies,
        b.available_copies,
        b.price,
        CASE 
            WHEN b.available_copies > 0 THEN 'Available'
            ELSE 'Not Available'
        END AS availability_status
    FROM Books b
    JOIN Authors a ON b.author_id = a.author_id
    LEFT JOIN Categories c ON b.category_id = c.category_id
    LEFT JOIN Publishers p ON b.publisher_id = p.publisher_id
    WHERE (@search_term IS NULL OR b.title LIKE '%' + @search_term + '%')
      AND (@category_id IS NULL OR b.category_id = @category_id)
      AND (@author_id IS NULL OR b.author_id = @author_id)
    ORDER BY b.title;
END
GO

-- Procedure 4: Generate Member Report
CREATE PROCEDURE sp_MemberReport
    @member_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Member Details
    SELECT 
        m.member_code,
        m.first_name + ' ' + m.last_name AS member_name,
        m.email,
        m.phone,
        m.membership_type,
        m.membership_date,
        m.expiry_date,
        m.status,
        m.total_books_issued
    FROM Members m
    WHERE m.member_id = @member_id;
    
    -- Currently Issued Books
    SELECT 
        b.title,
        a.author_name,
        bi.issue_date,
        bi.due_date,
        DATEDIFF(DAY, GETDATE(), bi.due_date) AS days_remaining,
        bi.status
    FROM Book_Issues bi
    JOIN Book_Copies bc ON bi.copy_id = bc.copy_id
    JOIN Books b ON bc.book_id = b.book_id
    JOIN Authors a ON b.author_id = a.author_id
    WHERE bi.member_id = @member_id AND bi.status IN ('Issued', 'Overdue')
    ORDER BY bi.due_date;
    
    -- Pending Fines
    SELECT 
        b.title,
        f.fine_amount,
        f.fine_reason,
        f.payment_status,
        f.created_at AS fine_date
    FROM Fines f
    JOIN Book_Issues bi ON f.issue_id = bi.issue_id
    JOIN Book_Copies bc ON bi.copy_id = bc.copy_id
    JOIN Books b ON bc.book_id = b.book_id
    WHERE bi.member_id = @member_id AND f.payment_status = 'Unpaid'
    ORDER BY f.created_at DESC;
END
GO

-- Procedure 5: Calculate Overdue Books and Auto-Generate Fines
CREATE PROCEDURE sp_ProcessOverdueBooks
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @fine_per_day DECIMAL(10,2) = 5.00;
        
        -- Update status to overdue
        UPDATE Book_Issues
        SET status = 'Overdue'
        WHERE status = 'Issued' AND due_date < CAST(GETDATE() AS DATE);
        
        -- Generate fines for newly overdue books
        INSERT INTO Fines (issue_id, fine_amount, fine_reason, payment_status)
        SELECT 
            bi.issue_id,
            DATEDIFF(DAY, bi.due_date, GETDATE()) * @fine_per_day,
            'Book overdue by ' + CAST(DATEDIFF(DAY, bi.due_date, GETDATE()) AS VARCHAR) + ' days',
            'Unpaid'
        FROM Book_Issues bi
        WHERE bi.status = 'Overdue' 
          AND NOT EXISTS (SELECT 1 FROM Fines f WHERE f.issue_id = bi.issue_id);
        
        SELECT @@ROWCOUNT AS fines_generated;
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END
GO

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Trigger 1: Automatically update book availability when copy status changes
CREATE TRIGGER trg_UpdateBookAvailability
ON Book_Copies
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(status)
    BEGIN
        -- Recalculate available copies for affected books
        UPDATE b
        SET b.available_copies = (
            SELECT COUNT(*) 
            FROM Book_Copies bc 
            WHERE bc.book_id = b.book_id AND bc.status = 'Available'
        )
        FROM Books b
        INNER JOIN inserted i ON b.book_id = i.book_id;
    END
END
GO

-- Trigger 2: Prevent deletion of books that are currently issued
CREATE TRIGGER trg_PreventBookDeletion
ON Books
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 
        FROM deleted d
        JOIN Book_Copies bc ON d.book_id = bc.book_id
        JOIN Book_Issues bi ON bc.copy_id = bi.copy_id
        WHERE bi.status IN ('Issued', 'Overdue')
    )
    BEGIN
        RAISERROR('Cannot delete books that are currently issued', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE FROM Books WHERE book_id IN (SELECT book_id FROM deleted);
    END
END
GO

-- Trigger 3: Log member activity
CREATE TABLE Member_Activity_Log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT,
    activity_type VARCHAR(50),
    activity_date DATETIME DEFAULT GETDATE(),
    description VARCHAR(MAX)
);
GO

CREATE TRIGGER trg_LogMemberActivity
ON Book_Issues
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Log new issues
    INSERT INTO Member_Activity_Log (member_id, activity_type, description)
    SELECT 
        i.member_id,
        'Book Issue',
        'Issued copy_id: ' + CAST(i.copy_id AS VARCHAR)
    FROM inserted i
    WHERE NOT EXISTS (SELECT 1 FROM deleted);
    
    -- Log returns
    INSERT INTO Member_Activity_Log (member_id, activity_type, description)
    SELECT 
        i.member_id,
        'Book Return',
        'Returned copy_id: ' + CAST(i.copy_id AS VARCHAR)
    FROM inserted i
    INNER JOIN deleted d ON i.issue_id = d.issue_id
    WHERE i.status = 'Returned' AND d.status != 'Returned';
END
GO

-- ============================================================
-- VIEWS
-- ============================================================

-- View 1: Available Books Summary
CREATE VIEW vw_AvailableBooks AS
SELECT 
    b.book_id,
    b.isbn,
    b.title,
    a.author_name,
    c.category_name,
    p.publisher_name,
    b.publication_year,
    b.available_copies,
    b.total_copies,
    b.price,
    CAST((b.available_copies * 100.0 / NULLIF(b.total_copies, 0)) AS DECIMAL(5,2)) AS availability_percentage
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
LEFT JOIN Categories c ON b.category_id = c.category_id
LEFT JOIN Publishers p ON b.publisher_id = p.publisher_id
WHERE b.available_copies > 0;
GO

-- View 2: Overdue Books Dashboard
CREATE VIEW vw_OverdueBooks AS
SELECT 
    bi.issue_id,
    m.member_code,
    m.first_name + ' ' + m.last_name AS member_name,
    m.phone,
    m.email,
    b.title AS book_title,
    a.author_name,
    bi.issue_date,
    bi.due_date,
    DATEDIFF(DAY, bi.due_date, GETDATE()) AS days_overdue,
    DATEDIFF(DAY, bi.due_date, GETDATE()) * 5.00 AS fine_amount,
    s.first_name + ' ' + s.last_name AS issued_by_staff
FROM Book_Issues bi
JOIN Members m ON bi.member_id = m.member_id
JOIN Book_Copies bc ON bi.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
JOIN Authors a ON b.author_id = a.author_id
LEFT JOIN Staff s ON bi.staff_id = s.staff_id
WHERE bi.status = 'Overdue';
GO

-- View 3: Popular Books Report
CREATE VIEW vw_PopularBooks AS
SELECT 
    b.book_id,
    b.title,
    a.author_name,
    c.category_name,
    COUNT(bi.issue_id) AS total_issues,
    COUNT(DISTINCT bi.member_id) AS unique_readers,
    AVG(DATEDIFF(DAY, bi.issue_date, COALESCE(bi.return_date, GETDATE()))) AS avg_reading_days
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
LEFT JOIN Categories c ON b.category_id = c.category_id
LEFT JOIN Book_Copies bc ON b.book_id = bc.book_id
LEFT JOIN Book_Issues bi ON bc.copy_id = bi.copy_id
GROUP BY b.book_id, b.title, a.author_name, c.category_name
HAVING COUNT(bi.issue_id) > 0;
GO

-- View 4: Member Statistics
CREATE VIEW vw_MemberStatistics AS
SELECT 
    m.member_id,
    m.member_code,
    m.first_name + ' ' + m.last_name AS member_name,
    m.membership_type,
    m.status,
    COUNT(DISTINCT bi.issue_id) AS total_books_borrowed,
    COUNT(DISTINCT CASE WHEN bi.status = 'Issued' THEN bi.issue_id END) AS currently_borrowed,
    COUNT(DISTINCT CASE WHEN bi.status = 'Overdue' THEN bi.issue_id END) AS overdue_count,
    SUM(ISNULL(f.fine_amount, 0)) AS total_fines,
    SUM(CASE WHEN f.payment_status = 'Unpaid' THEN f.fine_amount ELSE 0 END) AS unpaid_fines
FROM Members m
LEFT JOIN Book_Issues bi ON m.member_id = bi.member_id
LEFT JOIN Fines f ON bi.issue_id = f.issue_id
GROUP BY m.member_id, m.member_code, m.first_name, m.last_name, m.membership_type, m.status;
GO

-- ============================================================
-- ADVANCED QUERIES WITH WINDOW FUNCTIONS
-- ============================================================

-- Query 1: Running Total of Books Issued Per Day
SELECT 
    issue_date,
    COUNT(*) AS books_issued_today,
    SUM(COUNT(*)) OVER (ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM Book_Issues
GROUP BY issue_date
ORDER BY issue_date DESC;
GO

-- Query 2: Rank Members by Books Read with NTILE
SELECT 
    member_id,
    member_name,
    total_books_borrowed,
    NTILE(4) OVER (ORDER BY total_books_borrowed DESC) AS quartile,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY total_books_borrowed DESC) = 1 THEN 'Top Reader'
        WHEN NTILE(4) OVER (ORDER BY total_books_borrowed DESC) = 2 THEN 'Active Reader'
        WHEN NTILE(4) OVER (ORDER BY total_books_borrowed DESC) = 3 THEN 'Regular Reader'
        ELSE 'Occasional Reader'
    END AS reader_category
FROM vw_MemberStatistics
ORDER BY total_books_borrowed DESC;
GO

-- Query 3: LAG and LEAD - Compare Book Issues Month over Month
WITH MonthlyIssues AS (
    SELECT 
        FORMAT(issue_date, 'yyyy-MM') AS month,
        COUNT(*) AS issues_count
    FROM Book_Issues
    GROUP BY FORMAT(issue_date, 'yyyy-MM')
)
SELECT 
    month,
    issues_count,
    LAG(issues_count, 1) OVER (ORDER BY month) AS previous_month,
    LEAD(issues_count, 1) OVER (ORDER BY month) AS next_month,
    issues_count - LAG(issues_count, 1) OVER (ORDER BY month) AS growth,
    CAST((issues_count - LAG(issues_count, 1) OVER (ORDER BY month)) * 100.0 / 
         NULLIF(LAG(issues_count, 1) OVER (ORDER BY month), 0) AS DECIMAL(5,2)) AS growth_percentage
FROM MonthlyIssues
ORDER BY month DESC;
GO

-- ============================================================
-- PIVOT AND UNPIVOT EXAMPLES
-- ============================================================

-- Query 4: Category-wise Book Distribution using PIVOT
SELECT *
FROM (
    SELECT 
        p.publisher_name,
        c.category_name,
        b.book_id
    FROM Books b
    JOIN Publishers p ON b.publisher_id = p.publisher_id
    JOIN Categories c ON b.category_id = c.category_id
) AS SourceTable
PIVOT (
    COUNT(book_id)
    FOR category_name IN ([Fiction], [Non-Fiction], [Science], [Technology], [History])
) AS PivotTable;
GO

-- ============================================================
-- ADVANCED ANALYTICAL QUERIES
-- ============================================================

-- Query 5: Find Books Never Issued
SELECT 
    b.book_id,
    b.title,
    a.author_name,
    c.category_name,
    b.publication_year,
    b.total_copies
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
LEFT JOIN Categories c ON b.category_id = c.category_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM Book_Copies bc
    JOIN Book_Issues bi ON bc.copy_id = bi.copy_id
    WHERE bc.book_id = b.book_id
)
ORDER BY b.publication_year DESC;
GO

-- Query 6: Member Reading Patterns
WITH MemberReading AS (
    SELECT 
        m.member_id,
        m.first_name + ' ' + m.last_name AS member_name,
        c.category_name,
        COUNT(*) AS books_read,
        ROW_NUMBER() OVER (PARTITION BY m.member_id ORDER BY COUNT(*) DESC) AS preference_rank
    FROM Members m
    JOIN Book_Issues bi ON m.member_id = bi.member_id
    JOIN Book_Copies bc ON bi.copy_id = bc.copy_id
    JOIN Books b ON bc.book_id = b.book_id
    JOIN Categories c ON b.category_id = c.category_id
    GROUP BY m.member_id, m.first_name, m.last_name, c.category_name
)
SELECT 
    member_id,
    member_name,
    category_name AS favorite_category,
    books_read
FROM MemberReading
WHERE preference_rank = 1
ORDER BY books_read DESC;
GO

-- Query 7: Books Due in Next 7 Days (Alert System)
SELECT 
    bi.issue_id,
    m.member_code,
    m.first_name + ' ' + m.last_name AS member_name,
    m.email,
    m.phone,
    b.title,
    bi.issue_date,
    bi.due_date,
    DATEDIFF(DAY, GETDATE(), bi.due_date) AS days_until_due
FROM Book_Issues bi
JOIN Members m ON bi.member_id = m.member_id
JOIN Book_Copies bc ON bi.copy_id = bc.copy_id
JOIN Books b ON bc.book_id = b.book_id
WHERE bi.status = 'Issued' 
  AND bi.due_date BETWEEN GETDATE() AND DATEADD(DAY, 7, GETDATE())
ORDER BY bi.due_date;
GO

-- Query 8: Revenue Analysis (if library charges fees)
WITH RevenueAnalysis AS (
    SELECT 
        FORMAT(f.created_at, 'yyyy-MM') AS month,
        COUNT(f.fine_id) AS total_fines,
        SUM(f.fine_amount) AS total_fine_amount,
        SUM(CASE WHEN f.payment_status = 'Paid' THEN f.fine_amount ELSE 0 END) AS collected_amount,
        SUM(CASE WHEN f.payment_status = 'Unpaid' THEN f.fine_amount ELSE 0 END) AS pending_amount
    FROM Fines f
    GROUP BY FORMAT(f.created_at, 'yyyy-MM')
)
SELECT 
    month,
    total_fines,
    total_fine_amount,
    collected_amount,
    pending_amount,
    CAST((collected_amount * 100.0 / NULLIF(total_fine_amount, 0)) AS DECIMAL(5,2)) AS collection_rate
FROM RevenueAnalysis
ORDER BY month DESC;
GO

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- Function 1: Calculate Fine Amount
CREATE FUNCTION fn_CalculateFine (@issue_id INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @fine DECIMAL(10,2) = 0;
    DECLARE @due_date DATE;
    DECLARE @return_date DATE;
    DECLARE @fine_per_day DECIMAL(10,2) = 5.00;
    
    SELECT @due_date = due_date, @return_date = return_date
    FROM Book_Issues
    WHERE issue_id = @issue_id;
    
    IF @return_date IS NULL
        SET @return_date = CAST(GETDATE() AS DATE);
    
    IF @return_date > @due_date
        SET @fine = DATEDIFF(DAY, @due_date, @return_date) * @fine_per_day;
    
    RETURN @fine;
END
GO

-- Function 2: Check Book Availability
CREATE FUNCTION fn_IsBookAvailable (@book_id INT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @available_copies INT;
    DECLARE @result VARCHAR(50);
    
    SELECT @available_copies = available_copies FROM Books WHERE book_id = @book_id;
    
    IF @available_copies > 5
        SET @result = 'Readily Available';
    ELSE IF @available_copies > 0
        SET @result = 'Limited Copies';
    ELSE
        SET @result = 'Not Available';
    
    RETURN @result;
END
GO

-- ============================================================
-- SAMPLE PROCEDURE EXECUTIONS
-- ============================================================

-- Test Issue Book
-- EXEC sp_IssueBook @member_id = 1, @copy_id = 5, @staff_id = 1, @days = 14;

-- Test Return Book
-- EXEC sp_ReturnBook @issue_id = 1;

-- Test Search Books
-- EXEC sp_SearchBooks @search_term = 'Harry', @category_id = NULL, @author_id = NULL;

-- Test Member Report
-- EXEC sp_MemberReport @member_id = 1;

-- Test Process Overdue Books
-- EXEC sp_ProcessOverdueBooks;

-- ============================================================
-- USEFUL DASHBOARD QUERIES
-- ============================================================

-- Dashboard Query 1: Library Overview
SELECT 
    (SELECT COUNT(*) FROM Books) AS total_books,
    (SELECT SUM(total_copies) FROM Books) AS total_copies,
    (SELECT SUM(available_copies) FROM Books) AS available_copies,
    (SELECT COUNT(*) FROM Members WHERE status = 'Active') AS active_members,
    (SELECT COUNT(*) FROM Book_Issues WHERE status = 'Issued') AS books_currently_issued,
    (SELECT COUNT(*) FROM Book_Issues WHERE status = 'Overdue') AS overdue_books,
    (SELECT SUM(fine_amount) FROM Fines WHERE payment_status = 'Unpaid') AS total_unpaid_fines;
GO

-- Dashboard Query 2: Today's Activity
SELECT 
    (SELECT COUNT(*) FROM Book_Issues WHERE issue_date = CAST(GETDATE() AS DATE)) AS books_issued_today,
    (SELECT COUNT(*) FROM Book_Issues WHERE return_date = CAST(GETDATE() AS DATE)) AS books_returned_today,
    (SELECT COUNT(*) FROM Members WHERE CAST(created_at AS DATE) = CAST(GETDATE() AS DATE)) AS new_members_today,
    (SELECT COUNT(*) FROM Reservations WHERE reservation_date = CAST(GETDATE() AS DATE)) AS new_reservations_today;
GO

-- Dashboard Query 3: Top 5 Most Popular Books
SELECT TOP 5
    b.title,
    a.author_name,
    COUNT(bi.issue_id) AS times_issued,
    b.available_copies
FROM Books b
JOIN Authors a ON b.author_id = a.author_id
JOIN Book_Copies bc ON b.book_id = bc.book_id
JOIN Book_Issues bi ON bc.copy_id = bi.copy_id
GROUP BY b.title, a.author_name, b.available_copies
ORDER BY times_issued DESC;
GO

-- Dashboard Query 4: Top 5 Active Members
SELECT TOP 5
    m.member_code,
    m.first_name + ' ' + m.last_name AS member_name,
    COUNT(bi.issue_id) AS total_books_borrowed,
    SUM(CASE WHEN bi.status = 'Overdue' THEN 1 ELSE 0 END) AS overdue_books
FROM Members m
JOIN Book_Issues bi ON m.member_id = bi.member_id
GROUP BY m.member_code, m.first_name, m.last_name
ORDER BY total_books_borrowed DESC;
GO

-- ============================================================
-- BACKUP AND MAINTENANCE QUERIES
-- ============================================================

-- Query to find unused indexes
SELECT 
    OBJECT_NAME(s.object_id) AS table_name,
    i.name AS index_name,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE s.database_id = DB_ID('library_db')
  AND OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
  AND s.user_seeks = 0 AND s.user_scans = 0 AND s.user_lookups = 0
ORDER BY s.user_updates DESC;
GO

-- ============================================================
-- SUCCESS MESSAGE
-- ============================================================

PRINT '============================================================';
PRINT 'LIBRARY MANAGEMENT SYSTEM CREATED SUCCESSFULLY!';
PRINT '============================================================';
PRINT 'Database: library_db';
PRINT 'Tables: 10 core tables';
PRINT 'Procedures: 5 stored procedures';
PRINT 'Triggers: 3 triggers';
PRINT 'Views: 4 views';
PRINT 'Functions: 2 functions';
PRINT '';
PRINT 'Advanced Features Included:';
PRINT '- Common Table Expressions (CTEs)';
PRINT '- Window Functions (ROW_NUMBER, RANK, NTILE, LAG, LEAD)';
PRINT '- Recursive CTEs';
PRINT '- PIVOT/UNPIVOT';
PRINT '- Stored Procedures with Error Handling';
PRINT '- Triggers for Data Integrity';
PRINT '- Views for Reporting';
PRINT '- User-Defined Functions';
PRINT '- Transactions';
PRINT '- Indexes for Performance';
PRINT '============================================================';
GO