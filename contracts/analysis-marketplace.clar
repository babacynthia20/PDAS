;; Analysis Marketplace Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_LISTING (err u101))
(define-constant ERR_INSUFFICIENT_BALANCE (err u102))

;; Data variables
(define-data-var listing-count uint u0)

;; Data maps
(define-map listings
  uint
  {
    seller: principal,
    equipment-type: (string-ascii 64),
    description: (string-utf8 256),
    price: uint,
    availability: uint,
    location: (string-ascii 64)
  }
)

;; Public functions
(define-public (create-listing (equipment-type (string-ascii 64)) (description (string-utf8 256)) (price uint) (availability uint) (location (string-ascii 64)))
  (let
    (
      (listing-id (+ (var-get listing-count) u1))
    )
    (map-set listings
      listing-id
      {
        seller: tx-sender,
        equipment-type: equipment-type,
        description: description,
        price: price,
        availability: availability,
        location: location
      }
    )
    (var-set listing-count listing-id)
    (ok listing-id)
  )
)

(define-public (purchase-analysis-time (listing-id uint) (duration uint))
  (let
    (
      (listing (unwrap! (map-get? listings listing-id) ERR_INVALID_LISTING))
      (total-cost (* (get price listing) duration))
      (buyer tx-sender)
    )
    (asserts! (>= (stx-get-balance buyer) total-cost) ERR_INSUFFICIENT_BALANCE)
    (asserts! (>= (get availability listing) duration) ERR_INVALID_LISTING)
    (try! (stx-transfer? total-cost buyer (get seller listing)))
    (map-set listings
      listing-id
      (merge listing { availability: (- (get availability listing) duration) })
    )
    (ok true)
  )
)

(define-public (remove-listing (listing-id uint))
  (let
    (
      (listing (unwrap! (map-get? listings listing-id) ERR_INVALID_LISTING))
    )
    (asserts! (is-eq tx-sender (get seller listing)) ERR_NOT_AUTHORIZED)
    (map-delete listings listing-id)
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-listing (listing-id uint))
  (map-get? listings listing-id)
)

(define-read-only (get-listing-count)
  (var-get listing-count)
)

