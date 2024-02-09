# Developers Apache Iceberg Recipies

Data https://www.kaggle.com/datasets/joebeachcapital/57651-spotify-songs

```bash
aws-vault add minio 
aws-vault exec minio --no-session -- aws --endpoint-url http://localhost:9000 s3 ls
aws-vault exec minio --no-session -- aws --endpoint-url http://localhost:9000 s3 mb s3://warehouse
aws-vault exec minio --no-session -- aws --endpoint-url http://localhost:9000 s3 cp data/spotify_dataset.csv s3://data
```