# Makefile for Terraform + Lambda zip deploy

LAMBDA_DIR=lambda
LAMBDA_SRC=$(LAMBDA_DIR)/ecs_runtask.py
LAMBDA_ZIP=$(LAMBDA_DIR)/ecs_runtask.zip

.PHONY: all zip init plan apply clean destroy

# すべてを一括実行（zip → init → plan → apply）
all: zip init plan apply

# Lambda zip生成
zip:
	@echo "Lambda ZIP を作成中..."
	cd $(LAMBDA_DIR) && zip -j ecs_runtask.zip ecs_runtask.py
	@echo "作成完了: $(LAMBDA_ZIP)"

# Terraform 初期化
init:
	terraform init

# Terraform 構文および内部一貫性の検証
validate:
	terraform validate

# Terraform の変更内容を事前確認
plan:
	terraform plan -out=tfplan

# Terraform 適用
apply:
	terraform apply tfplan

# zipファイルの削除
clean:
	@echo "ZIP ファイルを削除中..."
	rm -f $(LAMBDA_ZIP) tfplan
	rm -rf .terraform
	@echo "削除完了"

# すべてのリソースを削除
destroy:
	@echo "Terraform リソースを削除中..."
	terraform destroy -auto-approve
	$(MAKE) clean
	@echo "削除完了"