# 開発合宿2020技術調査メモ
## 概要
Rails5.2からActive Storageがデフォルトで提供されている  
[Active Storage の概要 (Railsガイド)](https://railsguides.jp/active_storage_overview.html)

が、モデルと紐付けが必要であり、今回の要件には含まれていないため利用せずにS3へ直接アップロードする。下記を参考にした。  
https://docs.aws.amazon.com/ja_jp/sdk-for-ruby/v3/developer-guide/s3-example-upload-bucket-item.html

## 環境構築
1. 設定ファイルにS3の情報を記入する  
`config\storage.yml`を開き下記の通り記載する。デフォルトではコメントアウトするだ。け
    ```
    amazon:
        service: S3
        access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
        secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
        region: ap-northeast-1
        bucket: devcamp2020
    ```
1. `config\credentials.yml.enc`を編集  
S3のaccess_key_id, secret_access_keyを記入する  
credentials.yml.encは、デフォルトで暗号化されている。編集するには復号して編集して暗号化する必要があり、下記のコマンドで編集が可能となっている。  
`EDITOR="vi" bin/rails credentials:edit`
    ```
    aws:
      access_key_id: your_access_key_id
      secret_access_key: your_secret_access_key
    ```
1. Gemfileにaws-sdk-s3 gemを追加して`bundle install --path vendor/bundle`でインストール
    ```
    gem "aws-sdk-s3", require: false
    ```
1. 