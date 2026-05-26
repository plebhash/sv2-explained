---
marp: true
theme: sv2-explained
---

![center](../img/sv2-logo.png)
# Stratum V2 Explained

## Episode 5: SRI Tutorial

<!-- _class: credit -->
by [`@plebhash`](https://plebhash.github.io)

---

## Acknowledgements

This series is based on [Gabriele Vernetti (GitGab19)](https://github.com/GitGab19)'s Master Thesis at *Politecnico Di Torino* titled:

[**Stratum V2: the next generation protocol for Bitcoin pooled mining**](https://github.com/GitGab19/Stratum-V2-Master-Degree-Thesis/blob/main/Stratum-V2-MD-thesis.pdf)

---

# Tutorial: Testing SRI configurations

The SRI working group developed and shipped all the roles which are needed for all 4 configurations.

We will focus on Config C.

---

## Prerequisites

Before entering the Configurations details, there are some first-steps that needs to be checked:

- Rust installed: if not, install it by running this command in the terminal:
```
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

- Clone the SRI repository locally:
```
$ git clone https://github.com/stratum-mining/stratum.git
```

At this point everything is correctly setup and ready for the testing phase.

---

## Config C setup

This configuration allows Mining Devices running SV1 firmware to connect to a SV2 Pool through a Translation Proxy (tProxy). The proxy is designed to sit in between a SV1 downstream role (most typically Mining Devices running SV1 firmware) and a SV2 upstream role (most typically a SV2 Pool Server).

In this case, since there is not intended to be a Template Provider miner-side, transactions selections is delegated to the SV2 Pool server, which is running its local Template Provider.

---

```
$ cd stratum/roles/v2/pool/
$ cp pool-config-example.toml ./conf/pool-config.toml
$ cd conf/
```

---

Copy the example config file `pool-config.toml` into `/conf` directory.

This file contains all the parameters needed for the pool to be correctly configured. It’s possible to enter the file and customize it for the most desired behaviour, following the guidelines available in the `README` file of the pool role.

For simplicity, it’s possible to use the testnet Template Provider which is hosted by the SRI working group.

```
tp_address = "89.116.25.191:8442"
```

---

Finally, run the SV2 Pool:
```
$ cargo run -p pool_sv2
```

The Pool is now connected to the hosted testnet Template Provider, and it will get the transactions to be put in the next block template from it.

The Pool is also listening for connection requests via port `342254`.

---

The Translator Proxy is needed. In a new terminal:
```
$ cd stratum/roles/translator/
$ cp proxy-config-example.toml ./conf/proxy-config.toml
$ cd conf/
```

---

The configuration file provided is already prepared for Config C, so the Translator Proxy is ready to be run:
```
$ cargo run -p translator_sv2
```

The Translator Proxy requested a connection to the SV2 Pool, asking to open an extended channel, and it received an extended mining job, and a `prevhash`.

So it’s now ready to customize the templates that it will distribute to the Mining Devices which will be connected to it.

---

Now, the only role which is missing is the SV1 Mining Device. There are two alternatives to run it:
- CPUminer
- ASIC

---

## CPUminer

An open-source SHA-256, multi-threaded `CPUminer` for Bitcoin which works following the Stratum (V1) protocol. 

It can be downloaded via:
```
$ wget https://github.com/pooler/cpuminer/releases/download/v2.5.1/pooler-cpuminer-2.5.1-linux-x86_64.tar.gz
$ tar xvf pooler-cpuminer-2.5.1-linux-x86_64.tar.gz
```

---

## CPUminer

Start `CPUminer`:
```
$ ./minerd -a sha256d -o stratum+tcp://localhost:34255 -q -D -P
```

---

## ASIC

With a real ASIC machine, it’s very easy to configure it to point to the Translator Proxy.

In the miner pool settings, the following string has to be added to the current endpoints:
```
stratum+tcp://<tProxy ip>:34255
```

Once configured, the ASIC miner will restart automatically and it will point its hashrate to the Translator Proxy IP previously set.