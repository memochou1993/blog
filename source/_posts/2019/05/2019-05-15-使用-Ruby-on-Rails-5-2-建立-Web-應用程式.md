---
title: 使用 Ruby on Rails 5.2 建立 Web 應用程式
date: 2019-05-15 14:15:41
tags: ["程式設計", "Ruby", "Rails"]
categories: ["程式設計", "Ruby", "Rails"]
---

## 安裝

使用 `gem` 安裝 `rails`。

```BASH
gem install rails
rails --version
Rails 5.2.3
```

## 建立專案

建立專案。

```BASH
rails new blog
cd blog
```

啟動網頁服務器。

```BASH
rails server
```

前往：<http://localhost:3000/>

## 新增歡迎頁面

新增 `Welcome` 控制器，並附帶 `index` 方法。

```BASH
rails generate controller Welcome index
```

修改 `config` 資料夾的 `routes.rb` 檔。

```RB
Rails.application.routes.draw do
  get 'welcome/index'

  root 'welcome#index'
end
```

查看路由。

```BASH
rails routes
```

## 新增路由

修改 `config` 資料夾的 `routes.rb` 檔，並新增一個 `articles` 資源路由。

```RUBY
Rails.application.routes.draw do
  get 'welcome/index'

  resources :articles

  root 'welcome#index'
end
```

## 新增控制器

新增 `Articles` 控制器。

```BASH
rails generate controller Articles
```

修改 `app/controllers` 資料夾的 `articles_controller.rb` 檔：

```RB
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
  end

  def create
    @article = Article.new(article_params)

    @article.save
    redirect_to @article
  end

  private
    def article_params
      params.require(:article).permit(:title, :text)
    end
end
```

## 新增視圖

在 `views/articles` 資料夾新增 `new.html.erb` 視圖。

```HTML
<%= form_with scope: :article, url: articles_path, local: true do |form| %>
  <p>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </p>

  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>

  <p>
    <%= form.submit %>
  </p>
<% end %>
```

在 `views/articles` 資料夾新增 `new.html.erb` 視圖。

```HTML
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>
```

前往：<http://localhost:3000/articles/new>

## 新增模型

新增 `Article` 模型。

```BASH
rails generate model Article title:string text:text
```

執行遷移。

```BASH
rails db:migrate
```
