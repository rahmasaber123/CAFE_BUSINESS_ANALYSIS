# CAFE_BUSINESS_ANALYSIS
THIS PROJECT GIVE A CLEAR SIGHT ABOUT A CAFE BUSINESS ANALYSIS ANSWERING QUESTIONS USING SQL QUERIES THAT HELP CAFE BUSINESS TO GROW 


## Project Overview

**Project Title** CAFE BUSINESS ANALYSIS  

**Database**: `CAFE_ANALYSIS`

This project demonstrates the implementation of a CAFE BUSINESS ANALYSIS using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/rahmasaber123/CAFE_BUSINESS_ANALYSIS/blob/main/CAFE_PIC.jpeg?raw=true)

## Objectives

1. **Set up the CAFE BUSINESS ANALYSIS Database**: Create and populate the database with tables for Cities, Customers,Products, Sales, status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTE to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/rahmasaber123/CAFE_BUSINESS_ANALYSIS/blob/main/Cafe_schema.png?raw=true)

- **Database Creation**: Created a database named `CAFE_ANALYSIS`.
- **Table Creation**: Created tables for Cities, Customers, Products, Sales. Each table includes relevant columns and relationships.

```sql
-- library mangment system project
--CREATING BRANCH TABLE
 DROP TABLE IF EXISTS BRANCH ;
 CREATE TABLE BRANCH (
    branch_id varchar(20) primary key,
    manager_id	varchar(20),
    branch_address varchar(55),
    contact_no varchar(25)
 );
 --CREATING EMPLOYEE TABLE
  DROP TABLE IF EXISTS EMPLOYEES ;
 CREATE TABLE EMPLOYEES (
     emp_id varchar(15) primary key,
     emp_name varchar(20),
     position	text,
     salary int,
     branch_id varchar(10)--foreign key
 );

 
--CREATING BOOKS TABLE
 DROP TABLE IF EXISTS BOOKS ;
 CREATE TABLE BOOKS (
   isbn varchar(25) primary key,
   book_title varchar(75),
   category varchar(15),	
   rental_price float,
   status	varchar(10),
   author varchar(35),
   publisher varchar(55)
);

 ALTER TABLE BOOKS
 ALTER COLUMN  category TYPE VARCHAR (40);

--creating table members
 DROP TABLE IF EXISTS  MEMBERS ;
 CREATE TABLE MEMBERS (
    member_id varchar(10) primary key,
    member_name varchar(25),
    member_address varchar(75),
    reg_date Date
);
 
--creating issued_status table
 DROP TABLE IF EXISTS  issued_status;
 create table issued_status (
    issued_id varchar(15) primary key,
    issued_member_id varchar(10),--fk members
    issued_book_name varchar(75),
    issued_date	Date,
    issued_book_isbn	varchar(25),--fk books
    issued_emp_id varchar(15)--fk employees
) ;
--creating return status table
 DROP TABLE IF EXISTS  return_status;
 create table return_status 
 (
    return_id varchar(15)  primary key,
    issued_id	varchar(15) ,--fk issued_status
    return_book_name	varchar(75),
    return_date Date,
    return_book_isbn varchar(25) --fk books 
);



--add foreign keys constraints
ALTER TABLE issued_status 
ADD CONSTRAINT FK_MEMEBERS
FOREIGN KEY (issued_member_id)
REFERENCES MEMBERS(member_id);

--!!

ALTER TABLE issued_status 
ADD CONSTRAINT FK_BOOKS
FOREIGN KEY (issued_book_isbn)
REFERENCES BOOKS(isbn);

--!!
ALTER TABLE issued_status 
ADD CONSTRAINT FK_EMPOLYEES
FOREIGN KEY (issued_emp_id) 
REFERENCES EMPLOYEES(emp_id);


--!!


ALTER TABLE return_status 
ADD CONSTRAINT FK_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status( issued_id);


--!!
ALTER TABLE return_status 
ADD CONSTRAINT FK_BOOKS
FOREIGN KEY (return_book_isbn)
REFERENCES BOOKS(isbn);
--!!

ALTER TABLE return_status 
ADD CONSTRAINT FK_BOOKS
FOREIGN KEY (return_book_isbn) 
REFERENCES BOOKS(isbn);


--!!

 ALTER TABLE EMPLOYEES
ADD CONSTRAINT FK_BRANCH
FOREIGN KEY (branch_id) 
REFERENCES BRANCH(branch_id);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO BOOKS
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT* FROM BOOKS;

```
**Task 2: Update an Existing Member's Address**

