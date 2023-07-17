---
title: 使用 GitHub Actions 將 Laravel 專案部署至 AWS ECS 服務
date: 2023-05-25 22:42:00
tags: ["環境部署", "Docker", "PHP", "Laravel", "GitHub", "GitHub Actions", "AWS", "ECS"]
categories: ["程式設計", "PHP", "環境部署"]
---

## 容器化

新增 `docker/nginx/conf.d/default.conf` 檔。

```conf
server {
    listen 80;

    index index.php index.html;

    root /var/www/public;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    location / {
        try_files $uri /index.php?$args;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

新增 `docker/php/php.ini` 檔。

```ini
memory_limit = 256M
max_execution_time = 60
upload_max_filesize = 100M
post_max_size = 100M

date.timezone = "Asia/Taipei"

realpath_cache_size = 128M
realpath_cache_ttl = 86400

opcache.enable = On
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 64
opcache.max_accelerated_files = 50000
opcache.revalidate_freq = 60

session.cookie_httponly = On
session.cookie_secure = On
session.use_strict_mode = On

log_errors = On
error_log = /proc/self/fd/2
```

新增 `docker/entrypoint.sh` 檔。

```bash
#!/usr/bin/env bash

service nginx start
php-fpm
```

新增 `Dockerfile` 檔。

```dockerfile
FROM php:8.2-fpm

RUN apt-get update \
    && apt-get -y install zip \
    nginx

RUN apt-get install -y libpq-dev \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo pdo_pgsql pgsql

RUN docker-php-ext-install opcache

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www

COPY . /var/www
COPY ./docker/php/php.ini /usr/local/etc/php/php.ini
COPY ./docker/nginx/conf.d /etc/nginx/conf.d
COPY ./docker/entrypoint.sh /etc/entrypoint.sh

ENV COMPOSER_ALLOW_SUPERUSER=1

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer install --optimize-autoloader --no-scripts --ignore-platform-reqs
RUN php artisan optimize

RUN chown -R www-data:www-data \
    /var/www/bootstrap/cache \
    /var/www/storage

RUN rm -rf /var/www/html \
    && rm /etc/nginx/sites-enabled/default

EXPOSE 80

CMD ["sh", "/etc/entrypoint.sh"]
```

## 部署腳本

新增 `.github/workflows/deploy.yml` 檔。

```yaml
name: Deploy to Amazon ECS

on:
  push:
    branches:
      - main

env:
  AWS_REGION: ap-northeast-1
  ECR_REPOSITORY: my-api-production
  ECS_SERVICE: my-api-production
  ECS_CLUSTER: my
  ECS_TASK_DEFINITION: my-api-production
  CONTAINER_NAME: my-api-production

permissions:
  contents: read

jobs:
  deploy-production:
    name: Deploy
    runs-on: ubuntu-latest
    environment: production

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build, tag, and push image to Amazon ECR
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          echo "${{secrets.DOT_ENV_PROD }}" > .env
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT

      - name: Register new task definition
        id: task-def
        run: |
          TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition ${{ env.ECS_TASK_DEFINITION }} --region ${{ env.AWS_REGION }} --query 'taskDefinition' --output json)
          NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq '.containerDefinitions[0].image="${{ steps.build-image.outputs.image }}"') 
          echo "$NEW_TASK_DEFINITION" >> new-task-definition.json
          echo "new-task-definition=new-task-definition.json" >> $GITHUB_OUTPUT

      - name: Deploy Amazon ECS task definition
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: ${{ steps.task-def.outputs.new-task-definition }}
          service: ${{ env.ECS_SERVICE }}
          cluster: ${{ env.ECS_CLUSTER }}
          wait-for-service-stability: true
```

將程式碼推送至儲存庫。

## 參考資料

- [Deploying to Amazon Elastic Container Service](https://docs.github.com/en/actions/deployment/deploying-to-your-cloud-provider/deploying-to-amazon-elastic-container-service)
