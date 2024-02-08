Data https://www.kaggle.com/datasets/joebeachcapital/57651-spotify-songs
Jupyter
- https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#core-stacks
- https://jupyter-docker-stacks.readthedocs.io/en/latest/using/common.html


```bash
aws-vault add minio 
aws-vault exec minio --no-session -- aws --endpoint-url http://localhost:9000 s3 ls
aws-vault exec minio --no-session -- aws --endpoint-url http://localhost:9000 s3 mb s3://data
aws-vault exec minio --no-session -- aws --endpoint-url http://localhost:9000 s3 cp data/spotify_dataset.csv s3://data
```

```bash
pipx install podman-compose
```

```bash
virtualenv --python=/opt/homebrew/opt/python@3.11/libexec/bin/python .venv
source .venv/bin/activate.fish
pip install -r requirements.pip
```

```bash
docker-compose run --rm spark-sql
```