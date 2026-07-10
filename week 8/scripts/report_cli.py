import argparse
import sqlite3
import os
from datetime import datetime, timedelta

DB_PATH = "ecommerce.db"

def get_latest_order_date(cursor):
    cursor.execute("SELECT MAX(order_date) FROM orders")
    res = cursor.fetchone()[0]
    if res:
     
        return datetime.strptime(res.split()[0], "%Y-%m-%d")
    return datetime(2026, 6, 30) 

def parse_date(date_str):
    try:
        return datetime.strptime(date_str.strip(), "%Y-%m-%d")
    except ValueError:
        raise argparse.ArgumentTypeError(f"Invalid date format: '{date_str}'. Must be YYYY-MM-DD.")

def calculate_previous_period(start_dt, end_dt):
    delta = (end_dt - start_dt).days + 1
    prev_end_dt = start_dt - timedelta(days=1)
    prev_start_dt = start_dt - timedelta(days=delta)
    return prev_start_dt, prev_end_dt

def get_period_stats(cursor, start_dt, end_dt):
    start_str = start_dt.strftime("%Y-%m-%d") + " 00:00:00"
    end_str = end_dt.strftime("%Y-%m-%d") + " 23:59:59"
    
    # Total orders
    cursor.execute("""
        SELECT COUNT(order_id) 
        FROM orders 
        WHERE order_date BETWEEN ? AND ?
    """, (start_str, end_str))
    total_orders = cursor.fetchone()[0] or 0
    
    # Net revenue
    cursor.execute("""
        SELECT SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)) 
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.order_date BETWEEN ? AND ?
    """, (start_str, end_str))
    revenue = cursor.fetchone()[0] or 0.0
    
    # Unique customers
    cursor.execute("""
        SELECT COUNT(DISTINCT customer_id) 
        FROM orders 
        WHERE order_date BETWEEN ? AND ?
    """, (start_str, end_str))
    unique_customers = cursor.fetchone()[0] or 0
    
    return total_orders, round(revenue, 2), unique_customers

def get_top_products(cursor, start_dt, end_dt, limit=3):
    start_str = start_dt.strftime("%Y-%m-%d") + " 00:00:00"
    end_str = end_dt.strftime("%Y-%m-%d") + " 23:59:59"
    
    cursor.execute("""
        SELECT 
            p.product_name,
            p.category,
            SUM(oi.quantity) AS quantity_sold,
            ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS product_revenue
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN products p ON oi.product_id = p.product_id
        WHERE o.order_date BETWEEN ? AND ?
        GROUP BY p.product_id, p.product_name, p.category
        ORDER BY product_revenue DESC
        LIMIT ?
    """, (start_str, end_str, limit))
    return cursor.fetchall()

def get_breakdown(cursor, report_type, start_dt, end_dt):
    start_str = start_dt.strftime("%Y-%m-%d") + " 00:00:00"
    end_str = end_dt.strftime("%Y-%m-%d") + " 23:59:59"
    
    if report_type == "daily":
        date_format = "%Y-%m-%d"
        group_col = "date(o.order_date)"
    elif report_type == "weekly":
        date_format = "Week %W (%Y)"
        group_col = "strftime('%Y-W%W', o.order_date)"
    else:
        date_format = "%Y-%m"
        group_col = "strftime('%Y-%m', o.order_date)"
        
    query = f"""
        SELECT 
            {group_col} AS time_period,
            COUNT(DISTINCT o.order_id) AS total_orders,
            ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_percent / 100.0)), 2) AS period_revenue,
            COUNT(DISTINCT o.customer_id) AS unique_customers
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.order_date BETWEEN ? AND ?
        GROUP BY time_period
        ORDER BY time_period ASC
    """
    cursor.execute(query, (start_str, end_str))
    return cursor.fetchall()

def print_ascii_table(headers, rows):
    if not rows:
        print("No data available.")
        return
        
    # Find column widths
    widths = [len(h) for h in headers]
    for row in rows:
        for idx, val in enumerate(row):
            widths[idx] = max(widths[idx], len(str(val)))
            
    # Print border and headers
    row_fmt = " | ".join(f"{{:<{w}}}" for w in widths)
    separator = "-+-".join("-" * w for w in widths)
    
    print(separator)
    print(row_fmt.format(*headers))
    print(separator)
    for row in rows:
        # Convert numeric values to formatted strings 
        formatted_row = []
        for val in row:
            if isinstance(val, float):
                formatted_row.append(f"{val:,.2f}")
            else:
                formatted_row.append(str(val))
        print(row_fmt.format(*formatted_row))
    print(separator)

