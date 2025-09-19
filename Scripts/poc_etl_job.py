from pyspark.sql import SparkSession

# Configure SparkSession
spark = (SparkSession.builder
  .appName("view-query-results")
  .config("spark.sql.catalogImplementation", "hive")
  .config("hive.metastore.client.factory.class",
          "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory")
  .enableHiveSupport()
  .getOrCreate())

input_path = "s3://my-new-s3-bucket-bch/Data/"

# Create external table for source CSV data
spark.sql(f"""
    CREATE EXTERNAL TABLE IF NOT EXISTS 2016_stock_data (
        ticker STRING,
        the_date STRING,
        open DOUBLE,
        high DOUBLE,
        low DOUBLE,
        close DOUBLE,
        vol DOUBLE
    )
    ROW FORMAT DELIMITED
    FIELDS TERMINATED BY ','
    STORED AS TEXTFILE
    LOCATION '{input_path}'
    TBLPROPERTIES ('skip.header.line.count'='1')
""")

# Run query
results_df = spark.sql("""
    SELECT *
    FROM 2016_stock_data
    WHERE vol > 10000
    LIMIT 10
""")

# Show results in stdout
results_df.show(truncate=False)

spark.stop()
