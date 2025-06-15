;; Tokenized Real Estate Marketplace - Corrected Map Definition

;; Correct property map definition
(define-map properties
   uint  ;; Key is a single uint named 'id'
  (tuple 
    (owner principal) 
    (price uint) 
    (is-listed bool)
  )
)

(define-data-var property-counter uint u0)

;; Mint a new property token
(define-public (mint-property (price uint))
  (let ((id (var-get property-counter)))
    (begin
      (asserts! (> price u0) (err u100))
      (map-set properties 
        u6
        (tuple 
          (owner tx-sender) 
          (price price) 
          (is-listed false)))
      (var-set property-counter (+ id u1))
      (ok id))))

;; List a property for sale
(define-public (list-property (id uint) (price uint))
  (match (map-get? properties id)
    prop
    (begin
      (asserts! (is-eq tx-sender (get owner prop)) (err u101))
      (asserts! (> price u0) (err u102))
      (map-set properties 
        id
        (tuple 
          (owner (get owner prop)) 
          (price price) 
          (is-listed true)))
      (ok true))
    (err u103)))

;; Buy a property
(define-public (buy-property (id uint))
  (match (map-get? properties id)
    prop
    (begin
      (asserts! (get is-listed prop) (err u104))
      (asserts! (not (is-eq tx-sender (get owner prop))) (err u105))
      (try! (stx-transfer? (get price prop) tx-sender (get owner prop)))
      (map-set properties 
        id
        (tuple 
          (owner tx-sender) 
          (price (get price prop)) 
          (is-listed false)))
      (ok true))
    (err u106)))