```sql
 UPDATE MEMBERS
 SET MEMBER_ADDRESS = '125 Oak St'
 WHERE MEMBER_ID =  'C103';
 SELECT* FROM MEMBERS;


```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM ISSUED_STATUS
WHERE issued_id = 'IS121';
SELECT* FROM ISSUED_STATUS;

```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM ISSUED_STATUS
WHERE ISSUED_EMP_ID = 'E101';

```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT ISSUED_MEMBER_ID ,COUNT(*)
FROM ISSUED_STATUS
GROUP BY 1
HAVING COUNT(*)>1;

```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE TOTAL_BOOK_ISSUED AS
SELECT  B.ISBN,BOOK_TITLE ,COUNT(IST.ISSUED_BOOK_ISBN) AS book_issued_cnt
FROM ISSUED_STATUS IST
JOIN BOOKS B
ON B.ISBN = IST.ISSUED_BOOK_ISBN
GROUP BY B.ISBN;

SELECT * FROM TOTAL_BOOK_ISSUED;

```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM BOOKS 
WHERE CATEGORY ='Classic';

```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT CATEGORY ,SUM(B.RENTAL_PRICE) AS TOTAL_RENTAL_INCOME
FROM BOOKS AS B
JOIN ISSUED_STATUS IST
ON B.ISBN = IST.ISSUED_BOOK_ISBN

GROUP BY CATEGORY;

```

9. **List Members Who Registered in the Last 700 Days**:
```sql
SELECT* FROM MEMBERS 
WHERE REG_DATE > CURRENT_DATE - INTERVAL '700 DAYS';

```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT E.*,B.BRANCH_ID,E1.EMP_NAME AS MANAGER_NAME 
FROM EMPLOYEES E
JOIN BRANCH B 
ON B.BRANCH_ID  = E.BRANCH_ID
JOIN EMPLOYEES E1
ON E1.EMP_ID  = B.MANAGER_ID;

```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE EXPENSIVE_BOOKS AS
SELECT * FROM BOOKS 
WHERE RENTAL_PRICE >7;

```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT ISSUED_BOOK_NAME,RS.ISSUED_ID 
FROM RETURN_STATUS RS
RIGHT JOIN ISSUED_STATUS IST 
ON RS.ISSUED_ID = IST.ISSUED_ID
WHERE RETURN_BOOK_ISBN IS NULL;

```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 300-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql

SELECT M.MEMBER_ID,
M.MEMBER_NAME,
B.BOOK_TITLE, 
CURRENT_DATE-IST.ISSUED_DATE AS OVER_DUE
FROM ISSUED_STATUS IST
  JOIN MEMBERS M 
ON M.MEMBER_ID  = IST.ISSUED_MEMBER_ID
  JOIN BOOKS B
ON B.ISBN = IST.ISSUED_BOOK_ISBN
  LEFT JOIN RETURN_STATUS RS
ON RS.ISSUED_ID = IST.ISSUED_ID 
   WHERE RS.RETURN_DATE IS NULL 
   AND( CURRENT_DATE-ISSUED_DATE )>300
;

```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

CREATE OR REPLACE PROCEDURE RETURN_BOOKS_STATUS(P_RETURN_ID VARCHAR(15),P_ISSUED_ID VARCHAR(15),P_BOOK_QUALITY VARCHAR(15))
LANGUAGE PLPGSQL
AS $$
DECLARE 
V_ISSUED_ISBN VARCHAR(25);
V_BOOK_NAME VARCHAR(75);
BEGIN
SELECT ISSUED_BOOK_ISBN,ISSUED_BOOK_NAME
INTO V_ISSUED_ISBN,V_BOOK_NAME
FROM ISSUED_STATUS
WHERE ISSUED_ID=P_ISSUED_ID ;

