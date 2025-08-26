 USE BANK;
 SELECT * FROM ACCOUNTS;
SELECT*FROM BRANCHES;
SELECT* FROM CARDS;
SELECT* FROM CUSTOMERS;
SELECT * FROM EMPLOYEES;
SELECT* FROM LOANS;
SELECT* FROM SERVICES;
SELECT* FROM TRANSACTIONS;
SELECT * FROM EMPLOYEES_CUSTOMERS;
SELECT* FROM LOANPAYMENTS;
SELECT* FROM CUSTOMER_SERVICES;
UPDATE Services
SET ServiceName = CASE ServiceID
    WHEN 1 THEN 'Loan Services'
    WHEN 2 THEN 'Online Banking'
    WHEN 3 THEN 'Saving Accounts'
    WHEN 4 THEN 'Fixed Deposit'
    WHEN 5 THEN 'Loan Services'
    WHEN 6 THEN 'Online Banking'
    WHEN 7 THEN 'Saving Accounts'
    WHEN 8 THEN 'Fixed Deposit'
    WHEN 9 THEN 'Loan Services'
    WHEN 10 THEN 'Online Banking'
END,
Description = CASE ServiceID
    WHEN 1 THEN 'Provides personal, home, and business loans.'
    WHEN 2 THEN 'Secure internet-based banking services.'
    WHEN 3 THEN 'Accounts for saving money with interest.'
    WHEN 4 THEN 'Fixed-term deposits with higher interest rates.'
    WHEN 5 THEN 'Provides personal, home, and business loans.'
    WHEN 6 THEN 'Secure internet-based banking services.'
    WHEN 7 THEN 'Accounts for saving money with interest.'
    WHEN 8 THEN 'Fixed-term deposits with higher interest rates.'
    WHEN 9 THEN 'Provides personal, home, and business loans.'
    WHEN 10 THEN 'Secure internet-based banking services.'
END;

-- business analysis questions 
-- how many customers we have 
SELECT COUNT(*) AS total_customers
FROM Customers;

-- Number of accounts per customer (top 10 customers by accounts)
SELECT c.CustomerID, c.FullName, COUNT(a.AccountID) AS num_accounts
FROM Customers c
LEFT JOIN Accounts a ON a.CustomerID = c.CustomerID
GROUP BY c.CustomerID
ORDER BY num_accounts DESC
LIMIT 10;
-- Top 10 customers by total balance across all their accounts
SELECT c.CustomerID, c.FullName, SUM(a.Balance) AS total_balance
FROM Customers c
LEFT JOIN Accounts a ON a.CustomerID = c.CustomerID
GROUP BY c.CustomerID
ORDER BY total_balance DESC
LIMIT 10;

-- Count of transactions in the last 30 days
SELECT COUNT(*) AS trans_last_30_days
FROM Transactions
WHERE TransactionDate >= CURDATE() - INTERVAL 30 DAY;

-- How many active loans and total active loan amount
SELECT COUNT(*) AS active_loans, COALESCE(SUM(Amount),0) AS total_active_loan_amount
FROM Loans
WHERE Status = 'active';

-- Average transaction amount per account (accounts with > 5 transactions)
SELECT t.AccountID,
       AVG(t.Amount) AS avg_txn_amount,
       COUNT(*) AS txn_count
FROM Transactions t
GROUP BY t.AccountID
HAVING txn_count > 5
ORDER BY avg_txn_amount DESC
LIMIT 10;

-- Monthly transaction volume (count & sum) for last 12 months
SELECT DATE_FORMAT(TransactionDate, '%m') AS month,
       COUNT(*) AS tx_count,
       SUM(Amount) AS total_amount
FROM Transactions
WHERE TransactionDate >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY month
ORDER BY month;


-- Loan repayment rate per loan (total paid / loan amount)
SELECT l.LoanID,
       l.CustomerID,
       l.Amount AS loan_amount,
       SUM(lp.AmountPaid) AS total_paid,
       CASE WHEN l.Amount > 0
     THEN SUM(lp.AmountPaid) / l.Amount -- This calculates how much of the loan has been paid as a ratio
     ELSE NULL
END AS repayment_ratio
FROM Loans l
LEFT JOIN LoanPayments lp ON lp.LoanID = l.LoanID
GROUP BY l.LoanID
ORDER BY repayment_ratio ASC
LIMIT 20;


