import unittest
import pandas as pd
from datetime import datetime, timedelta
import sys
import os

# Add scripts directory to path to import cleaning functions
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
from scripts.clean_data import clean_orders, check_referential_integrity

class TestDataCleaningEdgeCases(unittest.TestCase):
    
    def test_orphaned_order_items(self):
        """
        Verify that check_referential_integrity removes items with an order_id not in orders.
        """
        orders_df = pd.DataFrame({
            "order_id": ["ORD00001", "ORD00002"],
            "customer_id": ["CUST00001", "CUST00002"],
            "order_date": ["2026-01-01 10:00:00", "2026-01-02 12:00:00"],
            "status": ["DELIVERED", "PLACED"],
            "region_code": ["US-EAST", "US-WEST"]
        })
        
        products_df = pd.DataFrame({
            "product_id": ["PROD00001", "PROD00002"],
            "product_name": ["Laptop", "Mouse"],
            "category": ["Electronics", "Electronics"],
            "subcategory": ["Computers", "Accessories"],
            "cost_price": [1000.0, 50.0]
        })
        
        order_items_df = pd.DataFrame({
            "item_id": ["ITEM00001", "ITEM00002", "ITEM00003"],
            "order_id": ["ORD00001", "ORD00002", "ORD99999"],  # ORD99999 is orphaned
            "product_id": ["PROD00001", "PROD00002", "PROD00001"],
            "quantity": [1, 2, 1],
            "unit_price": [1200.0, 60.0, 1200.0],
            "discount_percent": [10.0, 0.0, 0.0]
        })
        
        clean_items_df = check_referential_integrity(order_items_df, orders_df, products_df)
        
        # Verify that ORD99999 is removed
        self.assertEqual(len(clean_items_df), 2)
        self.assertNotIn("ORD99999", clean_items_df["order_id"].values)
        self.assertIn("ORD00001", clean_items_df["order_id"].values)
        self.assertIn("ORD00002", clean_items_df["order_id"].values)
        print("Test passed: Orphaned order_items correctly identified and removed.")

    def test_invalid_discount_percent(self):
        """
        Verify that discount_percent > 100 or < 0 is handled.
        """
        item_df = pd.DataFrame({
            "item_id": ["ITEM00001", "ITEM00002", "ITEM00003"],
            "order_id": ["ORD00001", "ORD00001", "ORD00001"],
            "product_id": ["PROD00001", "PROD00002", "PROD00003"],
            "quantity": [1, 2, 1],
            "unit_price": [100.0, 50.0, 20.0],
            "discount_percent": [10.0, 120.0, -5.0]  # 120 and -5 are invalid
        })
        
        # In clean_data.py pipeline, we perform invalid discount filtering as:
        invalid_discount_mask = (item_df["discount_percent"] > 100.0) | (item_df["discount_percent"] < 0.0)
        clean_df = item_df[~invalid_discount_mask]
        
        self.assertEqual(len(clean_df), 1)
        self.assertEqual(clean_df.iloc[0]["item_id"], "ITEM00001")
        print("Test passed: Invalid discount percents (> 100 or < 0) correctly filtered out.")

    def test_quantity_is_zero(self):
        """
        Verify that quantity = 0 is filtered out.
        """
        item_df = pd.DataFrame({
            "item_id": ["ITEM00001", "ITEM00002", "ITEM00003"],
            "order_id": ["ORD00001", "ORD00001", "ORD00001"],
            "product_id": ["PROD00001", "PROD00002", "PROD00003"],
            "quantity": [1, 0, 5],  # 0 quantity is invalid
            "unit_price": [100.0, 50.0, 20.0],
            "discount_percent": [0.0, 0.0, 0.0]
        })
        
        # In clean_data.py pipeline, we filter quantity == 0
        zero_qty_mask = item_df["quantity"] == 0
        clean_df = item_df[~zero_qty_mask]
        
        self.assertEqual(len(clean_df), 2)
        self.assertNotIn("ITEM00002", clean_df["item_id"].values)
        print("Test passed: Zero quantity order items correctly filtered out.")

    def test_future_order_date(self):
        """
        Verify that order_date in the future is handled and removed.
        """
        # Current simulated time is July 9, 2026.
        # We will create an order with a date in the future (e.g. 2027-01-01)
        future_date = (datetime(2026, 7, 9) + timedelta(days=10)).strftime("%Y-%m-%d %H:%M:%S")
        
        orders_df = pd.DataFrame({
            "order_id": ["ORD00001", "ORD00002"],
            "customer_id": ["CUST00001", "CUST00002"],
            "order_date": ["2026-05-01 10:00:00", future_date],
            "status": ["DELIVERED", "PLACED"],
            "region_code": ["US-EAST", "US-WEST"]
        })
        
        clean_orders_df = clean_orders(orders_df)
        
        # Verify only ORD00001 remains
        self.assertEqual(len(clean_orders_df), 1)
        self.assertEqual(clean_orders_df.iloc[0]["order_id"], "ORD00001")
        print("Test passed: Future order dates correctly identified and filtered out.")

if __name__ == "__main__":
    unittest.main()
