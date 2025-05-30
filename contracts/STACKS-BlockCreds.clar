;; STACKS-BlockCreds

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-DUPLICATE-INSTITUTION (err u101))
(define-constant ERR-RECORD-NOT-FOUND (err u102))
(define-constant ERR-UNSUPPORTED-CREDENTIAL-TYPE (err u103))
(define-constant ERR-CREDENTIAL-STATUS-REVOKED (err u104))
(define-constant ERR-CREDENTIAL-STATUS-EXPIRED (err u105))
(define-constant ERR-INVALID-INPUT (err u106))
(define-constant ERR-ZERO-ADDRESS (err u107))
(define-constant ERR-INVALID-PERIOD (err u108))
(define-constant ERR-DUPLICATE-CREDENTIAL (err u109))
(define-constant ERR-INVALID-HASH (err u110))  ;; Added new error code

;; Data maps
(define-map authorized-educational-institutions 
    principal 
    {
        education-provider-name: (string-ascii 50),
        education-provider-url: (string-ascii 100),
        education-provider-verification-status: bool
    }
)

(define-map credential-records 
    {credential-uuid: (string-ascii 50), student-address: principal}
    {
        education-provider-address: principal,
        issuance-block-height: uint,
        expiration-block-height: uint,
        credential-type-identifier: (string-ascii 50),
        credential-document-hash: (buff 32),
        additional-credential-info: (string-ascii 256),
        revocation-status: bool
    }
)

(define-map supported-credential-categories
    (string-ascii 50)
    {
        credential-category-description: (string-ascii 100),
        credential-validity-period: uint
    }
)

;; Administrative functions
(define-data-var contract-owner principal tx-sender)

;; Validation functions
(define-private (is-valid-principal (address principal))
    (and 
        (not (is-eq address (as-contract tx-sender)))
        (not (is-eq address 'SP000000000000000000002Q6VF78)))
)

(define-private (is-valid-period (period uint))
    (> period u0)
)

(define-private (is-valid-string (str (string-ascii 256)))
    (not (is-eq str ""))
)

;; Add new validation function for buffer
(define-private (is-valid-hash (hash (buff 32)))
    (and 
        (not (is-eq hash 0x))  ;; Check if not empty
        (is-eq (len hash) u32)  ;; Verify length is exactly 32 bytes
    )
)

;; Public functions with added validation
(define-public (transfer-ownership (new-owner-address principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (is-valid-principal new-owner-address) ERR-ZERO-ADDRESS)
        (ok (var-set contract-owner new-owner-address))
    )
)

(define-public (register-education-provider 
    (education-provider-name (string-ascii 50)) 
    (education-provider-url (string-ascii 100))
)
    (let (
        (institution-profile {
            education-provider-name: education-provider-name, 
            education-provider-url: education-provider-url, 
            education-provider-verification-status: false
        })
    )
        (asserts! (is-valid-string education-provider-name) ERR-INVALID-INPUT)
        (asserts! (is-valid-string education-provider-url) ERR-INVALID-INPUT)
        (asserts! (is-none (map-get? authorized-educational-institutions tx-sender)) ERR-DUPLICATE-INSTITUTION)
        (ok (map-set authorized-educational-institutions tx-sender institution-profile))
    )
)

(define-public (verify-education-provider (provider-address principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (is-valid-principal provider-address) ERR-ZERO-ADDRESS)
        (asserts! (is-some (map-get? authorized-educational-institutions provider-address)) ERR-RECORD-NOT-FOUND)
        (ok (map-set authorized-educational-institutions 
            provider-address 
            (merge (unwrap-panic (map-get? authorized-educational-institutions provider-address)) 
                {education-provider-verification-status: true}
            )
        ))
    )
)

(define-public (register-credential-category 
    (category-id (string-ascii 50)) 
    (category-description (string-ascii 100)) 
    (validity-period-blocks uint)
)
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (asserts! (is-valid-string category-id) ERR-INVALID-INPUT)
        (asserts! (is-valid-string category-description) ERR-INVALID-INPUT)
        (asserts! (is-valid-period validity-period-blocks) ERR-INVALID-PERIOD)
        (ok (map-set supported-credential-categories category-id {
            credential-category-description: category-description,
            credential-validity-period: validity-period-blocks
        }))
    )
)
