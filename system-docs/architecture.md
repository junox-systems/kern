# Kern system architecture v0.2

# Core Concepts

## Operator

The human using Kern.

The operator defines values through categories and time allocations.

The operator owns all commitments.

---

## Category

A category represents an area of life.

Categories express values.

Categories own:

* priority
* time allocation

---

## Commitment

A commitment is anything requiring attention.

Commitments belong to categories.

Commitments compete for available attention.

---

## Calendar

The external representation of attention allocation.

Calendar events are generated from category allocations.

Calendar events do not own commitments.

---

## Recommendation

A recommendation is a scheduling result produced by the Kernel.

Recommendations are temporary.

Recommendations exist only to direct attention.

---

## Kernel

The decision engine of Kern.

The Kernel continuously schedules commitments according to:

* category priorities
* category allocations
* available time
* commitment constraints

---

## Attention

Attention is the scarce resource managed by Kern.

Categories allocate it.

Time represents it.

Commitments compete for it.

Recommendations direct it.

---

# Boundaries

Kern schedules commitments.

Kern does not define values.

Kern does not define goals.

Kern applies the values and allocations defined by the operator.

---

# Invariants

- Categories express values.
- Time allocations express priorities.
- Commitments compete for attention.
- The kernel schedules commitments.
- Recommendations are explainable.
- The operator may ignore any recommendation.
- Reality overrides schedules.

# Decision Flow

```text
Operator

    ↓

Categories
+
Allocations
+
Commitments

    ↓

Kernel

    ↓

Recommendations

    ↓

Action

    ↓

Reality

    ↓

Kernel
```

---
# Architectural Principles

## Reality overrides schedules.

The schedule must adapt to reality.

Reality must never adapt to the schedule.

---

## The operator remains sovereign.

Recommendations are optional.

The operator may ignore any recommendation.

---

## Attention is the scarce resource.

Time is a representation of attention.

Commitments compete for attention.

---

## Explanation is required.

Every recommendation must be explainable.

Nothing important should be hidden.

---

## Complexity must justify itself.

Every permanent concept must reduce future decisions.

Otherwise it does not belong.

---

# Non-Goals

- Define values
- Define priorities
- Replace calendars
- Replace human judgment
- Optimize productivity
- Maximize output

# Ownership

Kern owns attention allocation. Calendars display attention allocation.

## Operator Owns

- Categories
- Time allocations
- Commitments

## Kernel Owns

- Scheduling
- Recommendations

## Google Calendar Owns

- Calendar events
- Synchronization
- External integrations

---
