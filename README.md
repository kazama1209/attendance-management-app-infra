# terraform-rails-on-ecs-fargate

Rails アプリを ECS（Fargate）にデプロイするための Terraform コード一式。

## セットアップ

環境変数をセット。

```
$ cp terraform.tfvars.example terraform.tfvars
```

terraform.tfvars 内に AWS アクセスキーやデータベースなどの情報などを記述する。

```
aws_access_key      = "AWSのアクセスキー"
aws_secret_key      = "AWSのシークレットキー"
aws_account_id      = "AWSのアカウントID"
domain_name         = "ドメイン名"
database_host       = "RDSのエンドポイント"
database_name       = "データベース名"
database_username   = "ユーザー名"
database_password   = "パスワード"
app_host            = "アプリのホスト"
rails_master_key    = "マスターキー"
rails_log_to_stdout = 1
mailer_user_name    = "送信元Gmailアカウントのメールアドレス"
mailer_password     = "送信元Gmailアカウントのアプリパスワード"
```

### Terraform 初期化

```
$ terraform init
```

### ECR を作成 & イメージをプッシュ

※ イメージのビルドはアプリ側のリポジトリで行う。

```
$ terraform apply -target={aws_ecr_repository.app,aws_ecr_lifecycle_policy.app,aws_ecr_repository.nginx}

$ aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin <AWS Account ID>.dkr.ecr.ap-northeast-1.amazonaws.com

$ docker build -f ./docker/production/web/Dockerfile . -t myapp-app
$ docker build -f ./docker/production/nginx/Dockerfile . -t myapp-nginx
$ docker tag myapp-app:latest <AWS Account ID>.dkr.ecr.ap-northeast-1.amazonaws.com/myapp-app:latest
$ docker tag myapp-nginx:latest <AWS Account ID>.dkr.ecr.ap-northeast-1.amazonaws.com/myapp-nginx:latest
$ docker push <AWS Account ID>.dkr.ecr.ap-northeast-1.amazonaws.com/myapp-app:latest
$ docker push <AWS Account ID>.dkr.ecr.ap-northeast-1.amazonaws.com/myapp-nginx:latest
```

### RDS を作成

```
$ terraform apply -target={aws_db_subnet_group.main,aws_db_instance.mysql}
```

### その他リソースを一括で作成

```
$ terraform apply
```

### DB 関連の ECS タスクを実行

```
$ aws ecs describe-services --cluster myapp-cluster --services myapp-service | jq ".services[0].networkConfiguration"

$ aws ecs run-task \
--cluster "myapp-cluster" \
--task-definition "arn:aws:ecs:ap-northeast-1:<AWS Account ID>:task-definition/myapp" \
--network-configuration "awsvpcConfiguration={subnets=[subnet-************,subnet-************],securityGroups=[sg-************,sg-************],assignPublicIp=ENABLED}" \
--overrides file://task-definitions/db_migrate.json \
--launch-type FARGATE

$ aws ecs run-task \
--cluster "myapp-cluster" \
--task-definition "arn:aws:ecs:ap-northeast-1:<AWS Account ID>:task-definition/myapp" \
--network-configuration "awsvpcConfiguration={subnets=[subnet-************,subnet-************],securityGroups=[sg-************,sg-************],assignPublicIp=ENABLED}" \
--overrides file://task-definitions/db_seed.json \
--launch-type FARGATE
```
