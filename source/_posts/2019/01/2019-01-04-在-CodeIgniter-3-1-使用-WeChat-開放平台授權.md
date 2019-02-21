---
title: 在 CodeIgniter 3.1 使用 WeChat 開放平台授權
permalink: 在-CodeIgniter-3-1-使用-WeChat-開放平台授權
date: 2019-01-04 22:04:48
tags: ["程式寫作", "PHP", "CodeIgniter", "WeChat"]
categories: ["程式寫作", "PHP", "CodeIgniter"]
---

登入：
```PHP
public function login()
{
    // 簡易隨機字串
    $random = md5(rand());

    // 將簡易隨機字串存入 Session
    $this->session->set_userdata([
        'csrf_token' => $random,
    ]);

    $url = 'https://open.weixin.qq.com/connect/qrconnect?' . http_build_query([
        'appid' => $this->config['oauth']['wechat']['appid'],
        'redirect_uri' => $this->config['oauth']['wechat']['redirect_uris'],
        'response_type' => 'code',
        'scope' => 'snsapi_login',
        'state' => $random, // 防止 CSRF 攻擊
    ]) . '#wechat_redirect';

    redirect($url); // 跳轉到微信方
}
```

回調：
```PHP
public function callback($provider) 
{
    $code = $_GET['code'] ?? null;
    $state = $_GET['state'] ?? null;

    // 檢查是否取得 code 以及 state 與 Session 中的是否一致
    if ($code && $state == $this->session->userdata('csrf_token')) {
        $this->session->unset_userdata('csrf_token');

        $url = 'https://api.weixin.qq.com/sns/oauth2/access_token?' . http_build_query([
            'appid' => $this->config['oauth']['wechat']['appid'],
            'secret' => $this->config['oauth']['wechat']['secret'],
            'code' => $code,
            'grant_type' => 'authorization_code',
        ]);
        
        $result = json_decode(file_get_contents($url), true);
        $accessToken = $result['access_token'];
        $openid = $result['openid'];
    }
}
```
