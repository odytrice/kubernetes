# S3A + Delta Lake Architecture

```
Spark SQL → Delta Lake Tables → S3A Protocol → MinIO
```

This replicates Databricks storage pattern with open-source components.

## 1. Spark Configuration for MinIO
```python
spark_conf = {
    # MinIO connection
    "spark.hadoop.fs.s3a.endpoint": "http://minio-service:9000",
    "spark.hadoop.fs.s3a.access.key": "your-minio-access-key",
    "spark.hadoop.fs.s3a.secret.key": "your-minio-secret-key",
    "spark.hadoop.fs.s3a.path.style.access": "true",
    "spark.hadoop.fs.s3a.impl": "org.apache.hadoop.fs.s3a.S3AFileSystem",

    # Delta Lake extensions
    "spark.sql.extensions": "io.delta.sql.DeltaSparkSessionExtension",
    "spark.sql.catalog.spark_catalog": "org.apache.spark.sql.delta.catalog.DeltaCatalog"
}
```

## 2. Data Organization in MinIO
```
my-data-bucket/
├── raw/                    # Your JSON bank statements
│   └── statements/
├── delta/                  # Delta tables
│   ├── transactions/       # Delta table
│   │   ├── _delta_log/     # Transaction log
│   │   ├── part-001.parquet
│   │   └── part-002.parquet
│   └── customers/
└── warehouse/              # Hive metastore warehouse
```

## 3. Convert JSON to Delta Tables
```python
# Read your JSON bank statements
df = spark.read.json("s3a://my-data-bucket/raw/statements/*.json")

# Write as Delta table with partitioning
df.write \
  .format("delta") \
  .partitionBy("year", "month") \
  .mode("overwrite") \
  .save("s3a://my-data-bucket/delta/transactions")

# Register as table for SQL access
spark.sql("""
  CREATE TABLE IF NOT EXISTS transactions
  USING DELTA
  LOCATION 's3a://my-data-bucket/delta/transactions'
""")
```

## 4. Query with Spark SQL
```sql
-- Now query like Databricks
SELECT account_id, SUM(amount) as total_spent
FROM transactions
WHERE year = 2024 AND transaction_type = 'debit'
GROUP BY account_id
ORDER BY total_spent DESC
```

## 5. Kubernetes Deployment
```yaml
apiVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication
metadata:
  name: bank-analysis
spec:
  image: delta-io/delta-docker:2.4.0
  sparkConf:
    spark.hadoop.fs.s3a.endpoint: "http://minio-service:9000"
  deps:
    jars:
      - "https://repo1.maven.org/maven2/io/delta/delta-core_2.12/2.4.0/delta-core_2.12-2.4.0.jar"
```

## Benefits
- **ACID transactions** - Updates/deletes work correctly
- **Time travel** - `SELECT * FROM transactions VERSION AS OF 1`
- **Schema evolution** - Add columns without breaking existing queries
- **Performance** - Automatic file compaction, Z-ordering
- **Databricks compatibility** - Same Delta format