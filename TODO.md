# Checkout Page Enhancement TODO

## Completed Tasks

- [x] Analyze current checkout_page.dart implementation
- [x] Read relevant models (Order, Payment, Dish, CartItem)
- [x] Read controllers (CartController, AuthController)
- [x] Create comprehensive plan
- [x] Update import aliases and references (order_pkg -> order_model, payment_pkg -> payment_model)
- [x] Add order type dropdown with Dine-in, Take-out, Reservation options
- [x] Fix subtotal display to use widget.totalAmount instead of hardcoded values
- [x] Modify payment options: remove Credit/Debit Card, rename "Cash on Delivery" to "Payment upon arrival", remove delivery fields
- [x] Update GCash modal: add Mobile Number (11 digits) and Reference Number (16 digits) fields with validation
- [x] Implement place order logic:
  - [x] Generate incremental orderId by querying Firestore
  - [x] Get current user name from AuthController
  - [x] Convert cartItems to order items format
  - [x] Create Order and Payment objects
  - [x] Save Order and Payment to Firestore
  - [x] Deduct ingredients from dishes in Firestore
  - [x] Clear cart using CartController.clear()
  - [x] Navigate to ConfirmationPage on success
- [x] Add necessary imports (cloud_firestore, controllers, models)
- [x] Handle validation and error cases

## Pending Tasks

- [x] Define a constant for service fee instead of hardcoded 10
- [x] Update subtotal calculation to use the constant
- [x] Rename payment option title from "Payment upon delivery" to "Payment upon arrival"
- [x] Verify all TODO items are completed
- [x] Test the implementation
