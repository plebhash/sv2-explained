---
marp: true
theme: sv2-explained
---

![center](../img/sv2-logo.png)
# Stratum V2 Explained

## Episode 2: History of pooled mining protocols

<!-- _class: credit -->
by [`@plebhash`](https://plebhash.github.io)

---

## Acknowledgements

This series is based on [Gabriele Vernetti (GitGab19)](https://github.com/GitGab19)'s Master Thesis at *Politecnico Di Torino* titled:

[**Stratum V2: the next generation protocol for Bitcoin pooled mining**](https://github.com/GitGab19/Stratum-V2-Master-Degree-Thesis/blob/main/Stratum-V2-MD-thesis.pdf)

---

# `getwork`

---

`getwork` was a RPC method introduced into `bitcoin-core` in 2010.

It allowed solo miners to:
- retrieve block headers to work on
- publish newfound valid blocks

On the context of pooled mining, it also allowed:
- pools to retrieve block headers and distribute jobs to miners
- miners to submit shares to the pools
- pools to publish newfound valid blocks

---

![center](../img/02-getwork-pool-00.png)

---

![center](../img/02-getwork-pool-01.png)

---

![center](../img/02-getwork-pool-02.png)

---

![center](../img/02-getwork-pool-03.png)

---

![center](../img/02-getwork-pool-04.png)

---

## `getwork` limitations

`getwork` only allowed miners to change the 32 bits of the `nonce` field.

For a miner with 4.3 Ghash/s ($2^{32}$ nonces/s), the entire search space would be exhausted in 1 second (!!!), and hashpower would be idle until a new job was distributed.

Some `getwork` protocol extensions (e.g.: `X-Roll-Ntime`) allowed to increase the search space by changing the `timestamp` field within a limited range. But that wasn't a perfect solution and it became clear that `getwork` was inefficient.

---

# `getblocktemplate`

---

`getblocktemplate` (also known as GBT) was introduced in 2012 by Luke-Jr via `BIP22` and `BIP23`.

The main motivations for GBT were:
- to solve the issue where as hashrate increased, the nonce search space was exhausted too quickly.
- to decentralize the power from pool operators (central point of failure and censorship), allowing for miners to select which transactions would go into the block.

---

![center](../img/02-gbt-00.png)

---

![center](../img/02-gbt-table-00.png)

---

![center](../img/02-gbt-01.png)

---

![center](../img/02-gbt-table-01.png)

---

![center](../img/02-gbt-02.png)

---

![center](../img/02-gbt-table-02.png)

---

![center](../img/02-gbt-03.png)

---

![center](../img/02-gbt-04.png)

---

## `getblocktemplate` limitations

Also in 2012, Marek "slush" Palatinus, the founder of one of the first Bitcoin mining pools (slushpool), announced his alternative to `getwork`: a protocol called `stratum`.

The performance of `stratum` was better than `getblocktemplate`, and the design was cleaner and easier to be understood by the mining pools operators of that time.

Thanks to its efficiency improvements `stratum` became the standard "de facto" of the pooled mining protocols.

---

# `stratum` (SV1)

----

Just like `getblocktemplate`, `stratum` aimed to solve the problems with `getwork`: 

the available mining hardware was already able to exhaust the `nonce` search space too quickly. This resulted in frequent requests for new job and networking congestion for the pool.

Another problem with both `getwork` and `getblocktemplate` is the fact that they were `JSON-RPC` methods over `HTTP`. `HTTP` is a protocol designed for website navigation, which also introduced unnecessary networking overhead.

---

## How `stratum` works

`stratum` is a line-based protocol over `TCP`, with payloads encoded as `JSON-RPC` messages.

The client simply opens a `TCP` socket and writes `JSON-RPC` messages, delimited by the `newline` (`\n`) character.

Every line received by the client is again a valid `JSON-RPC` fragment containing the response.

There is no `HTTP` overhead.

---

## How `stratum` works

`stratum` also introduced a push mechanism for real-time updates (job notification).

Unlike the previous `getwork` protocol, where miners had to explicitly request new mining jobs, `stratum` allows mining pool servers to proactively push mining jobs to subscribed miners.

This eliminates the delay and latency caused by frequent client requests, ensuring that miners are always provided with the correct mining work.

---

## How `stratum` works

In order to overcome the `getwork` inefficiency around the `nonce` search space, `stratum` introduced the concept of an **`extranonce`** field. 

The `extranonce` field is a mutable portion of the coinbase transaction in the block template that miners can modify during the mining process.

By allowing miners to modify the `extranonce`, `stratum` expanded the search space for a valid block nonce without requiring frequent job requests to the pool server. This optimized utilization of network resources.

---

![center](../img/02-stratum-00.png)

---

![center](../img/02-stratum-01.png)

---

![center](../img/02-stratum-02.png)

---

![center](../img/02-stratum-03.png)

---

![center](../img/02-stratum-04.png)

---

![center](../img/02-stratum-05.png)

---

![center](../img/02-stratum-06.png)

---

### Job notification fields

- `job_id`: ID of the job. Use this ID while submitting share generated from this job.
- `prevhash`: hash of previous block.
- `coinb1`: initial part of coinbase transaction
- `coinb2`: final part of coinbase transaction.
- `merkle_branch`: list of hashes for calculation of merkle root.
- `version`: version of Bitcoin protocol.
- `nbits`: encoded current network difficulty
- `ntime`: current ntime
- `clean_jobs`: when `true`, pool server indicates that shares from previous jobs will be rejected.

---

![center](../img/02-stratum-07.png)

---

![center](../img/02-stratum-08.png)

---

![center](../img/02-stratum-09.png)

---

![center](../img/02-stratum-10.png)

---

## `stratum` vulnerabilities

Since all miner-pool communication is **unencrypted**, it was demonstrated in 2021 [(Liu X. et al.)](https://i.blackhat.com/asia-21/Thursday-Handouts/as-21-Liu-Disappeared-Coins-Steal-Hashrate-In-Stratum-Secretly.pdf) that a man-in-the-middle attacker can steal hashrate secretly.

![center](../img/02-blackhat.png)

---

## Why `stratum-v2` is needed

### `stratum` pros:
- efficiency and scalability
- easy implementation
- wide adoption

### `stratum` cons:
- vulnerable to hashrate theft
- privacy concerns (plaintext)
- limited authentication
- bandwidth inneficient (`JSON`)
- tx censorship by pool

---

### Next Episode

- Stratum V2
  - What is SV2
  - How SV2 works
  - Differences between SV1 and SV2
  - Current implementations