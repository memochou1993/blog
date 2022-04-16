---
title: 使用 Rust 開發 Solana 鏈上程式（二）：履約保證
permalink: 使用-Rust-開發-Solana-鏈上程式（二）：履約保證
date: 2022-04-14 23:43:32
tags: ["區塊鏈", "Solana", "Rust", "Web3", "JavaScript", "Node", "Smart Contract", "DApp"]
categories: ["區塊鏈"]
---

## 前言

本文為「[Solana 開發者的入門指南](https://youtu.be/OIjsPrcPe8s)」影片的學習筆記。

## 建立專案

使用 `cargo` 指令，初始化一個 `solana-escrow` 專案。

```BASH
cargo new solana-escrow --lib
```

進到專案。

```BASH
cd solana-escrow
```

## 實作後端程式

更新 `Cargo.toml` 檔。

```TOML
[package]
name = "solana-escrow"
version = "0.1.0"
edition = "2018"
license = "WTFPL"
publish = false

[dependencies]
solana-program = "1.6.9"
thiserror = "1.0.24"
spl-token = {version = "3.1.1", features = ["no-entrypoint"]}
arrayref = "0.3.6"

[lib]
crate-type = ["cdylib", "lib"]
```

新增主要模組如下：

```BASH
touch src/entrypoint.rs \
touch src/error.rs \
touch src/instruction.rs \
touch src/processor.rs \
touch src/state.rs
```

更新 `lib.rs` 檔如下：

```RS
pub mod entrypoint;
pub mod error;
pub mod instruction;
pub mod processor;
pub mod state;
```

更新 `instruction.rs` 檔，新增 `InitEscrow` 到列舉中。

```RS
use std::convert::TryInto;
use solana_program::program_error::ProgramError;
use crate::error::EscrowError::InvalidInstruction;

pub enum EscrowInstruction {
    /// Starts the trade by creating and populating an escrow account and transferring ownership of the given temp token account to the PDA
    ///
    ///
    /// Accounts expected:
    ///
    /// 0. `[signer]` The account of the person initializing the escrow
    /// 1. `[writable]` Temporary token account that should be created prior to this instruction and owned by the initializer
    /// 2. `[]` The initializer's token account for the token they will receive should the trade go through
    /// 3. `[writable]` The escrow account, it will hold all necessary info about the trade.
    /// 4. `[]` The rent sysvar
    /// 5. `[]` The token program
    InitEscrow {
        /// The amount party A expects to receive of token Y
        amount: u64
    }
}

impl EscrowInstruction {
    /// Unpacks a byte buffer into a [EscrowInstruction](enum.EscrowInstruction.html).
    pub fn unpack(input: &[u8]) -> Result<Self, ProgramError> {
        let (tag, rest) = input.split_first().ok_or(InvalidInstruction)?;

        Ok(match tag {
            0 => Self::InitEscrow {
                amount: Self::unpack_amount(rest)?,
            },
            _ => return Err(InvalidInstruction.into()),
        })
    }

    fn unpack_amount(input: &[u8]) -> Result<u64, ProgramError> {
        let amount = input
            .get(..8)
            .and_then(|slice| slice.try_into().ok())
            .map(u64::from_le_bytes)
            .ok_or(InvalidInstruction)?;
        Ok(amount)
    }
}
```

更新 `error.rs` 檔。

```RS
use thiserror::Error;
use solana_program::program_error::ProgramError;

#[derive(Error, Debug, Copy, Clone)]
pub enum EscrowError {
    /// Invalid instruction
    #[error("Invalid Instruction")]
    InvalidInstruction,
    /// Not Rent Exempt
    #[error("Not Rent Exempt")]
    NotRentExempt,
}

impl From<EscrowError> for ProgramError {
    fn from(e: EscrowError) -> Self {
        ProgramError::Custom(e as u32)
    }
}
```

更新 `processor.rs` 檔，尚未實作完全：

```RS
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint::ProgramResult,
    program_error::ProgramError,
    msg,
    pubkey::Pubkey,
    program_pack::{Pack, IsInitialized},
    sysvar::{rent::Rent, Sysvar},
    program::invoke
};

use crate::{instruction::EscrowInstruction, error::EscrowError, state::Escrow};

pub struct Processor;
impl Processor {
    // entrypoint
    pub fn process(program_id: &Pubkey, accounts: &[AccountInfo], instruction_data: &[u8]) -> ProgramResult {
        let instruction = EscrowInstruction::unpack(instruction_data)?;

        match instruction {
            EscrowInstruction::InitEscrow { amount } => {
                msg!("Instruction: InitEscrow");
                Self::process_init_escrow(accounts, amount, program_id)
            }
        }
    }

    fn process_init_escrow(
        accounts: &[AccountInfo],
        amount: u64,
        program_id: &Pubkey,
    ) -> ProgramResult {
        let account_info_iter = &mut accounts.iter();
        let initializer = next_account_info(account_info_iter)?;

        if !initializer.is_signer {
            return Err(ProgramError::MissingRequiredSignature);
        }

        let temp_token_account = next_account_info(account_info_iter)?;

        let token_to_receive_account = next_account_info(account_info_iter)?;
        if *token_to_receive_account.owner != spl_token::id() {
            return Err(ProgramError::IncorrectProgramId);
        }
        
        let escrow_account = next_account_info(account_info_iter)?;
        let rent = &Rent::from_account_info(next_account_info(account_info_iter)?)?;

        if !rent.is_exempt(escrow_account.lamports(), escrow_account.data_len()) {
            return Err(EscrowError::NotRentExempt.into());
        }

        let mut escrow_info = Escrow::unpack_unchecked(&escrow_account.data.borrow())?;
        if escrow_info.is_initialized() {
            return Err(ProgramError::AccountAlreadyInitialized);
        }

        Ok(())
    }
}
```

更新 `state.rs` 檔。

```RS
use solana_program::{
    program_pack::{IsInitialized, Pack, Sealed},
    program_error::ProgramError,
    pubkey::Pubkey,
};

use arrayref::{array_mut_ref, array_ref, array_refs, mut_array_refs};

pub struct Escrow {
    pub is_initialized: bool,
    pub initializer_pubkey: Pubkey,
    pub temp_token_account_pubkey: Pubkey,
    pub initializer_token_to_receive_account_pubkey: Pubkey,
    pub expected_amount: u64,
}

impl Sealed for Escrow {}

impl IsInitialized for Escrow {
    fn is_initialized(&self) -> bool {
        self.is_initialized
    }
}

impl Pack for Escrow {
    const LEN: usize = 105;
    fn unpack_from_slice(src: &[u8]) -> Result<Self, ProgramError> {
        let src = array_ref![src, 0, Escrow::LEN];
        let (
            is_initialized,
            initializer_pubkey,
            temp_token_account_pubkey,
            initializer_token_to_receive_account_pubkey,
            expected_amount,
        ) = array_refs![src, 1, 32, 32, 32, 8];
        let is_initialized = match is_initialized {
            [0] => false,
            [1] => true,
            _ => return Err(ProgramError::InvalidAccountData),
        };

        Ok(Escrow {
            is_initialized,
            initializer_pubkey: Pubkey::new_from_array(*initializer_pubkey),
            temp_token_account_pubkey: Pubkey::new_from_array(*temp_token_account_pubkey),
            initializer_token_to_receive_account_pubkey: Pubkey::new_from_array(*initializer_token_to_receive_account_pubkey),
            expected_amount: u64::from_le_bytes(*expected_amount),
        })
    }

    fn pack_into_slice(&self, dst: &mut [u8]) {
        let dst = array_mut_ref![dst, 0, Escrow::LEN];
        let (
            is_initialized_dst,
            initializer_pubkey_dst,
            temp_token_account_pubkey_dst,
            initializer_token_to_receive_account_pubkey_dst,
            expected_amount_dst,
        ) = mut_array_refs![dst, 1, 32, 32, 32, 8];

        let Escrow {
            is_initialized,
            initializer_pubkey,
            temp_token_account_pubkey,
            initializer_token_to_receive_account_pubkey,
            expected_amount,
        } = self;

        is_initialized_dst[0] = *is_initialized as u8;
        initializer_pubkey_dst.copy_from_slice(initializer_pubkey.as_ref());
        temp_token_account_pubkey_dst.copy_from_slice(temp_token_account_pubkey.as_ref());
        initializer_token_to_receive_account_pubkey_dst.copy_from_slice(initializer_token_to_receive_account_pubkey.as_ref());
        *expected_amount_dst = expected_amount.to_le_bytes();
    }
}
```

更新 `processor.rs` 檔，完成實作：

```RS
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint::ProgramResult,
    program_error::ProgramError,
    msg,
    pubkey::Pubkey,
    program_pack::{Pack, IsInitialized},
    sysvar::{rent::Rent, Sysvar},
    program::invoke
};

use crate::{instruction::EscrowInstruction, error::EscrowError, state::Escrow};

pub struct Processor;
impl Processor {
    pub fn process(program_id: &Pubkey, accounts: &[AccountInfo], instruction_data: &[u8]) -> ProgramResult {
        let instruction = EscrowInstruction::unpack(instruction_data)?;

        match instruction {
            EscrowInstruction::InitEscrow { amount } => {
                msg!("Instruction: InitEscrow");
                Self::process_init_escrow(accounts, amount, program_id)
            }
        }
    }

    fn process_init_escrow(
        accounts: &[AccountInfo],
        amount: u64,
        program_id: &Pubkey,
    ) -> ProgramResult {
        let account_info_iter = &mut accounts.iter();
        let initializer = next_account_info(account_info_iter)?;

        if !initializer.is_signer {
            return Err(ProgramError::MissingRequiredSignature);
        }

        let temp_token_account = next_account_info(account_info_iter)?;

        let token_to_receive_account = next_account_info(account_info_iter)?;
        if *token_to_receive_account.owner != spl_token::id() {
            return Err(ProgramError::IncorrectProgramId);
        }
        
        let escrow_account = next_account_info(account_info_iter)?;
        let rent = &Rent::from_account_info(next_account_info(account_info_iter)?)?;

        if !rent.is_exempt(escrow_account.lamports(), escrow_account.data_len()) {
            return Err(EscrowError::NotRentExempt.into());
        }

        let mut escrow_info = Escrow::unpack_unchecked(&escrow_account.data.borrow())?;
        if escrow_info.is_initialized() {
            return Err(ProgramError::AccountAlreadyInitialized);
        }

        escrow_info.is_initialized = true;
        escrow_info.initializer_pubkey = *initializer.key;
        escrow_info.temp_token_account_pubkey = *temp_token_account.key;
        escrow_info.initializer_token_to_receive_account_pubkey = *token_to_receive_account.key;
        escrow_info.expected_amount = amount;

        Escrow::pack(escrow_info, &mut escrow_account.data.borrow_mut())?;

        let (pda, _bump_seed) = Pubkey::find_program_address(&[b"escrow"], program_id);

        let token_program = next_account_info(account_info_iter)?;
        let owner_change_ix = spl_token::instruction::set_authority(
            token_program.key,
            temp_token_account.key,
            Some(&pda),
            spl_token::instruction::AuthorityType::AccountOwner,
            initializer.key,
            &[&initializer.key],
        )?;

        msg!("Calling the token program to transfer token account ownership...");
        invoke(
            &owner_change_ix,
            &[
                temp_token_account.clone(),
                initializer.clone(),
                token_program.clone(),
            ],
        )?;

        Ok(())
    }
}
```

更新 `entrypoint.rs` 檔。

```RS
use solana_program::{
    account_info::AccountInfo, entrypoint, entrypoint::ProgramResult, pubkey::Pubkey
};

use crate::processor::Processor;

entrypoint!(process_instruction);
fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    Processor::process(program_id, accounts, instruction_data)
}
```

試著使用 `cargo` 指令進行編譯。

```BASH
cargo build-bpf
```

更新 `instruction.rs` 檔，新增 `Exchange` 到列舉中。

```RS
use crate::error::EscrowError::InvalidInstruction;
use solana_program::program_error::ProgramError;
use std::convert::TryInto;

pub enum EscrowInstruction {
    /// Starts the trade by creating and populating an escrow account and transferring ownership of the given temp token account to the PDA
    ///
    ///
    /// Accounts expected:
    ///
    /// 0. `[signer]` The account of the person initializing the escrow
    /// 1. `[writable]` Temporary token account that should be created prior to this instruction and owned by the initializer
    /// 2. `[]` The initializer's token account for the token they will receive should the trade go through
    /// 3. `[writable]` The escrow account, it will hold all necessary info about the trade.
    /// 4. `[]` The rent sysvar
    /// 5. `[]` The token program
    InitEscrow {
        /// The amount party A expects to receive of token Y
        amount: u64,
    },

    /// Accepts a trade
    ///
    ///
    /// Accounts expected:
    ///
    /// 0. `[signer]` The account of the person taking the trade
    /// 1. `[writable]` The taker's token account for the token they send
    /// 2. `[writable]` The taker's token account for the token they will receive should the trade go through
    /// 3. `[writable]` The PDA's temp token account to get tokens from and eventually close
    /// 4. `[writable]` The initializer's main account to send their rent fees to
    /// 5. `[writable]` The initializer's token account that will receive tokens
    /// 6. `[writable]` The escrow account holding the escrow info
    /// 7. `[]` The token program
    /// 8. `[]` The PDA account
    Exchange {
        /// the amount the taker expects to be paid in the other token, as a u64 because that's the max possible supply of a token
        amount: u64,
    },
}

impl EscrowInstruction {
    /// Unpacks a byte buffer into a [EscrowInstruction](enum.EscrowInstruction.html).
    pub fn unpack(input: &[u8]) -> Result<Self, ProgramError> {
        let (tag, rest) = input.split_first().ok_or(InvalidInstruction)?;

        Ok(match tag {
            0 => Self::InitEscrow {
                amount: Self::unpack_amount(rest)?,
            },
            1 => Self::Exchange {
                amount: Self::unpack_amount(rest)?,
            },
            _ => return Err(InvalidInstruction.into()),
        })
    }

    fn unpack_amount(input: &[u8]) -> Result<u64, ProgramError> {
        let amount = input
            .get(..8)
            .and_then(|slice| slice.try_into().ok())
            .map(u64::from_le_bytes)
            .ok_or(InvalidInstruction)?;
        Ok(amount)
    }
}
```

更新 `processor.rs` 檔。

```RS
use solana_program::{
    account_info::{next_account_info, AccountInfo},
    entrypoint::ProgramResult,
    msg,
    program::{invoke, invoke_signed},
    program_error::ProgramError,
    program_pack::{IsInitialized, Pack},
    pubkey::Pubkey,
    sysvar::{rent::Rent, Sysvar},
};

use spl_token::state::Account as TokenAccount;

use crate::{instruction::EscrowInstruction, error::EscrowError, state::Escrow};

pub struct Processor;
impl Processor {
    pub fn process(program_id: &Pubkey, accounts: &[AccountInfo], instruction_data: &[u8]) -> ProgramResult {
        let instruction = EscrowInstruction::unpack(instruction_data)?;

        match instruction {
            EscrowInstruction::InitEscrow { amount } => {
                msg!("Instruction: InitEscrow");
                Self::process_init_escrow(accounts, amount, program_id)
            }
            EscrowInstruction::Exchange { amount } => {
                msg!("Instruction: Exchange");
                Self::process_exchange(accounts, amount, program_id)
            }
        }
    }

    fn process_init_escrow(
        accounts: &[AccountInfo],
        amount: u64,
        program_id: &Pubkey,
    ) -> ProgramResult {
        let account_info_iter = &mut accounts.iter();
        let initializer = next_account_info(account_info_iter)?;

        if !initializer.is_signer {
            return Err(ProgramError::MissingRequiredSignature);
        }

        let temp_token_account = next_account_info(account_info_iter)?;

        let token_to_receive_account = next_account_info(account_info_iter)?;
        if *token_to_receive_account.owner != spl_token::id() {
            return Err(ProgramError::IncorrectProgramId);
        }
        
        let escrow_account = next_account_info(account_info_iter)?;
        let rent = &Rent::from_account_info(next_account_info(account_info_iter)?)?;

        if !rent.is_exempt(escrow_account.lamports(), escrow_account.data_len()) {
            return Err(EscrowError::NotRentExempt.into());
        }

        let mut escrow_info = Escrow::unpack_unchecked(&escrow_account.data.borrow())?;
        if escrow_info.is_initialized() {
            return Err(ProgramError::AccountAlreadyInitialized);
        }

        escrow_info.is_initialized = true;
        escrow_info.initializer_pubkey = *initializer.key;
        escrow_info.temp_token_account_pubkey = *temp_token_account.key;
        escrow_info.initializer_token_to_receive_account_pubkey = *token_to_receive_account.key;
        escrow_info.expected_amount = amount;

        Escrow::pack(escrow_info, &mut escrow_account.data.borrow_mut())?;

        let (pda, _bump_seed) = Pubkey::find_program_address(&[b"escrow"], program_id);

        let token_program = next_account_info(account_info_iter)?;
        let owner_change_ix = spl_token::instruction::set_authority(
            token_program.key,
            temp_token_account.key,
            Some(&pda),
            spl_token::instruction::AuthorityType::AccountOwner,
            initializer.key,
            &[&initializer.key],
        )?;

        msg!("Calling the token program to transfer token account ownership...");
        invoke(
            &owner_change_ix,
            &[
                temp_token_account.clone(),
                initializer.clone(),
                token_program.clone(),
            ],
        )?;

        Ok(())
    }
    
    fn process_exchange(
        accounts: &[AccountInfo],
        amount_expected_by_taker: u64,
        program_id: &Pubkey,
    ) -> ProgramResult {
        let account_info_iter = &mut accounts.iter();
        let taker = next_account_info(account_info_iter)?;

        if !taker.is_signer {
            return Err(ProgramError::MissingRequiredSignature);
        }

        let takers_sending_token_account = next_account_info(account_info_iter)?;

        let takers_token_to_receive_account = next_account_info(account_info_iter)?;

        let pdas_temp_token_account = next_account_info(account_info_iter)?;
        let pdas_temp_token_account_info =
            TokenAccount::unpack(&pdas_temp_token_account.data.borrow())?;
        let (pda, bump_seed) = Pubkey::find_program_address(&[b"escrow"], program_id);

        if amount_expected_by_taker != pdas_temp_token_account_info.amount {
            return Err(EscrowError::ExpectedAmountMismatch.into());
        }

        let initializers_main_account = next_account_info(account_info_iter)?;
        let initializers_token_to_receive_account = next_account_info(account_info_iter)?;
        let escrow_account = next_account_info(account_info_iter)?;

        let escrow_info = Escrow::unpack(&escrow_account.data.borrow())?;

        if escrow_info.temp_token_account_pubkey != *pdas_temp_token_account.key {
            return Err(ProgramError::InvalidAccountData);
        }

        if escrow_info.initializer_pubkey != *initializers_main_account.key {
            return Err(ProgramError::InvalidAccountData);
        }

        if escrow_info.initializer_token_to_receive_account_pubkey != *initializers_token_to_receive_account.key {
            return Err(ProgramError::InvalidAccountData);
        }

        let token_program = next_account_info(account_info_iter)?;

        let transfer_to_initializer_ix = spl_token::instruction::transfer(
            token_program.key,
            takers_sending_token_account.key,
            initializers_token_to_receive_account.key,
            taker.key,
            &[&taker.key],
            escrow_info.expected_amount,
        )?;
        msg!("Calling the token program to transfer tokens to the escrow's initializer...");
        invoke(
            &transfer_to_initializer_ix,
            &[
                takers_sending_token_account.clone(),
                initializers_token_to_receive_account.clone(),
                taker.clone(),
                token_program.clone(),
            ],
        )?;

        let pda_account = next_account_info(account_info_iter)?;

        let transfer_to_taker_ix = spl_token::instruction::transfer(
            token_program.key,
            pdas_temp_token_account.key,
            takers_token_to_receive_account.key,
            &pda,
            &[&pda],
            pdas_temp_token_account_info.amount,
        )?;
        msg!("Calling the token program to transfer tokens to the taker...");
        invoke_signed(
            &transfer_to_taker_ix,
            &[
                pdas_temp_token_account.clone(),
                takers_token_to_receive_account.clone(),
                pda_account.clone(),
                token_program.clone(),
            ],
            &[&[&b"escrow"[..], &[bump_seed]]],
        )?;

        let close_pdas_temp_acc_ix = spl_token::instruction::close_account(
            token_program.key,
            pdas_temp_token_account.key,
            initializers_main_account.key,
            &pda,
            &[&pda]
        )?;
        msg!("Calling the token program to close pda's temp account...");
        invoke_signed(
            &close_pdas_temp_acc_ix,
            &[
                pdas_temp_token_account.clone(),
                initializers_main_account.clone(),
                pda_account.clone(),
                token_program.clone(),
            ],
            &[&[&b"escrow"[..], &[bump_seed]]],
        )?;

        msg!("Closing the escrow account...");
        **initializers_main_account.lamports.borrow_mut() = initializers_main_account.lamports()
        .checked_add(escrow_account.lamports())
        .ok_or(EscrowError::AmountOverflow)?;
        **escrow_account.lamports.borrow_mut() = 0;
        *escrow_account.data.borrow_mut() = &mut [];

        Ok(())
    }
}
```

更新 `error.rs` 檔。

```RS
use solana_program::program_error::ProgramError;
use thiserror::Error;

#[derive(Error, Debug, Copy, Clone)]
pub enum EscrowError {
    /// Invalid instruction
    #[error("Invalid Instruction")]
    InvalidInstruction,
    /// Not Rent Exempt
    #[error("Not Rent Exempt")]
    NotRentExempt,
    /// Expected Amount Mismatch
    #[error("Expected Amount Mismatch")]
    ExpectedAmountMismatch,
    /// Amount Overflow
    #[error("Amount Overflow")]
    AmountOverflow,
}

impl From<EscrowError> for ProgramError {
    fn from(e: EscrowError) -> Self {
        ProgramError::Custom(e as u32)
    }
}
```

試著使用 `cargo` 指令進行編譯。

```BASH
cargo build-bpf
```

## 啟動節點

開啟一個新的終端視窗，使用 `solana-test-validator` 指令，啟動一個本地的 Solana 節點。

```BASH
solana-test-validator
```

更新 `.gitignore` 檔。

```ENV
/target
/Cargo.lock
/test-ledger
```

## 建立公私鑰

新增 `keys` 資料夾及相關檔案。

```BASH
mkdir keys &&
touch keys/id_pub.json \
touch keys/alice_pub.json \
touch keys/bob_pub.json \
touch keys/program_pub.json
```

使用 `solana-keygen` 指令為程式建立一組公私鑰。

```BASH
solana-keygen new -o keys/id.json
```

使用以下指令印出公鑰。

```BASH
solana address -k keys/id.json
```

將公鑰手動複製到 `id_pub.json` 檔：

```JSON
"9rRRFELbLfWuxSeCsDeqSd9Lv6Bhv7xhGoKyBkfMU74Z"
```

使用 `solana-keygen` 指令使用者 Alice 建立一組公私鑰。

```BASH
solana-keygen new -o keys/alice.json
```

使用以下指令印出公鑰。

```BASH
solana address -k keys/alice.json
```

將公鑰手動複製到 `alice_pub.json` 檔：

```JSON
"HTt2B7bWXfiTAY2z2TLvKPyRJMM7BTZ5yZcHAXf6Dmnk"
```

使用 `solana-keygen` 指令使用者 Bob 建立一組公私鑰。

```BASH
solana-keygen new -o keys/bob.json
```

使用以下指令印出公鑰。

```BASH
solana address -k keys/bob.json
```

將公鑰手動複製到 `bob_pub.json` 檔：

```JSON
"CYHvpgywtnbwzdSGYX29fPnMG46EijQbSXrit6wXqfR6"
```

## 實作前端程式

使用 `npm` 指令初始化專案。

```BASH
npm init -y
```

安裝依賴套件。

```BASH
npm install --save @solana/spl-token@0.1.8 @solana/web3.js @types/bn.js
```

安裝 TypeScript。

```BASH
npm install -g typescript
```

使用 `tsc` 指令初始化專案。

```BASH
tsc --init
```

更新 `.gitignore` 檔。

```ENV
/target
/Cargo.lock
/test-ledger
/node_modules
```

新增 `ts` 資料夾及相關檔案。

```BASH
mkdir ts &&
touch ts/setup.ts \
touch ts/utils.ts \
touch ts/alice.ts \
touch ts/bob.ts
```

修改 `utils.ts` 檔。

```TS
import {
  Connection,
  LAMPORTS_PER_SOL,
  PublicKey,
  Signer,
} from "@solana/web3.js";

import { Token, TOKEN_PROGRAM_ID } from "@solana/spl-token";
import {
  getKeypair,
  getPublicKey,
  getTokenBalance,
  writePublicKey,
} from "./utils";

const createMint = (
  connection: Connection,
  { publicKey, secretKey }: Signer
) => {
  return Token.createMint(
    connection,
    {
      publicKey,
      secretKey,
    },
    publicKey,
    null,
    0,
    TOKEN_PROGRAM_ID
  );
};

const setupMint = async (
  name: string,
  connection: Connection,
  alicePublicKey: PublicKey,
  bobPublicKey: PublicKey,
  clientKeypair: Signer
): Promise<[Token, PublicKey, PublicKey]> => {
  console.log(`Creating Mint ${name}...`);
  const mint = await createMint(connection, clientKeypair);
  writePublicKey(mint.publicKey, `mint_${name.toLowerCase()}`);

  console.log(`Creating Alice TokenAccount for ${name}...`);
  const aliceTokenAccount = await mint.createAccount(alicePublicKey);
  writePublicKey(aliceTokenAccount, `alice_${name.toLowerCase()}`);

  console.log(`Creating Bob TokenAccount for ${name}...`);
  const bobTokenAccount = await mint.createAccount(bobPublicKey);
  writePublicKey(bobTokenAccount, `bob_${name.toLowerCase()}`);

  return [mint, aliceTokenAccount, bobTokenAccount];
};

const setup = async () => {
  const alicePublicKey = getPublicKey("alice");
  const bobPublicKey = getPublicKey("bob");
  const clientKeypair = getKeypair("id");

  const connection = new Connection("http://localhost:8899", "confirmed");
  console.log("Requesting SOL for Alice...");
  // some networks like the local network provide an airdrop function (mainnet of course does not)
  await connection.requestAirdrop(alicePublicKey, LAMPORTS_PER_SOL * 10);
  console.log("Requesting SOL for Bob...");
  await connection.requestAirdrop(bobPublicKey, LAMPORTS_PER_SOL * 10);
  console.log("Requesting SOL for Client...");
  await connection.requestAirdrop(
    clientKeypair.publicKey,
    LAMPORTS_PER_SOL * 10
  );

  const [mintX, aliceTokenAccountForX, bobTokenAccountForX] = await setupMint(
    "X",
    connection,
    alicePublicKey,
    bobPublicKey,
    clientKeypair
  );
  console.log("Sending 50X to Alice's X TokenAccount...");
  await mintX.mintTo(aliceTokenAccountForX, clientKeypair.publicKey, [], 50);

  const [mintY, aliceTokenAccountForY, bobTokenAccountForY] = await setupMint(
    "Y",
    connection,
    alicePublicKey,
    bobPublicKey,
    clientKeypair
  );
  console.log("Sending 50Y to Bob's Y TokenAccount...");
  await mintY.mintTo(bobTokenAccountForY, clientKeypair.publicKey, [], 50);

  console.log("✨Setup complete✨\n");
  console.table([
    {
      "Alice Token Account X": await getTokenBalance(
        aliceTokenAccountForX,
        connection
      ),
      "Alice Token Account Y": await getTokenBalance(
        aliceTokenAccountForY,
        connection
      ),
      "Bob Token Account X": await getTokenBalance(
        bobTokenAccountForX,
        connection
      ),
      "Bob Token Account Y": await getTokenBalance(
        bobTokenAccountForY,
        connection
      ),
    },
  ]);
  console.log("");
};

setup();
```

修改 `setup.ts` 檔。

```TS
import { Connection, Keypair, PublicKey } from "@solana/web3.js";
//@ts-expect-error missing types
import * as BufferLayout from "buffer-layout";

import * as fs from "fs";

export const logError = (msg: string) => {
  console.log(`\x1b[31m${msg}\x1b[0m`);
};

export const writePublicKey = (publicKey: PublicKey, name: string) => {
  fs.writeFileSync(
    `./keys/${name}_pub.json`,
    JSON.stringify(publicKey.toString())
  );
};

export const getPublicKey = (name: string) =>
  new PublicKey(
    JSON.parse(fs.readFileSync(`./keys/${name}_pub.json`) as unknown as string)
  );

export const getPrivateKey = (name: string) =>
  Uint8Array.from(
    JSON.parse(fs.readFileSync(`./keys/${name}.json`) as unknown as string)
  );

export const getKeypair = (name: string) =>
  new Keypair({
    publicKey: getPublicKey(name).toBytes(),
    secretKey: getPrivateKey(name),
  });

export const getProgramId = () => {
  try {
    return getPublicKey("program");
  } catch (e) {
    logError("Given programId is missing or incorrect");
    process.exit(1);
  }
};

export const getTerms = (): {
  aliceExpectedAmount: number;
  bobExpectedAmount: number;
} => {
  return JSON.parse(fs.readFileSync(`./terms.json`) as unknown as string);
};

export const getTokenBalance = async (
  pubkey: PublicKey,
  connection: Connection
) => {
  return parseInt(
    (await connection.getTokenAccountBalance(pubkey)).value.amount
  );
};

/**
 * Layout for a public key
 */
const publicKey = (property = "publicKey") => {
  return BufferLayout.blob(32, property);
};

/**
 * Layout for a 64bit unsigned value
 */
const uint64 = (property = "uint64") => {
  return BufferLayout.blob(8, property);
};

export const ESCROW_ACCOUNT_DATA_LAYOUT = BufferLayout.struct([
  BufferLayout.u8("isInitialized"),
  publicKey("initializerPubkey"),
  publicKey("initializerTempTokenAccountPubkey"),
  publicKey("initializerReceivingTokenAccountPubkey"),
  uint64("expectedAmount"),
]);

export interface EscrowLayout {
  isInitialized: number;
  initializerPubkey: Uint8Array;
  initializerReceivingTokenAccountPubkey: Uint8Array;
  initializerTempTokenAccountPubkey: Uint8Array;
  expectedAmount: Uint8Array;
}
```

修改 `alice.ts` 檔。

```TS
import { AccountLayout, Token, TOKEN_PROGRAM_ID } from "@solana/spl-token";
import {
  Connection,
  Keypair,
  PublicKey,
  SystemProgram,
  SYSVAR_RENT_PUBKEY,
  Transaction,
  TransactionInstruction,
} from "@solana/web3.js";
import BN = require("bn.js");
import {
  EscrowLayout,
  ESCROW_ACCOUNT_DATA_LAYOUT,
  getKeypair,
  getProgramId,
  getPublicKey,
  getTerms,
  getTokenBalance,
  logError,
  writePublicKey,
} from "./utils";

const alice = async () => {
  const escrowProgramId = getProgramId();
  const terms = getTerms();

  const aliceXTokenAccountPubkey = getPublicKey("alice_x");
  const aliceYTokenAccountPubkey = getPublicKey("alice_y");
  const XTokenMintPubkey = getPublicKey("mint_x");
  const aliceKeypair = getKeypair("alice");

  const tempXTokenAccountKeypair = new Keypair();
  const connection = new Connection("http://localhost:8899", "confirmed");
  const createTempTokenAccountIx = SystemProgram.createAccount({
    programId: TOKEN_PROGRAM_ID,
    space: AccountLayout.span,
    lamports: await connection.getMinimumBalanceForRentExemption(
      AccountLayout.span
    ),
    fromPubkey: aliceKeypair.publicKey,
    newAccountPubkey: tempXTokenAccountKeypair.publicKey,
  });
  const initTempAccountIx = Token.createInitAccountInstruction(
    TOKEN_PROGRAM_ID,
    XTokenMintPubkey,
    tempXTokenAccountKeypair.publicKey,
    aliceKeypair.publicKey
  );
  const transferXTokensToTempAccIx = Token.createTransferInstruction(
    TOKEN_PROGRAM_ID,
    aliceXTokenAccountPubkey,
    tempXTokenAccountKeypair.publicKey,
    aliceKeypair.publicKey,
    [],
    terms.bobExpectedAmount
  );
  const escrowKeypair = new Keypair();
  const createEscrowAccountIx = SystemProgram.createAccount({
    space: ESCROW_ACCOUNT_DATA_LAYOUT.span,
    lamports: await connection.getMinimumBalanceForRentExemption(
      ESCROW_ACCOUNT_DATA_LAYOUT.span
    ),
    fromPubkey: aliceKeypair.publicKey,
    newAccountPubkey: escrowKeypair.publicKey,
    programId: escrowProgramId,
  });
  const initEscrowIx = new TransactionInstruction({
    programId: escrowProgramId,
    keys: [
      { pubkey: aliceKeypair.publicKey, isSigner: true, isWritable: false },
      {
        pubkey: tempXTokenAccountKeypair.publicKey,
        isSigner: false,
        isWritable: true,
      },
      {
        pubkey: aliceYTokenAccountPubkey,
        isSigner: false,
        isWritable: false,
      },
      { pubkey: escrowKeypair.publicKey, isSigner: false, isWritable: true },
      { pubkey: SYSVAR_RENT_PUBKEY, isSigner: false, isWritable: false },
      { pubkey: TOKEN_PROGRAM_ID, isSigner: false, isWritable: false },
    ],
    data: Buffer.from(
      Uint8Array.of(0, ...new BN(terms.aliceExpectedAmount).toArray("le", 8))
    ),
  });

  const tx = new Transaction().add(
    createTempTokenAccountIx,
    initTempAccountIx,
    transferXTokensToTempAccIx,
    createEscrowAccountIx,
    initEscrowIx
  );
  console.log("Sending Alice's transaction...");
  await connection.sendTransaction(
    tx,
    [aliceKeypair, tempXTokenAccountKeypair, escrowKeypair],
    { skipPreflight: false, preflightCommitment: "confirmed" }
  );

  // sleep to allow time to update
  await new Promise((resolve) => setTimeout(resolve, 1000));

  const escrowAccount = await connection.getAccountInfo(
    escrowKeypair.publicKey
  );

  if (escrowAccount === null || escrowAccount.data.length === 0) {
    logError("Escrow state account has not been initialized properly");
    process.exit(1);
  }

  const encodedEscrowState = escrowAccount.data;
  const decodedEscrowState = ESCROW_ACCOUNT_DATA_LAYOUT.decode(
    encodedEscrowState
  ) as EscrowLayout;

  if (!decodedEscrowState.isInitialized) {
    logError("Escrow state initialization flag has not been set");
    process.exit(1);
  } else if (
    !new PublicKey(decodedEscrowState.initializerPubkey).equals(
      aliceKeypair.publicKey
    )
  ) {
    logError(
      "InitializerPubkey has not been set correctly / not been set to Alice's public key"
    );
    process.exit(1);
  } else if (
    !new PublicKey(
      decodedEscrowState.initializerReceivingTokenAccountPubkey
    ).equals(aliceYTokenAccountPubkey)
  ) {
    logError(
      "initializerReceivingTokenAccountPubkey has not been set correctly / not been set to Alice's Y public key"
    );
    process.exit(1);
  } else if (
    !new PublicKey(decodedEscrowState.initializerTempTokenAccountPubkey).equals(
      tempXTokenAccountKeypair.publicKey
    )
  ) {
    logError(
      "initializerTempTokenAccountPubkey has not been set correctly / not been set to temp X token account public key"
    );
    process.exit(1);
  }
  console.log(
    `✨Escrow successfully initialized. Alice is offering ${terms.bobExpectedAmount}X for ${terms.aliceExpectedAmount}Y✨\n`
  );
  writePublicKey(escrowKeypair.publicKey, "escrow");
  console.table([
    {
      "Alice Token Account X": await getTokenBalance(
        aliceXTokenAccountPubkey,
        connection
      ),
      "Alice Token Account Y": await getTokenBalance(
        aliceYTokenAccountPubkey,
        connection
      ),
      "Bob Token Account X": await getTokenBalance(
        getPublicKey("bob_x"),
        connection
      ),
      "Bob Token Account Y": await getTokenBalance(
        getPublicKey("bob_y"),
        connection
      ),
      "Temporary Token Account X": await getTokenBalance(
        tempXTokenAccountKeypair.publicKey,
        connection
      ),
    },
  ]);

  console.log("");
};

alice();
```

修改 `bob.ts` 檔。

```TS
import { TOKEN_PROGRAM_ID } from "@solana/spl-token";
import {
  Connection,
  PublicKey,
  Transaction,
  TransactionInstruction,
} from "@solana/web3.js";
import BN = require("bn.js");
import {
  EscrowLayout,
  ESCROW_ACCOUNT_DATA_LAYOUT,
  getKeypair,
  getProgramId,
  getPublicKey,
  getTerms,
  getTokenBalance,
  logError,
} from "./utils";

const bob = async () => {
  const bobKeypair = getKeypair("bob");
  const bobXTokenAccountPubkey = getPublicKey("bob_x");
  const bobYTokenAccountPubkey = getPublicKey("bob_y");
  const escrowStateAccountPubkey = getPublicKey("escrow");
  const escrowProgramId = getProgramId();
  const terms = getTerms();

  const connection = new Connection("http://localhost:8899", "confirmed");
  const escrowAccount = await connection.getAccountInfo(
    escrowStateAccountPubkey
  );
  if (escrowAccount === null) {
    logError("Could not find escrow at given address!");
    process.exit(1);
  }

  const encodedEscrowState = escrowAccount.data;
  const decodedEscrowLayout = ESCROW_ACCOUNT_DATA_LAYOUT.decode(
    encodedEscrowState
  ) as EscrowLayout;
  const escrowState = {
    escrowAccountPubkey: escrowStateAccountPubkey,
    isInitialized: !!decodedEscrowLayout.isInitialized,
    initializerAccountPubkey: new PublicKey(
      decodedEscrowLayout.initializerPubkey
    ),
    XTokenTempAccountPubkey: new PublicKey(
      decodedEscrowLayout.initializerTempTokenAccountPubkey
    ),
    initializerYTokenAccount: new PublicKey(
      decodedEscrowLayout.initializerReceivingTokenAccountPubkey
    ),
    expectedAmount: new BN(decodedEscrowLayout.expectedAmount, 10, "le"),
  };

  const PDA = await PublicKey.findProgramAddress(
    [Buffer.from("escrow")],
    escrowProgramId
  );

  const exchangeInstruction = new TransactionInstruction({
    programId: escrowProgramId,
    data: Buffer.from(
      Uint8Array.of(1, ...new BN(terms.bobExpectedAmount).toArray("le", 8))
    ),
    keys: [
      { pubkey: bobKeypair.publicKey, isSigner: true, isWritable: false },
      { pubkey: bobYTokenAccountPubkey, isSigner: false, isWritable: true },
      { pubkey: bobXTokenAccountPubkey, isSigner: false, isWritable: true },
      {
        pubkey: escrowState.XTokenTempAccountPubkey,
        isSigner: false,
        isWritable: true,
      },
      {
        pubkey: escrowState.initializerAccountPubkey,
        isSigner: false,
        isWritable: true,
      },
      {
        pubkey: escrowState.initializerYTokenAccount,
        isSigner: false,
        isWritable: true,
      },
      { pubkey: escrowStateAccountPubkey, isSigner: false, isWritable: true },
      { pubkey: TOKEN_PROGRAM_ID, isSigner: false, isWritable: false },
      { pubkey: PDA[0], isSigner: false, isWritable: false },
    ],
  });

  const aliceYTokenAccountPubkey = getPublicKey("alice_y");
  const [aliceYbalance, bobXbalance] = await Promise.all([
    getTokenBalance(aliceYTokenAccountPubkey, connection),
    getTokenBalance(bobXTokenAccountPubkey, connection),
  ]);

  console.log("Sending Bob's transaction...");
  await connection.sendTransaction(
    new Transaction().add(exchangeInstruction),
    [bobKeypair],
    { skipPreflight: false, preflightCommitment: "confirmed" }
  );

  // sleep to allow time to update
  await new Promise((resolve) => setTimeout(resolve, 1000));

  if ((await connection.getAccountInfo(escrowStateAccountPubkey)) !== null) {
    logError("Escrow account has not been closed");
    process.exit(1);
  }

  if (
    (await connection.getAccountInfo(escrowState.XTokenTempAccountPubkey)) !==
    null
  ) {
    logError("Temporary X token account has not been closed");
    process.exit(1);
  }

  const newAliceYbalance = await getTokenBalance(
    aliceYTokenAccountPubkey,
    connection
  );

  if (newAliceYbalance !== aliceYbalance + terms.aliceExpectedAmount) {
    logError(
      `Alice's Y balance should be ${
        aliceYbalance + terms.aliceExpectedAmount
      } but is ${newAliceYbalance}`
    );
    process.exit(1);
  }

  const newBobXbalance = await getTokenBalance(
    bobXTokenAccountPubkey,
    connection
  );

  if (newBobXbalance !== bobXbalance + terms.bobExpectedAmount) {
    logError(
      `Bob's X balance should be ${
        bobXbalance + terms.bobExpectedAmount
      } but is ${newBobXbalance}`
    );
    process.exit(1);
  }

  console.log(
    "✨Trade successfully executed. All temporary accounts closed✨\n"
  );
  console.table([
    {
      "Alice Token Account X": await getTokenBalance(
        getPublicKey("alice_x"),
        connection
      ),
      "Alice Token Account Y": newAliceYbalance,
      "Bob Token Account X": newBobXbalance,
      "Bob Token Account Y": await getTokenBalance(
        bobYTokenAccountPubkey,
        connection
      ),
    },
  ]);
  console.log("");
};

bob();
```

## 設置參數

新增 `terms.json` 檔。

```BASH
touch terms.json
```

更新 `terms.json` 檔，設定使用者 Alice 與 Bob 各自期望的金額。

```JSON
{
  "aliceExpectedAmount": 3,
  "bobExpectedAmount": 5
}
```

## 充值

使用以下指令為程式充值，以程式的公鑰做為目標。

```BASH
solana transfer 9rRRFELbLfWuxSeCsDeqSd9Lv6Bhv7xhGoKyBkfMU74Z 100 --allow-unfunded-recipient
```

輸出結果如下：

```BASH
Signature: mhqm5AA5v8a5KABCR9Poj68Ranzms8ahq47zhdN3uQetYck68H42N1NNyxLpAQbU8pBWziPEN1nZqbY6GeP3Ldc
```

## 部署

部署 `solana_escrow` 鏈上程式。

```BASH
solana program deploy target/deploy/solana_escrow.so
```

輸出結果如下：

```BASH
Program Id: FWwUWeewacUBg3tU6mT8xSCbkeLhTLves6VGJtFXaatj
```

將 Program ID 更新到 `program_pub.json` 檔：

```JSON
"FWwUWeewacUBg3tU6mT8xSCbkeLhTLves6VGJtFXaatj"
```

## 執行腳本

使用 `ts-node` 指令執行 `setup.ts` 腳本。

```BASH
ts-node ts/setup.ts
```

輸出結果如下：

```BASH
Requesting SOL for Alice...
Requesting SOL for Bob...
Requesting SOL for Client...
Creating Mint X...
Creating Alice TokenAccount for X...
Creating Bob TokenAccount for X...
Sending 50X to Alice's X TokenAccount...
Creating Mint Y...
Creating Alice TokenAccount for Y...
Creating Bob TokenAccount for Y...
Sending 50Y to Bob's Y TokenAccount...
✨Setup complete✨

┌─────────┬───────────────────────┬───────────────────────┬─────────────────────┬─────────────────────┐
│ (index) │ Alice Token Account X │ Alice Token Account Y │ Bob Token Account X │ Bob Token Account Y │
├─────────┼───────────────────────┼───────────────────────┼─────────────────────┼─────────────────────┤
│    0    │          50           │           0           │          0          │         50          │
└─────────┴───────────────────────┴───────────────────────┴─────────────────────┴─────────────────────┘
```

使用 `ts-node` 指令執行 `alice.ts` 腳本。

```BASH
ts-node ts/alice.ts
```

輸出結果如下：

```BASH
Sending Alice's transaction...
✨Escrow successfully initialized. Alice is offering 5X for 3Y✨

┌─────────┬───────────────────────┬───────────────────────┬─────────────────────┬─────────────────────┬───────────────────────────┐
│ (index) │ Alice Token Account X │ Alice Token Account Y │ Bob Token Account X │ Bob Token Account Y │ Temporary Token Account X │
├─────────┼───────────────────────┼───────────────────────┼─────────────────────┼─────────────────────┼───────────────────────────┤
│    0    │          45           │           0           │          0          │         50          │             5             │
└─────────┴───────────────────────┴───────────────────────┴─────────────────────┴─────────────────────┴───────────────────────────┘
```

使用 `ts-node` 指令執行 `bob.ts` 腳本。

```BASH
ts-node ts/bob.ts
```

輸出結果如下：

```BASH
Sending Bob's transaction...
✨Trade successfully executed. All temporary accounts closed✨

┌─────────┬───────────────────────┬───────────────────────┬─────────────────────┬─────────────────────┐
│ (index) │ Alice Token Account X │ Alice Token Account Y │ Bob Token Account X │ Bob Token Account Y │
├─────────┼───────────────────────┼───────────────────────┼─────────────────────┼─────────────────────┤
│    0    │          45           │           3           │          5          │         47          │
└─────────┴───────────────────────┴───────────────────────┴─────────────────────┴─────────────────────┘
```

## 程式碼

- [solana-escrow](https://github.com/memochou1993/solana-escrow)

## 參考資料

- [A Starter Kit for New Solana Developer](https://hackmd.io/@ironaddicteddog/solana-starter-kit)
- [Solana 開發者的入門指南](https://youtu.be/OIjsPrcPe8s)
