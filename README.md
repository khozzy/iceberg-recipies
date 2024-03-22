# Developers Guide to Data Lakehouse with Apache Iceberg
[Blog post](https://kozlov.ski/developers-guide-to-data-lakehouse-with-apache-iceberg/)

Examine [justfile](./justfile) recipies to get started.

## Storage layer setup
```bash
just nuke
just storage
just bucket_mb
```

## Running queries
To run queries with either Spark SQL or Trino interactively

```bash
just run_sql_spark
just run_sql_trino
```

## SQL queries and commands
### 1. Table creation

```sql
-- Spark SQL
drop table cat_jdbc.db.events;

create table if not exists cat_jdbc.db.events (
    event_ts timestamp,
    level string,
    message string,
    stack_trace array<string>
)
using iceberg;

select * from cat_jdbc.db.events;
```

### 2. Metastore
```sql
-- Trino
show tables from metastore.public;
select * from metastore.public.iceberg_tables;
```
Inspection of metadata in S3 bucket

```bash
aws --endpoint-url http://localhost:9000 s3 cp s3://<FILE> - | jq
```

### 3. Data insert
```sql
-- Spark SQL
insert into cat_jdbc.db.events
values
(
    timestamp '2023-01-01 12:00:00.000001',
    'INFO',
    'App started',
    null
),
(
    timestamp '2023-01-02 13:20:00.000001',
    'ERROR',
    'Exception',
    array(
        'java.lang.Exception: Stack trace at
        java.base/java.lang.Thread.dumpStack(Thread.java:1380)'
    )
),
(
    timestamp '2023-01-02 15:45:00.000001',
    'WARN',
    'NullPointerException',
    array(
        'java.lang.NullPointerException: Stack trace at
        java.base/java.lang.Thread.dumpStack(Thread.java:1380)'
    )
);
```

### 4. Transaction support
```sql
-- Trino
update warehouse.db.events
    set message = 'NPE'
    where message = 'NullPointerException';

delete from warehouse.db.events
    where level = 'INFO';

insert into warehouse.db.events
values
(
    timestamp '2023-03-01 08:00:00.000001',
    'VERBOSE',
    'Connector configured',
    null
);

select * from warehouse.db.events;
```

### 5. Schema evolution
```sql
-- Trino
alter table warehouse.db.events add column severity integer; 
alter table warehouse.db.events rename column severity to priority;

select * from warehouse.db.events;
```

### 6. Hidden partitioning
```sql
-- Spark SQL
create table cat_jdbc.db.events_by_day (
    event_ts timestamp,
    level string,
    message string,
    stack_trace array<string>)
using iceberg
partitioned by (days(event_ts));


insert into cat_jdbc.db.events_by_day
select event_ts, level, message, stack_trace from cat_jdbc.db.events;
```

Existing table repartitioning
```sql
-- Trino
use warehouse.db;

drop table t1;
create table t1 (category varchar, value integer);
insert into t1 values ('cat1', 1), ('cat2', 1), ('cat2', 13), ('cat2', 51);

select * from "t1$partitions";

-- Repartition table maintaining snapshot history
create or replace table t1
with (partitioning = array['category'])
as select * from t1;

select * from "t1$partitions"; 
```

Predicate pushdown evaluation
```sql
-- Spark SQL
explain
select * from cat_jdbc.db.events
where cast(event_ts as date) = '2023-01-02';
```

```sql
-- Trino
explain
select * from warehouse.db.events
where date_trunc('day', event_ts) = date('2023-01-02');
```

### 7. Time travel
```sql
-- Trino
use warehouse.db;

-- Retrieving all table snapshots
select committed_at, snapshot_id
from "events$snapshots"
order by 1 asc;

-- Accessing data via a specific snapshot ID
select * from events for version as of 9139268659351273252;

-- Querying data at a specific point in time
select * from events for timestamp as of timestamp '2024-03-22 12:05:15 UTC';
```
Tagging
```sql
-- Spark SQL
use cat_jdbc.db;

-- Listing snapshots for a given table
select committed_at, snapshot_id
from cat_jdbc.db.events.snapshots
order by 1 asc;

-- Creating a permanent tag `INIT` for the initial snapshot
alter table events
  create tag `INIT`
  as of version 6154889736903359039;

-- Creating a temporary tag `INIT-EOW`, valid for one week
alter table events
  create tag `INIT-EOW`
  as of version 6154889736903359039
  retain 7 days;

-- Listing all tags and branches
select * from cat_jdbc.db.events.refs;

-- Querying the table using a specific tag
select * from events version as of 'INIT';
```

### 8. Maintenance
Files compaction
```sql
-- Spark SQL
CALL cat_jdbc.system.rewrite_data_files(
  table => 'db.events', 
  strategy => 'binpack', 
  options => map('min-input-files','2')
);
```

```sql
-- Trino
ALTER TABLE warehouse.db.events
  EXECUTE optimize(file_size_threshold => '128MB');
```
Snapshot expiration

```sql
-- Spark SQL
-- Expire all older by 5 days (default)
CALL cat_jdbc.system.expire_snapshots
  ('db.events');

-- Expire all snapshots older than specified date
CALL cat_jdbc.system.expire_snapshots
  ('db.events', TIMESTAMP '2023-12-30 00:00:00.000');
```

```sql
-- Trino
ALTER TABLE warehouse.db.events
  EXECUTE expire_snapshots(retention_threshold => '7d');
```

Orphan files removal
```sql
-- Spark SQL
-- This might not yet work with files on S3
-- bug: https://github.com/apache/iceberg/issues/8368
CALL cat_jdbc.system.remove_orphan_files
  (table => 'db.events', dry_run => true);
```

```sql
-- Trino
ALTER TABLE warehouse.db.events
  EXECUTE remove_orphan_files(retention_threshold => '7d');
```