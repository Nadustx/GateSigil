;; GateSigil - NFT Access Control Contract with QR Code Integration

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_OWNER_ONLY u100)
(define-constant ERR_NOT_TOKEN_OWNER u101)
(define-constant ERR_TOKEN_NOT_FOUND u102)
(define-constant ERR_TOKEN_EXPIRED u103)
(define-constant ERR_INVALID_EXPIRATION u104)
(define-constant ERR_UNAUTHORIZED u105)
(define-constant ERR_ALREADY_EXISTS u106)
(define-constant ERR_INVALID_PARAMETERS u107)
(define-constant ERR_MINT_FAILED u108)
(define-constant ERR_TRANSFER_FAILED u109)
(define-constant ERR_QR_CODE_EXPIRED u110)
(define-constant ERR_QR_CODE_INVALID u111)
(define-constant ERR_QR_CODE_USED u112)
(define-constant ERR_QR_CODE_NOT_FOUND u113)

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var contract-uri (string-utf8 256) u"")
(define-data-var qr-code-validity-period uint u144) ;; 144 blocks (~24 hours)

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

;; QR Code Maps
(define-map qr-codes
  { qr-hash: (buff 32) }
  {
    token-id: uint,
    created-at: uint,
    expires-at: uint,
    used: bool,
    realm: (string-ascii 64),
    creator: principal
  }
)

(define-map token-qr-usage
  { token-id: uint }
  { 
    total-generated: uint,
    last-generated: uint
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
    (err ERR_TOKEN_NOT_FOUND)
  )
)

;; QR Code read-only functions
(define-read-only (get-qr-code-info (qr-hash (buff 32)))
  (map-get? qr-codes { qr-hash: qr-hash })
)

(define-read-only (validate-qr-code (qr-hash (buff 32)))
  (match (map-get? qr-codes { qr-hash: qr-hash })
    qr-data
    (if (and 
          (not (get used qr-data))
          (<= stacks-block-height (get expires-at qr-data)))
      (ok true)
      (ok false))
    (ok false)
  )
)

(define-read-only (get-token-qr-stats (token-id uint))
  (map-get? token-qr-usage { token-id: token-id })
)

(define-read-only (get-qr-validity-period)
  (ok (var-get qr-code-validity-period))
)

;; Private functions
(define-private (is-valid-realm-name (realm (string-ascii 64)))
  (and (> (len realm) u0) (<= (len realm) u64))
)

(define-private (is-valid-uri (uri (string-utf8 256)))
  (and (> (len uri) u0) (<= (len uri) u256))
)