INSERT 
  INTO RETURN_STATUS(RETURN_ID,ISSUED_ID,RETURN_DATE,BOOK_QUALITY)
  VALUES(P_RETURN_ID,P_ISSUED_ID,CURRENT_DATE,P_BOOK_QUALITY);

UPDATE BOOKS
SET STATUS ='YES'
WHERE ISBN = V_ISSUED_ISBN;

RAISE NOTICE 'THANKS FOR RETURNING THE BOOK %',V_BOOK_NAME;
  
END;
$$



-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql

CREATE TABLE BRANCH_REPORT AS
SELECT
E.EMP_ID,
BC.MANAGER_ID ,
  COUNT(RS.RETURN_ID) AS TOTAL_RETURN_BOOKS,
  COUNT(IST.ISSUED_ID ) AS TOTAL_ISSUED_BOOKS
  FROM ISSUED_STATUS IST
  JOIN EMPLOYEES E 
ON E.EMP_ID =IST.ISSUED_EMP_ID
  JOIN BOOKS B
ON B.ISBN =IST.ISSUED_BOOK_ISBN
  JOIN BRANCH BC
ON BC.BRANCH_ID =E.BRANCH_ID
  LEFT JOIN RETURN_STATUS RS
ON RS.ISSUED_ID =IST.ISSUED_ID
  GROUP BY 1,2;
SELECT* FROM BRANCH_REPORT;

```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 20 months.

```sql
CREATE TABLE LAST_20MONTH_CHECK AS 
  SELECT * FROM MEMBERS WHERE MEMBER_ID IN(
  SELECT DISTINCT ISSUED_MEMBER_ID FROM 
ISSUED_STATUS
WHERE ISSUED_DATE >= CURRENT_DATE - INTERVAL'20 MONTHS');
SELECT* FROM LAST_20MONTH_CHECK;


```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT EMP_NAME,B.*,COUNT(IST.ISSUED_ID) AS NUM_BOOK_ISSUED
FROM ISSUED_STATUS IST
   JOIN
   EMPLOYEES E
ON E.EMP_ID=IST.ISSUED_EMP_ID
  JOIN BRANCH B
ON B.BRANCH_ID = E.BRANCH_ID
  GROUP BY 1,2
ORDER BY COUNT(IST.ISSUED_ID)
   LIMIT 3;

```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    
```sql
SELECT M.MEMBER_NAME, 
  B.BOOK_TITLE ,
COUNT(IST.ISSUED_BOOK_ISBN) AS HIGH_RISK_BOOKS
FROM ISSUED_STATUS IST
   LEFT JOIN RETURN_STATUS RS
ON IST.ISSUED_ID =RS.ISSUED_ID 
   JOIN MEMBERS M
ON M.MEMBER_ID=ISSUED_MEMBER_ID
   JOIN BOOKS B 
ON B.ISBN = IST.ISSUED_BOOK_ISBN 
   WHERE RS.BOOK_QUALITY ='Damaged'
GROUP BY 1,2
   HAVING count(RS.BOOK_QUALITY)>2;


```

**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql

 SELECT  M.member_id, 
	M.member_name, 
	COUNT(member_id) AS books_overdue,
	SUM((CURRENT_DATE - (iST.issued_date + INTERVAL '30 Days')::DATE) * 0.50) AS total_fines	--::DATE MAKES SURE IT RETURNS DATE TYPE
FROM members AS M
JOIN issued_status AS iST
	ON iST.issued_member_id = M.member_id
LEFT JOIN return_status AS RS
	ON RS.issued_id = IST.issued_id
JOIN books AS b
	ON b.isbn = iST.issued_book_isbn
WHERE return_date IS NULL 
	AND CURRENT_DATE - (iST.issued_date + INTERVAL '30 Days')::DATE > 0
GROUP BY 1,2;

```
## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/rahmasaber123/LIBRARAY_MANAGMENT_SYSTEM.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - RAHMA SABER ABBAS 
