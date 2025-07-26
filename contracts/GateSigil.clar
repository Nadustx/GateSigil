;; GateSigil - NFT Access Control Contract
;; Turns NFTs into access passes for private content, services, or communities

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_OWNER_ONLY (err u100))
(define-constant ERR_NOT_TOKEN_OWNER (err u101))
(define-constant ERR_TOKEN_NOT_FOUND (err u102))
(define-constant ERR_TOKEN_EXPIRED (err u103))
(define-constant ERR_INVALID_EXPIRATION (err u104))
(define-constant ERR_UNAUTHORIZED (err u105))
(define-constant ERR_ALREADY_EXISTS (err u106))
(define-constant ERR_INVALID_PARAMETERS (err u107))

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var contract-uri (string-utf8 256) u"")

;; Data Maps
(define-map tokens
  { token-id: uint }
  {
    owner: principal,
    expiration: (optional uint),
    realm: (string-ascii 64),
    metadata-uri: (string-utf8 256),
    active: bool
  }
)

(define-map realms
  { realm: (string-ascii 64) }
  {
    creator: principal,
    description: (string-utf8 256),
    access-required: uint,
    created-at: uint
  }
)

(define-map user-access
  { user: principal, realm: (string-ascii 64) }
  { 
    token-id: uint,
    granted-at: uint,
    expires-at: (optional uint)
  }
)

;; SIP-009 NFT Trait Implementation
(define-non-fungible-token gate-sigil uint)

;; Read-only functions
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (token-id uint))
  (match (map-get? tokens { token-id: token-id })
    token-data (ok (some (get metadata-uri token-data)))
    (ok none)
  )
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? gate-sigil token-id))
)

(define-read-only (get-token-info (token-id uint))
  (map-get? tokens { token-id: token-id })
)

(define-read-only (get-realm-info (realm (string-ascii 64)))
  (map-get? realms { realm: realm })
)

(define-read-only (check-access (user principal) (realm (string-ascii 64)))
  (match (map-get? user-access { user: user, realm: realm })
    access-data 
    (let ((token-id (get token-id access-data))
          (expires-at (get expires-at access-data)))
      (match (map-get? tokens { token-id: token-id })
        token-data
        (if (get active token-data)
          (match expires-at
            expiry (if (<= stacks-block-height expiry)
                     (ok true)
                     (ok false))
            (ok true))
          (ok false))
        (ok false)))
    (ok false)
  )
)

(define-read-only (is-token-expired (token-id uint))
  (match (map-get? tokens { token-id: token-id })
    token-data
    (match (get expiration token-data)
      exp-block (ok (> stacks-block-height exp-block))
      (ok false))
    ERR_TOKEN_NOT_FOUND
  )
)

(define-read-only (get-user-tokens (user principal))
  (ok (filter check-user-owns (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10)))
)

(define-private (check-user-owns (token-id uint))
  (match (nft-get-owner? gate-sigil token-id)
    owner (is-eq owner tx-sender)
    false
  )
)

;; Private functions
(define-private (is-valid-realm-name (realm (string-ascii 64)))
  (and (> (len realm) u0) (<= (len realm) u64))
)

(define-private (is-valid-uri (uri (string-utf8 256)))
  (and (> (len uri) u0) (<= (len uri) u256))
)

;; Public functions
(define-public (create-realm (realm (string-ascii 64)) (description (string-utf8 256)))
  (let ((realm-exists (is-some (map-get? realms { realm: realm }))))
    (asserts! (is-valid-realm-name realm) ERR_INVALID_PARAMETERS)
    (asserts! (not realm-exists) ERR_ALREADY_EXISTS)
    (asserts! (<= (len description) u256) ERR_INVALID_PARAMETERS)
    (ok (map-set realms 
      { realm: realm }
      {
        creator: tx-sender,
        description: description,
        access-required: u1,
        created-at: stacks-block-height
      }
    ))
  )
)

