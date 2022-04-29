---
title: 在 Next 12.0 使用 Raydium 建立 Solana 的 Swap 介面
permalink: 在-Next-12-0-使用-Raydium-建立-Solana-的-Swap-介面
date: 2022-04-22 21:01:43
tags: ["區塊鏈", "Solana", "Rust", "Web3", "JavaScript", "Smart Contract", "DApp"]
categories: ["區塊鏈", "Solana"]
---

## 前言

本文為「Solana 開發者的入門指南」影片的學習筆記。

## 建立專案

建立專案。

```BASH
npx create-next-app@latest solana-swap --typescript
```

## 安裝套件

刪除 `yarn.lock` 檔。

```BASH
rm yarn.lock
```

更新 `package.json` 檔。

```BASH
{
  "name": "solmeet-4-swap-ui",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "@chakra-ui/icons": "^1.1.1",
    "@chakra-ui/react": "^1.7.4",
    "@emotion/react": "^11",
    "@emotion/styled": "^11",
    "@jup-ag/react-hook": "^1.0.0-beta.2",
    "@project-serum/borsh": "^0.2.3",
    "@project-serum/serum": "^0.13.61",
    "@solana/spl-token-registry": "^0.2.1733",
    "@solana/wallet-adapter-base": "^0.9.2",
    "@solana/wallet-adapter-react": "^0.15.2",
    "@solana/wallet-adapter-react-ui": "^0.9.4",
    "@solana/wallet-adapter-wallets": "^0.14.2",
    "@solana/web3.js": "^1.32.0",
    "framer-motion": "^5",
    "lodash-es": "^4.17.21",
    "next": "12.0.8",
    "next-compose-plugins": "^2.2.1",
    "next-transpile-modules": "^9.0.0",
    "react": "17.0.2",
    "react-dom": "17.0.2",
    "sass": "^1.49.0"
  },
  "devDependencies": {
    "@types/lodash-es": "^4.17.5",
    "@types/node": "17.0.10",
    "@types/react": "17.0.38",
    "eslint": "8.7.0",
    "eslint-config-next": "12.0.8",
    "typescript": "4.5.5"
  },
  "resolutions": {
    "@solana/buffer-layout": "^3.0.0"
  }
}
```

安裝依賴套件。

```BASH
yarn
```

## 組織架構

建立相關資料夾。

```BASH
mkdir utils && touch utils/{ids.ts,layouts.ts,liquidity.ts,pools.ts,safe-math.ts,swap.ts,tokenList.ts,tokens.ts,web3.ts}
mkdir views && mkdir views/{commons,jupiter,raydium}
touch views/commons/{Navigator.tsx,WalletProvider.tsx,SplTokenList.tsx,Notify.tsx} && touch views/jupiter/{FeeInfo.tsx,JupiterForm.tsx,JupiterProvider.tsx} && touch views/raydium/{index.tsx,SlippageSetting.tsx,SwapOperateContainer.tsx,TokenList.tsx,TokenSelect.tsx,TitleRow.tsx}
touch styles/{swap.module.sass,color.module.sass,navigator.module.sass,jupiter.module.sass}
touch pages/{index.tsx,jupiter.tsx,raydium.tsx}
mkdir chakra && touch chakra/style.js
```

## 實作錢包

更新 `views/commons/Navigator.tsx` 檔。

```TS
import { FunctionComponent } from "react";
import Link from "next/link";
import {
  WalletModalProvider,
  WalletDisconnectButton,
  WalletMultiButton
} from "@solana/wallet-adapter-react-ui";
import { useWallet } from "@solana/wallet-adapter-react";
import style from "../../styles/navigator.module.sass";

const Navigator: FunctionComponent = () => {
  const wallet = useWallet();
  return (
    <div className={style.sidebar}>
      <div className={style.routesBlock}>
        <Link href="/" passHref>
          <a href="https://ibb.co/yP2vCNL">
            <img
              src="https://i.ibb.co/g9Yq8rs/logo-v4-horizontal-transparent.png"
              alt="logo-v4-horizontal-transparent"
              className={style.dappioLogo}
            />
          </a>
        </Link>
        <Link href="/jupiter">
          <a className={style.route}>Jupiter</a>
        </Link>
        <Link href="/raydium">
          <a className={style.route}>Raydium</a>
        </Link>
      </div>
      <WalletModalProvider>
        {wallet.connected ? <WalletDisconnectButton /> : <WalletMultiButton />}
      </WalletModalProvider>
    </div>
  );
};

export default Navigator;
```

更新 `views/commons/Notify.tsx` 檔。

```TS
import { FunctionComponent } from "react";
import {
  Alert,
  AlertIcon,
  AlertTitle,
  AlertDescription,
  AlertStatus
} from "@chakra-ui/react";
import style from "../../styles/swap.module.sass";

export interface INotify {
  status: AlertStatus;
  title: string;
  description: string;
  link?: string;
}
interface NotifyProps {
  message: {
    status: AlertStatus;
    title: string;
    description: string;
    link?: string;
  };
}

const Notify: FunctionComponent<NotifyProps> = props => {
  return (
    <Alert status={props.message.status} className={style.notifyContainer}>
      <div className={style.notifyTitleRow}>
        <AlertIcon boxSize="2rem" />
        <AlertTitle className={style.title}>{props.message.title}</AlertTitle>
      </div>
      <AlertDescription className={style.notifyDescription}>
        {props.message.description}
      </AlertDescription>
      {props.message.link ? (
        <a
          href={props.message.link}
          style={{ color: "#fbae21", textDecoration: "underline" }}
        >
          Check Explorer
        </a>
      ) : (
        ""
      )}
    </Alert>
  );
};

export default Notify;
```

更新 `views/commons/SplTokenList.tsx` 檔。

```TS
import { FunctionComponent } from "react";
import style from "../../styles/swap.module.sass";
import { TOKENS } from "../../utils/tokens";
import { ISplToken } from "../../utils/web3";

interface ISplTokenProps {
  splTokenData: ISplToken[];
}

interface SplTokenDisplayData {
  symbol: string;
  mint: string;
  pubkey: string;
  amount: number;
}

const SplTokenList: FunctionComponent<ISplTokenProps> = (
  props
): JSX.Element => {
  let tokenList: SplTokenDisplayData[] = [];
  if (props.splTokenData.length === 0) {
    return <></>;
  }

  for (const [_, value] of Object.entries(TOKENS)) {
    let spl: ISplToken | undefined = props.splTokenData.find(
      (t: ISplToken) => t.parsedInfo.mint === value.mintAddress
    );
    if (spl) {
      let token = {} as SplTokenDisplayData;
      token["symbol"] = value.symbol;
      token["mint"] = spl?.parsedInfo.mint;
      token["pubkey"] = spl?.pubkey;
      token["amount"] = spl?.amount;
      tokenList.push(token);
    }
  }

  let tokens = tokenList.map((item: SplTokenDisplayData) => {
    return (
      <div key={item.mint} className={style.splTokenItem}>
        <div>
          <span style={{ marginRight: "1rem", fontWeight: "600" }}>
            {item.symbol}
          </span>
          <span>- {item.amount}</span>
        </div>
        <div style={{ opacity: ".25" }}>
          <div>Mint: {item.mint}</div>
          <div>Pubkey: {item.pubkey}</div>
        </div>
      </div>
    );
  });

  return (
    <div className={style.splTokenContainer}>
      <div className={style.splTokenListTitle}>Your Tokens</div>
      {tokens}
    </div>
  );
};

export default SplTokenList;
```

更新 `views/commons/WalletProvider.tsx` 檔。

```TS
import React, { FunctionComponent, useMemo } from "react";
import {
  ConnectionProvider,
  WalletProvider
} from "@solana/wallet-adapter-react";
import { WalletAdapterNetwork } from "@solana/wallet-adapter-base";
import {
  LedgerWalletAdapter,
  PhantomWalletAdapter,
  SlopeWalletAdapter,
  SolflareWalletAdapter,
  SolletExtensionWalletAdapter,
  SolletWalletAdapter,
  TorusWalletAdapter
} from "@solana/wallet-adapter-wallets";
import { clusterApiUrl } from "@solana/web3.js";

// Default styles that can be overridden by your app
require("@solana/wallet-adapter-react-ui/styles.css");

export const Wallet: FunctionComponent = props => {
  // // The network can be set to 'devnet', 'testnet', or 'mainnet-beta'.
  const network = WalletAdapterNetwork.Mainnet;

  // // You can also provide a custom RPC endpoint.
  const endpoint = "https://rpc-mainnet-fork.dappio.xyz";

  // @solana/wallet-adapter-wallets includes all the adapters but supports tree shaking and lazy loading --
  // Only the wallets you configure here will be compiled into your application, and only the dependencies
  // of wallets that your users connect to will be loaded.
  const wallets = useMemo(
    () => [
      new PhantomWalletAdapter(),
      new SlopeWalletAdapter(),
      new SolflareWalletAdapter(),
      new TorusWalletAdapter(),
      new LedgerWalletAdapter(),
      new SolletWalletAdapter({ network }),
      new SolletExtensionWalletAdapter({ network })
    ],
    [network]
  );

  return (
    <ConnectionProvider endpoint={endpoint}>
      <WalletProvider wallets={wallets} autoConnect>
        {props.children}
      </WalletProvider>
    </ConnectionProvider>
  );
};
```

更新 `pages/raydium.tsx` 檔。

```TS
import { FunctionComponent } from "react";

const RaydiumPage: FunctionComponent = () => {
  return <div>This is Raydium Page</div>;
};

export default RaydiumPage;
```

更新 `pages/_app.tsx` 檔。

```TS
import "../styles/globals.css";
import type { AppProps } from "next/app";
import { Wallet } from "../views/commons/WalletProvider";
import Navigator from "../views/commons/Navigator";

function SwapUI({ Component, pageProps }: AppProps) {
  return (
    <>
      <Wallet>
        <Navigator />
        <Component {...pageProps} />
      </Wallet>
    </>
  );
}

export default SwapUI;
```

### 更新樣式

更新 `styles/globals.css` 檔。

```CSS
html,
body {
  font-size: 10px;
  background-color: rgb(19, 27, 51);
  color: #eee
}

.wallet-adapter-modal-list-more {
  color: #eee
}
.wallet-adapter-button-trigger {
  background-color: #fbae21 !important;
  color: black !important
}
```

更新 `styles/navigator.module.sass` 檔。

```CSS
@import './color.module.sass'

.dappioLogo
  flex: 2
  text-align: center
  width: 12rem
  margin-right: 10rem
  cursor: pointer
.sidebar
  display: flex
  align-items: center
  font-size: 2rem
  height: 7rem
  border-bottom: 1px solid rgb(29, 40, 76)
  background-color: $main_blue
  padding: 0 4rem
  justify-content: space-between
  letter-spacing: .1rem
  font-weight: 500
.routesBlock
  display: flex
  align-items: center
  justify-content: space-around
  color: $white
  font-size: 1.5rem
.route
  margin-right: 5rem
```

更新 `styles/color.module.sass` 檔。

```CSS
$white: #eee
$main_blue: rgb(19, 27, 51)
$swap_card_bgc: #131a35
$coin_select_block_bgc: #000829
$placeholder_grey: #f1f1f2
$swap_btn_border_color: #5ac4be
$token_list_bgc: #1c274f
$slippage_setting_warning_red: #f5222d
```

更新 `` 檔。

```CSS
```

## 實作代幣交換

更新 `utils/ids.ts` 檔。

```TS
import { PublicKey } from '@solana/web3.js'

export const SYSTEM_PROGRAM_ID = new PublicKey('11111111111111111111111111111111')
export const TOKEN_PROGRAM_ID = new PublicKey('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA')
export const MEMO_PROGRAM_ID = new PublicKey('Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo')
export const RENT_PROGRAM_ID = new PublicKey('SysvarRent111111111111111111111111111111111')
export const CLOCK_PROGRAM_ID = new PublicKey('SysvarC1ock11111111111111111111111111111111')
export const ASSOCIATED_TOKEN_PROGRAM_ID = new PublicKey('ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL')

export const SERUM_PROGRAM_ID_V2 = 'EUqojwWA2rd19FZrzeBncJsm38Jm1hEhE3zsmX3bRc2o'
export const SERUM_PROGRAM_ID_V3 = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin'

export const LIQUIDITY_POOL_PROGRAM_ID_V2 = 'RVKd61ztZW9GUwhRbbLoYVRE5Xf1B2tVscKqwZqXgEr'
export const LIQUIDITY_POOL_PROGRAM_ID_V3 = '27haf8L6oxUeXrHrgEgsexjSY5hbVUWEmvv9Nyxg8vQv'
export const LIQUIDITY_POOL_PROGRAM_ID_V4 = '675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8'

export const STABLE_POOL_PROGRAM_ID = '5quBtoiQqxF9Jv6KYKctB59NT3gtJD2Y65kdnB1Uev3h'

export const ROUTE_SWAP_PROGRAM_ID = '93BgeoLHo5AdNbpqy9bD12dtfxtA5M2fh3rj72bE35Y3'

export const STAKE_PROGRAM_ID = 'EhhTKczWMGQt46ynNeRX1WfeagwwJd7ufHvCDjRxjo5Q'
export const STAKE_PROGRAM_ID_V4 = 'CBuCnLe26faBpcBP2fktp4rp8abpcAnTWft6ZrP5Q4T'
export const STAKE_PROGRAM_ID_V5 = '9KEPoZmtHUrBbhWN1v1KWLMkkvwY6WLtAVUCPRtRjP4z'

export const IDO_PROGRAM_ID = '6FJon3QE27qgPVggARueB22hLvoh22VzJpXv4rBEoSLF'
export const IDO_PROGRAM_ID_V2 = 'CC12se5To1CdEuw7fDS27B7Geo5jJyL7t5UK2B44NgiH'
export const IDO_PROGRAM_ID_V3 = '9HzJyW1qZsEiSfMUf6L2jo3CcTKAyBmSyKdwQeYisHrC'

export const AUTHORITY_AMM = 'amm authority'
export const AMM_ASSOCIATED_SEED = 'amm_associated_seed'
export const TARGET_ASSOCIATED_SEED = 'target_associated_seed'
export const WITHDRAW_ASSOCIATED_SEED = 'withdraw_associated_seed'
export const OPEN_ORDER_ASSOCIATED_SEED = 'open_order_associated_seed'
export const COIN_VAULT_ASSOCIATED_SEED = 'coin_vault_associated_seed'
export const PC_VAULT_ASSOCIATED_SEED = 'pc_vault_associated_seed'
export const LP_MINT_ASSOCIATED_SEED = 'lp_mint_associated_seed'
export const TEMP_LP_TOKEN_ASSOCIATED_SEED = 'temp_lp_token_associated_seed'
```

更新 `utils/layouts.ts` 檔。

```TS
import { bool, publicKey, struct, u32, u64, u8 } from '@project-serum/borsh'

// https://github.com/solana-labs/solana-program-library/blob/master/token/js/client/token.js#L210
export const ACCOUNT_LAYOUT = struct([
  publicKey('mint'),
  publicKey('owner'),
  u64('amount'),
  u32('delegateOption'),
  publicKey('delegate'),
  u8('state'),
  u32('isNativeOption'),
  u64('isNative'),
  u64('delegatedAmount'),
  u32('closeAuthorityOption'),
  publicKey('closeAuthority')
])

export const MINT_LAYOUT = struct([
  u32('mintAuthorityOption'),
  publicKey('mintAuthority'),
  u64('supply'),
  u8('decimals'),
  bool('initialized'),
  u32('freezeAuthorityOption'),
  publicKey('freezeAuthority')
])

export function getBigNumber(num: any) {
  return num === undefined || num === null ? 0 : parseFloat(num.toString())
}
```

更新 `utils/liquidity.ts` 檔。

```TS
//@ts-ignore
import { struct } from "buffer-layout";
import { publicKey, u128, u64 } from "@project-serum/borsh";
import { PublicKey } from "@solana/web3.js";
import { LP_TOKENS } from "./tokens";
import { commitment, getMultipleAccounts } from "./web3";
import { MINT_LAYOUT } from "./layouts";

export const AMM_INFO_LAYOUT = struct([
  u64("status"),
  u64("nonce"),
  u64("orderNum"),
  u64("depth"),
  u64("coinDecimals"),
  u64("pcDecimals"),
  u64("state"),
  u64("resetFlag"),
  u64("fee"),
  u64("minSize"),
  u64("volMaxCutRatio"),
  u64("pnlRatio"),
  u64("amountWaveRatio"),
  u64("coinLotSize"),
  u64("pcLotSize"),
  u64("minPriceMultiplier"),
  u64("maxPriceMultiplier"),
  u64("needTakePnlCoin"),
  u64("needTakePnlPc"),
  u64("totalPnlX"),
  u64("totalPnlY"),
  u64("systemDecimalsValue"),
  publicKey("poolCoinTokenAccount"),
  publicKey("poolPcTokenAccount"),
  publicKey("coinMintAddress"),
  publicKey("pcMintAddress"),
  publicKey("lpMintAddress"),
  publicKey("ammOpenOrders"),
  publicKey("serumMarket"),
  publicKey("serumProgramId"),
  publicKey("ammTargetOrders"),
  publicKey("ammQuantities"),
  publicKey("poolWithdrawQueue"),
  publicKey("poolTempLpTokenAccount"),
  publicKey("ammOwner"),
  publicKey("pnlOwner")
]);

export const AMM_INFO_LAYOUT_V3 = struct([
  u64("status"),
  u64("nonce"),
  u64("orderNum"),
  u64("depth"),
  u64("coinDecimals"),
  u64("pcDecimals"),
  u64("state"),
  u64("resetFlag"),
  u64("fee"),
  u64("min_separate"),
  u64("minSize"),
  u64("volMaxCutRatio"),
  u64("pnlRatio"),
  u64("amountWaveRatio"),
  u64("coinLotSize"),
  u64("pcLotSize"),
  u64("minPriceMultiplier"),
  u64("maxPriceMultiplier"),
  u64("needTakePnlCoin"),
  u64("needTakePnlPc"),
  u64("totalPnlX"),
  u64("totalPnlY"),
  u64("poolTotalDepositPc"),
  u64("poolTotalDepositCoin"),
  u64("systemDecimalsValue"),
  publicKey("poolCoinTokenAccount"),
  publicKey("poolPcTokenAccount"),
  publicKey("coinMintAddress"),
  publicKey("pcMintAddress"),
  publicKey("lpMintAddress"),
  publicKey("ammOpenOrders"),
  publicKey("serumMarket"),
  publicKey("serumProgramId"),
  publicKey("ammTargetOrders"),
  publicKey("ammQuantities"),
  publicKey("poolWithdrawQueue"),
  publicKey("poolTempLpTokenAccount"),
  publicKey("ammOwner"),
  publicKey("pnlOwner"),
  publicKey("srmTokenAccount")
]);

export const AMM_INFO_LAYOUT_V4 = struct([
  u64("status"),
  u64("nonce"),
  u64("orderNum"),
  u64("depth"),
  u64("coinDecimals"),
  u64("pcDecimals"),
  u64("state"),
  u64("resetFlag"),
  u64("minSize"),
  u64("volMaxCutRatio"),
  u64("amountWaveRatio"),
  u64("coinLotSize"),
  u64("pcLotSize"),
  u64("minPriceMultiplier"),
  u64("maxPriceMultiplier"),
  u64("systemDecimalsValue"),
  // Fees
  u64("minSeparateNumerator"),
  u64("minSeparateDenominator"),
  u64("tradeFeeNumerator"),
  u64("tradeFeeDenominator"),
  u64("pnlNumerator"),
  u64("pnlDenominator"),
  u64("swapFeeNumerator"),
  u64("swapFeeDenominator"),
  // OutPutData
  u64("needTakePnlCoin"),
  u64("needTakePnlPc"),
  u64("totalPnlPc"),
  u64("totalPnlCoin"),

  u64("poolOpenTime"),
  u64("punishPcAmount"),
  u64("punishCoinAmount"),
  u64("orderbookToInitTime"),

  u128("swapCoinInAmount"),
  u128("swapPcOutAmount"),
  u64("swapCoin2PcFee"),
  u128("swapPcInAmount"),
  u128("swapCoinOutAmount"),
  u64("swapPc2CoinFee"),

  publicKey("poolCoinTokenAccount"),
  publicKey("poolPcTokenAccount"),
  publicKey("coinMintAddress"),
  publicKey("pcMintAddress"),
  publicKey("lpMintAddress"),
  publicKey("ammOpenOrders"),
  publicKey("serumMarket"),
  publicKey("serumProgramId"),
  publicKey("ammTargetOrders"),
  publicKey("poolWithdrawQueue"),
  publicKey("poolTempLpTokenAccount"),
  publicKey("ammOwner"),
  publicKey("pnlOwner")
]);

export const AMM_INFO_LAYOUT_STABLE = struct([
  u64("status"),
  publicKey("own_address"),
  u64("nonce"),
  u64("orderNum"),
  u64("depth"),
  u64("coinDecimals"),
  u64("pcDecimals"),
  u64("state"),
  u64("resetFlag"),
  u64("minSize"),
  u64("volMaxCutRatio"),
  u64("amountWaveRatio"),
  u64("coinLotSize"),
  u64("pcLotSize"),
  u64("minPriceMultiplier"),
  u64("maxPriceMultiplier"),
  u64("systemDecimalsValue"),

  u64("ammMaxPrice"),
  u64("ammMiddlePrice"),
  u64("ammPriceMultiplier"),

  // Fees
  u64("minSeparateNumerator"),
  u64("minSeparateDenominator"),
  u64("tradeFeeNumerator"),
  u64("tradeFeeDenominator"),
  u64("pnlNumerator"),
  u64("pnlDenominator"),
  u64("swapFeeNumerator"),
  u64("swapFeeDenominator"),
  // OutPutData
  u64("needTakePnlCoin"),
  u64("needTakePnlPc"),
  u64("totalPnlPc"),
  u64("totalPnlCoin"),
  u128("poolTotalDepositPc"),
  u128("poolTotalDepositCoin"),
  u128("swapCoinInAmount"),
  u128("swapPcOutAmount"),
  u128("swapPcInAmount"),
  u128("swapCoinOutAmount"),
  u64("swapPcFee"),
  u64("swapCoinFee"),

  publicKey("poolCoinTokenAccount"),
  publicKey("poolPcTokenAccount"),
  publicKey("coinMintAddress"),
  publicKey("pcMintAddress"),
  publicKey("lpMintAddress"),
  publicKey("ammOpenOrders"),
  publicKey("serumMarket"),
  publicKey("serumProgramId"),
  publicKey("ammTargetOrders"),
  publicKey("poolWithdrawQueue"),
  publicKey("poolTempLpTokenAccount"),
  publicKey("ammOwner"),
  publicKey("pnlOwner"),

  u128("currentK"),
  u128("padding1"),
  publicKey("padding2")
]);

export async function getLpMintListDecimals(
  conn: any,
  mintAddressInfos: string[]
): Promise<{ [name: string]: number }> {
  const reLpInfoDict: { [name: string]: number } = {};
  const mintList = [] as PublicKey[];
  mintAddressInfos.forEach(item => {
    let lpInfo = Object.values(LP_TOKENS).find(
      itemLpToken => itemLpToken.mintAddress === item
    );
    if (!lpInfo) {
      mintList.push(new PublicKey(item));
      lpInfo = {
        decimals: null
      };
    }
    reLpInfoDict[item] = lpInfo.decimals;
  });
  const mintAll = await getMultipleAccounts(conn, mintList, commitment);
  for (let mintIndex = 0; mintIndex < mintAll.length; mintIndex += 1) {
    const itemMint = mintAll[mintIndex];
    if (itemMint) {
      const mintLayoutData = MINT_LAYOUT.decode(
        Buffer.from(itemMint.account.data)
      );
      reLpInfoDict[mintList[mintIndex].toString()] = mintLayoutData.decimals;
    }
  }
  const reInfo: { [name: string]: number } = {};
  for (const key of Object.keys(reLpInfoDict)) {
    if (reLpInfoDict[key] !== null) {
      reInfo[key] = reLpInfoDict[key];
    }
  }
  return reInfo;
}
```

更新 `utils/pools.ts` 檔。

```TS
import { cloneDeep } from "lodash-es";

// @ts-ignore
import SERUM_MARKETS from "@project-serum/serum/lib/markets.json";

import {
  LIQUIDITY_POOL_PROGRAM_ID_V2,
  LIQUIDITY_POOL_PROGRAM_ID_V3,
  LIQUIDITY_POOL_PROGRAM_ID_V4,
  SERUM_PROGRAM_ID_V2,
  SERUM_PROGRAM_ID_V3
} from "./ids";
// import { LP_TOKENS, NATIVE_SOL, TokenInfo, TOKENS } from "./tokens";
import { LP_TOKENS, NATIVE_SOL, TOKENS } from "./tokens";

/**
 * Get pool use two mint addresses

 * @param {string} coinMintAddress
 * @param {string} pcMintAddress

 * @returns {LiquidityPoolInfo | undefined} poolInfo
 */
export function getPoolByTokenMintAddresses(
  coinMintAddress: string,
  pcMintAddress: string
): LiquidityPoolInfo | undefined {
  const pool = LIQUIDITY_POOLS.find(
    pool =>
      ((pool.coin.mintAddress === coinMintAddress &&
        pool.pc.mintAddress === pcMintAddress) ||
        (pool.coin.mintAddress === pcMintAddress &&
          pool.pc.mintAddress === coinMintAddress)) &&
      [4, 5].includes(pool.version)
  );

  if (pool) {
    return cloneDeep(pool);
  }

  return pool;
}

export function getLpMintByTokenMintAddresses(
  coinMintAddress: string,
  pcMintAddress: string,
  version = [3, 4, 5]
): string | null {
  const pool = LIQUIDITY_POOLS.find(
    pool =>
      ((pool.coin.mintAddress === coinMintAddress &&
        pool.pc.mintAddress === pcMintAddress) ||
        (pool.coin.mintAddress === pcMintAddress &&
          pool.pc.mintAddress === coinMintAddress)) &&
      version.includes(pool.version)
  );

  if (pool) {
    return pool.lp.mintAddress;
  }

  return null;
}

export function getLpListByTokenMintAddresses(
  coinMintAddress: string,
  pcMintAddress: string,
  ammIdOrMarket: string | undefined,
  version = [4, 5]
): LiquidityPoolInfo[] {
  const pool = LIQUIDITY_POOLS.filter(pool => {
    if (coinMintAddress && pcMintAddress) {
      if (
        ((pool.coin.mintAddress === coinMintAddress &&
          pool.pc.mintAddress === pcMintAddress) ||
          (pool.coin.mintAddress === pcMintAddress &&
            pool.pc.mintAddress === coinMintAddress)) &&
        version.includes(pool.version) &&
        pool.official
      ) {
        return !(
          ammIdOrMarket !== undefined &&
          pool.ammId !== ammIdOrMarket &&
          pool.serumMarket !== ammIdOrMarket
        );
      }
    } else {
      return !(
        ammIdOrMarket !== undefined &&
        pool.ammId !== ammIdOrMarket &&
        pool.serumMarket !== ammIdOrMarket
      );
    }
    return false;
  });
  if (pool.length > 0) {
    return pool;
  } else {
    return LIQUIDITY_POOLS.filter(pool => {
      if (coinMintAddress && pcMintAddress) {
        if (
          ((pool.coin.mintAddress === coinMintAddress &&
            pool.pc.mintAddress === pcMintAddress) ||
            (pool.coin.mintAddress === pcMintAddress &&
              pool.pc.mintAddress === coinMintAddress)) &&
          version.includes(pool.version)
        ) {
          return !(
            ammIdOrMarket !== undefined &&
            pool.ammId !== ammIdOrMarket &&
            pool.serumMarket !== ammIdOrMarket
          );
        }
      } else {
        return !(
          ammIdOrMarket !== undefined &&
          pool.ammId !== ammIdOrMarket &&
          pool.serumMarket !== ammIdOrMarket
        );
      }
      return false;
    });
  }
}

export function getPoolByLpMintAddress(
  lpMintAddress: string
): LiquidityPoolInfo | undefined {
  const pool = LIQUIDITY_POOLS.find(
    pool => pool.lp.mintAddress === lpMintAddress
  );

  if (pool) {
    return cloneDeep(pool);
  }

  return pool;
}

export function getAddressForWhat(address: string) {
  for (const pool of LIQUIDITY_POOLS) {
    for (const [key, value] of Object.entries(pool)) {
      if (key === "lp") {
        if (value.mintAddress === address) {
          return {
            key: "lpMintAddress",
            lpMintAddress: pool.lp.mintAddress,
            version: pool.version
          };
        }
      } else if (value === address) {
        return {
          key,
          lpMintAddress: pool.lp.mintAddress,
          version: pool.version
        };
      }
    }
  }

  return {};
}

export function isOfficalMarket(marketAddress: string) {
  for (const market of SERUM_MARKETS) {
    if (market.address === marketAddress && !market.deprecated) {
      return true;
    }
  }

  for (const pool of LIQUIDITY_POOLS) {
    if (pool.serumMarket === marketAddress && pool.official === true) {
      return true;
    }
  }

  return false;
}

export const LIQUIDITY_POOLS: LiquidityPoolInfo[] = [
  {
    name: "RAY-WUSDT",
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.WUSDT },
    lp: { ...LP_TOKENS["RAY-WUSDT"] },

    version: 2,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V2,

    ammId: "4GygMmZgSoyfM3DEBpA8HvB8pooKWnTp232bKA17ptMG",
    ammAuthority: "E8ddPSxjVUdW8wa5rs3gbscqoXQF1o7sJrkUMFU18zMS",
    ammOpenOrders: "Ht7CkowEPZ5yHQpQQhzhgnN8W7Dq3Gw96Z3Ph8f3tVpY",
    ammTargetOrders: "3FGv6AuhfsxPBsPz4dXRA629W7UF2rW3NjHaihxUNcrB",
    ammQuantities: "EwL1kwav5Z9dGrppUvusjPA4iJ4gVFsD3kGc5gCyAmMt",
    poolCoinTokenAccount: "G2zmxUhRGn12fuePJy9QsmJKem6XCRnmAEkf8G6xcRTj",
    poolPcTokenAccount: "H617sH2JNjMqPhRxsu43C8vDYfjZrFuoMEKdJyMu7V3t",
    poolWithdrawQueue: "2QiXRE5yAfTbTUT9BCfmkahmPPhsmWRox1V88iaJppEX",
    poolTempLpTokenAccount: "5ujWtJVhwzy8P3DJBYwLo4StxiFhJy5q6xHnMx7yrPPb",
    serumProgramId: SERUM_PROGRAM_ID_V2,
    serumMarket: "HZyhLoyAnfQ72irTdqPdWo2oFL9zzXaBmAqN72iF3sdX",
    serumCoinVaultAccount: "56KzKfd9LvsY4QuMZcGxcGCd78ZBFQ7JcyMFwgqpXH12",
    serumPcVaultAccount: "GLntTfM7RHeg5RuAuXcudT4NV7d4BGPrEFq7mmMxn29E",
    serumVaultSigner: "6FYUBnwRVxxYCv1kpad4FaFLJAzLYuevFWmpVp7hViTn",
    official: true
  },
  {
    name: "RAY-SOL",
    coin: { ...TOKENS.RAY },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["RAY-SOL"] },

    version: 2,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V2,

    ammId: "5Ytcen7ZQRWA8Dt4EGyVJngyqDL36ZKAGSTVKxbDGZPN",
    ammAuthority: "6LUFae1Ap44GVT9Dhw7NEqibFGSFxijdx4kzKVARsSuL",
    ammOpenOrders: "4JGNm7gSaZguaNJExYsFsL91x4GPtPyHpU7nrb5Jjygh",
    ammTargetOrders: "3rqYVkU3HkSj8XB9c2Y9e1LLPL6BjtNKr187qma6peCc",
    ammQuantities: "BMTLKbmwzsKRxzL45eKgb5or8spaStLZxvycrTGGAhdK",
    poolCoinTokenAccount: "CJukFFmH9FZ98uzFkUNgqRn8xUmSBTUETEDUMxZXk6p8",
    poolPcTokenAccount: "DoZyq9uo3W4WWBZJvPCvfB5cCBFvjU9oq3DdYjNgJNRX",
    poolWithdrawQueue: "9FY699Gpyq4CcL8KFS4rEP76dAR3GQchQnUw7Xg1yaew",
    poolTempLpTokenAccount: "A1BMmYPBXudTXzQExpqy1LrqEkKuoasfwCLjwigiSfRh",
    serumProgramId: SERUM_PROGRAM_ID_V2,
    serumMarket: "HTSoy7NCK98pYAkVV6M6n9CTziqVL6z7caS3iWFjfM4G",
    serumCoinVaultAccount: "6dDDqzNsLx8u2Prk384Rs1jUxFPFQsKHne5oQxnf4kog",
    serumPcVaultAccount: "AzxRBcig9mGTfdbUgEdKq48eiNZ2M4ynwQQH4Pvxbcy2",
    serumVaultSigner: "FhTczYTxkXMyofPMDQFJGHxjcnPrjrEGQMexob4BVwXD",
    official: true
  },
  {
    name: "LINK-WUSDT",
    coin: { ...TOKENS.LINK },
    pc: { ...TOKENS.WUSDT },
    lp: { ...LP_TOKENS["LINK-WUSDT"] },

    version: 2,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V2,

    ammId: "Avkh3hMrjRRdGbm7EAmeXaJ1wWrbcwGWDGEroKq5wHJ8",
    ammAuthority: "v1uTXS1hrW2DJkKPcQ3Dm7WwhYbGm7LhHoRE29QrHsJ",
    ammOpenOrders: "HD7VPeJL2Sgict6oBPhb2s3DXvS9uieQmuw7KzhrfD3j",
    ammTargetOrders: "DQ7un7pYeWWcBrt1mpucasb2CaepJQJ3Z3axM3PJ4pJ4",
    ammQuantities: "5KDL4Mtufuhe6Yof9nSPVjXgXgMFMHCXqKETzzbrsGzY",
    poolCoinTokenAccount: "7r5YjMLMnmoYkD1bkyYq374yiTBG9XwBHMwi5ZVDptre",
    poolPcTokenAccount: "6vMeQvJcC3VEGvtZ2TDXcShZerevxkqfW43yjX14vmSz",
    poolWithdrawQueue: "3tgn1n9wMGfryZu37skcMhUuwbNYFWTT5hurWGijikXZ",
    poolTempLpTokenAccount: "EL8G5U28xw9djiEb9AZiEtBUtUdA5YtvaAHJu5hxipCK",
    serumProgramId: SERUM_PROGRAM_ID_V2,
    serumMarket: "hBswhpNyz4m5nt4KwtCA7jYXvh7VmyZ4TuuPmpaKQb1",
    serumCoinVaultAccount: "8ZP84HpFb5k4paAgDGgXaMtne537LDFaxEWP89WKBPD1",
    serumPcVaultAccount: "E3X7J1vyogGKZSySEo3WTS9GzipyTGVd5KKiXeFy1YHu",
    serumVaultSigner: "7bwfaV98FDNtWvgPMo7wY3nE7cE8tKfXkFAVzCxtkw6w",
    official: true
  },
  {
    name: "ETH-WUSDT",
    coin: { ...TOKENS.ETH },
    pc: { ...TOKENS.WUSDT },
    lp: { ...LP_TOKENS["ETH-WUSDT"] },

    version: 2,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V2,

    ammId: "7PGNXqdhrpQoVS5uQs9gjT1zfY6MUzEeYHopRnryj7rm",
    ammAuthority: "BFCEvcoD1xY1HK4psbC5wYXVXEvmgwg4wKggk89u1NWw",
    ammOpenOrders: "3QaSNxMuA9zEXazLdD2oJq7jUCfShgtvdaepuq1uJFnS",
    ammTargetOrders: "2exvd2T7yFYhBpi67XSrCVChVwMu23g653ELEnjvv8uu",
    ammQuantities: "BtwQvRXNudUrazbJNhazajSZXEXbrf51ddBrmnje27Li",
    poolCoinTokenAccount: "Gej1jXVRMdDKWSxmEZ78KJp5jruGJfR9dV3beedXe3BG",
    poolPcTokenAccount: "FUDEbQKfMTfAaKS3dGdPEacfcC9bRpa5gmmDW8KNoUKp",
    poolWithdrawQueue: "4q3qXQsQSvzNE1fSyEh249vHGttKfQPJWM7A3AtffEX5",
    poolTempLpTokenAccount: "8i2cZ1UCAjVac6Z76GvQeRqZMKgMyuoZQeNSsjdtEgHG",
    serumProgramId: SERUM_PROGRAM_ID_V2,
    serumMarket: "5abZGhrELnUnfM9ZUnvK6XJPoBU5eShZwfFPkdhAC7o",
    serumCoinVaultAccount: "Gwna45N1JGLmUMGhFVP1ELz8szVSajp12RgPqCbk46n7",
    serumPcVaultAccount: "8uqjWjNQiZvoieaGSoCRkGZExrqMpaYJL5huknCEHBcP",
    serumVaultSigner: "4fgnxw343cfYgcNgWvan8H6j6pNBskBmGX4XMbhxtFbi",
    official: true
  },
  {
    name: "RAY-USDC",
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["RAY-USDC"] },

    version: 2,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V2,

    ammId: "G2PVNAKAp17xtruKiMwT1S2GWNxptWZfqK6oYrFWCXWX",
    ammAuthority: "2XTg6m9wpuUyPNhHbi8DCGfyo58bpqmAmbujEEpUykSo",
    ammOpenOrders: "HuGmmcqH6ULntUdfaCVrx4uzuhHME55Dczt793EweoTZ",
    ammTargetOrders: "B3UeQ7SK9U9a5vP8fDtZ5gfDv6KRFSsNtawpoH7fziNW",
    ammQuantities: "LEgCPaQhYv9YSnKXvHtc6HixwxdXe9mmvLCuTTxW2Yn",
    poolCoinTokenAccount: "CvcqJtGdS9C1jKKFzgCi5p8qsnR5BZCohWvYMBJXcnJ8",
    poolPcTokenAccount: "AiYm8jzb2WB4HTTFTHX1XCS7uVSQM5XWnMsure5sMeQY",
    poolWithdrawQueue: "rYqeTgbeQvrDxeCg4kjqHA1X6rfjjLQvQTJeYLAgXq7",
    poolTempLpTokenAccount: "4om345FvSd9dqwFpy1SVmPFY9KzeUk8WmKiMzTbQxCQf",
    serumProgramId: SERUM_PROGRAM_ID_V2,
    serumMarket: "Bgz8EEMBjejAGSn6FdtKJkSGtvg4cuJUuRwaCBp28S3U",
    serumCoinVaultAccount: "BuMsEd7Ub6MtCCh1eT8pvL6zcBPbiifa1idVWa1BeE2R",
    serumPcVaultAccount: "G7i7ZKx7rfMXGreLYzvR3ZZERgaGK7646nAgi8yjE8iN",
    serumVaultSigner: "Aj6H2siiKsnAdAS5YVwuJPdXrHaLodsSyKs7ZiEtEZQN",
    official: true
  },
  {
    name: "RAY-SRM",
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.SRM },
    lp: { ...LP_TOKENS["RAY-SRM"] },

    version: 2,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V2,

    ammId: "3Y5dpV9DtwkhewxXpiVRscFeQR2dvsHovXQonkKbuDwB",
    ammAuthority: "7iND8ysb6fGUy8tx4C8AS51wbjvRjBxxSoaaL7t1yWXX",
    ammOpenOrders: "4QXs3bK3nyauMYutJjD8qGunFphAw944SsRdSD7n8oUj",
    ammTargetOrders: "5oaHFj1aqz9xLxYwByddXiUfbSwRZ3gmSJsgBF4no7Xx",
    ammQuantities: "His9VQDWu55QdDUFu7tp5CpiCB1fMs6EDk5oC4uTaS4G",
    poolCoinTokenAccount: "5fHS778vozoDDYzzJz2xYG39whTzGGW6bF71GVxRyMXi",
    poolPcTokenAccount: "CzVe191iLM2E31DBW7isXpZBPtcufRRsaxNRc8uShcEs",
    poolWithdrawQueue: "BGmJSiCR7uuahrajWv1RgBJrbUjcQHREFfewqZPhf346",
    poolTempLpTokenAccount: "5aMZAZdab2iS62rfqPYd15AkQ7Y5zSSfz7WxHjV9ZRPw",
    serumProgramId: SERUM_PROGRAM_ID_V2,
    serumMarket: "HSGuveQDXtvYR432xjpKPgHfzWQxnb3T8FNuAAvaBbsU",
    serumCoinVaultAccount: "6wXCSGvFvWLVoiRaXJheHoXec4LiJhiCWnxmQbYc9kv5",
    serumPcVaultAccount: "G8KH5rE5EqeTpnLjTTNgKhVp47yRHCN28wH27vYFkWCR",
    serumVaultSigner: "EXZnYg9QCzujDwm621N286d4KLAZiMwpUv64GdECcxbm",
    official: true
  },
  // v3
  {
    name: "RAY-WUSDT",
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.WUSDT },
    lp: { ...LP_TOKENS["RAY-WUSDT-V3"] },

    version: 3,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V3,

    ammId: "FEAkBF4GhYKrYbxMa7tFcujvzxKrueC7xHT2NdyC9vxm",
    ammAuthority: "CgvoNxNc93c91zYkPTAkBsYxjcAn8bRsnLM5ZxNKUpDj",
    ammOpenOrders: "2nzyzD5sdDKkP5pN5V5HGDmacpQJPEkMHqA1vopuRupY",
    ammTargetOrders: "BYCxxFuPB6MjLmpBoA7XMXHKk87LP1V62HPFh5BaobBd",
    ammQuantities: "H8P2YR1MTFgcRKnGHYWk6Aitqf72aXCN3ZKM29mRQqqe",
    poolCoinTokenAccount: "DTQTBTSy3tiy7kZZWgaczWxs9snnTVTi8DBYBzjaVwbj",
    poolPcTokenAccount: "Bk2G4zhjB7VmRsaBwh2ijPwq6tavMHALEq4guogxsosT",
    poolWithdrawQueue: "9JnsD9Pm8YQhMMAKBV7RgPcdVnRTuwJW5PXdWx7T2K8C",
    poolTempLpTokenAccount: "FfNM2Szi8xKWj3SUAjYpsHKuyQsd9NuW8ARkMqyNYPiJ",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "C4z32zw9WKaGPhNuU54ohzrV4CE1Uau3cFx6T8RLjxYC",
    serumCoinVaultAccount: "6hCHQufQsxsHDkHYNmw79WvfsAGXvomdZnkzWN7MYz8f",
    serumPcVaultAccount: "7qM644QyBzMvqLLiEYhJksyPzwUpuQj44EodLb1va8aG",
    serumVaultSigner: "2hzqYES4AcwVkuMdNsNNqi1jqjfKSyL2BNus4kimVXNk",
    official: true
  },
  {
    name: "RAY-USDC",
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["RAY-USDC-V3"] },

    version: 3,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V3,

    ammId: "5NMFfbccSpLdre6anA8P8vVy35n2a52AJiNPpQn8tJnE",
    ammAuthority: "Bjhs6Mrvxr34WAKLog2tiU77VMvwNZcrJ1g8UyGoic3e",
    ammOpenOrders: "3Xq4vBd5EWs45v9YwG1Mpfr8Xjng23pDovVUbnAaPce9",
    ammTargetOrders: "7ccgnj4dTuVTaQCwbECDc3GrKrQpuGNA4cETiSNo2cCN",
    ammQuantities: "6ifgXdNx8zKd4bseuya6FEKb49VWx1dDvVTC8f7kc361",
    poolCoinTokenAccount: "DujWhSxnwqFd3TrLfScyUhJ3FdoaHrmoiVE6kU4ETQyL",
    poolPcTokenAccount: "D6F5CDaLDCHHWfE8kMLbMNAFULXLfM572AGDx2a6KeXc",
    poolWithdrawQueue: "76QQPxNT422AL8w5RhssRFQ3gUGy7Y23YxV9BRWqs44Q",
    poolTempLpTokenAccount: "2Q9PevhtVioNFyFFrbkzcGxn1QmzFph5Cpdy1FKe3nYJ",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "2xiv8A5xrJ7RnGdxXB42uFEkYHJjszEhaJyKKt4WaLep",
    serumCoinVaultAccount: "GGcdamvNDYFhAXr93DWyJ8QmwawUHLCyRqWL3KngtLRa",
    serumPcVaultAccount: "22jHt5WmosAykp3LPGSAKgY45p7VGh4DFWSwp21SWBVe",
    serumVaultSigner: "FmhXe9uG6zun49p222xt3nG1rBAkWvzVz7dxERQ6ouGw",
    official: true
  },
  {
    name: "RAY-SRM",
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.SRM },
    lp: { ...LP_TOKENS["RAY-SRM-V3"] },

    version: 3,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V3,

    ammId: "EGhB6FdyHtJPbPMRoBC8eeUVnVh2iRgnQ9HZBKAw46Uy",
    ammAuthority: "3gSVizZA2BFsWAfW4j1wBSQiQE9Xn3Ds518jPGve31se",
    ammOpenOrders: "6CVRtzecMaPZ1pdfT2ZzJ1qf89yuFsD7MKYGwvjYsy6w",
    ammTargetOrders: "CZYbET8zweaWtWLnFJnt5nouCE9snQxFi7zrTCGYycL1",
    ammQuantities: "3NGwJe5bueAgLp6fMrY5HV2rpHF9xh3HhH97S6LrMLPo",
    poolCoinTokenAccount: "Eg6sR9H28cFaek5DVdgxxDcRKKbS85XvCFEzzkdmYNhq",
    poolPcTokenAccount: "8g2nHtayS2JnRxaAY5ugsYC8CwiZutQrNWA9j2oH8UVM",
    poolWithdrawQueue: "7Yc1P9nyev1uoLtLJu15o5vQugvfXoHcde6x2mm1HeED",
    poolTempLpTokenAccount: "5WHmdyH7CgiezSGcD9PVMYth9hMEWETV1M64zmZ9UT5o",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "Cm4MmknScg7qbKqytb1mM92xgDxv3TNXos4tKbBqTDy7",
    serumCoinVaultAccount: "5QDTh4Bpz4wruWMfayMSjUxRgDvMzvS2ifkarhYtjS1B",
    serumPcVaultAccount: "76CofnHCvo5wEKtxNWfLa2jLDz4quwwSHFMne6BWWqx",
    serumVaultSigner: "AorjCaSV1L6NGcaFZXEyUrmbSqY3GdB3YXbQnrh85v6F",
    official: true
  },
  {
    name: "RAY-SOL",
    coin: { ...TOKENS.RAY },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["RAY-SOL-V3"] },

    version: 3,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V3,

    ammId: "HeRUVkQyPuJAPFXUkTaJaWzimBopWbJ54q5DCMuPpBY4",
    ammAuthority: "63Cw8omVwSQGDPP5nff3a9DakvL8ruaqqEpbQ4uDwPYf",
    ammOpenOrders: "JQEY8R9frhxuvcsewGfgkCVdGWztpHLx4P9zmTAsZFM",
    ammTargetOrders: "7mdd7oqHqULV1Yxaaf5GW52FKFbJz78sZj9ePcfmL5Fi",
    ammQuantities: "HHU2THd3tocaYagZh826KCvLDv7QNWLGKjaJKmtdtTQM",
    poolCoinTokenAccount: "Fy6SnHwAkxoGMhUH2cLu2biqAnHmaAwFDDww9k6gq5ws",
    poolPcTokenAccount: "GoRindEPofTJ3axsonTnbyf7cFwdFdG1A3MG9ENyBZsn",
    poolWithdrawQueue: "3bUwc23vXP9L6XBjVCvG9Mruuu7GRkcfmyXuaH6HdmW2",
    poolTempLpTokenAccount: "9dALTRnKoLmfMn3hPyQoizmSJ5CZSLMLdJy1XMocwXMU",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "C6tp2RVZnxBPFbnAsfTjis8BN9tycESAT4SgDQgbbrsA",
    serumCoinVaultAccount: "6U6U59zmFWrPSzm9sLX7kVkaK78Kz7XJYkrhP1DjF3uF",
    serumPcVaultAccount: "4YEx21yeUAZxUL9Fs7YU9Gm3u45GWoPFs8vcJiHga2eQ",
    serumVaultSigner: "7SdieGqwPJo5rMmSQM9JmntSEMoimM4dQn7NkGbNFcrd",
    official: true
  },
  {
    name: "RAY-ETH",
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.ETH },
    lp: { ...LP_TOKENS["RAY-ETH-V3"] },

    version: 3,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V3,

    ammId: "FrDSSYXGcrJc7ZwY5KMfTmzDfrzjvqdxmSinJFwxLr14",
    ammAuthority: "5Wbe7MYpw8y9iroZKVN8b3fLZNeBUbRKetQwULicDpw2",
    ammOpenOrders: "ugyjEMZLumc1M5c7MNXayMYmxpnuMRYiT4aPwfNb6bq",
    ammTargetOrders: "2M6cT1GvGTiovTj7bRsZBeLMeJzjYoDTHNiTRVJqRFeM",
    ammQuantities: "5YcH7AwHNLdDJd2K6YmZAxqqvGYjgE59NaYAh3pkgVd7",
    poolCoinTokenAccount: "ENjXaFNDiLTh44Gs89ZtfUH2i5MGLLkfYbSY7TmP4Du3",
    poolPcTokenAccount: "9uzWJD2WqJYSmB6UHSyPMskFGoP5L6hB7FxqUdYP4Esm",
    poolWithdrawQueue: "BkrxkmYs1JViXbiBJfnwgns75CJd9yHcqUkFXB8Bz7oB",
    poolTempLpTokenAccount: "CKZ7NMunTef18yKHuizRoNZedzTdDEFwYRUgB3dFDcrd",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "6jx6aoNFbmorwyncVP5V5ESKfuFc9oUYebob1iF6tgN4",
    serumCoinVaultAccount: "EVVtYo4AeCbmn2dYS1UnhtfjpzCXCcN26G1HmuHwMo7w",
    serumPcVaultAccount: "6ZT6KwvjLnJLpFdVfiRD9ifVUo4gv4MUie7VvPTuk69v",
    serumVaultSigner: "HXbRDLcX2FyqWJY95apnsTgBoRHyp7SWYXcMYod6EBrQ",
    official: true
  },
  // v4
  {
    name: "FIDA-RAY",
    coin: { ...TOKENS.FIDA },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["FIDA-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "2dRNngAm729NzLbb1pzgHtfHvPqR4XHFmFyYK78EfEeX",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "DUVSNpoCNyGDP9ef9gJC5Dg53khxTyM1pQrKVetmaW8R",
    ammTargetOrders: "89HcsFvCQaUdorVF712EhNhecvVM7Dk6XAdPbaykB3q2",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "6YeEo7ZTRHotXd89JTBJKRXERBjv3N3ofgsgJ4FoAa39",
    poolPcTokenAccount: "DDNURcWy3CU3CpkCnDoGXwQAeCg1mp2CC8WqvwHp5Fdt",
    poolWithdrawQueue: "H8gZ2f4hp6LfaszDN5uHAeDwZ1qJ4M4s2A59i7nMFFkN",
    poolTempLpTokenAccount: "Bp7LNZH44vecbv69kY35bjmsTjboGbEKy62p7iRT8az",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "9wH4Krv8Vim3op3JAu5NGZQdGxU8HLGAHZh3K77CemxC",
    serumBids: "E2FEkqPVcQZgRaE7KabcHGbpNkpycnvVZMan2MPNGKeM",
    serumAsks: "5TXqn1N2kpCWWV4AcXtFYJw8WqLrXP62qenxiSfhxJiD",
    serumEventQueue: "58qMcacA2Qk4Tc4Rut3Lnao91JvvWJJ26f5kojKnMRen",
    serumCoinVaultAccount: "A2SMhqA1kMTudVeAeWdzCaYYeG6Dts19iEZd4ZQQAcUm",
    serumPcVaultAccount: "GhpccNwfein8qP6uhWnP4vuRva1iLivuQQHUTM7tW58r",
    serumVaultSigner: "F7VdEoWQGmdFK35SD21wAbDWtnkVpcrxM3DPVnmG8Q3i",
    official: true
  },
  {
    name: "OXY-RAY",
    coin: { ...TOKENS.OXY },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["OXY-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "B5ZguAWAGC3GXVtJZVfoMtzvEvDnDKBPCevsUKMy4DTZ",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "FVb13WU1W1vFouhRXZWVZWGkQdK5jo35EnaCrMzFqzyd",
    ammTargetOrders: "FYPP5v8SLHPPcivgBJPE9FgrN6o2QVMB627n3XcZ8rCS",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "6ttf7G7FR9GWqxiyCLFNaBTvwYzTLPdbbrNcRvShaqtS",
    poolPcTokenAccount: "8orrvb6rHB776KbQmszcxPH44cZHdCTYC1fr2a3oHufC",
    poolWithdrawQueue: "4Q9bNJsWreAGhkwhKYL7ApyhEBuwNxiPkcEQNmUjQGHZ",
    poolTempLpTokenAccount: "E12sRQvEHArCULaJu8xppoJKQgJsuDuwPVJZJRrUKYFu",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HcVjkXmvA1815Es3pSiibsRaFw8r9Gy7BhyzZX83Zhjx",
    serumBids: "DaGRz2TAdcVcPwPmYF5JJ7d7kPWvLN68vuBTTMwnoM3T",
    serumAsks: "3ZRtPBQVcjCpVmCt4xPPeJJiUnDDbrc5jommVHGsDLnT",
    serumEventQueue: "C5SGEXUCmN1LxmxapPn2XaHX1FF7fAuQG5Wu4yuu8VK6",
    serumCoinVaultAccount: "FcDWM8eKUEny2wxopDMrZqgmPr3Tmoen9Dckh3MoVX9N",
    serumPcVaultAccount: "9ya4Hv4XdzntjiLwxpgqnX8eP4MtFf8YWEssF6C5Pqhq",
    serumVaultSigner: "Bf9MhS6hwAGSWVJ4uLWKSU6fqPAEroRsHX6ithEjGXiG",
    official: true
  },
  {
    name: "MAPS-RAY",
    coin: { ...TOKENS.MAPS },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["MAPS-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "5VyLSjUvaRxsubirbvbfJMbrKZRx1b7JZzuCAfyqgimf",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "HViBtwESRNKLZY7qLQxP68b5vLdUQa1XMAKz19LbSHjx",
    ammTargetOrders: "8Cwm1Z75hQdUpFUxCuoWmWBLcAaZvKMAn2xKeuotC4eC",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "6rYv6kLfhAVKZw1xN2S9NWNgp8EfUVvYKi1Hgzd5x9XE",
    poolPcTokenAccount: "8HfvN4VyAQjX6MhziRxMg5LjbMh9Fw889yf3sDgrXakw",
    poolWithdrawQueue: "HnzkiYgZg22ZaQGdeTHiCgJaoW138CLqCb8tr6QJFkU4",
    poolTempLpTokenAccount: "DnTQwA9PdwLSibsiQFZ35yJJDNJfG9fNbHspPmb8v8TQ",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "7Q4hee42y8ZGguqKmwLhpFNqVTjeVNNBqhx8nt32VF85",
    serumBids: "J9ZmfF71eMMzisvaYW12EK87UaopZ4hgND2nr61YwmKw",
    serumAsks: "9ah4Mewrh841gmfaX1v1wCByHU3rbCuUmWUgt2TBAfnb",
    serumEventQueue: "EtimVRtnRUAfv9tXVAHpGCGvtYezcpmzbkwZLuwWAYqe",
    serumCoinVaultAccount: "2zriJ5sVApLD9TC9PxbXK41AkVCQBaRreeXtGx7AGE41",
    serumPcVaultAccount: "2qAKnjzokKR4sL6Xtp1nZYKXTmsraXW9CL3HuBZx3qpA",
    serumVaultSigner: "CH76NgZMpUJ8QQqVNpjyCSpQmZBNZLXW6a5vDHj3aUUC",
    official: true
  },
  {
    name: "KIN-RAY",
    coin: { ...TOKENS.KIN },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["KIN-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "6kmMMacvoCKBkBrqssLEdFuEZu2wqtLdNQxh9VjtzfwT",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "DiP4F6FTR5jiTar8fwuwRVuYop5wYRqy2EjbiKTXPrHw",
    ammTargetOrders: "2ak4VVyS19sVESvvBuPZRMAhvY4vVCZCxeELYAybA7wk",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "s7LP6qptF1wufA9neYhekmVPqhav8Ak85AV5ip5h8wK",
    poolPcTokenAccount: "9Q1Xs1s8tCirX3Ky3qo9UjvSqSoGinZvWaUMFXY5r2HF",
    poolWithdrawQueue: "DeHaCJ8KL5uwBGenkUwa39JyhacxPDqDqHAp5HLqgd1i",
    poolTempLpTokenAccount: "T2acWsGDQ4ZRXs4WXVi7vCeH4TxzgjcL6s14xFNuT26",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "Fcxy8qYgs8MZqiLx2pijjay6LHsSUqXW47pwMGysa3i9",
    serumBids: "HKWdSptDBeXTURKpQQ2AGPmT2B9LGNBVteq44UzDxKBh",
    serumAsks: "2ceQrRfuNWL8kR2fockPo7C31uDeTyXTs4EyA28FD2kg",
    serumEventQueue: "GwnDyxFnHSnzDdu8dom3vydtTpSu443oZPKepXww5zNB",
    serumCoinVaultAccount: "2sCJ5YZtwEbpXiw7HSXVx8Qot8hwyCpXNEkswZCssi2J",
    serumPcVaultAccount: "H6B59E77WZt4JLfaXdZQBKdATRcWaKy5N6Ki1ZRo1Mcv",
    serumVaultSigner: "5V7FCcvmGtqkMJXHiTSeo61MS5LSMUFK1Esr5kn46cEv",
    official: true
  },
  {
    name: "RAY-USDT",
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["RAY-USDT-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "DVa7Qmb5ct9RCpaU7UTpSaf3GVMYz17vNVU67XpdCRut",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "7UF3m8hDGZ6bNnHzaT2YHrhp7A7n9qFfBj6QEpHPv5S8",
    ammTargetOrders: "3K2uLkKwVVPvZuMhcQAPLF8hw95somMeNwJS7vgWYrsJ",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "3wqhzSB9avepM9xMteiZnbJw75zmTBDVmPFLTQAGcSMN",
    poolPcTokenAccount: "5GtSbKJEPaoumrDzNj4kGkgZtfDyUceKaHrPziazALC1",
    poolWithdrawQueue: "8VuvrSWfQP8vdbuMAP9AkfgLxU9hbRR6BmTJ8Gfas9aK",
    poolTempLpTokenAccount: "FBzqDD1cBgkZ1h6tiZNFpkh4sZyg6AG8K5P9DSuJoS5F",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "teE55QrL4a4QSfydR9dnHF97jgCfptpuigbb53Lo95g",
    serumBids: "AvKStCiY8LTp3oDFrMkiHHxxhxk4sQUWnGVcetm4kRpy",
    serumAsks: "Hj9kckvMX96mQokfMBzNCYEYMLEBYKQ9WwSc1GxasW11",
    serumEventQueue: "58KcficuUqPDcMittSddhT8LzsPJoH46YP4uURoMo5EB",
    serumCoinVaultAccount: "2kVNVEgHicvfwiyhT2T51YiQGMPFWLMSp8qXc1hHzkpU",
    serumPcVaultAccount: "5AXZV7XfR7Ctr6yjQ9m9dbgycKeUXWnWqHwBTZT6mqC7",
    serumVaultSigner: "HzWpBN6ucpsA9wcfmhLAFYqEUmHjE9n2cGHwunG5avpL",
    official: true
  },
  {
    name: "SOL-USDC",
    coin: { ...NATIVE_SOL },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["SOL-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "58oQChx4yWmvKdwLLZzBi4ChoCc2fqCUWBkwMihLYQo2",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "HRk9CMrpq7Jn9sh7mzxE8CChHG8dneX9p475QKz4Fsfc",
    ammTargetOrders: "CZza3Ej4Mc58MnxWA385itCC9jCo3L1D7zc3LKy1bZMR",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "DQyrAcCrDXQ7NeoqGgDCZwBvWDcYmFCjSb9JtteuvPpz",
    poolPcTokenAccount: "HLmqeL62xR1QoZ1HKKbXRrdN1p3phKpxRMb2VVopvBBz",
    poolWithdrawQueue: "G7xeGGLevkRwB5f44QNgQtrPKBdMfkT6ZZwpS9xcC97n",
    poolTempLpTokenAccount: "Awpt6N7ZYPBa4vG4BQNFhFxDj4sxExAA9rpBAoBw2uok",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "9wFFyRfZBsuAha4YcuxcXLKwMxJR43S7fPfQLusDBzvT",
    serumBids: "14ivtgssEBoBjuZJtSAPKYgpUK7DmnSwuPMqJoVTSgKJ",
    serumAsks: "CEQdAFKdycHugujQg9k2wbmxjcpdYZyVLfV9WerTnafJ",
    serumEventQueue: "5KKsLVU6TcbVDK4BS6K1DGDxnh4Q9xjYJ8XaDCG5t8ht",
    serumCoinVaultAccount: "36c6YqAwyGKQG66XEp2dJc5JqjaBNv7sVghEtJv4c7u6",
    serumPcVaultAccount: "8CFo8bL8mZQK8abbFyypFMwEDd8tVJjHTTojMLgQTUSZ",
    serumVaultSigner: "F8Vyqk3unwxkXukZFQeYyGmFfTG3CAX4v24iyrjEYBJV",
    official: true
  },
  {
    name: "YFI-USDC",
    coin: { ...TOKENS.YFI },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["YFI-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "83xxjVczDseaCzd7D61BRo7LcP7cMXut5n7thhB4rL4d",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "DdBAps8e64hpjdWqAAHTThcVFz8mQ6WU2h6s1Kjgb9vk",
    ammTargetOrders: "8BFicQN1AKaVbf1KNoUieULun1bvpdMxsyjrgC15acM6",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "HhhqmQvx2GMQ6SRQh6nZ1A4C5KjCFLQ6yga1ZXDzRJ92",
    poolPcTokenAccount: "4J4Y6qkF9yzxz1EsZYTSqviMz3Lo1VHx9ViCUoJph167",
    poolWithdrawQueue: "FPkMHzDo46vzy1eW9FuQFz7TdAp1MNCkZFgKxrHiuh3W",
    poolTempLpTokenAccount: "DuTzisr6Z2D37yTyY9E4jPMCxhQk3HCNxaL1zKqvwRjR",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "7qcCo8jqepnjjvB5swP4Afsr3keVBs6gNpBTNubd1Kr2",
    serumBids: "8L8kU4H9Ah3fgbczYKFU9WUR1HgAghso1kKwWAPrmLfS",
    serumAsks: "4M9kDzMGsNHT3k31i54wf2ceeApvx3224pLbhDvnoj2s",
    serumEventQueue: "6wKPYgydqNrmcXwbfPeNwkzXmjKMgkUhQcGoGYrm9fS4",
    serumCoinVaultAccount: "2N59Aig7wqhfffAUjMit7T9tk4FmSRzmByMD7mncTesq",
    serumPcVaultAccount: "FcDTYePeh2KJts4nroCghgceiJmSBRgq2Xd3PfpernZm",
    serumVaultSigner: "HDdQQNNf9EoCGWhWUgkQHRJVbG3huDXs2z6Fcow3grCr",
    official: true
  },
  {
    name: "SRM-USDC",
    coin: { ...TOKENS.SRM },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["SRM-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "8tzS7SkUZyHPQY7gLqsMCXZ5EDCgjESUHcB17tiR1h3Z",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "GJwrRrNeeQKY2eGzuXGc3KBrBftYbidCYhmA6AZj2Zur",
    ammTargetOrders: "26LLpo8rscCpMxyAnJsqhqESPnzjMGiFdmXA4eF2Jrk5",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "zuLDJ5SEe76L3bpFp2Sm9qTTe5vpJL3gdQFT5At5xXG",
    poolPcTokenAccount: "4usvfgPDwXBX2ySX11ubTvJ3pvJHbGEW2ytpDGCSv5cw",
    poolWithdrawQueue: "7c1VbXTB7Xqx5eQQeUxAu5o6GHPq3P1ByhDsnRRUWYxB",
    poolTempLpTokenAccount: "2sozAi6zXDUCCkpgG3usphzeCDm4e2jTFngbm5atSdC9",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "ByRys5tuUWDgL73G8JBAEfkdFf8JWBzPBDHsBVQ5vbQA",
    serumBids: "AuL9JzRJ55MdqzubK4EutJgAumtkuFcRVuPUvTX39pN8",
    serumAsks: "8Lx9U9wdE3afdqih1mCAXy3unJDfzSaXFqAvoLMjhwoD",
    serumEventQueue: "6o44a9xdzKKDNY7Ff2Qb129mktWbsCT4vKJcg2uk41uy",
    serumCoinVaultAccount: "Ecfy8et9Mft9Dkavnuh4mzHMa2KWYUbBTA5oDZNoWu84",
    serumPcVaultAccount: "hUgoKy5wjeFbZrXDW4ecr42T4F5Z1Tos31g68s5EHbP",
    serumVaultSigner: "GVV4ZT9pccwy9d17STafFDuiSqFbXuRTdvKQ1zJX6ttX",
    official: true
  },
  {
    name: "FTT-USDC",
    coin: { ...TOKENS.FTT },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["FTT-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "4C2Mz1bVqe42QDDTyJ4HFCFFGsH5YDzo91Cen5w5NGun",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "23WS5XY3srvBtnP6hXK64HAsXTuj1kT7dd7srjrJUNTR",
    ammTargetOrders: "CYbPm6BCkMyX8NnnS7AoCUkpxHVwYyxvjQWwZLsrFcLR",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "4TaBaR1ZgHNuQM3QNHnjJdAT4Sws9cz46MtVWVebg7Ax",
    poolPcTokenAccount: "7eDiHvsfcZf1VFC2sUDJwr5EMMr66TpQ2nmAreUjoASV",
    poolWithdrawQueue: "36Aa83kffwBuEP7AqNU1w5c9oB9kLxmR4FMfadXfjNbJ",
    poolTempLpTokenAccount: "8hdJm5bvgXVtb5LA18QgGeKxnXBcp3cYKwRz8vb3fV44",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "2Pbh1CvRVku1TgewMfycemghf6sU9EyuFDcNXqvRmSxc",
    serumBids: "9HTDV2r7cQBUKL3fgcJZCUfmJsKA9qCP7nZAXyoyaQou",
    serumAsks: "EpnUJCMCQNZi45nCBoNs6Bugy67Kj3bCSTLYPfz6jkYH",
    serumEventQueue: "2XHxua6ZaPKpCGUNvSvTwc9teJBmexp8iMWCLu4mtzGb",
    serumCoinVaultAccount: "4LXjM6rptNvhBZTcWk4AL49oF4oA8AH7D4CV6z7tmpX3",
    serumPcVaultAccount: "2ycZAqQ3YNPfBZnKTbz2FqPiV7fmTQpzF95vjMUekP5z",
    serumVaultSigner: "B5b9ddFHrjndUieLAKkyzB1xmq8sNqGGZPmbyYWPzCyu",
    official: true
  },
  {
    name: "BTC-USDC",
    coin: { ...TOKENS.BTC },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["BTC-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "6kbC5epG18DF2DwPEW34tBy5pGFS7pEGALR3v5MGxgc5",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "L6A7qW935i2HgaiaRx6xNGCGQfFr4myFU51dUSnCshd",
    ammTargetOrders: "6DGjaczWfFthTYW7oBk3MXP2mMwrYq86PA3ki5YF6hLg",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "HWTaEDR6BpWjmyeUyfGZjeppLnH7s8o225Saar7FYDt5",
    poolPcTokenAccount: "7iGcnvoLAxthsXY3AFSgkTDoqnLiuti5fyPNm2VwZ3Wz",
    poolWithdrawQueue: "8g6jrVU7E7eghT3FQa7uPbwHUHwHHLVCEjBh94pA1NVk",
    poolTempLpTokenAccount: "2Nhg2RBqHBx7R74VSEAbfSF8Kmi1x3HxyzCu3oFgpRJJ",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "A8YFbxQYFVqKZaoYJLLUVcQiWP7G2MeEgW5wsAQgMvFw",
    serumBids: "6wLt7CX1zZdFpa6uGJJpZfzWvG6W9rxXjquJDYiFwf9K",
    serumAsks: "6EyVXMMA58Nf6MScqeLpw1jS12RCpry23u9VMfy8b65Y",
    serumEventQueue: "6NQqaa48SnBBJZt9HyVPngcZFW81JfDv9EjRX2M4WkbP",
    serumCoinVaultAccount: "GZ1YSupuUq9kB28kX9t1j9qCpN67AMMwn4Q72BzeSpfR",
    serumPcVaultAccount: "7sP9fug8rqZFLbXoEj8DETF81KasaRA1fr6jQb6ScKc5",
    serumVaultSigner: "GBWgHXLf1fX4J1p5fAkQoEbnjpgjxUtr4mrVgtj9wW8a",
    official: true
  },
  {
    name: "SUSHI-USDC",
    coin: { ...TOKENS.SUSHI },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["SUSHI-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "5dHEPTgvscKkAc54R77xUeGdgShdG9Mf6gJ9bwBqyb3V",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "7a8WXaxsvDV9CjSxgSpJG8LZgdxmSps1ehvtgQj2qt4j",
    ammTargetOrders: "9f5b3uy3hQutS6pka2GxcSoKjvKaTcB1ivkj1GK43UAV",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "B8vMKgzKHkapzdDu1jW76ALFvVYzHGGKhR5Afz3A4mZd",
    poolPcTokenAccount: "Hsxi4jvmszcMaWfU3tk98fQa9pVXtRktfKvKJ7rKBQYi",
    poolWithdrawQueue: "AgEspvUPUuaTqyJTjZMCAW3zTuxQBSaU17GhLJoc6Jad",
    poolTempLpTokenAccount: "BHLDqVcYUrAwv8RvDUQ76BQDQzvb2yftFN8UccpA2stx",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "A1Q9iJDVVS8Wsswr9ajeZugmj64bQVCYLZQLra2TMBMo",
    serumBids: "J8JVRuBojWcHFRGosQKRdDtzxwux8fy2dwfk42Z3dCaf",
    serumAsks: "6DScSyKZKBi9cXhD3mRkTkpsxrhw6HABFxebsteCP1zU",
    serumEventQueue: "Hvpz2Cv2LgWUfTtdfjpnefYrjQuaw8gGjKoDAeGxzrwE",
    serumCoinVaultAccount: "BJfPQ2iKTJknyWo2wtCVEpRGWVt8sgpvmSQVNwLioQrk",
    serumPcVaultAccount: "2UN8qfXzoUDAxZMX1KqKut93frkt5hFREL8xcw6Hgtsg",
    serumVaultSigner: "uWhVkK44yR6V5XywVom4oWzDQACSPYHhNjkwXprtUij",
    official: true
  },
  {
    name: "TOMO-USDC",
    coin: { ...TOKENS.TOMO },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["TOMO-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "8mBJC9qdPNDyrpAbrdwGbBpEAjPqwtvZQVmbnKFXXY2P",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "H11WJQWj51KyYU5gdrnsXvpaYZM6ZLGULV93VbTmvaBL",
    ammTargetOrders: "5E9x2QRpTM2oTtwb62C4rDYR8nJZxN8NFhAtnr2uYFKt",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "5swtuQhJQFid8uMd3DsegoxFKXVS8WoiiB3t9Pos9UHj",
    poolPcTokenAccount: "Eqbux46eaW4aZiuy6VUX6z7MJ2TsszeSA7TPnpdw3jVf",
    poolWithdrawQueue: "Hwtv6M9iTJc8SH49WjQx5rbRwzAryGm8f1NSQDmnY2iq",
    poolTempLpTokenAccount: "7YXJQ4rM59A69ow3M21MKbWEEKHbNeZQ1XFESVnbwEPx",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "8BdpjpSD5n3nk8DQLqPUyTZvVqFu6kcff5bzUX5dqDpy",
    serumBids: "DriSFYDLxWCEHcnFVaxKu2NrsWGB2htWhD1wkp39qxwU",
    serumAsks: "jd3YYp9WqjzyPxhBvj4ixa4DY3bCG1b74VquM4oCUbH",
    serumEventQueue: "J82jqHzNAzVYs9ZV3zuRgzRKuu1nGDFMrzJwdxvipjXk",
    serumCoinVaultAccount: "9tQtmWT3LCbVEoHFK5WK93wmDXv4us5s7NRYhficg9ih",
    serumPcVaultAccount: "HRFqUnxuegNbAf2auxqRwECyDijkVGDw25BCJkf5ohM5",
    serumVaultSigner: "7i7rf8LANeECyi8TAwwLTyvfiVUo4x12iJtKeeA6eG53",
    official: true
  },
  {
    name: "LINK-USDC",
    coin: { ...TOKENS.LINK },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["LINK-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "Hr8i6MAm4W5Lwb2fB2CD44A2t3Ag3gGc1rmd6amrWsWC",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "G4WdXwbczwDSs6iQmYt1F3sHDhfL6aD2uBkbAoMaaTt4",
    ammTargetOrders: "Hf3g2Q63UPSLFSCKZBPJvjVVZxVr83rXm1xWR7yC6spn",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "2ueuL35kQShG1ebZz3Cov4ug9Ex6xVXx4Fc4ZKvxFqMz",
    poolPcTokenAccount: "66JxeTwodpafkYLPYYAFoVoTh6ukNYoHvtwMMSzSPBCb",
    poolWithdrawQueue: "AgVo29AiDosdiXysfwMj8bF2AyD1Nvmn971x8PLwaNAA",
    poolTempLpTokenAccount: "58EPUPaefpjDxUppc4oyDeDGc9n7sUo7vapinKXigbd",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "3hwH1txjJVS8qv588tWrjHfRxdqNjBykM1kMcit484up",
    serumBids: "GhmGNpJhGDz6zhmJ2kskmETbX9SGxhstRsmUejMXC24t",
    serumAsks: "83KiGivH1w4SiSK9YoN9WZrTSmtwveuCUd1nuZ9AFd2V",
    serumEventQueue: "9ZZ8eGhTEYK3uBNaFWSYo6ugLD6UVvudxpFXff7XSrmx",
    serumCoinVaultAccount: "9BswoEnX3SN7YUnRujZa5ygiL8AXVHXE4xqp8USX4QSY",
    serumPcVaultAccount: "9TibPFxakkdogUYizRhj9Av92fxuY2HxS3nrmme81Sma",
    serumVaultSigner: "8zqs77myZg6wkPjbh9YdSKtNmfPh4FJTzeo9R39mbjCm",
    official: true
  },
  {
    name: "ETH-USDC",
    coin: { ...TOKENS.ETH },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["ETH-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "AoPebtuJC4f2RweZSxcVCcdeTgaEXY64Uho8b5HdPxAR",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "7PwhFjfFaYp7w9N8k2do5Yz7c1G5ebp3YyJRhV4pkUJW",
    ammTargetOrders: "BV2ucC7miDqsmABSkXGzsibCVWBp7gGPcvkhevDSTyZ1",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "EHT99uYfAnVxWHPLUMJRTyhD4AyQZDDknKMEssHDtor5",
    poolPcTokenAccount: "58tgdkogRoMsrXZJubnFPsFmNp5mpByEmE1fF6FTNvDL",
    poolWithdrawQueue: "9qPsKm82ZFacGn4ipV1DH85k7efP21Zbxrxbxm5v3GPb",
    poolTempLpTokenAccount: "2WtX2ow4h5FK1vb8VjwpJ3hmwmYKfJfa1hy1rcDBohBT",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "4tSvZvnbyzHXLMTiFonMyxZoHmFqau1XArcRCVHLZ5gX",
    serumBids: "8tFaNpFPWJ8i7inhKSfAcSestudiFqJ2wHyvtTfsBZZU",
    serumAsks: "2po4TC8qiTgPsqcnbf6uMZRMVnPBzVwqqYfHP15QqREU",
    serumEventQueue: "Eac7hqpaZxiBtG4MdyKpsgzcoVN6eMe9tAbsdZRYH4us",
    serumCoinVaultAccount: "7Nw66LmJB6YzHsgEGQ8oDSSsJ4YzUkEVAvysQuQw7tC4",
    serumPcVaultAccount: "EsDTx47jjFACkBhy48Go2W7AQPk4UxtT4765f3tpK21a",
    serumVaultSigner: "C5v68qSzDdGeRcs556YoEMJNsp8JiYEiEhw2hVUR8Z8y",
    official: true
  },
  {
    name: "xCOPE-USDC",
    coin: { ...TOKENS.xCOPE },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["xCOPE-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "3mYsmBQLB8EZSjRwtWjPbbE8LiM1oCCtNZZKiVBKsePa",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "4tN7g8KbPt5bU9YDpeAsUNs2FY4G6GRvajTwCCHXt9Lk",
    ammTargetOrders: "Fe5ZjyEhnB7mCgFhRkSLWNgvtkrut4iRzk1ydfJxwA9b",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "Guw4ErphtZQRC1foic6WweDSvA9AfuqJHKDXDcbrWH4f",
    poolPcTokenAccount: "86WgydpDUFRWa9aHzd9JgcKBELPJZVrkZ3uwxiiC3w2V",
    poolWithdrawQueue: "Gvmc1zR72pdgoWSzNBqMyNoVHe78nxKgd7FSCE422Lcp",
    poolTempLpTokenAccount: "6FpDRYsKds3WkiCLjqpDzNBHWZP2Bz6CK9dZryBLKB9D",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "7MpMwArporUHEGW7quUpkPZp5L5cHPs9eKUfKCdaPHq2",
    serumBids: "5SZ6xDgLzp3QbzkqT68BBAB7orCezSsV5Gb9eAk84zdY",
    serumAsks: "Gwt93Xzp8aFrP8YFV8YSuHmYbkrGURBVVHnE6AqDT4Hp",
    serumEventQueue: "Ea4bQ4wBJ5MXAwTG1hKzEv1zry5WnGY2G58YR8hcZTk3",
    serumCoinVaultAccount: "6LtcYXZVb7zfQG33F5dCDKZ29hyQaUh6BBhWjdHp8moy",
    serumPcVaultAccount: "FCqm5xfy8ZvMxifVFfSz9Gxv1CTRABVMyLXuJrWvzAq7",
    serumVaultSigner: "XoGZnpfyqj539wneBe8xUQyD282mwy5AMUaChz12JCH",
    official: true
  },
  {
    name: "SOL-USDT",
    coin: { ...NATIVE_SOL },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["SOL-USDT-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "7XawhbbxtsRcQA8KTkHT9f9nc6d69UwqCDh6U5EEbEmX",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "4NJVwEAoudfSvU5kdxKm5DsQe4AAqG6XxpZcNdQVinS4",
    ammTargetOrders: "9x4knb3nuNAzxsV7YFuGLgnYqKArGemY54r2vFExM1dp",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "876Z9waBygfzUrwwKFfnRcc7cfY4EQf6Kz1w7GRgbVYW",
    poolPcTokenAccount: "CB86HtaqpXbNWbq67L18y5x2RhqoJ6smb7xHUcyWdQAQ",
    poolWithdrawQueue: "52AfgxYPTGruUA9XyE8eF46hdR6gMQiA6ShVoMMsC6jQ",
    poolTempLpTokenAccount: "2JKZRQc92TaH3fgTcUZyxfD7k7V7BMqhF24eussPtkwh",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HWHvQhFmJB3NUcu1aihKmrKegfVxBEHzwVX6yZCKEsi1",
    serumBids: "2juozaawVqhQHfYZ9HNcs66sPatFHSHeKG5LsTbrS2Dn",
    serumAsks: "ANXcuziKhxusxtthGxPxywY7FLRtmmCwFWDmU5eBDLdH",
    serumEventQueue: "GR363LDmwe25NZQMGtD2uvsiX66FzYByeQLcNFr596FK",
    serumCoinVaultAccount: "29cTsXahEoEBwbHwVc59jToybFpagbBMV6Lh45pWEmiK",
    serumPcVaultAccount: "EJwyNJJPbHH4pboWQf1NxegoypuY48umbfkhyfPew4E",
    serumVaultSigner: "CzZAjoEqA6sjqtaiZiPqDkmxG6UuZWxwRWCenbBMc8Xz",
    official: true
  },
  {
    name: "YFI-USDT",
    coin: { ...TOKENS.YFI },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["YFI-USDT-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "81PmLJ8j2P8CC5EJAAhWGYA4HgJvoKs4Y94ALZF2uKKG",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "pxedkTHh23HBYoarBPKML3xWh96EaNzKLW3oXvHHCw5",
    ammTargetOrders: "GUMQZC9SAqynDvoV12sRUzACF8GzLpC5fUtRuzwCbU9S",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "GwY3weBBK4dQFwC96tHAoAQq4pSfMYmMZ4m6Njqq7Wbk",
    poolPcTokenAccount: "Bs3DatsVrDujvjpV1JUVmVgNrPkaVwvp6WtuHz4z1QE6",
    poolWithdrawQueue: "2JJPww9oCvBxTdZaiB2H69Jx4dKWctCEuvbLtFfNCqHd",
    poolTempLpTokenAccount: "B46wMQncJ2Ugp2NwWDxK6Qd4Q9T24NK3naNVdyVYxbug",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "3Xg9Q4VtZhD4bVYJbTfgGWFV5zjE3U7ztSHa938zizte",
    serumBids: "7FN1TgMmjQ8iwTdmJZAiwdTM3MddvxmgiF2J4GVHUtQ1",
    serumAsks: "5nudyjGUfjwVYCk1MzzuBeXcj9k59g9mruAUXrsQfcrR",
    serumEventQueue: "4AMp4qKTwE7RwExstg7Pk4JZwJGeRMnjkFmf52tqCHJN",
    serumCoinVaultAccount: "5KgKdCWVyWi9YJ6GipzozhWxAvnbQPpUtaxuMXXEn3Zs",
    serumPcVaultAccount: "29CnTKiFKwGPFfLBXDXGRX6ywGz3ToZfqZuLkoa33dbE",
    serumVaultSigner: "6LRcCMsRoGsye95Ck5oSyNqHJW8kk2iXt9z9YQyi9JkV",
    official: true
  },
  {
    name: "SRM-USDT",
    coin: { ...TOKENS.SRM },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["SRM-USDT-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "af8HJg2ffWoKJ6vKvkWJUJ9iWbRR83WgXs8HPs26WGr",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "8E2GLzSgLmzWdpdXjjEaHbPXRXsA5CFehg6FP6N39q2e",
    ammTargetOrders: "8R5TVxXvRfCaYvT493FWAJyLt8rVssUHYVGbGupAbYaQ",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "D6b4Loa4LoidUor2ffouE5BTMt6tLP6MtkNrsfBWG2C3",
    poolPcTokenAccount: "4gNeJniq6yqEygFmbAJa82TQjH1j3Fczm4bdeBHhwGJ1",
    poolWithdrawQueue: "D3JQytXAydpHKUPChDe8JXdmvYRRV4EpnrxsqzMHNjFp",
    poolTempLpTokenAccount: "2dYW9SoJb51YNneQG7AywSB75jmzZa2R8rzzW7gT61h1",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "AtNnsY1AyRERWJ8xCskfz38YdvruWVJQUVXgScC1iPb",
    serumBids: "EE2CYFBSoMvcUR9mkEF6tt8kBFhW9zcuFmYqRM9GmqYb",
    serumAsks: "nkNzrV3ZtkWCft6ykeNGXXCbNSemqcauYKiZdf5JcKQ",
    serumEventQueue: "2i34Kriz23ZaQaJK6FVhzkfLhQj8DSqdQTmMwz4FF9Cf",
    serumCoinVaultAccount: "GxPFMyeb7BUnu2mtGV2Zvorjwt8gxHqwL3r2kVDe6rZ8",
    serumPcVaultAccount: "149gvUQZeip4u8bGra5yyN11btUDahDVHrixzknfKFrL",
    serumVaultSigner: "4yWr7H2p8rt11QnXb2yxQF3zxSdcToReu5qSndWFEJw",
    official: true
  },
  {
    name: "FTT-USDT",
    coin: { ...TOKENS.FTT },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["FTT-USDT-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "4fgubfZVL6L8tc5x1j65S14P2Tnxr1YayKtKavQV5MBo",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "BSDKUy73wuGskKDVgzNGLL2k7hzDEwj237nZZ3Ch3bwz",
    ammTargetOrders: "4j1JaKap2s4XrkJeMDaMabfEDsQm9ykeUgJ9CWa9w4JU",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "HHTXo4Q8HFWMSDKnPJWCe1Y5UmYPFNZ6hU4mc8km7Zf4",
    poolPcTokenAccount: "5rbAHV9ufT11XRR5LcvMVsuA5FcpBozLKj91z372wpZR",
    poolWithdrawQueue: "AMU4FFUUahWfaUA6WWzTWNNuiXoNDEgNNsZjFLWhvB8f",
    poolTempLpTokenAccount: "FUVUCrKB6c7x9uVn1zK8qxbVwb6rNLqA2W17TM9Bhvta",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "Hr3wzG8mZXNHV7TuL6YqtgfVUesCqMxGYCEyP3otywZE",
    serumBids: "3k5bWdYn9thQmqrye2gSobzFBYTyYosx3bKvMJRcfTTN",
    serumAsks: "DPW1r1p2uyfQxVC7vx3xVQcVvyUeiS2vhAnveQiXs9AT",
    serumEventQueue: "9zMcCfjdHH2Z7iCBtVdkmf9qXUN6y7AhbuWhRMu2DmcV",
    serumCoinVaultAccount: "H1VJqo3piiadyVAUQW6yfZq4an8pgDFvAdqHJkRXMDbq",
    serumPcVaultAccount: "9SQ4Sjsszt59X3aLwRrTqa5SLxonEdXk5jF7KUfAxc8Z",
    serumVaultSigner: "CgV9LcnAukrgDZmqhUwcNQ31z4KEjZEz4DHUSE4bRaVg",
    official: true
  },
  {
    name: "BTC-USDT",
    coin: { ...TOKENS.BTC },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["BTC-USDT-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "AMMwkf57c7ZsbbDCXvBit9zFehMr1xRn8ZzaT1iDF18o",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "G5rZ4Qfv5SxpJegVng5FuZftDrJkzLkxQUNjEXuoczX5",
    ammTargetOrders: "DMEasFJLDw27MLkTBFqSX2duvV5GV6LzwtoVqVfBqeGR",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "7KwCHoQ9nqTnGea4XrcfLUr1pwEWp2maGBHWFqBTeoKW",
    poolPcTokenAccount: "HwbXe9YJVez3BKK22jBH1i64YeX2fSKaYny5jrcPDxAk",
    poolWithdrawQueue: "3XUXNx72jcaXB3N56UjrtWwxv99ivqUwLAdkagvop4HF",
    poolTempLpTokenAccount: "8rZSQ23HWfZ1P6qd9ZL4ywTgRYtRZDd3xW3aK1hY7pkR",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "C1EuT9VokAKLiW7i2ASnZUvxDoKuKkCpDDeNxAptuNe4",
    serumBids: "2e2bd5NtEGs6pb758QHUArNxt6X9TTC5abuE1Tao6fhS",
    serumAsks: "F1tDtTDNzusig3kJwhKwGWspSu8z2nRwNXFWc6wJowjM",
    serumEventQueue: "FERWWtsZoSLcHVpfDnEBnUqHv4757kTUUZhLKBCbNfpS",
    serumCoinVaultAccount: "DSf7hGudcxhhegMpZA1UtSiW4RqKgyEex9mqQECWwRgZ",
    serumPcVaultAccount: "BD8QnhY2T96h6KwyJoCT9abMcPBkiaFuBNK9h6FUNX2M",
    serumVaultSigner: "EPzuCsSzHwhYWn2j69HQPKWuWz6wuv4ANZiVigLGMBoD",
    official: true
  },
  {
    name: "SUSHI-USDT",
    coin: { ...TOKENS.SUSHI },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["SUSHI-USDT-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "DWvhPYVogsEKEsehHApUtjhP1UFtApkAPFJqFh2HPmWz",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "ARZWhFKLtqubNWdotvqeiTTpmBw4XfrySNtY4485Zmq",
    ammTargetOrders: "J8f8p2x3wPTbpaqJydxTY5CvxtiB8HrMdW1DouaEVvRx",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "C77d7jRkxu3WyzL7K2UZZPdWXPzsFrmzLG4uHrsZhGTz",
    poolPcTokenAccount: "BtweN6cYHBntMJiRY2gGB2u4oZFsbapjLz7QJeV3KWF1",
    poolWithdrawQueue: "6WsofMBNdHWacgButviYgn8CCTGyjW19H13vYntkzBzp",
    poolTempLpTokenAccount: "CgaVy8TjkUdxFhi4h3RdszmPtf6MPUyfquqAWUwAnim7",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "6DgQRTpJTnAYBSShngAVZZDq7j9ogRN1GfSQ3cq9tubW",
    serumBids: "7U3FPNGvcDkmfnD4u5jKVd2AKwc66RFBZ8GnyjzeNfML",
    serumAsks: "3Zx74FxHwttDuYxeqHzMijitrf25FhSzeoWBT9VeCrVj",
    serumEventQueue: "9PqaWBQ6gSZDZsztbWTnXp6LfrS2TUfVfPTSnf8tbgkE",
    serumCoinVaultAccount: "5LmHe3x8VwGzWZ6rooARZJNMo6AaN1P73478AuhBUjUr",
    serumPcVaultAccount: "iLCNUheHbq3bE1868XwWXs8enoTvjFnwpnmLFmBQGi3",
    serumVaultSigner: "9GN4139oezNfddWhcAc3c8Ke5aU4cwzcxL8cLkqE37Yy",
    official: true
  },
  {
    name: "TOMO-USDT",
    coin: { ...TOKENS.TOMO },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["TOMO-USDT-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "GjrXcSvwzGrz1RwKYGVWdbZyXzyotgichSHB95moDmf8",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "6As7AcwxnvawiY4mKnVTYqjTSRe9Uu2yW5hhJB97Ur6y",
    ammTargetOrders: "BPU6CpQ9RVrftpofrXD3Gui5iNXpbiNiCm9ecQUahgH6",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "8Ev8a9a8ZQi2xHYa7fwkYqzrmMrwbnUf6D9z762zAWcF",
    poolPcTokenAccount: "DriE8fPjPcTf7jzzyMqnQYqBPAVQPNS6bjZ4EABEJPUd",
    poolWithdrawQueue: "CR4AmK8geX2e1VLdFKgC2raxMwB4JsVUKXd3mBGkv4YW",
    poolTempLpTokenAccount: "GLXgb5oGNHQAVr2t68sET3NGPBtDitE5cQaMG3zgc7D8",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "GnKPri4thaGipzTbp8hhSGSrHgG4F8MFiZVrbRn16iG2",
    serumBids: "7C1XnffUgQVnfRTUPBPxQQT1QKsHwnQ7ogAWmmJqbW9L",
    serumAsks: "Hbd8HWXcZDPUUHYXJLH4vn9t1SfQZ83fqf4jQN65QpYL",
    serumEventQueue: "5AB3QbR7Ck5qsn21fM5zBzxVUnyougXroWHeR33bscwH",
    serumCoinVaultAccount: "P6qAvA6s7DHzzH4i74CUFAzx5bM4Yj3xk5TKmF7eWdb",
    serumPcVaultAccount: "8zFodcf4pKcRBq7Zhdg4tQeB76op7kSjPC2haPjPkDEm",
    serumVaultSigner: "ECTnLdZEaxUiCwyjKcts3CoMfT4kj3CNfVCd9B18hRim",
    official: true
  },
  {
    name: "LINK-USDT",
    coin: { ...TOKENS.LINK },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["LINK-USDT-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "E9EvurfzdSQaqCFBUaD4MgV93htuRQ93sghm922Pik88",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "CQ9roBWWPV5efTeZHoqgzJJvTSeVNMca6rteaenNwqF6",
    ammTargetOrders: "DVXgN8m2f8Ggs8zddLZyQdsh49jeUGnLq66s4Lhfd1uj",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "BKNf6HxSz9tCmeZts4ABHpYuXwP2wfKf4uRycwdTm3Jh",
    poolPcTokenAccount: "5Uzq3c6rnedxMF7t7s7PJVQkxxZE7YXGFPJUToyhdebY",
    poolWithdrawQueue: "Hj5vcVZCm6JXtkmCa1MPjteoxzkWQCmHQutXxofj2sy6",
    poolTempLpTokenAccount: "7WhsN9LGSeGxhZPT4E4rczauDvhmfquAKHQUESAXYS3k",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "3yEZ9ZpXSQapmKjLAGKZEzUNA1rcupJtsDp5mPBWmGZR",
    serumBids: "9fkA2oJQ7BKP5n2WxdLkY7mDA1mzBrGZ9osqVhvdBkH7",
    serumAsks: "G8c3xQURJk1oukLqJd3W4SJykmRq4wq3GrSWJwWipECH",
    serumEventQueue: "4MDEwZYKXuvEdQ58yMsE2zwXLG973aYp4EFvoaUSDMP2",
    serumCoinVaultAccount: "EmS34LncbTGs4yU4GM9bESRYMCFL3JBW6mnAeKB4UtEb",
    serumPcVaultAccount: "AseZZ8ZRqyvkZMMGAAG8dAqM9XFf2xGX2tWWbko7a4hC",
    serumVaultSigner: "FezSC2d6sXEcJ9ah8nYxHC18nh4FZzc4u7ZTtRSrk6Nd",
    official: true
  },
  {
    name: "ETH-USDT",
    coin: { ...TOKENS.ETH },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["ETH-USDT-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "He3iAEV5rYjv6Xf7PxKro19eVrC3QAcdic5CF2D2obPt",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "8x4uasC632WSrk3wgwoCWHy7MK7Xo2WKAe9vV93tj5se",
    ammTargetOrders: "G1eji3rrfRFfvHUbPEEbvnjmJ4eEyXeiJBVbMTUPfKL1",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "DZZwxvJakqbraXTbjRW3QoGbW5GK4R5nmyrrGrFMKWgh",
    poolPcTokenAccount: "HoGPb5Rp44TyR1EpM5pjQQyFUdgteeuzuMHtimGkAVHo",
    poolWithdrawQueue: "EispXkJcfh2PZA2fSXWsAanEGq1GHXzRRtu1DuqADQsL",
    poolTempLpTokenAccount: "9SrcJk8TB4JvutZcA4tMvvkdnxCXda8Gtepre7jcCaQr",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "7dLVkUfBVfCGkFhSXDCq1ukM9usathSgS716t643iFGF",
    serumBids: "J8a3dcUkMwrE5kxN86gsL1Mwrg63RnGdvWsPbgdFqC6X",
    serumAsks: "F6oqP13HNZho3bhwuxTmic4w5iNgTdn89HdihMUNR24i",
    serumEventQueue: "CRjXyfAxboMfCAmsvBw7pdvkfBY7XyGxB7CBTuDkm67v",
    serumCoinVaultAccount: "2CZ9JbDYPux5obFXb9sefwKyG6cyteNBSzbstYQ3iZxE",
    serumPcVaultAccount: "D2f4NG1NC1yeBM2SgRe5YUF91w3M4naumGQMWjGtxiiE",
    serumVaultSigner: "CVVGPFejAj3A75qPy2116iJFma7zGEuL8DgnxhwUaFBF",
    official: true
  },
  {
    name: "YFI-SRM",
    coin: { ...TOKENS.YFI },
    pc: { ...TOKENS.SRM },
    lp: { ...LP_TOKENS["YFI-SRM-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "GDVhJmDTdSExwHeMT5RvUBUNKLwwXNKhH8ndm1tpTv6B",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "5k2VpDkhbvypWvg9erQTZu4KsKjVLe1VAo3K71THrNM8",
    ammTargetOrders: "4dhnWeEq5aeqDFkEa5CKwS2TYrUmTZs7drFBAS656f6e",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "8FufHk1xV2j9RpVztnt9vuw9KJ89rpR7FMT1HTfsqyPH",
    poolPcTokenAccount: "FTuzfUyp6fhLMQ5kUdAkBWd9BjY114DfjkrVocAFKwkQ",
    poolWithdrawQueue: "A266ybcveVZYraGgEKWb9JqVWVp9Tsxa9hTudzvTQJgY",
    poolTempLpTokenAccount: "BXHfb8E4KNVnAVvz1eyVS12QqpvBUimtCnnNiBuoMrRa",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "6xC1ia74NbGZdBkySTw93wdxN4Sh2VfULtXh1utPaJDJ",
    serumBids: "EmfyNgr2t1mz6QJoGfs7ytLPpnT3A4kmZj2huGBFHtpr",
    serumAsks: "HQhD6ZoNfCjvUTfsE8KS46PLC8rpeyBYy1tY4FPgEbpQ",
    serumEventQueue: "4QGAwMgfi5PrMUoHvoSbGQV168kuRMURBK4pwGfSV7nC",
    serumCoinVaultAccount: "GzZCBp3Z3fYHZW9b4WusfQhp7p4rZXeSNahCpn8HBD9",
    serumPcVaultAccount: "ANK9Lpi4pUe9SxPvcKvd82jkG6AoKvvgo5kN8BCXukfA",
    serumVaultSigner: "9VAdxQgKNLkHgtQ4fkDetwwTKZG8xVaKeUFQwBVG7c7a",
    official: true
  },
  {
    name: "FTT-SRM",
    coin: { ...TOKENS.FTT },
    pc: { ...TOKENS.SRM },
    lp: { ...LP_TOKENS["FTT-SRM-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "21r2zeCacmm5YvbGoPZh9ZoGREuodhcbQHaP5tZmzY14",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "CimwwQH1h2MKbFbodHHByMq8MreFuJznMGVXxYKMpyiB",
    ammTargetOrders: "Fewh6hVTfeduAnbqwNuUx2Cu7uTyJTALP76hjpWCvRoV",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "Atc9Prscs9RLmDEpsCQzFgCqzkscAtTck5ZSZGV9s7hE",
    poolPcTokenAccount: "31ZJVJMap4WpPbzaScPwg5MGRUDjatP2kXVsSgf12yVZ",
    poolWithdrawQueue: "yAZD46BC1Bti2X5FEjveobueuyevi7jFV5ew6DH8Thz",
    poolTempLpTokenAccount: "7Ro1o6Vbh3Ech2zeozNDicRP1gZfHAWcRnxvrzdnLfYi",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "CDvQqnMrt9rmjAxGGE6GTPUdzLpEhgNuNZ1tWAvPsF3W",
    serumBids: "9NfJWy5QNqRDGmNARphS9kJyYtR6nkkWcFyJRLbgECtd",
    serumAsks: "9VEVBJZHVv6N2MzAzNLiCwN2MAdt5GDScCtpE4zkzDFW",
    serumEventQueue: "CbnLQT9Jwo3RHpWBnsPisAybSN4CBuwj4fcF1S9qJchV",
    serumCoinVaultAccount: "8qTUSDRxJ65sGKEUu746xJdCquoP38AqKsQo6ZruSSBk",
    serumPcVaultAccount: "ALe3hiZR35cCjcrzbJi1vKEhNftdVQjwkt4S8rbPZogq",
    serumVaultSigner: "CAAeuJAgnP368num8bCv6VMWCqMZ4pTANCcGTAMAJtm2",
    official: true
  },
  {
    name: "BTC-SRM",
    coin: { ...TOKENS.BTC },
    pc: { ...TOKENS.SRM },
    lp: { ...LP_TOKENS["BTC-SRM-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "DvxLb4NnQUYq1gErk35HVt9g8kxjNbviJfiZX1wqraMv",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "3CGxjymeKv5wvpVg9unUgbrGUESmeqfJUJkPjVeRuMvT",
    ammTargetOrders: "C8YiDYrk4rfC6sgK93zM3YpGj7SDpGuRbos7DHStSssT",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "5jV7XQ1JnfUg7RvEShyAdV7Gzn1xS54j163x8ZBSzxuh",
    poolPcTokenAccount: "HSKY5r6iqCpC4nWzCGP2oWMQdGEQsx69eBm33PrmZqhg",
    poolWithdrawQueue: "5faTQUz7gmasinkinA7BkC6HsG8hUrD9iukaohF2fuHZ",
    poolTempLpTokenAccount: "9QutovnPtwN9pPxsTdaEWBSCT7iTKc3hwMfF4QJHDXRz",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HfsedaWauvDaLPm6rwgMc6D5QRmhr8siqGtS6tf2wthU",
    serumBids: "GMM36fgidwYvXCAxQhpT1XkGoZ46g1wMc44hY8ds3P8u",
    serumAsks: "BFDQ4WGcEftURk6nrwtQ1GzYdPYj8fx3iBjeJVt6S3jQ",
    serumEventQueue: "94ER3KZeDrYSG8TytGJ56rZK9zM8oz1H8dJ2LP1gHn2s",
    serumCoinVaultAccount: "3ABvHYBeWrpgP82jvHh5TVwid1AjDj9rei7zfY8xh2wz",
    serumPcVaultAccount: "CSpdPdzzbaNWgwhPRTZ4TNoYS6Vco2w1s7jvqUsYQBzf",
    serumVaultSigner: "9o8LaPeTMJBoYyoUVNm6ju6c5rwfphhYReQsp1vTTyRg",
    official: true
  },
  {
    name: "SUSHI-SRM",
    coin: { ...TOKENS.SUSHI },
    pc: { ...TOKENS.SRM },
    lp: { ...LP_TOKENS["SUSHI-SRM-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "BLVjPTgzyfiKSgDujTNKKNzW2GXx7HhdMxgr2LQ2g83s",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "Efpi6e4ckqtfaED9gRmadN3RtiTXDtGPrp1szsh7sj7C",
    ammTargetOrders: "BZUFGpRWEsYzpVfLrFpdE7E9fzGhrySQE1TrsX92qWAC",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "BjWKHZxVMQykmGGmkhA1m9QQycJTeQFs51kyfP1zQvzv",
    poolPcTokenAccount: "EnWaAD7WAyznuRjg9PqRr2vVaXqQpTje2fBWyFFEvr37",
    poolWithdrawQueue: "GbEc9D11VhEHCDsqcSZ5vPVfnzV7BCS6eTquoVvhSaNz",
    poolTempLpTokenAccount: "AQ4YUkqPSbP8JpnCWEAkYNUWm6AjUSnPucKhVN8ypuiB",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "FGYAizUhNEC9GBmj3UyxdiRWmGjR3TfzMq2dznwYnjtH",
    serumBids: "J9weS4eF3DcSMLttazndEwVtjsqfRf6vBg1FNhdYrKiW",
    serumAsks: "4TCPXw9UBcPfSVtaArzydHvgAXfDbq28iZVjHidbM9rp",
    serumEventQueue: "2eJU3EygyV4SWGAH1g5F57CxtaTj4nL36apaRtnEZ9zH",
    serumCoinVaultAccount: "BSoAoNFKzK65TjcUpY5JZHBvZVMiYnkdo9upy3mLSTpq",
    serumPcVaultAccount: "8U9azb65o1dJuMs7je987i7hKxJfPZnbNRNeH5beJfo7",
    serumVaultSigner: "HZtDGZsz2fdXF75H8tyB8skp5a4rvoawgxwXqHTGEdvU",
    official: true
  },
  {
    name: "TOMO-SRM",
    coin: { ...TOKENS.TOMO },
    pc: { ...TOKENS.SRM },
    lp: { ...LP_TOKENS["TOMO-SRM-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "DkMAuUCQHC6BNgVnjtM5ZTKm1T8MsriQ6bL3Umi6NBtG",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "34eRiATmb9Ktv1QTDzzckyaFhj4KpC2y94TJXXd34erL",
    ammTargetOrders: "CK2vFsmS2CEZ2Hi6Vf9px8p5DSpoyXST9rkFHwbbHirU",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "8BjTHZccnRNZKZpAxsdXx5BEQ4Kpxd9pQLNgeMqMiTZL",
    poolPcTokenAccount: "DxcJXkGo8BUmsky51LuKi4Vs1zW48fHrCXEY6BKuY3TY",
    poolWithdrawQueue: "AoP3EXWypUheq9ZURDBpf8Jd1ijRuhUCQg1uiM5zFpB5",
    poolTempLpTokenAccount: "9go7YtJ6QdG3mWgVhwRcQAfmwPruJk5MmsjyTn2HJisK",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "7jBrpiq3w2ywzzb54K9SoosZKy7nhuSQK9XrsgSMogFH",
    serumBids: "ECdZLJGwcN6fXY9BjiSVNrWssKdWejW9uv8Zs6GkkxBG",
    serumAsks: "J5NN79kpFzGdxj8MGvis3NsGYcrvcdYHNXLtGGn9au5E",
    serumEventQueue: "7FrdprBxpDyM7P1AkeMtEJ75Q6UK6ZE92zgqGg5F4Gxb",
    serumCoinVaultAccount: "8W65Bwb83MYKHf82phS9xPUDsR6RpZbAXnSELxsBb3HH",
    serumPcVaultAccount: "5rjDHBsjFv3Z3Dxr5RMj98vj6LA5DNEwZGDM8wyUF1Hy",
    serumVaultSigner: "EJfMPPTvTKtgj7PUaM17bp2Gbye9CdKjZ5yqonPyY4rB",
    official: true
  },
  {
    name: "LINK-SRM",
    coin: { ...TOKENS.LINK },
    pc: { ...TOKENS.SRM },
    lp: { ...LP_TOKENS["LINK-SRM-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "796pvggjoDCPUtUSVFSCLqPRyes5YPvRiu4zFWX582wf",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "3bZB7mZ5hRNZfrJx6BL5C4GhP4nT14rEAGVPXL34hrZg",
    ammTargetOrders: "Ha4yLJU1UrZi8MqCMu2pLK3xXREG1GW1bjjqTsjQnC3c",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "5eTUmVN3kXqBeKHUA2kWU19jB7kFN3wpejWvWYcw6dBa",
    poolPcTokenAccount: "4BsmBxNQtuKgBTNjci8tWd2NqPxXBs2JY38X26epSHYy",
    poolWithdrawQueue: "2jn4FQ2CtYwXDgCcLbNrGUzKFeB5PpPbnMr2x2z2wz3V",
    poolTempLpTokenAccount: "7SxKHHATjgEgfxnLrtKaSU77s2ABqD8BoEr6W6dFMS3a",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "FafaYTnhDbLAFsr5qkD2ZwapRxaPrEn99z59UG4zqRmZ",
    serumBids: "HyKmFiuoWZo7STLjvJJ66YR4V1wauAorCPUaxnnB6umk",
    serumAsks: "8qjKdvjmBPZWjxP3nWjwFCcsrAspCN5EyTD3WfgKbFj4",
    serumEventQueue: "FWZB7PJLwg7WdgoVBRrkvz2A4S7ZctKnoGj1yCSxqs9G",
    serumCoinVaultAccount: "8J7iJ4uidHscVnNGsEgiEPJsUqrfteN7ifMscB9h4dAq",
    serumPcVaultAccount: "Bw7SrqDqvAXHi2yphAniH3uBw9N7J6vVi7jMH9B2KYWM",
    serumVaultSigner: "CvP4Jk6AYBV6Kch6w6FjwuMqHAugQqVrqCNp1eZmGihB",
    official: true
  },
  {
    name: "ETH-SRM",
    coin: { ...TOKENS.ETH },
    pc: { ...TOKENS.SRM },
    lp: { ...LP_TOKENS["ETH-SRM-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "3XwxHcbyqcd1xkdczaPv3TNCZsevELD4Zux3pu4sF2D8",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "FBfaqV1RRacEi27E3dm8yLcxpbWYx4BzMXG4zMNx7ZdS",
    ammTargetOrders: "B1gQ6FHLxmBzznDKn8Rj1ZokcJtdSWjkCoXdQLRhz8NS",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "CsFFjzC1hmpqimExTj8g4kregUxGnGrEWX9Jhne172uU",
    poolPcTokenAccount: "ACg55oVWt1a4ZVxnFVCRDEMz1JAeGY13snXufdQAp4pX",
    poolWithdrawQueue: "C6MRGfZ13tstxjcWuLqUseUikidsAjgk7zBEYqM6cFb4",
    poolTempLpTokenAccount: "EVRzNkPU9UAzBf8XhJYD84U7petDZnSMVaaa9mtBQaM6",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "3Dpu2kXk87mF9Ls9caWCHqyBiv9gK3PwQkSvnrHZDrmi",
    serumBids: "HBVsrbKLEf1aaUy9oKFkQZVDtgTf54T9H8FQdcGbF7EH",
    serumAsks: "5T3zDaT1XvfEb9jKcgpFyQRze9qWKNTE1iSE5aboxYZy",
    serumEventQueue: "3w11TRux1gX7nqaGUMGpPH9ocDBPudeLTw6k1uhsLo2k",
    serumCoinVaultAccount: "58jqhCZ11r6ZvATqdGfDXPk7LmiR9HS3jQt7kuoBx5CH",
    serumPcVaultAccount: "9NLpT5aZtbbauvEVVFsHqigv2ekTEPK1kojoMMCw6Hhx",
    serumVaultSigner: "EC5JsbaQVp8tM59TqkQBk4Yv7bzLQq3TrzpepjGr9Ecg",
    official: true
  },
  {
    name: "SRM-SOL",
    coin: { ...TOKENS.SRM },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["SRM-SOL-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "EvWJC2mnmu9C9aQrsJLXw8FhUcwBzFEUQsP1E5Y6a5N7",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "9ot4bg8aT2FRKfiRrM2fSPHEr7M1ihBqm1iT4771McqR",
    ammTargetOrders: "AfzGtG3XnMixxJTx2rwoWLXKVaWoFMhsMeYo929BrUBY",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "BCNYwsnz3yXvi4mY5e9w2RmZvwUW3pefzYQ4tsoNdDhp",
    poolPcTokenAccount: "7BXPSUXeBVqJGyxW3yvkNxnJjYHuC8mnhyFCDp2abAs6",
    poolWithdrawQueue: "HYo9FfBpm8NCpR8qYMGYFZNqzKkXDRFACLxu8PXCCDc4",
    poolTempLpTokenAccount: "AskrcNfMDKT5c65AYeuEBW6mfMXfT3SG4nDCDRAyEnad",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "jyei9Fpj2GtHLDDGgcuhDacxYLLiSyxU4TY7KxB2xai",
    serumBids: "4ZTJfhgKPizbkFXNvTRNLEncqg85yJ6pyT7NVHBAgvGw",
    serumAsks: "7hLgwZhHD1MRNyiF1qfAjfkMzwvP3VxQMLLTJmKSp4Y3",
    serumEventQueue: "nyZdeD16L5GxJq7Pso8R6KFfLA8R9v7c5A2qNaGWR44",
    serumCoinVaultAccount: "EhAJTsW745jiWjViB7Q4xXcgKf6tMF7RcMX9cbTuXVBk",
    serumPcVaultAccount: "HFSNnAxfhDt4DnmY9yVs2HNFnEMaDJ7RxMVNB9Y5Hgjr",
    serumVaultSigner: "6vBhv2L33KVJvAQeiaW3JEZLrJU7TtGaqcwPdrhytYWG",
    official: true
  },
  {
    name: "STEP-USDC",
    coin: { ...TOKENS.STEP },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["STEP-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "4Sx1NLrQiK4b9FdLKe2DhQ9FHvRzJhzKN3LoD6BrEPnf",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "EXgME2sUuzBxEc2wuyoSZ8FZNZMC3ChhZgFZRAW3nCQG",
    ammTargetOrders: "78bwAGKJjaiPQqmwKmbj4fhrRTLAdzwqNwpFdpTzrhk1",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "8Gf8Cc6yrxtfUZqM2vf2kg5uR9bGPfCHfzdYRVBAJSJj",
    poolPcTokenAccount: "ApLc86fHjVbGbU9QFzNPNuWM5VYckZM92q6sgJN1SGYn",
    poolWithdrawQueue: "5bzBcB7cnJYGYvGPFxKcZETn6sGAyBbXgFhUbefbagYh",
    poolTempLpTokenAccount: "CpfWKDYNYfvgk42tqR8HEHUWohGSJjASXfRBm3yaKJre",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "97qCB4cAVSTthvJu3eNoEx6AY6DLuRDtCoPm5Tdyg77S",
    serumBids: "5Xdpf7CMGFDkJj1smcVQAAZG6GY9gqAns18QLKbPZKsw",
    serumAsks: "6Tqwg8nrKJrcqsr4zR9wJuPv3iXsHAMN65FxwJ3RMH8S",
    serumEventQueue: "5frw4m8pEZHorTKVzmMzvf8xLUrj65vN7wA57KzaZFK3",
    serumCoinVaultAccount: "CVNye3Xr9Jv26c8TVqZZHq4F43BhoWWfmrzyp1M9YA67",
    serumPcVaultAccount: "AnGbReAhCDFkR83nB8mXTDX5dQJFB8Pwicu6pGMfCLjt",
    serumVaultSigner: "FbwU5U1Doj2PSKRJi7pnCny4dFPPJURwALkFhHwdHaMW",
    official: true
  },
  {
    name: "MEDIA-USDC",
    coin: { ...TOKENS.MEDIA },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["MEDIA-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "94CQopiGxxUXf2avyMZhAFaBdNatd62ttYGoTVQBRGdi",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "EdS5vqjihxRbRujPkqqzHYwBqcTP9QPbrBc9CDtnBDwo",
    ammTargetOrders: "6Rfew8qvNp97PVN14C9Wg8ybqRdF9HUEUhuqqZBWcAUW",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "7zfTWDFmMi3Tzbbd3FZ2vZDdBm1w7whiZq1DrCxAHwMj",
    poolPcTokenAccount: "FWUnfg1hHuanU8LxJv31TAfEWSvuWWffeMmHpcZ9BYVr",
    poolWithdrawQueue: "F7MUnGrShtQqSvi9DoWyBNRo7FUpRiYPsS9aw77auhiS",
    poolTempLpTokenAccount: "7oX2VcPYwEV6EUUyMUoTKVVxAPAvGQZcGiGzotX43wNM",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "FfiqqvJcVL7oCCu8WQUMHLUC2dnHQPAPjTdSzsERFWjb",
    serumBids: "GmqbTDL5QSAhWL7UsE8MriTHSnodWM1HyGR8Cn8GzZV5",
    serumAsks: "CrTBp7ThkRRYJBL4tprke2VbKYj2wSxJp3Q1LDoHcQwP",
    serumEventQueue: "HomZxFZNGmH2XedBavMsrXgLnWFpMLT95QV8nCYtKszd",
    serumCoinVaultAccount: "D8ToFvpVWmNnfJzjHuumRJ4eoJc39hsWWcLtFZQpzQTt",
    serumPcVaultAccount: "6RSpnBYaegSKisXaJxeP36mkdVPe9SP3p2kDERz8Ahhi",
    serumVaultSigner: "Cz2m3hW2Vcb8oEFz12uoWcdq8mKb9D1N7RTyXpigoFXU",
    official: true
  },
  {
    name: "ROPE-USDC",
    coin: { ...TOKENS.ROPE },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["ROPE-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "BuS4ScFcZjEBixF1ceCTiXs4rqt4WDfXLoth7VcM2Eoj",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "ASkE1yKPBei2aUxKHrLRptB2gpC3a6oTSxafMikoHYTG",
    ammTargetOrders: "5isDwR41fBJocfmcrcfwRtTnmSf7CdssdpsmBy2N2Eym",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "3mS8mb1vDrD45v4zoxbSdrvbyVM1pBLM31cYLT2RfS2U",
    poolPcTokenAccount: "BWfzmvvXhQ5V8ZWDMC4u82sEWgc6HyRLnq6nauwrtz5x",
    poolWithdrawQueue: "9T1cwwE5zZr3D2Rim8e5xnJoPJ9yKbTXvaRoxeVoqffo",
    poolTempLpTokenAccount: "FTFx4Vg6hgKLZMLBUvazvPbM7AzDe5GpfeBZexe2S6WJ",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "4Sg1g8U2ZuGnGYxAhc6MmX9MX7yZbrrraPkCQ9MdCPtF",
    serumBids: "BDYAnAUSoBTtX7c8TKHeqmSy7U91V2pDg8ojvLs2fnCb",
    serumAsks: "Bdm3R8X7Vt1FpTruE9SQVESSd3BjAyFhcobPwAoK2LSw",
    serumEventQueue: "HVzqLTfcZKVC2PanNpyt8jVRJfDW8M5LgDs5NVVDa4G3",
    serumCoinVaultAccount: "F8PdvS5QFhSqgVdUFo6ivXdXC4nDEiKGc4XU97ZhCKgH",
    serumPcVaultAccount: "61zxdnLpgnFgdk9Jom5f6d6cZ6cTbwnC6QqmJag1N9jB",
    serumVaultSigner: "rCFXUwdmQvRK9jtnCip3SdDm1cLn8nB6HHgEHngzfjQ",
    official: true
  },
  {
    name: "MER-USDC",
    coin: { ...TOKENS.MER },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["MER-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "BkfGDk676QFtTiGxn7TtEpHayJZRr6LgNk9uTV2MH4bR",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "FNwXaqyYNKNwJ8Qc39VGzuGnPcNTCVKExrgUKTLCcSzU",
    ammTargetOrders: "DKgXbNmsm1uCJ2eyh6xcnTe1G6YUav8RgzaxrbkG4xxe",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "6XZ1hoJQZARtyA17mXkfnKSHWK2RvocC3UDNsY7f4Lf6",
    poolPcTokenAccount: "F4opwQUoVhVRaf3CpMuCPpWNcB9k3AXvMMsfQh52pa66",
    poolWithdrawQueue: "8mqpqWGL7W2xh8B1s6XDZJsmPuo5zRedcM5sF55hhEKo",
    poolTempLpTokenAccount: "9ex6kCZsLR4ZbMCN4TcCuFzkw8YhiC9sdsJPavsrqCws",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "G4LcexdCzzJUKZfqyVDQFzpkjhB1JoCNL8Kooxi9nJz5",
    serumBids: "DVjhW8nLFWrpRwzaEi1fgJHJ5heMKddssrqE3AsGMCHp",
    serumAsks: "CY2gjuWxUFGcgeCy3UiureS3kmjgDSRF59AQH6TENtfC",
    serumEventQueue: "8w4n3fcajhgN8TF74j42ehWvbVJnck5cewpjwhRQpyyc",
    serumCoinVaultAccount: "4ctYuY4ZvCVRvF22QDw8LzUis9yrnupoLQNXxmZy1BGm",
    serumPcVaultAccount: "DovDds7NEzFn493DJ2yKBRgqsYgDXg6z38pUGXe1AAWQ",
    serumVaultSigner: "BUDJ4F1ZknbZiwHb6xHEsH6o1LuW394DE8wKT8CoAYNF",
    official: true
  },
  {
    name: "COPE-USDC",
    coin: { ...TOKENS.COPE },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["COPE-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "DiWxV1SPXPNJRCt5Ao1mJRAxjw97hJVyj8qGzZwFbAFb",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "jg8ayFZLH2cEUJULUirWy7wNggN1eyRnTMt6EjbJUun",
    ammTargetOrders: "8pE4fzFzRT6aje7B3hYHXrZakeEqNF2kFmJtxkrxUK9b",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "FhjBg8vpVgsiW9oCUxujqoWWSPSRvnWNXucEF1G1F39Z",
    poolPcTokenAccount: "Dv95skm7AUr33x1p2Bu5EgvE3usB1TxgZoxjBe2rpfm6",
    poolWithdrawQueue: "4An6jy1JocXGUjayXqVTx1jvs79o8LgsRk3VvmRgXxaq",
    poolTempLpTokenAccount: "57hiWKd47VHVD7y8BenqnakSdgQNBvyUrkSpf9BDP6UQ",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "6fc7v3PmjZG9Lk2XTot6BywGyYLkBQuzuFKd4FpCsPxk",
    serumBids: "FLjCjU5wLUsqF6FeYJaH5JtTTFSTZzTCingxN1uyr9zn",
    serumAsks: "7TcstD7AdWqjuFoRVK24zFv66v1qyMYDNDT1V5RNWKRz",
    serumEventQueue: "2dQ1Spgc7rGSuE1t3Fb9RL7zvGc7F7pH9XwJ46u3QiJr",
    serumCoinVaultAccount: "2ShBow4Bof4dkLjx8VTRjLXXvUydiBNF7bHzDaxPjpKq",
    serumPcVaultAccount: "EFdqJhawpCReiK2DcrbbUUWWc6cd8mqgZm5MSbQ3TR33",
    serumVaultSigner: "A6q5h5Wx9iqeoVsvYWA7xofUcKx6XUPPab8BTVrW91Bs",
    official: true
  },
  {
    name: "ALEPH-USDC",
    coin: { ...TOKENS.ALEPH },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["ALEPH-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "GDHXjn9wF2zxW35DBkCegWQdoTfFBC9LXt7D5ovJxQ5B",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "AtUeUK7MZayoDktjrRSJAFsyPiPwPsbAeTsunM5pSnnK",
    ammTargetOrders: "FMYSGYEL1CPYz8cpgAor5jV2HqeEQRDLMEggoz6wAiFV",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "BT3QMKHrha4fhqpisnYKaPDsv42XeHU2Aovhdu5Bazru",
    poolPcTokenAccount: "9L4tXPyuwuLhmtmX4yaRTK6TB7tYFNHupeENoCdPceq",
    poolWithdrawQueue: "4nRbmEUp7DQroG71jXv6cJjrhnh91ePdPhzmBSjinwB8",
    poolTempLpTokenAccount: "9JdpGvmo6aPZYf4hkiZNUjceXgd2RtR1fJgvjuoAuhsM",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "GcoKtAmTy5QyuijXSmJKBtFdt99e6Buza18Js7j9AJ6e",
    serumBids: "HmpcmzzajDvhFSXb4pmJo5mb23zW8Cj9FEeB3hVT78jV",
    serumAsks: "8sfGm6jsFTAcb4oLuqMKr1xNEBd5CXuNPAKZEdbeezA",
    serumEventQueue: "99Cd6D9QnFfTdKpcwtoF3zAZdQAuZQi5NsPMERresj1r",
    serumCoinVaultAccount: "EBRqW7DaUGFBHRbfgRagpSf9jTSS3yp9MAi3RvabdBGz",
    serumPcVaultAccount: "9QTMfdkgPWqLriB9J7FcYvroUEqfw6zW2VCi1dAabdUt",
    serumVaultSigner: "HKt6xFufxTBBs719WQPbro9t1DfDxffurxFhTPntMgoe",
    official: true
  },
  {
    name: "TULIP-USDC",
    coin: { ...TOKENS.TULIP },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["TULIP-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "96hPvuJ3SRT82m7BAc7G1AUVPVcoj8DABAa5gT7wjgzX",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "6GtSWZfdUFtT47RPk2oSxoB6RbNkp9aM6yP77jB4XmZB",
    ammTargetOrders: "9mB928abAihkhqM6AKLMW4cZkHBXFn2TmcxEKhTqs6Yr",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "s9Xp7GV1jGvixdSfY6wPgivsTd3c4TzjW1eJGyojwV4",
    poolPcTokenAccount: "wcyW58QFNfppgm4Wi7cKhSftdVNfpLdn67YvvCNMWrt",
    poolWithdrawQueue: "59NA3khShyZk4dhDjFN564nScNdEi3UR4wrCnLN6rRgX",
    poolTempLpTokenAccount: "71oLQgsHknJVHGJDCaBVUnb6udGepK7kwkHXGy47u2i4",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "8GufnKq7YnXKhnB3WNhgy5PzU9uvHbaaRrZWQK6ixPxW",
    serumBids: "69W6zLetZ7FgXPXgHRp4i4wNd422tXeZzDuBzdkjgoBW",
    serumAsks: "42RcphsKYsVWDhaqJRETmx74RHXtHJDjZLFeeDrEL2F9",
    serumEventQueue: "ExbLY71YpFaAGKuHjJKXSsWLA8hf1hGLoUYHNtzvbpGJ",
    serumCoinVaultAccount: "6qH3FNTSGKw34SEEj7GXbQ6kMQXHwuyGsAAeV5hLPhJc",
    serumPcVaultAccount: "6AdJbeH76BBSJ34DeQ6LLdauF6W8fZRrMKEfLt3YcMcT",
    serumVaultSigner: "5uJEd4wfVH84HyFEBf5chfJMTTPHBddXi1S7GmBE6x14",
    official: true
  },
  {
    name: "WOO-USDC",
    coin: { ...TOKENS.WOO },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["WOO-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "DSkXJYPZqJ3yHQECyVyh3xiE3HBrt7ARmepwNDA9rREn",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "6WHHLn8ia2eHZnPFPDwBKaW2nt7vTRNsvrbgzS55gVwi",
    ammTargetOrders: "HuSyM774u2zhjbG8rQYCrALBHhK7yVWgUP36rNEtfTs2",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "HeMxCh5SozqLth4QPpU1cbEw29ueqFUKSYP6369GX1HV",
    poolPcTokenAccount: "J3jwx9wsRAq1sBu5tSsKpA4ixQVzLiLyRKdxkjMcRenv",
    poolWithdrawQueue: "FRSDrhT8Q28yZ3dGhVwNoAbzWawsE3qgmAAEwxTNtE6y",
    poolTempLpTokenAccount: "GP8hM7HRSjcsQfTbvHKNAWnwhqdn2Nxthb4UJiKXkfJC",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "2Ux1EYeWsxywPKouRCNiALCZ1y3m563Tc4hq1kQganiq",
    serumBids: "34oLSEmDGyH4NyP84mUXCHbpW9JvG5anNd3iPaCF55zE",
    serumAsks: "Lp7h84DcAmWqhDbJ6LpvVX9m45GJQfpvMbWPTg4qtkF",
    serumEventQueue: "8Y7MaACCFcTdjcUSLsGkxqxMLDaJDPSZtT5R1kuUL1Hk",
    serumCoinVaultAccount: "54vv5QSZkmHpQzpvUmpS5ZreDwmbuXPdbGp9ybzgcsTM",
    serumPcVaultAccount: "7PL69dV89XXJg9V6wzzdu9p2ymhVwBWqp82sUzWvjnp2",
    serumVaultSigner: "CTcvsPoWroF2e2iiZWe6ztBwNQHiDyAVCs8EbQ5Annig",
    official: true
  },
  {
    name: "SNY-USDC",
    coin: { ...TOKENS.SNY },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["SNY-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "5TgJXpv6H3KJhHCuP7KoDLSCmi8sM8nABizP7CmYAKm1",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "2Nr82a2ZxqsQYwBbpeLWQedy1s9kAi2U2AbeuMKjgFzw",
    ammTargetOrders: "Cts3uDVAgUSaXAHMEfLPnQWF4W5TpGdiB7WhYDAaQbSy",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "FaUYbopmMVdNRe3rLnqGPBA2KB96nLHudKaEgAUcvHXn",
    poolPcTokenAccount: "9YiW8N9QdEsAdTQN8asjebwwEmDXAHRnb1E3nvz64vjg",
    poolWithdrawQueue: "HpWzYHXNeQkmW9oxFjHFozyy6sVxetqJBZdhNSTwcNid",
    poolTempLpTokenAccount: "7QAVG74PVZntmFqvnGYwYySRBjB13HSeSNABwMPtfAPR",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "DPfj2jYwPaezkCmUNm5SSYfkrkz8WFqwGLcxDDUsN3gA",
    serumBids: "CFFoYkeUJaAEh6kQyVEbAgkWfABnH7c8Lynr2hk8ycJT",
    serumAsks: "AVQEVeftGzTV6Yj2jEPFGgWHyTYs5uyT3ZFFyTaLgTAP",
    serumEventQueue: "H6UE5r8zMsaHW9fha6Xm7bsWrYbyaL8WbBjhbqbZYPQM",
    serumCoinVaultAccount: "CddTJJj2tDWUk6Kteh3KSBJJh4HvkoWMXcQjZuXaaAzP",
    serumPcVaultAccount: "BGr1LWgHKaekkmScogSU1SYSRUaJBBPFeBAEBvuwf7CE",
    serumVaultSigner: "3APrMUDUQ16iEsL4vTaovTf5fPXAEwtXmWXvD9xQVPaB",
    official: true
  },
  {
    name: "BOP-RAY",
    coin: { ...TOKENS.BOP },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["BOP-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "SJmR8rJgzzCi4sPjGnrNsqY4akQb3jn5nsxZBhyEifC",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "8pt8zWa9hsRSsiCJtVWnApXGBkmzSubjqf9sbgkbj9LS",
    ammTargetOrders: "Gg6gGVaokrVMJWtgDbamPwVG8PBN3VbgHLFghfSn3JxY",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "B345z8QcC2WvCwKjeTveLHAuEghumw2qH2xPxAbW7Awd",
    poolPcTokenAccount: "EPFPMhTRNA6f7J1NzEZ1rkWyhfexZBr9VX3MAn3C6Ce4",
    poolWithdrawQueue: "E8PcDA6vn9WHRsrMYZvKy2D2CxTB28Bp2cKAYcu16JH9",
    poolTempLpTokenAccount: "47GcR2477mHukyTte1LpDShs4RUmkcF2rejJvisRFALB",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "6Fcw8aEs7oP7YeuMrM2JgAQUotYxa4WHKHWdLLXssA3R",
    serumBids: "3CNgQ6KpTQYKX9s1CSy5y16ZtnXqYfcTHikmHjEjXKJm",
    serumAsks: "7VxSfKDL7i3FmpJLnK4v7YgidNa1t7SCo84FY7YinQyA",
    serumEventQueue: "9ote3YanmgQgL6vPBUGJVZyFsp6HDJNviTw7ghxzMDLT",
    serumCoinVaultAccount: "CTv9hnW3nbANzJ2yyzmyMCoUxv5s95ndxcBbLzV39z3w",
    serumPcVaultAccount: "GXFttVfXbH7rU6GJnBVs3LyyuiPU8a6sW2tv5K5ZGEAQ",
    serumVaultSigner: "5JEwQ7hM1qFCBwJkZ2JyjkoJ99ojJXRx2bFjLcFobDvC",
    official: true
  },
  {
    name: "SLRS-USDC",
    coin: { ...TOKENS.SLRS },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["SLRS-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "7XXKU8oGDbeGrkPyK5yHKzdsrMJtB7J2TMugjbrXEhB5",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "3wNRVMaot3R2piZkzmKsAqewcZ5ABktqrJZrc4Vz3uWs",
    ammTargetOrders: "BwSmQF7nxRqzzVdfaynxM98dNbXFi94cemDDtxMfV3SB",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "6vjnbp6vhw4RxNqN3e2tfE3VnkbCx8RCLt8RBmHZvuoC",
    poolPcTokenAccount: "2anKifuiizorX69zWQddupMqawGfk3TMPGZs4t7ZZk43",
    poolWithdrawQueue: "Fh5WTfP9jCbkLPzsspCs4WCSPGqE5GYE8v7kqFXijMSA",
    poolTempLpTokenAccount: "9oiniKrJ7r1cHw97gv4XPxTFS9i61vSa7PkpRcm8qGeK",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "2Gx3UfV831BAh8uQv1FKSPKS9yajfeeD8GJ4ZNb2o2YP",
    serumBids: "6kMW5vafM4mWZJdBNpH4EsVjFSuSTUokx5meYoVY8GTw",
    serumAsks: "D5asu2BVatxtgGFugwmNubdknAsLSJDZcqRHvkaS8UBd",
    serumEventQueue: "66Go3JcjNJaDHHvJyaFaV8rh8GAciLzvM8WzN7fRE3HM",
    serumCoinVaultAccount: "6B527pfkvbvbLRDgjASLGygdaQ1fFLwmmqyFCgTacsKH",
    serumPcVaultAccount: "Bsa11vdveUhSouxAXSYCE4yXToUP58N9EEeM1P8qbtp3",
    serumVaultSigner: "CjiJdQ9a7dnjTKfVPZ2fwn31NtgJA1kRU55pwDE8HHrM",
    official: true
  },
  {
    name: "SAMO-RAY",
    coin: { ...TOKENS.SAMO },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["SAMO-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "EyDgEU9BdG7m6ZK4bYERxbN4NCJ129WzPtv23dBkfsLg",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "45TD9SmkGoq4hBxBnsQQD2V7pyWK53HkEXz7uNNHpezG",
    ammTargetOrders: "Ave8ozwW9iBGL4SpK1tM1RfrQi8CsLUFj4UGdFkWRPRp",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "9RFqA8EbTTqH3ct1fTGiGgqFAg2hziUdtyGgg1w69LJP",
    poolPcTokenAccount: "ArAyYYib2X8BTcURYNXKhfoUww2DWkzk67PRPGVpFAuJ",
    poolWithdrawQueue: "ASeXk7dri8jz466wCtkCVUYheHFEznX55EMuGivL5WPL",
    poolTempLpTokenAccount: "2pu8zUYpwa9UEPvKkQvZHQUbbTdMg6N2mXi2Vv4DaEJV",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "AAfgwhNU5LMjHojes1SFmENNjihQBDKdDDT1jog4NV8w",
    serumBids: "AYEeLrFWhGDRgX9L428SqBU56iVzDSyP3A6Db4VekcjE",
    serumAsks: "CctHQdpAtxugQNFU7PA4ebb2T5K1ZkwDTvoFrsYrxifY",
    serumEventQueue: "CFtHmFydRBtw1qsoPZ4LufbdX39LKT9Aw5HzUib9JpiL",
    serumCoinVaultAccount: "BpHuL7HNTJDDGiw4ELpnYQdhTNNgZ53ennhtkQjGawGS",
    serumPcVaultAccount: "BzsbZPiwLMJHhSFNVdtGqi9MWKhYijgq34Z6YjYkQJUr",
    serumVaultSigner: "F2f14Nw7kqBeGwgFymm7sEPcZrKWWN56hvN5yx2vc6sE",
    official: true
  },
  {
    name: "renBTC-USDC",
    coin: { ...TOKENS.renBTC },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["renBTC-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "61JtCkTQKSeBU8ztEScByZiBhS6KAHSXfQduVyA4s1h7",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "AtFR9ub2dbNJJod7gPL81F7gRxVtpcR1n4GczqgasqX2",
    ammTargetOrders: "ZVmcXezubm6FXvS8Wtvah66vqZRW6NKD17tea7FcGsB",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "2cA595zqm12sRtsiNvV6AqD8WDYYiJoLwEYNQ1FZG2ep",
    poolPcTokenAccount: "Fxn92YfcVsd9diz32YtKixqmuezgLeSWqd1gypFL5qe",
    poolWithdrawQueue: "ioR3UfTLnz6t9Bzbcu7TPmw1xYQRwXCgGqcpvzRmCQx",
    poolTempLpTokenAccount: "8VEBvPwhBwu9D4e4Zei6X31ZBs5udL5epJHp935LVMv1",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "74Ciu5yRzhe8TFTHvQuEVbFZJrbnCMRoohBK33NNiPtv",
    serumBids: "B1xjpD5EEVtLWnWioHc7pCJLj1WVGyKdyMV1NzY4q5pa",
    serumAsks: "6NZf4f6dxxv83Bdfiyf1R1vMFo5QP8BLB862qrVkmhuS",
    serumEventQueue: "7RbmehbSunJLpg7N6kaCX5SenR1N79xHN8jKnuvXoEHC",
    serumCoinVaultAccount: "EqnX836tGG4PYSBPgzzQecbTP47AZQRVfcy4RqQW8F3D",
    serumPcVaultAccount: "7yiA6p6BXxZwcm38St3vTzyGNEmZjw8x7Ko2nyTfvVx3",
    serumVaultSigner: "9aZNHmGZrNnB3fKmBj5B9oD7moA1nFviZqNUSkx2tctg",
    official: true
  },
  {
    name: "renDOGE-USDC",
    coin: { ...TOKENS.renDOGE },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["renDOGE-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "34oD4akb2DeNcCw1smKHPsD3iqQQQWmNy3cY81nz7HP8",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "92QStSTSQHYFg2ZxJjxWETwiS3zYsKnJm9BznJ8JDvrh",
    ammTargetOrders: "EHjwgEneTm6DZWGbictuSxf7NfcirEjyYdzYaSyNkhT1",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "EgNtpEoLCiSJx8TtVLWUBpXhUWmqzBrymgweihtmnd83",
    poolPcTokenAccount: "HZHCa82ezeYegyQWtsWW3vznpoiRaa3ewtxYvm5X6tTz",
    poolWithdrawQueue: "FbWCd9uQfAD5M62Pyceff5S2WFeN9Z5rL6azysGdhais",
    poolTempLpTokenAccount: "H12qWVeehVN6CQGfwCnSH2LxcHJ9we33U6gPmiViueu5",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "5FpKCWYXgHWZ9CdDMHjwxAfqxJLdw2PRXuAmtECkzADk",
    serumBids: "EdXd7dZLfkjz4k38VoP8d8ij7UJdrnZ3EoR9RHr5ThqX",
    serumAsks: "DuGkNca9NtZByzAxQsbt5yPFNF8pyv2PqB2sjSbBGEWi",
    serumEventQueue: "AeRsgcjxerNiMK1wpPyt7TSkH9Ps1mTr9Ac1bbWvYhdp",
    serumCoinVaultAccount: "5UbUbaVLXnZq1eibQSUxdsk6Lp38bgdTjbjQPssXGgwW",
    serumPcVaultAccount: "4KMsmK7gPdKMAKmEcHqtBB5EhNnWVRd71v3a5uBwhQ2T",
    serumVaultSigner: "Gwe1pE3rV4LLviNZqrEFPAeLchwvHrftBUQsnJtEkpSa",
    official: true
  },
  {
    name: "RAY-USDC",
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["RAY-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "6UmmUiYoBjSrhakAobJw8BvkmJtDVxaeBtbt7rxWo1mg",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "J8u8nTHYtvudyqwLrXZboziN95LpaHFHpd97Jm5vtbkW",
    ammTargetOrders: "3cji8XW5uhtsA757vELVFAeJpskyHwbnTSceMFY5GjVT",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "FdmKUE4UMiJYFK5ogCngHzShuVKrFXBamPWcewDr31th",
    poolPcTokenAccount: "Eqrhxd7bDUCH3MepKmdVkgwazXRzY6iHhEoBpY7yAohk",
    poolWithdrawQueue: "ERiPLHrxvjsoMuaWDWSTLdCMzRkQSo8SkLBLYEmSokyr",
    poolTempLpTokenAccount: "D1V5GMf3N26owUFcbz2qR5N4G81qPKQvS2Vc4SM73XGB",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "2xiv8A5xrJ7RnGdxXB42uFEkYHJjszEhaJyKKt4WaLep",
    serumBids: "Hf84mYadE1VqSvVWAvCWc9wqLXak4RwXiPb4A91EAUn5",
    serumAsks: "DC1HsWWRCXVg3wk2NndS5LTbce3axwUwUZH1RgnV4oDN",
    serumEventQueue: "H9dZt8kvz1Fe5FyRisb77KcYTaN8LEbuVAfJSnAaEABz",
    serumCoinVaultAccount: "GGcdamvNDYFhAXr93DWyJ8QmwawUHLCyRqWL3KngtLRa",
    serumPcVaultAccount: "22jHt5WmosAykp3LPGSAKgY45p7VGh4DFWSwp21SWBVe",
    serumVaultSigner: "FmhXe9uG6zun49p222xt3nG1rBAkWvzVz7dxERQ6ouGw",
    official: true
  },
  {
    name: "RAY-SRM",
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.SRM },
    lp: { ...LP_TOKENS["RAY-SRM-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "GaqgfieVmnmY4ZsZHHA6L5RSVzCGL3sKx4UgHBaYNy8m",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "7XWbMpdyGM5Aesaedh6V653wPYpEswA864sBvodGgWDp",
    ammTargetOrders: "9u8bbHv7DnEbVRXmptz3LxrJsryY1xHqGvXLpgm9s5Ng",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "3FqQ8p72N85USJStyttaohu1EBsTsEZQ9tVqwcPWcuSz",
    poolPcTokenAccount: "384kWWf2Km56EReGvmtCKVo1BBmmt2SwiEizjhwpCmrN",
    poolWithdrawQueue: "58z15NsT3JJyfywFbdYzn2GVeDDC444WHyUrssZ5tCm7",
    poolTempLpTokenAccount: "8jqpuijsM2ne5dkwLyjQxa9oCbYEjM6bE1uBaFXmC3TE",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "Cm4MmknScg7qbKqytb1mM92xgDxv3TNXos4tKbBqTDy7",
    serumBids: "G65a5G6xHpc9zV8tGhVSKJtz7AcAJ8Q3hbMqnDJQgMkz",
    serumAsks: "7bKEjcZEqVAWsiRGDnxXvTnNwhZLt2SH6cHi5hpcg5de",
    serumEventQueue: "4afBYfMNsNpLQxFFt72atZsSF4erfU28XvugpX6ugvr1",
    serumCoinVaultAccount: "5QDTh4Bpz4wruWMfayMSjUxRgDvMzvS2ifkarhYtjS1B",
    serumPcVaultAccount: "76CofnHCvo5wEKtxNWfLa2jLDz4quwwSHFMne6BWWqx",
    serumVaultSigner: "AorjCaSV1L6NGcaFZXEyUrmbSqY3GdB3YXbQnrh85v6F",
    official: true
  },
  {
    name: "RAY-ETH",
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.ETH },
    lp: { ...LP_TOKENS["RAY-ETH-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "8iQFhWyceGREsWnLM8NkG9GC8DvZunGZyMzuyUScgkMK",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "7iztHknuo7FAXVrrpAjsHBEEjRTaNH4b3hecVApQnSwN",
    ammTargetOrders: "JChSqhn6yyEWqD95t8UR5DaZZtEZ1RGGjdwgMc8S6UUt",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "G3Szi8fUqxfZjZoNx17kQbxeMTyXt2ieRvju4f3eJt9j",
    poolPcTokenAccount: "7MgaPPNa7ySdu5XV7ik29Xoav4qcDk4wznXZ2Muq9MnT",
    poolWithdrawQueue: "C9aijsE3tLbVyYaXXHi45qneDL5jfyN8befuJh8zzpou",
    poolTempLpTokenAccount: "3CDnyBsNnexdvfvo6ASde5Q4e72jzMQFHRRkSQr49vEG",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "6jx6aoNFbmorwyncVP5V5ESKfuFc9oUYebob1iF6tgN4",
    serumBids: "Hdvh4ZGL9MkiQApNqfZtdmd4jM6Sz8e9akCUuxxkYhb8",
    serumAsks: "7vWmTv9Mh8XbAxcduEqed2dLtro4N7hFroqch6mMxYKM",
    serumEventQueue: "EgcugBBSwM2FxqLQx5S6zAiU9x9qRS8qMVRMDFFU4Zty",
    serumCoinVaultAccount: "EVVtYo4AeCbmn2dYS1UnhtfjpzCXCcN26G1HmuHwMo7w",
    serumPcVaultAccount: "6ZT6KwvjLnJLpFdVfiRD9ifVUo4gv4MUie7VvPTuk69v",
    serumVaultSigner: "HXbRDLcX2FyqWJY95apnsTgBoRHyp7SWYXcMYod6EBrQ",
    official: true
  },
  {
    name: "RAY-SOL",
    coin: { ...TOKENS.RAY },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["RAY-SOL-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "AVs9TA4nWDzfPJE9gGVNJMVhcQy3V9PGazuz33BfG2RA",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "6Su6Ea97dBxecd5W92KcVvv6SzCurE2BXGgFe9LNGMpE",
    ammTargetOrders: "5hATcCfvhVwAjNExvrg8rRkXmYyksHhVajWLa46iRsmE",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "Em6rHi68trYgBFyJ5261A2nhwuQWfLcirgzZZYoRcrkX",
    poolPcTokenAccount: "3mEFzHsJyu2Cpjrz6zPmTzP7uoLFj9SbbecGVzzkL1mJ",
    poolWithdrawQueue: "FSHqX232PHE4ev9Dpdzrg9h2Tn1byChnX4tuoPUyjjdV",
    poolTempLpTokenAccount: "87CCkBfthmyqwPuCDwFmyqKWJfjYqPFhm5btkNyoALYZ",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "C6tp2RVZnxBPFbnAsfTjis8BN9tycESAT4SgDQgbbrsA",
    serumBids: "C1nEbACFaHMUiKAUsXVYPWZsuxunJeBkqXHPFr8QgSj9",
    serumAsks: "4DNBdnTw6wmrK4NmdSTTxs1kEz47yjqLGuoqsMeHvkMF",
    serumEventQueue: "4HGvdannxvmAhszVVig9auH6HsqVH17qoavDiNcnm9nj",
    serumCoinVaultAccount: "6U6U59zmFWrPSzm9sLX7kVkaK78Kz7XJYkrhP1DjF3uF",
    serumPcVaultAccount: "4YEx21yeUAZxUL9Fs7YU9Gm3u45GWoPFs8vcJiHga2eQ",
    serumVaultSigner: "7SdieGqwPJo5rMmSQM9JmntSEMoimM4dQn7NkGbNFcrd",
    official: true
  },
  {
    name: "DXL-USDC",
    coin: { ...TOKENS.DXL },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["DXL-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "asdEJnE7osjgnSyQkSZJ3e5YezbmXuDQPiyeyiBxoUm",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "4zuyAKT81y9mSSrjq8sN872zwgcD5ncQGyCXwRJDn6tC",
    ammTargetOrders: "H2GMj87upPeBQT3ywzqudJodwyTFpPmwuwtiZ7DQB8Md",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "FHAqAqqdyZFaxUTCg19hH9pRfKKChwNekFrY428NVPtT",
    poolPcTokenAccount: "7jzwUCSq1R1QX72PKRDjZ4xgUm6Q6iiLW9BY8tnj8wkc",
    poolWithdrawQueue: "3WBnh4HbddG6sMvv6s1GALVLPq6xfwVat3WqufZKKFXa",
    poolTempLpTokenAccount: "9DRSmvcrXC7AtNrhf9tgfBuwT4q5hXyWaAybe5yfRU7q",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "DYfigimKWc5VhavR4moPBibx9sMcWYVSjVdWvPztBPTa",
    serumBids: "2Z6Do29oGtze6dnVMXAVw8mkRxFpLGc8uS2RjfrWoCyy",
    serumAsks: "FosLnuNKUKqfqYviAPdp1doC3dKpXQXvAeRGM5xAoUCJ",
    serumEventQueue: "EW5QgqGUZ7dSmXLXiuWB8AAsjSjpb8kaaoxAUqK1DWyg",
    serumCoinVaultAccount: "9ZaKDVrjCaPRZTqnuteGc8iBmJhdaGVf8JV2HBT67wbX",
    serumPcVaultAccount: "5Y65XyuJemmRU7G1AQQTvWKSge8WDVYhb2knd7htJHoh",
    serumVaultSigner: "y6FHXgMwWvvpoiox6Ut6mUAUHgbJMXNJnXQm7MQkEdE",
    official: true
  },
  {
    name: "LIKE-USDC",
    coin: { ...TOKENS.LIKE },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["LIKE-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "GmaDNMWsTYWjaXVBjJTHNmCWAKU6cn5hhtWWYEZt4odo",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "Crn5beRFeyj4Xw13E2wdJ9YkkLLEZzKYmtTV4LFDx3MN",
    ammTargetOrders: "7XjS6MrvBRi9JeFWBMAYPaKhKgR3b7xnVdYDBkFb4CXR",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "8LoHX6f6bMdQVs4mThoH2KwX2dQDSkqVFADi4ZjDQv9T",
    poolPcTokenAccount: "2Fwm8M8vuPXEXxvKz98VdawDxsK9W8uRuJyJhvtRdhid",
    poolWithdrawQueue: "CW9zJ2JbBekkdd5SdvPapPcbziR8d1UHBzW7nNn1W3ga",
    poolTempLpTokenAccount: "FVHsnC1nhwMcrAzFwcK4dgUtDdYFM1VrTJ8Rp8Mb1LkY",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "3WptgZZu34aiDrLMUiPntTYZGNZ72yT1yxHYxSdbTArX",
    serumBids: "GzHpnQSfS7KdqLKgiEEP7pkYnwEBz9zaE7De2CjmCrNV",
    serumAsks: "FpEBAT9qP1so4ASUTiEWxyXH2SJvgoBYUiZ1AbPimcS7",
    serumEventQueue: "CUMDMV9KtE22RUZECUNHxiq7FmUiRusyKa1rHUJfRptq",
    serumCoinVaultAccount: "Dd9F1fugQj2xtduyNvFS5TtxP9vKnuxVMcrPsHFnLyqp",
    serumPcVaultAccount: "BnXXu8kLUXrwg3MpcVRVPLZw9bpX2mLd95qtCMnSUtu7",
    serumVaultSigner: "MKCHeoqNGWU8TJBkdF1M76nMUteJCwuBRUJfCtR3iV7",
    official: true
  },
  {
    name: "mSOL-USDC",
    coin: { ...TOKENS.mSOL },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["mSOL-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "ZfvDXXUhZDzDVsapffUyXHj9ByCoPjP4thL6YXcZ9ix",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "4zoatXFjMSirW2niUNhekxqeEZujjC1oioKCEJQMLeWF",
    ammTargetOrders: "Kq9Vgb8ntBzZy5doEER2p4Zpt8SqW2GqJgY5BgWRjDn",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "8JUjWjAyXTMB4ZXcV7nk3p6Gg1fWAAoSck7xekuyADKL",
    poolPcTokenAccount: "DaXyxj42ZDrp3mjrL9pYjPNyBp5P8A2f37am4Kd4EyrK",
    poolWithdrawQueue: "CfjpUvQAoU4hadb9nReTCAqBFFP7MpJyBW97ezbiWgsQ",
    poolTempLpTokenAccount: "3EdqPYv3hLJFXC3U9LH7yA7HX6Z7gRxT7vGQQJrxScDH",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "6oGsL2puUgySccKzn9XA9afqF217LfxP5ocq4B3LWsjy",
    serumBids: "8qyWhEcpuvEsdCmY1kvEnkTfgGeWHmi73Mta5jgWDTuT",
    serumAsks: "PPnJy6No31U45SVSjWTr45R8Q73X6bNHfxdFqr2vMq3",
    serumEventQueue: "BC8Tdzz7rwvuYkJWKnPnyguva27PQP5DTxosHVQrEzg9",
    serumCoinVaultAccount: "2y3BtF5oRBpLwdoaGjLkfmT3FY3YbZCKPbA9zvvx8Pz7",
    serumPcVaultAccount: "6w5hF2hceQRZbaxjPJutiWSPAFWDkp3YbY2Aq3RpCSKe",
    serumVaultSigner: "9dEVMESKXcMQNndoPc5ji9iTeDJ9GfToboy8prkZeT96",
    official: true
  },
  {
    name: "mSOL-SOL",
    coin: { ...TOKENS.mSOL },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["mSOL-SOL-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "EGyhb2uLAsRUbRx9dNFBjMVYnFaASWMvD6RE1aEf2LxL",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "6c1u1cNEELKPmuH352WPNNEPdfTyVPHsei39DUPemC42",
    ammTargetOrders: "CLuMpSesLPqdxewQTxfiLdifQfDfRsxkFhPgiChmdGfk",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "85SxT7AdDQvJg6pZLoDf7vPiuXLj5UYZLVVNWD1NjnFK",
    poolPcTokenAccount: "BtGUR6y7uwJ6UGXNMcY3gCLm7dM3WaBdmgtKVgGnE1TJ",
    poolWithdrawQueue: "7vvoHxA6di9EvzJKL6bmojbZnH3YaRXu2LitufrQhM21",
    poolTempLpTokenAccount: "ACn8TZ27fQ85kgdPKUfkETB4dS5JPFoq53z7uCgtHDai",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "5cLrMai1DsLRYc1Nio9qMTicsWtvzjzZfJPXyAoF4t1Z",
    serumBids: "JAABQk3n6S8W85LC6RpqTvGgP9wJFb8kfqir6kUhBXkQ",
    serumAsks: "psFs3Dm7quZZn3BhvrT1LdWCVtbMqxXanU7ZYdHULj6",
    serumEventQueue: "4bmSJJCrx3dehFQ8kXAE1c4L9kfP8DyHow4tFw6aRJZe",
    serumCoinVaultAccount: "2qmHPJn3URkrboLiJkQ5tBB4bmYWdb6MyhQzZ6ms7wf9",
    serumPcVaultAccount: "A6eEM36Vpyti2PoHK8h8Dqk5zu7YTaSRTQb7XXL8tcrV",
    serumVaultSigner: "EHMK3DdPiPBd9aBjeRU4aZjD7z568rmwHCSAAxRooPq6",
    official: true
  },
  {
    name: "MER-PAI",
    coin: { ...TOKENS.MER },
    pc: { ...TOKENS.PAI },
    lp: { ...LP_TOKENS["MER-PAI-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "6GUF8Qb5FWmifzYpRdKomFNbSQAsLShhT45GbTGg34VJ",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "Gh3w9pfjwbZX2FVrMy6PzUQG5rhihKduGCB7UaPGUTZw",
    ammTargetOrders: "37k5Xe8Sej1TrjrGsR2HyRR1EjYECV1HcS3Xh6Jnxggi",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "ApnMY7ahxTMssU1dzxYEfMcag1aSa5s4Axje3nqnnrXH",
    poolPcTokenAccount: "BuQxGhmS82ZhczEGbUyi9R7TjxczXTMRoD4nQ4GvqxCf",
    poolWithdrawQueue: "CrvN8Zi4c6BHVFc3mAB8CZSZRftY73WtpBH2Zade9MKZ",
    poolTempLpTokenAccount: "5W9V96yUqk95zUYawoCfEittj4VT4Nbv8NVjevJ4kN78",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "FtxAV7xEo6DLtTszffjZrqXknAE4wpTSfN6fBHW4iZpE",
    serumBids: "Hi6bo1sodi7X2GrpeVpk5mKKG42Ga8n4Gi3Fxr2WK6rg",
    serumAsks: "75a4ASjShTXZPdxNzm4RoSEVydLBFfDa1V81Wcf7Xw59",
    serumEventQueue: "7WDqc3MAApvgDskQBDKVVPmya3Src228sAk8Lag8ovph",
    serumCoinVaultAccount: "2Duueu4HUnv6e4qUqdM4DKECM9X3XggBsXp5eLYuSLXe",
    serumPcVaultAccount: "3GEqHH6VAnyqrgG9jRB4Qy9PMTYJmSBvg7u3LtBWHEWD",
    serumVaultSigner: "7cBPvLMQvf1X5rzLMNKrx7TY5M186rTR49yJNHNSp81s",
    official: true
  },
  {
    name: "PORT-USDC",
    coin: { ...TOKENS.PORT },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["PORT-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "6nJes56KF999Q8VtQTrgWEHJGAfGMuJktGb8x2uWff2u",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "ENfqr7WFKJy9VRwfDkgL4HvMM6GU7pHyowzZsZwx8P39",
    ammTargetOrders: "9wjp6tFY1XNH6KhdCHeDgeUsNLVjTwxA3iC9k5aun2NW",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "GGurDvQctUDgcegSYZetkNGytcWEfLes6yXzYruhLuLP",
    poolPcTokenAccount: "3FmHEQRHaKMS4vA41eYTVmfxX9ErxdAScS2tvgWvNHSz",
    poolWithdrawQueue: "ETie1oDMcoTD8jzrseAcvTqZYyyoWxR92LH15nA6Lfub",
    poolTempLpTokenAccount: "GEJfHTwURq89KcM1RgvFZRweb4f7H8NAsmyMg2kTPBEs",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "8x8jf7ikJwgP9UthadtiGFgfFuyyyYPHL3obJAuxFWko",
    serumBids: "9Y24T3co7Cc7cGbG2mFc9n3LQonAWgtayqfLz3p28JPa",
    serumAsks: "8uQcJBapCnxy3tNEB8tfmssUvqYWvuCsSHYtdNFbFFjm",
    serumEventQueue: "8ptDxtRLWXAKYQYRoRXpKmrJje31p8dsDsxeZHEksqtV",
    serumCoinVaultAccount: "8rNKJFsd9yuGx7xTTm9sb23JLJuWJ29zTSTznGFpUBZB",
    serumPcVaultAccount: "5Vs1UWLxZHHRW6yRYEEK3vpzE5HbQ8BFm27PnAaDjqgb",
    serumVaultSigner: "63ZaXnSj7SxWLFEcjmK79fyGokJxhR3UEXomN7q7Po25",
    official: true
  },
  {
    name: "MNGO-USDC",
    coin: { ...TOKENS.MNGO },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["MNGO-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "34tFULRrRwh4bMcBLPtJaNqqe5pVgGZACi5sR8Xz95KC",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "58G7RrYRntVvVj9rVgDwGhAJoWhMWHNyDCoMydYUwSR6",
    ammTargetOrders: "2qBcjDqDywhB7Kgb1VYq8K5svJh37BB8oC5kBE4VqA7q",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "91fMidHL8Yr8KRcu4Zu2RPRRg1FbXxZ7DV43rAyKRLjn",
    poolPcTokenAccount: "93oFfbcayY2WkcR6d9AyqPcRC121dXmWarFJkwPErRRE",
    poolWithdrawQueue: "FhnSdMoRPj75bLs6yzaDPFfiuucUZhVDiyM78WEhaKJo",
    poolTempLpTokenAccount: "FZAwAb6UxNiwDTbQZ3bPKYA4PkbYpurh8YpAH8G424Lv",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "3d4rzwpy9iGdCZvgxcu7B1YocYffVLsQXPXkBZKt2zLc",
    serumBids: "3nAdH9wTEhPoW4e2s8K2cXfn4jZH8FBCkUqtzWpsZaGb",
    serumAsks: "HxbWm3iabHEFeHG9LVGYycTwn7aJVYYHbpQyhZhAYnfn",
    serumEventQueue: "H1VVmwbM96BiBJq46zubSBm6VBhfM2FUhLVUqKGh1ee9",
    serumCoinVaultAccount: "7Ex7id4G37HynuiCAv5hTYM4BnPB9y4NU85QcaNWZy3G",
    serumPcVaultAccount: "9UB1NhGeDuV1apHdtK5LeAEjP7kZFH8vVYGdh2yGFRi8",
    serumVaultSigner: "BFkxdUwW17eANhfs1xNmBqEcegb4EStQxVb5VaMS2dq6",
    official: true
  },
  {
    name: "ATLAS-USDC",
    coin: { ...TOKENS.ATLAS },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["ATLAS-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "2bnZ1edbvK3CK3LTNZ5jH9anvXYCmzPR4W2HQ6Ngsv5K",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "EzYB1U93e8E1KGJdUzmnwgNBFMP9E1XAuyosmiPGLAvD",
    ammTargetOrders: "DVxJDo3E9zfGgvSkC2DYS5fsv5AyXA7gXpcs1fHFrP3y",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "FpFV46UVvRtcrRvYtKYgJpJtP1tZkvssjhrLUfoj8Cvo",
    poolPcTokenAccount: "GzwX68f1ZF4dKnAJ58RdET8sPvvnYktbDEHmjoGw7Umk",
    poolWithdrawQueue: "26SuCukyzbYo5kzeufaSoMjRPStAwqfVzTXb4QGynTit",
    poolTempLpTokenAccount: "HcoA8ucDBjEUVMjvURaS9CZgdEUbq8jRieGabq48mCL8",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "Di66GTLsV64JgCCYGVcY21RZ173BHkjJVgPyezNN7P1K",
    serumBids: "2UabAccF1AFPcNqv9D46JgyGnErnaYAJuCwyaT5dCkHc",
    serumAsks: "9umNLTbks7S51TEB8XF4jeCxwyq3qmdHrFDMFB8cT1gv",
    serumEventQueue: "EYU32k5waRUxF521k2KFSuhEj11HQvg4MbQ9tFXuixLi",
    serumCoinVaultAccount: "22a8dDQwHmmnW4M4WuSXHC9NdQAufZ2V8at3EtPzBqFj",
    serumPcVaultAccount: "5Wu76Qx7EoiR79zVVV49cZDYZ5csZaKFiHKYtCjF9FNU",
    serumVaultSigner: "FiyZW6n5VE64Yubn2PUFAxbmB2FZXhYce74LzJUhqSZg",
    official: true
  },
  {
    name: "POLIS-USDC",
    coin: { ...TOKENS.POLIS },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["POLIS-USDC-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "9xyCzsHi1wUWva7t5Z8eAvZDRmUCVhRrbaFfm3VbU4Mf",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "12A4SGay36i2cSwA4JSdvg7rWSmCz8JzhsoDqMM8Yns7",
    ammTargetOrders: "6bszsB6zxw2YowrEm26XYhh57HKQEVMRx5YMvPSSVQNh",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "7HgvC7GdmUt7kMivdLMovLStW25avFsW9GDXgNr525Uy",
    poolPcTokenAccount: "9FknRLGpWBqYg7fXQaBDyWWdu1v2RwUM6zRV6CiPjWBD",
    poolWithdrawQueue: "6uN62R1i31QVoy9cmQAeDrfLccMZDjQ2gmwv2D4iBTJT",
    poolTempLpTokenAccount: "FJV66MrqZW8VYGmTuAupstwYtqfF6ULLPP9voYtnc8DS",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HxFLKUAmAMLz1jtT3hbvCMELwH5H9tpM2QugP8sKyfhW",
    serumBids: "Bc5wovapX1tRjZfyZVpsGH73Gq5LGN4ANsj8kaEhfY7c",
    serumAsks: "4EHg2ANFFEKLFkpLxgiyinJ1UDWsG2p8rVoAjFfjMDKc",
    serumEventQueue: "qeQC4u5vpo5QMC17V5UMkQfK67vu3DHtBYVT1hFSGCK",
    serumCoinVaultAccount: "5XQ7xYE3ujVA21HGbvFGVG4pLgqVHSfR9anz2EfmZ3nA",
    serumPcVaultAccount: "ArUDWPwzGQFfa7t7nSdkp1Dj6tYA3icXEq8K7goz9WoG",
    serumVaultSigner: "FHX9fPAUVA1MxPme28f4eeVH81QVRHDWofa2V6FUJaiR",
    official: true
  },
  {
    name: "ATLAS-RAY",
    coin: { ...TOKENS.ATLAS },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["ATLAS-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "F73euqPynBwrgcZn3fNSEneSnYasDQohPM5aZazW9hp2",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "2CbuxnkjsBvaQoAubc5MAmbeZSMn36z8sZnfMvZWH1vb",
    ammTargetOrders: "6GZrucFa9hAQW7yHiPt3oZj9GkL6oBipngyY1Hw3zMx",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "33UaaUmmySzxK7q3yhmQiXMrW1tQrwqojyD6ZEFgM6FZ",
    poolPcTokenAccount: "9SYRTwYE5UV2cxEuRz8iiJcV8gMbMnJUYFC8zgDAsUwB",
    poolWithdrawQueue: "6bznLHPLPA3axnRfjh3sFzkxeMUQDLWhDuaHzjGL1EE6",
    poolTempLpTokenAccount: "FnmoaJqFYHotLTG2Ur84jSUmVUACVWrBvBvRHdPzhqvb",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "Bn7n597jMxU4KjBPUo3QwJhbqr5145cHy31p6EPwPHwL",
    serumBids: "9zAgdk4Na8fBKLiTWzsqZwgYQETuHBDjPe2GYqHy17L",
    serumAsks: "Fv6MY3w7PP7A54cuPQHevQNuwekGy8yksXWioBsyVd42",
    serumEventQueue: "75iVJf9QKovBdsvgxcCFfwn2N4QyxEXyKxQdBvZTdzjr",
    serumCoinVaultAccount: "9tBagdm862GCoxZNFvXv7HFjLUFmypxPYxfiT3j9S3h3",
    serumPcVaultAccount: "4oc1kGhKByyxRnh3oXupjTn5P6JwWPnoxwvLxjZzi2vE",
    serumVaultSigner: "EK2TjcyoXzUweNJnJupQf6sZK8756mvBJeGBvi6y18Cq",
    official: true
  },
  {
    name: "POLIS-RAY",
    coin: { ...TOKENS.POLIS },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["POLIS-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "5tho4By9RsqTF1rbm9Akiepik3kZBT7ffUzGg8bL1mD",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "UBa61sKev8gr19nqVyN3BZbW2jG7eAGjbjeZvpU4wu8",
    ammTargetOrders: "FgMtC8pDrSQJUovmnrDiRWgLGVrVSq9kui98re6uRz5i",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "Ah9T12tzwnTXWrWVWzLmCrwCEmVHS7HMdWKG4qLUDzJP",
    poolPcTokenAccount: "J7kjQkrpafcLjL7cCpmMamxLAFnCkGApLTC2QrbHe2NQ",
    poolWithdrawQueue: "EgZgi8skDug7YecbFuCFxXx3SPFPhbGSVrGiNzLHErkj",
    poolTempLpTokenAccount: "TYw7qQDt6sqpwUFSRfNBaLHEA1SUxbEWtmZxtZQhojk",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "3UP5PuGN6db7NhWf4Q76FLnR4AguVFN14GvgDbDj1u7h",
    serumBids: "4tAuffNhWeF2MDWjMDgrRoR8X8Jg3BLvUAaerXzLsFpG",
    serumAsks: "9W133475h1LZ2ZzY7aJtbJajLDSCn5hNnKcsu6gXgE2G",
    serumEventQueue: "5DX4tJ8jZt91XzM7JUUPhu6CL4o6UDGnfjLJZtkmEfVT",
    serumCoinVaultAccount: "pLD9GMk4LACBXDJAWJSgbT1batbHgunBVyy8BaVBazG",
    serumPcVaultAccount: "Ah3JVyTAGLbH63XPWDDnJUwV1xYwHhFX2J81CDHomkLk",
    serumVaultSigner: "5RqVkFy8hUbYDR81ucZhF6rAwpgYJngLJLSynMTeC4vM",
    official: true
  },
  {
    name: "ALEPH-RAY",
    coin: { ...TOKENS.ALEPH },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["ALEPH-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "8Fr3wxZXLtiSozqms5nF4XXGHNSNqcMC6K6MvRqEfk4a",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "GrTQQTca8U7QpNiThwHfiQuFVihvSkkNPchhkKr7PMy",
    ammTargetOrders: "7WCvFBFN3fjU5hKJjPF2rHLAyXfzGCEqJ8qbqKLBaGTv",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "4WzdFwdKaXLQdFn9i84asMxdr6Fmhmh3qd6uC2xjBXwd",
    poolPcTokenAccount: "yFWn8ji7zq24UDg1mMqP1mA3vWyUdkjARQUPZCS5iCf",
    poolWithdrawQueue: "J9QSrJtasvLydL5dgbfv55eqBoADM9z91kVi5hpxk36Y",
    poolTempLpTokenAccount: "fGohyeWwAGqGdjQsHrE4c6GoTC1xHmyiAxJsgz2uZZ9",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "4qATPNrEGqE4yFJhXXWtppzJj5evmUaZ5LJspjL6TRoU",
    serumBids: "84wPUTporXrCAceD753fXdiysry7WNkpiJH5HwhV5PwC",
    serumAsks: "BDcmopZQkPoxkk1BLAeh4zR3oWeDFUXTkrD2fJgh8xYu",
    serumEventQueue: "4PiUj2EFVq8YNjMd8zWCUe7dV2prLEJCucapjzTeiShv",
    serumCoinVaultAccount: "7dCAQbfwtDFtLwNgoB2WahCubPhFjZRGjfVYJajcF6qJ",
    serumPcVaultAccount: "2DsQ33R4GqqBkmxPdFyBy7WYAzyWYm6BNPqKtENAKXuY",
    serumVaultSigner: "DDyP6zj3GTK3hTRyjPuaEL9yyqgfdstRMMKCkn939pkp",
    official: true
  },
  {
    name: "TULIP-RAY",
    coin: { ...TOKENS.TULIP },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["TULIP-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "Dm1Q15216uRARmQTbo6VfnyEGVzRvLTm4TfCWWX4MF3F",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "2x6JvLToztTWoiYAXFvLw9R8Ump3aDcuiRPBY9ZuzoRL",
    ammTargetOrders: "GZzyFjERxn9CqS5jXq1o2J3zmSNmhPMzn7U4aMJ82wL",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "96VnEN3nhvyb6hLSyP6BGsvSFdTJycQtTr574Kavrje8",
    poolPcTokenAccount: "FhnZ1j8C8d7aXecxQXEGpRycoH6uJ1Fpncj4Sm33J2iS",
    poolWithdrawQueue: "ELX79G4JU2YQrykozCvaRnhU2dBFmxNpSrJD3BoRoxfE",
    poolTempLpTokenAccount: "BagZFcJSYZzQn3iS37sPFDPiaKsfUwo8YD98XsEMKrsd",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "GXde1EjpxVV5fzhHJcZqdLmsA3zmaChGFstZMjWsgKW7",
    serumBids: "2ty8Nq6brwkp74n6EtJkD8msgBnc3fRiavNGrE5d7yE3",
    serumAsks: "GzztpwBixtLW1vqZwtNZH7FvyGJcRmLvCZTffCW2ZoS2",
    serumEventQueue: "4EgxxtAL5zsc1GCR243EU2vpbYpSvsawyfznVuRYbGHm",
    serumCoinVaultAccount: "JD1MfYD2SXiY1j6p3H6DifpG6RAe8cAtmNNLdRAdB1aT",
    serumPcVaultAccount: "UtkM2zbygo9tig18DQJDdRjHSKQiMf5uSuDTR2kf7ov",
    serumVaultSigner: "3yRCDVhumspJgYJnNhyJaXTjRn5jiMqdbQ13rTyHHQgQ",
    official: true
  },
  {
    name: "SLRS-RAY",
    coin: { ...TOKENS.SLRS },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["SLRS-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "J3CoGcJqHquUdSgS7qAwdGbp3so4EpLX8eVDdGuauvi",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "FhtXN2pPZ8JMxGcLKSfRJtGsorSCXBKJyw3n7SsEc1aR",
    ammTargetOrders: "2hdnnbsAu7pCf6nX5fDKPAdThLZmmWFQ7Kcq2cdShPGW",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "8QWf745UQeyMyM1qAAsCeb73jTvQvpm2diVgjNvHgbVX",
    poolPcTokenAccount: "5TsxBaazJ7Zdx4x4Zd2zC7TY98EVSwGY7hnioS2omkx1",
    poolWithdrawQueue: "6w9z1TGNkMU2qBHj5wzfaoqCLn7cPLKvPa23qeffsn9U",
    poolTempLpTokenAccount: "39VEjufVUfdASteaQstBT25zQuLUha8ZrqYQfcDdJ47A",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "BkJVRQZ7PjfwevMKsyjjpGZ4j6sBu9j5QTUmKuTLZNrq",
    serumBids: "8KouZyh14hmqurZZd1YRpwZ9pMVkWWHPnKTsETSYUuQQ",
    serumAsks: "NBpY6i9KbWx2V5sS3iP54KYYaHg8aVB6WB43ibVFUPo",
    serumEventQueue: "BMZfHb6CkiYwdgfVkAiiy4SWf6PHuRPFZyZWQNw1uDZx",
    serumCoinVaultAccount: "F71huJuAGZ8Q9xVxQueLQ8vDQD6Nq8MkJJsyM2S937sy",
    serumPcVaultAccount: "AbmAd3LgTowBANXnCNPLctxL7PReirJv5VcizvQ3mfah",
    serumVaultSigner: "E91Pu1z4q4Nr5mGSVcwyDzzbQC3LdDBzmFyLoXfXfg17",
    official: true
  },
  {
    name: "MER-RAY",
    coin: { ...TOKENS.MER },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["MER-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "BKLCqnuk4qc5iHWuJuewMxuvsNZXuTBSUyRT5ftnRb6H",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "qDqpetCPbbV2n8bgcy4urhDcKYkUNVoEn7xaCQSDzKv",
    ammTargetOrders: "7KU9VPAZ8BMXA29gadnpssgtcoo4Tm1LYnc6Sn5HefcL",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "rmnAGzEwFnim88JLhqj66B86QLJL6cgm3tPDfGiKqZf",
    poolPcTokenAccount: "4Lm4c4NqNyobLGULtHRtgoG4hbX7ytuGQFFcdip4jvBb",
    poolWithdrawQueue: "9qwtjaEnTCHFf6GuTNxPf85hFzJVNJAAXJnWNFi4DmkX",
    poolTempLpTokenAccount: "H9uyyChWbaXCmNmQu3g4fqKF5xsa7YVZiMvGcsVrCcNn",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "75yk6hSTuX6n6PoPRxEbXapJbbXj4ynw3gKgub7vRdUf",
    serumBids: "56zkA91Mad1HBJpiq8baMi9XhvvnTRNyd6m8hzeu5arh",
    serumAsks: "BgovKK4YP6ZgLUHsnXeUym1BH5BSjUxDuinTk6shPuzd",
    serumEventQueue: "5NVyybcVeC8wqjgBj3ZxaX3RauWa2iqvdXkUYPJnistu",
    serumCoinVaultAccount: "EaFu94rusrGHjJWhuuUbKWW2AJizDGbpWJXJa4cxmLCP",
    serumPcVaultAccount: "ApZdrWpBu2uLkYAeVLneWnDhVrbR6TjhjbBR78kpg5r2",
    serumVaultSigner: "FCf82FB2TFAfH4YEDkBJtEeSkTK1EQFc27d1iSnvXMjk",
    official: true
  },
  {
    name: "MEDIA-RAY",
    coin: { ...TOKENS.MEDIA },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["MEDIA-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "5ZPBHzMr19iQjBaDgFDYGAx2bxaQ3TzWmSS7zAGrHtQJ",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "HhAqmp3r8gaKo9P1ybaEXpwjq5MfmkfD6sRVD4EYs1tU",
    ammTargetOrders: "3Dwo6BD7H2GQMyxoh5nXdmAK7dWfqPMUj3PcrJVqUuEp",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "FGskpuYNgqgHU4kHSibgqDkYCCZhxAtpQxZNqFaKfBDK",
    poolPcTokenAccount: "7AiT1Re8Z8m8eLdy5HWRqWvx6pBZMytdWQ3wL8zCrSNp",
    poolWithdrawQueue: "7reJT6i8tnFjf5vbvmRLw6ikZZxs6ZJ8bsEx4iCU22ot",
    poolTempLpTokenAccount: "6LmFCURzNyEsNpF4fgMDyGPX1xoNAnm2oVcrYJJQGv9Y",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "2STXADodK1iZhGh54g3QNrq2Ap4TMwrAzV3Ja14UXut9",
    serumBids: "FKgbQ8Sdv9d44SMrtLMy58EmP3V59fvjse2UUQ8mNCxd",
    serumAsks: "CNcZwNeBA1QVL1Kzq3n166RSvUocLrKNs4nzTGXgVPuE",
    serumEventQueue: "FwHwAcBc54zm8XjtNxvaZG1t84shzYs68z3BAsKZdoE",
    serumCoinVaultAccount: "Ea7ECm7a3ECLnvJJMpZS9QrWbYnb8LkqVvWCXtmFVzWX",
    serumPcVaultAccount: "54a18egZToocQ2yeCstCrtYZLAj3z82qfLG4Ed1quThb",
    serumVaultSigner: "F1XJJ2fkPiiYg1hWnDD6phMfDd8Sr8XwM6GKFeAZpTmr",
    official: true
  },
  {
    name: "SNY-RAY",
    coin: { ...TOKENS.SNY },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["SNY-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "Am9FpX73ctZ3HzohcRdyCCv84iT7nugevqLjY5yTSUQP",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "BFxUhqhrUWqMMazhef1dwDGXDo1LkQYV2YAgMfY81Evo",
    ammTargetOrders: "AKp1o6Nxe224Z8z4tFzyFKdCRoJDFpCen1xHyGXfyxKu",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "BjJMnG8c4zMHHZrvxP6ydKYGPkvXL5fF9gC38rtAu2Sx",
    poolPcTokenAccount: "7dwpWj95qzPoBFCL7qzgoj9zhjmNNoDyncbyJEYiRfv7",
    poolWithdrawQueue: "6g5sTJtMw1r9vx4RP5YkN3ZJpSssh7eH8QdVK986xLS2",
    poolTempLpTokenAccount: "9tHcrwFdxNNzosaTkqrejHNXkr2HasKSwczimjBh2F8Z",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HFAsygpAgFq3f9YQ932ptoEsEdBP2ELJSAK5eYAJrg4K",
    serumBids: "6A6njiM3ByNbopETpEfbqsQci3NZecTzheg2YACVFXjc",
    serumAsks: "8YvHQkUCB7HxCAu3muytUTbEXuDGmroVcnwbkXydzyEH",
    serumEventQueue: "8syFMq2kMQV9beCJ9Y5T9TARgUii6aND5MDgDEAAGF73",
    serumCoinVaultAccount: "F1LcTLXQhFf9ymAHnxFNovSdZttZiVjRBoqQxyPAEipj",
    serumPcVaultAccount: "64UEnruJCyjKUz8vdgZh3FwWwd53oSMY9Knd5dt5oVuK",
    serumVaultSigner: "3enyrrweGCtkVDvaiAkSo2d2tF7B899tWHGSDfEGKtNs",
    official: true
  },
  {
    name: "LIKE-RAY",
    coin: { ...TOKENS.LIKE },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["LIKE-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "DGSnfcE1kw4uDC6jgrsZ3s5CMfsWKN7JNjDNasHdvKfq",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "4hgUQQevH5BauWE1CGGsfsDZbnCUrjd6YsRHB2gQjRUb",
    ammTargetOrders: "AD3TRMfAuTJXTdxsvJ3E9p6YK3GyNAGDSk4DX26mtmFC",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "HXmwydLeUB7JaLWhoPFkDLazQJwUuWCBi3M28p7WfwL7",
    poolPcTokenAccount: "BDbjkVrTezpirdkk24MfXprJrAi3WXazr4L6DHT5buXi",
    poolWithdrawQueue: "FFKXu8Q3kaQjnuZsicVyUQNNBwRRLFAT86WqDN8Yz2UV",
    poolTempLpTokenAccount: "FJguakQVbJmhjVGrzakNGQo5WCm5HG1Uk23X6x75WtZz",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "E4ohEJNB86RkKoveYtQZuDX1GzbxE2xrbdjJ7EddCc5T",
    serumBids: "7vhuHsR1VxAGN4DD5EywRnW9nb7cX3VHcyrAKL1AAJ4v",
    serumAsks: "KXrJ3YVBvSGpCRETy3M2ronxM55PU8xBmQ2wCWVzhpY",
    serumEventQueue: "EMTQJ2v3dn4ndnV7UwZTiGTmSNPsVSCgdSN6w5QvCv2M",
    serumCoinVaultAccount: "EENxPU4YaXqTLBgd5jHBHigpH74MZNq9WxcLaKVsVSvq",
    serumPcVaultAccount: "5c9DtqqCvj5du96cgUCSt2GZp8sreE7uV1Defmb615na",
    serumVaultSigner: "GWnLv7RwJhceF3YNqawMyEJqg6WgZc6XtT7Bi6prjkyC",
    official: true
  },
  {
    name: "COPE-RAY",
    coin: { ...TOKENS.COPE },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["COPE-RAY-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "8hvVAhShYLPThcxrxwMNAWmgRCSjtxygj11EGHp2WHz8",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "HMwERnf6t8JTR8qnrQDDGxGL2PeBgpzzmQBJQgvXL3NS",
    ammTargetOrders: "9y7m8jaURWcehBkMt6ebgQ92mqaJzZfxW51wBv6dtGR8",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "CVCDGPwGmxHyt1HwfJgCYbskEXPTvKxZfR6nkZexFQi5",
    poolPcTokenAccount: "DyHnyEW4MQ1J28JrqvY7AdMq6Djr3TjvczgsokQxj6YB",
    poolWithdrawQueue: "PPCMh17bDnu6sZKhipEfXf4ASK4sTpHkWrEX3SBNKRV",
    poolTempLpTokenAccount: "HReYRwCxu4qEjzkyjsdf67DyEUsWn1Tqf7eisvM3J7ro",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "6y9WTFJRYoqKXQQZftFxzLdnBYStvqrDmLwTFAUarudt",
    serumBids: "Afj14X2pCvbgVzWFAXRC4XBS3B71hZFXiTpVaFEohdCe",
    serumAsks: "GmZTkEYABdUej3QXXZSf8aeZ1UxLB2WaQ4dhVihKZPB8",
    serumEventQueue: "3PveQeVGVfaa4LpTjhuRtm1Xe3Y9q7iW7YQeGJZYKtc4",
    serumCoinVaultAccount: "9mQ22KCPTyFkJ4dp16Fhpd1pFrVmonS6SMa9L8nM6nLn",
    serumPcVaultAccount: "BKGiYU9So4XMYYuYiV2d68kcR2wwLogKbi3rmg8ci4xt",
    serumVaultSigner: "k5mhBL7yqEtAQs1WtUGdMT9eLLZkjambTd1Y4MyGouf",
    official: true
  },
  {
    name: "ETH-SOL",
    coin: { ...TOKENS.ETH },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["ETH-SOL-V4"] },

    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "9Hm8QX7ZhE9uB8L2arChmmagZZBtBmnzBbpfxzkQp85D",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "GwFM8qoBwusXVbcdfreKV9q86vqdudnVtvhYfJWgtgB",
    ammTargetOrders: "FQp9HzJKEFfiDSnV6qyQNoz8cEKsWHnV3yFqWrT1ThgN",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "59STNbqDpY1sj6m95jBPRiFwjtigtivHqQeJRUofWY2a",
    poolPcTokenAccount: "HXz1MFnu9ANWfCBesnrzMZMPoFbUyyqPDKT67sqgT4rk",
    poolWithdrawQueue: "GrLKNkFVyAdV1wXoBFYxMSSPJ3BNekggiZJERrPSnAE2",
    poolTempLpTokenAccount: "AtQQZJUBrXs8nBKCHy4L2WovuEEVf7QnVWwgRdVbnKd4",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HkLEttvwk2b4QDAHzNcVtxsvBG35L1gmYY4pecF9LrFe",
    serumBids: "B38zSRMdSHYxnbsWCgY4GvSy4aRytkhqR5qVjaHsNXdA",
    serumAsks: "E4hWT9G64hLDMY7VrGXfJ5cuU8jRzJsUYAi8fqep6Sqy",
    serumEventQueue: "Bdy9encMZ7UpbEbdCgh5qDq8qQn4D31tFR45Bdas3f5y",
    serumCoinVaultAccount: "HMPki4uRhncFhMHpLAacHCDAU4QazjgFTsB8SQgh6bMY",
    serumPcVaultAccount: "BeWaZ85mTxmrYfS3J9E1jQQ5tKgDRA6qmTpksKnGeNps",
    serumVaultSigner: "GPNCigFBsjNhXu3cbmU1uxfbGVuxCA8bJN4bobwDjuTm",
    official: true
  },
  {
    name: "stSOL-USDC",
    coin: { ...TOKENS.stSOL },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["stSOL-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "6a1CsrpeZubDjEJE9s1CMVheB6HWM5d7m1cj2jkhyXhj",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "28NQqHxrqMYMQ67aWyn9AzZ1F16PYd4zvLpiiKnEZpsD",
    ammTargetOrders: "B8nmqinHQjyqAnMWNiqSzs1Jb8VbMpX5k9VUMnDp1gUA",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "DD6oh3HRCvMzqHkGeUW3za4pLgWNPJdV6aNYW3gVjXXi",
    poolPcTokenAccount: "6KR4qkJN91LGko2gdizheri8LMtCwsJrhtsQt6QPwCi5",
    poolWithdrawQueue: "5i9pTTk9x7r8fx8mJMBCEN85URVLAnkLzZXKyoutUJhU",
    poolTempLpTokenAccount: "GiuNbiBirwsBp9GuxGYgNUMMKGM6Qf6wqgnxbJFHTYFa",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "5F7LGsP1LPtaRV7vVKgxwNYX4Vf22xvuzyXjyar7jJqp",
    serumBids: "HjJSzUbis6VhBZLCbSFN1YtvWLLdxutb7WEvymCLrBJt",
    serumAsks: "9e37wf6QUqe2s4J6UUNsuv6REQkwTxd47hXhDanm1adp",
    serumEventQueue: "CQY7LwdZJrfLRZcmEzUYp34XJbxhnxgF4UXmLKqJPLCk",
    serumCoinVaultAccount: "4gqecEySZu6SEgCNhBJm7cEn2TFqCMsMNoiyski5vMTD",
    serumPcVaultAccount: "6FketuhRzyTpevhgjz4fFgd5GL9fHeBeRsq9uJvu8h9m",
    serumVaultSigner: "x1vRSsrhXkSn7xzJfu9mYP2i19SPqG1gjyj3vUWhim1",
    official: true
  },
  {
    name: "GRAPE-USDC",
    coin: { ...TOKENS.GRAPE },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["GRAPE-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,

    ammId: "vVXfY15WdPsCmLvbiP4hWWECPFeAvPTuPNq3Q4BXfhy",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "A7RFkvmDFN4Qev8XgGAqSr5W75sNhhtCY3ZcGHZiDDo1",
    ammTargetOrders: "HRiPQyFJfzF7WgC4g2cFbxuKgqn1vKVRjTCuZTNGim36",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "BKqBnj1TLpW4UEBbZn6aVoPLLBHDB6NTEL5nFNRqX7e7",
    poolPcTokenAccount: "AN7XxHrrcFL7629WySWVA2Tq9inczxkbE6YqgZ31rDnG",
    poolWithdrawQueue: "29WgH1suwTnhL4JUwDMUQQpUzypet8PHEh8jQpZtiDBK",
    poolTempLpTokenAccount: "3XCGBJpfHV5VYkz92nqzRtHahTiHXjYzVs4PargSpYwS",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "72aW3Sgp1hMTXUiCq8aJ39DX2Jr7sZgumAvdLrLuCMLe",
    serumBids: "F3PQsAGiFf8fSySjUGgP3NQdAGSnioAThncyfd26GKZ3",
    serumAsks: "6KyB4XprAw7Mgp1YMMsxRGx8T59Y5Lcu6s1FcwFrXy3i",
    serumEventQueue: "Due4ZmGX2u7an9DPMvk3uX3sXYgngRatP1XmwzEgk1tT",
    serumCoinVaultAccount: "8FMjC6yopBVYTXcYSGdFgoh6AFpwTdkJAGXxBeoV8xSq",
    serumPcVaultAccount: "5vgxuCqMn7DUt6Le6EGhdMzZjPQrtD1x4TD9zGw3mPte",
    serumVaultSigner: "FCZkJzztVTx6qKVec25jA3m4XjeGBH1iukGdDqDBHPvG",
    official: true
  },
  {
    name: "LARIX-USDC",
    coin: { ...TOKENS.LARIX },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["LARIX-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "A21ui9aYTSs3CbkscaY6irEMQx3Z59dLrRuZQTt2hJwQ",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "3eCx9tQqnPUUCgCwoF5pXJBBQSTHKsNtZ46YRzDxkMJf",
    ammTargetOrders: "rdoSiCqvxNdnzuZNUZnsXGQpwkB1jNPctiS194UtK7z",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "HUW3Nsvjad7jdexKu9PUbrq5G7XYykD9us25JnqxphTA",
    poolPcTokenAccount: "4jBvRQSz5UDRwZH8vE6zqgqm1wpvALdNYAndteSQaSih",
    poolWithdrawQueue: "Dt8fAfftoVcFicC8uHgKpWtdJHA8e4xCPeoVRCfounDy",
    poolTempLpTokenAccount: "FQ3XFCQAEjK1U235pgaB9nRPU1fkQaLjKQiWYYNzB5Fr",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "DE6EjZoMrC5a3Pbdk8eCMGEY9deeeHECuGFmEuUpXWZm",
    serumBids: "2ngvymBN8J3EmGsVyrPHhESbF8RoBBaLdA4HBAQBTcv9",
    serumAsks: "BZpcoVeBbBytjY6vRxoufiZYB3Te4iMxrpcZykvvdH6A",
    serumEventQueue: "2sZhugKekfxcfYueUNWNsyHuaYmZ2rXsKACVQHMrgFqw",
    serumCoinVaultAccount: "JDEsHM4igV84vbH3DhZKvxSTHtswcNQqVHH9RDq1ySzB",
    serumPcVaultAccount: "GKU4WhnfYXKGeYxZ3bDuBDNrBGupAnnh1Qhn91eyTcu7",
    serumVaultSigner: "4fGoqGi6jR78dU9TRdL5LvBUPjwnoUCBwxNjfFxcLaCw",
    official: true
  },
  {
    name: "RIN-USDC",
    coin: { ...TOKENS.RIN },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["RIN-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "7qZJTK5NatxQJRTxZvHi3gRu4cZZsKr8ZPzs7BA5JMTC",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "21yKxhKmJSvUWpL3doX5QwjXKXuzm3oxCG7k5Kima6hu",
    ammTargetOrders: "DaN1UZZ1ExraQi1Ghz8YS3pKaZG44PASbNiApysiRSRg",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "7NMCVudgyHKwVXA62Rv2cFrucQiNYE9b5MMvn4cVtCPW",
    poolPcTokenAccount: "4d9Q2ekDzHqX51Nu9EZHZ96PhGjLSpVosa5Nci7BbwLe",
    poolWithdrawQueue: "DjHe1Sj7fouU5gJEiFz7C4Vd5TtvApEAxWr5EVhTuEps",
    poolTempLpTokenAccount: "EpKgUgtmTL425M9ENLqbjupm5funsPdhVr37hB8hJiuy",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "7gZNLDbWE73ueAoHuAeFoSu7JqmorwCLpNTBXHtYSFTa",
    serumBids: "4mSS9iidPrVmMV9D7CNJia5zza2apmBLe3SmYW8SNPFR",
    serumAsks: "7ovw7s6Ta1EQY4PsMu1MvnHfUNyEDADacmc4Rd5m34UD",
    serumEventQueue: "2h7YS1nRQqc86jGKQLT29xnfBk9xVQrzXx9yiB21P5gK",
    serumCoinVaultAccount: "5JCpfGbNdFhXWxMFR4xefBfLEd2qxYgovEggS6wxtmQe",
    serumPcVaultAccount: "FQfVJz7STBGMheiAAuZdF8ndyvbJhJZWJvpKhFKqSqYh",
    serumVaultSigner: "DFoStusQdrMbHms9Sce3tiRwSHAnaPLEtXCaFAnrhSy3",
    official: true
  },
  {
    name: "APEX-USDC",
    coin: { ...TOKENS.APEX },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["APEX-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "43UHp4TuwQ7BYsaULN1qfpktmg7GWs9GpR8TDb8ovu9c",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "5SrvK4rUdhRAekLxYnDb552x1DzQP4F42mydUcxMMNJD",
    ammTargetOrders: "8W9P9rDx5a8C234jWLaUT7x4RGUGscXx2oCpS3eMfGUo",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "3tMBycaDewfj2trk1HP1ZSRb4YEJQs6k7nFAk4jTrRtN",
    poolPcTokenAccount: "DRDqm7rLuGnkh9RU1H2aaaJihRSU2Yg3WhropTWmcpWW",
    poolWithdrawQueue: "HA1wfa31ogn6eMY6174gNVf9LGjfjAhBdMaYtCkWBLhx",
    poolTempLpTokenAccount: "BPJ6HpvGBpQ5TUezSv3NzicANEq8Grma6QmPV1gXKnx8",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "GX26tyJyDxiFj5oaKvNB9npAHNgdoV9ZYHs5ijs5yG2U",
    serumBids: "3N3tX1CLNCsnEffqhNBkiQxo34VJBPE7dbYUWsy4M6UD",
    serumAsks: "BLCo9efr528yH73zJU47FCDKzvsJAYFGdYkPgHb8yWxJ",
    serumEventQueue: "3St3PhenFusFH1Guo7WQhNeNSfwDNpJQScDJ1EhRcLai",
    serumCoinVaultAccount: "CEGcRVzSbX5hGpsKsPX8zhTMm8N4xJSTH1VFEcWXRUmE",
    serumPcVaultAccount: "7Q1TDhNbhpN9KN3vCRk7WhPi2EaETSCkXpsTdaDppvAx",
    serumVaultSigner: "GprUwgGyqBiEC5e6ivxgpUf7uhpS17n7WRiU7HDV3VGk",
    official: true
  },
  {
    name: "mSOL-RAY",
    coin: { ...TOKENS.mSOL },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["mSOL-RAY-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "6gpZ9JkLoYvpA5cwdyPZFsDw6tkbPyyXM5FqRqHxMCny",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "HDsF9Mp9w3Pc8ZqQJw3NBvtC795NuWENPmTed1YVz5a3",
    ammTargetOrders: "68g1uhKVVLFG1Aua1BKtCx3uiwPixue1qqbKDJAc32Uo",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "BusJVbHEkJeYRpHkqCrt85d1LALS1EVcKRjqRFZtBSty",
    poolPcTokenAccount: "GM1CjxKixFkKpakxx5Lg9u3zYjXAK2Gr2pzoy1G88Td5",
    poolWithdrawQueue: "GDZx8SZSYsRKc1WfWfbqR9JaTdBEwHwAMcJuYk2rBm74",
    poolTempLpTokenAccount: "EdLjP9p2AA7zKWwRPxKx8SKFCJ9awfSxnsPgURX6HuuJ",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HVFpsSP4QsC8gFfsFWwYcdmvt3FepDRB6xdFK2pSQtMr",
    serumBids: "7ZCucutxHFwJjfUmxD1Pae8vYg9HB1WQ6DhRkueNyJqF",
    serumAsks: "6cM5rqTHhngGtifjK7pUwved3CdHKZgFj7nnP3LsP325",
    serumEventQueue: "Gucy2LXDFjWBZEFX4gyrqr6xEb2AWRf4VVgqX33ZXkWu",
    serumCoinVaultAccount: "GPksxJSxy5pEigdtSLBBZuRQEuGPJRT2ah3J1HwMeKm5",
    serumPcVaultAccount: "TACxu78UJHz2Vzg2HwGa2w9mvLw2mY5mL7Q3ho9W6J9",
    serumVaultSigner: "FD6U73ZW2YkD9R8cbDT6KSamVodYqWJBtS3ZcPeU7X29",
    official: true
  },
  {
    name: "MNDE-mSOL",
    coin: { ...TOKENS.MNDE },
    pc: { ...TOKENS.mSOL },
    lp: { ...LP_TOKENS["MNDE-mSOL-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "2kPA9XUuHUifcCYTnjSuN7ZrC3ma8EKPrtzUhC86zj3m",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "G3qeShDT2w3Y9XnJbk5TZsx1qbxkBLFmRsnNVLMnkNZb",
    ammTargetOrders: "DfMpzNeT4XHs2xtN74j5q94QfqPSJbng5BgGyyyChsVm",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "F1zwWuPfYLZfLykDYUqu43A74TUsv8mHuWL6BUrwVhL7",
    poolPcTokenAccount: "TuT7ftAgCQGsETei4Q4nMBwp2QLcDwKnixAEgFSBuao",
    poolWithdrawQueue: "5FoP78mNninxP5VbSHN3LfsBBbqMNqiucANGQungGJLV",
    poolTempLpTokenAccount: "2UbzfMCHjSERpMo9C3BAq5NUhVF9sx39ruJ1zu8Gf4Lu",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "AVxdeGgihchiKrhWne5xyUJj7bV2ohACkQFXMAtpMetx",
    serumBids: "9YBjtad6ZxR7hxNXyTjRRPnPgS7geiBMHbBp4BqHsgV2",
    serumAsks: "8UZpvreCr8bprUwstHMPb1pe5jQY82N9fJ1XLa3oKMXg",
    serumEventQueue: "3eeXmsg8byQEC6Q18NE7MSgSbnAJkxz8KNPbW2zfKyfY",
    serumCoinVaultAccount: "aj1igzDQNRg18h9yFGvNqMPBfCGGWLDvKDp2NdYh92C",
    serumPcVaultAccount: "3QjiyDAny7ZrwPohN8TecXL4jBwGWoSUe7hzTiX35Pza",
    serumVaultSigner: "6Ysd8CE6KwC7KQYpPD9Ax8B77z3bWRnHt1SVrBM8AYC9",
    official: true
  },
  {
    name: "LARIX-RAY",
    coin: { ...TOKENS.LARIX },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["LARIX-RAY-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "EBqQdu9rGe6j3WGJQSyTvDjUMWcRd6uLcxSS4TbFT31t",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "MpAAS4U2fQnQRhTc1dAZEzLuQ9G4q6qRSUKwTJbYynJ",
    ammTargetOrders: "A1w44YMFKvVXFnXYTrz7EVfSgjHdZfE67g59HdhE1Yfh",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "6Sq11euWaw2Hpd6bXMZccJLZpPcVgs3nhV7P5396jE7e",
    poolPcTokenAccount: "12iyJhJgr9AeJrL6q6jAN63zU3YgpPV98CR87c6JGoH4",
    poolWithdrawQueue: "BD3rgKtrnxdi45UpCHEMrtBtSA2NRcpP9zrah1CWN35a",
    poolTempLpTokenAccount: "Hc3pK8xppE3NxexxjAz4sxs3ZKwGjKfo7Lpth3FdGeQ6",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "5GH4F2Z9adqkEP8FtR4sJqvrVgBuUSrWoQAa7bVCdB44",
    serumBids: "8JdtK95nRc3sHkDdFdtMWvJ9fXFY67LMo74RiHTh8f3a",
    serumAsks: "99ScAmHwokD3Zs5assDwQHxunZe1Fz1N9GL9L1YUbvgr",
    serumEventQueue: "feXvc7XGRDETboXZiCMShmSKvsTnZtxrKoBkjJMCkNf",
    serumCoinVaultAccount: "5uUh8pUvYzEjPtofPbappZBswKieWtLW7d32yuDNC6tw",
    serumPcVaultAccount: "6eRt1RkQokKk5gmVmJ85gY42xirTMXQ1QDLXiDmbXs4b",
    serumVaultSigner: "4pwBSrGHpVn1qXjzDC2Tm8nFG8mxR9y2qudFjAQ8cVQy",
    official: true
  },
  {
    name: "LIQ-USDC",
    coin: { ...TOKENS.LIQ },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["LIQ-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "33dWwj33J3NUzoTmkMAUq1VdXZL89qezxkdaHdN88vK2",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "H4zMatEWC1cgzpJd4Ckw29M7FD6h6gpVYMs8ATkVYsee",
    ammTargetOrders: "Gz9e8TUgQg2XwPvJs5CwijFyYgRL43LiB3CeWNTkkcsu",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "GGQU74M6ikrn8Cj7qywpmj6qdx2nKJLXGb34MbtPChoh",
    poolPcTokenAccount: "DHoRYvCnFfL53zpq6ZbdHj9wdbtYpK4ip9ieFkk1TyLw",
    poolWithdrawQueue: "6gsvjkgSsxWtQRxYQ6J8uZPPhpgyoM6HwBJDpp2DzPon",
    poolTempLpTokenAccount: "7y59c7yGzLJGS8HmERaZgnbkgpKeAaAKSML3Jnsz4r4f",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "D7p7PebNjpkH6VNHJhmiDFNmpz9XE7UaTv9RouxJMrwb",
    serumBids: "HNrzaujyABxtAcGyAqCJNcbfiJT4SLHGHuwBkVH4Zmiz",
    serumAsks: "Fm2BPhsTnozBGLhFzd5iKfoBjKRWDEoCGC78xBEJg5P",
    serumEventQueue: "CXhqNRvzdgrG8TRHjzUiymQFS7NNL8nGMyUvrQT3XPnu",
    serumCoinVaultAccount: "GuivK7Kd7aiJT9gTnhDskqUpbUD5Yur3f2NyygvwhA9B",
    serumPcVaultAccount: "ZKoVkBhZ9DJvuCMLvuPvZnhFTCQFAoF1BmVZZ1SqgPg",
    serumVaultSigner: "GfX8cR4p9BWr47RknXetRvmHdCnbd1qRhi59kyibq6V4",
    official: true
  },
  {
    name: "WAG-USDC",
    coin: { ...TOKENS.WAG },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["WAG-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "FEFzBbbEK8yDigqyJPgJKMR5X1xZARC25QTCskvudjuK",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "8PAAfUWoVsSotWUGrL6CJCT2sApMpE2hn8DGWXq4y9Gs",
    ammTargetOrders: "BFtdbsu9Tq8mup8osWretDzTbWF71WuzRBHtm7G6PVpS",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "AZPsv6tY1HQjmeps2sMje5ysNtPKsfbtxj5Qw3jcya1a",
    poolPcTokenAccount: "9D6JfNjyi6dXBYGErxmXmezkauPJdHW4KjMr2RGyD86Y",
    poolWithdrawQueue: "6i1US4rvtqxPUTwqq6ax381zVgry44rX3oG7gD7VJAef",
    poolTempLpTokenAccount: "F6MrQn7qPTbDmp7ZGQkJ3ztB1uzBtVoc7iNcR6CyqCBM",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "BHqcTEDhCoZgvXcsSbwnTuzPdxv1HPs6Kz4AnPpNrGuq",
    serumBids: "F61FtHm4R4F1gszB3FuwDPvXeSPQwNmHTofoYCnrV4FY",
    serumAsks: "5tYcHCW3ZZK4TMUSYiTi4dEE7iefyQ9dE17XDDAmDf92",
    serumEventQueue: "C5gcq3kmmXJ6ADWvH3Pc8bpiBQCL5cx4ypRwPg5xxFFx",
    serumCoinVaultAccount: "6sF1TAJjfrNucAqaQFRrMD78z2RinTGeyo4KsXPbwiqh",
    serumPcVaultAccount: "5iXoDYXGnMxEwL65XTJHWdr6Z2UD5qq47ZijW24VSSSQ",
    serumVaultSigner: "BuRLkxJffwznEsxXEqmXZJdLh4vQ1BRXc41sT6BtPV4X",
    official: true
  },
  {
    name: "ETH-mSOL",
    coin: { ...TOKENS.ETH },
    pc: { ...TOKENS.mSOL },
    lp: { ...LP_TOKENS["ETH-mSOL-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "Ghj3v2qYbSp6XqmH4NV4KRu4Rrgqoh2Ra7L9jEdsbNzF",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "ABPcKmxjrGqSCQCvTBtjpRwLD7DJNmfhXsr6ADhjiLDZ",
    ammTargetOrders: "7ATMf6E5StLSAtPYMoLTgZoAzmmXmii5CC6f5HYCjdKn",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "8jRAjkPkVLeBwA4BgTvS43irS8HPmBKXmqU6WonpdkxT",
    poolPcTokenAccount: "EiuYikutCLtq1WDsinnZfXREM1vchgH5ruRJTNDYHA7b",
    poolWithdrawQueue: "GVDZeTpSkseFrsooLNpeZzpzL3WkYo7cSVMLRHCKqbcQ",
    poolTempLpTokenAccount: "DZxRzxsztb5u3TFQaZd3ce8aNUbAikLAH79x2MMNdH86",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "3KLNtqA8H4Em36tifoTHNqTZM6wiwbprYkTDyVJbrBuu",
    serumBids: "GaGvreFFZ89SKsRMxn1MbDXwEvLKH7nd2EbykAEzvaRn",
    serumAsks: "CmktYGnATPGCus9rypT2q2GmEtXx6jv14Hz5v59iN9Em",
    serumEventQueue: "12kgGbCNQjcKWnezanmCfPodE2kkoWTojgmGkt47HhCH",
    serumCoinVaultAccount: "DPdJZDKtTiaaqd52LPCvqyMPPNnJE3dSGAKVnZbsUSNm",
    serumPcVaultAccount: "5fpAmGMAqtkueG5w2doNDeBncFUvh4zgBsYoCwpGBkMA",
    serumVaultSigner: "H6uYBVPb36jnUUxzGFWadNvuqMnCr12Sx6EbmebqwgfC",
    official: true
  },
  {
    name: "mSOL-USDT",
    coin: { ...TOKENS.mSOL },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["mSOL-USDT-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "BhuMVCzwFVZMSuc1kBbdcAnXwFg9p4HJp7A9ddwYjsaF",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "67xxC7oyzGFMVX8AaAHqcT3UWpPt4fMsHuoHrHvauhog",
    ammTargetOrders: "HrNUwbZF4NPRSdZ9hwD7EWV1cwQoJ9Yhu9Jf7ybXALpe",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "FaoMKkKzMDQaURce1VLewT6K38F6FQS5UQXD1mTXJ2Cb",
    poolPcTokenAccount: "GE8m3rHHejrNf4jE96n5gzMmLbxTfPPcmv9Ppaw24FZa",
    poolWithdrawQueue: "4J45miDrQ5UdqpLzunHAYUqTg8A78CHKeBwa6a1TvFeF",
    poolTempLpTokenAccount: "7WCk8sFJiUnpGbzHpFF9FsV5oJQgKs5iBERysFDyywnq",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HxkQdUnrPdHwXP5T9kewEXs3ApgvbufuTfdw9v1nApFd",
    serumBids: "wNv6YZ31PX5hS42XCijwgd7SuMAu63aPvDWjMNTM2UP",
    serumAsks: "7g28QYJPPNypyPvoAdir8WzPT2Me78u78jufiG7M3wym",
    serumEventQueue: "Ee9UPY9CH2jHx2LLW2daLyc9VS5Bnp4yTykw4aveeXLX",
    serumCoinVaultAccount: "FgVVda2Wnp2PuDpuh23B341qZx2cnArqVNSgxsU877Y",
    serumPcVaultAccount: "2PtdrUGJd7aYoMKXpQ5d19r5Aa1z8dkRj6NNRCNGTE3D",
    serumVaultSigner: "QMhH9Mnv1jg8tLNanAvKf3ymbuzh7sDENyjCgiyn3Kk",
    official: true
  },
  {
    name: "BTC-mSOL",
    coin: { ...TOKENS.BTC },
    pc: { ...TOKENS.mSOL },
    lp: { ...LP_TOKENS["BTC-mSOL-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "ynV2H2b7FcRBho2TvE25Zc4gDeuu2N45rUw9DuJYjJ9",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "FD7fCGepsCf3bBWF4EmPHuKCNuE9UmqqTHVsAsQSKv6b",
    ammTargetOrders: "HBpTcRToBmQKWTwCHgziFhoRkzzEdXEyAAqHoTLpyMXg",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "CXmwnKYkXebSbiFdNa2AVF34iRQPaf6jecyLWkEra6Dd",
    poolPcTokenAccount: "GtdKqFoUtHC8vH1rMZvW2eVqqFa3vRphqkNCviog4LAK",
    poolWithdrawQueue: "3gctDYUqCgeinnxecj3iifkopbG88Ars14QhAf6UoCwY",
    poolTempLpTokenAccount: "5TrJppACzkDAra1MUgZ1rCm4pvYZ2gVYWBAXPt7pMQDt",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HvanEnuruBXBPJymSLr9EmsFUnZcbY97B7RBwZAmfcax",
    serumBids: "UPgp2Apw1weBoAVyozcc4WuAJrCJPf6ckSZa9psCe63",
    serumAsks: "HQyMusq5noGcSz2VoPqvztZyEAy8K1Mx6F37bN5ppH35",
    serumEventQueue: "D4bcCmeFca5rF8KC1JDJkJTiRLLBmoQAdNS2x7zTaqF4",
    serumCoinVaultAccount: "DxXBH5NCTENPh6zsfMstyHhoBtdaVnYSzHgaa6GyVbfY",
    serumPcVaultAccount: "9XqpiagW7bnAbMwpc85M2hfrcqxtvfgZucyrYPAPkcvq",
    serumVaultSigner: "mZrDXx1TQizPd9CzToBx8FqqrPCPdePHy6ttgBdNPuB",
    official: true
  },
  {
    name: "SLIM-SOL",
    coin: { ...TOKENS.SLIM },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["SLIM-SOL-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "8idN93ZBpdtMp4672aS4GGMDy7LdVWCCXH7FKFdMw9P4",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "E9t69DajWSrPC2acSjPb2EnLhFjXaDzcWsfZkEu5i26i",
    ammTargetOrders: "GtE4pXKu4Ps1oFP6Y2E7mu2RyqCJxoSqE9Cz3qwQRLRD",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "6FoSD24CM2MyadTwVUqgZQ17kXozfMa3DfusbnuqYduy",
    poolPcTokenAccount: "EDL73XTnmr56U4ohW5uXXh6LJwsQQdoRLragMYEWLGPn",
    poolWithdrawQueue: "8LEzGejBbTP7q5mNKru5vjK1HMp9XriEsVv4SAvKTSy9",
    poolTempLpTokenAccount: "3FXv4555tehX7tBwbTL1MkKxLm9Q28dJFvh32wnFoEvg",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "GekRdc4eD9qnfPTjUMK5NdQDho8D9ByGrtnqhMNCTm36",
    serumBids: "GXUZncBwk2iGYNbUtyCYon1CWu8tpTGqnyjYGZZQLuf9",
    serumAsks: "26fwQXsb5Gh5uPAwLCwBvHj6nqtXhL3DpPwYdtWKFcSo",
    serumEventQueue: "6FKmUUXSu11nnYwbWRpwQQrgLHScxDxyDdBD9MGbs23G",
    serumCoinVaultAccount: "NwNLSyB41djEmYzmqWVbia4p3kVZuqjFpdC7c72ZAZC",
    serumPcVaultAccount: "87FwRiq7Ct7Tvc2KUVPGvssbKwPAM7BLTzV9ixS3g6Y9",
    serumVaultSigner: "Fv9vYZoH5t9bGnyLrV7ifGt74vz4qvtsAUyZbLXX7qoz",
    official: true
  },
  {
    name: "AURY-USDC",
    coin: { ...TOKENS.AURY },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["AURY-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "Ek8uoHjADzbNk2yr2HysybwFk1h2j9XXDsWAjAJN38n1",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "BnGTcze1GXtCMkFPceWfUC4HPRXjJo5dGb2bmevHfgL3",
    ammTargetOrders: "2h5kDQddqUTUaAjFv3FHNMtvVVCYo1PY6BxkxtkhVzkH",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "JBvjQsg5YasDvmSKnetHZzUesa1Aucp6gXwGtPhjefGY",
    poolPcTokenAccount: "2auTq31drUwTmMKsJcD2KqZnKgiTRTN1XDKS9CQ7wzGe",
    poolWithdrawQueue: "BngHmGEaQbDF9LacaSs1hQRFMVmkvEqFpo5h5gkiWQRB",
    poolTempLpTokenAccount: "5wdZqTKhpnFwWSC3mxEH4QHd9o8Jwt7swqB2QPBJb5yf",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "461R7gK9GK1kLUXQbHgaW9L6PESQFSLGxKXahvcHEJwD",
    serumBids: "B8yZ7jW9UAKLTtPTGzfobqfn9J4obmwy8BtdX17joKVt",
    serumAsks: "8cytrpCzPUiFub2Zjxhz4VN6sz5UycVYWPEpyVteARXh",
    serumEventQueue: "Dg1CmXWtyHwoi71GVgpp9N4u7wQtcmuGcXbh9Bgpd9wb",
    serumCoinVaultAccount: "HbYw9LSKVepB9mYwbTeDy6oAj5TPrw3GqAFtKWm99jNd",
    serumPcVaultAccount: "6DbF2jRhrNgeZnHGR6c1UfGmQxk4qtBueox56huK8Etr",
    serumVaultSigner: "639H2jxUJRbvNiCQnkypf4Nvz72bSdbexchvcCg2jHYR",
    official: true
  },
  {
    name: "PRT-SOL",
    coin: { ...TOKENS.PRT },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["PRT-SOL-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "7rVAbPFzqaBmydukTDFAuBiuyBrTVhpa5LpfDRrjX9mr",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "7nsGyAGAawvpVF2JQRKLJ9PVwE64Xc2CzhbTukJdZ4TY",
    ammTargetOrders: "DqR8zK676oafdCMAtRm6Jc5d8ADQtoiUKnQb6DkTnisE",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "Bh8KFmkkXZQzNgQ9qpjegfWQjNupLugtoNDZSacawGbb",
    poolPcTokenAccount: "ArBXA3NvfSmSDq4hhR17qyKpwkKvGvgnBiZC4K36eMvz",
    poolWithdrawQueue: "4kj6urHjHG3DD8eEdSrMvKQ3P1sL5wvaTakHoZqaTLLx",
    poolTempLpTokenAccount: "6u5JagDxsfVwGe543NKAviCwRUEXV9XCXEBXFFcUPcoT",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "H7ZmXKqEx1T8CTM4EMyqR5zyz4e4vUpWTTbCmYmzxmeW",
    serumBids: "5Yfr8HHzV8FHWBiCDCh5U7bUNbnaUL4UKMGasaveAXQo",
    serumAsks: "A2gckowJzAv3P2fuYtMTQbEvVCpKZa6EbjwRsBzzeLQj",
    serumEventQueue: "2hYscTLaWWWELYNsHmYqK9XK8TnbGF2fn2cSqAvVrwrd",
    serumCoinVaultAccount: "4Zm3aQqQHJFb7Q4oQotfxUFBcf9FVP6qvt2pkJA35Ymn",
    serumPcVaultAccount: "B34rGhNUNxnSfxodkUoqYC3kGMdF4BjFHV2rQZAzQPMF",
    serumVaultSigner: "9ZGDGCN9BHiqEy44JAd1ExaAiRoh9HWou8nw44MbhnNX",
    official: true
  },
  {
    name: "LIQ-RAY",
    coin: { ...TOKENS.LIQ },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["LIQ-RAY-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "HuMDhYhW1BmBjXoJZBdjqaqoD3ehQeCUMbDSiZsaXSDU",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "7wdwaVqX54dpmHsAv1p1j6CNX384ngTdPw6hhyrqnSkm",
    ammTargetOrders: "35KVohngiK6EuhFVSycgVkedgmxGjyebjHBEWnTmZSaJ",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "DNfbb7s6zD1kWpGHCCEv6BrLYUFdvoqbLE7pkRpWEAD3",
    poolPcTokenAccount: "6tPg3nmHnvN8HfCfLC9EEpB1dvV3sB5XtwaQeqpwaqzY",
    poolWithdrawQueue: "2bQ5JURC12KdxzigEzUTC15wMvFb8Lf6UQWDMTr4by3f",
    poolTempLpTokenAccount: "Exj93mjyV378SD3CTDAyh5V5zEf9pSPU12yKJtp3hjgQ",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "FL8yPAyVTepV5YfzDfJvNu6fGL7Rcv5v653LdZ6h4Bsu",
    serumBids: "BkiWgktHinZLpc6ochQGUujh4aLQL7S9ZvhnRY64Z5Je",
    serumAsks: "EcHLYi56KcNKsiUiHb7mXrT29YJhArdizegkjmVJ6LeJ",
    serumEventQueue: "9U3PefXaFHYiTaCz2p4SsW6X5RK9Kq7FxUeB3PTwpG1a",
    serumCoinVaultAccount: "3VB8kEgcpuFzSf6Nbe3Nm2BiUNGxmJpZGbYSoqnDruRp",
    serumPcVaultAccount: "DYRShjB8necZU1Qx9FVPDLSjuu3zEkbHgd6BEkMZPS23",
    serumVaultSigner: "CEhFiD6xAgRptnuyUJg3iAkN7Zi65ZNoyi9uBPt5V8Y",
    official: true
  },
  {
    name: "SYP-SOL",
    coin: { ...TOKENS.SYP },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["SYP-SOL-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "D95EzH4ZsGLikvYzp7kmz1RM1xNMo1MXXiXaedQesA2m",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "34Ggyj2dNyQUWDaGUaMKVvyQDoTHEupD4o2m1mPFaPVf",
    ammTargetOrders: "DAadSXEyP5dZPiYFKcEkj6i7rY5TQtHucXPvum53uAHY",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "4iuHfu5rPzdsnjBEPAdGvnK3brF3JiqpwtXerko1o6U4",
    poolPcTokenAccount: "5FvQrUmnCN4o1HBsA3XqbCDPypvyroJ9MBSYH5goxFGC",
    poolWithdrawQueue: "3sXFB5JFTi38cVbJaAf6b95GJp8UqgbBX5YMcPg5sBsH",
    poolTempLpTokenAccount: "CdQQS6QJLR6it5bNfmpiU6uQod6Z71scF5ZuGTzrwdut",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "4ksjTQDc2rV3d1ZHdPxmi5s6TRc3j4aa7rAUKiY7nneh",
    serumBids: "BgzeMbya7kgtaV9zNhF4L6oABQSrErg9ZiDFDWeUqpv1",
    serumAsks: "8L6HcYpMr4TqaEksbUy7GkGBUvPv8UARCVH4nhbrfZFt",
    serumEventQueue: "J99229xgQtGXN7jvWFh6wB73kT44X269GEtjaykkcuf5",
    serumCoinVaultAccount: "GkM6SiD2GFKTuqJraMuWbPVYcvEvzPqjndsKq3GfYEX4",
    serumPcVaultAccount: "FF6EXqFSZzUvyuj6uYRWxTFDAhd5jcz57PL69BAMPutd",
    serumVaultSigner: "BmNvsW45ZLYrnSZpFHFL3xmTyWsJ1X6jof3XoCkEry6H",
    official: true
  },
  {
    name: "SYP-RAY",
    coin: { ...TOKENS.SYP },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["SYP-RAY-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "3hhSfFhbk7Kd8XrRYKCcGAyUVYRaW9MLhcqAaU9kx6SA",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "9WAbiCgjiYeV9aBh8jo2eX8ujAhfEZdZPxPeBtEemz9t",
    ammTargetOrders: "43FmUjW5ZLQ9VeZA7B5gCqJ5fmvJgXHn2zfistpxJt8t",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "FPPZjSgvMJ9EkKJpsTFNnGNJYAbiteskZQGHieVh9Mfh",
    poolPcTokenAccount: "FEB62fNjbKaPPc9YBnuA2SMacyQhqQw5XTy5d5kTS1oW",
    poolWithdrawQueue: "6MMAE9t29jmuckFgmYojPQk5pJB4TTHJxAmTvWfHAkBr",
    poolTempLpTokenAccount: "EbNabXhGffsMVn2QyaRVgaR9M1M2NM9AZWCCKMLuZSRT",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "5s966j9dDcs6c25MZjUZJUCvpABpC4gXqf9pktwfzhw1",
    serumBids: "6ESsneZ4fQgPE6MUKsP6Z8kzAZk9RGeVg3uffVqhuJXb",
    serumAsks: "F2SRQpGR8z4gQQxJ1QVdrzZr7gowTLmfXanTsWmBbzTf",
    serumEventQueue: "6WpyfUCGwDBMgMng5kqsYeGHq4cmFP7X5zyXSs6ZZJ93",
    serumCoinVaultAccount: "5reSWxhb7uugMzxQXPEfYY7zaveCmHro7juk3VzQJx9T",
    serumPcVaultAccount: "4S5XZnwyd7kB1LnY55rJmXjZHty3FGAxyqQaNHphqfzC",
    serumVaultSigner: "BBaMkoum9hY53mCXAGqMcP2hMSzEyS7Nr12RLY395eCL",
    official: true
  },
  {
    name: "SYP-USDC",
    coin: { ...TOKENS.SYP },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["SYP-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "2Tv6eMih3iqxHrLAWn372Nba4A8FT8AxFSbowBmmTuAd",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "GNHftHYD7WRG5HYdyWjd9KsxjUgUALrLcSG2AZvv5ahU",
    ammTargetOrders: "89weJGn5qci3QF1tPQC3P4B3xMbKqdgeXSHfiNxKvKCd",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "9ZQNgn9zAc9oLKST5yW9PNjCCqSfJVwnFpfgZnd88Xn1",
    poolPcTokenAccount: "HLtqBqwgdbGdFfd5UZtKkvrdxLLcpaMnAJ5aZAzDjFdT",
    poolWithdrawQueue: "4LybXzk5xxLPRsz8evCNtNXLc6Mydb5HCWyitHeDvCKT",
    poolTempLpTokenAccount: "5WKtEZL7Zst2QBKA5E9YCbKMPxTZNrErGB8TyGs3z9oD",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "9cuBrXXSH9Uw51JB9odLqEyeF5RQSeRpcfXbEW2L8X6X",
    serumBids: "EmqbfgZFSQxAeJRWKrrBVST4oLsq8aMt4WtcufPARcd7",
    serumAsks: "GZqx3xX1PjNpmw2qDGhiUSa6PsM5tWYY7cMmKzYFCCLD",
    serumEventQueue: "8w8JzuqcRUm9QAC3YWJm2mBCVjWDLXh8b7ktSouJKMUd",
    serumCoinVaultAccount: "8DGcP5Z8M878mguFLohaK9jFrrShDCREF3qa7JhMfgib",
    serumPcVaultAccount: "CLS4WFje2PbV3MmV4v7CGxu3bNFqx2sYewq95rzGR8t8",
    serumVaultSigner: "FBLtcfAXmm5PpJLLr95L5cjfgbpJiGHsWdBXDpC2TBQ2",
    official: true
  },
  {
    name: "FAB-USDC",
    coin: { ...TOKENS.FAB },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["FAB-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "7eM9KWYiJmNfDfeztMoEZE1KPyWD54LRxM9GmRY9ske6",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "4JJD9FBTigYALJgmJ5NN7uSAdm4UF3MqcfQG6zaDcZSj",
    ammTargetOrders: "PknPGRn3K3HPzjyaKjSAqDWqXm65TRzQzsSjG6dibPn",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "Dz7UPsYuDnCPfomPDS1qzhGXqerPhoy7PYScv99JDefh",
    poolPcTokenAccount: "3Xo2iExmhn4X3yrKmwsRTMMTg2mXdWuEQD2BVweNyCCr",
    poolWithdrawQueue: "4bneChpQF8xrjB7TAYZvBm5xgxncZgn4skZxKV4r3ByM",
    poolTempLpTokenAccount: "7npJaUpN2TFcMStrQKVPjEcKD9Ju5wpyJHcnVW54Z1Ye",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "Cud48DK2qoxsWNzQeTL5D8sAiHsGwG8Ev1VMNcYLayxt",
    serumBids: "FWSRaqAPmbwepdz49MVvvioTLWTXW18XCtEvfSv3ytBV",
    serumAsks: "21CBXgZHF58nfFJVts6rAphuPNsbj6JY8CacokMdhpNB",
    serumEventQueue: "6qdexKV3nXYtkZkh49fSFrzEStdmaGj8HttNWSG2ZViT",
    serumCoinVaultAccount: "71E7dr2Rodeneu6wPn8oofCpLQJjfDHr6r76HGCDv491",
    serumPcVaultAccount: "8gU7HWyk3X41ebNkMH44JhEWq1nzRGdWwGgZaJfr4zGR",
    serumVaultSigner: "GuLwNbHHLDyNtYF5qv16boMKvdek5AFK8v7PZ2hMgvdv",
    official: true
  },
  {
    name: "WOOF-RAY",
    coin: { ...TOKENS.WOOF },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["WOOF-RAY-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "3HYhQC6ne6SAPVT5sPTKawRUxv9ZpYyLuk1ifrw8baov",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "Bo8BrjEpfu7pJVH32FTE6rJr2UBvhPp59zfA2mWT581U",
    ammTargetOrders: "4JZBoQLkpgPzdwLBbQeZ6PQj11vtLomuRtSFE4Xkc3CJ",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "5cjmkkBTx5QecZh78iwwVRUobE25fyjJZQcfEXdzWo37",
    poolPcTokenAccount: "DPLFfchYfphyS86uLRx2gqHTTy8urWBGt1yYC2a6xUHX",
    poolWithdrawQueue: "7UYg1Gh4tipvNdYYC4rqqLapcs9szENKkrgrEKmDqtJu",
    poolTempLpTokenAccount: "DQAeQPjQqB733mJfJbt4wHfA2fHVM6bVgaUGNjCerJjE",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "EfckmBgVkKxBAqPgzLNni6mW1gbHaRKiJSJ3KgWihZ7V",
    serumBids: "4WfAKMzXH2Gbcx6tafVy2CwpKDbqFqtx5CbAr877ivx5",
    serumAsks: "H8WLtDAhcJZLW3J1g2sNPhiqy7PG75GkRZU93EB5xwwj",
    serumEventQueue: "7n1qHSyCH7btGmiexi1tj5tzsJgRBywg1a1Xvov3GVoq",
    serumCoinVaultAccount: "CJVUSSsd4AnqNK7pvDb3XWWx6v34NELyy8JdQoKxnSdW",
    serumPcVaultAccount: "4YFPXdvk2HYwAJMPFCw7EU2h6CUTeWzvsC5DnrrTGF3Z",
    serumVaultSigner: "78dHXV2JdqQyFTs1tprMH359be7WWMYsmsSAsFctBoZe",
    official: true
  },
  {
    name: "WOOF-USDC",
    coin: { ...TOKENS.WOOF },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["WOOF-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "EZRHhpvAP4zEX1wZtTQcf6NP4FLWjs9c6tMRBqfrXgFD",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "GBGxwY1eqBJcTVAjwFDpLGQGCv5eoQTciudT9ttFybqZ",
    ammTargetOrders: "EdQNfUu9EAX6aT7ixLV9zYBRLhArCgrxPAQPr3CBdFK7",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "6LP3CwLwA7StkyMQ9NpKUqLS9ipMmUjPrKhQ8V9w1BoH",
    poolPcTokenAccount: "6HXfUDRXJkywFYvrKVgZMhnhvfqiU8T9pVYhJzyHEcmS",
    poolWithdrawQueue: "EhgYsvA9J31J64LREuzTtt7QYhMBUX3EEAoCSZ6BwQjk",
    poolTempLpTokenAccount: "7E1e3kEWAgaerDErppzSJX34ukHtUQryiM7sAa7zhYPa",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "CwK9brJ43MR4BJz2dwnDM7EXCNyHhGqCJDrAdsEts8n5",
    serumBids: "D5S8oWsPjytRq6uXB9H7fHxzFTpcmvULwYbuhAeAKNu4",
    serumAsks: "3PZAPrwUkhTqjaB7sDHLEj669J6hQXzPFTrnv7tgcgZT",
    serumEventQueue: "4V7fTH8x6qYz4GyvEVbzq1yLoGcpoByo6nCrsiA1HUUv",
    serumCoinVaultAccount: "2VcGBzs54DWCVtAQsw8fx1VVdrxEvX7bJz3AD4j8EBHX",
    serumPcVaultAccount: "3rfTMxRqmtoVvVsZXnvf2ifpFweeKSWxuFkYtyQnN9KG",
    serumVaultSigner: "BUwcHs7HSHMexNjrEuSaP3TY5xdqBo87384VmWMV9BQF",
    official: true
  },
  {
    name: "SLND-USDC",
    coin: { ...TOKENS.SLND },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["SLND-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "GRM4jGMtx64sEocBFz6ZgdogF2fyTWiixht8thZoHjkK",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "GLgrNWTUfX4n165WaMG4dELg4e7E7RBNWMzBFvYKbcbs",
    ammTargetOrders: "FCa9xL1TeJrDvhxyuc9J3o4KNtXBZREC3Kxr5sYVZNtQ",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "DCHrCqguY9Jtn8xutdVPAhCbLayYaksPSwqg5aZzFXVM",
    poolPcTokenAccount: "BxzizWAWk91TKbMAZM4F9zhUM5omdtdhjQQSdEM5sEXA",
    poolWithdrawQueue: "2TYYWf8RKyu5YoH5bwxiJnCyHdAeWUMadBDMotuNWoR8",
    poolTempLpTokenAccount: "53KFE2hkixwSRMj8Co9dZfG8uj2PXmfm1pBBUaqCocsA",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "F9y9NM83kBMzBmMvNT18mkcFuNAPhNRhx7pnz9EDWwfv",
    serumBids: "EcwoMdYezDRLVNFzSzf7jKEuUe32KHp5ddU7RZWdAnWh",
    serumAsks: "4iLAK21RWx2XRyXzHhhuoj7hhjVFcrUiMqMSRGandobn",
    serumEventQueue: "8so7uCu3u53PUWU8UZSTJG1b9agvQtQms9gDDsynuXr1",
    serumCoinVaultAccount: "5JDR5i3wqrLxoZfaytoW14hti9pxVEouRy5pUtyhisYD",
    serumPcVaultAccount: "6ktrwB3FevRNdNHXW7n6ufk2h1jwKnWFtjhHgNwYaxJb",
    serumVaultSigner: "HP7nqJpWXBS91fRncBCawqidJhxqNwKbS84Ni3HBTiGG",
    official: true
  },
  {
    name: "FRKT-SOL",
    coin: { ...TOKENS.FRKT },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["FRKT-SOL-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "H3dhkXcC5MRN7VRXNbWVSvogH8mUQPzpn8PYQL7HfBVg",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "7yHu2fwMQDA7vx5RJMX1TyzDE2cJx6u1v4abTgfEP8rd",
    ammTargetOrders: "BXjSVXdMUYM3CpAs97SE5e9YnxC2NLqaT6tzwNiJNi6r",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "EAz41ABjVhXLWFXcVdC6WtYBjnVqBZQw7XxXBd8J8KMp",
    poolPcTokenAccount: "6gBKhNH2U1Qrxg73Eo6BMuXLoW2H4DML18AnALSrbrXr",
    poolWithdrawQueue: "9Pczi311AjZRXukgUws9QVPYBswXmMETZTM4TFcjqd4s",
    poolTempLpTokenAccount: "BNRZ1W1QCw9v6LNgor1fU91X49WyPUnTWEUJ6H7HVefj",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "FE5nRChviHFXnUDPRpPwHcPoQSxXwjAB5gdPFJLweEYK",
    serumBids: "F4D6Qe2FcVSLDGByxCQoMeCdaLQF3Z7vuWnrXoEW3xss",
    serumAsks: "9oPEuJtJQTaFWqhkA9omNzKoz8BLEFmGfFyPdVYxkk8B",
    serumEventQueue: "6Bb5UtTAu6VBJ71dh8vGji6JBRsajRGKXaxhtRkqwy7R",
    serumCoinVaultAccount: "EgZKQ4zMUiNNXFzTJ89eyL4gjfF2yCrH1seQHTnwihAc",
    serumPcVaultAccount: "FCnpLA4Xzo4GKctHwMydTx81NRgbAxsZTreT9zHAEV8d",
    serumVaultSigner: "3x6rbV78zDotLTfat9tXpWgCzqKYBJKEzaDEWStcumud",
    official: true
  },
  {
    name: "weWETH-SOL",
    coin: { ...TOKENS.weWETH },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["weWETH-SOL-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "4yrHms7ekgTBgJg77zJ33TsWrraqHsCXDtuSZqUsuGHb",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "FBU5FSjYeEZTbbLAjPCfkcDKJpAKtHVQUwL6zDgnNGRF",
    ammTargetOrders: "2KjKkci5zpGa6orKCu3ov4eFSB2aLR2ZdAYvVnaJxJjd",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "5ushog8nHpHmYVJVfEs3NXqPJpne21sVZNuK3vqm8Gdg",
    poolPcTokenAccount: "CWGyCCMC7xmWJZgAynhfAG7vSdYoJcmh27FMwVPsGuq5",
    poolWithdrawQueue: "BzTWSVgYaqHvUcuPZKD4yKTDR2xCDtZFb1bqkwfoPHZJ",
    poolTempLpTokenAccount: "Dfvj9bmde56ZWgxDsrADywZhctejEG2WTbnYa7P5SAhk",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "7gtMZphDnZre32WfedWnDLhYYWJ2av1CCn1RES5g8QUf",
    serumBids: "4Z6iBaVyCusvALJShz39yDY98jwPn6T1SsKaiLE3k5du",
    serumAsks: "J6ULjQv2xpifRQQAKNYAtEGapgAsAA7vNhhRU57Law6m",
    serumEventQueue: "4tMSdiQWSGJbaz4UCdHQpqczxCJfLvBNWtskGbAnFgBz",
    serumCoinVaultAccount: "5F5W8nkQpXnb5ewS2GiUCuWAiamZpzGEMBciwaZ72frr",
    serumPcVaultAccount: "CdWhLReMv1A4BJQkogvMwxVVop6agSW22YzQBzKUCS1y",
    serumVaultSigner: "GRiN6BiHeaa2wrFEpqzR397d6RqefCSRhnQVsVscwT3r",
    official: true
  },
  {
    name: "weWETH-USDC",
    coin: { ...TOKENS.weWETH },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["weWETH-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "EoNrn8iUhwgJySD1pHu8Qxm5gSQqLK3za4m8xzD2RuEb",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "6iwDsRGaQucEcfXX8TgDW1eyTfxLAGrypxdMJ5uqoYcp",
    ammTargetOrders: "EGZL5PtEnSHrNmeoQF64wXG6b5oqiTArDvAQuSRyomX5",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "DVWRhoXKCoRbvC5QUeTECRNyUSU1gwUM48dBMDSZ88U",
    poolPcTokenAccount: "HftKFJJcUTu6xYcS75cDkm3y8HEkGgutcbGsdREDWdMr",
    poolWithdrawQueue: "A443y1KRAvKdK8yLJ9H29mgwuY56FAq1KvJmkcPCn47B",
    poolTempLpTokenAccount: "jYvXX2z6USGtBSgJiPYWM9XZTBoiHJGPRGeQ9AUX98T",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "8Gmi2HhZmwQPVdCwzS7CM66MGstMXPcTVHA7jF19cLZz",
    serumBids: "3nXzH1gYKM1FKdSLHM7GCRG76mhKwyDjwinJxAg8jjx6",
    serumAsks: "b3L5dvehk48X4mDoKzZUZKA4nXGpPAMFkYxHZmsZ98n",
    serumEventQueue: "3z4QQPFdgNSxazqEAzmZD5C5tJWepczimVqWak2ZPY8v",
    serumCoinVaultAccount: "8cCoWNtgCL7pMapGZ6XQ6NSyD1KC9cosUEs4QgeVq49d",
    serumPcVaultAccount: "C7KrymKrLWhCsSjFaUquXU3SYRmgYLRmMjQ4dyQeFiGE",
    serumVaultSigner: "FG3z1H2BBsf5ekEAxSc1K6DERuAuiXpSdUGkYecQrP5v",
    official: true
  },
  {
    name: "weUNI-USDC",
    coin: { ...TOKENS.weUNI },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["weUNI-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "8J5fa8WBGaDSv8AUpgtqdh9HM5AZuSf2ijvSkKoaCXCi",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "4s8QacM13Z9Vf9en2DyM3EhKbekwnmYQTvd2RDjWAsee",
    ammTargetOrders: "FDNvqhZiUkWwo95Q21gNimdqFQDJb5nqqttPT5uCUmBe",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "B5S6r6DBFgB8nxa8P7FnTwps7NAiTsFbiM6Xo7KrGtxP",
    poolPcTokenAccount: "DBd8RZyBi3rdrpbXxXdcmWuTTrfkA5vfPh9HDLo1cHS",
    poolWithdrawQueue: "CsPmj2rcDNQF85Q1bvWbieNkymtEHqyo7aXHmwHNiEKQ",
    poolTempLpTokenAccount: "9qHe2MC69BTwZY2GBJusz1rgMARsJAd6WvRu7cCYczjg",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "B7b5rjQuqQCuGqmUBWmcCTqaL3Z1462mo4NArqty6QFR",
    serumBids: "2FafQRbcuh7sE9iPgWU7ccs5WNsSyih9rXCTZn4Bv3t2",
    serumAsks: "HJMohwcR3WUVFj9whhogSpBYzqKBjHyLcXHecArwgUEN",
    serumEventQueue: "CTZuXPjhrLb4PSNSqdsc7xUn8eiRAByfQXoi4HXkPVUe",
    serumCoinVaultAccount: "4c4EMg5rPDx4quJdo3tL1uvQVpnoLLPKzMDn224NtER7",
    serumPcVaultAccount: "8MCzvWSskaoJpcXNVMui9GfzYMaMBQKPvE9GpqVZWtxq",
    serumVaultSigner: "E4D2s9V4wuh6MMEJp7zkh6rcGgnoncJtMFFHjo4y1d5v",
    official: true
  },
  {
    name: "weSUSHI-USDC",
    coin: { ...TOKENS.weSUSHI },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["weSUSHI-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "9SWy6nbSVZ44XuixEvHpona663pZPpVgzXQ3N7muG4ou",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "4dDzSb5sVQuQU7JpiELNLukEUVYoTNyhwrfTd59L3HTK",
    ammTargetOrders: "4soQgpB1MhYjnD2cbo3aRinZh9muAAgBhTk6gLYSG4hM",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "CTTAtNw3TPxMhZVcrxHPjbyqEfYS7ShAf6KafC4xeJj",
    poolPcTokenAccount: "EPav47MmuNRnHdiRSNpRZq9fPAvpvGb81mWfQ4TMc4VQ",
    poolWithdrawQueue: "4DwCSyerQnxtiHc2koWWxpz31KjQdmLFe8ywWwrVkwEq",
    poolTempLpTokenAccount: "EwFVC9RA6WRBpqPjTxRmw6iYVtCGd7JoSi5MECvc3vE9",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "3uWVMWu7cwMnYMAAdtsZNwaaqeeeZHARGZwcExnQiFay",
    serumBids: "HtAQ6zXqg53WKTHoPNz6Y6nfy2vpRvaFFif13y9wWQzo",
    serumAsks: "CyMeznxwdK1vVLB8yrq1MpwZpmQ43UipnqhahrwHNj5r",
    serumEventQueue: "EiA2FLSrSJkJEGZg79eJkrAz7wtaB3jHDiXvQ4v5hZyA",
    serumCoinVaultAccount: "2DiofKbhznosm6ngnVXZY9r6j3WypkK6PXZu4XVhrUwS",
    serumPcVaultAccount: "FwRAP48S9kwXFgiBDHU4NvuGkFnqctXEurgLFZFqdt2Z",
    serumVaultSigner: "4BRTPsziQ1QcKtsqAiXjnJe5rASuu41VXF1Bt5zpHqJs",
    official: true
  },
  {
    name: "CYS-USDC",
    coin: { ...TOKENS.CYS },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["CYS-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "661trVCzDWp114gy4PEK4etbjb3u3RNaP4aENa5uN8Vp",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "gng63EZXkDhK3Qp8KgvLEZkcWmVDrmBe3EuYRy8mBPy",
    ammTargetOrders: "5Y23u3wgJ68uk7suF1mbJZQ9q1BnQKSVXUZfjJeY5RGw",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "CVioXLp58QsN9Xsf8JkAcadRmC1vsW74imLpKhMxPWSM",
    poolPcTokenAccount: "HfBK19mBWh5D9VgnsPaKccfQaD79AYXetULtwLo62qxr",
    poolWithdrawQueue: "7txhWR41faQuKEBb6xq53RHBdGMCXf7fM7MBJgMvTiBN",
    poolTempLpTokenAccount: "FrzaE4b2kpXtihidZj8mpTK3ji36wrTMtKLdVAxqPbiU",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "6V6y6QFi17QZC9qNRpVp7SaPiHpCTp2skbRQkUyZZXPW",
    serumBids: "5GdFXwsM4oW5pgyYUE4uqQXKsswL1y21DBwn6HJTteQt",
    serumAsks: "ARGstQL7aLDdfN5yXUXKh8Y4Gwqe6eq5pMvYGcgkvHR1",
    serumEventQueue: "FC9bnU5d4irjaWdCjG8sgUT5TTaADDpvxdn4twN9fA9A",
    serumCoinVaultAccount: "4PfqVvYg6tshSnMBMrXUwzYdS9gZvoxWFwGeLEx6BKow",
    serumPcVaultAccount: "81WG3s7xWe8aT6nf3r3t6sBuoMFb4QPiEZ2caENXQuKr",
    serumVaultSigner: "FeGULrcjRyxHyRJTAUt84TqjR89biLnwwtjReWtRNoy2",
    official: true
  },
  {
    name: "SAMO-USDC",
    coin: { ...TOKENS.SAMO },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["SAMO-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "7oYaghDwJ6ZbZwzdzcPqQtW6r4cojSLJDKB6U7tqAK1x",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "DsYePDFjAFNQVEjiGwg4tsUdqfLu9hXuu9VPS6DtyPZs",
    ammTargetOrders: "6RQvAcLyub9KNcAWkJMER3Rm2AvwysYyVVdxzSBuUNMm",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "4jrV1Fwqxdnw3WXvLQiXqquLvn4p6p5F9imAVNEU4yCT",
    poolPcTokenAccount: "5vkX52gpV1ZXmvk2JBSjD8z2wpGKp5Cs1XW15y5YB5ca",
    poolWithdrawQueue: "6ZX2Ct81QtwvWKUARLMjzR3jvs9QNDwPVyPN45YaoKAL",
    poolTempLpTokenAccount: "DsT2dCWWGEmNcrX8vzx9Fm89Xg4J58LjEijNhVXsRuuN",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "FR3SPJmgfRSKKQ2ysUZBu7vJLpzTixXnjzb84bY3Diif",
    serumBids: "2Ra3y1Y4HDd2jLjvAwdR6JKgGbyySGMToaZACkjroRWR",
    serumAsks: "EXBohV8AsD8kt1GcHTuwHoPLfkz5n8PmNn5JyPJybJ35",
    serumEventQueue: "9FeUXsT6LbNXXZRQohoMRuxsmmYdfQM85JbVtrLUSB2w",
    serumCoinVaultAccount: "HgKq27kVsH6bFdHru5p3ohnrL2d4D776Yiptkzv2ntwX",
    serumPcVaultAccount: "JzkBGgCZLSzuZrC2XAmq5F4BRHmvhZtiUrbxsMP2BP6",
    serumVaultSigner: "679pdaM91fct45cM3nCvzBN57UGCFHe1CTSJwSRqjGwJ",
    official: true
  },
  {
    name: "ABR-USDC",
    coin: { ...TOKENS.ABR },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["ABR-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "GQJjrG6f8HbxkE3ZVSRpzoyWhQ2RiivT68BybVK9DxME",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "AwHZdJrEDWAFhxsdsErvVPjWyE5JEY5Xq6cq4JjZX73L",
    ammTargetOrders: "AdWdYACEwtJLtNsqjBeAuXhHFiJPNJHkScYrdQeJWV6W",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "3zrQ9od43vB9sV1MNbM68VnkLCfq9dVUvM1hmp8tcJNz",
    poolPcTokenAccount: "5odFuHq8jhqtNBKtCu4F2GvUiH5hB1zVfpS9XXbLf35d",
    poolWithdrawQueue: "FHi35hxZM29USwLwdAhbT8u7YhW8BPWvtLHyLnXPebW2",
    poolTempLpTokenAccount: "53fmAZj3d3YEnHY4PvyCE1Cx23x5g3d1ejwyDAZd3NzH",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "FrR9FBmiBjm2GjLZbfnCcgkbueUJ78NbBx1qcQKPUQe8",
    serumBids: "4W6ZoBB2QNBe6AYM6ofpWjerAsnJad93hVfdC5WMjRsX",
    serumAsks: "64yfFmc7ivEknLRT2nvUmWkASGwz8MPxtcPdaiWUffro",
    serumEventQueue: "GgJ8bQSZ6Lt2mEurrhzLMWFMzTgVFq8ax91QzmZzYiS6",
    serumCoinVaultAccount: "9yg6VjgPUbojGn9d2n3UpX7B6gz7todGfTcV8apV5wkL",
    serumPcVaultAccount: "BDdh4ane6wXkRdbqUuMGYYR4ggf3GufUbjT2TxpHiAzU",
    serumVaultSigner: "A3LkbNQUjz1q3Ux5kQKCzNMFJw3yxk9qx1RtuQBXbZZe",
    official: true
  },
  {
    name: "IN-USDC",
    coin: { ...TOKENS.IN },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["IN-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "5DECiJuqwmeCptoBEpyJtXKrVfiUrG9nBbBGkxGkPYyF",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "GujdDreXBSEXUCjk39tRnM8ZYCrtyambNSa3JjJVGvLJ",
    ammTargetOrders: "D4dBV5v9AMfGzgf1eBrpAUom72YVLYeZr1ufnY1dJd8W",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "2z4day3sVMRULUtFJ4sbTvKrkjMsc42rjXHDQtggbSE9",
    poolPcTokenAccount: "9PVPqk5RYf5x9nRYbEzotVNpk36NJ6bAZJaaSnaaZrYn",
    poolWithdrawQueue: "3xxiFPPRwy4bshMeG3bN4yCNDiFsbVdPq29qK2bddJ9J",
    poolTempLpTokenAccount: "EbDVS5gwPdVYK7f14g2B9zNesgEfAcgnxQzTYf7GYw9j",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "49vwM54DX3JPXpey2daePZPmimxA4CrkXLZ6E1fGxx2Z",
    serumBids: "8hU3yAFb1429V1TTSKqpgJ7XJyQQQoLq76wxHeM1WYo",
    serumAsks: "CEdiYZ2Cp62ECHgkz2mPiK9A6HcMG2jSmrppxiENzgKT",
    serumEventQueue: "DJgsxzKvBY2wTqAWEmiqV8quTR7k9GZ7rsmvov3yzXPw",
    serumCoinVaultAccount: "De4wrN3UtHs783VTZjqoFZtP2v95pMWFx1KCqmkWBXqU",
    serumPcVaultAccount: "DiiAfxX3J5apQ8SJ42Z4z2USTK3QbhksTzniAugLaG91",
    serumVaultSigner: "D8QQQMut9bbPfpCXHgbwoPSF4KNYSg7SyRUGF828dBfZ",
    official: true
  },
  {
    name: "weDYDX-USDC",
    coin: { ...TOKENS.weDYDX },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["weDYDX-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "CbGQojcizFEHn3woL7NPu3P9BLL1SWz5a8zkL9gks24q",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "75hTsLMn57111C8JwG9uqrkw6iZsFtyU8CYQYSzM2CY8",
    ammTargetOrders: "3pbY7NyETK3UBG1yvaFjqeYPLXMd2wHgcZVJi9LZVdx1",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "45pPLPHYUJ7ainr9eqPzdKcWJSbGuoUwcMcMamAXgcCX",
    poolPcTokenAccount: "7aE4zihDvU58Uua8W82Q2u915rKqzpmpWPxZSDdeXrwu",
    poolWithdrawQueue: "2r8yHQGdydgngeTXdqsM2P2ZWVmwRAe3Kq3MLTCQPpHD",
    poolTempLpTokenAccount: "DBmenZarP1WQx9uvrKQQj3pNfhmNanZ9ns5tpMYpDcyJ",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "GNmTGd6iQvQApXgsyvHepDpCnvdRPiWzRr8kzFEMMNKN",
    serumBids: "89Ux1PrzAVv5tejtCQhfs5tqEfQdb3WQsfY6f7BzQtsN",
    serumAsks: "36eRuVT8kyWq1UbZeYf66q5EhUpNP2Kq8TgffyVbHEzF",
    serumEventQueue: "4GX63nbB8SHwDeDpuSKacfch1ANTLp4zn8ivkcTjCnEn",
    serumCoinVaultAccount: "CXxN6hGatd5nK7uPwxvxHYmqvM4b88eKb9fcHapRhtda",
    serumPcVaultAccount: "NMWKX4jfzkKvRBYkcvurus8aofaHZ8MwMNYqudztWZh",
    serumVaultSigner: "DD6e6WMaZ3JePsBNP9Eoz9aJsD3bZ81EjMvUSWF96qQx",
    official: true
  },
  {
    name: "STARS-USDC",
    coin: { ...TOKENS.STARS },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["STARS-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "CWQVga1qUbpZXjrWQRj6U6tmL3HhrFiAT11VYnB8d3CF",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "D3bJNYcUhza55mdGFTAUi4CLE12f54qzMcPmawoBCNLc",
    ammTargetOrders: "FNjcSQ7VB7ULoSU7BDTotiRDmqiQj7CvVxHALnYC5JGP",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "5NtsnqVNXGmxs6zEU73W2RaFh4e58gqdWrxMvzcqNxGk",
    poolPcTokenAccount: "MZihwPviJgm5WjHDmh6c5pq1tTipuZnHFN3KBg63Mtj",
    poolWithdrawQueue: "5NRhJQS8m4pgc8Lgo1kuqHJrU8JAeToriPvpJ4LY88uH",
    poolTempLpTokenAccount: "8vLEHvkCEdAj4YPGbfrcTKHccaEJQwuY32WunJWzyuZx",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "DvLrUbE8THQytBCe3xrpbYadNRUfUT7SVCm677Nhrmby",
    serumBids: "9Nvw43fQ4vNfdJgajMC4JUpLGGTiia1vGYEM7SbfaWei",
    serumAsks: "CnVNbSQcVNQjGA4fdBtSrzDyFNXAHuBhcMnZsQBpEHo5",
    serumEventQueue: "D1hpxetuGzfz2mSf3US6F7QHjmmA3A5Q1EUJ3Qk5E1ZG",
    serumCoinVaultAccount: "AzhvXGjqJtDW4ieSYVje3zxL14TP1pGJv6uULR2F86uR",
    serumPcVaultAccount: "8SrtqysGeiKkXWMGMgee9frWbGdhXZr9gWHh2VKRnvkZ",
    serumVaultSigner: "EN7RnB2RVxeDcTQWFBAuaf5Bg9sEuHhwwWiuj1TFHEuC",
    official: true
  },
  {
    name: "weAXS-USDC",
    coin: { ...TOKENS.weAXS },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["weAXS-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "HopVRTvFvRe1ED3dRCQrt1h5onkMvY3tKUHRVQMc7MMH",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "BWJ96nvwjxqkjbu2rQN2H4U3E5PjWRMjrw2gqRcicazt",
    ammTargetOrders: "6JtLCecsVp3UN1eEyZCHUBXKmd4HqnzYXB3AcS1DCEFe",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "9pyHCyqHKvfbsTeYNQRTf5zHLzZedmxWA7YGC4ybCfBD",
    poolPcTokenAccount: "3WuvWRBqCtw1zqKmgZ79t5QK8Ph7Rfwf7nYB8Tv5KV2C",
    poolWithdrawQueue: "B5ixFzgKhBysnWpJcEiozrf8Ykc361xKwkKstWCBLggW",
    poolTempLpTokenAccount: "F7NwbHNfgU9p1iQAkjDs8HnbVVDsCXfSxv5jn4LxUxKn",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HZCheduA4nsSuQpVww1TiyKZpXSAitqaXxjBD2ymg22X",
    serumBids: "AaWuUgau8jRbbo2tVv3oFcAUyrSPXQxJkPUYsUPeCFe6",
    serumAsks: "HFZCap81Q9JAuySeggJrQvw9XJuVdbb9R617BeTnsZbA",
    serumEventQueue: "DQZDYYbCCknsvAUadroAs3YPH8XU4Bo7iCmTy3GAWFrF",
    serumCoinVaultAccount: "69bNeKy1gM4xDfSfjCaVeGpoBR2hPeXioJMNShu1BjdS",
    serumPcVaultAccount: "Gzbck4nwKYEEmwHxJxBpBpGhuMZaDhL1UqVBVFTrReki",
    serumVaultSigner: "2qodg1XKZ5hauWnz1hBBfUWzMbRqABym2hMgLSS7pmJ2",
    official: true
  },
  {
    name: "weSHIB-USDC",
    coin: { ...TOKENS.weSHIB },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["weSHIB-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "SU7vPveBjEuR5tgQwidRqqTxn1WwraHpydHHBpM2W96",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "GQBHmoAkWiXEsoGYBqFGifCwDcfU2QYCwL8GHWFAbBqZ",
    ammTargetOrders: "m7JmrtyJq4CxTYPmB3WKMVbsDxge8SD95rWHb4WREEz",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "Ar37g5ebxRMq1NJyswFw9JKwRzZ8CzVr9SEMFH5wy9P8",
    poolPcTokenAccount: "EGynHanKeLLUYeWFE6ULXE1QRD8YPTV7ehSnphWsLqq2",
    poolWithdrawQueue: "5VBUYLnVPHKtiFSqSEhaANF5fXv7QzATRB5BRHrQv3B",
    poolTempLpTokenAccount: "G5Wrnafh95moPCxvKM5QNTMwAFQMGnnB9YTh24TvWnrD",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "Er7Jp4PADPVHifykFwbVoHdkL1RtZSsx9zGJrPJTrCgW",
    serumBids: "2FkkrUR6MWq7Qd1LLMnR4NWmKcnqkNhK6NK6x7Wi1aRD",
    serumAsks: "2Qxa2n6rRGm5f3Qc8H9HDV7wYsjnXZuXEWjgQs1bEwzK",
    serumEventQueue: "5jGZmP29GfcEWKVHGxCymuD5qGg33kM2rPfPvD1BFS35",
    serumCoinVaultAccount: "7nbNVNdhzZoD3KdjKnGRXbb9pPnDP2CSK1tPoRNvq94m",
    serumPcVaultAccount: "6ovLsr9T6754PrgH3QwFCPtjizWEh6H3DDpc3QXnMsqi",
    serumVaultSigner: "HoDhphLcgw8hb6GdTicv6V9are7Yi7xXvUriwWwRWuRk",
    official: true
  },
  {
    name: "SBR-USDC",
    coin: { ...TOKENS.SBR },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["SBR-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "5cmAS6Mj4pG2Vp9hhyu3kpK9yvC7P6ejh9HiobpTE6Jc",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "8bEDWrUBqMV7ei55PgySABm8swC9WFW24NB6U5f5sPJT",
    ammTargetOrders: "G2nswHPqZLXtMimXZtsiLHVZ5gJ9GTiKRdLxahDDdYag",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "8vwzjpW7KPGFLQdRuyoBBoiBCsNG6SLRGssKMNsofch2",
    poolPcTokenAccount: "AcK6bv25Q7xofBUiXKwUgueSi3ELS6anMbmNn2NPV8FZ",
    poolWithdrawQueue: "BG59NCoZnxqSU2TQ2DNsENiCZci73BcRvXWtqmQhNrcw",
    poolTempLpTokenAccount: "msNco37chvHeLivUwoetEnHDFZxVNi2KXQzjGAXkRuZ",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HXBi8YBwbh4TXF6PjVw81m8Z3Cc4WBofvauj5SBFdgUs",
    serumBids: "FdGKYpHxpQEkRitZw6KZ8b21Q2mYiATHXZgJjFDhnRWM",
    serumAsks: "cxqTRyeoGeh6TBEgo3NAieHaMkdmfZiCjSEfkNAe1Y3",
    serumEventQueue: "EUre4VPaLh7B95qG3JPS3atquJ5hjbwtX7XFcTtVNkc7",
    serumCoinVaultAccount: "38r5pRYVzdScrJNZowNyrpjVbtRKQ5JMcQxn7PgKE45L",
    serumPcVaultAccount: "4YqAGXQEQTQbn4uKX981yCiSjUuYPV8aCajc9qQh3QPy",
    serumVaultSigner: "84aqZGKMzbr8ddA267ML7JUTAjieVJe8oR1yGUaKwP53",
    official: true
  },
  {
    name: "OXS-USDC",
    coin: { ...TOKENS.OXS },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["OXS-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "8ekXiGjEjtWzd2us3rAsusKv7kKEhPENV7nvzS7RGRYY",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "G1vzK51TP85Vr8bcfoDkLDakySNSruTp3Fw3RhB4uvWs",
    ammTargetOrders: "23VaWFz63uXWpkkwoTezADokmpSbWwXfRH2AgAFMBHTY",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "DSiQzr8a4pEwoZa5TE8KdRBMwUoUnHumg7s2Q1vH32G5",
    poolPcTokenAccount: "5zRG6Hj6QJ51h28yreTdUQpFEDikgu111XUtRNXSAKM6",
    poolWithdrawQueue: "a3q6KagLNFZqLFZviiPeQLNveHz1Duq1nrgGcRgah7v",
    poolTempLpTokenAccount: "F4HmaY8u6x3rrfrLVHjTVjKEcGn58LjnMc5viuvqKZ5h",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "gtQT1ipaCBC5wmTm99F9irBDhiLJCo1pbxrcFUMn6mp",
    serumBids: "834hHw1CGbyXRjPD375P5pdhtaXhEphdcrjxFGpXHPVh",
    serumAsks: "6tf7B3V8hYnqwoqUSYTXYWBULLx2hS8TfHvB2roV3YAz",
    serumEventQueue: "SFUvgUFF2CKxS6QAtCfsbrN38QK7Bva1NHrhJ9nxCkd",
    serumCoinVaultAccount: "GSpz3LmstYiUEWfTfFcKt6hv9TDPWg8Yxneq8xeL8RJ6",
    serumPcVaultAccount: "Fh8X13tSH6RfwXdTudmzEWHEcnTMJfM7HbVf4rUNUXhy",
    serumVaultSigner: "HuseDRZYHcCPFSuzhdRHvs2M4dfCWr5ZXENu4aiUtGqx",
    official: true
  },
  {
    name: "CWAR-USDC",
    coin: { ...TOKENS.CWAR },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["CWAR-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "13uCPybNakXHGVd2DDVB7o2uwXuf9GqPFkvJMVgKy6UJ",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "E6wZo9uiPf156g9jG5ZWX3s23hM3jcicHiNjMg9NTvo3",
    ammTargetOrders: "HnX2KEKgXfPbHoFCSfZydDDYm51DwdkXcibWP9o6sP9Z",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "2rgPoyabSPeYoMiACSp9UcqG9WEBhDdXDmGQ4XRoBeo7",
    poolPcTokenAccount: "CzynpjFdoLekUGMPRNT6un5ieg6YQyT4WmJFKngoZHJY",
    poolWithdrawQueue: "AwYLatzaiaRG1JBQYevogqG6VhX3xfF93FHt4T5FtQgy",
    poolTempLpTokenAccount: "4ACwuir8yUrYQLmFDX6Lsq8BozEizKCVdRduYuUyR4zr",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "CDYafmdHXtfZadhuXYiR7QaqmK9Ffgk2TA8otUWj9SWz",
    serumBids: "A3LCjzPEE9reQhKRED1TBGBG9ksL45rhLxh4fRzThWXJ",
    serumAsks: "53krdJQgxmTaJgBPQ1Kc7SKLEEosvYs2uDYodQd9Lcqf",
    serumEventQueue: "224GEWPVsY5fjn3JqqkxC7jW2oasosipvWSZCFrpbiDm",
    serumCoinVaultAccount: "2CAabztdescZCLyTmUAvRUxi3CZDgtFPx4WFrUmXEz8H",
    serumPcVaultAccount: "nkMvRrq8ove9AMBJ65jPSsnd3RS7kvTTh5L3jN93uNu",
    serumVaultSigner: "GiVPfzeddXAbneSZWZ1XrNAZvB7XhNFbJtck7skN6xBE",
    official: true
  },
  {
    name: "UPS-USDC",
    coin: { ...TOKENS.UPS },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["UPS-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "FSSRqrGrDjDXnojhSDrDBknJeQ83pyACemnaMLaZDD1U",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "AQLtFoAuHCbA6uLwSgWyweQ1wbk1ednmg55mzZV3M7NP",
    ammTargetOrders: "4SSCpJvq7XQVzJVwxUdR2QJLM6j29ye3LVBUW6gz99Fb",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "Ft4UpV7G6eKVAL8YrsDypjAYv21cNEwvquz9WTEL6AA1",
    poolPcTokenAccount: "FZpxvgZHoJxF96H1qNjj93dFYVVfm22TfDavfbojL1ho",
    poolWithdrawQueue: "DuPqYGfu3L6G7ebZ4KvP83UTE7p3v4Q6LYYzhs8iMVWs",
    poolTempLpTokenAccount: "CS2n3zncd3mPpK8BEecuoPW4hfVYgoN4UVaqWsQGTPdL",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "DByPstQRx18RU2A8DH6S9mT7bpT6xuLgD2TTFiZJTKZP",
    serumBids: "CrYL51GW3yPeekGM8ZNitiAB5ZL6Y4egNJhf8DGBUAmk",
    serumAsks: "5NHhazJmYGnYsXdMPnn1hKMhCXg8U3xpJWdQTTfdwn2u",
    serumEventQueue: "1PjxFWFojvxPxJWXGzJap5cN8dcxHLVyDgofruMxLSa",
    serumCoinVaultAccount: "SnDuSUVuEnNPBhn2wPVNrAQz92Ri2hZB9ixZEHhWGCE",
    serumPcVaultAccount: "DRyGXiW5c8SAq3c8oYt4aViY8rqL6BQrozMqw1yZSQAV",
    serumVaultSigner: "4WYVAki32938cxiWKcWsAxoGrtGP3LmP6oBsiujLz8sE",
    official: true
  },
  {
    name: "weSAND-USDC",
    coin: { ...TOKENS.weSAND },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["weSAND-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "3cmPpX8kKzEra2umtLCDxMfjma82ELtAMaSYVmdaNLxi",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "Gwd7zQAHr3bkyGkNRrKM5hZwUVsjdBEeyNr8ME5cqxUz",
    ammTargetOrders: "9wu7YGgankeWkeygE8Qt8A5qHeycDp9vBTSUsr85QBzZ",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "C1MF3pFLfRBzrywrMJvHPP2EUjCQfKYmyW975rdkXB85",
    poolPcTokenAccount: "5mLSVNzt7juMjxXohvvwHZdojG81GbdFrjYxgsSqDnNH",
    poolWithdrawQueue: "7XpC5EC51j1WBz56Nr9cq33akEeaU2NoA7MQ3NMYNjMX",
    poolTempLpTokenAccount: "8EW9HQ4QtXTFSyZ6LuLk3bRUvi1MsPVxFKmUqd37a1vh",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "3FE2g3cadTJjN3C7gNRavwnv7Yh9Midq7h9KgTVUE7tR",
    serumBids: "HexBvvrL8jZRGti3zXZ6vCXqDzJ7skgSaMgqLJjzXaCm",
    serumAsks: "224juRrCj1VeeiG3qoXLDrJkGPSh8MJH2XuEsLCHLLj7",
    serumEventQueue: "DY4P5LEdehACn83akvVb49MNJf5VhDQuWTxfx95nGdgY",
    serumCoinVaultAccount: "2t3MMN5FLMqsieeUsQK8nfM4YKQobK5ZvDgjNV6hn7SW",
    serumPcVaultAccount: "55SiYWMEP7XrMvP31YhZQE1YTkypv6yeDe7Z3663pMfb",
    serumVaultSigner: "FLqXAFVSveyKjtfWpfT8ttrn3yUAzoHGKiYwcR5r6tp7",
    official: true
  },
  {
    name: "weMANA-USDC",
    coin: { ...TOKENS.weMANA },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["weMANA-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "7Z1c6GHutf3q2MNheyFE8KMNVEALuiPaqoEMyjbCbuku",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "59ceFXHiqriiFLGqwabgVwZncq86hEw6bLyq3unDPnSG",
    ammTargetOrders: "7gKNnFvzT7yrvoPnQakdV7BpCRAELnGBnn3dQYEojqHd",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "2A8PVremRfR6SLAaX5qPBqatzcufr6pg8wdaD828E8FC",
    poolPcTokenAccount: "4XdAP2fmGo2ziQUAjDxg5y4jLhSy2ShdJE5TFg3jjxYG",
    poolWithdrawQueue: "C6hV97zRb4WubTtwXsHTFEYLhu8vamSCCs3VmzkqSSyr",
    poolTempLpTokenAccount: "3a8FXTm3d8RUZm9eXAGSxLQiQUCnu9ox9qiSqd4WysXX",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "7GSn6KQRasgPQCHwCbuDjDCsyZ3cxVHKWFmBXzJUUW8P",
    serumBids: "FzD4EpQmwsFhAeRJF1S6efp1uqkgJ8hqWrNkWoCxMJuc",
    serumAsks: "HLYwubWymYFtMhgU9BcNz8ngsKGNDSjQzooWYbuQ7Pze",
    serumEventQueue: "JCxtKZBuqYruJm7TZpd9DEtsSYcq23dc42dRQz4wf5Cq",
    serumCoinVaultAccount: "3mmhhvfLeHMtTMm17r477rcnbVUtRusqVgQ3wZh8hepV",
    serumPcVaultAccount: "9FgALLcqFUn1o3tn5NPiEhh7HRPYr1n25cAXhcDjfGNJ",
    serumVaultSigner: "DcxxF4grETLsyYWkqAzT3MYUFAE2VA4fRs7i4Uu4K7dv",
    official: true
  },
  {
    name: "CAVE-USDC",
    coin: { ...TOKENS.CAVE },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["CAVE-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "2PfKnjEfoUoVDbDS1YwvZ8HuPGBCpN831mnTuqTAJZjH",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "ECG1LTHELj27wyKVz4DPCKdFB8mthqEwbnPeuUzkgz2H",
    ammTargetOrders: "H4vuXiWxuKLec3TLrZk3QgJMsLH4Y2L6E9LosnefFMyR",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "B1SCcyk4AqQcn6RY7Qjqj8rE53DDZ7N2eiqtMNcmfZxa",
    poolPcTokenAccount: "2HUjTaYw3mmU6kRA3ZfC4MGSzUhr2H6ZUQCWWdrfwUB6",
    poolWithdrawQueue: "83z9iqzrGv3ZF1aQ14i4cfLGLJ2yH2uBByMQe2347EjB",
    poolTempLpTokenAccount: "BNfk8c5CYcA7Cyg6iRNTBRwhEuhKARLD8toBzdxtmRJt",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "KrGK6ZHyE7Nt35D7GqAKJYAYUPUysGtVBgTXsJuAxMT",
    serumBids: "73yb9Y8cZfxX8KV96dMXVp5tTfu4FVjPc9LchtrzEdUu",
    serumAsks: "3sYKt1KYtB2Ycnf6jzNvnji8wUCWbsu9ZcA4DboiU1FH",
    serumEventQueue: "D6PsDqCb5BbAhXfaLA9AtYz8SHLCUtdQSmozu7T4JGJe",
    serumCoinVaultAccount: "2ZzE1FQixLYqw94htVYn99kSH1LE35De3d8XeWPnypte",
    serumPcVaultAccount: "8oVmJ6vT6kMfWyRETDjuo4nAZZZC3KSNZBjsHzEDQDLD",
    serumVaultSigner: "5bXbwUkB14na4uBAjG2u3PKx9BMV182T68EjgFV6duuz",
    official: true
  },
  {
    name: "GENE-USDC",
    coin: { ...TOKENS.GENE },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["GENE-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "Enq8vJucRbkzKA1i1PahJNhMyUTzoVL5Cs8n5rC3NLGn",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "7dcfFNqaGnHrUB1bg1mEbvJsvsvfn7oamkpjDdt7ykUm",
    ammTargetOrders: "FrJ5aM3Vi1DyxNfSbqq4vPYX3S9kH9foWMjqHjHGQq3E",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "6yxszHV62pCjHtGijwgroqRXGVLuoiHUFhcEoHQepB91",
    poolPcTokenAccount: "6AovHvG7UovcavaJW6rEef728JtFV5adZ9MaNRBcX2nH",
    poolWithdrawQueue: "J6YMSZfmy68QLH4R5gv5wasyF3pTVBF5CgkY6WaNwaBD",
    poolTempLpTokenAccount: "7uNG8iCJNjN7xRDXAvb1afGAvd6GQitQ7K7chhTy43w5",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "FwZ2GLyNNrFqXrmR8Sdkm9DQ61YnQmxS6oobeH3rrLUM",
    serumBids: "CQvBaGPpjn9aSM5VJYmXSxjrqG79aqF8wPAbuCSWhPtz",
    serumAsks: "5R4k5QNxtN1zcAiCHR4h1FmmBdpajvF6EeR3kuoMYbu9",
    serumEventQueue: "7MQzBut5taNSxbusoBnuuLB6Bmnfo6wm1Ukze5B13Uxd",
    serumCoinVaultAccount: "AjKhS74QWgcatcJvHDS3fdCJq8BdAsrHxzcoNyT738Hy",
    serumPcVaultAccount: "3xtHLByKqJzyvu3TbtDW8cnzJTbdRLKRjihWo1fVM5Fp",
    serumVaultSigner: "CTWJZKgSwanoom2Bb9QiNKj6mrDtAMPFe2UUh8mZx9d5",
    official: true
  },
  {
    name: "GENE-RAY",
    coin: { ...TOKENS.GENE },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["GENE-RAY-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "8FrCybrh7UFznP1hVHg8kXZ8bhii37c7BGzmjkdcsGJp",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "3qTqthYwuZKNQKruWJRGnubfXHU4MyGnvmoJcCbhELmn",
    ammTargetOrders: "HwwQ3v5x3AdLopGFdQYZmwK7D5YURpFoDJcrbuZDsMHm",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "FMxYRoHA3Xn4Su62GCwofmdALGdn4s16S5ZA4C91ULbX",
    poolPcTokenAccount: "3h7PhXbCAGvtQHqwTS2V3Mhc3fK8E5Hs8EbgCVHkQFwd",
    poolWithdrawQueue: "HW7QPs33Fzw9uME7gqs8DRuvbdP24WFc8jfpBQaqdi5C",
    poolTempLpTokenAccount: "CJbRPzdxPXEbyfM4YKinhojgmJv6yjcwaWpgvFYL4umz",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "DpFKTy69uZv2G6KW7b117axwQRSztH5g4gUtBPZ9fCS7",
    serumBids: "DntegVqu4W73GAywDMnNNZv1RhzMnvg2ZG1SpEXiZCjb",
    serumAsks: "CfTMiXZnDvVEyBAoXrNhf2mNBRJ5WCQh4JEwHXMoxh7o",
    serumEventQueue: "CTe9iXRYZJ35xss1KsiFXJHS9w8638H7RKwt9WUdtznq",
    serumCoinVaultAccount: "53zLrENukPYyMTgHtgLaPaSVUB15YphguocAC4b5nFbK",
    serumPcVaultAccount: "4ZTZ5khpqH4jBELchj4g8kcDZUcpuyWmMkj6ajycwGRu",
    serumVaultSigner: "SDSGfMSBFpUZWKZcsHSkLt7FGD4TQPjWNk2fux2asL6",
    official: true
  },
  {
    name: "APT-USDC",
    coin: { ...TOKENS.APT },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["APT-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "4crhN3D8R5rnZd66q9b32P7K649e5XdzCfPMPiTzBceH",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "9ZkyYVUKZ3iWZnx6uJNUNKdv3NW3WcKNWZMg2YDYTxSx",
    ammTargetOrders: "FWKNVdavvUKdcpCCU3XT1dsCEbHF1ak21q2EzoyMy1av",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "6egmkyieHa2R2TiVoLkwmy3fXG1F8EG8KmEMBN2Lahh7",
    poolPcTokenAccount: "4dcKsdDe39Yp4NDzko1Jv6ViSDo2AUMh2KGxT6giidpA",
    poolWithdrawQueue: "FwSCPqMixHerULmKCuaxU8VzUGmMVTUrbpNUaY6EwBgP",
    poolTempLpTokenAccount: "CCxPRM9viLU3nr82UcgqgUkyTxM1NTW2a8DtwR9NwSAP",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "ATjWoJDChATL7E5WVeSk9EsoJAhZrHjzCZABNx3Miu8B",
    serumBids: "5M3bbs43jpQWkXccVbny317rKFFq9bZT3ccv3YoLSwRd",
    serumAsks: "EZYkKSRfdqbQbwBrVmkkWXmosYFB4cVhcT4jLT3Qjfxt",
    serumEventQueue: "7tnT8FCXaN5zryRpjJieFHLLVBUtZYR3LhYDh3da9HJh",
    serumCoinVaultAccount: "GesJe56oHgbA9gTxNz5BFGXxhGdScteKNdmYeLj6PBmq",
    serumPcVaultAccount: "GvjFcsncRnqfmRig7kkgoeur7QzkZaPurpHHyWyeriNu",
    serumVaultSigner: "Hfn1km6sEcBnQ6S1SLYsJZkwQzx7kJJ9o8UqwWhPNiW3",
    official: true
  },
  {
    name: "GOFX-USDC",
    coin: { ...TOKENS.GOFX },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["GOFX-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "zoouer92idprkptX76yvhp4stK2keTzJpMNkeLqtxAx",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "6jQpC6ZE5sRAPbfShTxymJLE5pXUM1AGfbmyyBddCP5e",
    ammTargetOrders: "5aDvGGEbb1ECP4yNEVdP9BbXFgX5Ut3Zb3dBjDsFQ9Kh",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "2RPyUYLEWRHXB7hN9p795gorU6bvPJ9UEKFniw4Cpgcm",
    poolPcTokenAccount: "eRtMAhZz6qXqsrRV9cgS6n6xQyvqwkTFZXaw5RP1yxu",
    poolWithdrawQueue: "FHLLxn9BTMF65qDc7CjHjN17qEoMVZYfgM9BTgwncGBo",
    poolTempLpTokenAccount: "AewsiURuxZ5McY3hi3zsKAgd2R7q2QWVMmWcJH7pAvaK",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "2wgi2FabNsSDdb8dke9mHFB67QtMYjYa318HpSqyJLDD",
    serumBids: "5iME2kvAv5jVsw9df7EXXUNQtV1uUyFtibeHj6fF5T3q",
    serumAsks: "3dBK4di97jAPzQAkz39wUwmQ6qbW98H1zsmrNxEUZVif",
    serumEventQueue: "CzKrdXjLtZRq3AyrwN9MZ667Ka9buVFESJUbEWBezxCV",
    serumCoinVaultAccount: "DckgBxFNQNQA796Jg12dRpCZZ1nBqus4PDbKQhfmJraf",
    serumPcVaultAccount: "2jZJzfVGgHdzVq1e3HpRz9U5HnByoazyMzQ3jexn4jUE",
    serumVaultSigner: "5RKd5tWKtvEocrQgf8vCo3BkPcjXYnTJWRBmNadCMemR",
    official: true
  },
  {
    name: "SONAR-USDC",
    coin: { ...TOKENS.SONAR },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["SONAR-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "CrWbfKwyAaUfYctXWF9iaDUP4AH5t6k6bbaWnXBL8nHm",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "Ei23wxsu7WVsXv72yaTohSVASLqseinqA7DqXktprSSz",
    ammTargetOrders: "NheF95jviuoA9Rv5QPQgXDT3oQUbyoHJcyY5yXAFFnh",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "DQX9NhwznyWTYcTJ8uiqZP3PrzqRmfGNj4XNQzVKG8hW",
    poolPcTokenAccount: "AseLV5kWbAjNETCKJsXcrrs6ksvBefEPdRa7pKXFsvYE",
    poolWithdrawQueue: "5mkppasqox6XpdcHhYAfM1GKTckQemqtANP85FphThw8",
    poolTempLpTokenAccount: "9TjtDU6TMgHqAEdnUTBCgVJapGsqKnDTCFzDG2y4higa",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "9YdVSNrDsKDaGyhKL2nqEFKvxe3MSqMjmAvcjndVg1kj",
    serumBids: "B6t3JoptHoNer3YgEUZASeQwcXEnhvGH4ovYeVdGW2c7",
    serumAsks: "ACEdfnzBEFRopUkLwqowPuQpiMbuYR4uCk85wdxUvVWp",
    serumEventQueue: "Vq6g4iaDJhqB8PeUPf99JixtpdQ6zrdXXNuQ2LrGyvV",
    serumCoinVaultAccount: "EzMjpFVMZE4VrqbeGCXssfvDbpvHGMtHvkiLbX1YUTs7",
    serumPcVaultAccount: "B8A7V1124ka8WVKDHyWMAgbHCaCdhbU7JHy2nB7e2o6E",
    serumVaultSigner: "44rLzbRfxmpsmHPZUEuLS6rxv9pyDBVnzUSps8mGaEr2",
    official: true
  },
  {
    name: "JSOL-SOL",
    coin: { ...TOKENS.JSOL },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["JSOL-SOL-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "D8pasgJWjP9wy39fzeD8BUjQMvYCZxABzPcnuoDSLHBB",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "2fXtmmePfWQTFuzCZ6WydnM96j4ZZjkbEhof2f9YnQsP",
    ammTargetOrders: "2Eh6QWELimVN4uKji1KWZohKtvWCERHf5kYpd45Pro8Y",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "8P81j68MyzuixeKE3U1yuCmEMcSKUWsarxUKCPjPqG5V",
    poolPcTokenAccount: "ygjuCz9gawcU35UHgc8y7xLYRd12uY8ww3ToSgyAVj9",
    poolWithdrawQueue: "vWmn9TmQrvthTYP5zRwaJba2PajduXakJQvE4sEQtq9",
    poolTempLpTokenAccount: "DQhW2UkMUJ3ZfkgfvjMGci1FHwDrAQU52sFTYsfZYZtS",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "GTfi2wtcZmFVjF5rr4bexs6M6xrszb6iT5bqn694Fk6S",
    serumBids: "4kXVcHe29TsuMPAhKcRjPEtZ3tnLWQLMe592jggAzshN",
    serumAsks: "Aw6Ris8FUTL1oQuqKrzmaWxQfmLun6ZD4vPzamFvdqEg",
    serumEventQueue: "Hb6GesB1688DUdyuvXqDZk1pUxRp7epVymAX8BLkUGcn",
    serumCoinVaultAccount: "CRutAjBoc5qABvZvBmnuUYQ1VFYjjBpfEcQxvAkyusLu",
    serumPcVaultAccount: "F54JoYXAR7m6KA4FHndF82W5kraBZvVQwqUyXRNcqDJH",
    serumVaultSigner: "7XhDQ1epCDMRX7gDEi9r2S7pbEzuyAH3PpNZ9s8Yz4Ht",
    official: true
  },
  {
    name: "JSOL-USDC",
    coin: { ...TOKENS.JSOL },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["JSOL-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "7e8GrkwsRm5sS5UaKobLJUNu9esmrzg37dqX6aQyuver",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "2GiFVts1PwwwKvw7n7cZkigCRfCXj6StY6dSMAzPf2A2",
    ammTargetOrders: "F3vk58GqNs11abuGGHRxnUUUHbeWF5Pc9Yss8sCVAVV5",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "DqUW9TqewcqnAn3k9XpYx2w88hskgxi5PVxZofyZduTr",
    poolPcTokenAccount: "HiWTWGm1hb988dwbZW2niFkrDQ9GpefGNp2aBwsc5V4S",
    poolWithdrawQueue: "3JXDWxCSRBAdP2yquoX4ypLVeTN7QkJVfvzpvgLjtKX4",
    poolTempLpTokenAccount: "HKjKJY9AUwYDujHt12mBsbp6AetDm6bMACQPbfHksT8z",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "8mQ3nNCdcwSHkYwsRygTbBFLeGPsJ4zB2zpEwXmwegBh",
    serumBids: "9gwbJpCGVRYKM6twn5tyqkxXEo49JMKp4usZJQjPxRg1",
    serumAsks: "CsaJr18TyYhcabQjn16HW3ZsSoUbct8NSLSKuUcbr1cW",
    serumEventQueue: "2zvmX9TGi5afJs2B6EPaPCBbHLkydAh5TGeCsGkwv9nB",
    serumCoinVaultAccount: "9uZNMq6TbFQWT7Mj3fkH7gy9gP5bdroJKPpDFyA8x2NW",
    serumPcVaultAccount: "9W3sz9P8LiAKDbiaY83cKssmuQckgFpzyKKXKYMrivkB",
    serumVaultSigner: "2J63m8YjYMr495tU6JfYT23RfEWwaQfzgQXxzctXCgXY",
    official: true
  },
  {
    name: "SHILL-USDC",
    coin: { ...TOKENS.SHILL },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["SHILL-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "FTyJCLwQ3YvVfanJp8mtC2eqmvZPpzSpmNLqWpaPaXbC",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "Fh4cmCjxTendCSrdKcihDhy2YXHQSo8AMZugkuYpSVav",
    ammTargetOrders: "8CQgNaRxHAXKi5vFLgz1tavbsc3Bi1q9P9dbV32kxt54",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "jkXEdAVTBeSjPBX2NtysNcgm9h5o2Sv1EbebCWFmxny",
    poolPcTokenAccount: "62S88DcNiESRWZYwar1nizpSMT83ahmps6FSZ4hU8WeJ",
    poolWithdrawQueue: "Fogf4YY75yUURLKjhWnfaKsGemsKDsR3qNVrQRw3HfqQ",
    poolTempLpTokenAccount: "2CcwbW3x1p4mK13pA3STxprkDbJnTSp851NwC5vE7UdN",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "3KNXNjf1Vp3V5gYPjwnpALYCPhWpRXsPPC8CWBXqmnnN",
    serumBids: "EkMB68wYrUFBFDjWfNqhH6vDy72wwGRJZwzMpWWNSrRu",
    serumAsks: "HqEzJdKq1FcHV9wDrygLsbfJx7vhVW8LEax1Gio3aa4J",
    serumEventQueue: "2CnKu8Xt9aGEShjtDVVYBRH7PpD37YeVxWrWpDExvXzG",
    serumCoinVaultAccount: "eSCLQn2TgtpDMGCRqmaMDuSTAk7JifTgJU7CwVtRWnH",
    serumPcVaultAccount: "BsJEDoCcd1EFjeVx39uffrp1WhcxJmE9H7U83Y3iTnF6",
    serumVaultSigner: "D1mYg9jbfCfxz1wFv7deSkqy92NGzxSFpQiScimQozpw",
    official: true
  },
  {
    name: "DFL-USDC",
    coin: { ...TOKENS.DFL },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["DFL-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "8GJdzPuEBPP3BHJpcspBcfpRZV4moZMFwhTAuXebaPL8",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "zZgp9gm6MCFSvub491ncJQ78zRF4WymJErhy2cR7nnU",
    ammTargetOrders: "GKo4P3uofE47wug87QE6QGSRHa8wBLDEiW4nXEWeDUb4",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "GteHVo2oJUJC2tFYe1QHS7MyasCVooPJdHfxwdF6hPZ2",
    poolPcTokenAccount: "FHqPtKCB2w9C94oupinMgykxuzjF6pQRVaBVNzqemXc7",
    poolWithdrawQueue: "495s2Vr8PPXofHsJtkvazG77qNUHrhEpS86XkiFrTQgp",
    poolTempLpTokenAccount: "6eXLVRMNEVFF7adfkbAQni537VrbPpR8LE3PEXbWxS67",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "9UBuWgKN8ZYXcZWN67Spfp3Yp67DKBq1t31WLrVrPjTR",
    serumBids: "xNgA2EugkNq9M9yZeshGSbP7Epy85p8NHhrwkffYyAY",
    serumAsks: "CcCDWuH5zW9577wtoMVUZU6PXoT5ZhiL5dadDo4124c5",
    serumEventQueue: "9U9u5GLjbNNYaqECQATcMAuETbnh2QGjpJJVGoFxjLfm",
    serumCoinVaultAccount: "CvCsGEAe3Lxwo7zQ5Acqd34jjpS1iFWKp9h9Vt2KExpj",
    serumPcVaultAccount: "EGiCYaiiL65yx8uHkQKAmCv8U1fuDN4su6pSdsL3tQqB",
    serumVaultSigner: "98fhGkizAxyzvsFZMAyt342wkNP6BGa8wfcHkJJURYrN",
    official: true
  },
  {
    name: "BOKU-USDC",
    coin: { ...TOKENS.BOKU },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["BOKU-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "FsERtRjCEQNyND3ccnMGrd61ntPmJ3tbZs4vvcCzMr1L",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "7bQ84DTTnHz3vWjXHHr6eug4zHNPqgUA2u3hR186CQUc",
    ammTargetOrders: "2rNGZ5DDQDTExPUDsWYgWHT2wWhcWkcz6yFzbzMaEfFH",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "He2merLuRCaccBvLhzmTGv5RyZuX77KrXYsDiegk1NBJ",
    poolPcTokenAccount: "zLGXRcckcM4dJnwha7zC9UfeCgxcFjqArtGjni53KFX",
    poolWithdrawQueue: "DDecdVYPEFJNgdrjYB5TKWLkF69qHKrqxWbPjY1FxAWk",
    poolTempLpTokenAccount: "8pwcYxTivm9q5Pwqzx5ui7QMDxPYpN2rY4Mqa9Wyrn4",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "Dvm8jjdAy8uyXn9WXjS2p1mcPeFTuYS6yW2eUL9SJE8p",
    serumBids: "5FG62Yx8e5cM92wTvHrLbw33qhRGEiiDtS15SeWyMPa9",
    serumAsks: "3XTkgrqXoLtMw3XGZBKq43RLfN8o5DBkZ8tga5jCEQ6E",
    serumEventQueue: "BMaiUbDPukghHMFFFNPSKybHEnx1GzgnZaA7Wfa8eQkt",
    serumCoinVaultAccount: "As6NSizcseTTvFStf5tAv3eitxDNo2djKE36AVsHvVCW",
    serumPcVaultAccount: "BqwG61kV7Wi1ZAsL2KRBqaFoczJFCjGXL5bveN6gr9xR",
    serumVaultSigner: "DsaKT6fZuBGcA25WNQHScrZC9AvqSYh6hnGQzEkrubBo",
    official: true
  },
  {
    name: "MIMO-SOL",
    coin: { ...TOKENS.MIMO },
    pc: { ...NATIVE_SOL },
    lp: { ...LP_TOKENS["MIMO-SOL-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "DqYSvijBXydSx9GfvVDjEzUg5StLLrkqZVPzsU2FeVZ2",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "GKSbpr3z4SV2AWmLndfw6FST3rNttyAzJKNvya8CQyLd",
    ammTargetOrders: "9rXzQFx2udvvDBkzzUAH7ASW4DFEzQYytT9fnDyZvgeM",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "EjrKJXurKjpxCXHcvLDdaN28tg5X2mhAFpi7vj4rPPjP",
    poolPcTokenAccount: "HZcZjZZR6t6kbXTZisLKdCRnHqFWACG9RrBvJKWaDyvW",
    poolWithdrawQueue: "CzDNWpq6Wh5iQfaCRb8HB7W92T6LSXKoyEwuk3eoi1iH",
    poolTempLpTokenAccount: "CLxnCgBv6pc9UD7cbqam67rYXjvZFvBhYPNxNCXeicbH",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "BBD3mBvHnx4PWiGeJCvwG8zosHwmAuwkx7JLjfTCRMw",
    serumBids: "5cabXo89gLZoQSG4AYxYqchkhczuwNRivz2U2BA1nk4g",
    serumAsks: "6wRsk3W1v5JMouuUzNjbevbuxA5onend9xEkQni7bSfP",
    serumEventQueue: "9PZ5J7LLcfv2nCjJb93wEjHUC2h5RCjZhTv8yLS6Dpcn",
    serumCoinVaultAccount: "4DVzV5Y4JwRQ6NyCnFmdkc8zqhuFrPaF319q8DRVQDGG",
    serumPcVaultAccount: "ARwUt79ZTCkkD6GtvwxLv72N4r6zQJjNykDmYcXDMwXD",
    serumVaultSigner: "DSc4PMo49kARDga5qpxGvmR8hYYyBNNKQb4Qr6nWSDYu",
    official: true
  },
  {
    name: "wbWBNB-USDC",
    coin: { ...TOKENS.wbWBNB },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["wbWBNB-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "Fb1WR1kYvG1tHu4pwAxXQpdKT8Grh9i7ES9rZusLg7D6",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "3AoL7SCi9ZKBAGoCdRvHwH3DMKD3WAv2Dpev4BkX3dYj",
    ammTargetOrders: "Hh1zHYam85KshQPkMf3YSDy7bD6fDuEa5WWjp7P35dqu",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "2WtQHGAMAhMsj3mR2wSPcUR7yZhYhuNwRZBxVPKcrCyb",
    poolPcTokenAccount: "4vrVEysPFSoS5YcZQwRUam8CbVgZehQdBVQ8yYbmkQSw",
    poolWithdrawQueue: "C8PrYX1SCwgpZQbDyUtGPYcSHkvJmxTB3QpHPjih4JRX",
    poolTempLpTokenAccount: "J9dA4g4JXprDMgqhC6vWyCk8pTPoYQtECK6krratyHpz",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "3zzTxtDCt9PimwzGrgWJEbxZfSLetDMkdYegPanGNpMf",
    serumBids: "8JJrdQEzMSoekpzy7qcYDs1hVJyWoRcfTHR2pGDgd7wy",
    serumAsks: "A3TmGhemkp8u8d5HCLMyiBByvwDtp7khv9Vt3p1cqH8c",
    serumEventQueue: "ZYhSiaFWkuNTBzRFM9UPJXwHPyTGbujCKvPXhbssYPG",
    serumCoinVaultAccount: "D77WaGjvSLwk6d3xdK9aEU3R7G5UKvqHrNAXmkHxjgh4",
    serumPcVaultAccount: "BwT7GkbKaQQqSCGwUjhtktYf6kjLvKLJsQA2j11jEAni",
    serumVaultSigner: "9sHBqMtqmKDftTLiAN19ngVFywHK8M1MGANuMoZoJaQK",
    official: true
  },
  {
    name: "wePEOPLE-USDC",
    coin: { ...TOKENS.wePEOPLE },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["wePEOPLE-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "GfvqUB36CPfqZDz5ntQ2YsoKRwg1MCewmurhc7jw3P5s",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "5ZodjQpktYCNqtLZLvYcDQET9UVsmya2wGzsdxGrxi8z",
    ammTargetOrders: "Tn2PqEet9R4jspxZ35dvrzDQT2LhicnbjznExJppKRw",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "3JyvAQagVdeGdmUqMHEYuGsCi4qZuTQwJsyHarQrAVYm",
    poolPcTokenAccount: "GuMPTZBkY9WjkcdzLfjGzDBb6S7ZuwLWvHHbAYRGdaKn",
    poolWithdrawQueue: "CiiZZRHdSppXEVjfGjZUpD4oB5wV6jMdgJcdGFd4Q9Eu",
    poolTempLpTokenAccount: "2eg2bvXrYRb1R73Uxa2SoYrcpQzZcx1eVWXni6hfs6jj",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "GsWEL352sYgQC3uAVKgEQz2TtA1RA5cgNwUQahyzwJyz",
    serumBids: "DNkoCo9nN7mnnfWEvL6Qp9cyn5BjqDgVrgX3QktkXdnP",
    serumAsks: "5ZJAmbMPvjUXR345TkCH7kxXaeCGHKnoozrUhzD4TxjR",
    serumEventQueue: "FQnZjJVgRrrDJGA9ohPUrdmWMbuGwCGTVeZLqv1zJoc6",
    serumCoinVaultAccount: "CGNexJSnAQFYZRUWj5cqtb9QN2wHNo1WxuGLErbHmxxU",
    serumPcVaultAccount: "4i1ZsFFcVQG1Ufmeak8ibU4ur88t4QFLonyh9kR7Eh8m",
    serumVaultSigner: "8EnrqayT31TqvUQRsCxC3ZZTNrTQjMNxki8MN71Hwp6B",
    official: true
  },
  {
    name: "XTAG-USDC",
    coin: { ...TOKENS.XTAG },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["XTAG-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "Hv1BFhyADPjYXTqEeMgwzoybnNwYrHXNv7U2VjcAuEDr",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "JFR4ZGJwF2sA7q2Fkve1be39wnbV8EKmb3BTCi5grc6",
    ammTargetOrders: "7TeQ8U9pZEA52Cek6FVRNisLsgsPwFy7EEUiXAiyjWQV",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "3UJZNSSi8JkeA9dP53Aok8EHbgE82K9HYKAGkgyxjyur",
    poolPcTokenAccount: "6tTg68RpRDjVuEda62ihfTxsiMCN8Vpox4E9WvW5acRa",
    poolWithdrawQueue: "4sWDRH7J6JU33y8JLshEt3oMSYXxw5H2Avc4DJCmMfwb",
    poolTempLpTokenAccount: "2KzSH7behRFcovtVqxQ2Xz3MmDga3tLECDP11UXJqReA",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "6QM3iZfkVc5Yyb5z8Uya1mvqU1JBN9ez81u9463px45A",
    serumBids: "6Z7VQehWjM831vyTTdJnt1NyQxhXtwLKKHDjhiey1MJb",
    serumAsks: "uD6PfpLoCihKD9uVRm4AE1tb1XsAneyMKtsJu43ynYY",
    serumEventQueue: "9qQA1p3YW7LMEF3kqsYT3LsDw4GwMaopn1ghzWnN5RdS",
    serumCoinVaultAccount: "5cBmqRj57VW7bpK9RscDyJjcu7S3QNUsML3axNxA3ja7",
    serumPcVaultAccount: "J2Yw8yeqdh89mBQfSkEnhQXudfgiuy6G11s4cduQuiN4",
    serumVaultSigner: "FLL49yBue1tqWDjLW9ztRaVULZz91uKsEjzJ6h5scgqt",
    official: true
  },
  {
    name: "KKO-USDC",
    coin: { ...TOKENS.KKO },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["KKO-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "FvN7dJz7GX1XB1BTk6jD5rEKRxQc3ZwNkWJKai5sBJWS",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "Hh87TCaD5syc3ssin4kt9gdmoMwqYbQRC4ABw5bvD6vo",
    ammTargetOrders: "A6qas7S7Y49oGbF2zApeg3wmZPbZqqCBewmbMRraGbJt",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "9RyM5aXG1wcRmiGYLRTas3gySyoPvFCRcetTQGrVbPQ4",
    poolPcTokenAccount: "H19PNJ24H3zMheS2wyGzNoN29dWZ2JxrQgBmqSeFJmb7",
    poolWithdrawQueue: "BuhYTCcYtdULF5PFXQK6vuHCieVvCGq9tMX4nXHN8X6q",
    poolTempLpTokenAccount: "5a4VLYXVM3f4mZJKy3mnnkn7kW8fhWoTEo4MZ33gojVH",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "9zR51YmUq2Tzccaq4iXXWDKbNy2TkEyPmoqCsfpjw2bc",
    serumBids: "FtNaV9qZJV2LgfiYhjCqwAmLkkspnmEe84ctytYhKHUi",
    serumAsks: "HMifR9pTkhHGaa31LBUFr8KD4ggRRRhH5NoG5ZjuHA6C",
    serumEventQueue: "BSKDaDGxDzhLP91fSK7dL42aYrjJiSNazmgSV3VEyCsr",
    serumCoinVaultAccount: "8UyekuWh39J7YWEquLP5rft9aEgCmBRTzKwCDjhbq3dq",
    serumPcVaultAccount: "2w4EZCYF8HMLrAFcDXefZcVyFfSJLfFyFRTSaoeGXyoQ",
    serumVaultSigner: "7ieataxFqG3ob8dFXgNkNjjmoWqEtJ17wHFcX7RXZMaU",
    official: true
  },
  {
    name: "VI-USDC",
    coin: { ...TOKENS.VI },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["VI-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "MphbxYtji1FSkm7G2FNGpUUz5AWn7iRPNFAvEqD4mzE",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "6zLi1A5MYMVBtaJ8T1Un5MYoNvvaLBXo3Y1wSytdxG9c",
    ammTargetOrders: "FavPWAiHfGL1rYGwWMMY26B8bA6y5pkhbdq6jvv5FvM2",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "8TePpe8C43YiphVZQPyeUUL7dy1gv1vu99bwMLrnxDUU",
    poolPcTokenAccount: "Ac7fBPfyitRUgN2nTJ56nGfuYK6NXsC96aKgDgZSCReK",
    poolWithdrawQueue: "EQtU6bpd6AX3C4LnzXXHbuyrooDQE1a6xgvoBfBFvrx7",
    poolTempLpTokenAccount: "FWn67c222MrFFuvnAQvFHFksqD989F8fPkX8xqWBCrK5",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "5fbYoaSBvAD8rW6zXo6oWqcCsgbYZCecbxAouk97p8SM",
    serumBids: "D6eckG9iezMUAqt4E8vwHt9enkV9Sw3Fyj4fFPCkRaRW",
    serumAsks: "32HGbWJsPr1bZd8XnvESgCY94XK4hSLypfNiEDxFzDve",
    serumEventQueue: "BcFtMNmx5B47F6VXocr9YJqCWHLybayC67rvKtaZ7iS2",
    serumCoinVaultAccount: "9sS11MD83k3Zn9VzYzyEZSviSXwJtUtVnc9NMq4MUpkf",
    serumPcVaultAccount: "HQhCfR2hUgMopxh2dpfpTGccG55gGpwn2QNJCHpvrcyL",
    serumVaultSigner: "14jVcqFL27atPUFhYoFtVgbCa2tnvfeayNqoukaPfP7h",
    official: true
  },
  {
    name: "SOLC-USDT",
    coin: { ...TOKENS.SOLC },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["SOLC-USDT-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "783kPvwHwDXaU32kV8NK5dB4JVeMWQwe8a3WUNZFpupr",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "CxevWceR45vLckW5GwJf2P8pBHgivG7X852z43dwHzFA",
    ammTargetOrders: "BQi5hcjDTGFVE5KkQu2aoqzcSWVV432k881Zb8BEMnyT",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "GCiihp9tZEcUbXuvBk2B5xaXq4KjCoHunmsVMQaFHKJv",
    poolPcTokenAccount: "9ZsiqAMG5dnpjwRFxJj3zvHCsYYZdZNJmP8fYfJkR1VZ",
    poolWithdrawQueue: "8EFyi6Lz1DbavbwwVg8rAVfuFh4au2cxCdJbxYdrRkaY",
    poolTempLpTokenAccount: "G49ujYznJPAhZS6gZHp8gfFNrtNKvGCYtZPhBqvWxRQz",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HYM1HS6MM4E1NxgHPH4Wnth7ztXsYTpbB2Rh9raje8Xq",
    serumBids: "5RrrwmRQcHsrWyQffDbNQMPATdM6W21kHbvdUT3L4n1x",
    serumAsks: "6JXFumfL3e3DhK48aR9JhjKQRGqWW8nWPXkB8GuAbYZU",
    serumEventQueue: "4EPZfsmz8JgmdbgEY7zZ9rxchqbCkqXFWyvHtL9j3zx4",
    serumCoinVaultAccount: "CF3iPT4V6HrD1iN3kVka2LFkDnYkNfJbgWqAdfFwK7XG",
    serumPcVaultAccount: "H5KmunmdEYA6FpiDAQPH3xXKeTtQppkiDL27ccvoSiCL",
    serumVaultSigner: "39uZFr8KuW6puPcovZ8h3J7xCToEQbySsLBN2UGUEdSG",
    official: true
  },
  {
    name: "STR-USDC",
    coin: { ...TOKENS.STR },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["STR-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "E9Z2JeEKS2WGGyA18mGU33rnQskK9moPhM4tdzrv24fh",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "2VXhUYA8r9dbajVrpYPhph2n4LMTHvPq9FZxePLojMh1",
    ammTargetOrders: "9Z7bnGEZj6rrTepJcf81mpgFT6CVQ5YehuH5aNBgi9cC",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "GwDeKNzQGLimDszBhpikJ85Kzngpsor77ts8Ry2SEwtg",
    poolPcTokenAccount: "2RVjUrDtQVWL4j7nyYx8kDhifmhxAsZM7JRRETm4g9xy",
    poolWithdrawQueue: "F8jtVFch1Eu7GXNnAqC6vqsxyoHfjpxriFf6Zzv4TKju",
    poolTempLpTokenAccount: "BZeJqKxUTrxZ1zTVFUQ7xX5NDLwdwTEQYz9dJrPktE1Z",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "6vXecj4ipEXChK9uPAd5giWn6aB3fn5Lbu4eVMLX7rRU",
    serumBids: "EYHrFmKz2dH7PVRQ5GXg14DRSC9sHAd5QhgazjHBQH2t",
    serumAsks: "8sC4E99kYkaYUK2G3AdXxXGJAapwBcdu54mtosQFjZZk",
    serumEventQueue: "8sPnF53bonayqHfr73apPmpivx3ATH8YE4Tzu3JMCHLv",
    serumCoinVaultAccount: "Dy27M2AeDz3DfxmrV6JZQ8CRMzrz63QAMg2YCUaWF93x",
    serumPcVaultAccount: "HwTt653QDLgHKS4BjaTSFXjrJ1jVLKSTP7uwHLNNarvR",
    serumVaultSigner: "6yCg8Dmgkg6pXoJBFEV7UFEWnLSPuAUAri9KTaVQ3PKE",
    official: true
  },
  {
    name: "SPWN-USDC",
    coin: { ...TOKENS.SPWN },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["SPWN-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "Bhw7DbVwWMcTBXoKaWgsCaofL6QqmQQ65FCSGfgCEawm",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "8jG2uaaeBSKDDCw91qoKD8zcyCmXVbjoVz6MwyoY9hY1",
    ammTargetOrders: "CHXWrG2DV2T6ty4tEL2sFWhNq8JyDeYRiEWMKT3k6Jhh",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "31ug6DXqFG94kza6rqEc2j4Q4PCCncXapAFZcxMg7nPA",
    poolPcTokenAccount: "HucTXQXnH7RgmDimkZZ5GuUTdXVjRnc9DwNoDaM5cVXg",
    poolWithdrawQueue: "C1uTwAJC6Vic3WXJC5iAFLvjc3sFwiGM8ATmhKkfZhkV",
    poolTempLpTokenAccount: "GskjHddFmXpj4RtMfCDmKscD9qUfDkEfzPp3b15ZeruW",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "CMxieHNoWYgF5c6wS1yz1QYhxpxZV7MbDMp8c7EpiRGj",
    serumBids: "5Mb67cTCeGgbEWwdXXw1qDTBeH27ZuHPEoLojqyDmwhX",
    serumAsks: "9o8AxfYsiT5cv63rR1zrYr7r6jw7bP3p2pH9cJNAVo6X",
    serumEventQueue: "2iTAShfDpxohfYM6stE3HVSUpXJ5m1sNzEFMeHKbAmQn",
    serumCoinVaultAccount: "EiQdjxmFWZeyRxizBfXPsXQrnsU6KfBvnANeXYvimELr",
    serumPcVaultAccount: "5q1aff7VkkyHB6LvRg24PVEZNJCDPzcQpp29DuP2Gfjj",
    serumVaultSigner: "E623iAaJJzw5NJLBCtpFZbcn8iEnY3BsFHYfG1CYf2cm",
    official: true
  },
  {
    name: "ISOLA-USDT",
    coin: { ...TOKENS.ISOLA },
    pc: { ...TOKENS.USDT },
    lp: { ...LP_TOKENS["ISOLA-USDT-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "69Mo81rUPDgru4UbigPQovx7cYBxpEm44qQok8wcut4M",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "G1qyfVQgaYrUxemLV4acWZg9RG3C4RD4XqHu8B1AgcxA",
    ammTargetOrders: "Eqs2SKiUBQadw5KbPhbKNFA7LmSjF2T6iY3cxqDj3JE2",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "Avh1uyt3sFu2FUUCoMHmWssrN3nPw5GrAMX5wLLefs2L",
    poolPcTokenAccount: "Zfy5TtPXCEK8rxSbp2cb14WCR4aG4qGsgJLLdC7gxGe",
    poolWithdrawQueue: "5Yhk3vYCDvmcRE9TQC5QREQw6fysTQRnZ7fXPqQdqdPY",
    poolTempLpTokenAccount: "CRDyUcasjeKwqeHziDXoHD7P9ho9K1V4aD7JN2vXJEm7",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "42QVcMqoXmHT94zaBXm9KeU7pqDfBuAPHYN9ADW8weCF",
    serumBids: "HNqcNhSHcXAcZJV45y4xyWqquuicdg88J73cTBbXLsuG",
    serumAsks: "J54QZ5LE535DVZxSzL45edE4d1nDrhbcq2NxrV9GTA6a",
    serumEventQueue: "DeypfVmbbp9ajhQdZCfx1EVkiEL3WVLPCHcRvTZgRcfZ",
    serumCoinVaultAccount: "FaRw8KMqoiuRAjunz2tDnJBVbPxeKKg8z4FNrHQtpnzu",
    serumPcVaultAccount: "59c3uxz4qgKonm48oBHuwqrL1SdMV4WudQAsjrgw39kv",
    serumVaultSigner: "GMYEbrinZLmPMY6FRnFdmuHbYZ9Bz1PcTWmjqBMK5LuQ",
    official: true
  },
  {
    name: "TTT-USDC",
    coin: { ...TOKENS.TTT },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["TTT-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "HcqHvH27wk42L1ND5YPhLDJu7oGsU7HGSreMiXdq5LNK",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "85ZThysvEWpvFQVaBySCjSufxBrBQ3x7oBM4Tb6Ltn7j",
    ammTargetOrders: "CJrGZVb2uSccqX98RyhukEPKWSMEuvcamnUuenLzj9pH",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "FEFD8JuYMeB3SRACZa5EsFJPoURHjsPsrKFjRpWJJr3G",
    poolPcTokenAccount: "g8uv7UBpdu9UkJCsqfMkGzMNtYqKXfh8m7rHFLNtmA6",
    poolWithdrawQueue: "EPyYVUgMAcY1Zu1vFD7aJPjPNpe18m7Ab4CVoV5AAp9q",
    poolTempLpTokenAccount: "7yFVKL9K4othAe5PcBXL3WNVM6ebtC4M1PLqP3RQWidC",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "2sdQQDyBsHwQBRJFsYAGpLZcxzGscMUd5uxr8jowyYHs",
    serumBids: "2TZ3U3wed6DeM6teUJfZCYFerthdG2xYKcYBUGZtTozE",
    serumAsks: "FTnrFFR7HtYFCi6citKX2NFgdAP2KumPdpSs23V8VQHa",
    serumEventQueue: "AVL9buJzjn69bo8ZtK6UacL7KaNKQSQyEJ9jPkmLjDbV",
    serumCoinVaultAccount: "HHBEQnNnPwMhRbyiVYvET2GfdFs2tUF4kcyYUd7mdU7k",
    serumPcVaultAccount: "AQ4XA4eUPbmkrxForC6P24gMW6ozv4XUY8HzuAs5SKsA",
    serumVaultSigner: "C98tgmCJpdXYgwsURupvWrA6zhzyGsbE3g4NUxi9PUG4",
    official: true
  },
  {
    name: "RUN-USDC",
    coin: { ...TOKENS.RUN },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["RUN-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "zuivKkgkNFFkV9jfNpsU1p5tWNbDWUEx5XX16m4k2Ej",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "E1kouJkEmATcSrsbCcZLYo5YJnYkXjAD8GwW5RC4evXb",
    ammTargetOrders: "ECzY8XJHTLLspi3zmqh3vkeZSj5Dswh47MwZ6TWHpBQb",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "HAULecjkcF2GHGSQ566yRBuwRoHxH24YGZs1n6B3QpAG",
    poolPcTokenAccount: "9mo6Dhx8RhrwNqxCBGcfqEZzmGPGr4hz1mfTdW8tpsq7",
    poolWithdrawQueue: "839mt1VUqTTyK18ibCoMoZ6Lpm2EmzyocSqjPYGn4rXc",
    poolTempLpTokenAccount: "4pnYCNbsdhywXRVZGWtGyEJ4Ng1CfYCue6xGJivKbVYo",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "HCvX4un57v1SdYQ2LFywaDYyZySqLHMQ5cojq5kQJM3y",
    serumBids: "6KgrT2PgdBQEfFctsXhgFbLKTbFErVj2SBa3zJTkSbLd",
    serumAsks: "EVtsr3WNub2i9jVBEj9aHmsxrumBFmHoLp6QyhuzFP5G",
    serumEventQueue: "EpwsM7YCYEaC2LynGVSyWNUYugaxNYymPgqAX1cAvhKu",
    serumCoinVaultAccount: "MhKHNubLV6SpsTosFSFnx2cPTxhfXZRYtsw97sN74eu",
    serumPcVaultAccount: "72SGvxnDRo9wuzcNrJxrpK5YNjXuwcfyBof9BuXELFhp",
    serumVaultSigner: "HxhgxLeE3agcvWNx9og8asUs7JKV8TXfQdo1qLK7uGUQ",
    official: true
  },
  {
    name: "CRWNY-USDC",
    coin: { ...TOKENS.CRWNY },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["CRWNY-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "4ELBQuq3ivhLamfCT36As5sXLkQDWRJw1pJ9JVFLp6gK",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "GLGAhYAAi8FuhxVys1ZqJZb1rw9p8JVM6YYxUeR9ZUfT",
    ammTargetOrders: "douEwhf1WA7ay18r7kGDYuwPNpBus3Tu5aApeLZGKSR",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "3dkMWcJkghmvGeQGFUr7nKYWZjYNdxWg9riaxtT3xCHV",
    poolPcTokenAccount: "B7JNDmk3YG6bGbqcDMcBpNQJqau3HJPeFwvHATdVZRsG",
    poolWithdrawQueue: "7yJL932ytN1pQQ6PYBbKt5eqRCYE2ixtGAdguv9mJV7u",
    poolTempLpTokenAccount: "DMzWN9j6ZMV6ebZ2ugW4ENvbsJUi1cJZBAAoZ9XQZzRs",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "H8GSFzSZmPNs4ANW9dPd5XTgrzWkta3CaT57TgWYs7SV",
    serumBids: "3onFzW294iJT3ZW2rbfFbH9jErD4mcZistyMf8Xbbf8u",
    serumAsks: "3chCWxohikbd9ENp62mLRSkjKi37MjokEUzLsdvtsyB5",
    serumEventQueue: "7pVNda7bdZzdrU7WVchS5u3gAYG9x6NNUFuD7wzRgn2q",
    serumCoinVaultAccount: "B4n994TDxFeAz35YMEQZJvkhVtHmab5PRQUjgtigScAi",
    serumPcVaultAccount: "2LAVDjbCkDPY4B3aLzgWs3VCEA2Rq6SJPjCqgBcB2N2L",
    serumVaultSigner: "HKdMHuRTgKEwGg26Ew1xUoGo4vesP6dN8dnLjFbDANfr",
    official: true
  },
  {
    name: "CRWNY-RAY",
    coin: { ...TOKENS.CRWNY },
    pc: { ...TOKENS.RAY },
    lp: { ...LP_TOKENS["CRWNY-RAY-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "HARRXESCwid3xMi2qThag1PXzmp6rDhAzMR9THhFRQGf",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "HN5KP7RDZT5w1oPB6GRrqawYJFrtrY58Ck2tDxVrD5Af",
    ammTargetOrders: "FERGssxP2qEN9jEjQ2frQx3ckAneXJzXf6JMXZYmMRc6",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "FZKDZoUDjo5Ck2apVqSyk5ppKuUqSbNQgg4Uu7y6tjuK",
    poolPcTokenAccount: "okPqapFBcHoRRYyER9a8z1C4xBuueu5RbJGGhJ8TemS",
    poolWithdrawQueue: "CNkzEN6tueKqHwD4JhAFQa6LDT3kfYx91jBPxB3nsiR4",
    poolTempLpTokenAccount: "Cet73tyKCqjjUJxBueqtGxzy7C6STF3vP2MVzaFD8ryN",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "6NRE3U7BRWftimyzmKoNSseWDMMxzuoTefxCRBciwD3",
    serumBids: "38V5FuifMSNoNdtCzPcxLuJzUQ2YAZ1w84pzqyQqwdCF",
    serumAsks: "Hz1qNHXFyfoz5FddGoszJgSp4dhaBn8GqbntUympRNkK",
    serumEventQueue: "CubKCz6q5Q8Q9ZnW5qTYY6M9q1WmEYuvuEtmKYbfjLjN",
    serumCoinVaultAccount: "DovSvXvzRUvUYWCzJCtbYHDGu9QTsfd4v3szLYK8qq9V",
    serumPcVaultAccount: "54CyipC5PJnmEHwCPqEgzPEPVEMRdPebCxpoUbZBeZmC",
    serumVaultSigner: "8NJSfgh9fPkRw1odRyJW2ftTeK5BnTUwKpiEGs93wktu",
    official: true
  },
  {
    name: "BLOCK-USDC",
    coin: { ...TOKENS.BLOCK },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["BLOCK-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "CfBSfVTcYFJsD8vZ2fTiMGkUYFim2rv8weAoqHxUU2pn",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "2ivrPyyMKcMmaAWcA6VReQ3qT41htQTJ4kfGcxGRiPTj",
    ammTargetOrders: "GBkiJYXviRDBDoXRbaK5BArHeisTYo3C65FgwjmXmCzL",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "GNzNnmSnXo1gABhtkgHvMfimQQMhwSz1RS4amTYaSN9y",
    poolPcTokenAccount: "BW2FHugQqPPgMrGRtfm1BaR5R3WP9TBCjnYt4PHcpbUn",
    poolWithdrawQueue: "2fzhi1Qxp4FvFk4WNj1SV8kKe7kF4ZQgwLoopkQ4g2iL",
    poolTempLpTokenAccount: "GF6jDvmss3JinbbXh9EdZUo343ZRoFELEzJgnGM4WwBL",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "2b6GbUbY979QhRoWb2b9F3vNi7pcCGPDivuiKPHC56zY",
    serumBids: "FEmTdsfmszMxwi34aawEsZPT1cWqa41StEBfYnnshDYx",
    serumAsks: "CMnyFZKG8zWWajbtZfduqtRX74cRyyVKXakM6NYe7MAN",
    serumEventQueue: "2rrYmuEieEyRTBKF39AqTdskde8kLfVSieanVWyCZNJQ",
    serumCoinVaultAccount: "6Fxz92QGSJrWEmHFuxqMJwBiq1MPxLNzQfKw5ZRsLWRw",
    serumPcVaultAccount: "LcANK8GJ4uY47QyDitYBiQUzHkHWKCuoPXdCq3YLxW3",
    serumVaultSigner: "5TXTSZpWoVoJpfdf848ov8pj9NYJZ7we9BM746sMUyfF",
    official: true
  },
  {
    name: "REAL-USDC",
    coin: { ...TOKENS.REAL },
    pc: { ...TOKENS.USDC },
    lp: { ...LP_TOKENS["REAL-USDC-V4"] },
    version: 4,
    programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
    ammId: "A7ZxDrK9LSkVXhfRTu2pRCinwYfdxW2kK6DaJk12jRWw",
    ammAuthority: "5Q544fKrFoe6tsEbD7S8EmxGTJYAKtTVhAW5Q5pge4j1",
    ammOpenOrders: "E1sVmUNF4iHXLLz4yQqYufzrmzvm9aCF6NPR5C328Dzo",
    ammTargetOrders: "9zHNsBf6kySxnPuX75muu6gm8STUWkyGjZ4od5HPmJBd",
    // no need
    ammQuantities: NATIVE_SOL.mintAddress,
    poolCoinTokenAccount: "ByU8cczVRmBw3TxdKD8WUHNZgpwDPZ9ZgHTdreeTV5oX",
    poolPcTokenAccount: "7GYr4FqaDsC6vUoL4nN8EfRUe1aoxbdv22jr4diurJ8C",
    poolWithdrawQueue: "F5fCEgeh9zCKkQgN6jKnxgeMXMoSWuLhX1HW9nUmZw9Y",
    poolTempLpTokenAccount: "7JWNRx2fhWthFePZtfSx3v2eDYb2xuqGDGg8ZabjPtAw",
    serumProgramId: SERUM_PROGRAM_ID_V3,
    serumMarket: "AU8VGwd4NGRbcMz9LT6Fu2LP69LPAbWUJ6gEfEgeYM33",
    serumBids: "G1K2p1C3S4SgwnFw4A4fEbmFoshAHtLmpQCdFz7BiYaD",
    serumAsks: "ESw6KKnLP3nRGtF1sgwc6EdoY5wWawkTWwa5zEjgDkHu",
    serumEventQueue: "Bii4W3FfohnHhGUDa1mA8TH82FMEQeYk48BB3zJNcfSQ",
    serumCoinVaultAccount: "3VnrHq1JWSD4DRdT1TAW4qG7nBVUFSh8mVRnkCtzV4Ry",
    serumPcVaultAccount: "6mSGzi7P2mM4tE6hkEsjXfZ4zR2LjctrNA3DwBvULrJU",
    serumVaultSigner: "BT3TcX9UsgeVgTWN6TgvSM11mx4GbkDUCMY1mnJbkxPq",
    official: true
  }
];
```

更新 `utils/safe-math.ts` 檔。

```TS
import BigNumber from "bignumber.js";

// https://github.com/MikeMcl/bignumber.js
// https://blog.csdn.net/shenxianhui1995/article/details/103985434
export class TokenAmount {
  public wei: BigNumber;

  public decimals: number;
  public _decimals: BigNumber;

  constructor(
    wei: number | string | BigNumber,
    decimals: number = 0,
    isWei = true
  ) {
    this.decimals = decimals;
    this._decimals = new BigNumber(10).exponentiatedBy(decimals);

    if (isWei) {
      this.wei = new BigNumber(wei);
    } else {
      this.wei = new BigNumber(wei).multipliedBy(this._decimals);
    }
  }

  toWei() {
    return this.wei;
  }

  fixed() {
    return this.wei.dividedBy(this._decimals).toFixed(this.decimals);
  }
}
```

更新 `utils/swap.ts` 檔。

```TS
import { Buffer } from "buffer";
import { closeAccount } from "@project-serum/serum/lib/token-instructions";
import { OpenOrders } from "@project-serum/serum";
// import { _OPEN_ORDERS_LAYOUT_V2} from '@project-serum/serum/lib/market';
import {
  Connection,
  PublicKey,
  Transaction,
  TransactionInstruction,
  AccountInfo,
  Keypair
} from "@solana/web3.js";
// @ts-ignore
import { nu64, struct, u8 } from "buffer-layout";

// eslint-disable-next-line
import { TokenAmount } from "./safe-math";
import {
  createAssociatedTokenAccountIfNotExist,
  createTokenAccountIfNotExist,
  sendTransaction,
  getMultipleAccounts,
  getFilteredProgramAccountsAmmOrMarketCache,
  createAmmAuthority
} from "./web3";
import { TOKEN_PROGRAM_ID } from "./ids";
import { getBigNumber, ACCOUNT_LAYOUT, MINT_LAYOUT } from "./layouts";

// eslint-disable-next-line
import {
  getTokenByMintAddress,
  NATIVE_SOL,
  TOKENS,
  // TokenInfo,
  LP_TOKENS
} from "./tokens";
// import { getAddressForWhat, LIQUIDITY_POOLS, LiquidityPoolInfo } from "./pools";
import { getAddressForWhat, LIQUIDITY_POOLS} from "./pools";
import {
  AMM_INFO_LAYOUT,
  AMM_INFO_LAYOUT_STABLE,
  AMM_INFO_LAYOUT_V3,
  AMM_INFO_LAYOUT_V4,
  getLpMintListDecimals
} from "./liquidity";
import { LIQUIDITY_POOL_PROGRAM_ID_V4, SERUM_PROGRAM_ID_V3 } from "./ids";
import { MARKET_STATE_LAYOUT_V2 } from "@project-serum/serum/lib/market";

export function swapInstruction(
  programId: PublicKey,
  // tokenProgramId: PublicKey,
  // amm
  ammId: PublicKey,
  ammAuthority: PublicKey,
  ammOpenOrders: PublicKey,
  ammTargetOrders: PublicKey,
  poolCoinTokenAccount: PublicKey,
  poolPcTokenAccount: PublicKey,
  // serum
  serumProgramId: PublicKey,
  serumMarket: PublicKey,
  serumBids: PublicKey,
  serumAsks: PublicKey,
  serumEventQueue: PublicKey,
  serumCoinVaultAccount: PublicKey,
  serumPcVaultAccount: PublicKey,
  serumVaultSigner: PublicKey,
  // user
  userSourceTokenAccount: PublicKey,
  userDestTokenAccount: PublicKey,
  userOwner: PublicKey,

  amountIn: number,
  minAmountOut: number
): TransactionInstruction {
  const dataLayout = struct([
    u8("instruction"),
    nu64("amountIn"),
    nu64("minAmountOut")
  ]);

  const keys = [
    // spl token
    { pubkey: TOKEN_PROGRAM_ID, isSigner: false, isWritable: false },
    // amm
    { pubkey: ammId, isSigner: false, isWritable: true },
    { pubkey: ammAuthority, isSigner: false, isWritable: false },
    { pubkey: ammOpenOrders, isSigner: false, isWritable: true },
    { pubkey: ammTargetOrders, isSigner: false, isWritable: true },
    { pubkey: poolCoinTokenAccount, isSigner: false, isWritable: true },
    { pubkey: poolPcTokenAccount, isSigner: false, isWritable: true },
    // serum
    { pubkey: serumProgramId, isSigner: false, isWritable: false },
    { pubkey: serumMarket, isSigner: false, isWritable: true },
    { pubkey: serumBids, isSigner: false, isWritable: true },
    { pubkey: serumAsks, isSigner: false, isWritable: true },
    { pubkey: serumEventQueue, isSigner: false, isWritable: true },
    { pubkey: serumCoinVaultAccount, isSigner: false, isWritable: true },
    { pubkey: serumPcVaultAccount, isSigner: false, isWritable: true },
    { pubkey: serumVaultSigner, isSigner: false, isWritable: false },
    { pubkey: userSourceTokenAccount, isSigner: false, isWritable: true },
    { pubkey: userDestTokenAccount, isSigner: false, isWritable: true },
    { pubkey: userOwner, isSigner: true, isWritable: false }
  ];

  const data = Buffer.alloc(dataLayout.span);
  dataLayout.encode(
    {
      instruction: 9,
      amountIn,
      minAmountOut
    },
    data
  );

  return new TransactionInstruction({
    keys,
    programId,
    data
  });
}

export async function swap(
  connection: Connection,
  wallet: any,
  poolInfo: any,
  fromCoinMint: string,
  toCoinMint: string,
  fromTokenAccount: string,
  toTokenAccount: string,
  aIn: string,
  aOut: string,
  wsolAddress: string
) {
  const transaction = new Transaction();
  const signers: Keypair[] = [];

  const owner = wallet.publicKey;

  const from = getTokenByMintAddress(fromCoinMint);
  const to = getTokenByMintAddress(toCoinMint);
  if (!from || !to) {
    throw new Error("Miss token info");
  }

  const amountIn = new TokenAmount(aIn, from.decimals, false);
  const amountOut = new TokenAmount(aOut, to.decimals, false);

  if (fromCoinMint === NATIVE_SOL.mintAddress && wsolAddress) {
    transaction.add(
      closeAccount({
        source: new PublicKey(wsolAddress),
        destination: owner,
        owner
      })
    );
  }

  let fromMint = fromCoinMint;
  let toMint = toCoinMint;

  if (fromMint === NATIVE_SOL.mintAddress) {
    fromMint = TOKENS.WSOL.mintAddress;
  }
  if (toMint === NATIVE_SOL.mintAddress) {
    toMint = TOKENS.WSOL.mintAddress;
  }

  let wrappedSolAccount: PublicKey | null = null;
  let wrappedSolAccount2: PublicKey | null = null;
  let newFromTokenAccount = PublicKey.default;
  let newToTokenAccount = PublicKey.default;

  if (fromCoinMint === NATIVE_SOL.mintAddress) {
    wrappedSolAccount = await createTokenAccountIfNotExist(
      connection,
      wrappedSolAccount,
      owner,
      TOKENS.WSOL.mintAddress,
      getBigNumber(amountIn.wei) + 1e7,
      transaction,
      signers
    );
  } else {
    newFromTokenAccount = await createAssociatedTokenAccountIfNotExist(
      fromTokenAccount,
      owner,
      fromMint,
      transaction
    );
  }

  if (toCoinMint === NATIVE_SOL.mintAddress) {
    wrappedSolAccount2 = await createTokenAccountIfNotExist(
      connection,
      wrappedSolAccount2,
      owner,
      TOKENS.WSOL.mintAddress,
      1e7,
      transaction,
      signers
    );
  } else {
    newToTokenAccount = await createAssociatedTokenAccountIfNotExist(
      toTokenAccount,
      owner,
      toMint,
      transaction
    );
  }

  transaction.add(
    swapInstruction(
      new PublicKey(poolInfo.programId),
      new PublicKey(poolInfo.ammId),
      new PublicKey(poolInfo.ammAuthority),
      new PublicKey(poolInfo.ammOpenOrders),
      new PublicKey(poolInfo.ammTargetOrders),
      new PublicKey(poolInfo.poolCoinTokenAccount),
      new PublicKey(poolInfo.poolPcTokenAccount),
      new PublicKey(poolInfo.serumProgramId),
      new PublicKey(poolInfo.serumMarket),
      new PublicKey(poolInfo.serumBids),
      new PublicKey(poolInfo.serumAsks),
      new PublicKey(poolInfo.serumEventQueue),
      new PublicKey(poolInfo.serumCoinVaultAccount),
      new PublicKey(poolInfo.serumPcVaultAccount),
      new PublicKey(poolInfo.serumVaultSigner),
      wrappedSolAccount ?? newFromTokenAccount,
      wrappedSolAccount2 ?? newToTokenAccount,
      owner,
      Math.floor(getBigNumber(amountIn.toWei())),
      Math.floor(getBigNumber(amountOut.toWei()))
    )
  );

  if (wrappedSolAccount) {
    transaction.add(
      closeAccount({
        source: wrappedSolAccount,
        destination: owner,
        owner
      })
    );
  }
  if (wrappedSolAccount2) {
    transaction.add(
      closeAccount({
        source: wrappedSolAccount2,
        destination: owner,
        owner
      })
    );
  }

  return await sendTransaction(connection, wallet, transaction, signers);
}

export function getSwapOutAmount(
  poolInfo: any,
  fromCoinMint: string,
  toCoinMint: string,
  amount: string,
  slippage: number
) {
  const { coin, pc, fees } = poolInfo;
  const { swapFeeNumerator, swapFeeDenominator } = fees;

  if (fromCoinMint === TOKENS.WSOL.mintAddress)
    fromCoinMint = NATIVE_SOL.mintAddress;
  if (toCoinMint === TOKENS.WSOL.mintAddress)
    toCoinMint = NATIVE_SOL.mintAddress;

  if (fromCoinMint === coin.mintAddress && toCoinMint === pc.mintAddress) {
    // coin2pc
    const fromAmount = new TokenAmount(amount, coin.decimals, false);
    const fromAmountWithFee = fromAmount.wei
      .multipliedBy(swapFeeDenominator - swapFeeNumerator)
      .dividedBy(swapFeeDenominator);
    const denominator = coin.balance.wei.plus(fromAmountWithFee);
    const amountOut = pc.balance.wei
      .multipliedBy(fromAmountWithFee)
      .dividedBy(denominator);
    const amountOutWithSlippage = amountOut.dividedBy(1 + slippage / 100);

    const outBalance = pc.balance.wei.minus(amountOut);
    const beforePrice = new TokenAmount(
      parseFloat(new TokenAmount(pc.balance.wei, pc.decimals).fixed()) /
        parseFloat(new TokenAmount(coin.balance.wei, coin.decimals).fixed()),
      pc.decimals,
      false
    );
    const afterPrice = new TokenAmount(
      parseFloat(new TokenAmount(outBalance, pc.decimals).fixed()) /
        parseFloat(new TokenAmount(denominator, coin.decimals).fixed()),
      pc.decimals,
      false
    );
    const priceImpact =
      Math.abs(
        (parseFloat(beforePrice.fixed()) - parseFloat(afterPrice.fixed())) /
          parseFloat(beforePrice.fixed())
      ) * 100;

    return {
      amountIn: fromAmount,
      amountOut: new TokenAmount(amountOut, pc.decimals),
      amountOutWithSlippage: new TokenAmount(
        amountOutWithSlippage,
        pc.decimals
      ),
      priceImpact
    };
  } else {
    // pc2coin
    const fromAmount = new TokenAmount(amount, pc.decimals, false);
    const fromAmountWithFee = fromAmount.wei
      .multipliedBy(swapFeeDenominator - swapFeeNumerator)
      .dividedBy(swapFeeDenominator);

    const denominator = pc.balance.wei.plus(fromAmountWithFee);
    const amountOut = coin.balance.wei
      .multipliedBy(fromAmountWithFee)
      .dividedBy(denominator);
    const amountOutWithSlippage = amountOut.dividedBy(1 + slippage / 100);

    const outBalance = coin.balance.wei.minus(amountOut);

    const beforePrice = new TokenAmount(
      parseFloat(new TokenAmount(pc.balance.wei, pc.decimals).fixed()) /
        parseFloat(new TokenAmount(coin.balance.wei, coin.decimals).fixed()),
      pc.decimals,
      false
    );
    const afterPrice = new TokenAmount(
      parseFloat(new TokenAmount(denominator, pc.decimals).fixed()) /
        parseFloat(new TokenAmount(outBalance, coin.decimals).fixed()),
      pc.decimals,
      false
    );
    const priceImpact =
      Math.abs(
        (parseFloat(afterPrice.fixed()) - parseFloat(beforePrice.fixed())) /
          parseFloat(beforePrice.fixed())
      ) * 100;
    return {
      amountIn: fromAmount,
      amountOut: new TokenAmount(amountOut, coin.decimals),
      amountOutWithSlippage: new TokenAmount(
        amountOutWithSlippage,
        coin.decimals
      ),
      priceImpact
    };
  }
}

export async function setupPools(conn: Connection) {
  let ammAll: {
    publicKey: PublicKey;
    accountInfo: AccountInfo<Buffer>;
  }[] = [];
  let marketAll: {
    publicKey: PublicKey;
    accountInfo: AccountInfo<Buffer>;
  }[] = [];

  await Promise.all([
    await (async () => {
      ammAll = await getFilteredProgramAccountsAmmOrMarketCache(
        "amm",
        conn,
        new PublicKey(LIQUIDITY_POOL_PROGRAM_ID_V4),
        [
          {
            dataSize: AMM_INFO_LAYOUT_V4.span
          }
        ]
      );
    })(),
    await (async () => {
      marketAll = await getFilteredProgramAccountsAmmOrMarketCache(
        "market",
        conn,
        new PublicKey(SERUM_PROGRAM_ID_V3),
        [
          {
            dataSize: MARKET_STATE_LAYOUT_V2.span
          }
        ]
      );
    })()
  ]);
  const marketToLayout: { [name: string]: any } = {};
  marketAll.forEach(item => {
    marketToLayout[item.publicKey.toString()] = MARKET_STATE_LAYOUT_V2.decode(
      item.accountInfo.data
    );
  });
  const lpMintAddressList: string[] = [];
  ammAll.forEach(item => {
    const ammLayout = AMM_INFO_LAYOUT_V4.decode(
      Buffer.from(item.accountInfo.data)
    );
    console.log("\n",ammLayout.serumMarket.toString())                                    // Serum Dex Program v3 
    console.log(ammLayout.coinMintAddress.toString())                                     // coin Mint Address
    console.log(ammLayout.pcMintAddress.toString())                                       // Pair Coin Mint Address 
    console.log(ammLayout.lpMintAddress.toString(), "\n")                                 // LP Coin Mint Address
    
    if (
      ammLayout.pcMintAddress.toString() === ammLayout.serumMarket.toString() ||          /** How could the pair coin mint be = serum dex program?? */
      ammLayout.lpMintAddress.toString() === "11111111111111111111111111111111"           /** How could the lp coin mint be = system program?? */
    ) {
      return;
    }
    lpMintAddressList.push(ammLayout.lpMintAddress.toString());
  });
  const lpMintListDecimls = await getLpMintListDecimals(
    conn,
    lpMintAddressList
  );
  const tokenMintData: { [mintAddress: string]: TokenInfo } = {};
  for (const itemToken of Object.values(TOKENS)) {
    tokenMintData[itemToken.mintAddress] = itemToken;
  }
                                                                                                /**@TODO combine with prev ammAll.forEach section */
  for (let indexAmmInfo = 0; indexAmmInfo < ammAll.length; indexAmmInfo += 1) {
    const ammInfo = AMM_INFO_LAYOUT_V4.decode(
      Buffer.from(ammAll[indexAmmInfo].accountInfo.data)
    );
    if (
      !Object.keys(lpMintListDecimls).includes(
        ammInfo.lpMintAddress.toString()
      ) ||
      ammInfo.pcMintAddress.toString() === ammInfo.serumMarket.toString() ||
      ammInfo.lpMintAddress.toString() === "11111111111111111111111111111111" ||
      !Object.keys(marketToLayout).includes(ammInfo.serumMarket.toString())
    ) {
      continue;
    }
    const fromCoin =
      ammInfo.coinMintAddress.toString() === TOKENS.WSOL.mintAddress
        ? NATIVE_SOL.mintAddress
        : ammInfo.coinMintAddress.toString();
    const toCoin =
      ammInfo.pcMintAddress.toString() === TOKENS.WSOL.mintAddress
        ? NATIVE_SOL.mintAddress
        : ammInfo.pcMintAddress.toString();
    let coin = tokenMintData[fromCoin];
    if (!coin && fromCoin !== NATIVE_SOL.mintAddress) {
      TOKENS[`unknow-${ammInfo.coinMintAddress.toString()}`] = {
        symbol: "unknown",
        name: "unknown",
        mintAddress: ammInfo.coinMintAddress.toString(),
        decimals: getBigNumber(ammInfo.coinDecimals),
        cache: true,
        tags: []
      };
      coin = TOKENS[`unknow-${ammInfo.coinMintAddress.toString()}`];
      tokenMintData[ammInfo.coinMintAddress.toString()] = coin;
    } else if (fromCoin === NATIVE_SOL.mintAddress) {
      coin = NATIVE_SOL;
    }
    if (!coin.tags.includes("unofficial")) {
      coin.tags.push("unofficial");
    }

    let pc = tokenMintData[toCoin];
    if (!pc && toCoin !== NATIVE_SOL.mintAddress) {
      TOKENS[`unknow-${ammInfo.pcMintAddress.toString()}`] = {
        symbol: "unknown",
        name: "unknown",
        mintAddress: ammInfo.pcMintAddress.toString(),
        decimals: getBigNumber(ammInfo.pcDecimals),
        cache: true,
        tags: []
      };
      pc = TOKENS[`unknow-${ammInfo.pcMintAddress.toString()}`];
      tokenMintData[ammInfo.pcMintAddress.toString()] = pc;
    } else if (toCoin === NATIVE_SOL.mintAddress) {
      pc = NATIVE_SOL;
    }
    if (!pc.tags.includes("unofficial")) {
      pc.tags.push("unofficial");
    }

    if (coin.mintAddress === TOKENS.WSOL.mintAddress) {
      coin.symbol = "SOL";
      coin.name = "SOL";
      coin.mintAddress = "11111111111111111111111111111111";
    }
    if (pc.mintAddress === TOKENS.WSOL.mintAddress) {
      pc.symbol = "SOL";
      pc.name = "SOL";
      pc.mintAddress = "11111111111111111111111111111111";
    }
    const lp = Object.values(LP_TOKENS).find(
      item => item.mintAddress === ammInfo.lpMintAddress
    ) ?? {
      symbol: `${coin.symbol}-${pc.symbol}`,
      name: `${coin.symbol}-${pc.symbol}`,
      coin,
      pc,
      mintAddress: ammInfo.lpMintAddress.toString(),
      decimals: lpMintListDecimls[ammInfo.lpMintAddress]
    };

    const { publicKey } = await createAmmAuthority(
      new PublicKey(LIQUIDITY_POOL_PROGRAM_ID_V4)
    );

    const market = marketToLayout[ammInfo.serumMarket];

    const serumVaultSigner = await PublicKey.createProgramAddress(
      [
        ammInfo.serumMarket.toBuffer(),
        market.vaultSignerNonce.toArrayLike(Buffer, "le", 8)
      ],
      new PublicKey(SERUM_PROGRAM_ID_V3)
    );

    const itemLiquidity: LiquidityPoolInfo = {
      name: `${coin.symbol}-${pc.symbol}`,
      coin,
      pc,
      lp,
      version: 4,
      programId: LIQUIDITY_POOL_PROGRAM_ID_V4,
      ammId: ammAll[indexAmmInfo].publicKey.toString(),
      ammAuthority: publicKey.toString(),
      ammOpenOrders: ammInfo.ammOpenOrders.toString(),
      ammTargetOrders: ammInfo.ammTargetOrders.toString(),
      ammQuantities: NATIVE_SOL.mintAddress,
      poolCoinTokenAccount: ammInfo.poolCoinTokenAccount.toString(),
      poolPcTokenAccount: ammInfo.poolPcTokenAccount.toString(),
      poolWithdrawQueue: ammInfo.poolWithdrawQueue.toString(),
      poolTempLpTokenAccount: ammInfo.poolTempLpTokenAccount.toString(),
      serumProgramId: SERUM_PROGRAM_ID_V3,
      serumMarket: ammInfo.serumMarket.toString(),
      serumBids: market.bids.toString(),
      serumAsks: market.asks.toString(),
      serumEventQueue: market.eventQueue.toString(),
      serumCoinVaultAccount: market.baseVault.toString(),
      serumPcVaultAccount: market.quoteVault.toString(),
      serumVaultSigner: serumVaultSigner.toString(),
      official: false
    };
    if (!LIQUIDITY_POOLS.find(item => item.ammId === itemLiquidity.ammId)) {
      LIQUIDITY_POOLS.push(itemLiquidity);
    } else {
      for (
        let itemIndex = 0;
        itemIndex < LIQUIDITY_POOLS.length;
        itemIndex += 1
      ) {
        if (
          LIQUIDITY_POOLS[itemIndex].ammId === itemLiquidity.ammId &&
          LIQUIDITY_POOLS[itemIndex].name !== itemLiquidity.name &&
          !LIQUIDITY_POOLS[itemIndex].official
        ) {
          LIQUIDITY_POOLS[itemIndex] = itemLiquidity;
        }
      }
    }
  }

  const liquidityPools = {} as any;
  const publicKeys = [] as any;

  LIQUIDITY_POOLS.forEach(pool => {
    const {
      poolCoinTokenAccount,
      poolPcTokenAccount,
      ammOpenOrders,
      ammId,
      coin,
      pc,
      lp
    } = pool;

    publicKeys.push(
      new PublicKey(poolCoinTokenAccount),
      new PublicKey(poolPcTokenAccount),
      new PublicKey(ammOpenOrders),
      new PublicKey(ammId),
      new PublicKey(lp.mintAddress)
    );

    const poolInfo = JSON.parse(JSON.stringify(pool));
    poolInfo.coin.balance = new TokenAmount(0, coin.decimals);
    poolInfo.pc.balance = new TokenAmount(0, pc.decimals);

    liquidityPools[lp.mintAddress] = poolInfo;
  });

  const multipleInfo = await getMultipleAccounts(conn, publicKeys, "confirmed");
  multipleInfo.forEach(info => {
    if (info) {
      const address = info.publicKey.toBase58();
      const data = Buffer.from(info.account.data);

      const { key, lpMintAddress, version } = getAddressForWhat(address);

      if (key && lpMintAddress) {
        const poolInfo = liquidityPools[lpMintAddress];

        switch (key) {
          case "poolCoinTokenAccount": {
            const parsed = ACCOUNT_LAYOUT.decode(data);
            // quick fix: Number can only safely store up to 53 bits
            poolInfo.coin.balance.wei = poolInfo.coin.balance.wei.plus(
              getBigNumber(parsed.amount)
            );

            break;
          }
          case "poolPcTokenAccount": {
            const parsed = ACCOUNT_LAYOUT.decode(data);

            poolInfo.pc.balance.wei = poolInfo.pc.balance.wei.plus(
              getBigNumber(parsed.amount)
            );

            break;
          }
          case "ammOpenOrders": {
            const OPEN_ORDERS_LAYOUT = OpenOrders.getLayout(
              new PublicKey(poolInfo.serumProgramId)
            );
            const parsed = OPEN_ORDERS_LAYOUT.decode(data);

            const { baseTokenTotal, quoteTokenTotal } = parsed;
            poolInfo.coin.balance.wei = poolInfo.coin.balance.wei.plus(
              getBigNumber(baseTokenTotal)
            );
            poolInfo.pc.balance.wei = poolInfo.pc.balance.wei.plus(
              getBigNumber(quoteTokenTotal)
            );

            break;
          }
          case "ammId": {
            let parsed;
            if (version === 2) {
              parsed = AMM_INFO_LAYOUT.decode(data);
            } else if (version === 3) {
              parsed = AMM_INFO_LAYOUT_V3.decode(data);
            } else {
              if (version === 5) {
                parsed = AMM_INFO_LAYOUT_STABLE.decode(data);
                poolInfo.currentK = getBigNumber(parsed.currentK);
              } else {
                parsed = AMM_INFO_LAYOUT_V4.decode(data);
                if (getBigNumber(parsed.status) === 7) {
                  poolInfo.poolOpenTime = getBigNumber(parsed.poolOpenTime);
                }
              }

              const { swapFeeNumerator, swapFeeDenominator } = parsed;
              poolInfo.fees = {
                swapFeeNumerator: getBigNumber(swapFeeNumerator),
                swapFeeDenominator: getBigNumber(swapFeeDenominator)
              };
            }

            const { status, needTakePnlCoin, needTakePnlPc } = parsed;
            poolInfo.status = getBigNumber(status);
            poolInfo.coin.balance.wei = poolInfo.coin.balance.wei.minus(
              getBigNumber(needTakePnlCoin)
            );
            poolInfo.pc.balance.wei = poolInfo.pc.balance.wei.minus(
              getBigNumber(needTakePnlPc)
            );

            break;
          }
          // getLpSupply
          case "lpMintAddress": {
            const parsed = MINT_LAYOUT.decode(data);

            poolInfo.lp.totalSupply = new TokenAmount(
              getBigNumber(parsed.supply),
              poolInfo.lp.decimals
            );

            break;
          }
        }
      }
    }
  });
  return liquidityPools;
}
```

更新 `utils/tokenList.ts` 檔。

```TS
import { TokenListProvider } from "@solana/spl-token-registry";

const SPLTokenRegistrySource = async () => {
  let tokens = await new TokenListProvider().resolve()
  let tokenList = tokens.filterByClusterSlug("mainnet-beta").getList()
  return tokenList.sort((a: any, b: any) =>
    a.symbol < b.symbol ? -1 : a.symbol > b.symbol ? 1 : 0
  )
};

export default SPLTokenRegistrySource;
```

更新 `utils/tokens.ts` 檔。

```TS
import { cloneDeep } from 'lodash-es';

/**
 * Get token use symbol

 * @param {string} symbol

 * @returns {TokenInfo | null} tokenInfo
 */

export function getTokenBySymbol(symbol: string): TokenInfo | null {
  if (symbol === 'SOL') {
    return cloneDeep(NATIVE_SOL)
  }

  let token = cloneDeep(TOKENS[symbol])

  if (!token) {
    token = null
  }

  return token
}

/**
 * Get token use mint addresses

 * @param {string} mintAddress

 * @returns {TokenInfo | null} tokenInfo
 */
export function getTokenByMintAddress(mintAddress: string): TokenInfo | null {
  if (mintAddress === NATIVE_SOL.mintAddress) {
    return cloneDeep(NATIVE_SOL)
  }
  const token = Object.values(TOKENS).find((item) => item.mintAddress === mintAddress)
  return token ? cloneDeep(token) : null
}

export function getTokenSymbolByMint(mint: string) {
  if (mint === NATIVE_SOL.mintAddress) {
    return NATIVE_SOL.symbol
  }

  const token = Object.values({ ...TOKENS, ...LP_TOKENS }).find((item) => item.mintAddress === mint)

  if (token) {
    return token.symbol
  }
  return 'UNKNOWN'
}

export interface Tokens {
  [key: string]: any
  [index: number]: any
}

export const TOKENS_TAGS: { [key: string]: { mustShow: boolean; show: boolean; outName: string } } = {
  raydium: { mustShow: true, show: true, outName: 'Raydium Default List' },
  userAdd: { mustShow: true, show: true, outName: 'User Added Tokens' },
  solana: { mustShow: false, show: false, outName: 'Solana Token List' },
  unofficial: { mustShow: false, show: false, outName: 'Permissionless Pool Tokens' }
}

export const NATIVE_SOL: TokenInfo = {
  symbol: 'SOL',
  name: 'Native Solana',
  mintAddress: '11111111111111111111111111111111',
  decimals: 9,
  tags: ['raydium']
}

export const TOKENS: Tokens = {
  SOL: {
    symbol: 'SOL',
    name: 'Native Solana',
    mintAddress: '11111111111111111111111111111111',
    address: '11111111111111111111111111111111',
    decimals: 9,
    tags: ['raydium']
  },
  WSOL: {
    symbol: 'WSOL',
    name: 'Wrapped Solana',
    mintAddress: 'So11111111111111111111111111111111111111112',
    decimals: 9,
    referrer: 'HTcarLHe7WRxBQCWvhVB8AP56pnEtJUV2jDGvcpY3xo5',
    tags: ['raydium']
  },
  BTC: {
    symbol: 'BTC',
    name: 'Wrapped Bitcoin',
    mintAddress: '9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E',
    decimals: 6,
    referrer: 'GZpS8cY8Nt8HuqxzJh6PXTdSxc38vFUjBmi7eEUkkQtG',
    tags: ['raydium']
  },
  ETH: {
    symbol: 'ETH',
    name: 'Wrapped Ethereum',
    mintAddress: '2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk',
    decimals: 6,
    referrer: 'CXPTcSxxh4AT38gtv3SPbLS7oZVgXzLbMb83o4ziXjjN',
    tags: ['raydium']
  },
  USDT: {
    symbol: 'USDT',
    name: 'USDT',
    mintAddress: 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
    decimals: 6,
    referrer: '8DwwDNagph8SdwMUdcXS5L9YAyutTyDJmK6cTKrmNFk3',
    tags: ['raydium']
  },
  WUSDT: {
    symbol: 'WUSDT',
    name: 'Wrapped USDT',
    mintAddress: 'BQcdHdAQW1hczDbBi9hiegXAR7A98Q9jx3X3iBBBDiq4',
    decimals: 6,
    referrer: 'CA98hYunCLKgBuD6N8MJSgq1GbW9CXdksLf5mw736tS3',
    tags: ['raydium']
  },
  USDC: {
    symbol: 'USDC',
    name: 'USDC',
    mintAddress: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
    decimals: 6,
    referrer: '92vdtNjEg6Zth3UU1MgPgTVFjSEzTHx66aCdqWdcRkrg',
    tags: ['raydium']
  },
  WUSDC: {
    symbol: 'WUSDC',
    name: 'Wrapped USDC',
    mintAddress: 'BXXkv6z8ykpG1yuvUDPgh732wzVHB69RnB9YgSYh3itW',
    decimals: 6,
    tags: ['raydium']
  },
  YFI: {
    symbol: 'YFI',
    name: 'Wrapped YFI',
    mintAddress: '3JSf5tPeuscJGtaCp5giEiDhv51gQ4v3zWg8DGgyLfAB',
    decimals: 6,
    referrer: 'DZjgzKfYzZBBSTo5vytMYvGdNF933DvuX8TftDMrThrb',
    tags: ['raydium']
  },
  LINK: {
    symbol: 'LINK',
    name: 'Wrapped Chainlink',
    mintAddress: 'CWE8jPTUYhdCTZYWPTe1o5DFqfdjzWKc9WKz6rSjQUdG',
    decimals: 6,
    referrer: 'DRSKKsYZaPEFkRgGywo7KWBGZikf71R9aDr8tjtpr41V',
    tags: ['raydium']
  },
  XRP: {
    symbol: 'XRP',
    name: 'Wrapped XRP',
    mintAddress: 'Ga2AXHpfAF6mv2ekZwcsJFqu7wB4NV331qNH7fW9Nst8',
    decimals: 6,
    referrer: '6NeHPXG142tAE2Ej3gHgT2N66i1KH6PFR6PBZw6RyrwH',
    tags: ['raydium']
  },
  SUSHI: {
    symbol: 'SUSHI',
    name: 'Wrapped SUSHI',
    mintAddress: 'AR1Mtgh7zAtxuxGd2XPovXPVjcSdY3i4rQYisNadjfKy',
    decimals: 6,
    referrer: '59QxHeHgb28tDc3gStnrW8FNKC9qWuRmRZHBaAqCerJX',
    tags: ['raydium']
  },
  ALEPH: {
    symbol: 'ALEPH',
    name: 'Wrapped ALEPH',
    mintAddress: 'CsZ5LZkDS7h9TDKjrbL7VAwQZ9nsRu8vJLhRYfmGaN8K',
    decimals: 6,
    referrer: '8FKAKrenJMDd7V6cxnM5BsymHTjqxgodtHbLwZReMnWW',
    tags: ['raydium']
  },
  SXP: {
    symbol: 'SXP',
    name: 'Wrapped SXP',
    mintAddress: 'SF3oTvfWzEP3DTwGSvUXRrGTvr75pdZNnBLAH9bzMuX',
    decimals: 6,
    referrer: '97Vyotr284UM2Fyq9gbfQ3azMYtgf7cjnsf8pN1PFfY9',
    tags: ['raydium']
  },
  HGET: {
    symbol: 'HGET',
    name: 'Wrapped HGET',
    mintAddress: 'BtZQfWqDGbk9Wf2rXEiWyQBdBY1etnUUn6zEphvVS7yN',
    decimals: 6,
    referrer: 'AGY2wy1ANzLM2jJLSkVxPUYAY5iAYXYsLMQkoQsAhucj',
    tags: ['raydium']
  },
  CREAM: {
    symbol: 'CREAM',
    name: 'Wrapped CREAM',
    mintAddress: '5Fu5UUgbjpUvdBveb3a1JTNirL8rXtiYeSMWvKjtUNQv',
    decimals: 6,
    referrer: '7WPzEiozJ69MQe8bfbss1t2unR6bHR4S7FimiUVRgu7P',
    tags: ['raydium']
  },
  UNI: {
    symbol: 'UNI',
    name: 'Wrapped UNI',
    mintAddress: 'DEhAasscXF4kEGxFgJ3bq4PpVGp5wyUxMRvn6TzGVHaw',
    decimals: 6,
    referrer: '4ntxDv95ajBbXfZyGy3UhcQDx8xmH1yJ6eKvuNNH466x',
    tags: ['raydium']
  },
  SRM: {
    symbol: 'SRM',
    name: 'Serum',
    mintAddress: 'SRMuApVNdxXokk5GT7XD5cUUgXMBCoAz2LHeuAoKWRt',
    decimals: 6,
    referrer: 'HYxa4Ea1dz7ya17Cx18rEGUA1WbCvKjXjFKrnu8CwugH',
    tags: ['raydium']
  },
  FTT: {
    symbol: 'FTT',
    name: 'Wrapped FTT',
    mintAddress: 'AGFEad2et2ZJif9jaGpdMixQqvW5i81aBdvKe7PHNfz3',
    decimals: 6,
    referrer: 'CafpgSh8KGL2GPTjdXfctD3vXngNZDJ3Q92FTfV71Hmt',
    tags: ['raydium']
  },
  MSRM: {
    symbol: 'MSRM',
    name: 'MegaSerum',
    mintAddress: 'MSRMcoVyrFxnSgo5uXwone5SKcGhT1KEJMFEkMEWf9L',
    decimals: 0,
    referrer: 'Ge5q9x8gDUNYqqLA1MdnCzWNJGsbj3M15Yxse2cDbw9z',
    tags: ['raydium']
  },
  TOMO: {
    symbol: 'TOMO',
    name: 'Wrapped TOMO',
    mintAddress: 'GXMvfY2jpQctDqZ9RoU3oWPhufKiCcFEfchvYumtX7jd',
    decimals: 6,
    referrer: '9fexfN3eZomF5gfenG5L9ydbKRQkPhq6x74rb5iLrvXP',
    tags: ['raydium']
  },
  KARMA: {
    symbol: 'KARMA',
    name: 'Wrapped KARMA',
    mintAddress: 'EcqExpGNFBve2i1cMJUTR4bPXj4ZoqmDD2rTkeCcaTFX',
    decimals: 4,
    tags: ['raydium']
  },
  LUA: {
    symbol: 'LUA',
    name: 'Wrapped LUA',
    mintAddress: 'EqWCKXfs3x47uVosDpTRgFniThL9Y8iCztJaapxbEaVX',
    decimals: 6,
    referrer: 'HuZwNApjVFuFSDgrwZA8GP2JD7WMby4qt6rkWDnaMo7j',
    tags: ['raydium']
  },
  MATH: {
    symbol: 'MATH',
    name: 'Wrapped MATH',
    mintAddress: 'GeDS162t9yGJuLEHPWXXGrb1zwkzinCgRwnT8vHYjKza',
    decimals: 6,
    referrer: 'C9K1M8sJX8WMdsnFT7DuzdiHHunEj79EsLuz4DixQYGm',
    tags: ['raydium']
  },
  KEEP: {
    symbol: 'KEEP',
    name: 'Wrapped KEEP',
    mintAddress: 'GUohe4DJUA5FKPWo3joiPgsB7yzer7LpDmt1Vhzy3Zht',
    decimals: 6,
    tags: ['raydium']
  },
  SWAG: {
    symbol: 'SWAG',
    name: 'Wrapped SWAG',
    mintAddress: '9F9fNTT6qwjsu4X4yWYKZpsbw5qT7o6yR2i57JF2jagy',
    decimals: 6,
    tags: ['raydium']
  },
  FIDA: {
    symbol: 'FIDA',
    name: 'Bonfida',
    mintAddress: 'EchesyfXePKdLtoiZSL8pBe8Myagyy8ZRqsACNCFGnvp',
    decimals: 6,
    referrer: 'AeAsG75UmyPDB271c6NHonHxXAPXfkvhcf2xjfJhReS8',
    tags: ['raydium']
  },
  KIN: {
    symbol: 'KIN',
    name: 'KIN',
    mintAddress: 'kinXdEcpDQeHPEuQnqmUgtYykqKGVFq6CeVX5iAHJq6',
    decimals: 5,
    referrer: 'AevFXmApVxN2yk1iemSxXc6Wy7Z1udUEfST11kuYKmr9',
    tags: ['raydium']
  },
  MAPS: {
    symbol: 'MAPS',
    name: 'MAPS',
    mintAddress: 'MAPS41MDahZ9QdKXhVa4dWB9RuyfV4XqhyAZ8XcYepb',
    decimals: 6,
    tags: ['raydium']
  },
  OXY: {
    symbol: 'OXY',
    name: 'OXY',
    mintAddress: 'z3dn17yLaGMKffVogeFHQ9zWVcXgqgf3PQnDsNs2g6M',
    decimals: 6,
    tags: ['raydium']
  },
  RAY: {
    symbol: 'RAY',
    name: 'Raydium',
    mintAddress: '4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R',
    decimals: 6,
    referrer: '33XpMmMQRf6tSPpmYyzpwU4uXpZHkFwCZsusD9dMYkjy',
    tags: ['raydium']
  },
  xCOPE: {
    symbol: 'xCOPE',
    name: 'xCOPE',
    mintAddress: '3K6rftdAaQYMPunrtNRHgnK2UAtjm2JwyT2oCiTDouYE',
    decimals: 0,
    referrer: '8DTehuES4tfnd2SrqcjN52XofxWXGjiLZRgM12U9pB6f',
    tags: ['raydium']
  },
  COPE: {
    symbol: 'COPE',
    name: 'COPE',
    mintAddress: '8HGyAAB1yoM1ttS7pXjHMa3dukTFGQggnFFH3hJZgzQh',
    decimals: 6,
    referrer: 'G7UYwWhkmgeL57SUKFF45K663V9TdXZw6Ho6ZLQ7p4p',
    tags: ['raydium']
  },
  STEP: {
    symbol: 'STEP',
    name: 'STEP',
    mintAddress: 'StepAscQoEioFxxWGnh2sLBDFp9d8rvKz2Yp39iDpyT',
    decimals: 9,
    referrer: 'EFQVX1S6dFroDDhJDAnMTX4fCfjt4fJXHdk1eEtJ2uRY',
    tags: ['raydium']
  },
  MEDIA: {
    symbol: 'MEDIA',
    name: 'MEDIA',
    mintAddress: 'ETAtLmCmsoiEEKfNrHKJ2kYy3MoABhU6NQvpSfij5tDs',
    decimals: 6,
    referrer: 'AYnaG3AidNWFzjq9U3BJSsQ9DShE8g7FszriBDtRFvsx',

    details:
      'Media Network is a new protocol that bypasses traditional CDN providers’ centralized approach for a self-governed and open source solution where everyone can participate. Media Network creates a distributed bandwidth market that enables service providers such as media platforms to hire resources from the network and dynamically come and go as the demand for last-mile data delivery shifts. It allows anyone to organically serve content without introducing any trust assumptions or pre-authentication requirements. Participants earn MEDIA rewards for their bandwidth contributions, a fixed supply SPL token minted on Solana’s Blockchain.',
    docs: {
      website: 'https://media.network/',
      whitepaper: 'https://media.network/whitepaper.pdf'
    },
    socials: {
      Twitter: 'https://twitter.com/Media_FDN',
      Telegram: 'https://t.me/Media_FDN',
      Medium: 'https://mediafoundation.medium.com/'
    },
    tags: ['raydium']
  },
  ROPE: {
    symbol: 'ROPE',
    name: 'ROPE',
    mintAddress: '8PMHT4swUMtBzgHnh5U564N5sjPSiUz2cjEQzFnnP1Fo',
    decimals: 9,
    referrer: '5sGVVniBSPLTwRHDETShovq7STRH2rJwbvdvvH3NcVTF',
    tags: ['raydium']
  },
  MER: {
    symbol: 'MER',
    name: 'Mercurial',
    mintAddress: 'MERt85fc5boKw3BW1eYdxonEuJNvXbiMbs6hvheau5K',
    decimals: 6,
    referrer: '36F4ryvqaNW2yKQsAry4ZHCZ3j7tz3gtEz7NEwv7pSRu',

    details:
      'Mercurial Finance\nMercurial is building DeFi’s first dynamic vaults for stable assets on Solana, providing the technical tools for users to easily deposit, swap and mint stable assets.\n\nInnovations\nMercurial will be introducing several key new technical innovations, including on-chain algorithms to regulate the flow of assets and dynamic fees that tap on the market and price data to assist LPs in optimizing performance. We will also be developing a unique pricing curve that will be the first to combine high efficiency, multi-token support, and generalizability for all types of token sets.\n\nMaximizing Capital Utlilization\nMercurial vaults will dynamically utilize assets for a wide range of use cases, like low slippage swaps, lending, flash loans, and external third-party decentralized protocols. To increase pegged assets availability on Solana, we will allow the creation of synthetics, like mUSD or mBTC, which can be added to our vaults to improve liquidity for other stables and facilitate interaction with other third-party decentralized protocols.\n\nStarting with a vault for the most common stables, for example, USDC, USDT, wUSDC, and wDAI, we will be facilitating low slippage swaps with dynamic fees. Features will be added as key technical and ecosystem pieces become available on Solana, i.e. inter-program composability, price oracles, etc.\n\nMER\nThe MER token will be used to accrue value for the holder via fees from swaps, commission from yield farms, and as collateral for synthetic stables like mUSD. MER will also be intrinsically linked to the governance and growth of Mercurial, playing a crucial role in regulating the system across governance, insurance, and bootstrapping.',
    docs: {
      website: 'https://www.mercurial.finance/',
      whitepaper: 'https://www.mercurial.finance/Mercurial-Lite-Paper-v1.pdf'
    },
    socials: {
      Twitter: 'https://twitter.com/MercurialFi',
      Telegram: 'https://t.me/MercurialFi',
      Medium: 'https://mercurialfi.medium.com/'
    },
    tags: ['raydium']
  },
  TULIP: {
    symbol: 'TULIP',
    name: 'TULIP',
    mintAddress: 'TuLipcqtGVXP9XR62wM8WWCm6a9vhLs7T1uoWBk6FDs',
    decimals: 6,
    referrer: 'Bcw1TvX8jUj6CtY2a7GU2THeYVAudvmT8yzRypVMVsSH',
    tags: ['raydium']
  },
  SNY: {
    symbol: 'SNY',
    name: 'SNY',
    mintAddress: '4dmKkXNHdgYsXqBHCuMikNQWwVomZURhYvkkX5c4pQ7y',
    decimals: 6,
    referrer: 'G7gyaTNn2hgjF67SWs4Ee9PEaFU2xadhtXL8HmkJ2cNL',

    detailLink: 'https://raydium.medium.com/synthetify-launching-on-acceleraytor-3755b4903f88',
    details:
      'Synthetify is a decentralized protocol that allows for the creation and exchange of synthetic assets that closely track the price of underlying assets. Synthetify’s synthetics adhere to the SPL token standard, allowing them to be easily integrated with DeFi applications across the Solana ecosystem.\n\nSynthetify leverages Solana to enable a fast, cheap and intuitive trading experience for users of the platform while staying fully decentralized thanks to an infrastructure that relies on smart contracts and blockchain oracles.\n\nThe Synthetify Token (SNY) gives the ability to participate in the protocol through staking. Stakers receive a pro rata share of fees generated by the exchange as well as additional rewards. SNY acts as a collateral token for all synthetic assets created on the platform and each token will have voting power on future governance proposals.',
    docs: {
      website: 'https://synthetify.io/',
      whitepaper: 'https://resources.synthetify.io/synthetify-whitepaper.pdf'
    },
    socials: {
      Twitter: 'https://twitter.com/synthetify',
      Telegram: 'https://t.me/synthetify',
      Medium: 'https://synthetify.medium.com/'
    },
    tags: ['raydium']
  },
  SLRS: {
    symbol: 'SLRS',
    name: 'SLRS',
    mintAddress: 'SLRSSpSLUTP7okbCUBYStWCo1vUgyt775faPqz8HUMr',
    decimals: 6,
    referrer: 'AmqeHgTdm6kBzy5ewZFKuMAfbynZmhve1GQxbJzQFLbP',

    detailLink: 'https://raydium.medium.com/solrise-is-launching-on-acceleraytor-c2c980362037',
    details:
      'Solrise Finance is a fully decentralized and non-custodial protocol for investment funds on Solana. What this means in practice is that anyone can open a fund, and anyone can invest in it.\n\nSolrise’s platform allows fund managers from all across the globe — weWether they are well-established and looking for a new channel, or ambitious rookies with something to prove — to open a fund, with performance kept completely transparent.\n\nExisting decentralized fund management platforms on Ethereum are suffering from brutally high transaction fees. With Solrise, you can create, enter, and exit funds all for under $0.01.',
    docs: {
      website: 'https://solrise.finance/',
      docs: 'https://docs.solrise.finance/'
    },
    socials: {
      Twitter: 'https://twitter.com/SolriseFinance',
      Telegram: 'https://t.me/solrisefinance',
      Medium: 'https://blog.solrise.finance/'
    },
    tags: ['raydium']
  },
  WOO: {
    symbol: 'WOO',
    name: 'Wootrade Network',
    mintAddress: 'E5rk3nmgLUuKUiS94gg4bpWwWwyjCMtddsAXkTFLtHEy',
    decimals: 6,
    referrer: '7UbeAZxpza5zN3QawQ5KsUo88zXvohUncYB9Zk5QCiim',
    tags: ['raydium']
  },
  BOP: {
    symbol: 'BOP',
    name: 'Boring Protocol',
    mintAddress: 'BLwTnYKqf7u4qjgZrrsKeNs2EzWkMLqVCu6j8iHyrNA3',
    decimals: 8,
    referrer: 'FWxBZmNsvNckx8DnaL2NuyMtiQmT1x529WwV4e1UWiGk',
    tags: ['raydium']
  },
  SAMO: {
    symbol: 'SAMO',
    name: 'Samoyed Coin',
    mintAddress: '7xKXtg2CW87d97TXJSDpbD5jBkheTqA83TZRuJosgAsU',
    decimals: 9,
    referrer: 'FnMDNFL9t8EpbADSU3hLWBtx7SuwRBB6NM84U3PzSkUu',
    tags: ['raydium']
  },
  renBTC: {
    symbol: 'renBTC',
    name: 'renBTC',
    mintAddress: 'CDJWUqTcYTVAKXAVXoQZFes5JUFc7owSeq7eMQcDSbo5',
    decimals: 8,
    referrer: '7rr64uygy3o5RKVeNv12JGDUFMXVdr2YHvA3NTxzbZT6',
    tags: ['raydium']
  },
  renDOGE: {
    symbol: 'renDOGE',
    name: 'renDOGE',
    mintAddress: 'ArUkYE2XDKzqy77PRRGjo4wREWwqk6RXTfM9NeqzPvjU',
    decimals: 8,
    referrer: 'J5g7uvJRGnpRyLnRQjFs1MqMkiTVgjxVJCXocu4B4BcZ',
    tags: ['raydium']
  },
  LIKE: {
    symbol: 'LIKE',
    name: 'LIKE',
    mintAddress: '3bRTivrVsitbmCTGtqwp7hxXPsybkjn4XLNtPsHqa3zR',
    decimals: 9,
    referrer: '2rnVeVGfM88XqyNyBzGWEb7JViYKqncFzjWq5h1ujS9A',

    detailLink: 'https://raydium.medium.com/only1-is-launching-on-acceleraytor-41ecb89dcc4e',
    details:
      'Only1 is the first NFT-powered social platform built on the Solana blockchain. Mixing social media, an NFT marketplace, a scalable blockchain, and the native token — $LIKE, Only1 offers fans a unique way of connecting with the creators they love.\n\nBy using the Only1 platform, fans will have the ability to invest, access, and earn from the limited edition contents created by the world’s largest influencers/celebrities, all powered by NFTs.',
    docs: {
      website: 'https://only1.io/',
      whitepaper: 'https://only1.io/pitch-deck.pdf'
    },
    socials: {
      Twitter: 'https://twitter.com/only1nft',
      Telegram: 'https://t.me/only1nft',
      Medium: 'https://medium.com/@only1nft',
      Discord: 'https://discord.gg/sUu7KZwNCB'
    },
    tags: ['raydium']
  },
  DXL: {
    symbol: 'DXL',
    name: 'DXL',
    mintAddress: 'GsNzxJfFn6zQdJGeYsupJWzUAm57Ba7335mfhWvFiE9Z',
    decimals: 6,
    referrer: 'HF7mhT9YgD5CULAFDYQmhnUMi1FnNbKeBFCy9SZDh2XE',
    tags: ['raydium']
  },
  mSOL: {
    symbol: 'mSOL',
    name: 'Marinade staked SOL (mSOL)',
    mintAddress: 'mSoLzYCxHdYgdzU16g5QSh3i5K3z3KZK7ytfqcJm7So',
    decimals: 9,
    referrer: '7h5bckf8P29RdviNoKjDyH3Ky3uwdrBiPgYuSCD4asV5',
    tags: ['raydium']
  },
  PAI: {
    symbol: 'PAI',
    name: 'PAI (Parrot)',
    mintAddress: 'Ea5SjE2Y6yvCeW5dYTn7PYMuW5ikXkvbGdcmSnXeaLjS',
    decimals: 6,
    referrer: '54X98LAxRR2j1KMBBXkbYyUaAWi1iKW9G1Y4TnTJVY2e',
    tags: ['raydium']
  },
  PORT: {
    symbol: 'PORT',
    name: 'PORT',
    mintAddress: 'PoRTjZMPXb9T7dyU7tpLEZRQj7e6ssfAE62j2oQuc6y',
    decimals: 6,
    referrer: '5Ve8q9fb7R2DhdqGV4o1RVy7xxo4D6ifQfbxGiASdxEH',
    tags: ['raydium']
  },
  MNGO: {
    symbol: 'MNGO',
    name: 'Mango',
    mintAddress: 'MangoCzJ36AjZyKwVj3VnYU4GTonjfVEnJmvvWaxLac',
    decimals: 6,
    referrer: 'CijuvE6qDpxZ5WqdEQEe7mS11fXEKiiHc7RR8wRiGzjY',
    tags: ['raydium']
  },
  CRP: {
    symbol: 'CRP',
    name: 'CRP',
    mintAddress: 'DubwWZNWiNGMMeeQHPnMATNj77YZPZSAz2WVR5WjLJqz',
    decimals: 9,
    referrer: 'FKocyVJptELTbnkUkDRmT7y6hUem2JYrqHoph9uyvQXt',
    tags: ['raydium']
  },
  ATLAS: {
    symbol: 'ATLAS',
    name: 'ATLAS',
    mintAddress: 'ATLASXmbPQxBUYbxPsV97usA3fPQYEqzQBUHgiFCUsXx',
    decimals: 8,
    referrer: '9t9mzbkMtLdazj1D9JycS15Geb1KVtcDt4XyAkpM72Ee',

    detailLink: 'https://raydium.medium.com/star-atlas-is-launching-on-acceleraytor-fa35cfe3291f',
    details:
      'POLIS is the primary governance token of Star Atlas.\n\nStar Atlas is a grand strategy game that combines space exploration, territorial conquest, and political domination. In the distant future, players can join one of three galactic factions to directly influence the course of the metaverse and earn real-world income for their contributions.\n\nThe Star Atlas offers a unique gaming experience by combining block chain mechanics with traditional game mechanics. All assets in the metaverse are directly owned by players, and can be traded on the marketplace or exchanged on other cryptocurrency networks.',
    docs: {
      website: 'https://staratlas.com/',
      whitepaper: 'https://staratlas.com/files/star-atlas-white-paper.pdf'
    },
    socials: {
      Twitter: 'https://twitter.com/staratlas',
      Telegram: 'https://t.me/staratlasgame',
      Medium: 'https://medium.com/star-atlas',
      Discord: 'https://discord.gg/staratlas',
      Twitch: 'https://www.twitch.tv/staratlasgame',
      Youtube: 'https://www.youtube.com/channel/UCt-y8Npwje5KDG5MSZ0a9Jw/videos'
    },
    tags: ['raydium']
  },
  POLIS: {
    symbol: 'POLIS',
    name: 'POLIS',
    mintAddress: 'poLisWXnNRwC6oBu1vHiuKQzFjGL4XDSu4g9qjz9qVk',
    decimals: 8,
    referrer: 'CQ7HWCeSSp3tAfWzqH7ZEzgnTBr5Tvz1No3Y1xbiWzBm',

    detailLink: 'https://raydium.medium.com/star-atlas-is-launching-on-acceleraytor-fa35cfe3291f',
    details:
      'POLIS is the primary governance token of Star Atlas.\n\nStar Atlas is a grand strategy game that combines space exploration, territorial conquest, and political domination. In the distant future, players can join one of three galactic factions to directly influence the course of the metaverse and earn real-world income for their contributions.\n\nThe Star Atlas offers a unique gaming experience by combining block chain mechanics with traditional game mechanics. All assets in the metaverse are directly owned by players, and can be traded on the marketplace or exchanged on other cryptocurrency networks.',
    docs: {
      website: 'https://staratlas.com/',
      whitepaper: 'https://staratlas.com/files/star-atlas-white-paper.pdf'
    },
    socials: {
      Twitter: 'https://twitter.com/staratlas',
      Telegram: 'https://t.me/staratlasgame',
      Medium: 'https://medium.com/star-atlas',
      Discord: 'https://discord.gg/staratlas',
      Twitch: 'https://www.twitch.tv/staratlasgame',
      Youtube: 'https://www.youtube.com/channel/UCt-y8Npwje5KDG5MSZ0a9Jw/videos'
    },
    tags: ['raydium']
  },
  GRAPE: {
    symbol: 'GRAPE',
    name: 'GRAPE',
    mintAddress: '8upjSpvjcdpuzhfR1zriwg5NXkwDruejqNE9WNbPRtyA',
    decimals: 6,
    referrer: 'M4nDMB9krXbaNFPVu1DjrBTfqPUHbKEQLZSSDNH2JrL',

    detailLink: 'https://raydium.medium.com/grape-protocol-launching-on-acceleraytor-547f58c12937',
    details:
      'The GRAPE “Great Ape” community is a token-based membership community focused on accelerating the growth and adoption of Solana. GRAPE token holders at different tiers are rewarded with exclusive benefits and monthly emissions of GRAPE. You can find more details on the GRAPE membership tiers and benefits here.\n\nThe GRAPE toolset creates a framework for decentralized and tokenized communities to better organize and coordinate their activities, unlocking a whole new world of possibility for these dynamic groups. The GRAPE roadmap includes modules for DAO Management, non-custodial tipping, escrow, and event planning to be deployed in the next 6 months.\n\nGRAPE protocol’s first tool, Grape Access, creates a Dynamic Balance-Based Membership solution by connecting members’ social accounts to cryptographic keys. All Solana tokens are supported by Multi-Coin configurations, which grants users permission and access rights based on SPL tokens, token pairs, and LP tokens in their wallet.',
    docs: {
      website: 'https://grapes.network/'
      // whitepaper: '' // TODO
    },
    socials: {
      Discord: 'https://discord.com/invite/greatape',
      Medium: 'https://medium.com/great-ape',
      Twitter: 'https://twitter.com/grapeprotocol',
      Twitch: 'https://www.twitch.tv/whalesfriend'
    },
    tags: ['raydium']
  },
  GENE: {
    symbol: 'GENE',
    name: 'Genopets',
    mintAddress: 'GENEtH5amGSi8kHAtQoezp1XEXwZJ8vcuePYnXdKrMYz',
    decimals: 9,

    detailLink: 'https://raydium.medium.com/genopets-is-launching-on-acceleraytor-a4cba0b9f78b',
    details:
      'Genopets is the world’s first Free-to-Play, Move-to-Earn NFT game that makes it fun and rewarding to live an active lifestyle. Build on Solana, Genopets integrates your daily activity in real life with blockchain Play-to-Earn economics so you can turn your real-life actions into expansive gameplay and earn crypto while doing it.',
    docs: {
      website: 'https://www.genopets.me/'
      // whitepaper: ''
    },
    socials: {
      Discord: 'https://discord.gg/genopets',
      Medium: 'https://medium.com/@genopets',
      Twitter: 'https://twitter.com/genopets'
    },
    tags: ['raydium']
  },
  DFL: {
    symbol: 'DFL',
    name: 'DeFi Land',
    mintAddress: 'DFL1zNkaGPWm1BqAVqRjCZvHmwTFrEaJtbzJWgseoNJh',
    decimals: 9,

    detailLink: 'https://raydium.medium.com/defi-land-is-launching-on-acceleraytor-8aa06caecc3c',
    details:
      'DeFi Land is a multi-chain agriculture simulation web game created to gamify decentralized finance. The game will have all the features that traditional platforms have, but it will be gathered all in one place. DeFi Land gamifies decentralized finance by turning investment activities into games.',
    docs: {
      website: 'https://defiland.app/'
      // whitepaper: ''
    },
    socials: {
      Discord: 'https://discord.gg/defiland',
      Medium: 'https://defiland.medium.com/',
      Twitter: 'https://twitter.com/DeFi_Land',
      Telegram: 'https://t.me/defiland_official'
    },
    tags: ['raydium']
  },
  CHEEMS: {
    symbol: 'CHEEMS',
    name: 'CHEEMS',
    mintAddress: '3FoUAsGDbvTD6YZ4wVKJgTB76onJUKz7GPEBNiR5b8wc',
    decimals: 4,
    referrer: '',
    tags: ['raydium']
  },
  stSOL: {
    symbol: 'stSOL',
    name: 'stSOL',
    mintAddress: '7dHbWXmci3dT8UFYWYZweBLXgycu7Y3iL6trKn1Y7ARj',
    decimals: 9,
    referrer: '8Mq4Tugv1fcT4gb1wf5ChdEFmdqNGKxFVCnM9TVe44vD',
    tags: ['raydium']
  },
  LARIX: {
    symbol: 'LARIX',
    name: 'LARIX',
    mintAddress: 'Lrxqnh6ZHKbGy3dcrCED43nsoLkM1LTzU2jRfWe8qUC',
    decimals: 6,
    referrer: 'DReKowvoxxEDdi5jnxBWJLTV73D9oHSt9uNMuSCk9cLk',
    tags: ['raydium']
  },
  RIN: {
    symbol: 'RIN',
    name: 'RIN',
    mintAddress: 'E5ndSkaB17Dm7CsD22dvcjfrYSDLCxFcMd6z8ddCk5wp',
    decimals: 9,
    tags: ['raydium']
  },
  APEX: {
    symbol: 'APEX',
    name: 'APEX',
    mintAddress: '51tMb3zBKDiQhNwGqpgwbavaGH54mk8fXFzxTc1xnasg',
    decimals: 9,
    tags: ['raydium']
  },
  MNDE: {
    symbol: 'MNDE',
    name: 'MNDE',
    mintAddress: 'MNDEFzGvMt87ueuHvVU9VcTqsAP5b3fTGPsHuuPA5ey',
    decimals: 9,
    tags: ['raydium']
  },
  LIQ: {
    symbol: 'LIQ',
    name: 'LIQ',
    mintAddress: '4wjPQJ6PrkC4dHhYghwJzGBVP78DkBzA2U3kHoFNBuhj',
    decimals: 6,
    tags: ['raydium']
  },
  WAG: {
    symbol: 'WAG',
    name: 'WAG',
    mintAddress: '5tN42n9vMi6ubp67Uy4NnmM5DMZYN8aS8GeB3bEDHr6E',
    decimals: 9,
    tags: ['raydium']
  },
  wLDO: {
    symbol: 'wLDO',
    name: 'wLDO',
    mintAddress: 'HZRCwxP2Vq9PCpPXooayhJ2bxTpo5xfpQrwB1svh332p',
    decimals: 8,
    tags: ['raydium']
  },
  SLIM: {
    symbol: 'SLIM',
    name: 'SLIM',
    mintAddress: 'xxxxa1sKNGwFtw2kFn8XauW9xq8hBZ5kVtcSesTT9fW',
    decimals: 6,
    tags: ['raydium']
  },
  PRT: {
    symbol: 'PRT',
    name: 'PRT',
    mintAddress: 'PRT88RkA4Kg5z7pKnezeNH4mafTvtQdfFgpQTGRjz44',
    decimals: 6,
    tags: ['raydium']
  },
  SBR: {
    symbol: 'SBR',
    name: 'SBR',
    mintAddress: 'Saber2gLauYim4Mvftnrasomsv6NvAuncvMEZwcLpD1',
    decimals: 6,
    tags: ['raydium']
  },
  FAB: {
    symbol: 'FAB',
    name: 'FAB',
    mintAddress: 'EdAhkbj5nF9sRM7XN7ewuW8C9XEUMs8P7cnoQ57SYE96',
    decimals: 9,
    tags: ['raydium']
  },
  ABR: {
    symbol: 'ABR',
    name: 'ABR',
    mintAddress: 'a11bdAAuV8iB2fu7X6AxAvDTo1QZ8FXB3kk5eecdasp',
    decimals: 9,
    tags: ['raydium']
  },
  IVN: {
    symbol: 'IVN',
    name: 'IVN',
    mintAddress: 'iVNcrNE9BRZBC9Aqf753iZiZfbszeAVUoikgT9yvr2a',
    decimals: 6,
    tags: ['raydium']
  },
  CYS: {
    symbol: 'CYS',
    name: 'CYS',
    mintAddress: 'BRLsMczKuaR5w9vSubF4j8HwEGGprVAyyVgS4EX7DKEg',
    decimals: 6,
    tags: ['raydium']
  },
  FRKT: {
    symbol: 'FRKT',
    name: 'FRKT',
    mintAddress: 'ErGB9xa24Szxbk1M28u2Tx8rKPqzL6BroNkkzk5rG4zj',
    decimals: 8,
    tags: ['raydium']
  },
  AURY: {
    symbol: 'AURY',
    name: 'AURY',
    mintAddress: 'AURYydfxJib1ZkTir1Jn1J9ECYUtjb6rKQVmtYaixWPP',
    decimals: 9,
    tags: ['raydium']
  },
  SYP: {
    symbol: 'SYP',
    name: 'SYP',
    mintAddress: 'FnKE9n6aGjQoNWRBZXy4RW6LZVao7qwBonUbiD7edUmZ',
    decimals: 9,
    tags: ['raydium']
  },
  WOOF: {
    symbol: 'WOOF',
    name: 'WOOF',
    mintAddress: '9nEqaUcb16sQ3Tn1psbkWqyhPdLmfHWjKGymREjsAgTE',
    decimals: 6,
    tags: ['raydium']
  },
  ORCA: {
    symbol: 'ORCA',
    name: 'ORCA',
    mintAddress: 'orcaEKTdK7LKz57vaAYr9QeNsVEPfiu6QeMU1kektZE',
    decimals: 6,
    tags: ['raydium']
  },
  SLND: {
    symbol: 'SLND',
    name: 'SLND',
    mintAddress: 'SLNDpmoWTVADgEdndyvWzroNL7zSi1dF9PC3xHGtPwp',
    decimals: 6,
    tags: ['raydium']
  },
  weWETH: {
    symbol: 'weWETH',
    name: 'weWETH',
    mintAddress: '7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs',
    decimals: 8,
    tags: ['raydium']
  },
  weUNI: {
    symbol: 'weUNI',
    name: 'weUNI',
    mintAddress: '8FU95xFJhUUkyyCLU13HSzDLs7oC4QZdXQHL6SCeab36',
    decimals: 8,
    tags: ['raydium']
  },
  weSUSHI: {
    symbol: 'weSUSHI',
    name: 'weSUSHI',
    mintAddress: 'ChVzxWRmrTeSgwd3Ui3UumcN8KX7VK3WaD4KGeSKpypj',
    decimals: 8,
    tags: ['raydium']
  },
  GOFX: {
    symbol: 'GOFX',
    name: 'GOFX',
    mintAddress: 'GFX1ZjR2P15tmrSwow6FjyDYcEkoFb4p4gJCpLBjaxHD',
    decimals: 9,
    tags: ['raydium']
  },
  IN: {
    symbol: 'IN',
    name: 'IN',
    mintAddress: 'inL8PMVd6iiW3RCBJnr5AsrRN6nqr4BTrcNuQWQSkvY',
    decimals: 9,
    tags: ['raydium']
  },
  weDYDX: {
    symbol: 'weDYDX',
    name: 'weDYDX',
    mintAddress: '4Hx6Bj56eGyw8EJrrheM6LBQAvVYRikYCWsALeTrwyRU',
    decimals: 8,
    tags: ['raydium']
  },
  STARS: {
    symbol: 'STARS',
    name: 'STARS',
    mintAddress: 'HCgybxq5Upy8Mccihrp7EsmwwFqYZtrHrsmsKwtGXLgW',
    decimals: 6,
    tags: ['raydium']
  },
  weAXS: {
    symbol: 'weAXS',
    name: 'weAXS',
    mintAddress: 'HysWcbHiYY9888pHbaqhwLYZQeZrcQMXKQWRqS7zcPK5',
    decimals: 8,
    tags: ['raydium']
  },
  weSHIB: {
    symbol: 'weSHIB',
    name: 'weSHIB',
    mintAddress: 'CiKu4eHsVrc1eueVQeHn7qhXTcVu95gSQmBpX4utjL9z',
    decimals: 8,
    tags: ['raydium']
  },
  OXS: {
    symbol: 'OXS',
    name: 'OXS',
    mintAddress: '4TGxgCSJQx2GQk9oHZ8dC5m3JNXTYZHjXumKAW3vLnNx',
    decimals: 9,
    tags: ['raydium']
  },
  CWAR: {
    symbol: 'CWAR',
    name: 'CWAR',
    mintAddress: 'HfYFjMKNZygfMC8LsQ8LtpPsPxEJoXJx4M6tqi75Hajo',
    decimals: 9,
    tags: ['raydium']
  },
  UPS: {
    symbol: 'UPS',
    name: 'UPS',
    mintAddress: 'EwJN2GqUGXXzYmoAciwuABtorHczTA5LqbukKXV1viH7',
    decimals: 6,
    tags: ['raydium']
  },
  weSAND: {
    symbol: 'weSAND',
    name: 'weSAND',
    mintAddress: '49c7WuCZkQgc3M4qH8WuEUNXfgwupZf1xqWkDQ7gjRGt',
    decimals: 8,
    tags: ['raydium']
  },
  weMANA: {
    symbol: 'weMANA',
    name: 'weMANA',
    mintAddress: '7dgHoN8wBZCc5wbnQ2C47TDnBMAxG4Q5L3KjP67z8kNi',
    decimals: 8,
    tags: ['raydium']
  },
  CAVE: {
    symbol: 'CAVE',
    name: 'CAVE',
    mintAddress: '4SZjjNABoqhbd4hnapbvoEPEqT8mnNkfbEoAwALf1V8t',
    decimals: 6,
    tags: ['raydium']
  },
  JSOL: {
    symbol: 'JSOL',
    name: 'JSOL',
    mintAddress: '7Q2afV64in6N6SeZsAAB81TJzwDoD6zpqmHkzi9Dcavn',
    decimals: 9,
    tags: ['raydium']
  },
  APT: {
    symbol: 'APT',
    name: 'APT',
    mintAddress: 'APTtJyaRX5yGTsJU522N4VYWg3vCvSb65eam5GrPT5Rt',
    decimals: 6,
    tags: ['raydium']
  },
  SONAR: {
    symbol: 'SONAR',
    name: 'SONAR',
    mintAddress: 'sonarX4VtVkQemriJeLm6CKeW3GDMyiBnnAEMw1MRAE',
    decimals: 9,
    tags: ['raydium']
  },
  SHILL: {
    symbol: 'SHILL',
    name: 'SHILL',
    mintAddress: '6cVgJUqo4nmvQpbgrDZwyfd6RwWw5bfnCamS3M9N1fd',
    decimals: 6,
    tags: ['raydium']
  },
  TTT: {
    symbol: 'TTT',
    name: 'TabTrader',
    mintAddress: 'FNFKRV3V8DtA3gVJN6UshMiLGYA8izxFwkNWmJbFjmRj',
    decimals: 6,

    detailLink: 'https://raydium.medium.com/tabtrader-is-launching-on-acceleraytor-bc570b6a9628',
    details:
      'TabTrader is a trading terminal that supports 34 exchanges with over 12,000 instruments, a variety of analytical tools, and a convenient interface. It’s a quick-access application allowing you to track your exchange accounts, trade, analyze charts, and get instantly notified on price changes, all within one unified interface. The app has a rating of 4.7 on the Apple App Store (with over 52,000 ratings) and a rating of 4.5 on the Google Play Store (with over 55,000 ratings).',
    docs: {
      website: 'https://tab-trader.com/'
      // whitepaper: ''
    },
    socials: {
      Twitter: 'https://twitter.com/tabtraderpro',
      Telegram: 'https://t.me/tabtrader_en'
    },
    tags: ['raydium']
  },
  BOKU: {
    symbol: 'BOKU',
    name: 'BOKU',
    mintAddress: 'CN7qFa5iYkHz99PTctvT4xXUHnxwjQ5MHxCuTJtPN5uS',
    decimals: 9,
    tags: ['raydium']
  },
  MIMO: {
    symbol: 'MIMO',
    name: 'MIMO',
    mintAddress: '9TE7ebz1dsFo1uQ2T4oYAKSm39Y6fWuHrd6Uk6XaiD16',
    decimals: 9,
    tags: ['raydium']
  },
  wbWBNB: {
    symbol: 'wbWBNB',
    name: 'wbWBNB',
    mintAddress: '9gP2kCy3wA1ctvYWQk75guqXuHfrEomqydHLtcTCqiLa',
    decimals: 8,
    tags: ['raydium']
  },
  wePEOPLE: {
    symbol: 'wePEOPLE',
    name: 'wePEOPLE',
    mintAddress: 'CobcsUrt3p91FwvULYKorQejgsm5HoQdv5T8RUZ6PnLA',
    decimals: 8,
    tags: ['raydium']
  },
  XTAG: {
    symbol: 'XTAG',
    name: 'XTAG',
    mintAddress: '5gs8nf4wojB5EXgDUWNLwXpknzgV2YWDhveAeBZpVLbp',
    decimals: 6,
    tags: ['raydium']
  },
  KKO: {
    symbol: 'KKO',
    name: 'KKO',
    mintAddress: 'kiNeKo77w1WBEzFFCXrTDRWGRWGP8yHvKC9rX6dqjQh',
    decimals: 9,
    tags: ['raydium']
  },
  VI: {
    symbol: 'VI',
    name: 'VI',
    mintAddress: '7zBWymxbZt7PVHQzfi3i85frc1YRiQc23K7bh3gos8ZC',
    decimals: 9,
    tags: ['raydium']
  },
  SOLC: {
    symbol: 'SOLC',
    name: 'SOLC',
    mintAddress: 'Bx1fDtvTN6NvE4kjdPHQXtmGSg582bZx9fGy4DQNMmAT',
    decimals: 9,
    tags: ['raydium']
  },
  STR: {
    symbol: 'STR',
    name: 'STR',
    mintAddress: '9zoqdwEBKWEi9G5Ze8BSkdmppxGgVv1Kw4LuigDiNr9m',
    decimals: 9,
    tags: ['raydium']
  },
  SPWN: {
    symbol: 'SPWN',
    name: 'SPWN',
    mintAddress: '5U9QqCPhqXAJcEv9uyzFJd5zhN93vuPk1aNNkXnUfPnt',
    decimals: 9,
    tags: ['raydium']
  },
  ISOLA: {
    symbol: 'ISOLA',
    name: 'ISOLA',
    mintAddress: '333iHoRM2Awhf9uVZtSyTfU8AekdGrgQePZsKMFPgKmS',
    decimals: 6,
    tags: ['raydium']
  },
  RUN: {
    symbol: 'RUN',
    name: 'RUN',
    mintAddress: '6F9XriABHfWhit6zmMUYAQBSy6XK5VF1cHXuW5LDpRtC',
    decimals: 9,

    detailLink: 'https://raydium.medium.com/runnode-is-launching-on-acceleraytor-3ff7326864b0',
    details:
      'RunNode is a bridge from web 2.0 to 3.0 and powers the infrastructure of Solana through its RPC protocol. With a quick onboarding application to get an RPC endpoint in under 30 seconds, any project can launch, build and scale its Solana dApp — now.',
    docs: {
      website: 'https://runnode.com/'
      // whitepaper: ''
    },
    socials: {
      Twitter: 'https://twitter.com/RunNode',
      Telegram: 'https://t.me/runnode',
      Discord: 'https://discord.gg/V2f74X8Zrt'
    },

    tags: ['raydium']
  },
  REAL: {
    symbol: 'REAL',
    name: 'REAL',
    mintAddress: 'AD27ov5fVU2XzwsbvnFvb1JpCBaCB5dRXrczV9CqSVGb',
    decimals: 9,

    detailLink: 'https://raydium.medium.com/realy-is-launching-on-acceleraytor-b6d6a63d69d8',
    details:
      'Realy Metaverse will be the 1st Live-to-Earn metaverse on Solana. Developed via Unreal Engine, Realy is a virtual city with AAA graphics that seamlessly integrates virtual and reality.',
    docs: {
      website: 'https://realy.pro/'
      // whitepaper: ''
    },
    socials: {
      Twitter: 'https://twitter.com/RealyOfficial',
      Telegram: 'https://t.me/realyofficial',
      Discord: 'https://discord.gg/realy'
    },

    tags: ['raydium']
  },
  CRWNY: {
    symbol: 'CRWNY',
    name: 'CRWNY',
    mintAddress: 'CRWNYkqdgvhGGae9CKfNka58j6QQkaD5bLhKXvUYqnc1',
    decimals: 6,
    tags: ['raydium']
  },
  BLOCK: {
    symbol: 'BLOCK',
    name: 'BLOCK',
    mintAddress: 'NFTUkR4u7wKxy9QLaX2TGvd9oZSWoMo4jqSJqdMb7Nk',
    decimals: 6,
    tags: ['raydium']
  },
  SOLAR: {
    symbol: 'SOLAR',
    name: 'SOLAR',
    mintAddress: '2wmKXX1xsxLfrvjEPrt2UHiqj8Gbzwxvffr9qmNjsw8g',
    decimals: 9,
    tags: ['raydium']
  },
  BASIS: {
    symbol: 'BASIS',
    name: 'BASIS',
    mintAddress: 'Basis9oJw9j8cw53oMV7iqsgo6ihi9ALw4QR31rcjUJa',
    decimals: 6,
    tags: ['raydium']
  },
  SOLX: {
    symbol: 'SOLX',
    name: 'SOLX',
    mintAddress: 'CH74tuRLTYcxG7qNJCsV9rghfLXJCQJbsu7i52a8F1Gn',
    decimals: 9,
    tags: ['raydium']
  },
  CHICKS: {
    symbol: 'CHICKS',
    name: 'CHICKS',
    mintAddress: 'cxxShYRVcepDudXhe7U62QHvw8uBJoKFifmzggGKVC2',
    decimals: 9,
    tags: ['raydium']
  }
}

export const LP_TOKENS: Tokens = {
  'RAY-WUSDT': {
    symbol: 'RAY-WUSDT',
    name: 'RAY-WUSDT V2 LP',
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.WUSDT },

    mintAddress: 'CzPDyvotTcxNqtPne32yUiEVQ6jk42HZi1Y3hUu7qf7f',
    decimals: TOKENS.RAY.decimals
  },
  'RAY-SOL': {
    symbol: 'RAY-SOL',
    name: 'RAY-SOL LP',
    coin: { ...TOKENS.RAY },
    pc: { ...NATIVE_SOL },

    mintAddress: '134Cct3CSdRCbYgq5SkwmHgfwjJ7EM5cG9PzqffWqECx',
    decimals: TOKENS.RAY.decimals
  },
  'LINK-WUSDT': {
    symbol: 'LINK-WUSDT',
    name: 'LINK-WUSDT LP',
    coin: { ...TOKENS.LINK },
    pc: { ...TOKENS.WUSDT },

    mintAddress: 'EVDmwajM5U73PD34bYPugwiA4Eqqbrej4mLXXv15Z5qR',
    decimals: TOKENS.LINK.decimals
  },
  'ETH-WUSDT': {
    symbol: 'ETH-WUSDT',
    name: 'ETH-WUSDT LP',
    coin: { ...TOKENS.ETH },
    pc: { ...TOKENS.WUSDT },

    mintAddress: 'KY4XvwHy7JPzbWYAbk23jQvEb4qWJ8aCqYWREmk1Q7K',
    decimals: TOKENS.ETH.decimals
  },
  'RAY-USDC': {
    symbol: 'RAY-USDC',
    name: 'RAY-USDC V2 LP',
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.USDC },

    mintAddress: 'FgmBnsF5Qrnv8X9bomQfEtQTQjNNiBCWRKGpzPnE5BDg',
    decimals: TOKENS.RAY.decimals
  },
  'RAY-SRM': {
    symbol: 'RAY-SRM',
    name: 'RAY-SRM V2 LP',
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.SRM },

    mintAddress: '5QXBMXuCL7zfAk39jEVVEvcrz1AvBGgT9wAhLLHLyyUJ',
    decimals: TOKENS.RAY.decimals
  },
  // v3
  'RAY-WUSDT-V3': {
    symbol: 'RAY-WUSDT',
    name: 'RAY-WUSDT V3 LP',
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.WUSDT },

    mintAddress: 'FdhKXYjCou2jQfgKWcNY7jb8F2DPLU1teTTTRfLBD2v1',
    decimals: TOKENS.RAY.decimals
  },
  'RAY-USDC-V3': {
    symbol: 'RAY-USDC',
    name: 'RAY-USDC V3 LP',
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.USDC },

    mintAddress: 'BZFGfXMrjG2sS7QT2eiCDEevPFnkYYF7kzJpWfYxPbcx',
    decimals: TOKENS.RAY.decimals
  },
  'RAY-SRM-V3': {
    symbol: 'RAY-SRM',
    name: 'RAY-SRM V3 LP',
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.SRM },

    mintAddress: 'DSX5E21RE9FB9hM8Nh8xcXQfPK6SzRaJiywemHBSsfup',
    decimals: TOKENS.RAY.decimals
  },
  'RAY-SOL-V3': {
    symbol: 'RAY-SOL',
    name: 'RAY-SOL V3 LP',
    coin: { ...TOKENS.RAY },
    pc: { ...NATIVE_SOL },

    mintAddress: 'F5PPQHGcznZ2FxD9JaxJMXaf7XkaFFJ6zzTBcW8osQjw',
    decimals: TOKENS.RAY.decimals
  },
  'RAY-ETH-V3': {
    symbol: 'RAY-ETH',
    name: 'RAY-ETH V3 LP',
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.ETH },

    mintAddress: '8Q6MKy5Yxb9vG1mWzppMtMb2nrhNuCRNUkJTeiE3fuwD',
    decimals: TOKENS.RAY.decimals
  },
  // v4
  'FIDA-RAY-V4': {
    symbol: 'FIDA-RAY',
    name: 'FIDA-RAY LP',
    coin: { ...TOKENS.FIDA },
    pc: { ...TOKENS.RAY },

    mintAddress: 'DsBuznXRTmzvEdb36Dx3aVLVo1XmH7r1PRZUFugLPTFv',
    decimals: TOKENS.FIDA.decimals
  },
  'OXY-RAY-V4': {
    symbol: 'OXY-RAY',
    name: 'OXY-RAY LP',
    coin: { ...TOKENS.OXY },
    pc: { ...TOKENS.RAY },

    mintAddress: 'FwaX9W7iThTZH5MFeasxdLpxTVxRcM7ZHieTCnYog8Yb',
    decimals: TOKENS.OXY.decimals
  },
  'MAPS-RAY-V4': {
    symbol: 'MAPS-RAY',
    name: 'MAPS-RAY LP',
    coin: { ...TOKENS.MAPS },
    pc: { ...TOKENS.RAY },

    mintAddress: 'CcKK8srfVdTSsFGV3VLBb2YDbzF4T4NM2C3UEjC39RLP',
    decimals: TOKENS.MAPS.decimals
  },
  'KIN-RAY-V4': {
    symbol: 'KIN-RAY',
    name: 'KIN-RAY LP',
    coin: { ...TOKENS.KIN },
    pc: { ...TOKENS.RAY },

    mintAddress: 'CHT8sft3h3gpLYbCcZ9o27mT5s3Z6VifBVbUiDvprHPW',
    decimals: 6
  },
  'RAY-USDT-V4': {
    symbol: 'RAY-USDT',
    name: 'RAY-USDT LP',
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.USDT },

    mintAddress: 'C3sT1R3nsw4AVdepvLTLKr5Gvszr7jufyBWUCvy4TUvT',
    decimals: TOKENS.RAY.decimals
  },
  'SOL-USDC-V4': {
    symbol: 'SOL-USDC',
    name: 'SOL-USDC LP',
    coin: { ...NATIVE_SOL },
    pc: { ...TOKENS.USDC },

    mintAddress: '8HoQnePLqPj4M7PUDzfw8e3Ymdwgc7NLGnaTUapubyvu',
    decimals: NATIVE_SOL.decimals
  },
  'YFI-USDC-V4': {
    symbol: 'YFI-USDC',
    name: 'YFI-USDC LP',
    coin: { ...TOKENS.YFI },
    pc: { ...TOKENS.USDC },

    mintAddress: '865j7iMmRRycSYUXzJ33ZcvLiX9JHvaLidasCyUyKaRE',
    decimals: TOKENS.YFI.decimals
  },
  'SRM-USDC-V4': {
    symbol: 'SRM-USDC',
    name: 'SRM-USDC LP',
    coin: { ...TOKENS.SRM },
    pc: { ...TOKENS.USDC },

    mintAddress: '9XnZd82j34KxNLgQfz29jGbYdxsYznTWRpvZE3SRE7JG',
    decimals: TOKENS.SRM.decimals
  },
  'FTT-USDC-V4': {
    symbol: 'FTT-USDC',
    name: 'FTT-USDC LP',
    coin: { ...TOKENS.FTT },
    pc: { ...TOKENS.USDC },

    mintAddress: '75dCoKfUHLUuZ4qEh46ovsxfgWhB4icc3SintzWRedT9',
    decimals: TOKENS.FTT.decimals
  },
  'BTC-USDC-V4': {
    symbol: 'BTC-USDC',
    name: 'BTC-USDC LP',
    coin: { ...TOKENS.BTC },
    pc: { ...TOKENS.USDC },

    mintAddress: '2hMdRdVWZqetQsaHG8kQjdZinEMBz75vsoWTCob1ijXu',
    decimals: TOKENS.BTC.decimals
  },
  'SUSHI-USDC-V4': {
    symbol: 'SUSHI-USDC',
    name: 'SUSHI-USDC LP',
    coin: { ...TOKENS.SUSHI },
    pc: { ...TOKENS.USDC },

    mintAddress: '2QVjeR9d2PbSf8em8NE8zWd8RYHjFtucDUdDgdbDD2h2',
    decimals: TOKENS.SUSHI.decimals
  },
  'TOMO-USDC-V4': {
    symbol: 'TOMO-USDC',
    name: 'TOMO-USDC LP',
    coin: { ...TOKENS.TOMO },
    pc: { ...TOKENS.USDC },

    mintAddress: 'CHyUpQFeW456zcr5XEh4RZiibH8Dzocs6Wbgz9aWpXnQ',
    decimals: TOKENS.TOMO.decimals
  },
  'LINK-USDC-V4': {
    symbol: 'LINK-USDC',
    name: 'LINK-USDC LP',
    coin: { ...TOKENS.LINK },
    pc: { ...TOKENS.USDC },

    mintAddress: 'BqjoYjqKrXtfBKXeaWeAT5sYCy7wsAYf3XjgDWsHSBRs',
    decimals: TOKENS.LINK.decimals
  },
  'ETH-USDC-V4': {
    symbol: 'ETH-USDC',
    name: 'ETH-USDC LP',
    coin: { ...TOKENS.ETH },
    pc: { ...TOKENS.USDC },

    mintAddress: '13PoKid6cZop4sj2GfoBeujnGfthUbTERdE5tpLCDLEY',
    decimals: TOKENS.ETH.decimals
  },
  'xCOPE-USDC-V4': {
    symbol: 'xCOPE-USDC',
    name: 'xCOPE-USDC LP',
    coin: { ...TOKENS.xCOPE },
    pc: { ...TOKENS.USDC },

    mintAddress: '2Vyyeuyd15Gp8aH6uKE72c4hxc8TVSLibxDP9vzspQWG',
    decimals: TOKENS.xCOPE.decimals
  },
  'SOL-USDT-V4': {
    symbol: 'SOL-USDT',
    name: 'SOL-USDT LP',
    coin: { ...NATIVE_SOL },
    pc: { ...TOKENS.USDT },

    mintAddress: 'Epm4KfTj4DMrvqn6Bwg2Tr2N8vhQuNbuK8bESFp4k33K',
    decimals: NATIVE_SOL.decimals
  },
  'YFI-USDT-V4': {
    symbol: 'YFI-USDT',
    name: 'YFI-USDT LP',
    coin: { ...TOKENS.YFI },
    pc: { ...TOKENS.USDT },

    mintAddress: 'FA1i7fej1pAbQbnY8NbyYUsTrWcasTyipKreDgy1Mgku',
    decimals: TOKENS.YFI.decimals
  },
  'SRM-USDT-V4': {
    symbol: 'SRM-USDT',
    name: 'SRM-USDT LP',
    coin: { ...TOKENS.SRM },
    pc: { ...TOKENS.USDT },

    mintAddress: 'HYSAu42BFejBS77jZAZdNAWa3iVcbSRJSzp3wtqCbWwv',
    decimals: TOKENS.SRM.decimals
  },
  'FTT-USDT-V4': {
    symbol: 'FTT-USDT',
    name: 'FTT-USDT LP',
    coin: { ...TOKENS.FTT },
    pc: { ...TOKENS.USDT },

    mintAddress: '2cTCiUnect5Lap2sk19xLby7aajNDYseFhC9Pigou11z',
    decimals: TOKENS.FTT.decimals
  },
  'BTC-USDT-V4': {
    symbol: 'BTC-USDT',
    name: 'BTC-USDT LP',
    coin: { ...TOKENS.BTC },
    pc: { ...TOKENS.USDT },

    mintAddress: 'DgGuvR9GSHimopo3Gc7gfkbKamLKrdyzWkq5yqA6LqYS',
    decimals: TOKENS.BTC.decimals
  },
  'SUSHI-USDT-V4': {
    symbol: 'SUSHI-USDT',
    name: 'SUSHI-USDT LP',
    coin: { ...TOKENS.SUSHI },
    pc: { ...TOKENS.USDT },

    mintAddress: 'Ba26poEYDy6P2o95AJUsewXgZ8DM9BCsmnU9hmC9i4Ki',
    decimals: TOKENS.SUSHI.decimals
  },
  'TOMO-USDT-V4': {
    symbol: 'TOMO-USDT',
    name: 'TOMO-USDT LP',
    coin: { ...TOKENS.TOMO },
    pc: { ...TOKENS.USDT },

    mintAddress: 'D3iGro1vn6PWJXo9QAPj3dfta6dKkHHnmiiym2EfsAmi',
    decimals: TOKENS.TOMO.decimals
  },
  'LINK-USDT-V4': {
    symbol: 'LINK-USDT',
    name: 'LINK-USDT LP',
    coin: { ...TOKENS.LINK },
    pc: { ...TOKENS.USDT },

    mintAddress: 'Dr12Sgt9gkY8WU5tRkgZf1TkVWJbvjYuPAhR3aDCwiiX',
    decimals: TOKENS.LINK.decimals
  },
  'ETH-USDT-V4': {
    symbol: 'ETH-USDT',
    name: 'ETH-USDT LP',
    coin: { ...TOKENS.ETH },
    pc: { ...TOKENS.USDT },

    mintAddress: 'nPrB78ETY8661fUgohpuVusNCZnedYCgghzRJzxWnVb',
    decimals: TOKENS.ETH.decimals
  },
  'YFI-SRM-V4': {
    symbol: 'YFI-SRM',
    name: 'YFI-SRM LP',
    coin: { ...TOKENS.YFI },
    pc: { ...TOKENS.SRM },

    mintAddress: 'EGJht91R7dKpCj8wzALkjmNdUUUcQgodqWCYweyKcRcV',
    decimals: TOKENS.YFI.decimals
  },
  'FTT-SRM-V4': {
    symbol: 'FTT-SRM',
    name: 'FTT-SRM LP',
    coin: { ...TOKENS.FTT },
    pc: { ...TOKENS.SRM },

    mintAddress: 'AsDuPg9MgPtt3jfoyctUCUgsvwqAN6RZPftqoeiPDefM',
    decimals: TOKENS.FTT.decimals
  },
  'BTC-SRM-V4': {
    symbol: 'BTC-SRM',
    name: 'BTC-SRM LP',
    coin: { ...TOKENS.BTC },
    pc: { ...TOKENS.SRM },

    mintAddress: 'AGHQxXb3GSzeiLTcLtXMS2D5GGDZxsB2fZYZxSB5weqB',
    decimals: TOKENS.BTC.decimals
  },
  'SUSHI-SRM-V4': {
    symbol: 'SUSHI-SRM',
    name: 'SUSHI-SRM LP',
    coin: { ...TOKENS.SUSHI },
    pc: { ...TOKENS.SRM },

    mintAddress: '3HYhUnUdV67j1vn8fu7ExuVGy5dJozHEyWvqEstDbWwE',
    decimals: TOKENS.SUSHI.decimals
  },
  'TOMO-SRM-V4': {
    symbol: 'TOMO-SRM',
    name: 'TOMO-SRM LP',
    coin: { ...TOKENS.TOMO },
    pc: { ...TOKENS.SRM },

    mintAddress: 'GgH9RnKrQpaMQeqmdbMvs5oo1A24hERQ9wuY2pSkeG7x',
    decimals: TOKENS.TOMO.decimals
  },
  'LINK-SRM-V4': {
    symbol: 'LINK-SRM',
    name: 'LINK-SRM LP',
    coin: { ...TOKENS.LINK },
    pc: { ...TOKENS.SRM },

    mintAddress: 'GXN6yJv12o18skTmJXaeFXZVY1iqR18CHsmCT8VVCmDD',
    decimals: TOKENS.LINK.decimals
  },
  'ETH-SRM-V4': {
    symbol: 'ETH-SRM',
    name: 'ETH-SRM LP',
    coin: { ...TOKENS.ETH },
    pc: { ...TOKENS.SRM },

    mintAddress: '9VoY3VERETuc2FoadMSYYizF26mJinY514ZpEzkHMtwG',
    decimals: TOKENS.ETH.decimals
  },
  'SRM-SOL-V4': {
    symbol: 'SRM-SOL',
    name: 'SRM-SOL LP',
    coin: { ...TOKENS.SRM },
    pc: { ...NATIVE_SOL },

    mintAddress: 'AKJHspCwDhABucCxNLXUSfEzb7Ny62RqFtC9uNjJi4fq',
    decimals: TOKENS.SRM.decimals
  },
  'STEP-USDC-V4': {
    symbol: 'STEP-USDC',
    name: 'STEP-USDC LP',
    coin: { ...TOKENS.STEP },
    pc: { ...TOKENS.USDC },

    mintAddress: '3k8BDobgihmk72jVmXYLE168bxxQUhqqyESW4dQVktqC',
    decimals: TOKENS.STEP.decimals
  },
  'MEDIA-USDC-V4': {
    symbol: 'MEDIA-USDC',
    name: 'MEDIA-USDC LP',
    coin: { ...TOKENS.MEDIA },
    pc: { ...TOKENS.USDC },

    mintAddress: 'A5zanvgtioZGiJMdEyaKN4XQmJsp1p7uVxaq2696REvQ',
    decimals: TOKENS.MEDIA.decimals
  },
  'ROPE-USDC-V4': {
    symbol: 'ROPE-USDC',
    name: 'ROPE-USDC LP',
    coin: { ...TOKENS.ROPE },
    pc: { ...TOKENS.USDC },

    mintAddress: 'Cq4HyW5xia37tKejPF2XfZeXQoPYW6KfbPvxvw5eRoUE',
    decimals: TOKENS.ROPE.decimals
  },
  'MER-USDC-V4': {
    symbol: 'MER-USDC',
    name: 'MER-USDC LP',
    coin: { ...TOKENS.MER },
    pc: { ...TOKENS.USDC },

    mintAddress: '3H9NxvaZoxMZZDZcbBDdWMKbrfNj7PCF5sbRwDr7SdDW',
    decimals: TOKENS.MER.decimals
  },
  'COPE-USDC-V4': {
    symbol: 'COPE-USDC',
    name: 'COPE-USDC LP',
    coin: { ...TOKENS.COPE },
    pc: { ...TOKENS.USDC },

    mintAddress: 'Cz1kUvHw98imKkrqqu95GQB9h1frY8RikxPojMwWKGXf',
    decimals: TOKENS.COPE.decimals
  },
  'ALEPH-USDC-V4': {
    symbol: 'ALEPH-USDC',
    name: 'ALEPH-USDC LP',
    coin: { ...TOKENS.ALEPH },
    pc: { ...TOKENS.USDC },

    mintAddress: 'iUDasAP2nXm5wvTukAHEKSdSXn8vQkRtaiShs9ceGB7',
    decimals: TOKENS.ALEPH.decimals
  },
  'TULIP-USDC-V4': {
    symbol: 'TULIP-USDC',
    name: 'TULIP-USDC LP',
    coin: { ...TOKENS.TULIP },
    pc: { ...TOKENS.USDC },

    mintAddress: '2doeZGLJyACtaG9DCUyqMLtswesfje1hjNA11hMdj6YU',
    decimals: TOKENS.TULIP.decimals
  },
  'WOO-USDC-V4': {
    symbol: 'WOO-USDC',
    name: 'WOO-USDC LP',
    coin: { ...TOKENS.WOO },
    pc: { ...TOKENS.USDC },

    mintAddress: '7cu42ao8Jgrd5A3y3bNQsCxq5poyGZNmTydkGfJYQfzh',
    decimals: TOKENS.WOO.decimals
  },
  'SNY-USDC-V4': {
    symbol: 'SNY-USDC',
    name: 'SNY-USDC LP',
    coin: { ...TOKENS.SNY },
    pc: { ...TOKENS.USDC },

    mintAddress: 'G8qcfeFqxwbCqpxv5LpLWxUCd1PyMB5nWb5e5YyxLMKg',
    decimals: TOKENS.SNY.decimals
  },
  'BOP-RAY-V4': {
    symbol: 'BOP-RAY',
    name: 'BOP-RAY LP',
    coin: { ...TOKENS.BOP },
    pc: { ...TOKENS.RAY },

    mintAddress: '9nQPYJvysyfnXhQ6nkK5V7sZG26hmDgusfdNQijRk5LD',
    decimals: TOKENS.BOP.decimals
  },
  'SLRS-USDC-V4': {
    symbol: 'SLRS-USDC',
    name: 'SLRS-USDC LP',
    coin: { ...TOKENS.SLRS },
    pc: { ...TOKENS.USDC },

    mintAddress: '2Xxbm1hdv5wPeen5ponDSMT3VqhGMTQ7mH9stNXm9shU',
    decimals: TOKENS.SLRS.decimals
  },
  'SAMO-RAY-V4': {
    symbol: 'SAMO-RAY',
    name: 'SAMO-RAY LP',
    coin: { ...TOKENS.SAMO },
    pc: { ...TOKENS.RAY },

    mintAddress: 'HwzkXyX8B45LsaHXwY8su92NoRBS5GQC32HzjQRDqPnr',
    decimals: TOKENS.SAMO.decimals
  },
  'renBTC-USDC-V4': {
    symbol: 'renBTC-USDC',
    name: 'renBTC-USDC LP',
    coin: { ...TOKENS.renBTC },
    pc: { ...TOKENS.USDC },

    mintAddress: 'CTEpsih91ZLo5gunvryLpJ3pzMjmt5jbS6AnSQrzYw7V',
    decimals: TOKENS.renBTC.decimals
  },
  'renDOGE-USDC-V4': {
    symbol: 'renDOGE-USDC',
    name: 'renDOGE-USDC LP',
    coin: { ...TOKENS.renDOGE },
    pc: { ...TOKENS.USDC },

    mintAddress: 'Hb8KnZNKvRxu7pgMRWJgoMSMcepfvNiBFFDDrdf9o3wA',
    decimals: TOKENS.renDOGE.decimals
  },
  'RAY-USDC-V4': {
    symbol: 'RAY-USDC',
    name: 'RAY-USDC LP',
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.USDC },

    mintAddress: 'FbC6K13MzHvN42bXrtGaWsvZY9fxrackRSZcBGfjPc7m',
    decimals: TOKENS.RAY.decimals
  },
  'RAY-SRM-V4': {
    symbol: 'RAY-SRM',
    name: 'RAY-SRM LP',
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.SRM },

    mintAddress: '7P5Thr9Egi2rvMmEuQkLn8x8e8Qro7u2U7yLD2tU2Hbe',
    decimals: TOKENS.RAY.decimals
  },
  'RAY-ETH-V4': {
    symbol: 'RAY-ETH',
    name: 'RAY-ETH LP',
    coin: { ...TOKENS.RAY },
    pc: { ...TOKENS.ETH },

    mintAddress: 'mjQH33MqZv5aKAbKHi8dG3g3qXeRQqq1GFcXceZkNSr',
    decimals: TOKENS.RAY.decimals
  },
  'RAY-SOL-V4': {
    symbol: 'RAY-SOL',
    name: 'RAY-SOL LP',
    coin: { ...TOKENS.RAY },
    pc: { ...NATIVE_SOL },

    mintAddress: '89ZKE4aoyfLBe2RuV6jM3JGNhaV18Nxh8eNtjRcndBip',
    decimals: TOKENS.RAY.decimals
  },
  'DXL-USDC-V4': {
    symbol: 'DXL-USDC',
    name: 'DXL-USDC LP',
    coin: { ...TOKENS.DXL },
    pc: { ...TOKENS.USDC },

    mintAddress: '4HFaSvfgskipvrzT1exoVKsUZ174JyExEsA8bDfsAdY5',
    decimals: TOKENS.DXL.decimals
  },
  'LIKE-USDC-V4': {
    symbol: 'LIKE-USDC',
    name: 'LIKE-USDC LP',
    coin: { ...TOKENS.LIKE },
    pc: { ...TOKENS.USDC },

    mintAddress: 'cjZmbt8sJgaoyWYUttomAu5LJYU44ZrcKTbzTSEPDVw',
    decimals: TOKENS.LIKE.decimals
  },
  'mSOL-USDC-V4': {
    symbol: 'mSOL-USDC',
    name: 'mSOL-USDC LP',
    coin: { ...TOKENS.mSOL },
    pc: { ...TOKENS.USDC },

    mintAddress: '4xTpJ4p76bAeggXoYywpCCNKfJspbuRzZ79R7pRhbqSf',
    decimals: TOKENS.mSOL.decimals
  },
  'mSOL-SOL-V4': {
    symbol: 'mSOL-SOL',
    name: 'mSOL-SOL LP',
    coin: { ...TOKENS.mSOL },
    pc: { ...NATIVE_SOL },

    mintAddress: '5ijRoAHVgd5T5CNtK5KDRUBZ7Bffb69nktMj5n6ks6m4',
    decimals: TOKENS.mSOL.decimals
  },
  'MER-PAI-V4': {
    symbol: 'MER-PAI',
    name: 'MER-PAI LP',
    coin: { ...TOKENS.MER },
    pc: { ...TOKENS.PAI },

    mintAddress: 'DU5RT2D9EviaSmX6Ta8MZwMm85HwSEqGMRdqUiuCGfmD',
    decimals: TOKENS.MER.decimals
  },
  'PORT-USDC-V4': {
    symbol: 'PORT-USDC',
    name: 'PORT-USDC LP',
    coin: { ...TOKENS.PORT },
    pc: { ...TOKENS.USDC },

    mintAddress: '9tmNtbUCrLS15qC4tEfr5NNeqcqpZ4uiGgi2vS5CLQBS',
    decimals: TOKENS.PORT.decimals
  },
  'MNGO-USDC-V4': {
    symbol: 'MNGO-USDC',
    name: 'MNGO-USDC LP',
    coin: { ...TOKENS.MNGO },
    pc: { ...TOKENS.USDC },

    mintAddress: 'DkiqCQ792n743xjWQVCbBUaVtkdiuvQeYndM53ReWnCC',
    decimals: TOKENS.MNGO.decimals
  },
  'ATLAS-USDC-V4': {
    symbol: 'ATLAS-USDC',
    name: 'ATLAS-USDC LP',
    coin: { ...TOKENS.ATLAS },
    pc: { ...TOKENS.USDC },

    mintAddress: '9shGU9f1EsxAbiR567MYZ78WUiS6ZNCYbHe53WUULQ7n',
    decimals: TOKENS.ATLAS.decimals
  },
  'POLIS-USDC-V4': {
    symbol: 'POLIS-USDC',
    name: 'POLIS-USDC LP',
    coin: { ...TOKENS.POLIS },
    pc: { ...TOKENS.USDC },

    mintAddress: '8MbKSBpyXs8fVneKgt71jfHrn5SWtX8n4wMLpiVfF9So',
    decimals: TOKENS.POLIS.decimals
  },
  'ATLAS-RAY-V4': {
    symbol: 'ATLAS-RAY',
    name: 'ATLAS-RAY LP',
    coin: { ...TOKENS.ATLAS },
    pc: { ...TOKENS.RAY },

    mintAddress: '418MFhkaYQtbn529wmjLLqL6uKxDz7j4eZBaV1cobkyd',
    decimals: TOKENS.ATLAS.decimals
  },
  'POLIS-RAY-V4': {
    symbol: 'POLIS-RAY',
    name: 'POLIS-RAY LP',
    coin: { ...TOKENS.POLIS },
    pc: { ...TOKENS.RAY },

    mintAddress: '9ysGKUH6WqzjQEUT4dxqYCUaFNVK9QFEa24pGzjFq8xg',
    decimals: TOKENS.POLIS.decimals
  },
  'ALEPH-RAY-V4': {
    symbol: 'ALEPH-RAY',
    name: 'ALEPH-RAY LP',
    coin: { ...TOKENS.ALEPH },
    pc: { ...TOKENS.RAY },

    mintAddress: 'n76skjqv4LirhdLok2zJELXNLdRpYDgVJQuQFbamscy',
    decimals: TOKENS.ALEPH.decimals
  },
  'TULIP-RAY-V4': {
    symbol: 'TULIP-RAY',
    name: 'TULIP-RAY LP',
    coin: { ...TOKENS.TULIP },
    pc: { ...TOKENS.RAY },

    mintAddress: '3AZTviji5qduMG2s4FfWGR3SSQmNUCyx8ao6UKCPg3oJ',
    decimals: TOKENS.TULIP.decimals
  },
  'SLRS-RAY-V4': {
    symbol: 'SLRS-RAY',
    name: 'SLRS-RAY LP',
    coin: { ...TOKENS.SLRS },
    pc: { ...TOKENS.RAY },

    mintAddress: '2pk78vsKT3jfJAcN2zbpMUnrR57SZrxHqaZYyFgp92mM',
    decimals: TOKENS.SLRS.decimals
  },
  'MER-RAY-V4': {
    symbol: 'MER-RAY',
    name: 'MER-RAY LP',
    coin: { ...TOKENS.MER },
    pc: { ...TOKENS.RAY },

    mintAddress: '214hxy3AbKoaEKgqcg2aC1cP5R67cGGAyDEg5GDwC7Ub',
    decimals: TOKENS.MER.decimals
  },
  'MEDIA-RAY-V4': {
    symbol: 'MEDIA-RAY',
    name: 'MEDIA-RAY LP',
    coin: { ...TOKENS.MEDIA },
    pc: { ...TOKENS.RAY },

    mintAddress: '9Aseg5A1JD1yCiFFdDaNNxCiJ7XzrpZFmcEmLjXFdPaH',
    decimals: TOKENS.MEDIA.decimals
  },
  'SNY-RAY-V4': {
    symbol: 'SNY-RAY',
    name: 'SNY-RAY LP',
    coin: { ...TOKENS.SNY },
    pc: { ...TOKENS.RAY },

    mintAddress: '2k4quTuuLUxrSEhFH99qcoZzvgvVEc3b5sz3xz3qstfS',
    decimals: TOKENS.SNY.decimals
  },
  'LIKE-RAY-V4': {
    symbol: 'LIKE-RAY',
    name: 'LIKE-RAY LP',
    coin: { ...TOKENS.LIKE },
    pc: { ...TOKENS.RAY },

    mintAddress: '7xqDycbFSCpUpzkYapFeyPJWPwEpV7zdWbYf2MVHTNjv',
    decimals: TOKENS.LIKE.decimals
  },
  'COPE-RAY-V4': {
    symbol: 'COPE-RAY',
    name: 'COPE-RAY LP',
    coin: { ...TOKENS.COPE },
    pc: { ...TOKENS.RAY },

    mintAddress: 'A7GCVHA8NSsbdFscHdoNU41tL1TRKNmCH4K94CgcLK9F',
    decimals: TOKENS.COPE.decimals
  },
  'ETH-SOL-V4': {
    symbol: 'ETH-SOL',
    name: 'ETH-SOL LP',
    coin: { ...TOKENS.ETH },
    pc: { ...NATIVE_SOL },

    mintAddress: 'GKfgC86iJoMjwAtcyiLu6nWnjggqUXsDQihXkP14fDez',
    decimals: TOKENS.ETH.decimals
  },
  'stSOL-USDC-V4': {
    symbol: 'stSOL-USDC',
    name: 'stSOL-USDC LP',
    coin: { ...TOKENS.stSOL },
    pc: { ...TOKENS.USDC },

    mintAddress: 'HDUJMwYZkjUZre63xUeDhdCi8c6LgUDiBqxmP3QC3VPX',
    decimals: TOKENS.stSOL.decimals
  },
  'GRAPE-USDC-V4': {
    symbol: 'GRAPE-USDC',
    name: 'GRAPE-USDC LP',
    coin: { ...TOKENS.GRAPE },
    pc: { ...TOKENS.USDC },

    mintAddress: 'A8ZYmnZ1vwxUa4wpJVUaJgegsuTEz5TKy5CiJXffvmpt',
    decimals: TOKENS.GRAPE.decimals
  },
  'LARIX-USDC-V4': {
    symbol: 'LARIX-USDC',
    name: 'LARIX-USDC LP',
    coin: { ...TOKENS.LARIX },
    pc: { ...TOKENS.USDC },

    mintAddress: '7yieit4YsNsZ9CAK8H5ZEMvvk35kPEHHeXwp6naoWU9V',
    decimals: TOKENS.LARIX.decimals
  },
  'RIN-USDC-V4': {
    symbol: 'RIN-USDC',
    name: 'RIN-USDC LP',
    coin: { ...TOKENS.RIN },
    pc: { ...TOKENS.USDC },

    mintAddress: 'GfCWfrZez7BDmCSEeMERVDVUaaM2TEreyYUgb2cpuS3w',
    decimals: TOKENS.RIN.decimals
  },
  'APEX-USDC-V4': {
    symbol: 'APEX-USDC',
    name: 'APEX-USDC LP',
    coin: { ...TOKENS.APEX },
    pc: { ...TOKENS.USDC },

    mintAddress: '444cVqYyDxJNo6FqiMb9qQWFUd7tYzFRdDuJRFrSAGnU',
    decimals: TOKENS.APEX.decimals
  },
  'mSOL-RAY-V4': {
    symbol: 'mSOL-RAY',
    name: 'mSOL-RAY LP',
    coin: { ...TOKENS.mSOL },
    pc: { ...TOKENS.RAY },

    mintAddress: 'De2EHBAdkgfc72DpShqDGG42cV3iDWh8wvvZdPsiEcqP',
    decimals: TOKENS.mSOL.decimals
  },
  'MNDE-mSOL-V4': {
    symbol: 'MNDE-mSOL',
    name: 'MNDE-mSOL LP',
    coin: { ...TOKENS.MNDE },
    pc: { ...TOKENS.mSOL },

    mintAddress: '4bh8XCzTHSbqbWN8o1Jn4ueBdz1LvJFoEasN6K6CQ8Ny',
    decimals: TOKENS.MNDE.decimals
  },
  'LARIX-RAY-V4': {
    symbol: 'LARIX-RAY',
    name: 'LARIX-RAY LP',
    coin: { ...TOKENS.LARIX },
    pc: { ...TOKENS.RAY },

    mintAddress: 'ZRDfSLgWGeaYSmhdPvFNKQQhDcYdZQaue2N8YDmHX4q',
    decimals: TOKENS.LARIX.decimals
  },
  'LIQ-USDC-V4': {
    symbol: 'LIQ-USDC',
    name: 'LIQ-USDC LP',
    coin: { ...TOKENS.LIQ },
    pc: { ...TOKENS.USDC },

    mintAddress: 'GWpD3eTfhJB5KDCcnE85dBQrjAk2CsrgDF9b52R9CrjV',
    decimals: TOKENS.LIQ.decimals
  },
  'WAG-USDC-V4': {
    symbol: 'WAG-USDC',
    name: 'WAG-USDC LP',
    coin: { ...TOKENS.WAG },
    pc: { ...TOKENS.USDC },

    mintAddress: '4yykyPugitUVRewNPXXCviRvxGfsfsRMoP32z3b6FmUC',
    decimals: TOKENS.WAG.decimals
  },
  'ETH-mSOL-V4': {
    symbol: 'ETH-mSOL',
    name: 'ETH-mSOL LP',
    coin: { ...TOKENS.ETH },
    pc: { ...TOKENS.mSOL },

    mintAddress: 'HYv3grQfi8QbV7nG7EFgNK1aJSrsJ7HynXJKJVPLL2Uh',
    decimals: TOKENS.ETH.decimals
  },
  'mSOL-USDT-V4': {
    symbol: 'mSOL-USDT',
    name: 'mSOL-USDT LP',
    coin: { ...TOKENS.mSOL },
    pc: { ...TOKENS.USDT },

    mintAddress: '69NCmEW9mGpiWLjAcAWHq51k4ionJZmzgRfRT3wQaCCf',
    decimals: TOKENS.mSOL.decimals
  },
  'BTC-mSOL-V4': {
    symbol: 'BTC-mSOL',
    name: 'BTC-mSOL LP',
    coin: { ...TOKENS.BTC },
    pc: { ...TOKENS.mSOL },

    mintAddress: '92bcERNtUmuaJ6mwLSxYHZYSph37jdKxRdoYNxpcYNPp',
    decimals: TOKENS.BTC.decimals
  },
  'SLIM-SOL-V4': {
    symbol: 'SLIM-SOL',
    name: 'SLIM-SOL LP',
    coin: { ...TOKENS.SLIM },
    pc: { ...NATIVE_SOL },

    mintAddress: '9X4EK8E59VAVi6ChnNvvd39m6Yg9RtkBbAPq1mDVJT57',
    decimals: TOKENS.SLIM.decimals
  },
  'AURY-USDC-V4': {
    symbol: 'AURY-USDC',
    name: 'AURY-USDC LP',
    coin: { ...TOKENS.AURY },
    pc: { ...TOKENS.USDC },

    mintAddress: 'Gub5dvTy4nzP82qpmpNkBxmRqjtqRddBTBqHSdNcf2oS',
    decimals: TOKENS.AURY.decimals
  },
  'PRT-SOL-V4': {
    symbol: 'PRT-SOL',
    name: 'PRT-SOL LP',
    coin: { ...TOKENS.PRT },
    pc: { ...NATIVE_SOL },

    mintAddress: 'EcJ8Wgwt1AzSPiDpVr6aaSur8TKAsNTPmmzRACeqT68Z',
    decimals: TOKENS.PRT.decimals
  },
  'LIQ-RAY-V4': {
    symbol: 'LIQ-RAY',
    name: 'LIQ-RAY LP',
    coin: { ...TOKENS.LIQ },
    pc: { ...TOKENS.RAY },

    mintAddress: '49YUsDrThJosHSagCn1F59Uc9NRxbr9thVrZikUnQDXy',
    decimals: TOKENS.LIQ.decimals
  },
  'SYP-SOL-V4': {
    symbol: 'SYP-SOL',
    name: 'SYP-SOL LP',
    coin: { ...TOKENS.SYP },
    pc: { ...NATIVE_SOL },

    mintAddress: 'KHV6dfj2bDntzJ9z1S26cDfqWfUZdJRFmteLR6LxHwW',
    decimals: TOKENS.SYP.decimals
  },
  'SYP-RAY-V4': {
    symbol: 'SYP-RAY',
    name: 'SYP-RAY LP',
    coin: { ...TOKENS.SYP },
    pc: { ...TOKENS.RAY },

    mintAddress: 'FT2KZqxxM8F2h9pZtTF4PyjK88bM4YbuBzd7ZPwQ5wMB',
    decimals: TOKENS.SYP.decimals
  },
  'SYP-USDC-V4': {
    symbol: 'SYP-USDC',
    name: 'SYP-USDC LP',
    coin: { ...TOKENS.SYP },
    pc: { ...TOKENS.USDC },

    mintAddress: '2xJGuLAivAR1WkARRA6zP1v4jaA9jV2Qis8JfMNvrVyZ',
    decimals: TOKENS.SYP.decimals
  },
  'FAB-USDC-V4': {
    symbol: 'FAB-USDC',
    name: 'FAB-USDC LP',
    coin: { ...TOKENS.FAB },
    pc: { ...TOKENS.USDC },

    mintAddress: '5rTCvZq6BcApsC3VV1EEUuTJfaVd8uYhcGjwTy1By6P8',
    decimals: TOKENS.FAB.decimals
  },
  'WOOF-RAY-V4': {
    symbol: 'WOOF-RAY',
    name: 'WOOF-RAY LP',
    coin: { ...TOKENS.WOOF },
    pc: { ...TOKENS.RAY },

    mintAddress: 'H2FAnazDaGFutcmnrwDxhmdncR1Bd7GG4mhPCSUiamDX',
    decimals: TOKENS.WOOF.decimals
  },
  'WOOF-USDC-V4': {
    symbol: 'WOOF-USDC',
    name: 'WOOF-USDC LP',
    coin: { ...TOKENS.WOOF },
    pc: { ...TOKENS.USDC },

    mintAddress: 'EFSu5TMc1ijRevaYCxUkS7uGvbhsymDHEaTK3UVdNE3q',
    decimals: TOKENS.WOOF.decimals
  },
  'SLND-USDC-V4': {
    symbol: 'SLND-USDC',
    name: 'SLND-USDC LP',
    coin: { ...TOKENS.SLND },
    pc: { ...TOKENS.USDC },

    mintAddress: 'EunE9uDh2cGsyJcsGuGKc6wte7kBn8iye2gzC4w2ePHn',
    decimals: TOKENS.SLND.decimals
  },
  'FRKT-SOL-V4': {
    symbol: 'FRKT-SOL',
    name: 'FRKT-SOL LP',
    coin: { ...TOKENS.FRKT },
    pc: { ...NATIVE_SOL },

    mintAddress: 'HYUKXgpjaxMXHttyrFYtv3z2rdhZ1U9QDH8zEc8BooQC',
    decimals: TOKENS.FRKT.decimals
  },
  'weWETH-SOL-V4': {
    symbol: 'weWETH-SOL',
    name: 'weWETH-SOL LP',
    coin: { ...TOKENS.weWETH },
    pc: { ...NATIVE_SOL },

    mintAddress: '3hbozt2Por7bcrGod8N7kEeJNMocFFjCJrQR16TQGBrE',
    decimals: TOKENS.weWETH.decimals
  },
  'weWETH-USDC-V4': {
    symbol: 'weWETH-USDC',
    name: 'weWETH-USDC LP',
    coin: { ...TOKENS.weWETH },
    pc: { ...TOKENS.USDC },

    mintAddress: '3529SBnMCDW3S3xQ52aABbRHo7PcHvpQA4no8J12L5eK',
    decimals: TOKENS.weWETH.decimals
  },
  'weUNI-USDC-V4': {
    symbol: 'weUNI-USDC',
    name: 'weUNI-USDC LP',
    coin: { ...TOKENS.weUNI },
    pc: { ...TOKENS.USDC },

    mintAddress: 'EEC4QnT41py39QaYnzQnoYQEtDUDNa6Se8SBDgfPSN2a',
    decimals: TOKENS.weUNI.decimals
  },
  'weSUSHI-USDC-V4': {
    symbol: 'weSUSHI-USDC',
    name: 'weSUSHI-USDC LP',
    coin: { ...TOKENS.weSUSHI },
    pc: { ...TOKENS.USDC },

    mintAddress: '3wVrtQZsiDNp5yTPyfEzQHPU6iuJoMmpnWg6CTt4V8sR',
    decimals: TOKENS.weSUSHI.decimals
  },
  'CYS-USDC-V4': {
    symbol: 'CYS-USDC',
    name: 'CYS-USDC LP',
    coin: { ...TOKENS.CYS },
    pc: { ...TOKENS.USDC },

    mintAddress: 'GfV3QDzzdVUwCNSdfn6PjhmyJvjw18tn51RingWZYwk3',
    decimals: TOKENS.CYS.decimals
  },
  'SAMO-USDC-V4': {
    symbol: 'SAMO-USDC',
    name: 'SAMO-USDC LP',
    coin: { ...TOKENS.SAMO },
    pc: { ...TOKENS.USDC },

    mintAddress: 'B2PjGEP3vPf1999fUD14pYdxvSDRVBk43hxB2rgthwEY',
    decimals: TOKENS.SAMO.decimals
  },
  'ABR-USDC-V4': {
    symbol: 'ABR-USDC',
    name: 'ABR-USDC LP',
    coin: { ...TOKENS.ABR },
    pc: { ...TOKENS.USDC },

    mintAddress: 'ECHfxkf5zjjZFTX95QfFahNyzG7feyEKcfTdjsdrMSGU',
    decimals: TOKENS.ABR.decimals
  },
  'IN-USDC-V4': {
    symbol: 'IN-USDC',
    name: 'IN-USDC LP',
    coin: { ...TOKENS.IN },
    pc: { ...TOKENS.USDC },

    mintAddress: 'GbmJtVgg9fRmmmjKUYGMZeSt8wZ47cDDXasg5Y3iF4kz',
    decimals: TOKENS.IN.decimals
  },
  'weDYDX-USDC-V4': {
    symbol: 'weDYDX-USDC',
    name: 'weDYDX-USDC LP',
    coin: { ...TOKENS.weDYDX },
    pc: { ...TOKENS.USDC },

    mintAddress: 'BjkkMZnnzmgLqzGErzDbkk15ozv48iVKQuunpeM2Hqnk',
    decimals: TOKENS.weDYDX.decimals
  },
  'STARS-USDC-V4': {
    symbol: 'STARS-USDC',
    name: 'STARS-USDC LP',
    coin: { ...TOKENS.STARS },
    pc: { ...TOKENS.USDC },

    mintAddress: 'FJ68q7NChhETcGVdinMbM2FF1Cy79dpmUi6HC83K55Hv',
    decimals: TOKENS.STARS.decimals
  },
  'weAXS-USDC-V4': {
    symbol: 'weAXS-USDC',
    name: 'weAXS-USDC LP',
    coin: { ...TOKENS.weAXS },
    pc: { ...TOKENS.USDC },

    mintAddress: '6PSoJQ7myQ1BJtbQC6oiWR8HSecQGyoWsPYTZRJo2ci3',
    decimals: TOKENS.weAXS.decimals
  },
  'weSHIB-USDC-V4': {
    symbol: 'weSHIB-USDC',
    name: 'weSHIB-USDC LP',
    coin: { ...TOKENS.weSHIB },
    pc: { ...TOKENS.USDC },

    mintAddress: 'AcjX5pmTMGSgxkdxc3r82r6WMKBvS6eQXXFz5ck5KKUa',
    decimals: TOKENS.weSHIB.decimals
  },
  'SBR-USDC-V4': {
    symbol: 'SBR-USDC',
    name: 'SBR-USDC LP',
    coin: { ...TOKENS.SBR },
    pc: { ...TOKENS.USDC },

    mintAddress: '9FC8xTFRbgTpuZZYAYnZLxgnQ8r7FwfSBM1SWvGwgF7s',
    decimals: TOKENS.SBR.decimals
  },
  'OXS-USDC-V4': {
    symbol: 'OXS-USDC',
    name: 'OXS-USDC LP',
    coin: { ...TOKENS.OXS },
    pc: { ...TOKENS.USDC },

    mintAddress: 'et9pdjWm97rbmsJoN183GkFV5qzTGru79GE1Zhe7NTU',
    decimals: TOKENS.OXS.decimals
  },
  'CWAR-USDC-V4': {
    symbol: 'CWAR-USDC',
    name: 'CWAR-USDC LP',
    coin: { ...TOKENS.CWAR },
    pc: { ...TOKENS.USDC },

    mintAddress: 'HjR23bxn2gtRDB2P1Tm3DLepAPPZgazsWJpLG9wqjnYR',
    decimals: TOKENS.CWAR.decimals
  },
  'UPS-USDC-V4': {
    symbol: 'UPS-USDC',
    name: 'UPS-USDC LP',
    coin: { ...TOKENS.UPS },
    pc: { ...TOKENS.USDC },

    mintAddress: '9hSUZdREEsbaYaKY4FouvXr7xyAqtpdHRDoYCb6Mb28a',
    decimals: TOKENS.UPS.decimals
  },
  'weSAND-USDC-V4': {
    symbol: 'weSAND-USDC',
    name: 'weSAND-USDC LP',
    coin: { ...TOKENS.weSAND },
    pc: { ...TOKENS.USDC },

    mintAddress: '3dADrQa7utyiCsaFeVk9r7oebW1WheowhKo5soBYKBVT',
    decimals: TOKENS.weSAND.decimals
  },
  'weMANA-USDC-V4': {
    symbol: 'weMANA-USDC',
    name: 'weMANA-USDC LP',
    coin: { ...TOKENS.weMANA },
    pc: { ...TOKENS.USDC },

    mintAddress: 'HpUkVAPRJ5zNRuJ1ZwMXEhbMHL3gSuPb2QuSER9YUd3a',
    decimals: TOKENS.weMANA.decimals
  },
  'CAVE-USDC-V4': {
    symbol: 'CAVE-USDC',
    name: 'CAVE-USDC LP',
    coin: { ...TOKENS.CAVE },
    pc: { ...TOKENS.USDC },

    mintAddress: '5Gba1k3fU7Vh7UtAiBmie9vhQNNq1JfEwgn1DPGZ7NKQ',
    decimals: TOKENS.CAVE.decimals
  },
  'GENE-USDC-V4': {
    symbol: 'GENE-USDC',
    name: 'GENE-USDC LP',
    coin: { ...TOKENS.GENE },
    pc: { ...TOKENS.USDC },

    mintAddress: '7GKvfHEXenNiWYbJBKae89mdaMPr5gGMYwZmyC8gBNVG',
    decimals: TOKENS.GENE.decimals
  },
  'GENE-RAY-V4': {
    symbol: 'GENE-RAY',
    name: 'GENE-RAY LP',
    coin: { ...TOKENS.GENE },
    pc: { ...TOKENS.RAY },

    mintAddress: '3HzXnc1qZ8mGqun18Ck3KA616XnZNqF1RWbgYE2nGRMA',
    decimals: TOKENS.GENE.decimals
  },
  'APT-USDC-V4': {
    symbol: 'APT-USDC',
    name: 'APT-USDC LP',
    coin: { ...TOKENS.APT },
    pc: { ...TOKENS.USDC },

    mintAddress: 'Hk8mDAJFq4E9kF3DtNgPFwzbo5kbeiusNFJgWmo3LoQ5',
    decimals: TOKENS.APT.decimals
  },
  'GOFX-USDC-V4': {
    symbol: 'GOFX-USDC',
    name: 'GOFX-USDC LP',
    coin: { ...TOKENS.GOFX },
    pc: { ...TOKENS.USDC },

    mintAddress: '4svqAwrLPGRDCQuuieYTmtLXF75wiahjeK2rEN9tY1YL',
    decimals: TOKENS.GOFX.decimals
  },
  'SONAR-USDC-V4': {
    symbol: 'SONAR-USDC',
    name: 'SONAR-USDC LP',
    coin: { ...TOKENS.SONAR },
    pc: { ...TOKENS.USDC },

    mintAddress: '2tAcfqJ1YYjpGLqwh76kyNt9VaNFDd4fJySfH6SmWfKt',
    decimals: TOKENS.SONAR.decimals
  },
  'JSOL-SOL-V4': {
    symbol: 'JSOL-SOL',
    name: 'JSOL-SOL LP',
    coin: { ...TOKENS.JSOL },
    pc: { ...NATIVE_SOL },

    mintAddress: '61z37rpHsU6d3Fq5sUjJ85K6tXGzkoYKDAG3kPJQNDRo',
    decimals: TOKENS.JSOL.decimals
  },
  'JSOL-USDC-V4': {
    symbol: 'JSOL-USDC',
    name: 'JSOL-USDC LP',
    coin: { ...TOKENS.JSOL },
    pc: { ...TOKENS.USDC },

    mintAddress: '3JZqf2VPNxj1kDZQsfzC7myM6spsGQbGuFv1gVfdYosN',
    decimals: TOKENS.JSOL.decimals
  },
  'SHILL-USDC-V4': {
    symbol: 'SHILL-USDC',
    name: 'SHILL-USDC LP',
    coin: { ...TOKENS.SHILL },
    pc: { ...TOKENS.USDC },

    mintAddress: 'CnUhYBtQEbSBZ76bgxAouVCTCb8rofZzwerVF5z5LREJ',
    decimals: TOKENS.SHILL.decimals
  },
  'DFL-USDC-V4': {
    symbol: 'DFL-USDC',
    name: 'DFL-USDC LP',
    coin: { ...TOKENS.DFL },
    pc: { ...TOKENS.USDC },

    mintAddress: 'Fffijd6UVJdQeLVXhenS8YcsnMUdWJqpbBeH42LFkXgS',
    decimals: TOKENS.DFL.decimals
  },
  'BOKU-USDC-V4': {
    symbol: 'BOKU-USDC',
    name: 'BOKU-USDC LP',
    coin: { ...TOKENS.BOKU },
    pc: { ...TOKENS.USDC },

    mintAddress: '8jjQn5Yagb6Nm2WGAxPW1bcGqrTWpg5adf6QukXEarcP',
    decimals: TOKENS.BOKU.decimals
  },
  'MIMO-SOL-V4': {
    symbol: 'MIMO-SOL',
    name: 'MIMO-SOL LP',
    coin: { ...TOKENS.MIMO },
    pc: { ...NATIVE_SOL },

    mintAddress: 'HUJ1opSk8AiPfDT47r7n4hTiK2EXgrR3Msy7T8q1BywS',
    decimals: TOKENS.MIMO.decimals
  },
  'wbWBNB-USDC-V4': {
    symbol: 'wbWBNB-USDC',
    name: 'wbWBNB-USDC LP',
    coin: { ...TOKENS.wbWBNB },
    pc: { ...TOKENS.USDC },

    mintAddress: 'FEsEfEJJSfiMQcshUgZ5UigfytfGRQ3z5puyF6DXDp9C',
    decimals: TOKENS.wbWBNB.decimals
  },
  'wePEOPLE-USDC-V4': {
    symbol: 'wePEOPLE-USDC',
    name: 'wePEOPLE-USDC LP',
    coin: { ...TOKENS.wePEOPLE },
    pc: { ...TOKENS.USDC },

    mintAddress: '3e5ZCKi4etorpV4pv1fSckP5iJD67xcUkx3RtFCZhbzD',
    decimals: TOKENS.wePEOPLE.decimals
  },
  'ISOLA-USDT-V4': {
    symbol: 'ISOLA-USDT',
    name: 'ISOLA-USDT LP',
    coin: { ...TOKENS.ISOLA },
    pc: { ...TOKENS.USDT },

    mintAddress: 'H8s1wQsZpRK61pyLF3XwyQc6E8vNUnwRDhy3TBDCDENQ',
    decimals: TOKENS.ISOLA.decimals
  },
  'SPWN-USDC-V4': {
    symbol: 'SPWN-USDC',
    name: 'SPWN-USDC LP',
    coin: { ...TOKENS.SPWN },
    pc: { ...TOKENS.USDC },

    mintAddress: 'B5uyCAQcX6nAjZypLgiivbEKabSptgUb8JK9tkaSnqdW',
    decimals: TOKENS.SPWN.decimals
  },
  'STR-USDC-V4': {
    symbol: 'STR-USDC',
    name: 'STR-USDC LP',
    coin: { ...TOKENS.STR },
    pc: { ...TOKENS.USDC },

    mintAddress: '8uDVKmVwNmbXHDB7rNKqtpcT9VAsFHTJ5pPYxjyoBbNg',
    decimals: TOKENS.STR.decimals
  },
  'SOLC-USDT-V4': {
    symbol: 'SOLC-USDT',
    name: 'SOLC-USDT LP',
    coin: { ...TOKENS.SOLC },
    pc: { ...TOKENS.USDT },

    mintAddress: '2g9JzTWycLzK4KEBBHsponAtZRee2ii63bRrJ8tefEyt',
    decimals: TOKENS.SOLC.decimals
  },
  'VI-USDC-V4': {
    symbol: 'VI-USDC',
    name: 'VI-USDC LP',
    coin: { ...TOKENS.VI },
    pc: { ...TOKENS.USDC },

    mintAddress: '3MwHyHCRfVqtH3ABFtdKXdY9dwemr9GGxQFaBkeq6NjY',
    decimals: TOKENS.VI.decimals
  },
  'KKO-USDC-V4': {
    symbol: 'KKO-USDC',
    name: 'KKO-USDC LP',
    coin: { ...TOKENS.KKO },
    pc: { ...TOKENS.USDC },

    mintAddress: '7xr1Doc1NiMWbUg99YVFqQSLfYXNzo6YvacXUsSgBMNW',
    decimals: TOKENS.KKO.decimals
  },
  'XTAG-USDC-V4': {
    symbol: 'XTAG-USDC',
    name: 'XTAG-USDC LP',
    coin: { ...TOKENS.XTAG },
    pc: { ...TOKENS.USDC },

    mintAddress: 'GCEQbLg4ik5YJ4CMcbtuVqEc4sjLdSGy34rFk1CtGjdg',
    decimals: TOKENS.XTAG.decimals
  },
  'TTT-USDC-V4': {
    symbol: 'TTT-USDC',
    name: 'TTT-USDC LP',
    coin: { ...TOKENS.TTT },
    pc: { ...TOKENS.USDC },

    mintAddress: '84fmrerHGohoRf4iLPDQ1KG4CjSjCRksYWGzjWfCRM8a',
    decimals: TOKENS.TTT.decimals
  },
  'RUN-USDC-V4': {
    symbol: 'RUN-USDC',
    name: 'RUN-USDC LP',
    coin: { ...TOKENS.RUN },
    pc: { ...TOKENS.USDC },

    mintAddress: 'CjTLvvKSQdEujcSzeZRYgk4w1DpuXBbMppLHaxZyz11Y',
    decimals: TOKENS.RUN.decimals
  },
  'CRWNY-USDC-V4': {
    symbol: 'CRWNY-USDC',
    name: 'CRWNY-USDC LP',
    coin: { ...TOKENS.CRWNY },
    pc: { ...TOKENS.USDC },

    mintAddress: 'H3D9Gyi4frRLW6bS9vBthDVDJyzyRJ6XhhpP6PJGWaDC',
    decimals: TOKENS.CRWNY.decimals
  },
  'CRWNY-RAY-V4': {
    symbol: 'CRWNY-RAY',
    name: 'CRWNY-RAY LP',
    coin: { ...TOKENS.CRWNY },
    pc: { ...TOKENS.RAY },

    mintAddress: '5Cz9wGStNjiUg81q8t6sJJeckuT2C14CYSfyQbtYirSX',
    decimals: TOKENS.CRWNY.decimals
  },
  'BLOCK-USDC-V4': {
    symbol: 'BLOCK-USDC',
    name: 'BLOCK-USDC LP',
    coin: { ...TOKENS.BLOCK },
    pc: { ...TOKENS.USDC },

    mintAddress: '8i44Y23GkkwDYZ5iSkVEqmrXUfwNmwo9grguTDWKM8wg',
    decimals: TOKENS.BLOCK.decimals
  },
  'REAL-USDC-V4': {
    symbol: 'REAL-USDC',
    name: 'REAL-USDC LP',
    coin: { ...TOKENS.REAL },
    pc: { ...TOKENS.USDC },

    mintAddress: 'EN43tp8xdkcM8RYSJ4msFHMPTJRXKhUteVYBDJLwTvr3',
    decimals: TOKENS.REAL.decimals
  }
}

function addUserLocalCoinMint() {
  const localMintStr = window.localStorage.user_add_coin_mint
  const localMintList = (localMintStr ?? '').split('---')
  if (localMintList.length % 3 !== 0) {
    window.localStorage.removeItem('user_add_coin_mint')
  } else {
    for (let index = 0; index < Math.floor(localMintList.length / 3); index += 1) {
      const name = localMintList[index * 3 + 0]
      const mintAddress = localMintList[index * 3 + 1]
      const decimals = localMintList[index * 3 + 2]
      if (!Object.values(TOKENS).find((item) => item.mintAddress === mintAddress)) {
        TOKENS[name + mintAddress + 'unofficialUserAdd'] = {
          name,
          symbol: name,
          decimals: parseInt(decimals),
          mintAddress,
          tags: ['userAdd']
        }
      } else if (
        !Object.values(TOKENS)
          .find((item) => item.mintAddress === mintAddress)
          .tags.includes('userAdd')
      ) {
        Object.values(TOKENS)
          .find((item) => item.mintAddress === mintAddress)
          .tags.push('userAdd')
      }
    }
  }
}

// fake
const BLACK_LIST = ['3pX59cis3ZXnX6ZExPoUQjpvJVspmj4YavtUmpTpkB33']

function blockBlackList(tokens: { address: string }[]) {
  return tokens.filter((item) => !BLACK_LIST.includes(item.address))
}

function addTokensSolana() {
  fetch('https://api.raydium.io/cache/solana-token-list')
    .then(async (response) => {
      addTokensSolanaFunc(blockBlackList((await response.json()).tokens))
    })
    .catch(() => {
      fetch('https://raw.githubusercontent.com/solana-labs/token-list/main/src/tokens/solana.tokenlist.json')
        .then(function (response) {
          return response.json()
        })
        .then(function (myJson) {
          addTokensSolanaFunc(blockBlackList(myJson.tokens))
        })
    })
}

const notUseSolanaPicMint: string[] = [TOKENS.TTT.mintAddress]

function addTokensSolanaFunc(tokens: any[]) {
  tokens.forEach((itemToken: any) => {
    if (itemToken.tags && itemToken.tags.includes('lp-token')) {
      return
    }
    if (!Object.values(TOKENS).find((item) => item.mintAddress === itemToken.address)) {
      TOKENS[itemToken.symbol + itemToken.address + 'solana'] = {
        symbol: itemToken.symbol,
        name: itemToken.name,
        mintAddress: itemToken.address,
        decimals: itemToken.decimals,
        picUrl: itemToken.logoURI,
        tags: ['solana']
      }
    } else {
      const token = Object.values(TOKENS).find((item) => item.mintAddress === itemToken.address)
      if (token.symbol !== itemToken.symbol && !token.tags.includes('raydium')) {
        token.symbol = itemToken.symbol
        token.name = itemToken.name
        token.decimals = itemToken.decimals
        token.tags.push('solana')
      }
      const picToken = Object.values(TOKENS).find((item) => item.mintAddress === itemToken.address)
      if (picToken && !notUseSolanaPicMint.includes(itemToken.address)) {
        picToken.picUrl = itemToken.logoURI
      }
    }
  })

  if (window.localStorage.addSolanaCoin) {
    window.localStorage.addSolanaCoin.split('---').forEach((itemMint: string) => {
      if (itemMint === NATIVE_SOL.mintAddress) NATIVE_SOL.tags.push('userAdd')
      else
        Object.keys(TOKENS).forEach((item) => {
          if (TOKENS[item].mintAddress === itemMint) {
            TOKENS[item].tags.push('userAdd')
          }
        })
    })
  }
}

function updateTokenTagsChange() {
  const userSelectSource = window.localStorage.userSelectSource ?? ''
  const userSelectSourceList: string[] = userSelectSource.split('---')
  for (const itemSource of userSelectSourceList) {
    if (TOKENS_TAGS[itemSource] && !TOKENS_TAGS[itemSource].mustShow) {
      TOKENS_TAGS[itemSource].show = true
    }
  }
}

addUserLocalCoinMint()
addTokensSolana()
updateTokenTagsChange()
```

更新 `utils/web3.ts` 檔。

```TS
import { initializeAccount } from "@project-serum/serum/lib/token-instructions";
import { WalletContextState } from "@solana/wallet-adapter-react";

// @ts-ignore without ts ignore, yarn build will failed
import { Token } from "@solana/spl-token";
import {
    Keypair,                                                              // Account is deprecated, using Keypair instead
    Commitment,
    Connection,
    PublicKey,
    TransactionSignature,
    Transaction,
    SystemProgram,
    AccountInfo,
    LAMPORTS_PER_SOL
} from "@solana/web3.js";

import { ASSOCIATED_TOKEN_PROGRAM_ID, TOKEN_PROGRAM_ID } from "./ids";
import { ACCOUNT_LAYOUT } from "./layouts";

export const commitment: Commitment = "confirmed";
export async function createTokenAccountIfNotExist(                     // returns Token Account
    connection: Connection,
    account: string | undefined | null,
    owner: PublicKey,
    mintAddress: string,
    lamports: number | null,

    transaction: Transaction,
    signer: Array<Keypair>
) : Promise<PublicKey> {
    let publicKey;

    if (account) {
        publicKey = new PublicKey(account);
    } else {
        publicKey = await createProgramAccountIfNotExist(
            connection,
            account,
            owner,
            TOKEN_PROGRAM_ID,
            lamports,
            ACCOUNT_LAYOUT,
            transaction,
            signer
        );

        transaction.add(
            initializeAccount({
                account: publicKey,
                mint: new PublicKey(mintAddress),
                owner
            })
        );
    }
    return publicKey;
}

export async function createAssociatedTokenAccountIfNotExist(
    account: string | undefined | null,
    owner: PublicKey,
    mintAddress: string,

    transaction: Transaction,
    atas: string[] = []
) {
    let publicKey;
    if (account) {
        publicKey = new PublicKey(account);
    }

    const mint = new PublicKey(mintAddress);
    // @ts-ignore without ts ignore, yarn build will failed
    const ata = await Token.getAssociatedTokenAddress(
        ASSOCIATED_TOKEN_PROGRAM_ID,
        TOKEN_PROGRAM_ID,
        mint,
        owner,
        true
    );

    if (
        (!publicKey || !ata.equals(publicKey)) &&
        !atas.includes(ata.toBase58())
    ) {
        transaction.add(
            Token.createAssociatedTokenAccountInstruction(
                ASSOCIATED_TOKEN_PROGRAM_ID,
                TOKEN_PROGRAM_ID,
                mint,
                ata,
                owner,
                owner
            )
        );
        atas.push(ata.toBase58());
    }

    return ata;
}

export async function sendTransaction(
    connection: Connection,
    wallet: any,
    transaction: Transaction,
    signers: Array<Keypair> = []
) {
    const txid: TransactionSignature = await wallet.sendTransaction(
        transaction,
        connection,
        {
            signers,
            skipPreflight: true,
            preflightCommitment: commitment
        }
    );

    return txid;
}

export async function createProgramAccountIfNotExist(
  connection: Connection,
  account: string | undefined | null,
  owner: PublicKey,
  programId: PublicKey,
  lamports: number | null,
  layout: any,

  transaction: Transaction,
  signer: Array<Keypair>
) {
  let publicKey;

  if (account) {
    publicKey = new PublicKey(account);
  } else {
    const newAccount = new Keypair();
    publicKey = newAccount.publicKey;

    transaction.add(
      SystemProgram.createAccount({
        fromPubkey: owner,
        newAccountPubkey: publicKey,
        lamports:
          lamports ??
          (await connection.getMinimumBalanceForRentExemption(layout.span)),
        space: layout.span,
        programId
      })
    );

    signer.push(newAccount);
  }

    return publicKey;
}

export async function findAssociatedTokenAddress(
    walletAddress: PublicKey,
    tokenMintAddress: PublicKey
) {
    const { publicKey } = await findProgramAddress(
        [
        walletAddress.toBuffer(),
        TOKEN_PROGRAM_ID.toBuffer(),
        tokenMintAddress.toBuffer()
        ],
        ASSOCIATED_TOKEN_PROGRAM_ID
    );
    return publicKey;
}

export async function findProgramAddress(
    seeds: Array<Buffer | Uint8Array>,
    programId: PublicKey
) {
    const [publicKey, nonce] = await PublicKey.findProgramAddress(
        seeds,
        programId
    );
    return { publicKey, nonce };
}

export async function getMultipleAccounts(
    connection: Connection,
    publicKeys: PublicKey[],
    commitment?: Commitment
): Promise<Array<null | { publicKey: PublicKey; account: AccountInfo<Buffer> }>> {
    const keys: PublicKey[][] = [];
    let tempKeys: PublicKey[] = [];

    publicKeys.forEach(k => {
        if (tempKeys.length >= 100) {
        keys.push(tempKeys);
        tempKeys = [];
        }
        tempKeys.push(k);
    });
    if (tempKeys.length > 0) {
        keys.push(tempKeys);
    }

    const accounts: Array<null | {
        executable: any;
        owner: PublicKey;
        lamports: any;
        data: Buffer;
    }> = [];
    const resArray: { [key: number]: any } = {};

    await Promise.all(
        keys.map(async (key, index) => {
        const res = await connection.getMultipleAccountsInfo(key, commitment);
        resArray[index] = res;
        })
    );

    Object.keys(resArray)
        .sort((a, b) => parseInt(a) - parseInt(b))
        .forEach(itemIndex => {
            const res = resArray[parseInt(itemIndex)];
            for (const account of res) {
                accounts.push(account);
            }
        });

    return accounts.map((account, idx) => {
        if (account === null) {
        return null;
        }
        return {
        publicKey: publicKeys[idx],
        account
        };
    });
}

export async function getFilteredProgramAccountsAmmOrMarketCache(
  cacheName: String,
  connection: Connection,
  programId: PublicKey,
  filters: any
): Promise<{ publicKey: PublicKey; accountInfo: AccountInfo<Buffer> }[]> {
  try {
    if (!cacheName) {
        throw new Error("cacheName error");
    }

    const resp = await (
      await fetch("https://api.raydium.io/cache/rpc/" + cacheName)
    ).json();
    if (resp.error) {
      throw new Error(resp.error.message);
    }
    // @ts-ignore
    return resp.result.map(
      // @ts-ignore
      ({ pubkey, account: { data, executable, owner, lamports } }) => ({
        publicKey: new PublicKey(pubkey),
        accountInfo: {
          data: Buffer.from(data[0], "base64"),
          executable,
          owner: new PublicKey(owner),
          lamports
        }
      })
    );
  } catch (e) {
    return getFilteredProgramAccounts(connection, programId, filters);
  }
}

export async function getFilteredProgramAccounts(
  connection: Connection,
  programId: PublicKey,
  filters: any
): Promise<{ publicKey: PublicKey; accountInfo: AccountInfo<Buffer> }[]> {
  // @ts-ignore
  const resp = await connection._rpcRequest("getProgramAccounts", [
    programId.toBase58(),
    {
      commitment: connection.commitment,
      filters,
      encoding: "base64"
    }
  ]);
  if (resp.error) {
    throw new Error(resp.error.message);
  }
  return resp.result.map(
    // @ts-ignore
    ({ pubkey, account: { data, executable, owner, lamports } }) => ({
      publicKey: new PublicKey(pubkey),
      accountInfo: {
        data: Buffer.from(data[0], "base64"),
        executable,
        owner: new PublicKey(owner),
        lamports
      }
    })
  );
}

export async function createAmmAuthority(programId: PublicKey) {
  return await findProgramAddress(
    [
      new Uint8Array(
        Buffer.from("amm authority".replace("\u00A0", " "), "utf-8")
      )
    ],
    programId
  );
}
// export interface ISplToken {
//   pubkey: string;
//   parsedInfo: any;
//   amount: number;
// }

export const getSPLTokenData = async (
  wallet: WalletContextState,
  connection: Connection
): Promise<ISplToken[]> => {
  if (!wallet.connected) {
    return [];
  }
  const res = await connection.getParsedTokenAccountsByOwner(
    wallet.publicKey!,
    {
      programId: new PublicKey(TOKEN_PROGRAM_ID)
    },
    "confirmed"
  );
                                                                            // Get all SPL tokens owned by connected wallet
  let data = await connection.getAccountInfo(wallet.publicKey!);

  let list = res.value.map(item => {
    let token = {
      pubkey: item.pubkey.toBase58(),
      parsedInfo: item.account.data.parsed.info,
      amount:
        item.account.data.parsed.info.tokenAmount.amount /
        10 ** item.account.data.parsed.info.tokenAmount.decimals
    };
                                                                            // Filter out empty account
    if (item.account.data.parsed.info.tokenAmount.decimals === 0) {
      return undefined;
    } else {
      return token;
    }
  });
                                                                            // Add SOL into list
  list.push({
    //@ts-ignore
    pubkey: wallet.publicKey?.toBase58(),
    parsedInfo: {
      mint: data?.owner.toBase58()
    },
    //@ts-ignore
    amount: data?.lamports / LAMPORTS_PER_SOL
  });
  return list as ISplToken[];
};
```

更新 `views/raydium/TitleRow.tsx` 檔。

```TS
import style from "../../styles/swap.module.sass";
import {
  Tooltip,
  Popover,
  PopoverTrigger,
  PopoverContent,
  PopoverBody,
  PopoverArrow
} from "@chakra-ui/react";
import { SettingsIcon, InfoOutlineIcon } from "@chakra-ui/icons";
import { useState, useEffect, FunctionComponent } from "react";
import { TokenData, ITokenInfo } from ".";

interface ITitleProps {
  toggleSlippageSetting: Function;
  fromData: TokenData;
  toData: TokenData;
  updateSwapOutAmount: Function;
}

interface IAddressInfoProps {
  type: string;
}

const TitleRow: FunctionComponent<ITitleProps> = (props): JSX.Element => {
  const [second, setSecond] = useState<number>(0);
  const [percentage, setPercentage] = useState<number>(0);

  useEffect(() => {
    let id = setInterval(() => {
      setSecond(second + 1);
      setPercentage((second * 100) / 60);
      if (second === 60) {
        setSecond(0);
        props.updateSwapOutAmount();
      }
    }, 1000);
    return () => clearInterval(id);
  });

  const AddressInfo: FunctionComponent<IAddressInfoProps> = (
    addressProps
  ): JSX.Element => {
    let fromToData = {} as ITokenInfo;
    if (addressProps.type === "From") {
      fromToData = props.fromData.tokenInfo;
    } else {
      fromToData = props.toData.tokenInfo;
    }

    return (
      <>
        <span className={style.symbol}>{fromToData?.symbol}</span>
        <span className={style.address}>
          <span>{fromToData?.mintAddress.substring(0, 14)}</span>
          <span>{fromToData?.mintAddress ? "..." : ""}</span>
          {fromToData?.mintAddress.substr(-14)}
        </span>
      </>
    );
  };

  return (
    <div className={style.titleContainer}>
      <div className={style.title}>Swap</div>
      <div className={style.iconContainer}>
        <Tooltip
          hasArrow
          label={`Displayed data will auto-refresh after ${
            60 - second
          } seconds. Click this circle to update manually.`}
          color="white"
          bg="brand.100"
          padding="3"
        >
          <svg
            viewBox="0 0 36 36"
            className={`${style.percentageCircle} ${style.icon}`}
          >
            <path
              className={style.circleBg}
              d="M18 2.0845
              a 15.9155 15.9155 0 0 1 0 31.831
              a 15.9155 15.9155 0 0 1 0 -31.831"
            />
            <path
              d="M18 2.0845
              a 15.9155 15.9155 0 0 1 0 31.831
              a 15.9155 15.9155 0 0 1 0 -31.831"
              fill="none"
              stroke="rgb(20, 120, 227)"
              strokeWidth="3"
              // @ts-ignore
              strokeDasharray={[percentage, 100]}
            />
          </svg>
        </Tooltip>
        <Popover trigger="hover">
          <PopoverTrigger>
            <div className={style.icon}>
              <InfoOutlineIcon w={18} h={18} />
            </div>
          </PopoverTrigger>
          <PopoverContent
            color="white"
            bg="brand.100"
            border="none"
            w="auto"
            className={style.popover}
          >
            <PopoverArrow bg="brand.100" className={style.popover} />
            <PopoverBody>
              <div className={style.selectTokenAddressTitle}>
                Program Addresses (DO NOT DEPOSIT)
              </div>
              <div className={style.selectTokenAddress}>
                {props.fromData.tokenInfo?.symbol ? (
                  <AddressInfo type="From" />
                ) : (
                  ""
                )}
              </div>
              <div className={style.selectTokenAddress}>
                {props.toData.tokenInfo?.symbol ? (
                  <AddressInfo type="To" />
                ) : (
                  ""
                )}
              </div>
            </PopoverBody>
          </PopoverContent>
        </Popover>
        <div
          className={style.icon}
          onClick={() => props.toggleSlippageSetting()}
        >
          <SettingsIcon w={18} h={18} />
        </div>
      </div>
    </div>
  );
};

export default TitleRow;
```

更新 `views/raydium/TokenList.tsx` 檔。

```TS
import { FunctionComponent, useEffect, useRef, useState } from "react";
import { CloseIcon } from "@chakra-ui/icons";
import SPLTokenRegistrySource from "../../utils/tokenList";
import { TOKENS } from "../../utils/tokens";
import { ITokenInfo } from ".";
import style from "../../styles/swap.module.sass";

interface TokenListProps {
  showTokenList: boolean;
  toggleTokenList: (event?: React.MouseEvent<HTMLDivElement>) => void;
  getTokenInfo: Function;
}

const TokenList: FunctionComponent<TokenListProps> = props => {
  const [initialList, setList] = useState<ITokenInfo[]>([]);
  const [searchedList, setSearchList] = useState<ITokenInfo[]>([]);
  const searchRef = useRef<any>();

  useEffect(() => {
    SPLTokenRegistrySource().then((res: any) => {
      let list: ITokenInfo[] = [];
      res.map((item: any) => {
        let token = {} as ITokenInfo;
        if (
          TOKENS[item.symbol] &&
          !list.find(
            (t: ITokenInfo) => t.mintAddress === TOKENS[item.symbol].mintAddress
          )
        ) {
          token = TOKENS[item.symbol];
          token["logoURI"] = item.logoURI;
          list.push(token);
        }
      });
      setList(() => list);
      props.getTokenInfo(
        list.find((item: ITokenInfo) => item.symbol === "SOL")
      );
    });
  }, []);

  useEffect(() => {
    setSearchList(() => initialList);
  }, [initialList]);

  const setTokenInfo = (item: ITokenInfo) => {
    props.getTokenInfo(item);
    props.toggleTokenList();
  };

  useEffect(() => {
    if (!props.showTokenList) {
      setSearchList(initialList);
      searchRef.current.value = "";
    }
  }, [props.showTokenList]);

  const listItems = (data: ITokenInfo[]) => {
    return data.map((item: ITokenInfo) => {
      return (
        <div
          className={style.tokenRow}
          key={item.mintAddress}
          onClick={() => setTokenInfo(item)}
        >
          <img src={item.logoURI} alt="" className={style.tokenLogo} />
          <div>{item.symbol}</div>
        </div>
      );
    });
  };

  const searchToken = (e: any) => {
    let key = e.target.value.toUpperCase();
    let newList: ITokenInfo[] = [];
    initialList.map((item: ITokenInfo) => {
      if (item.symbol.includes(key)) {
        newList.push(item);
      }
    });
    setSearchList(() => newList);
  };

  let tokeListComponentStyle;
  if (!props.showTokenList) {
    tokeListComponentStyle = {
      display: "none"
    };
  } else {
    tokeListComponentStyle = {
      display: "block"
    };
  }

  return (
    <div className={style.tokeListComponent} style={tokeListComponentStyle}>
      <div className={style.tokeListContainer}>
        <div className={style.header}>
          <div>Select a token</div>
          <div className={style.closeIcon} onClick={props.toggleTokenList}>
            <CloseIcon w={5} h={5} />
          </div>
        </div>
        <div className={style.inputBlock}>
          <input
            type="text"
            placeholder="Search name or mint address"
            ref={searchRef}
            className={style.searchTokenInput}
            onChange={searchToken}
          />
          <div className={style.tokenListTitleRow}>
            <div>Token name</div>
          </div>
        </div>
        <div className={style.list}>{listItems(searchedList)}</div>
        <div className={style.tokenListSetting}>View Token List</div>
      </div>
    </div>
  );
};

export default TokenList;
```

更新 `views/raydium/SlippageSetting.tsx` 檔。

```TS
import { useState, useEffect, FunctionComponent } from "react";
import { CloseIcon } from "@chakra-ui/icons";
import style from "../../styles/swap.module.sass";

interface SlippageSettingProps {
  showSlippageSetting: boolean;
  toggleSlippageSetting: Function;
  getSlippageValue: Function;
  slippageValue: number;
}

const SlippageSetting: FunctionComponent<SlippageSettingProps> = props => {
  const rate = [0.1, 0.5, 1];
  const [warningText, setWarningText] = useState("");

  const setSlippageBtn = (item: number) => {
    props.getSlippageValue(item);
  };

  useEffect(() => {
    Options();

    if (props.slippageValue < 0) {
      setWarningText("Please enter a valid slippage percentage");
    } else if (props.slippageValue < 1) {
      setWarningText("Your transaction may fail");
    } else {
      setWarningText("");
    }
  }, [props.slippageValue]);

  const Options = (): JSX.Element => {
    return (
      <>
        {rate.map(item => {
          return (
            <button
              className={`${style.optionBtn} ${
                item === props.slippageValue
                  ? style.selectedSlippageRateBtn
                  : ""
              }`}
              key={item}
              onClick={() => setSlippageBtn(item)}
            >
              {item}%
            </button>
          );
        })}
      </>
    );
  };

  const updateInputRate = (e: React.FormEvent<HTMLInputElement>) => {
    props.getSlippageValue(e.currentTarget.value);
  };

  const close = () => {
    if (props.slippageValue < 0) {
      return;
    }
    props.toggleSlippageSetting();
  };

  if (!props.showSlippageSetting) {
    return null;
  }

  return (
    <div className={style.slippageSettingComponent}>
      <div className={style.slippageSettingContainer}>
        <div className={style.header}>
          <div>Setting</div>
          <div className={style.closeIcon} onClick={close}>
            <CloseIcon w={5} h={5} />
          </div>
        </div>
        <div className={style.settingSelectBlock}>
          <div className={style.title}>Slippage tolerance</div>
          <div className={style.optionsBlock}>
            <Options />
            <button className={`${style.optionBtn} ${style.inputBtn}`}>
              <input
                type="number"
                placeholder="0%"
                className={style.input}
                value={props.slippageValue}
                onChange={updateInputRate}
              />
              %
            </button>
          </div>
          <div className={style.warning}>{warningText}</div>
        </div>
      </div>
    </div>
  );
};

export default SlippageSetting;
```

更新 `views/raydium/TokenSelect.tsx` 檔。

```TS
import { FunctionComponent, useEffect, useState } from "react";
import { ArrowDownIcon } from "@chakra-ui/icons";
import { useWallet } from "@solana/wallet-adapter-react";
import { TokenData } from "./index";
import { ISplToken } from "../../utils/web3";
import style from "../../styles/swap.module.sass";

interface TokenSelectProps {
  type: string;
  toggleTokenList: Function;
  tokenData: TokenData;
  updateAmount: Function;
  wallet: Object;
  splTokenData: ISplToken[];
}

export interface IUpdateAmountData {
  type: string;
  amount: number;
}

interface SelectTokenProps {
  propsData: {
    tokenData: TokenData;
  };
}

const TokenSelect: FunctionComponent<TokenSelectProps> = props => {
  let wallet = useWallet();
  const [tokenBalance, setTokenBalance] = useState<number | null>(null);

  const updateAmount = (e: any) => {
    e.preventDefault();

    const amountData: IUpdateAmountData = {
      amount: e.target.value,
      type: props.type
    };
    props.updateAmount(amountData);
  };

  const selectToken = () => {
    props.toggleTokenList(props.type);
  };

  useEffect(() => {
    const getTokenBalance = () => {
      let data: ISplToken | undefined = props.splTokenData.find(
        (t: ISplToken) =>
          t.parsedInfo.mint === props.tokenData.tokenInfo?.mintAddress
      );

      if (data) {
        //@ts-ignore
        setTokenBalance(data.amount);
      }
    };
    getTokenBalance();
  }, [props.splTokenData]);

  const SelectTokenBtn: FunctionComponent<
    SelectTokenProps
  > = selectTokenProps => {
    if (selectTokenProps.propsData.tokenData.tokenInfo?.symbol) {
      return (
        <>
          <img
            src={selectTokenProps.propsData.tokenData.tokenInfo?.logoURI}
            alt="logo"
            className={style.img}
          />
          <div className={style.coinNameBlock}>
            <span className={style.coinName}>
              {selectTokenProps.propsData.tokenData.tokenInfo?.symbol}
            </span>
            <ArrowDownIcon w={5} h={5} />
          </div>
        </>
      );
    }
    return (
      <>
        <span>Select a token</span>
        <ArrowDownIcon w={5} h={5} />
      </>
    );
  };

  return (
    <div className={style.coinSelect}>
      <div className={style.noteText}>
        <div>
          {props.type === "To" ? `${props.type} (Estimate)` : props.type}
        </div>
        <div>
          {wallet.connected && tokenBalance
            ? `Balance: ${tokenBalance.toFixed(4)}`
            : ""}
        </div>
      </div>
      <div className={style.coinAmountRow}>
        {props.type !== "From" ? (
          <div className={style.input}>
            {props.tokenData.amount ? props.tokenData.amount : "-"}
          </div>
        ) : (
          <input
            type="number"
            className={style.input}
            placeholder="0.00"
            onChange={updateAmount}
            disabled={props.type !== "From"}
          />
        )}

        <div className={style.selectTokenBtn} onClick={selectToken}>
          <SelectTokenBtn propsData={props} />
        </div>
      </div>
    </div>
  );
};

export default TokenSelect;
```

更新 `views/raydium/SwapOperateContainer.tsx` 檔。

```TS
import { FunctionComponent } from "react";
import { ArrowUpDownIcon, QuestionOutlineIcon } from "@chakra-ui/icons";
import { Tooltip } from "@chakra-ui/react";
import { useWallet } from "@solana/wallet-adapter-react";
import {
  WalletModalProvider,
  WalletMultiButton
} from "@solana/wallet-adapter-react-ui";
import { TokenData } from ".";
import TokenSelect from "./TokenSelect";
import { ISplToken } from "../../utils/web3";
import style from "../../styles/swap.module.sass";

interface SwapOperateContainerProps {
  toggleTokenList: Function;
  fromData: TokenData;
  toData: TokenData;
  updateAmount: Function;
  switchFromAndTo: (event?: React.MouseEvent<HTMLDivElement>) => void;
  slippageValue: number;
  sendSwapTransaction: (event?: React.MouseEvent<HTMLButtonElement>) => void;
  splTokenData: ISplToken[];
}

interface SwapDetailProps {
  title: string;
  tooltipContent: string;
  value: string;
}

const SwapOperateContainer: FunctionComponent<
  SwapOperateContainerProps
> = props => {
  let wallet = useWallet();
  const SwapBtn = (swapProps: any) => {
    if (wallet.connected) {
      if (
        !swapProps.props.fromData.tokenInfo?.symbol ||
        !swapProps.props.toData.tokenInfo?.symbol
      ) {
        return (
          <button
            className={`${style.operateBtn} ${style.disabledBtn}`}
            disabled
          >
            Select a token
          </button>
        );
      }
      if (
        swapProps.props.fromData.tokenInfo?.symbol &&
        swapProps.props.toData.tokenInfo?.symbol
      ) {
        if (
          !swapProps.props.fromData.amount ||
          !swapProps.props.toData.amount
        ) {
          return (
            <button
              className={`${style.operateBtn} ${style.disabledBtn}`}
              disabled
            >
              Enter an amount
            </button>
          );
        }
      }

      return (
        <button
          className={style.operateBtn}
          onClick={props.sendSwapTransaction}
        >
          Swap
        </button>
      );
    } else {
      return (
        <div className={style.selectWallet}>
          <WalletModalProvider>
            <WalletMultiButton />
          </WalletModalProvider>
        </div>
      );
    }
  };

  const SwapDetailPreview: FunctionComponent<SwapDetailProps> = props => {
    return (
      <div className={style.slippageRow}>
        <div className={style.slippageTooltipBlock}>
          <div>{props.title}</div>
          <Tooltip
            hasArrow
            label={props.tooltipContent}
            color="white"
            bg="brand.100"
            padding="3"
          >
            <QuestionOutlineIcon
              w={5}
              h={5}
              className={`${style.icon} ${style.icon}`}
            />
          </Tooltip>
        </div>
        <div>{props.value}</div>
      </div>
    );
  };

  const SwapDetailPreviewList = (): JSX.Element => {
    return (
      <>
        <SwapDetailPreview
          title="Swapping Through"
          tooltipContent="This venue gave the best price for your trade"
          value={`${props.fromData.tokenInfo.symbol} > ${props.toData.tokenInfo.symbol}`}
        />
      </>
    );
  };

  return (
    <div className={style.swapCard}>
      <div className={style.cardBody}>
        <TokenSelect
          type="From"
          toggleTokenList={props.toggleTokenList}
          tokenData={props.fromData}
          updateAmount={props.updateAmount}
          wallet={wallet}
          splTokenData={props.splTokenData}
        />
        <div
          className={`${style.switchIcon} ${style.icon}`}
          onClick={props.switchFromAndTo}
        >
          <ArrowUpDownIcon w={5} h={5} />
        </div>
        <TokenSelect
          type="To"
          toggleTokenList={props.toggleTokenList}
          tokenData={props.toData}
          updateAmount={props.updateAmount}
          wallet={wallet}
          splTokenData={props.splTokenData}
        />
        <div className={style.slippageRow}>
          <div className={style.slippageTooltipBlock}>
            <div>Slippage Tolerance </div>
            <Tooltip
              hasArrow
              label="The maximum difference between your estimated price and execution price."
              color="white"
              bg="brand.100"
              padding="3"
            >
              <QuestionOutlineIcon
                w={5}
                h={5}
                className={`${style.icon} ${style.icon}`}
              />
            </Tooltip>
          </div>
          <div>{props.slippageValue}%</div>
        </div>
        {props.fromData.amount! > 0 &&
        props.fromData.tokenInfo.symbol &&
        props.toData.amount! > 0 &&
        props.toData.tokenInfo.symbol ? (
          <SwapDetailPreviewList />
        ) : (
          ""
        )}
        <SwapBtn props={props} />
      </div>
    </div>
  );
};

export default SwapOperateContainer;
```

更新 `views/raydium/index.tsx` 檔。


```TS
import { useState, useEffect, FunctionComponent } from "react";
import TokenList from "./TokenList";
import TitleRow from "./TitleRow";
import SlippageSetting from "./SlippageSetting";
import SwapOperateContainer from "./SwapOperateContainer";
import { Connection } from "@solana/web3.js";
import { Spinner } from "@chakra-ui/react";
import { useWallet, WalletContextState } from "@solana/wallet-adapter-react";
import { getPoolByTokenMintAddresses } from "../../utils/pools";
import { swap, getSwapOutAmount, setupPools } from "../../utils/swap";
import { getSPLTokenData } from "../../utils/web3";
import Notify from "../commons/Notify";
import { INotify } from "../commons/Notify";
import SplTokenList from "../commons/SplTokenList";
import { ISplToken } from "../../utils/web3";
import { IUpdateAmountData } from "./TokenSelect";
import style from "../../styles/swap.module.sass";

export interface ITokenInfo {
  symbol: string;
  mintAddress: string;
  logoURI: string;
}
export interface TokenData {
  amount: number | null;
  tokenInfo: ITokenInfo;
}

const SwapPage: FunctionComponent = () => {
  const [showTokenList, setShowTokenList] = useState(false);
  const [showSlippageSetting, setShowSlippageSetting] = useState(false);
  const [selectType, setSelectType] = useState<string>("From");
  const [fromData, setFromData] = useState<TokenData>({} as TokenData);
  const [toData, setToData] = useState<TokenData>({} as TokenData);
  const [slippageValue, setSlippageValue] = useState(1);
  const [splTokenData, setSplTokenData] = useState<ISplToken[]>([]);
  const [liquidityPools, setLiquidityPools] = useState<any>("");
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [notify, setNotify] = useState<INotify>({
    status: "info",
    title: "",
    description: "",
    link: ""
  });
  const [showNotify, toggleNotify] = useState<Boolean>(false);

  let wallet: WalletContextState = useWallet();
  const connection = new Connection("https://rpc-mainnet-fork.dappio.xyz", {
    wsEndpoint: "wss://rpc-mainnet-fork.dappio.xyz/ws",
    commitment: "processed"
  });

  useEffect(() => {
    setIsLoading(true);
    setupPools(connection).then(data => {
      setLiquidityPools(data);
      setIsLoading(false);
    });
    return () => {
      setLiquidityPools("");
    };
  }, []);

  useEffect(() => {
    if (wallet.connected) {
      getSPLTokenData(wallet, connection).then((tokenList: ISplToken[]) => {
        if (tokenList) {
          setSplTokenData(() => tokenList.filter(t => t !== undefined));
        }
      });
    }
  }, [wallet.connected]);

  const updateAmount = (e: IUpdateAmountData) => {
    if (e.type === "From") {
      setFromData((old: TokenData) => ({
        ...old,
        amount: e.amount
      }));

      if (!e.amount) {
        setToData((old: TokenData) => ({
          ...old,
          amount: 0
        }));
      }
    }
  };

  const updateSwapOutAmount = () => {
    if (
      fromData.amount! > 0 &&
      fromData.tokenInfo?.symbol &&
      toData.tokenInfo?.symbol
    ) {
      let poolInfo = getPoolByTokenMintAddresses(
        fromData.tokenInfo.mintAddress,
        toData.tokenInfo.mintAddress
      );
      if (!poolInfo) {
        setNotify((old: INotify) => ({
          ...old,
          status: "error",
          title: "AMM error",
          description: "Current token pair pool not found"
        }));
        toggleNotify(true);
        return;
      }

      let parsedPoolsData = liquidityPools;
      let parsedPoolInfo = parsedPoolsData[poolInfo?.lp.mintAddress];

      // //@ts-ignore
      const { amountOutWithSlippage } = getSwapOutAmount(
        parsedPoolInfo,
        fromData.tokenInfo.mintAddress,
        toData.tokenInfo.mintAddress,
        fromData.amount!.toString(),
        slippageValue
      );

      setToData((old: TokenData) => ({
        ...old,
        amount: parseFloat(amountOutWithSlippage.fixed())
      }));
    }
  };

  useEffect(() => {
    updateSwapOutAmount();
  }, [fromData]);

  useEffect(() => {
    updateSwapOutAmount();
  }, [toData.tokenInfo?.symbol]);

  useEffect(() => {
    updateSwapOutAmount();
  }, [slippageValue]);

  const toggleTokenList = (e: any) => {
    setShowTokenList(() => !showTokenList);
    setSelectType(() => e);
  };

  const toggleSlippageSetting = () => {
    setShowSlippageSetting(() => !showSlippageSetting);
  };

  const getSlippageValue = (e: number) => {
    if (!e) {
      setSlippageValue(() => e);
    } else {
      setSlippageValue(() => e);
    }
  };

  const switchFromAndTo = () => {
    const fromToken = fromData.tokenInfo;
    const toToken = toData.tokenInfo;
    setFromData((old: TokenData) => ({
      ...old,
      tokenInfo: toToken,
      amount: null
    }));

    setToData((old: TokenData) => ({
      ...old,
      tokenInfo: fromToken,
      amount: null
    }));
  };

  const getTokenInfo = (e: any) => {
    if (selectType === "From") {
      if (toData.tokenInfo?.symbol === e?.symbol) {
        setToData((old: TokenData) => ({
          ...old,
          tokenInfo: {
            symbol: "",
            mintAddress: "",
            logoURI: ""
          }
        }));
      }

      setFromData((old: TokenData) => ({
        ...old,
        tokenInfo: e
      }));
    } else {
      if (fromData.tokenInfo?.symbol === e.symbol) {
        setFromData((old: TokenData) => ({
          ...old,
          tokenInfo: {
            symbol: "",
            mintAddress: "",
            logoURI: ""
          }
        }));
      }

      setToData((old: TokenData) => ({
        ...old,
        tokenInfo: e
      }));
    }
  };

  const sendSwapTransaction = async () => {
    let poolInfo = getPoolByTokenMintAddresses(
      fromData.tokenInfo.mintAddress,
      toData.tokenInfo.mintAddress
    );

    let fromTokenAccount: ISplToken | undefined | string = splTokenData.find(
      (token: ISplToken) =>
        token.parsedInfo.mint === fromData.tokenInfo.mintAddress
    );
    if (fromTokenAccount) {
      fromTokenAccount = fromTokenAccount.pubkey;
    } else {
      fromTokenAccount = "";
    }

    let toTokenAccount: ISplToken | undefined | string = splTokenData.find(
      (token: ISplToken) =>
        token.parsedInfo.mint === toData.tokenInfo.mintAddress
    );
    if (toTokenAccount) {
      toTokenAccount = toTokenAccount.pubkey;
    } else {
      toTokenAccount = "";
    }

    let wsol: ISplToken | undefined = splTokenData.find(
      (token: ISplToken) =>
        token.parsedInfo.mint === "So11111111111111111111111111111111111111112"
    );
    let wsolMint: string = "";
    if (wsol) {
      wsolMint = wsol.parsedInfo.mint;
    }

    if (poolInfo === undefined) {
      alert("Pool not exist");
      return;
    }

    swap(
      connection,
      wallet,
      poolInfo,
      fromData.tokenInfo.mintAddress,
      toData.tokenInfo.mintAddress,
      fromTokenAccount,
      toTokenAccount,
      fromData.amount!.toString(),
      toData.amount!.toString(),
      wsolMint
    ).then(async res => {
      toggleNotify(true);
      setNotify((old: INotify) => ({
        ...old,
        status: "success",
        title: "Transaction Send",
        description: "",
        link: `https://explorer.solana.com/address/${res}`
      }));

      let result = await connection.confirmTransaction(res);

      if (!result.value.err) {
        setNotify((old: INotify) => ({
          ...old,
          status: "success",
          title: "Transaction Success"
        }));
      } else {
        setNotify((old: INotify) => ({
          ...old,
          status: "success",
          title: "Fail",
          description: "Transaction fail, please check below link",
          link: `https://explorer.solana.com/address/${res}`
        }));
      }

      getSPLTokenData(wallet, connection).then((tokenList: ISplToken[]) => {
        if (tokenList) {
          setSplTokenData(() =>
            tokenList.filter((t: ISplToken) => t !== undefined)
          );
        }
      });
    });
  };

  useEffect(() => {
    const time = setTimeout(() => {
      toggleNotify(false);
    }, 8000);

    return () => clearTimeout(time);
  }, [notify]);

  useEffect(() => {
    if (wallet.connected) {
      setNotify((old: INotify) => ({
        ...old,
        status: "success",
        title: "Wallet connected",
        description: wallet.publicKey?.toBase58() as string
      }));
    } else {
      let description = wallet.publicKey?.toBase58();
      if (!description) {
        description = "Please try again";
      }
      setNotify((old: INotify) => ({
        ...old,
        status: "error",
        title: "Wallet disconnected",
        description: description as string
      }));
    }

    toggleNotify(true);
  }, [wallet.connected]);

  return (
    <div className={style.swapPage}>
      {isLoading ? (
        <div className={style.loading}>
          Loading raydium amm pool <Spinner />
        </div>
      ) : (
        ""
      )}
      <SplTokenList splTokenData={splTokenData} />
      <SlippageSetting
        showSlippageSetting={showSlippageSetting}
        toggleSlippageSetting={toggleSlippageSetting}
        getSlippageValue={getSlippageValue}
        slippageValue={slippageValue}
      />
      <TokenList
        showTokenList={showTokenList}
        toggleTokenList={toggleTokenList}
        getTokenInfo={getTokenInfo}
      />
      <div className={style.container}>
        {isLoading ? (
          ""
        ) : (
          <>
            <TitleRow
              toggleSlippageSetting={toggleSlippageSetting}
              fromData={fromData}
              toData={toData}
              updateSwapOutAmount={updateSwapOutAmount}
            />
            <SwapOperateContainer
              toggleTokenList={toggleTokenList}
              fromData={fromData}
              toData={toData}
              updateAmount={updateAmount}
              switchFromAndTo={switchFromAndTo}
              slippageValue={slippageValue}
              sendSwapTransaction={sendSwapTransaction}
              splTokenData={splTokenData}
            />
          </>
        )}
      </div>
      {showNotify ? <Notify message={notify} /> : null}
    </div>
  );
};

export default SwapPage;
```

更新 `pages/raydium.tsx` 檔。

```JS
import { FunctionComponent } from "react";
import Swap from "../views/raydium/index";
import { ChakraProvider } from "@chakra-ui/react";
import theme from "../chakra/style";

const RaydiumPage: FunctionComponent = () => {
  return (
    <div>
      <ChakraProvider theme={theme}>
        <Swap />
      </ChakraProvider>
    </div>
  );
};

export default RaydiumPage;
```

### 更新樣式

更新 `styles/swap.module.sass` 檔。

```CSS
@import './color.module'

.swapPage
  position: relative
  height: calc( 100vh - 7rem )
  color: $white
  background-color: $main_blue
.container
  position: absolute
  top: 5rem
  left: 50%
  transform: translateX(-50%)
.titleContainer
  display: flex
  align-items: center
  justify-content: center
  margin-bottom: 1rem
  .title
    flex: 1
    font-weight: 600
    font-size: 2.4rem
  .iconContainer
    display: flex
    flex: 2
    justify-content: flex-end
  .icon
    cursor: pointer
    padding: .5rem
    border-radius: .5rem
    margin-left: 1rem
    &:hover
      background-color: $coin_select_block_bgc
  .percentageCircle
    width: 3rem
    height: 3rem
  .circleBg
    stroke: $white
    fill: none
    stroke-width: 4
  .popover
    box-shadow: none !important
    outline: none !important
  .selectTokenAddressTitle
    font-size: 1.2rem
    font-weight: 600
    color: $placeholder_grey
    margin: .5rem 0 1rem 0
  .selectTokenAddress
    opacity: .7
    display: flex
    align-items: center
    margin-top: .5rem
    .symbol
      width: 5rem
      flex-shrink: 0
    .address
      background-color: $swap_card_bgc
      padding: .5rem
      border-radius: .5rem
      font-weight: 600
.swapCard
  margin: auto
  width: 36rem
  background: linear-gradient(245.22deg,#da2eef 7.97%,#2b6aff 49.17%,#39d0d8 92.1%)
  display: flex
  align-items: center
  justify-content: center
  border-radius: .5rem
  padding: .1rem
.cardBody
  background-color: $swap_card_bgc
  border-radius: .5rem
  width: 100%
  height: 100%
  opacity: .9
  padding: 3.2rem 1.8rem 3.2rem 1.8rem
  display: flex
  flex-direction: column
  align-items: center
  .switchIcon
    margin: 1rem 0
    width: 3.2rem
    height: 3.2rem
    background-color: #000829
    border-radius: 50%
    display: flex
    align-items: center
    justify-content: center
  .icon
    cursor: pointer
  .lowSOLWarning
    font-size: 1.4rem
    color: $white
    display: flex
    align-items: center
    justify-content: center
    font-weight: 600
    padding-top: 1.5rem
    .txt
      margin-right: 1rem
.coinSelect
  color: $white
  background-color: $coin_select_block_bgc
  border-radius: .4rem
  box-sizing: border-box
  padding: 1rem
  width: 100%
  .noteText
    font-size: 1.2rem
    color: #85858d
    display: flex
    justify-content: space-between
  .coinAmountRow
    display: flex
    align-items: center
    justify-content: space-between
    margin: 2rem 0 1rem 0
    .input
      background-color: transparent
      flex: 6
      border: none
      font-weight: 600
      font-size: 1.6rem
      color: $placeholder_grey
      white-space: nowrap
      overflow: hidden
      text-overflow: ellipsis
      letter-spacing: .1rem
      outline: none
    .selectTokenBtn
      flex: 4
      display: flex
      align-items: center
      justify-content: center
      padding: .5rem
      border-radius: .5rem
      font-weight: 500
      height: 4rem
      &:hover
        background-color: $token_list_bgc
        cursor: pointer
    .img
      width: 2.4rem
      height: 2.4rem
      border-radius: 50%
      margin-right: 1rem
    .coinNameBlock
      border: none
      font-weight: 600
      font-size: 1.4rem
      border-radius: .4rem
      white-space: nowrap
      cursor: pointer
      font-family: Bakbak One
      letter-spacing: 1px
    .coinName
      margin-right: .5rem
.slippageRow
  color: $white
  display: flex
  align-items: center
  justify-content: space-between
  width: 100%
  padding: 1rem 1.2rem 0 1.2rem
  font-size: 1.2rem
  opacity: .75
  font-weight: 600
  .slippageTooltipBlock
    display: flex
    align-items: center
  .icon
    margin-left: 1rem

.operateBtn
  width: 100%
  height: 4rem
  border: solid .1rem $swap_btn_border_color
  color: $white
  background-color: transparent
  border-radius: .4rem
  margin-top: 2rem
  font-size: 1.6rem
  font-weight: 600
  &:hover
    transition: .5s
    color: $swap_btn_border_color
// .selectWallet
//   margin-top: 2.5rem
.disabledBtn
  border-color: $placeholder_grey
  opacity: .7
  cursor: unset
  &:hover
    color: $placeholder_grey

.tokeListComponent
  transition: .3s
  width: 100vw
  height: 100vh
  background-color: rgba(0,0,0,.5)
  color: $white
  position: fixed
  top: 0
  left: 0
  z-index: 99
  .tokeListContainer
    max-width: 45rem
    width: calc(100vw - 1.6rem)
    height: calc( 100vh - 14rem)
    overflow: hidden
    background-color: $token_list_bgc
    position: absolute
    top: 10rem
    left: 50%
    transform: translateX(-50%)
    border-radius: .5rem
  .header
    height: 6rem
    padding: 2.4rem
    display: flex
    align-items: center
    justify-content: space-between
    font-size: 1.6rem
    font-weight: 600
    letter-spacing: 1px
    border-bottom: solid .1rem $white
  .list
    height: calc(100% - 10rem)
    overflow: scroll
    padding: 0 1.5rem 2rem 1.5rem
  .tokenRow
    display: flex
    align-items: center
    padding: .8rem 1.2rem
    font-size: 1.2rem
    cursor: pointer
    &:hover
      background-color: $coin_select_block_bgc
      opacity: .7
  .tokenLogo
    width: 2rem
    height: 2rem
    border-radius: 50%
    overflow: hidden
    margin-right: 1.2rem
  .tokenListSetting
    border-top: solid .1rem $white
    height: 5.5rem
    flex-shrink: 0
    display: flex
    align-items: center
    justify-content: center
    font-size: 1.4rem
    letter-spacing: 1px
    position: absolute
    bottom: 0
    background-color: $token_list_bgc
    width: 100%
  .closeIcon
    cursor: pointer
  .inputBlock
    padding: 0.2rem 2.5rem 0 2.5rem
    .tokenListTitleRow
      font-size: 1.4rem
      font-weight: 600
      height: 5rem
      display: flex
      justify-content: space-between
      align-items: center
    .searchTokenInput
      // padding: 0.5rem
      border: solid .1rem $swap_btn_border_color
      outline: none
      width: 100%
      background-color: $token_list_bgc
      font-size: 1.8rem
      border-radius: .5rem
      margin-top: 2rem

.slippageSettingComponent
  width: 100vw
  height: 100vh
  background-color: rgba(0,0,0,.5)
  position: fixed
  z-index: 999
  top: 0
  left: 0
  .slippageSettingContainer
    width: 50rem
    height: 20rem
    background-color: $token_list_bgc
    top: 50%
    left: 50%
    transform: translate(-50%, -50%)
    position: fixed
    z-index: 9999999
    border-radius: .5rem
  .header
    padding: 0 2rem
    font-size: 1.6rem
    height: 5rem
    display: flex
    align-items: center
    justify-content: space-between
    border-bottom: solid .1rem $white
    font-weight: 500
  .closeIcon
    cursor: pointer
  .settingSelectBlock
    padding: 2.4rem
  .title
    font-weight: 700
    font-size: 1.6rem
    color: $placeholder_grey
  .optionsBlock
    display: flex
    align-items: center
    margin-top: 1rem
  .optionBtn
    display: flex
    align-items: center
    justify-content: center
    width: 100%
    background-color: $swap_card_bgc
    color: $placeholder_grey
    padding: 1rem 1.2rem
    border: 0
    border-radius: 4px
    font-size: 1.4rem
    font-weight: 600
    cursor: pointer
    flex: 1
    margin-right: 1.5rem
  .warning
    margin: 1rem
    color: $slippage_setting_warning_red
    font-size: 1.4rem
  .input
    width: 100%
    background-color: transparent
    outline: none
    text-align: center
  .optionBtn.selectedSlippageRateBtn
    background-color: $swap_btn_border_color
  .inputBtn
    border: solid .1rem $swap_btn_border_color
.splTokenContainer
  padding: 3rem 2rem 3rem 3rem
  margin-top: 5rem
  border-radius: 0 1rem 1rem 0
  height: 80%
  overflow: scroll
  background-color: $token_list_bgc
  display: inline-block
  .splTokenListTitle
    font-size: 2.2rem
    margin-bottom: 4rem
    font-weight: 600
  .splTokenItem
    margin-top: 1rem
    font-size: 1.5rem
.loading
  font-size: 2rem
  position: absolute
  left: 50%
  transform: translateX(-50%)
  margin-top: 3rem
```

更新 `chakra/style.js` 檔。

```JS
import {
  extendTheme
} from "@chakra-ui/react"

const theme = extendTheme({
  colors: {
    brand: {
      100: "#1c274f"
    },
  },
})

export default theme
```

更新 `next.config.js` 檔。

```JS
/** @type {import('next').NextConfig} */
const withPlugins = require("next-compose-plugins");

/** eslint-disable @typescript-eslint/no-var-requires */
const withTM = require("next-transpile-modules")([
  "@solana/wallet-adapter-base",
  // Uncomment wallets you want to use
  // "@solana/wallet-adapter-bitpie",
  // "@solana/wallet-adapter-coin98",
  // "@solana/wallet-adapter-ledger",
  // "@solana/wallet-adapter-mathwallet",
  "@solana/wallet-adapter-phantom",
  "@solana/wallet-adapter-react",
  "@solana/wallet-adapter-solflare",
  "@solana/wallet-adapter-sollet",
  // "@solana/wallet-adapter-solong",
  // "@solana/wallet-adapter-torus",
  "@solana/wallet-adapter-wallets",
  // "@project-serum/sol-wallet-adapter",
  // "@solana/wallet-adapter-ant-design",
]);

const plugins = [
  [
    withTM,
    {
      webpack5: true,
      reactStrictMode: true,
    },
  ],
];

const nextConfig = {
  swcMinify: false,
  webpack: (config, {
    isServer
  }) => {
    if (!isServer) {
      config.resolve.fallback.fs = false;
    }
    return config;
  },
};

module.exports = withPlugins(plugins, nextConfig);
```

## 程式碼

- [solana-swap](https://github.com/memochou1993/solana-swap)

## 參考資料

- [BUIDL a Swap UI on Solana](https://book.solmeet.dev/notes/buidl-swap-ui#introduction)
- [Solana 開發者的入門指南](https://youtu.be/Ot2lvBLja40)
- [swap-ui-example](https://github.com/DappioWonderland/swap-ui-example)