-- customers with >= 2 services
SELECT cs.CustomerID, c.FullName, COUNT(*) AS num_services
FROM Customer_Services cs
JOIN Customers c ON c.CustomerID = cs.CustomerID
GROUP BY cs.CustomerID
HAVING num_services >= 2
ORDER BY num_services DESC
LIMIT 20;

-- Total balances attributable to each branch
WITH branch_customers AS (
  SELECT DISTINCT e.BranchID, ec.CustomerID
  FROM Employees_Customers ec
  JOIN Employees e ON ec.EmployeeID = e.EmployeeID
)
SELECT b.BranchID, b.BranchName,
       SUM(a.Balance) AS total_balance
FROM Branches b
JOIN branch_customers bc ON bc.BranchID = b.BranchID
JOIN Accounts a ON a.CustomerID = bc.CustomerID
GROUP BY b.BranchID
ORDER BY total_balance DESC;


-- Flag accounts with suspicious same-day activity 
SELECT AccountID,
       DATE(TransactionDate) AS tx_date,
       COUNT(*) AS tx_count,
       SUM(Amount) AS total_amount
FROM Transactions
GROUP BY AccountID, DATE(TransactionDate)
HAVING tx_count > 10 OR total_amount > 10000; 


-- Delinquent loans: loans past EndDate with <50% repaid
SELECT l.LoanID, l.CustomerID, l.Amount AS loan_amount,
	SUM(lp.AmountPaid) AS total_paid,
	l.EndDate,
	SUM(lp.AmountPaid) / (l.Amount)AS repayment_ratio
FROM Loans l
LEFT JOIN LoanPayments lp ON lp.LoanID = l.LoanID
GROUP BY l.LoanID
HAVING l.EndDate < current_date() AND SUM(lp.AmountPaid) < 0.5 *( l.Amount); -- Divides the total paid by the original loan amount to produce a repayment ratio

--  rank employees by the total balance of unique customers they manage
SELECT e.EmployeeID, e.FullName,
       SUM(a.Balance) AS managed_customers_total_balance,
       COUNT(DISTINCT ec.CustomerID) AS unique_customers
FROM Employees e
JOIN EmployeeS_CustomerS ec ON ec.EmployeeID = e.EmployeeID
JOIN Accounts a ON a.CustomerID = ec.CustomerID
GROUP BY e.EmployeeID
ORDER BY managed_customers_total_balance DESC
LIMIT 20;


-- CTAS
CREATE TABLE overdue_loans AS
SELECT 
    l.LoanID, 
    l.CustomerID, 
    l.Amount AS loan_amount,
    SUM(lp.AmountPaid) AS total_paid,
    l.EndDate,
    SUM(lp.AmountPaid) / l.Amount AS repayment_ratio
FROM Loans l
LEFT JOIN LoanPayments lp 
    ON lp.LoanID = l.LoanID
GROUP BY l.LoanID, l.CustomerID, l.Amount, l.EndDate
HAVING 
l.EndDate < CURRENT_DATE()       -- loan has already ended
AND SUM(lp.AmountPaid) < 0.5 * l.Amount;  -- paid less than 50% of total loan

SELECT * FROM overdue_loans;

--
CREATE TABLE loan_remaining_balance AS
SELECT 
    l.LoanID,
    l.Amount AS original_amount,
    SUM(lp.AmountPaid) AS total_paid,
    (l.Amount - SUM(lp.AmountPaid)) AS remaining_balance
FROM Loans l
LEFT JOIN LoanPayments lp 
    ON l.LoanID = lp.LoanID
GROUP BY l.LoanID, l.Amount;
SELECT * FROM loan_remaining_balance ;
 
 
 -- PROCEDURES
 DELIMITER $$

CREATE PROCEDURE GetLoanDetails(IN loan_id INT)
BEGIN
    SELECT l.LoanID, l.Amount, SUM(lp.AmountPaid) AS TotalPaid
    FROM loans l
    LEFT JOIN loanpayments lp ON l.LoanID = lp.LoanID
    WHERE l.LoanID = loan_id
    GROUP BY l.LoanID, l.Amount;
END $$

DELIMITER ;
CALL GetLoanDetails(114);

--
DELIMITER $$

CREATE PROCEDURE GetTotalPayment(IN loan_id INT)
BEGIN
    SELECT SUM(lp.AmountPaid) / l.Amount AS PaymentRatio
    FROM loanpayments lp
    JOIN loans l ON lp.LoanID = l.LoanID
    WHERE l.LoanID = loan_id
    GROUP BY l.LoanID,l.Amount;
END $$

DELIMITER ;
 CALL GetTotalPayment(5);
 
 --










