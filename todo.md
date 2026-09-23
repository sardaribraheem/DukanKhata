# DukanKhata — TODO

> Simple Urdu-first shop inventory + daily khata app for an auto repair / spare-parts shop.
>
> **Primary user:** Shop owner in his 70s.
>
> **Style:** Minimalist Claymorphism.
>
> **Core principle:** The owner should be able to use the app with almost no technical knowledge. Voice should be the easiest input method, while manual controls must always be available.

---

# 0. PROJECT RULES

- [ ] Keep V1 extremely simple.
- [ ] Optimize for an older user, not for developers.
- [ ] Large buttons, readable text, clear labels, minimal screens.
- [ ] Urdu-first UX where practical; technical implementation can remain English.
- [ ] Never make the user understand accounting terminology.
- [ ] AI assists with understanding voice input; AI must NOT directly control the database.
- [ ] Every AI transaction must be converted into structured data and confirmed before committing.
- [ ] Business calculations must be deterministic application logic, not AI-generated calculations.
- [ ] Do not add unnecessary features just because they are technically possible.
- [ ] Prefer simple, maintainable architecture over over-engineering.
- [ ] V1 must work without requiring the owner to understand the backend.

---

# 1. PROJECT GOAL

Build a Flutter mobile application for a real auto repair / spare-parts shop.

The shop owner:

- Owns the shop.
- Purchases and stocks oils, spare parts, tires, filters, small items, etc.
- Sells those products to customers.
- A mechanic works at the shop and separately earns labour/mazdoori.
- V1 focuses on the owner's product inventory and daily sales/khata.
- Mechanic labour management is NOT part of V1.

The application should replace the need for a paper daily khata for product sales and inventory.

---

# 2. CORE V1 WORKFLOW

The owner should be able to:

1. Log in.
2. See today's khata immediately.
3. Record a sale manually.
4. Record a sale using Urdu voice.
5. Add a completely new product to the inventory.
6. Restock an existing product.
7. See current stock.
8. See today's sold items.
9. See revenue, cost, and profit.
10. Correct mistakes manually.

---

# 3. TECHNOLOGY

## Frontend

- [ ] Flutter
- [ ] Mobile-first
- [ ] Responsive enough for common Android phones
- [ ] Clean and simple UI
- [ ] Large touch targets

## Backend

Use Supabase for this project to gain experience with PostgreSQL/backend architecture.

- [ ] Supabase Auth
- [ ] Supabase PostgreSQL
- [ ] Supabase Storage for product photos

Avoid unnecessary Supabase features in V1.

Do NOT introduce Edge Functions, realtime systems, complex server architecture, etc. unless genuinely required.

## AI / Voice

AI provider must remain replaceable.

Architecture:

```
Voice
  ↓
Speech-to-Text
  ↓
LLM / AI extraction
  ↓
Structured transaction
  ↓
App validation
  ↓
User confirmation
  ↓
Database
```

Possible AI/voice providers can be evaluated during implementation.

Do not tightly couple the application architecture to one AI provider.

---

# 4. AUTHENTICATION

## V1

- [ ] Supabase email/password authentication
- [ ] Login screen
- [ ] Logout
- [ ] Persistent session
- [ ] Only authenticated owner can access shop data

Do not build:

- social login
- multiple shops
- employee accounts
- roles/permissions system

unless required later.

---

# 5. PRODUCT MODEL

A product represents a type of item the shop sells.

Example:

```
Shell 20W-50 Engine Oil
```

A product should contain approximately:

- [ ] id
- [ ] name
- [ ] category
- [ ] photo
- [ ] default/original purchase cost
- [ ] default sale price
- [ ] current stock quantity
- [ ] favorite status
- [ ] created\_at
- [ ] updated\_at

Important:

### Default Sale Price

This is the normal/reference price.

It is NOT a fixed selling price.

Customers may negotiate.

Example:

```
Default sale price = Rs. 900
```

Actual sale:

```
Customer negotiated = Rs. 850
```

The sale record must store Rs. 850.

The product's default price remains Rs. 900.

---

# 6. PRODUCT CATEGORIES

Initial categories:

- [ ] All
- [ ] Oils & Fluids
- [ ] Parts
- [ ] Tires
- [ ] Batteries
- [ ] Small Items
- [ ] Other

Categories should be simple and expandable later.

Do not attempt to create a perfect automotive taxonomy in V1.

---

# 7. ADD PRODUCT

This means:

> "We are introducing a completely new product into the shop."

Workflow:

```
Inventory
  ↓
Add Product
  ↓
Take/select photo
  ↓
Product name
  ↓
Category
  ↓
Default purchase/cost price
  ↓
Default sale price
  ↓
Favorite? ⭐
  ↓
Initial quantity
  ↓
Add Product
```

The owner should be able to photograph the real product.

Example:

```
Photo: actual oil bottle
Name: Engine Oil 20W-50
Category: Oil
Cost: Rs.700
Sale: Rs.900
Favorite: Yes
Initial stock: 12
```

Product photo should be stored using Supabase Storage.

---

# 8. RESTOCK

Restock is different from Add Product.

### Add Product

Creates a completely new product.

### Restock

Adds more quantity of an existing product.

Example:

Current:

```
Engine Oil
Stock: 4
```

Owner buys:

```
Quantity: 12
Purchase price: Rs.720
```

After restock:

```
Stock: 16
```

The restock must be recorded as a stock-purchase transaction.

Do not treat purchased inventory as today's sales expense/profit.

The money has been converted into inventory.

---

# 9. STOCK PURCHASE MODEL

Create a `stock_purchases` table.

Suggested fields:

- [ ] id
- [ ] product\_id
- [ ] quantity
- [ ] purchase\_price
- [ ] total\_cost
- [ ] purchased\_at

This preserves purchase history.

Purchase price may change over time.

Example:

Old batch:

```
Rs.700
```

New batch:

```
Rs.720
```

Do not overwrite historical purchase records.

V1 may use a simple cost-pricing rule for profit calculation. Document the rule clearly in the implementation.

Do not build complicated accounting/inventory valuation unless required.

---

# 10. SALES

Create a `sales` table.

Suggested fields:

- [ ] id
- [ ] product\_id
- [ ] quantity
- [ ] cost\_price
- [ ] sale\_price
- [ ] revenue
- [ ] profit
- [ ] sold\_at
- [ ] input\_method (manual / voice)

When a sale occurs:

```
revenue = quantity × actual sale price

cost = quantity × applicable cost price

profit = revenue - cost
```

The application calculates these values.

AI must NOT calculate or invent them.

---

# 11. MANUAL SALE

Manual selling should be extremely easy.

Flow:

```
Sell
  ↓
Categories
  ↓
Product
  ↓
Quantity
  ↓
Sale price
  ↓
Add to today's khata
```

Product card should show:

- product photo
- product name
- current stock
- default sale price

Example:

```
Engine Oil
Stock: 12
Normal price: Rs.900

Quantity: 2

Actual sale price:
Rs.850
```

The actual sale price can differ from the default sale price.

Before committing, show a simple confirmation.

---

# 12. VOICE / AI ENTRY

Voice input is a major V1 feature.

The owner should be able to press one large microphone button and speak naturally in Urdu.

Example:

```
"آج تین آئل نو سو روپے کے بیچے"
```

The system should:

1. Capture voice.
2. Convert voice to text.
3. Send text to AI extraction.
4. Return structured transaction data.
5. Match the product against existing inventory.
6. Validate quantity and prices.
7. Show confirmation.
8. Commit only after confirmation.

Example structured result:

```
action: sale
product: Engine Oil
quantity: 3
sale_price: 900
```

Then show:

```
Engine Oil × 3

Sale price: Rs.900 each
Total: Rs.2,700

[ Confirm ]
[ Edit ]
[ Cancel ]
```

---

# 13. AI SAFETY RULES

AI must NOT:

- invent products
- invent prices
- invent quantities
- invent stock
- calculate final business profit
- directly write to the database
- silently perform ambiguous transactions

If something is unclear:

Example:

```
"میں نے تین آئل بیچے"
```

The AI should identify that the product is ambiguous.

The app should ask:

```
"کون سا آئل؟"
```

or present possible matches.

If the price is missing, ask for it or use the product's default sale price only when that behavior is explicitly designed and clearly shown to the user.

Every AI-generated transaction must be confirmed before database modification.

---

# 14. TODAY'S KHATA

This is the central screen.

Display:

## Today's Sales

For each item:

- product
- quantity
- actual sale price
- revenue
- cost
- profit

Example:

```
Engine Oil
3 × Rs.850
Revenue: Rs.2,550
Profit: Rs.450

Oil Filter
2 × Rs.500
Revenue: Rs.1,000
Profit: Rs.300
```

At bottom:

```
Total Revenue: Rs.3,550
Total Cost: Rs.2,800
Total Profit: Rs.750
```

Provide:

- [ ] Add Sale Manually
- [ ] Add Sale by Voice

Do not clutter this screen with unnecessary analytics.

---

# 15. HOME SCREEN

The home screen should prioritize today's business.

Possible layout:

