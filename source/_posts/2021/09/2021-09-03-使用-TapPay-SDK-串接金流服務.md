---
title: 使用 TapPay SDK 串接金流服務
date: 2021-09-03 20:40:56
tags: ["金流", "Go", "JavaScript", "TapPay"]
categories: ["其他", "金流"]
---

## 前言

TapPay 在 [GitHub](https://github.com/TapPay/tappay-web-example) 有提供完整的範例，包括 App ID 和 App Key 等必要資訊。本文僅利用 TapPay SDK 和 Go 來實作一個簡單的付款流程。

## 前端

### 設定

進入後台，在「開發者」的「應用程式」，將 App ID 和 App Key 複製下來。

### 實作

建立一個 `index.html` 檔，引入 TapPay SDK。

```HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <div id="tappay-iframe"></div>
    <div id="message"></div>
    <button id="submit" disabled>Pay</button>
    <script src="https://js.tappaysdk.com/tpdirect/v5.7.0"></script>
    <script src="/assets/app.js"></script>
</body>
</html>
```

在 `assets` 資料夾建立 `app.js` 檔：

```JS
const APP_ID = '';
const APP_KEY = '';

const submitButton = document.querySelector('#submit');
const status = {
  '0': '欄位已填妥',
  '1': '欄位未填妥',
  '2': '欄位有錯誤',
  '3': '輸入中',
};
const style = {
  color: 'black',
  fontSize: '16px',
  lineHeight: '24px',
  fontWeight: '300',
  errorColor: 'red',
  placeholderColor: '',
};
const config = {
  isUsedCcv: true,
};

// 使用 APP_ID 和 APP_KEY 初始化
TPDirect.setupSDK(APP_ID, APP_KEY, 'sandbox');
// 載入表單
TPDirect.card.setup('#tappay-iframe', style, config);
// 監聽表單輸入狀態
TPDirect.card.onUpdate((update) => {
  document.getElementById('message').innerHTML = `
    Card Number Status: ${status[update.status.number]} <br>
    Card Expiry Status: ${status[update.status.expiry]} <br>
    Cvc Status: ${status[update.status.ccv]}
  `;
  update.canGetPrime
    ? submitButton.removeAttribute('disabled')
    : submitButton.setAttribute('disabled', 'true');
});

submitButton.addEventListener('click', () => {
  TPDirect.card.getPrime(async (result) => {
    const res = await pay({
      prime: result.card.prime,
    });
    document.getElementById('message').innerHTML = `
      Message: ${res.msg} <br>
      Amount: ${res.amount} <br>
      Currency: ${res.currency} <br>
      Merchant ID: ${res.merchant_id}
    `;
    console.log(res);
    submitButton.setAttribute('hidden', 'true');
  });
});

// 將 Prime Token 送往應用程式後端
const pay = async (data) => {
  try {
    const res = await fetch('/api/pay', {
      method: 'POST',
      body: JSON.stringify(data),
    });
    return res.json();
  } catch {
    //
  }
};
```

## 後端

### 設定

進入後台，在「帳戶資訊」將 Partner Key 複製下來，以及在「商家管理」的「商家設置」將要使用的 Merchant ID 複製下來。最後，在「開發者」的「系統設定」，將「後台 IP 限制」設為「`0.0.0.0/0`」方便本地測試。

### 實作

建立一個 `config.yaml` 檔，讓後端讀取 Partner Key 和 Merchant ID：

```YAML
---
partner_key:
merchant_id:
```

後端將前端送來的 Prime Token 連同 Partner Key 和 Merchant ID 一起發送至 TapPay 服務端：

```GO
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"gopkg.in/yaml.v2"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"text/template"
	"time"
)

var (
	client = &http.Client{
		Timeout: 10 * time.Second,
	}
	templates = template.Must(template.ParseFiles("index.html"))
	config    Config
)

type Config struct {
	PartnerKey string `yaml:"partner_key"`
	MerchantID string `yaml:"merchant_id"`
}

type Payload struct {
	PartnerKey string `json:"partner_key"`
	Prime      string `json:"prime"`
	Amount     int    `json:"amount"`
	MerchantID string `json:"merchant_id"`
	Details    string `json:"details"`
	Cardholder struct {
		PhoneNumber string `json:"phone_number"`
		Name        string `json:"name"`
		Email       string `json:"email"`
		ZipCode     string `json:"zip_code"`
		Address     string `json:"address"`
		NationalID  string `json:"national_id"`
	} `json:"cardholder"`
}

type Result struct {
	Status            int    `json:"status"`
	Msg               string `json:"msg"`
	Amount            int    `json:"amount"`
	Acquirer          string `json:"acquirer"`
	Currency          string `json:"currency"`
	RecTradeID        string `json:"rec_trade_id"`
	BankTransactionID string `json:"bank_transaction_id"`
	OrderNumber       string `json:"order_number"`
	AuthCode          string `json:"auth_code"`
	CardInfo          struct {
		Issuer      string `json:"issuer"`
		Funding     int    `json:"funding"`
		Type        int    `json:"type"`
		Level       string `json:"level"`
		Country     string `json:"country"`
		LastFour    string `json:"last_four"`
		BinCode     string `json:"bin_code"`
		IssuerZhTw  string `json:"issuer_zh_tw"`
		BankID      string `json:"bank_id"`
		CountryCode string `json:"country_code"`
	} `json:"card_info"`
	TransactionTimeMillis int64 `json:"transaction_time_millis"`
	BankTransactionTime   struct {
		StartTimeMillis string `json:"start_time_millis"`
		EndTimeMillis   string `json:"end_time_millis"`
	} `json:"bank_transaction_time"`
	BankResultCode           string `json:"bank_result_code"`
	BankResultMsg            string `json:"bank_result_msg"`
	CardIdentifier           string `json:"card_identifier"`
	MerchantID               string `json:"merchant_id"`
	IsRbaVerified            bool   `json:"is_rba_verified"`
	TransactionMethodDetails struct {
		TransactionMethodReference string `json:"transaction_method_reference"`
		TransactionMethod          string `json:"transaction_method"`
	} `json:"transaction_method_details"`
}

func init() {
	if err := parseConfig(); err != nil {
		log.Fatal(err)
	}
}

func main() {
	http.HandleFunc("/", Index)
	http.HandleFunc("/api/pay", Pay)
	http.Handle("/assets/", http.StripPrefix("/assets/", http.FileServer(http.Dir("assets"))))
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func parseConfig() error {
	file := "config.yaml"
	b, err := ioutil.ReadFile(file)
	if err != nil {
		return err
	}
	return yaml.Unmarshal(b, &config)
}

// 渲染前端
func Index(w http.ResponseWriter, r *http.Request) {
	if err := templates.ExecuteTemplate(w, "index.html", nil); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// 處理付款
func Pay(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodOptions {
		response(w, http.StatusOK, nil)
		return
	}
	payload := Payload{
		PartnerKey: config.PartnerKey,
		Amount:     1,
		MerchantID: config.MerchantID,
	}
	err := json.NewDecoder(r.Body).Decode(&payload)
	if err != nil {
		response(w, http.StatusBadRequest, nil)
		return
	}
	b, err := json.Marshal(payload)
	if err != nil {
		response(w, http.StatusInternalServerError, nil)
		return
	}
	resp, err := payByPrime(bytes.NewBuffer(b))
	if err != nil {
		response(w, http.StatusInternalServerError, nil)
		return
	}
	result := Result{}
	if err := json.Unmarshal(resp, &result); err != nil {
		response(w, http.StatusInternalServerError, nil)
		return
	}
	response(w, http.StatusOK, result)
}

func payByPrime(body io.Reader) (b []byte, err error) {
	url := "https://sandbox.tappaysdk.com/tpc/payment/pay-by-prime"
	req, _ := http.NewRequest(http.MethodPost, url, body)
	req.Header.Set("x-api-key", config.PartnerKey)
	resp, err := client.Do(req)
	if err != nil {
		return
	}
	if resp.StatusCode != http.StatusOK {
		err = fmt.Errorf("unexpected response code: %v", resp.StatusCode)
		return
	}
	defer closeBody(resp.Body)
	b, err = ioutil.ReadAll(resp.Body)
	if err != nil {
		return
	}
	return
}

func closeBody(reader io.ReadCloser) {
	if err := reader.Close(); err != nil {
		log.Fatal(err)
	}
}

func response(w http.ResponseWriter, code int, v interface{}) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "*")
	w.WriteHeader(code)
	if v == nil {
		return
	}
	if err := json.NewEncoder(w).Encode(v); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}
```

## 程式碼

- [tappay-example](https://github.com/memochou1993/tappay-example)

## 參考資料

- [tappay-web-example](https://github.com/TapPay/tappay-web-example)
