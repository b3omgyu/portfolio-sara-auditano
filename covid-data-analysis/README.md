# COVID-19 Database Analytics

A relational database project developed using SQL and PL/SQL for the analysis of COVID-19 spread across Italian regions and provinces.

## Project Overview

The project was developed starting from the official COVID-19 dataset released by the Italian Civil Protection Department.

The original master table was analyzed and normalized up to Third Normal Form (3NF) to reduce redundancy and improve data consistency.

The final database includes regional and provincial information together with analytical tools such as SQL queries, views, indexes, stored procedures and triggers.

## Main Features

- Relational database design
- Database normalization (1NF, 2NF, 3NF)
- Entity-Relationship modeling
- SQL analytical queries
- Views and indexes for performance optimization
- PL/SQL stored procedures
- Database triggers
- COVID-19 data analysis and visualization

## Database Structure

### Master Table

![Master Table](docs/create_master_table.png)

### Normalized Schema

![Regioni](docs/create_regioni.png)

![Province](docs/create_province.png)

![Covid Province](docs/create_covid_province.png)

### Entity-Relationship Diagram

![ER Diagram](docs/er_diagram.png)

## Analytics Queries

### Region with the highest population density

![Query 1](docs/query_01_density.png)

### Average number of new positive cases by region

![Query 3](docs/query_03_avg_positive.png)

### Percentage of infected population by region

![Query 5](docs/query_05_infected_percentage.png)

### Monthly trend of positive cases

![Query 10](docs/query_10_monthly_trend.png)

### Positivity index by region

![Query 12](docs/query_12_positivity_index.png)

### COVID-19 cases in Campania provinces

![Campania Query](docs/query_campania_cases.png)

## Views and Indexes

Views were created to group Italian regions into:

- Northern Italy
- Central Italy
- Southern Italy

Additional indexes were introduced to improve query performance.

![Views and Indexes](docs/views_indexes.png)

## Stored Procedures

### Number of cases by region and date

![Procedure 1](docs/procedure_contagi_regione.png)

### Most affected region on a selected date

![Procedure 2](docs/procedure_regione_piu_colpita.png)

## Triggers

The project includes triggers for:

- automatic population of normalized tables;
- backup of deleted records from the master table.

![Triggers](docs/triggers.png)

## Documentation

The complete academic report is available in:

`docs/report.pdf`

## Technologies

- Oracle Database
- SQL
- PL/SQL
- Database Design
- Entity-Relationship Modeling
- Microsoft Excel
- Google Sheets

## Author

Sara Auditano

B.Sc. Telecommunications Engineering

University of Naples Parthenope
