;; grid-balancing.clar
;; Manages overall stability of the energy network

(define-map grid-status
  uint  ;; period
  {
    total-production: uint,
    total-consumption: uint,
    balance: int,
    timestamp: uint
  }
)

(define-map producer-contributions
  { producer: principal, period: uint }
  { amount: uint }
)

(define-map consumer-usage
  { consumer: principal, period: uint }
  { amount: uint }
)

(define-data-var current-period uint u1)

(define-read-only (get-current-period)
  (var-get current-period)
)

(define-read-only (get-grid-status (period uint))
  (map-get? grid-status period)
)

(define-read-only (get-producer-contribution (producer principal) (period uint))
  (default-to
    { amount: u0 }
    (map-get? producer-contributions { producer: producer, period: period })
  )
)

(define-read-only (get-consumer-usage (consumer principal) (period uint))
  (default-to
    { amount: u0 }
    (map-get? consumer-usage { consumer: consumer, period: period })
  )
)

(define-public (record-production (producer principal) (amount uint))
  (let
    (
      (period (var-get current-period))
      (current-status (default-to
        { total-production: u0, total-consumption: u0, balance: 0, timestamp: block-height }
        (map-get? grid-status period)))
      (current-contribution (get amount (get-producer-contribution producer period)))
    )

    ;; Update producer contribution
    (map-set producer-contributions
      { producer: producer, period: period }
      { amount: (+ current-contribution amount) }
    )

    ;; Update grid status
    (map-set grid-status period {
      total-production: (+ (get total-production current-status) amount),
      total-consumption: (get total-consumption current-status),
      balance: (+ (get balance current-status) (to-int amount)),
      timestamp: block-height
    })

    (ok true)
  )
)

(define-public (record-consumption (consumer principal) (amount uint))
  (let
    (
      (period (var-get current-period))
      (current-status (default-to
        { total-production: u0, total-consumption: u0, balance: 0, timestamp: block-height }
        (map-get? grid-status period)))
      (current-usage (get amount (get-consumer-usage consumer period)))
    )

    ;; Update consumer usage
    (map-set consumer-usage
      { consumer: consumer, period: period }
      { amount: (+ current-usage amount) }
    )

    ;; Update grid status
    (map-set grid-status period {
      total-production: (get total-production current-status),
      total-consumption: (+ (get total-consumption current-status) amount),
      balance: (- (get balance current-status) (to-int amount)),
      timestamp: block-height
    })

    (ok true)
  )
)

(define-public (advance-period)
  (begin
    (var-set current-period (+ (var-get current-period) u1))
    (ok (var-get current-period))
  )
)
