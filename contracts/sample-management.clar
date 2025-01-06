;; Sample Management Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_SAMPLE (err u101))
(define-constant ERR_INVALID_STATUS (err u102))

;; Data variables
(define-data-var sample-count uint u0)

;; Data maps
(define-map samples
  uint
  {
    collector: principal,
    location: (string-ascii 64),
    timestamp: uint,
    description: (string-utf8 256),
    status: (string-ascii 20),
    verification-count: uint
  }
)

(define-map sample-verifications
  { sample-id: uint, verifier: principal }
  { verified: bool, timestamp: uint }
)

;; Public functions
(define-public (register-sample (location (string-ascii 64)) (description (string-utf8 256)))
  (let
    (
      (sample-id (+ (var-get sample-count) u1))
    )
    (map-set samples
      sample-id
      {
        collector: tx-sender,
        location: location,
        timestamp: block-height,
        description: description,
        status: "pending",
        verification-count: u0
      }
    )
    (var-set sample-count sample-id)
    (ok sample-id)
  )
)

(define-public (verify-sample (sample-id uint))
  (let
    (
      (sample (unwrap! (map-get? samples sample-id) ERR_INVALID_SAMPLE))
      (current-count (get verification-count sample))
    )
    (asserts! (is-none (map-get? sample-verifications { sample-id: sample-id, verifier: tx-sender })) ERR_NOT_AUTHORIZED)
    (map-set sample-verifications
      { sample-id: sample-id, verifier: tx-sender }
      { verified: true, timestamp: block-height }
    )
    (map-set samples
      sample-id
      (merge sample {
        verification-count: (+ current-count u1),
        status: (if (>= (+ current-count u1) u3) "verified" "pending")
      })
    )
    (ok true)
  )
)

(define-public (update-sample-status (sample-id uint) (new-status (string-ascii 20)))
  (let
    (
      (sample (unwrap! (map-get? samples sample-id) ERR_INVALID_SAMPLE))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_AUTHORIZED)
    (asserts! (or (is-eq new-status "pending") (is-eq new-status "verified") (is-eq new-status "rejected")) ERR_INVALID_STATUS)
    (ok (map-set samples
      sample-id
      (merge sample { status: new-status })
    ))
  )
)

;; Read-only functions
(define-read-only (get-sample (sample-id uint))
  (map-get? samples sample-id)
)

(define-read-only (get-sample-verification (sample-id uint) (verifier principal))
  (map-get? sample-verifications { sample-id: sample-id, verifier: verifier })
)

(define-read-only (get-sample-count)
  (var-get sample-count)
)

