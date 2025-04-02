;; peer-to-peer-trading.clar
;; Facilitates direct energy exchange between producers and consumers

(define-data-var next-offer-id uint u1)

(define-map energy-offers
  uint
  {
    seller: principal,
    energy-amount: uint,
    price-per-unit: uint,
    expiration: uint,
    active: bool
  }
)

(define-map trades
  uint
  {
    offer-id: uint,
    buyer: principal,
    seller: principal,
    energy-amount: uint,
    total-price: uint,
    timestamp: uint
  }
)

(define-data-var next-trade-id uint u1)

(define-read-only (get-offer (offer-id uint))
  (map-get? energy-offers offer-id)
)

(define-read-only (get-trade (trade-id uint))
  (map-get? trades trade-id)
)

(define-public (create-energy-offer (energy-amount uint) (price-per-unit uint) (blocks-valid uint))
  (let
    ((offer-id (var-get next-offer-id)))

    (map-set energy-offers offer-id {
      seller: tx-sender,
      energy-amount: energy-amount,
      price-per-unit: price-per-unit,
      expiration: (+ block-height blocks-valid),
      active: true
    })

    (var-set next-offer-id (+ offer-id u1))
    (ok offer-id)
  )
)

(define-public (cancel-offer (offer-id uint))
  (let ((offer (unwrap! (map-get? energy-offers offer-id) (err u1))))
    (asserts! (is-eq tx-sender (get seller offer)) (err u2))
    (asserts! (get active offer) (err u3))

    (map-set energy-offers offer-id (merge offer { active: false }))
    (ok true)
  )
)

(define-public (purchase-energy (offer-id uint) (amount uint))
  (let
    (
      (offer (unwrap! (map-get? energy-offers offer-id) (err u1)))
      (seller (get seller offer))
      (available-amount (get energy-amount offer))
      (price-per-unit (get price-per-unit offer))
      (total-price (* amount price-per-unit))
      (trade-id (var-get next-trade-id))
    )

    ;; Validate the offer
    (asserts! (get active offer) (err u2))
    (asserts! (<= block-height (get expiration offer)) (err u3))
    (asserts! (<= amount available-amount) (err u4))

    ;; Update the offer
    (if (is-eq amount available-amount)
      (map-set energy-offers offer-id (merge offer { active: false, energy-amount: u0 }))
      (map-set energy-offers offer-id (merge offer { energy-amount: (- available-amount amount) }))
    )

    ;; Record the trade
    (map-set trades trade-id {
      offer-id: offer-id,
      buyer: tx-sender,
      seller: seller,
      energy-amount: amount,
      total-price: total-price,
      timestamp: block-height
    })

    (var-set next-trade-id (+ trade-id u1))
    (ok trade-id)
  )
)
