default_bucket := 'whjdbc'
trino_output_format := 'AUTO'

default:
    @just --choose

# lists bucket contents
bucket_ls bucket=default_bucket:
    aws-vault exec minio --no-session -- aws --endpoint-url http://localhost:9000 s3 ls s3://{{bucket}}

# creates a bucket in object storage
bucket_mb bucket=default_bucket:
    aws-vault exec minio --no-session -- aws --endpoint-url http://localhost:9000 s3 mb s3://{{bucket}}

# removes storage layer containers
[confirm]
nuke:
    docker-compose down -v

# spins up minio & postgres 
storage:
	docker-compose up -d minio db

# spins up trino container
trino_coordinator:
    docker-compose up -d trino

# trino cli
run_sql_trino output_format=trino_output_format: trino_coordinator
    docker exec -ti trino trino --output-format-interactive={{output_format}}

# spark sql cli
run_sql_spark:
	docker-compose run --rm spark /opt/spark/bin/spark-sql --conf "spark.hadoop.hive.cli.print.header=true"