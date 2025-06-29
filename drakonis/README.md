### 📘 README for **Drakonis**

---

# Drakonis

**Drakonis** is a decentralized mystical sanctuary for evolving dragon NFTs that grow stronger through magical essence and the strength of their bond with their keepers. Built in Clarity for the Stacks blockchain, it fuses fantasy lore with on-chain game mechanics, NFT auctions, and ritual-based progression.

---

## 🧬 Features

* **Dynamic NFT Dragons**: Each dragon has unique traits (breed, legend, portrait, power level) and can evolve over time.
* **Keeper Bonding System**: Keepers can strengthen their relationship with dragons through rituals, influencing power growth.
* **Mana Essence Mechanic**: The sanctuary is infused with magical essence that affects dragon awakening and evolution.
* **Auctions & Ownership Transfer**: Dragons can be listed for auction and claimed by new keepers, with tribute paid to the dragon master.
* **Evolving Power Levels**: Dragons grow stronger based on mana, bond level, and time spent with a keeper.
* **Read-Only Queries**: Fetch trait data, auction prices, keeper mastery, and current mana levels seamlessly.

---

## 📜 Contract Overview

### 🐣 Dragon Lifecycle

* **`hatch-dragon`**: Mint a new mystical dragon with custom traits.
* **`offer-at-auction`**: List a dragon for sale at a reserve price.
* **`claim-dragon`**: Purchase and adopt a dragon from auction.

### 🪄 Progression & Rituals

* **`perform-ritual`**: Strengthen the bond with a dragon.
* **`awaken-dragon`**: Evolve a dragon’s power if bonded for 100+ moon cycles and if magical conditions are met.
* **`channel-mana-essence`**: Sanctuary master sets magical essence levels for each moon cycle.

### 🔍 Read-Only Access

* **`get-dragon-traits`**, **`get-dragon-price`**, **`get-keeper-mastery`**, etc., provide insight into dragons, auctions, and keeper status.

---

## 🛠 Developer Guide

### Deployment

Ensure you are deploying on the Stacks blockchain using [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-smart-contract-language).

Set `dragon-master` to the deployer (`tx-sender`) on contract initialization.

```clojure
(initialize-sanctuary)
```

This sets the sanctuary's magical essence to the default threshold.

---

## ⚖️ Tribute & Economy

* **Sanctuary Tribute**: 2% of each auction payment goes to the `dragon-master`.
* **Keeper Payment**: 98% is sent to the current keeper during an auction claim.

---

## ⚠️ Errors

| Code | Description                             |
| ---- | --------------------------------------- |
| 300  | Only dragon master can call             |
| 301  | Caller is not dragon's keeper           |
| 302  | Dragon not found                        |
| 303  | Dragon already hatched                  |
| 304  | Not enough moon cycles bonded           |
| 305  | New power level not higher than current |

---

## 🧙‍♂️ Lore-Driven Possibilities

* Use `legend` to tell unique dragon stories.
* Combine `portrait-uri` with AI-generated art.
* Create gameplay incentives around power-level thresholds.
* Implement keeper leaderboards based on ritual mastery.

---

## 🔮 Future Extensions

* Breeding mechanics between dragons.
* Magic items for dragon enhancement.
* Cross-keeper dragon duels.
* DAO-based governance for the sanctuary.
