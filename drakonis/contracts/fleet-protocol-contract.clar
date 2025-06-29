;; Mystical Dragon Sanctuary
;; Dragons that evolve based on magical essence and keeper bonding

;; Define the Dragon NFT
(define-non-fungible-token mystical-dragon uint)

;; Constants
(define-constant dragon-master tx-sender)
(define-constant err-master-only (err u300))
(define-constant err-not-keeper (err u301))
(define-constant err-dragon-not-found (err u302))
(define-constant err-already-hatched (err u303))

;; Data Variables
(define-data-var last-dragon-id uint u0)
(define-data-var mana-surge-threshold uint u60000) ;; Magical essence threshold
(define-data-var sanctuary-tribute uint u200) ;; 2% tribute (200 basis points)

;; Data Maps
(define-map dragon-traits 
  uint 
  {
    breed: (string-ascii 64),
    legend: (string-ascii 256),
    portrait-uri: (string-ascii 256),
    power-level: uint,
    last-awakening-moon: uint,
    keeper-bond: uint,
    ritual-count: uint
  }
)

(define-map dragon-auction-price uint uint)
(define-map keeper-ritual-mastery principal uint)
(define-map mana-essence-flow uint uint) ;; Moon cycle -> Essence level

;; Helper Functions
(define-private (get-next-dragon-id)
  (+ (var-get last-dragon-id) u1)
)

(define-private (calculate-power-level (mana-essence uint) (keeper-bond uint) (moons-bonded uint))
  (let ((mana-amplifier (if (>= mana-essence (var-get mana-surge-threshold)) u2 u1))
        (bond-amplifier (/ keeper-bond u10))
        (time-amplifier (/ moons-bonded u1000)))
    (+ mana-amplifier bond-amplifier time-amplifier)
  )
)

(define-private (strengthen-keeper-bond (keeper principal))
  (let ((current-bond (default-to u0 (map-get? keeper-ritual-mastery keeper))))
    (map-set keeper-ritual-mastery keeper (+ current-bond u1))
    (+ current-bond u1)
  )
)

;; Public Functions

;; Hatch a new mystical dragon
(define-public (hatch-dragon (keeper principal) (breed (string-ascii 64)) (legend (string-ascii 256)) (portrait-uri (string-ascii 256)))
  (let ((dragon-id (get-next-dragon-id)))
    (begin
      (try! (nft-mint? mystical-dragon dragon-id keeper))
      (map-set dragon-traits dragon-id {
        breed: breed,
        legend: legend,
        portrait-uri: portrait-uri,
        power-level: u1,
        last-awakening-moon: block-height,
        keeper-bond: u0,
        ritual-count: u0
      })
      (var-set last-dragon-id dragon-id)
      (ok dragon-id)
    )
  )
)

;; Offer dragon at auction
(define-public (offer-at-auction (dragon-id uint) (reserve-price uint))
  (let ((keeper (unwrap! (nft-get-owner? mystical-dragon dragon-id) err-dragon-not-found)))
    (begin
      (asserts! (is-eq keeper tx-sender) err-not-keeper)
      (map-set dragon-auction-price dragon-id reserve-price)
      (ok true)
    )
  )
)

;; Claim dragon from auction
(define-public (claim-dragon (dragon-id uint))
  (let ((price (unwrap! (map-get? dragon-auction-price dragon-id) err-dragon-not-found))
        (current-keeper (unwrap! (nft-get-owner? mystical-dragon dragon-id) err-dragon-not-found))
        (tribute (/ (* price (var-get sanctuary-tribute)) u10000))
        (keeper-payment (- price tribute)))
    (begin
      ;; Transfer payment to current keeper
      (try! (stx-transfer? keeper-payment tx-sender current-keeper))
      ;; Transfer tribute to dragon master
      (try! (stx-transfer? tribute tx-sender dragon-master))
      ;; Transfer dragon to new keeper
      (try! (nft-transfer? mystical-dragon dragon-id current-keeper tx-sender))
      ;; Remove from auction
      (map-delete dragon-auction-price dragon-id)
      ;; Strengthen keeper bond
      (strengthen-keeper-bond tx-sender)
      (ok true)
    )
  )
)

;; Channel mana essence (only dragon master)
(define-public (channel-mana-essence (essence-level uint))
  (begin
    (asserts! (is-eq tx-sender dragon-master) err-master-only)
    (map-set mana-essence-flow block-height essence-level)
    (ok true)
  )
)

;; Awaken dragon's true power
(define-public (awaken-dragon (dragon-id uint))
  (let ((dragon-data (unwrap! (map-get? dragon-traits dragon-id) err-dragon-not-found))
        (keeper (unwrap! (nft-get-owner? mystical-dragon dragon-id) err-dragon-not-found))
        (current-mana (default-to u55000 (map-get? mana-essence-flow block-height)))
        (keeper-bond (default-to u0 (map-get? keeper-ritual-mastery keeper)))
        (moons-bonded (- block-height (get last-awakening-moon dragon-data)))
        (new-power-level (calculate-power-level current-mana keeper-bond moons-bonded)))
    (begin
      ;; Must bond for at least 100 moon cycles
      (asserts! (> moons-bonded u100) (err u304))
      ;; Must actually increase power
      (asserts! (> new-power-level (get power-level dragon-data)) (err u305))
      
      ;; Update dragon traits
      (map-set dragon-traits dragon-id (merge dragon-data {
        power-level: new-power-level,
        last-awakening-moon: block-height,
        keeper-bond: keeper-bond,
        ritual-count: (+ (get ritual-count dragon-data) u1)
      }))
      
      ;; Strengthen keeper bond
      (strengthen-keeper-bond keeper)
      (ok new-power-level)
    )
  )
)

;; Perform bonding ritual
(define-public (perform-ritual (dragon-id uint))
  (let ((keeper (unwrap! (nft-get-owner? mystical-dragon dragon-id) err-dragon-not-found)))
    (begin
      (asserts! (is-eq keeper tx-sender) err-not-keeper)
      (let ((new-bond (strengthen-keeper-bond tx-sender)))
        (ok new-bond)
      )
    )
  )
)

;; Read-only functions

(define-read-only (get-dragon-traits (dragon-id uint))
  (map-get? dragon-traits dragon-id)
)

(define-read-only (get-dragon-price (dragon-id uint))
  (map-get? dragon-auction-price dragon-id)
)

(define-read-only (get-keeper-mastery (keeper principal))
  (default-to u0 (map-get? keeper-ritual-mastery keeper))
)

(define-read-only (get-current-mana-essence)
  (default-to u55000 (map-get? mana-essence-flow block-height))
)

(define-read-only (get-sanctuary-population)
  (var-get last-dragon-id)
)

(define-read-only (get-dragon-keeper (dragon-id uint))
  (ok (nft-get-owner? mystical-dragon dragon-id))
)

;; Initialize mystical sanctuary
(define-public (initialize-sanctuary)
  (begin
    (asserts! (is-eq tx-sender dragon-master) err-master-only)
    (map-set mana-essence-flow block-height u60000)
    (ok true)
  )
)