## Infrastructure as Code using Terraform

## ディレクトリ構成

```css
terraform/
├── alb.tf                 # Application Load Balancer関連の設定
├── cloudfront.tf          # CloudFrontの設定
├── ecr.tf                 # ECRの設定
├── ecs.tf                 # ECSクラスターやサービス定義
├── internet_gateway.tf    # インターネットゲートウェイの設定
├── main.tf                # メイン設定ファイル（entry point）
├── nat_gateway.tf         # NATゲートウェイの設定
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
```