(define-private (validate-principal (p principal))
  (not (is-eq p 'SP000000000000000000002Q6VF78))
)

(define-private (validate-expiration (exp (optional uint)))
  (match exp
    exp-val (> exp-val stacks-block-height)
    true)
)

(define-private (is-valid-token-id (token-id uint))
  (and (> token-id u0) (<= token-id (var-get last-token-id)))
)

(define-private (is-valid-qr-hash (qr-hash (buff 32)))
  (is-eq (len qr-hash) u32)
)

;; Public functions
(define-public (create-realm (realm (string-ascii 64)) (description (string-utf8 256)))
  (let ((realm-exists (is-some (map-get? realms { realm: realm }))))
    (asserts! (is-valid-realm-name realm) (err ERR_INVALID_PARAMETERS))
    (asserts! (not realm-exists) (err ERR_ALREADY_EXISTS))
    (asserts! (<= (len description) u256) (err ERR_INVALID_PARAMETERS))
    (asserts! (validate-principal tx-sender) (err ERR_INVALID_PARAMETERS))
    (map-set realms 
      { realm: realm }
      {
        creator: tx-sender,
        description: description,
        access-required: u1,
        created-at: stacks-block-height
      }
    )
    (ok true)
  )
)

(define-public (mint-access-nft 
  (to principal) 
  (realm (string-ascii 64)) 
  (expiration (optional uint))
  (metadata-uri (string-utf8 256)))
  (let ((token-id (+ (var-get last-token-id) u1))
        (realm-data (unwrap! (map-get? realms { realm: realm }) (err ERR_TOKEN_NOT_FOUND))))
    ;; Validate all inputs
    (asserts! (validate-principal to) (err ERR_INVALID_PARAMETERS))
    (asserts! (is-valid-realm-name realm) (err ERR_INVALID_PARAMETERS))
    (asserts! (is-valid-uri metadata-uri) (err ERR_INVALID_PARAMETERS))
    (asserts! (validate-expiration expiration) (err ERR_INVALID_EXPIRATION))
    (asserts! (> token-id u0) (err ERR_INVALID_PARAMETERS))
    
    ;; Check authorization - only realm creator or contract owner can mint
    (asserts! (or (is-eq tx-sender (get creator realm-data))
                  (is-eq tx-sender CONTRACT_OWNER)) (err ERR_UNAUTHORIZED))
    
    ;; Attempt to mint NFT
    (unwrap! (nft-mint? gate-sigil token-id to) (err ERR_MINT_FAILED))
    
    ;; Update token data
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
    
    ;; Update user access
    (map-set user-access
      { user: to, realm: realm }
      {
        token-id: token-id,
        granted-at: stacks-block-height,
        expires-at: expiration
      }
    )
    
    ;; Initialize QR usage stats
    (map-set token-qr-usage
      { token-id: token-id }
      {
        total-generated: u0,
        last-generated: u0
      }
    )
    
    ;; Update last token ID
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (let ((token-owner (unwrap! (nft-get-owner? gate-sigil token-id) (err ERR_TOKEN_NOT_FOUND)))
        (token-data (unwrap! (map-get? tokens { token-id: token-id }) (err ERR_TOKEN_NOT_FOUND))))
    ;; Validate inputs
    (asserts! (is-valid-token-id token-id) (err ERR_INVALID_PARAMETERS))
    (asserts! (validate-principal sender) (err ERR_INVALID_PARAMETERS))
    (asserts! (validate-principal recipient) (err ERR_INVALID_PARAMETERS))
    
    ;; Verify ownership and authorization
    (asserts! (is-eq sender token-owner) (err ERR_NOT_TOKEN_OWNER))
    (asserts! (or (is-eq tx-sender token-owner) (is-eq tx-sender sender)) (err ERR_NOT_TOKEN_OWNER))
    
    ;; Attempt transfer
    (let ((realm-val (get realm token-data)))
      (unwrap! (nft-transfer? gate-sigil token-id sender recipient) (err ERR_TRANSFER_FAILED))
      
      ;; Update token data
      (map-set tokens
        { token-id: token-id }
        {
          owner: recipient,
          expiration: (get expiration token-data),
          realm: realm-val,
          metadata-uri: (get metadata-uri token-data),
          active: (get active token-data)
        }
      )
      
      ;; Update user access maps
      (map-delete user-access { user: sender, realm: realm-val })
      (map-set user-access
        { user: recipient, realm: realm-val }
        {
          token-id: token-id,
          granted-at: stacks-block-height,
          expires-at: (get expiration token-data)
        }
      )
      
      (ok true)
    )
  )
)

(define-public (revoke-token (token-id uint))
  (let ((token-data (unwrap! (map-get? tokens { token-id: token-id }) (err ERR_TOKEN_NOT_FOUND)))
        (realm (get realm token-data))
        (realm-data (unwrap! (map-get? realms { realm: realm }) (err ERR_TOKEN_NOT_FOUND))))
    ;; Validate inputs
    (asserts! (is-valid-token-id token-id) (err ERR_INVALID_PARAMETERS))
    
    ;; Check authorization
    (asserts! (or (is-eq tx-sender CONTRACT_OWNER) 
                  (is-eq tx-sender (get creator realm-data))) (err ERR_UNAUTHORIZED))
    
    ;; Revoke token by setting active to false
    (map-set tokens
      { token-id: token-id }
      {
        owner: (get owner token-data),
        expiration: (get expiration token-data),
        realm: realm,
        metadata-uri: (get metadata-uri token-data),
        active: false
      }
    )
    (ok true)
  )
)

;; QR Code Generation and Validation Functions
(define-public (generate-qr-code (token-id uint) (qr-hash (buff 32)))
  (let ((token-data (unwrap! (map-get? tokens { token-id: token-id }) (err ERR_TOKEN_NOT_FOUND)))
        (token-owner (unwrap! (nft-get-owner? gate-sigil token-id) (err ERR_TOKEN_NOT_FOUND)))
        (current-stats (default-to { total-generated: u0, last-generated: u0 } 
                                  (map-get? token-qr-usage { token-id: token-id }))))
    ;; Validate inputs
    (asserts! (is-valid-token-id token-id) (err ERR_INVALID_PARAMETERS))
    (asserts! (is-valid-qr-hash qr-hash) (err ERR_INVALID_PARAMETERS))
    
    ;; Check if token is active and not expired
    (asserts! (get active token-data) (err ERR_TOKEN_EXPIRED))
    (match (get expiration token-data)
      exp-block (asserts! (<= stacks-block-height exp-block) (err ERR_TOKEN_EXPIRED))
      true)
    
    ;; Check authorization - only token owner can generate QR codes
    (asserts! (is-eq tx-sender token-owner) (err ERR_NOT_TOKEN_OWNER))
    
    ;; Check if QR code already exists
    (asserts! (is-none (map-get? qr-codes { qr-hash: qr-hash })) (err ERR_ALREADY_EXISTS))
    
    ;; Create QR code entry
    (let ((expires-at (+ stacks-block-height (var-get qr-code-validity-period))))
      (map-set qr-codes
        { qr-hash: qr-hash }
        {
          token-id: token-id,
          created-at: stacks-block-height,
          expires-at: expires-at,
          used: false,
          realm: (get realm token-data),
          creator: tx-sender
        }
      )
      
      ;; Update usage stats
      (map-set token-qr-usage
        { token-id: token-id }
        {
          total-generated: (+ (get total-generated current-stats) u1),
          last-generated: stacks-block-height
        }
      )
      
      (ok expires-at)
    )
  )
)

(define-public (verify-and-use-qr-code (qr-hash (buff 32)) (realm (string-ascii 64)))
  (let ((qr-data (unwrap! (map-get? qr-codes { qr-hash: qr-hash }) (err ERR_QR_CODE_NOT_FOUND)))
        (token-data (unwrap! (map-get? tokens { token-id: (get token-id qr-data) }) (err ERR_TOKEN_NOT_FOUND))))
    ;; Validate inputs
    (asserts! (is-valid-qr-hash qr-hash) (err ERR_INVALID_PARAMETERS))
    (asserts! (is-valid-realm-name realm) (err ERR_INVALID_PARAMETERS))
    
    ;; Check if QR code is valid
    (asserts! (not (get used qr-data)) (err ERR_QR_CODE_USED))
    (asserts! (<= stacks-block-height (get expires-at qr-data)) (err ERR_QR_CODE_EXPIRED))
    (asserts! (is-eq realm (get realm qr-data)) (err ERR_QR_CODE_INVALID))
    
    ;; Check if underlying token is still valid
    (asserts! (get active token-data) (err ERR_TOKEN_EXPIRED))
    (match (get expiration token-data)
      exp-block (asserts! (<= stacks-block-height exp-block) (err ERR_TOKEN_EXPIRED))
      true)
    
    ;; Mark QR code as used
    (map-set qr-codes
      { qr-hash: qr-hash }
      {
        token-id: (get token-id qr-data),
        created-at: (get created-at qr-data),
        expires-at: (get expires-at qr-data),
        used: true,
        realm: (get realm qr-data),
        creator: (get creator qr-data)
      }
    )
    
    (ok (get token-id qr-data))
  )
)

(define-public (batch-mint 
  (recipients (list 50 principal))
  (realm (string-ascii 64))
  (expiration (optional uint))
  (base-uri (string-utf8 256)))
  (let ((realm-data (unwrap! (map-get? realms { realm: realm }) (err ERR_TOKEN_NOT_FOUND))))
    ;; Validate inputs
    (asserts! (is-valid-realm-name realm) (err ERR_INVALID_PARAMETERS))
    (asserts! (is-valid-uri base-uri) (err ERR_INVALID_PARAMETERS))
    (asserts! (validate-expiration expiration) (err ERR_INVALID_EXPIRATION))
    
    ;; Check authorization
    (asserts! (or (is-eq tx-sender (get creator realm-data))
                  (is-eq tx-sender CONTRACT_OWNER)) (err ERR_UNAUTHORIZED))
    
    ;; Validate all recipients
    (asserts! (is-eq (len (filter validate-principal recipients)) (len recipients)) (err ERR_INVALID_PARAMETERS))
    
    ;; Perform batch mint
    (ok (fold batch-mint-fold recipients { realm: realm, expiration: expiration, base-uri: base-uri, results: (list) }))
  )
)

(define-private (batch-mint-fold 
  (recipient principal) 
  (data { realm: (string-ascii 64), expiration: (optional uint), base-uri: (string-utf8 256), results: (list 50 uint) }))
  (let ((token-id (+ (var-get last-token-id) u1)))
    (match (nft-mint? gate-sigil token-id recipient)
      success
      (begin
        ;; Update token data
        (map-set tokens
          { token-id: token-id }
          {
            owner: recipient,
            expiration: (get expiration data),
            realm: (get realm data),
            metadata-uri: (get base-uri data),
            active: true
          }
        )
        
        ;; Update user access
        (map-set user-access
          { user: recipient, realm: (get realm data) }
          {
            token-id: token-id,
            granted-at: stacks-block-height,
            expires-at: (get expiration data)
          }
        )
        
        ;; Initialize QR usage stats
        (map-set token-qr-usage
          { token-id: token-id }
          {
            total-generated: u0,
            last-generated: u0
          }
        )
        
        ;; Update last token ID
        (var-set last-token-id token-id)
        
        ;; Return updated data with new token ID
        {
          realm: (get realm data),
          expiration: (get expiration data),
          base-uri: (get base-uri data),
          results: (unwrap-panic (as-max-len? (append (get results data) token-id) u50))
        }
      )
      err-code
      ;; Return data unchanged on failure
      {
        realm: (get realm data),
        expiration: (get expiration data),
        base-uri: (get base-uri data),
        results: (unwrap-panic (as-max-len? (append (get results data) u0) u50))
      }
    )
  )
)

;; Admin functions
(define-public (set-contract-uri (uri (string-utf8 256)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_OWNER_ONLY))
    (asserts! (is-valid-uri uri) (err ERR_INVALID_PARAMETERS))
    (var-set contract-uri uri)
    (ok true)
  )
)

(define-public (set-qr-validity-period (blocks uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) (err ERR_OWNER_ONLY))
    (asserts! (and (> blocks u0) (<= blocks u4320)) (err ERR_INVALID_PARAMETERS)) ;; Max 30 days
    (var-set qr-code-validity-period blocks)
    (ok true)
  )
)