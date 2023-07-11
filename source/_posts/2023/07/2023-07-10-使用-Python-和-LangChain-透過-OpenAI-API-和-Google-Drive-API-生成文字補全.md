---
title: 使用 Python 和 LangChain 透過 OpenAI API 和 Google Drive API 生成文字補全
date: 2023-07-10 23:15:18
tags: ["程式設計", "Python", "GPT", "AI", "OpenAI", "LangChain"]
categories: ["程式設計", "Python", "其他"]
---

## 前置作業

首先到 [Google Cloud](https://console.cloud.google.com/projectcreate) 頁面，建立一個 `langchain-google-drive` 專案。

進到 [快速入門](https://developers.google.com/drive/api/quickstart/python)，進行以下設定：

- 啟用 API
- 設定 OAuth 同意畫面
- 為桌面應用程式授權

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
chroma
chromadb
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

將憑證放到指定資料夾。

```bash
mkdir ~/.credentials
mv ./credentials.json ~/.credentials/credentials.json
```

新增 `.env` 檔，填入環境變數。

```env
OPENAI_API_KEY=
GOOGLE_DRIVE_FOLDER_ID=
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
python3.9 main.py
```

## 程式碼

- [langchain-google-drive](https://github.com/memochou1993/langchain-google-drive)

## 參考資料

- [How to build a ChatGPT + Google Drive app with LangChain and Python](https://www.haihai.ai/gpt-gdrive/)
