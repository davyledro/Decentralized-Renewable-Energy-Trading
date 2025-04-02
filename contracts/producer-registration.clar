;; producer-registration.clar
;; Records details of energy generation sources

(define-data-var next-producer-id uint u1)

(define-map producers
  uint
  {
    owner: principal,
    name: (string-utf8 100),
    energy-type: (string-utf8 20),
    capacity: uint,
    location: (string-utf8 100),
    active: bool
  }
)

(define-read-only (get-producer (id uint))
  (map-get? producers id)
)

(define-read-only (get-producer-count)
  (var-get next-producer-id)
)

(define-public (register-producer
    (name (string-utf8 100))
    (energy-type (string-utf8 20))
    (capacity uint)
    (location (string-utf8 100)))
  (let
    ((producer-id (var-get next-producer-id)))
    (map-set producers producer-id {
      owner: tx-sender,
      name: name,
      energy-type: energy-type,
      capacity: capacity,
      location: location,
      active: true
    })
    (var-set next-producer-id (+ producer-id u1))
    (ok producer-id)
  )
)

(define-public (update-producer-status (id uint) (active bool))
  (let ((producer (unwrap! (map-get? producers id) (err u1))))
    (asserts! (is-eq tx-sender (get owner producer)) (err u2))
    (map-set producers id (merge producer { active: active }))
    (ok true)
  )
)

(define-public (update-capacity (id uint) (new-capacity uint))
  (let ((producer (unwrap! (map-get? producers id) (err u1))))
    (asserts! (is-eq tx-sender (get owner producer)) (err u2))
    (map-set producers id (merge producer { capacity: new-capacity }))
    (ok true)
  )
)