```
Today's Khata

Revenue
Rs.____

Profit
Rs.____

Items Sold
____

[ 🎙️ Voice Entry ]

[ 🛒 Sell ]

[ 📦 Inventory ]

[ 📒 Today's Khata ]
```

Keep it visually calm and readable.

---

# 16. INVENTORY SCREEN

Display products grouped by category.

Controls:

- [ ] Search
- [ ] All
- [ ] Oils & Fluids
- [ ] Parts
- [ ] Tires
- [ ] Batteries
- [ ] Small Items
- [ ] Other
- [ ] Favorites

Each product card can show:

- photo
- name
- current stock
- default sale price
- favorite indicator

Actions:

- [ ] View/edit product
- [ ] Restock
- [ ] Sell
- [ ] Favorite/unfavorite

---

# 17. FAVORITES

V1 should use a simple manual favorite system.

Each product has:

```
is_favorite = true / false
```

Favorites appear at the top.

Do NOT build an automatic recommendation algorithm in V1.

Later, transaction history could be used to identify frequently sold products.

---

# 18. PRODUCT EDITING

Owner should eventually be able to edit:

- product name
- category
- photo
- default purchase price
- default sale price
- favorite status

Be careful with historical data.

Changing a product's current/default price must not rewrite old sales records.

---

# 19. INVENTORY ADJUSTMENT

Provide a simple manual adjustment mechanism for mistakes.

Example:

```
Engine Oil
Current stock: 10

Adjustment:
+2 / -2

Reason:
Damaged / missing / counting correction
```

This is useful because real physical inventory will not always perfectly match the database.

Keep this simple.

---

# 20. DAILY DATA

Today's khata should be based on actual recorded sales.

The app should support viewing previous days later.

V1 minimum:

- [ ] Today
- [ ] Previous days

Do not build advanced reporting yet.

---

# 21. BUSINESS LOGIC

The application must distinguish:

### Sale

```
Inventory decreases
Revenue increases
Profit is calculated
```

### Restock

```
Inventory increases
Purchase/inventory cost is recorded
It does NOT count as sales revenue
```

### Inventory Adjustment

```
Inventory changes
No automatic sales revenue
```

### Product Creation

```
Creates product definition
May optionally create initial stock transaction
```

---

# 22. DATABASE

Initial Supabase tables:

## products

```
id
name
category
photo_url
default_cost_price
default_sale_price
stock_quantity
is_favorite
created_at
updated_at
```

## sales

```
id
product_id
quantity
cost_price
sale_price
revenue
profit
input_method
sold_at
```

## stock\_purchases

```
id
product_id
quantity
purchase_price
total_cost
purchased_at
```

## inventory\_adjustments

```
id
product_id
quantity_change
reason
created_at
```

Use proper foreign keys.

Protect data using Supabase Row Level Security.

For V1 there is only one shop owner, but structure the database so the authenticated user's ownership can be enforced.

---

# 23. PRODUCT PHOTOS

Use Supabase Storage.

Requirements:

- [ ] Upload photo when creating product.
- [ ] Store resulting URL/path in product record.
- [ ] Show thumbnail in inventory.
- [ ] Allow changing photo later.
- [ ] Handle upload failure gracefully.
- [ ] Compress/resize images where appropriate.

Do not allow huge original camera images to unnecessarily consume storage.

---

# 24. UI / UX PRINCIPLES

The owner is in his 70s.

Therefore:

- [ ] Large text
- [ ] Large buttons
- [ ] High contrast
- [ ] Minimal navigation
- [ ] No tiny icons as the only indication of an action
- [ ] Clear Urdu labels where useful
- [ ] Confirm destructive actions
- [ ] Avoid hidden gestures
- [ ] Avoid complicated forms
- [ ] Avoid technical terminology
- [ ] Avoid unnecessary animations
- [ ] Make important actions reachable within 1–2 taps

The app should feel closer to a simple digital notebook than a business ERP.

---

# 25. ERROR HANDLING

Every important operation needs a clear failure state.

Examples:

- No internet
- Voice recognition failed
- AI couldn't understand
- Product not found
- Not enough stock
- Photo upload failed
- Database request failed

Messages should explain what happened and what the owner can do next.

Avoid technical errors such as raw database/HTTP messages in the UI.

---

# 26. OFFLINE CONSIDERATION

Do not build a full offline-sync architecture in V1.

However:

- [ ] Detect when internet is unavailable.
- [ ] Avoid pretending a transaction was saved when it was not.
- [ ] Clearly tell the user when an operation requires internet.

Offline support can be a future version if real shop usage demonstrates the need.

---

# 27. V1 EXCLUSIONS

