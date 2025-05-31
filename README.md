## Infrastructure as Code using Terraform

本リポジトリは、AWS上のWebアプリケーションインフラ（ECS + RDS + ALB + S3 + CloudFrontなど）をTerraformで構築・管理するためのコード群です。

## 前提条件

このTerraformコードを実行するには、以下のツールがインストールされている必要があります。

- Terraform v1.6.x 以上（`terraform --version` で確認可能）
- AWS CLI v2（`aws configure` 済み）
- zip コマンド（Lambdaパッケージ作成用）
- make コマンド（Makefile利用のため）

また、実行者には以下のAWS IAM権限が必要です：

- `ec2:*`, `iam:*`, `ecs:*`, `rds:*`, `cloudwatch:*`, `logs:*`, `secretsmanager:*` など

## ディレクトリ構成

```css
terraform/
├── .gitignore             # Git追跡除外
├── Makefile               # 実行コマンドを管理
├── lambda/
│   └── ecs_runtask.py     # Lambda関数のPythonコード
├── lambda_function.tf     # Lambda moduleの呼び出しファイル
├── zip_lambda.sh          # Lambda zip作成スクリプト
├── alb.tf                 # Application Load Balancer関連の設定
├── cloudfront.tf          # CloudFrontの設定
├── ecs.tf                 # ECSクラスターやサービス定義
├── internet_gateway.tf    # インターネットゲートウェイの設定
├── lambda.tf              # lambdaの設定
├── main.tf                # メイン設定ファイル（entry point）
├── nat_gateway.tf         # NATゲートウェイの設定
├── outputs.tf             # 出力値を定義
├── provider.tf            # プロバイダー（例：AWS）定義
├── rds.tf                 # RDSインスタンスの設定
├── README.md              # プロジェクトの概要や使用方法など
├── route_table.tf         # ルートテーブル関連の設定
├── route53.tf             # Route 53（DNS）設定
├── s3_maintenance.tf      # S3バケット定義（メンテナンス用）
├── s3.tf                  # S3バケット定義（静的ホスティングやログ保存など）
├── security_groups.tf     # セキュリティグループの定義
├── subnet.tf              # サブネットの設定
├── variables.tf           # 変数定義ファイル
├── vpc_endpoints.tf       # VPC Endpointの設定
└── vpc.tf                 # VPCの定義

ecs_runtask.zip は zip_lambda.sh により自動生成
```
## セットアップ手順

```css
# Lambda ZIPの作成
make zip

# Terraformの初期化
make init

# 構文チェックおよび内部一貫性の検証
make validate

# 差分の確認（plan出力）
make plan

# リソースの作成・変更（apply）
make apply

# すべてのリソースを削除（destroy）＋ZIPクリーン
make destroy
```

一括で構築する場合は make all を使うこともできます：
```css
make all
```

## シークレット管理

データベース接続情報やAPIキーなどの機密情報は、**AWS Secrets Manager** で安全に管理しています。

### 管理している代表的なシークレット例

- `DATABASE_URL`：RDS接続用のURL
- `SECRET_KEY`：アプリケーションで使用する秘密鍵（FastAPIなど）
- `OPENAI_API_KEY`：OpenAI API連携用のキー

これらは Terraform を通じて ECS タスク定義や Lambda に環境変数として注入されています。