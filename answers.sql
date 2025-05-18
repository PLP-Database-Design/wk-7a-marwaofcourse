-- Create a new table to hold 1NF-compliant data
CREATE TABLE ProductDetail_1NF (
  OrderID INT,
  CustomerName VARCHAR(255),
  Product VARCHAR(255)
);

-- Insert normalized data using JSON_TABLE for splitting Products string into rows
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT
  OrderID,
  CustomerName,
  TRIM(product) AS Product
FROM
  ProductDetail,
  JSON_TABLE(
    CONCAT('["', REPLACE(Products, ',', '","'), '"]'),
    "$[*]" COLUMNS(product VARCHAR(255) PATH "$")
  ) AS split_products;

-- Create Orders table to hold OrderID and CustomerName
CREATE TABLE Orders (
  OrderID INT PRIMARY KEY,
  CustomerName VARCHAR(255)
);

-- Insert distinct orders into Orders table
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName FROM OrderDetails;

-- Create new OrderDetails table without CustomerName
CREATE TABLE OrderDetails_2NF (
  OrderID INT,
  Product VARCHAR(255),
  Quantity INT,
  PRIMARY KEY (OrderID, Product),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Insert remaining order details into new table
INSERT INTO OrderDetails_2NF (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity FROM OrderDetails;

