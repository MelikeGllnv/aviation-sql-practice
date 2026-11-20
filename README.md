# Aviation SQL Practice

SQL and Power BI projects built on open aviation data, from basic queries to data quality checks.
Database: **SQL Server 2022 Express** · Query language: **T-SQL** · Visualisation: **Power BI Desktop**

|#|Project|Status|
|-|-|-|
|1|[Airport Directory](#project-1--airport-directory)|✅ Done|
|2|Route Network (JOINs)|In progress|
|3|European Traffic in SQL (CTEs, window functions)|Planned|

\---

## Project 1 – Airport Directory

**Question:** What does the open airport data say about Türkiye, and how far can it be trusted?

**Data:** [OurAirports](https://github.com/davidmegginson/ourairports-data) `airports.csv`, 86,368 records worldwide.
**Files:** [`proje1\_havalimani\_rehberi.sql`](proje1_havalimani_rehberi.sql) (15 queries) · [`proje1\_harita.pbix`](proje1_harita.pbix) (Power BI report)

!\[Power BI report: airports in Türkiye by type](proje1\_harita.png)

### Loading the data: three problems and how they were solved

Loading the CSV took longer than the analysis, and taught the most.

|Problem|Symptom|Fix|
|-|-|-|
|Text longer than the column|Import failed on a 90+ character heliport name|Text columns set to `nvarchar(MAX)`; the longest name in the data turned out to be 108 characters|
|Regional settings|No error, but Esenboğa's latitude loaded as **40128100** instead of 40.1281, and 17,889 latitudes were silently dropped|Loaded coordinates as text, then converted with `ALTER COLUMN ... FLOAT`, which always reads `.` as the decimal separator|
|Empty text vs. NULL|Converting `''` to a number gives **0**, which would place an airport in the Gulf of Guinea|`NULLIF(column, '')` before converting|

After each load, a **spot check** against a known airport (LTAC, Ankara Esenboğa: 40.128 N, 32.995 E, 3,125 ft) and a non-null count per column confirmed the result: 86,368 rows, 86,368 coordinates, 71,390 elevations.

### Key findings

1. **"444 airports" in Türkiye is misleading.** 270 (61%) are heliports; only **68** are large or medium airports able to handle scheduled traffic. Definitions must be checked before counting.
2. **The highest airports are all in Eastern Anatolia:** Hakkari Yüksekova (6,400 ft), Kars (5,889 ft), Erzurum (5,763 ft), Van (5,480 ft), Ağrı (5,462 ft). At these elevations thin air reduces engine and wing performance, lengthening the take-off run and limiting payload, especially on hot summer days.
3. **Medium airports sit higher than large ones on average** (2,173 ft vs 1,388 ft). Large airports are mostly in coastal and metropolitan areas (İstanbul, Antalya, İzmir), while many medium airports serve the eastern plateau.
4. **The choice of filter changes the answer.** Searching the city name finds **4** airfields in Ankara; filtering by province code (`TR-06`) finds **24**, because heliports are listed under district names such as Yenimahalle or Gölbaşı.
5. **Hatay (49) has almost as many airfields as İstanbul (50)**, and Ağrı ranks 5th with 20. The map shows them clustered along the borders, which suggests border-post helipads; a breakdown by type is the next query to confirm this.
6. **The three airfields closest to Esenboğa are military:** Etimesgut (33 km), Akıncı (37 km) and Temelli (68 km). Distances were calculated with SQL Server's `geography` type, which accounts for the Earth's curvature.
7. Worldwide, the USA has the most large airports (95), followed by China (69) and Russia (44). Türkiye has 16 and is not in the top 10.

### Data quality notes

These issues were found in the source data itself and will feed into the data quality project later in this repo.

* **204 airports with scheduled service have no IATA code**, including Sir Ahmadu Bello International Airport (Nigeria). None of them is in Türkiye.
* **A duplicate record is flagged only in its name:** `(Duplicate)YEG` in Canada.
* **Status is inconsistent:** Salyazı and Yozgat airports are labelled *Under Construction* in their names but classified as `closed`.
* **Elevation is missing for 14,978 records (17%)**, mostly small airstrips and heliports.
* Integer averages are truncated: `AVG()` on an integer column returned 1,387 instead of 1,388 for large airports, so values are cast to `FLOAT` before averaging.

### SQL used

`SELECT` · `WHERE` · `AND` / `IN` / `LIKE` · `IS NULL` · `GROUP BY` · `HAVING` · `ORDER BY` · `TOP` · `COUNT` / `AVG` / `MAX` / `LEN` · `CAST` / `ROUND` / `NULLIF` · subquery · variables (`DECLARE`) · `geography::Point` and `STDistance` · `CREATE DATABASE` · `ALTER TABLE` · `PRIMARY KEY`

### Power BI

The report connects directly to the SQL Server database. Coordinates were given the *Latitude / Longitude* data category, and summarisation was switched off so Power BI would not add them up. A page-level filter limits the report to Türkiye. The bar chart's counts match the SQL `GROUP BY` result exactly, which cross-checks both tools.

### How to reproduce

1. Create a database in SQL Server: `CREATE DATABASE AviationDB;`
2. Import `airports.csv` with **Import Flat File**: `id` and `elevation\_ft` as `int`, every other column as `nvarchar(MAX)`, all columns nullable.
3. Run the conversion block at the top of `proje1\_havalimani\_rehberi.sql`, then the 15 queries.
4. Open `proje1\_harita.pbix` and point the data source to your own server.

\---

*Melike Gullanova ·* [*github.com/MelikeGllnv*](https://github.com/MelikeGllnv)

