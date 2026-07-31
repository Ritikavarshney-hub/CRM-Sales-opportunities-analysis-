# 3. Entity-Relationship Diagram

Based on the dataset audit findings:
- `sales_pipeline` is the fact table; `accounts`, `products`, `sales_teams` are dimensions (star schema).
- `sales_pipeline.account` is nullable (1,425 rows have no account — likely early Prospecting-stage deals).
- `sales_pipeline.product` has a data quality issue (`'GTXPro'` vs `'GTX Pro'`) that must be cleaned before enforcing an FK constraint.
- `accounts.subsidiary_of` is a self-referencing FK (parent company is itself an account, or NULL if independent).
- `sales_teams.manager` is NOT a formal FK to `sales_agent` — 6 managers in the data never appear as agents themselves, so this is just a descriptive text column, not an enforced relationship.

```mermaid
erDiagram
    ACCOUNTS ||--o{ SALES_PIPELINE : "has opportunities"
    PRODUCTS ||--o{ SALES_PIPELINE : "sold in"
    SALES_TEAMS ||--o{ SALES_PIPELINE : "worked by"
    ACCOUNTS ||--o{ ACCOUNTS : "subsidiary_of (self-ref)"

    ACCOUNTS {
        varchar account PK
        varchar sector
        int year_established
        decimal revenue
        int employees
        varchar office_location
        varchar subsidiary_of FK "nullable, self-ref to account"
    }

    PRODUCTS {
        varchar product PK
        varchar series
        decimal sales_price
    }

    SALES_TEAMS {
        varchar sales_agent PK
        varchar manager "descriptive text, not enforced FK"
        varchar regional_office
    }

    SALES_PIPELINE {
        varchar opportunity_id PK
        varchar sales_agent FK
        varchar product FK
        varchar account FK "nullable"
        varchar deal_stage "Prospecting/Engaging/Won/Lost"
        date engage_date "nullable"
        date close_date "nullable"
        decimal close_value "nullable"
    }
```

## Cardinality summary

| Relationship | Cardinality | Notes |
|---|---|---|
| accounts → sales_pipeline | 1 : N | one account can have many deals; account may be NULL |
| products → sales_pipeline | 1 : N | one product sold across many deals |
| sales_teams → sales_pipeline | 1 : N | one agent works many deals |
| accounts → accounts | 1 : N (self) | parent company → subsidiaries |
