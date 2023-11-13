---
title: 使用 Python 和 LangChain 透過 OpenAI API 和 Google Drive API 生成文字補全
date: 2023-07-10 23:15:18
tags: ["Programming", "Python", "GPT", "AI", "OpenAI", "LangChain"]
categories: ["Programming", "Python", "Others"]
---

## 前置作業

首先，到 [Google Cloud](https://console.cloud.google.com/projectcreate) 頁面，建立一個 `langchain-google-drive` 專案。

然後，進到[啟用 API 精靈](https://console.cloud.google.com/projectselector2/apis/enableflow)頁面，啟用 Google Drive API。

### 使用 OAuth 2.0

點選「建立憑證」，選擇「建立 OAuth 用戶端 ID」，選擇「電腦版應用程式」。

建立並下載憑證後，重新命名為 `credentials.json` 檔。

### 使用服務帳戶

或者點選「建立憑證」，選擇「服務帳戶」，建立後進到該服務帳戶點選「新增金鑰」。

建立並下載憑證後，重新命名為 `credentials.json` 檔。

## 建立專案

建立專案。

```bash
mkdir langchain-google-drive
cd langchain-google-drive
```

建立虛擬環境。

```bash
pyenv install 3.11.4
pyenv virtualenv 3.11.4 langchain-google-drive
pyenv local langchain-google-drive
```

新增 `requirements.txt` 檔。

```txt
chromadb==0.3.29
google-api-python-client
google-auth-httplib2
google-auth-oauthlib
langchain
openai
pypdf2
python-dotenv
tiktoken
```

安裝依賴套件。

```bash
pip install -r requirements.txt
```

## 實作

將憑證放到專案根目錄。

```bash
mv ~/Downloads/credentials.json .
```

新增 `.env` 檔，填入環境變數。

```env
OPENAI_API_KEY=
GOOGLE_APPLICATION_CREDENTIALS=./
GOOGLE_DRIVE_FOLDER_ID=
```

新增 `.gitignore` 檔。

```bash
.env
.chroma
credentials.json
```

建立 `main.py` 檔。

```py
from langchain.chat_models import ChatOpenAI
from langchain.chains import RetrievalQA
from langchain.document_loaders import GoogleDriveLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import Chroma
from dotenv import load_dotenv
import os

load_dotenv()

loader = GoogleDriveLoader(
    folder_id=os.environ["GOOGLE_DRIVE_FOLDER_ID"],
    service_account_key='credentials.json',
    # credentials_path='credentials.json',
    # token_path='token.json',
    recursive=False
)
docs = loader.load()

text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=4000, chunk_overlap=0, separators=[" ", ",", "\n"]
)

texts = text_splitter.split_documents(docs)
embeddings = OpenAIEmbeddings()
db = Chroma.from_documents(texts, embeddings)
retriever = db.as_retriever()

llm = ChatOpenAI(temperature=0, model_name="gpt-3.5-turbo")
qa = RetrievalQA.from_chain_type(llm=llm, chain_type="stuff", retriever=retriever)

while True:
    query = input("> ")
    answer = qa.run(query)
    print(answer)
```

執行程式。

```bash
python3.11 main.py
```

## 程式碼

- [langchain-google-drive](https://github.com/memochou1993/langchain-google-drive)

## 參考資料

- [How to build a ChatGPT + Google Drive app with LangChain and Python](https://www.haihai.ai/gpt-gdrive/)
