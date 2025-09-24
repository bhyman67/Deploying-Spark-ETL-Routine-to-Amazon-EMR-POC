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

# Define output path for the new table
output_path = "s3://my-new-s3-bucket-bch/processed_data/"

# Create and populate new table with query results using SQL
spark.sql(f"""
    CREATE TABLE IF NOT EXISTS high_volume_stocks (
        ticker STRING,
        the_date STRING,
        open DOUBLE,
        high DOUBLE,
        low DOUBLE,
        close DOUBLE,
        vol DOUBLE
    )
    USING PARQUET
    LOCATION '{output_path}'
""")

# Insert query results into the new table
spark.sql("""
    INSERT OVERWRITE TABLE high_volume_stocks
    SELECT ticker, the_date, open, high, low, close, vol
    FROM 2016_stock_data
    WHERE vol > 250000
""")

# Verify the data was written by showing a sample
verification_df = spark.sql("""
    SELECT COUNT(*) as total_records
    FROM high_volume_stocks
""")

print("ETL job completed successfully!")
verification_df.show()

spark.stop()
