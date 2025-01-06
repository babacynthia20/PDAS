;; Biosignature NFT Contract

(define-non-fungible-token biosignature-nft uint)

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_INVALID_NFT (err u101))

;; Data variables
(define-data-var last-token-id uint u0)

;; Data maps
(define-map token-metadata
  uint
  {
    creator: principal,
    sample-id: uint,
    name: (string-ascii 64),
    description: (string-utf8 256),
    image-url: (string-ascii 256),
    discovery-date: uint,
    confidence-level: uint
  }
)

;; Public functions
(define-public (mint-biosignature (sample-id uint) (name (string-ascii 64)) (description (string-utf8 256)) (image-url (string-ascii 256)) (confidence-level uint))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (asserts! (and (>= confidence-level u0) (<= confidence-level u100)) ERR_NOT_AUTHORIZED)
    (try! (nft-mint? biosignature-nft token-id tx-sender))
    (map-set token-metadata
      token-id
      {
        creator: tx-sender,
        sample-id: sample-id,
        name: name,
        description: description,
        image-url: image-url,
        discovery-date: block-height,
        confidence-level: confidence-level
      }
    )
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer-biosignature (token-id uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender (unwrap! (nft-get-owner? biosignature-nft token-id) ERR_INVALID_NFT)) ERR_NOT_AUTHORIZED)
    (try! (nft-transfer? biosignature-nft token-id tx-sender recipient))
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-biosignature-metadata (token-id uint))
  (map-get? token-metadata token-id)
)

(define-read-only (get-biosignature-owner (token-id uint))
  (nft-get-owner? biosignature-nft token-id)
)

(define-read-only (get-last-token-id)
  (var-get last-token-id)
)

