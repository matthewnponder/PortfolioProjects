/* 
Mortgage Data Exploration

Data obtained from the National Mortgage Licensing System: https://mortgage.nationwidelicensingsystem.org/about/pages/reports.aspx

Skills Used: Aggregate Functions, Truncate, Joins, CTE's, Temp Tables, Creating Views

*/ 




--------------------------------------------------------------------------------------------------------------------------------------
--Select Data that we are going to be starting with

select state, filing_year, loan_type, Loan_amt, Loan_cnt
from LoanType
where filing_year = '2021'



--------------------------------------------------------------------------------------------------------------------------------------
--VA Loan Closings by State

select state, filing_year, loan_type, sum(loan_cnt) as Closings
from LoanType
where filing_year = '2021'
	and loan_type = 'VA-Guaranteed'
group by state, filing_year, loan_type
order by 4 desc



--------------------------------------------------------------------------------------------------------------------------------------
--Loan Amounts by State 
--Shows States with highest mortgage volume

select state, filing_year, sum(loan_amt) as FundingAmount
from LoanType
where filing_year = '2021'
group by state, filing_year
order by 4 desc



--------------------------------------------------------------------------------------------------------------------------------------
--Refinancing Loan Closings by State

Select state, filing_year, Loan_Type, sum(loan_cnt) as Refinances
from LoanPurpose
where filing_year = '2021'
	and loan_type = 'Refinancing'
group by state, filing_year, Loan_Type



--------------------------------------------------------------------------------------------------------------------------------------
--License Applications vs Terminations 
--Shows which states have the most individual licenses terminated compared to new applicants

select left(licensing.state, 2) as State, statusstartyear, entity_type, Terminated, New_Applications 
	, (Terminated/New_Applications) * 100 as TerminationsVsApplications
from Licensing
where entity_type = 'individual'
 and statusstartyear = '2021'
 and Terminated <> '0'
 order by TerminationsVsApplications desc

 
 
 --------------------------------------------------------------------------------------------------------------------------------------
 --Loan Application Loan Amount vs Loan Funding Amount by State
 --shows funding loan amount compared to original application loan amount  
 
 select *
 from Applications
 where filing_year = '2021'

 select * 
 from LoanType
 where filing_year = '2021'

select loa.state 
	, loa.filing_year
	, SUM(loa.loan_amt) FundedAmount
	, SUM(app.loan_amt) ApplicationAmount
from LoanType loa
join applications app
	on loa.State = app.State
where loa.filing_year = '2021'
group by loa.State, loa.filing_year



--------------------------------------------------------------------------------------------------------------------------------------
--Using CTE to perform Calculation on Aggregate Functions in previous query

With FundvsApp (state, filing_year, FundedAmount, ApplicationAmount)
as
(
select loa.state 
	, loa.filing_year
	, SUM(loa.loan_amt) FundedAmount
	, SUM(app.loan_amt) ApplicationAmount
from LoanType loa
join applications app
	on loa.State = app.State
where loa.filing_year = '2021'
group by loa.State, loa.filing_year
)

select *, (FundedAmount/ApplicationAmount) * 100 as FundingPercentage
from FundvsApp
order by FundingPercentage




--------------------------------------------------------------------------------------------------------------------------------------
 --Loan Applications vs Loan Fundings
 --Shows likelihood of a loan application to close by State

 select *
 from Applications

 select * 
 from LoanType
 where filing_year = '2021'

select loa.state 
	, loa.filing_year
	, SUM(loa.loan_cnt) LoanClosings
	, SUM(app.loan_cnt) LoanApps
	--,(LoanClosings/LoanApps) * 100 as ClosingPercentage
from LoanType loa
join applications app
	on loa.State = app.State
where loa.filing_year = '2021'
group by loa.State, loa.filing_year




--------------------------------------------------------------------------------------------------------------------------------------
--Using Temp Table to perform Calculation on Aggregate Functions in previous query

Drop Table if Exists #PercentLoansClosed
Create Table #PercentLoansClosed
(
	state nvarchar (255)
	, filing_year numeric
	, LoanClosings numeric
	, LoanApps numeric
)

Insert into #PercentLoansClosed
select loa.state 
	, loa.filing_year
	, SUM(loa.loan_cnt) LoanClosings
	, SUM(app.loan_cnt) LoanApps
	--,(LoanClosings/LoanApps) * 100 as ClosingPercentage
from LoanType loa
join applications app
	on loa.State = app.State
where loa.filing_year = '2021'
group by loa.State, loa.filing_year
 
select *, (LoanClosings/LoanApps) * 100 as ClosingPercentage
from #PercentLoansClosed
order by ClosingPercentage desc



--------------------------------------------------------------------------------------------------------------------------------------
--Creating View to store data for later visualization

Create View PercentLoansClosed as
select loa.state 
	, loa.filing_year
	, SUM(loa.loan_cnt) LoanClosings
	, SUM(app.loan_cnt) LoanApps
	--,(LoanClosings/LoanApps) * 100 as ClosingPercentage
from LoanType loa
join applications app
	on loa.State = app.State
where loa.filing_year = '2021'
group by loa.State, loa.filing_year