(define-public (mint-access-nft 
  (to principal) 
  (realm (string-ascii 64)) 
  (expiration (optional uint))
  (metadata-uri (string-utf8 256)))
  (let ((token-id (+ (var-get last-token-id) u1)))
    (if (and (is-valid-realm-name realm)
             (is-some (map-get? realms { realm: realm }))
             (is-valid-uri metadata-uri)
             (or (is-none expiration) 
                 (> (default-to u0 expiration) stacks-block-height)))
      (match (nft-mint? gate-sigil token-id to)
        success
        (begin
          (map-set tokens
            { token-id: token-id }
            {
              owner: to,
              expiration: expiration,
              realm: realm,
              metadata-uri: metadata-uri,
              active: true
            }
          )
          (map-set user-access
            { user: to, realm: realm }
            {
              token-id: token-id,
              granted-at: stacks-block-height,
              expires-at: expiration
            }
          )
          (var-set last-token-id token-id)
          (ok token-id)
        )
        error (err ERR_INVALID_PARAMETERS)
      )
      (err (if (not (is-valid-realm-name realm))
             ERR_INVALID_PARAMETERS
             (if (not (is-some (map-get? realms { realm: realm })))
               ERR_TOKEN_NOT_FOUND
               (if (not (is-valid-uri metadata-uri))
                 ERR_INVALID_PARAMETERS
                 ERR_INVALID_EXPIRATION))))
    )
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (let ((token-owner (unwrap! (nft-get-owner? gate-sigil token-id) ERR_TOKEN_NOT_FOUND)))
    (asserts! (> token-id u0) ERR_INVALID_PARAMETERS)
    (asserts! (or (is-eq tx-sender token-owner) (is-eq tx-sender sender)) ERR_NOT_TOKEN_OWNER)
    (asserts! (is-eq sender token-owner) ERR_NOT_TOKEN_OWNER)
    (match (map-get? tokens { token-id: token-id })
      token-data
      (let ((realm (get realm token-data)))
        (match (nft-transfer? gate-sigil token-id sender recipient)
          success
          (begin
            (map-set tokens
              { token-id: token-id }
              (merge token-data { owner: recipient })
            )
            (map-delete user-access { user: sender, realm: realm })
            (map-set user-access
              { user: recipient, realm: realm }
              {
                token-id: token-id,
                granted-at: stacks-block-height,
                expires-at: (get expiration token-data)
              }
            )
            (ok true)
          )
          error (err u107)
        )
      )
      (err u102)
    )
  )
)

(define-public (revoke-token (token-id uint))
  (let ((token-data (unwrap! (map-get? tokens { token-id: token-id }) ERR_TOKEN_NOT_FOUND))
        (realm (get realm token-data))
        (realm-data (unwrap! (map-get? realms { realm: realm }) ERR_TOKEN_NOT_FOUND)))
    (asserts! (> token-id u0) ERR_INVALID_PARAMETERS)
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) 
                  (is-eq tx-sender (get creator realm-data))) ERR_UNAUTHORIZED)
    (map-set tokens
      { token-id: token-id }
      (merge token-data { active: false })
    )
    (ok true)
  )
)

(define-public (batch-mint 
  (recipients (list 50 principal))
  (realm (string-ascii 64))
  (expiration (optional uint))
  (base-uri (string-utf8 256)))
  (let ((realm-data (unwrap! (map-get? realms { realm: realm }) ERR_TOKEN_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get creator realm-data)) ERR_UNAUTHORIZED)
    (asserts! (is-valid-uri base-uri) ERR_INVALID_PARAMETERS)
    (ok (map mint-single-nft recipients))
  )
)

(define-private (mint-single-nft (recipient principal))
  (let ((token-id (+ (var-get last-token-id) u1)))
    (match (nft-mint? gate-sigil token-id recipient)
      success
      (begin
        (var-set last-token-id token-id)
        token-id)
      error u0
    )
  )
)

(define-public (set-contract-uri (uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_OWNER_ONLY)
    (asserts! (is-valid-uri uri) ERR_INVALID_PARAMETERS)
    (ok (var-set contract-uri uri))
  )
)