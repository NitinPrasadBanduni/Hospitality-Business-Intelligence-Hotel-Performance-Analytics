/*=========================================================================
Project : Hospitality Business Intelligence & Hotel Performance Analytics
File    : 07I_Expenses_Cleaning.sql

Purpose:
Cleans and validates the Expenses table after ETL.
The script standardizes expense fields, validates expense identifiers,
hotel references, dates, expense categories, and amounts, and verifies
expense coverage across the hotel portfolio.

===========================================================================*/

USE Hospitality_BI;

-- ============================================================
-- PREPARE SESSION FOR DATA CLEANING
-- ============================================================

SET SQL_SAFE_UPDATES = 0;


-- ============================================================
-- 1. TEXT STANDARDIZATION
-- ============================================================

UPDATE Expenses
SET
    expense_id = TRIM(expense_id),
    hotel_id = TRIM(hotel_id),
    expense_category = TRIM(expense_category);


-- ============================================================
-- 2. EXPENSE ID VALIDATION
-- ============================================================

-- Missing Expense IDs
SELECT *
FROM Expenses
WHERE expense_id IS NULL
   OR expense_id = '';

-- Duplicate Expense IDs
SELECT
    expense_id,
    COUNT(*) AS duplicate_count
FROM Expenses
GROUP BY expense_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. HOTEL REFERENCE VALIDATION
-- ============================================================

-- Missing Hotel IDs
SELECT *
FROM Expenses
WHERE hotel_id IS NULL
   OR hotel_id = '';

-- Invalid Hotel references
SELECT
    e.expense_id,
    e.hotel_id
FROM Expenses e
LEFT JOIN Hotels h
    ON e.hotel_id = h.hotel_id
WHERE h.hotel_id IS NULL;


-- ============================================================
-- 4. EXPENSE DATE VALIDATION
-- ============================================================

-- Expense dates outside project period
SELECT *
FROM Expenses
WHERE expense_date IS NULL
   OR expense_date < '2024-01-01'
   OR expense_date > '2026-08-31';


-- ============================================================
-- 5. EXPENSE CATEGORY VALIDATION
-- ============================================================

SELECT DISTINCT expense_category
FROM Expenses
WHERE expense_category NOT IN
(
    'Employee & Staff',
    'Food & Beverage',
    'Housekeeping',
    'Laundry',
    'Maintenance',
    'Marketing',
    'Other Operating Expenses',
    'Security',
    'Supplies',
    'Technology',
    'Transportation',
    'Utilities'
)
OR expense_category IS NULL;


-- ============================================================
-- 6. EXPENSE AMOUNT VALIDATION
-- ============================================================

-- Expense amounts must be positive
SELECT *
FROM Expenses
WHERE amount IS NULL
   OR amount <= 0;


-- ============================================================
-- 7. HOTEL EXPENSE COVERAGE VALIDATION
-- ============================================================

-- Hotels without any expense records
SELECT
    h.hotel_id,
    h.hotel_name
FROM Hotels h
LEFT JOIN Expenses e
    ON h.hotel_id = e.hotel_id
WHERE e.expense_id IS NULL;


-- Number of expense records per hotel
SELECT
    hotel_id,
    COUNT(*) AS expense_record_count
FROM Expenses
GROUP BY hotel_id
ORDER BY expense_record_count DESC;


-- ============================================================
-- 8. EXPENSE ACTIVITY OVERVIEW
-- ============================================================

-- Number of expenses by category
SELECT
    expense_category,
    COUNT(*) AS expense_count,
    SUM(amount) AS total_expense
FROM Expenses
GROUP BY expense_category
ORDER BY total_expense DESC;


-- ============================================================
-- 9. FINAL EXPENSE VALIDATION
-- ============================================================

SELECT COUNT(*) AS total_expenses
FROM Expenses;

SELECT COUNT(DISTINCT expense_id) AS unique_expense_ids
FROM Expenses;

SELECT COUNT(DISTINCT hotel_id) AS hotels_with_expenses
FROM Expenses;

SELECT COUNT(DISTINCT expense_category) AS expense_categories
FROM Expenses;


-- ============================================================
-- 10. CLEANING SUMMARY
-- ============================================================

/*
EXPENSES CLEANING FINDINGS
--------------------------
1. TEXT STANDARDIZATION
   - Expense IDs, hotel IDs, and expense categories standardized
     using TRIM().

2. EXPENSE ID
   - No missing expense IDs.
   - All expense IDs are unique.

3. HOTEL REFERENCE
   - No missing hotel IDs.
   - All expense records reference valid hotels.

4. EXPENSE DATE
   - All expense dates fall within the expected project period.

5. EXPENSE CATEGORY
   - All 12 expense categories are within the expected business domain.

6. EXPENSE AMOUNT
   - All expense amounts are positive.

7. HOTEL EXPENSE COVERAGE
   - Every hotel has expense records.
   - Number of expense records per hotel ranges from 400 to 408.

8. EXPENSE ACTIVITY
   - Expense volume and total expense amounts were reviewed by category.

9. FINAL VALIDATION
   - Total expenses: 8,064.
   - Unique expense IDs: 8,064.
   - Hotels with expenses: 20.
   - Expense categories: 12.

CONCLUSION:
Expenses table passed all cleaning and validation checks.
No corrective data changes were required beyond text standardization.
*/


-- ============================================================
-- RE-ENABLE SAFE UPDATE MODE
-- ============================================================

SET SQL_SAFE_UPDATES = 1;