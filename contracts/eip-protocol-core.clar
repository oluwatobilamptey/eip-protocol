;; eip-protocol-core.clar
;; EIP Protocol: Expense and Invoice Payment Management Smart Contract

;; This contract provides a decentralized protocol for managing group expenses, 
;; invoices, and financial settlements using blockchain-based transparency and trust.

;; =============== Error Constants ===============

(define-constant ERR-NOT-AUTHORIZED (err u1001))
(define-constant ERR-GROUP-EXISTS (err u1002))
(define-constant ERR-GROUP-NOT-FOUND (err u1003))
(define-constant ERR-USER-NOT-IN-GROUP (err u1004))
(define-constant ERR-USER-ALREADY-IN-GROUP (err u1005))
(define-constant ERR-EXPENSE-NOT-FOUND (err u1006))
(define-constant ERR-INSUFFICIENT-FUNDS (err u1007))
(define-constant ERR-INVALID-AMOUNT (err u1008))
(define-constant ERR-INVALID-ALLOCATION (err u1009))
(define-constant ERR-INVALID-EXPENSE-TYPE (err u1010))
(define-constant ERR-MEMBER-HAS-BALANCE (err u1011))
(define-constant ERR-INVALID-PAYMENT (err u1012))
(define-constant ERR-INVALID-PARAMETER (err u1013))

;; =============== Data Structures ===============

;; Tracks group information
(define-map groups
  { group-id: uint }
  { 
    name: (string-ascii 100),
    creator: principal,
    created-at: uint,
    active: bool
  }
)

;; Tracks group membership
(define-map group-members
  { group-id: uint, member: principal }
  {
    joined-at: uint,
    allocation-bps: uint,
    active: bool
  }
)

;; Maps group IDs to a list of member principals
(define-map group-member-list
  { group-id: uint }
  { members: (list 20 principal) }
)

;; Stores expense information
(define-map expenses
  { group-id: uint, expense-id: uint }
  {
    name: (string-ascii 100),
    amount: uint,
    paid-by: principal,
    expense-type: (string-ascii 20),
    recurrence-period: uint,
    created-at: uint,
    allocation-type: (string-ascii 10),
    settled: bool
  }
)

;; Custom expense allocations for variable expense splits
(define-map expense-allocations
  { group-id: uint, expense-id: uint, member: principal }
  { allocation-bps: uint }
)

;; Tracks running balances between members
(define-map member-balances
  { group-id: uint, from-member: principal, to-member: principal }
  { amount: uint }
)

;; Tracks payment settlements between members
(define-map settlements
  { group-id: uint, settlement-id: uint }
  {
    from-member: principal,
    to-member: principal,
    amount: uint,
    timestamp: uint,
    tx-id: (optional (buff 32))
  }
)

;; Counter for group IDs
(define-data-var next-group-id uint u1)

;; Counters for expense and settlement IDs (per group)
(define-map group-counters
  { group-id: uint }
  { 
    next-expense-id: uint,
    next-settlement-id: uint
  }
)

;; =============== Private Helper Functions ===============

;; Get the next group ID and increment the counter
(define-private (get-next-group-id)
  (let ((current-id (var-get next-group-id)))
    (var-set next-group-id (+ current-id u1))
    current-id
  )
)

;; Get the next expense ID for a group
(define-private (get-next-expense-id (group-id uint))
  (let (
    (counters (default-to { next-expense-id: u1, next-settlement-id: u1 } 
                (map-get? group-counters { group-id: group-id })))
    (next-id (get next-expense-id counters))
  )
    (map-set group-counters 
      { group-id: group-id } 
      (merge counters { next-expense-id: (+ next-id u1) })
    )
    next-id
  )
)

;; Rest of the code remains the same as the original contract
;; (with variable names updated from 'household' to 'group')