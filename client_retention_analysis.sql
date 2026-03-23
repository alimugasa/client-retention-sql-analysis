-- ============================================================
-- PROJECT 1: Client Retention & Revenue Analysis
-- Author: Ali Mugasa
-- Tools: SQL (SQLite)
-- Dataset: Bank client data (800 clients, 1500+ accounts, 19K+ transactions)
--
-- Business Context:
-- Leadership wants to understand client churn patterns and
-- quantify the revenue impact of lost clients. These queries
-- identify who is leaving, why, and what it costs the bank.
-- ============================================================


-- ============================================================
-- Q1: What is the overall churn rate, and how does it break
--     down by geography?
-- Business Question: Which regions are losing the most clients?
-- ============================================================

SELECT
    geography,
    COUNT(*) AS total_clients,
    SUM(exited) AS churned_clients,
    ROUND(SUM(exited) * 100.0 / COUNT(*), 1) AS churn_rate_pct
FROM clients
GROUP BY geography
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- Q2: What is the churn rate by credit score tier?
-- Business Question: Are lower credit clients leaving faster?
-- ============================================================

SELECT
    CASE
        WHEN credit_score >= 750 THEN 'Excellent (750+)'
        WHEN credit_score >= 700 THEN 'Good (700-749)'
        WHEN credit_score >= 650 THEN 'Fair (650-699)'
        WHEN credit_score >= 600 THEN 'Below Average (600-649)'
        ELSE 'Poor (Below 600)'
    END AS credit_tier,
    COUNT(*) AS total_clients,
    SUM(exited) AS churned,
    ROUND(SUM(exited) * 100.0 / COUNT(*), 1) AS churn_rate_pct
FROM clients
GROUP BY credit_tier
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- Q3: What is the churn rate by age group?
-- Business Question: Which age demographics are we losing?
-- ============================================================

SELECT
    CASE
        WHEN age < 30 THEN '18-29'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        WHEN age < 60 THEN '50-59'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS total_clients,
    SUM(exited) AS churned,
    ROUND(SUM(exited) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(estimated_salary), 0) AS avg_salary
FROM clients
GROUP BY age_group
ORDER BY age_group;


-- ============================================================
-- Q4: How does product count relate to churn?
-- Business Question: Do clients with more products stay longer?
-- ============================================================

WITH client_products AS (
    SELECT
        c.client_id,
        c.exited,
        COUNT(a.account_id) AS num_products
    FROM clients c
    LEFT JOIN accounts a ON c.client_id = a.client_id
    GROUP BY c.client_id, c.exited
)
SELECT
    num_products,
    COUNT(*) AS total_clients,
    SUM(exited) AS churned,
    ROUND(SUM(exited) * 100.0 / COUNT(*), 1) AS churn_rate_pct
FROM client_products
GROUP BY num_products
ORDER BY num_products;


-- ============================================================
-- Q5: What is the total balance at risk from churned clients?
-- Business Question: How much AUM did we lose to churn?
-- ============================================================

SELECT
    CASE WHEN c.exited = 1 THEN 'Churned' ELSE 'Retained' END AS client_status,
    COUNT(DISTINCT c.client_id) AS num_clients,
    ROUND(SUM(a.balance), 2) AS total_balance,
    ROUND(AVG(a.balance), 2) AS avg_balance_per_account
FROM clients c
JOIN accounts a ON c.client_id = a.client_id
GROUP BY client_status;


-- ============================================================
-- Q6: Which product types lost the most balance to churn?
-- Business Question: Where is the revenue impact concentrated?
-- ============================================================

SELECT
    a.product_type,
    COUNT(DISTINCT CASE WHEN c.exited = 1 THEN c.client_id END) AS churned_clients,
    ROUND(SUM(CASE WHEN c.exited = 1 THEN a.balance ELSE 0 END), 2) AS churned_balance,
    ROUND(SUM(CASE WHEN c.exited = 0 THEN a.balance ELSE 0 END), 2) AS retained_balance,
    ROUND(
        SUM(CASE WHEN c.exited = 1 THEN a.balance ELSE 0 END) * 100.0 /
        NULLIF(SUM(a.balance), 0), 1
    ) AS pct_balance_lost
FROM accounts a
JOIN clients c ON a.client_id = c.client_id
GROUP BY a.product_type
ORDER BY churned_balance DESC;


-- ============================================================
-- Q7: Top 20 highest-value clients who churned
-- Business Question: Which lost clients should we try to win back?
-- ============================================================

SELECT
    c.client_id,
    c.first_name || ' ' || c.last_name AS client_name,
    c.geography,
    c.credit_score,
    c.tenure_months,
    c.exit_reason,
    COUNT(a.account_id) AS num_accounts,
    ROUND(SUM(a.balance), 2) AS total_balance
FROM clients c
JOIN accounts a ON c.client_id = a.client_id
WHERE c.exited = 1
GROUP BY c.client_id
ORDER BY total_balance DESC
LIMIT 20;


-- ============================================================
-- Q8: What are the top reasons for churn, and what is the
--     average balance of clients per exit reason?
-- Business Question: Why are clients leaving?
-- ============================================================

SELECT
    exit_reason,
    COUNT(*) AS num_clients,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_of_churned,
    ROUND(AVG(c.estimated_salary), 0) AS avg_salary,
    ROUND(AVG(total_bal.total_balance), 2) AS avg_total_balance
FROM clients c
JOIN (
    SELECT client_id, SUM(balance) AS total_balance
    FROM accounts
    GROUP BY client_id
) total_bal ON c.client_id = total_bal.client_id
WHERE c.exited = 1
GROUP BY exit_reason
ORDER BY num_clients DESC;


-- ============================================================
-- Q9: Churn rate by tenure group
-- Business Question: At what point in the relationship do we
--     lose clients?
-- ============================================================

SELECT
    CASE
        WHEN tenure_months < 12 THEN '0-11 months'
        WHEN tenure_months < 36 THEN '1-2 years'
        WHEN tenure_months < 60 THEN '3-4 years'
        WHEN tenure_months < 120 THEN '5-9 years'
        ELSE '10+ years'
    END AS tenure_group,
    COUNT(*) AS total_clients,
    SUM(exited) AS churned,
    ROUND(SUM(exited) * 100.0 / COUNT(*), 1) AS churn_rate_pct
FROM clients
GROUP BY tenure_group
ORDER BY 
    CASE tenure_group
        WHEN '0-11 months' THEN 1
        WHEN '1-2 years' THEN 2
        WHEN '3-4 years' THEN 3
        WHEN '5-9 years' THEN 4
        WHEN '10+ years' THEN 5
    END;


-- ============================================================
-- Q10: Monthly transaction volume trend — churned vs retained
-- Business Question: Did churned clients show declining activity
--     before leaving?
-- ============================================================

WITH client_monthly AS (
    SELECT
        t.client_id,
        c.exited,
        t.month,
        SUM(t.num_transactions) AS monthly_txns,
        SUM(t.total_deposits) AS monthly_deposits
    FROM transactions t
    JOIN clients c ON t.client_id = c.client_id
    GROUP BY t.client_id, c.exited, t.month
)
SELECT
    month,
    CASE WHEN exited = 1 THEN 'Churned' ELSE 'Retained' END AS client_status,
    COUNT(DISTINCT client_id) AS active_clients,
    ROUND(AVG(monthly_txns), 1) AS avg_transactions,
    ROUND(AVG(monthly_deposits), 2) AS avg_deposits
FROM client_monthly
GROUP BY month, client_status
ORDER BY month, client_status;