def generate_report(report_type, start_dt, end_dt):
    if not os.path.exists(DB_PATH):
        print(f"Error: Database file '{DB_PATH}' not found. Please run 'python scripts/db_setup.py' first.")
        return
        
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Calculate previous period dates
    prev_start_dt, prev_end_dt = calculate_previous_period(start_dt, end_dt)
    
    #  Fetch statistics
    curr_orders, curr_rev, curr_cust = get_period_stats(cursor, start_dt, end_dt)
    prev_orders, prev_rev, prev_cust = get_period_stats(cursor, prev_start_dt, prev_end_dt)
    
    # Calculate % change
    def pct_change(curr, prev):
        if prev == 0:
            return "N/A" if curr == 0 else "+100.0%"
        change = ((curr - prev) * 100.0) / prev
        sign = "+" if change >= 0 else ""
        return f"{sign}{change:.2f}%"

    orders_change = pct_change(curr_orders, prev_orders)
    rev_change = pct_change(curr_rev, prev_rev)
    cust_change = pct_change(curr_cust, prev_cust)
    
    #  Fetch top products
    top_products = get_top_products(cursor, start_dt, end_dt)
    
    #  Fetch breakdown
    breakdown_data = get_breakdown(cursor, report_type, start_dt, end_dt)
    
    # Print report
    print("\n" + "=" * 70)
    print(f"             E-COMMERCE ORDER ANALYTICS SUMMARY REPORT")
    print(f"             Report Type: {report_type.upper()}")
    print(f"             Current Period:  {start_dt.strftime('%Y-%m-%d')} to {end_dt.strftime('%Y-%m-%d')}")
    print(f"             Previous Period: {prev_start_dt.strftime('%Y-%m-%d')} to {prev_end_dt.strftime('%Y-%m-%d')}")
    print("=" * 70)
    
    print("\n[KEY PERFORMANCE METRICS]")
    metric_headers = ["Metric", "Current Period", "Previous Period", "% Change"]
    metric_rows = [
        ["Total Orders", curr_orders, prev_orders, orders_change],
        ["Net Revenue", curr_rev, prev_rev, rev_change],
        ["Unique Customers", curr_cust, prev_cust, cust_change]
    ]
    print_ascii_table(metric_headers, metric_rows)
    
    print("\n[TOP 3 PRODUCTS BY REVENUE]")
    product_headers = ["Product Name", "Category", "Units Sold", "Revenue"]
    print_ascii_table(product_headers, top_products)
    
    print(f"\n[PERIODIC BREAKDOWN ({report_type.upper()})]")
    breakdown_headers = ["Period", "Orders", "Revenue", "Unique Customers"]
    print_ascii_table(breakdown_headers, breakdown_data)
    
    conn.close()

def main():
    parser = argparse.ArgumentParser(description="E-Commerce Order Analytics CLI Reporting Tool")
    parser.add_argument(
        "--report", 
        choices=["daily", "weekly", "monthly"], 
        default="monthly", 
        help="Report period breakdown type (default: monthly)"
    )
    parser.add_argument(
        "--start-date", 
        type=parse_date, 
        help="Start date for the report range (YYYY-MM-DD)"
    )
    parser.add_argument(
        "--end-date", 
        type=parse_date, 
        help="End date for the report range (YYYY-MM-DD)"
    )
    
    args = parser.parse_args()
    

    if not os.path.exists(DB_PATH):
        print(f"Error: Database file '{DB_PATH}' not found. Please run 'python scripts/db_setup.py' first.")
        return
        
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    

    ref_dt = get_latest_order_date(cursor)
    conn.close()
    
    start_dt = args.start_date
    end_dt = args.end_date
    
    if not end_dt:
        end_dt = ref_dt
    if not start_dt:
        if args.report == "daily":
      
            start_dt = end_dt
        elif args.report == "weekly":
            
            start_dt = end_dt - timedelta(days=6)
        else:
           
            start_dt = end_dt - timedelta(days=29)
            
    # Validate date range logic
    if start_dt > end_dt:
        print("Error: --start-date must be before or equal to --end-date.")
        return
        
    generate_report(args.report, start_dt, end_dt)

if __name__ == "__main__":
    main()
