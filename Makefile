.PHONY: nuke storage spark_sql pyspark

nuke:
	docker-compose down -v

storage:
	docker-compose up -d minio db

spark_sql:
	docker-compose run --rm spark /opt/spark/bin/spark-sql
