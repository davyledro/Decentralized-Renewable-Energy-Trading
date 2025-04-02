;; consumption-metering.clar
;; Tracks energy usage by consumers

(define-map consumer-meters
  principal
  {
    total-consumption: uint,
    last-reading: uint,
    last-update: uint
  }
)

(define-map consumption-history
  { consumer: principal, period: uint }
  { amount: uint, timestamp: uint }
)

(define-read-only (get-meter (consumer principal))
  (default-to
    { total-consumption: u0, last-reading: u0, last-update: u0 }
    (map-get? consumer-meters consumer)
  )
)

(define-read-only (get-consumption-for-period (consumer principal) (period uint))
  (map-get? consumption-history { consumer: consumer, period: period })
)

(define-public (register-meter (consumer principal))
  (begin
    (asserts! (is-eq tx-sender consumer) (err u1))
    (map-set consumer-meters consumer {
      total-consumption: u0,
      last-reading: u0,
      last-update: block-height
    })
    (ok true)
  )
)

(define-public (record-consumption (consumer principal) (reading uint) (period uint))
  (let
    (
      (current-meter (get-meter consumer))
      (last-reading (get last-reading current-meter))
      (consumption (- reading last-reading))
    )

    ;; Update the meter
    (map-set consumer-meters consumer {
      total-consumption: (+ (get total-consumption current-meter) consumption),
      last-reading: reading,
      last-update: block-height
    })

    ;; Record in history
    (map-set consumption-history
      { consumer: consumer, period: period }
      { amount: consumption, timestamp: block-height }
    )

    (ok consumption)
  )
)