Do NOT build these in V1:

- [ ] Mechanic payroll
- [ ] Labour commission system
- [ ] Customer CRM
- [ ] Supplier CRM
- [ ] Credit/debt management
- [ ] Online payments
- [ ] Multi-shop support
- [ ] Employee accounts
- [ ] Advanced analytics
- [ ] Automatic product recommendations
- [ ] Barcode scanning
- [ ] OCR invoices
- [ ] WhatsApp integration
- [ ] Cloud accounting integrations
- [ ] Complex accounting reports
- [ ] Full offline synchronization
- [ ] Web admin dashboard
- [ ] Vercel deployment unless a web application is later added

These can be considered after the real V1 is being used.

---

# 28. FUTURE IDEAS

Possible future versions:

- Mechanic labour tracking
- Shop contribution from labour
- Customer vehicle history
- Customer khata/credit
- Supplier purchases
- Low-stock alerts
- Monthly profit reports
- Frequently sold products
- Automatic favorite suggestions
- Barcode/QR scanning
- Voice-based inventory queries
- "How much did we sell today?"
- "How many Engine Oils are left?"
- "What was our profit this month?"
- Multi-user shop accounts
- Web dashboard
- Backup/export
- Better offline support

Do not implement these until V1 proves useful.

---

# 29. DEVELOPMENT PHASES

## Phase 1 — Foundation

- [ ] Create Flutter project
- [ ] Establish project structure
- [ ] Add Supabase
- [ ] Configure environment variables securely
- [ ] Create Supabase project
- [ ] Configure Auth
- [ ] Create initial database schema
- [ ] Configure Storage
- [ ] Configure RLS
- [ ] Verify Flutter ↔ Supabase connection

## Phase 2 — Product Inventory

- [ ] Product model
- [ ] Inventory screen
- [ ] Categories
- [ ] Search
- [ ] Favorites
- [ ] Add Product
- [ ] Product photo upload
- [ ] Product editing
- [ ] Restock
- [ ] Inventory adjustment

## Phase 3 — Sales / Khata

- [ ] Manual sale
- [ ] Actual negotiated sale price
- [ ] Stock decrement
- [ ] Revenue calculation
- [ ] Profit calculation
- [ ] Today's khata
- [ ] Previous-day viewing

## Phase 4 — Voice AI

- [ ] Speech-to-text
- [ ] Urdu voice input
- [ ] AI structured extraction
- [ ] Product matching
- [ ] Validation
- [ ] Confirmation UI
- [ ] Database commit
- [ ] Error handling
- [ ] Manual correction after AI extraction

## Phase 5 — UX Polish

- [ ] Large touch targets
- [ ] Urdu-friendly labels
- [ ] Loading states
- [ ] Empty states
- [ ] Error states
- [ ] Confirmation states
- [ ] Photo optimization
- [ ] Accessibility/readability pass

## Phase 6 — Real Shop Testing

Take the app to the actual shop.

Test with real products.

Test:

- [ ] Add real products
- [ ] Photograph products
- [ ] Enter real stock
- [ ] Record real sales
- [ ] Test negotiated prices
- [ ] Test restocking
- [ ] Test voice with natural Urdu
- [ ] Test mistakes/corrections
- [ ] Watch father use it without assistance
- [ ] Record every point where he gets confused

Then improve the UX based on actual usage.

---

# 30. DEFINITION OF DONE — V1

V1 is successful when:

- [ ] Father can log in without assistance.
- [ ] Father can see today's khata immediately.
- [ ] Father can add a new product with a photo.
- [ ] Father can restock an existing product.
- [ ] Father can manually record a sale.
- [ ] Father can change the actual sale price for negotiation.
- [ ] Stock automatically decreases after a sale.
- [ ] Stock automatically increases after restock.
- [ ] Today's revenue is correct.
- [ ] Today's profit is correct according to the documented cost rule.
- [ ] Father can record a sale by speaking naturally in Urdu.
- [ ] AI asks for clarification when information is ambiguous.
- [ ] AI never silently changes inventory.
- [ ] Father can confirm/edit/cancel an AI transaction.
- [ ] Product photos work reliably.
- [ ] Favorites appear first.
- [ ] Father can correct inventory mistakes.
- [ ] The app remains simple enough for him to use independently.

---

# 31. IMPORTANT DEVELOPMENT PHILOSOPHY

Build the smallest working version first.

Do not prematurely optimize.

Do not create abstractions that are not needed.

Do not add features because they "might be useful someday."

Every feature should answer:

> "Will my father actually use this in the shop?"

If the answer is unclear, leave it out of V1.
