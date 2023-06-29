DROP TABLE IF EXISTS suppliers, items, orders;

CREATE TABLE suppliers (
	id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
	supplier_name varchar NOT NULL,
	phone varchar UNIQUE NOT NULL,
	city varchar NOT NULL
);
-- a foreign key is a column in one table (table A) whose data consists of
-- a reference to another table (table B)

CREATE TABLE items (
  id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
  item_name TEXT NOT NULL,
  unit TEXT,
  unit_cost numeric,
  -- REFERENCES constraint lets us set up a foreign key
  -- everything in this supplier_id column in the items table has to have a corresponding
  -- supplier with that id in the suppliers table
  supplier_id INTEGER REFERENCES suppliers(id) NOT NULL
); 

CREATE TABLE orders (
  id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
  created_at TIMESTAMPTZ DEFAULT now(),
  item_id INTEGER REFERENCES items(id) NOT NULL,
  amount numeric,
  total_cost numeric,
  shipping_status TEXT
);

	
-- first remove any data that may be present
TRUNCATE  suppliers, items, orders RESTART IDENTITY CASCADE;
 
-- insert some suppliers
INSERT INTO suppliers
  (supplier_name, phone, city)
  VALUES 
    ('Arnold Grummers Papermaking', '920-840-6056', 'Appleton'),
    ('Glatfelter', '49 (0) 3 39 86 / 69-0', 'Falkenhagen'),
    ('Blumfeld Paper', '555-6789', 'Moscow');
    
   	
-- insert some items
INSERT INTO items
  (item_name, unit, unit_cost, supplier_id)
  VALUES
    ('Paper Additives', 'LBS', '3.85', 1),
    ('G-Colors Envelope Papers', 'LBS', '0.62', 2),    
    ('Abaca Sheet Pulp', 'LBS', '11.20', 1),    
    ('Unbleached Abaca', 'LBS', '1499.00', 1),    
    ('Wood pulp', 'LBS', '0.20', 3),
    ('White Envelope Papers', 'LBS', '0.52', 2);
    
   	
-- insert some orders
INSERT INTO orders 
  (item_id, amount, total_cost, shipping_status)
  VALUES
    (1, 10, 38.5, 'Delivered'),
    (2, 2000, 1240, 'Shipped'),
    (3, 50, 560, 'Shipped'),
    (4, 1, 1499, 'Shipped'),
    (5, 2000, 400, 'Preparing'),
    (2, 1000, 620, 'Preparing');   
    
   
INSERT INTO orders
  (item_id, amount, total_cost, shipping_status)
VALUES
  (4, 20, 20, 'Shipped');

DELETE FROM orders WHERE item_id = 4;
DELETE FROM items WHERE id = 4;

SELECT * FROM orders;
SELECT * FROM orders JOIN items ON orders.item_id = items.id;
SELECT orders.id, total_cost, shipping_status, item_name FROM orders JOIN items ON orders.item_id = items.id WHERE total_cost > 400;

SELECT orders.id, total_cost, shipping_status, item_name, supplier_name 
	FROM orders 
		JOIN items ON orders.item_id = items.id
		JOIN suppliers ON items.supplier_id = suppliers.id
	WHERE total_cost > 400;
	

-- many to many adventure time
ALTER TABLE items DROP COLUMN supplier_id;

CREATE TABLE suppliers_items (
  supplier_id INTEGER REFERENCES suppliers(id) NOT NULL,
  item_id INTEGER REFERENCES items(id) NOT NULL,
  PRIMARY KEY (supplier_id, item_id)
);

INSERT INTO suppliers_items
    (supplier_id, item_id)
VALUES
    (1, 1),
    (1, 3),
    (1, 5);
    
   	
INSERT INTO suppliers_items
    (supplier_id, item_id)
VALUES
    (2, 5),
    (3, 5);
    
-- joining across many tables

SELECT * 
	FROM items 
	JOIN suppliers_items ON suppliers_items.item_id = items.id
	JOIN suppliers ON suppliers_items.supplier_id = suppliers.id;
	
SELECT * 
	FROM items 
	JOIN suppliers_items ON suppliers_items.item_id = items.id
	JOIN suppliers ON suppliers_items.supplier_id = suppliers.id
	JOIN orders ON orders.item_id = items.id;

-- example 2: candies and colors
CREATE TABLE candies(
	id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
	candy_name TEXT,
	sweetness INTEGER
);

CREATE TABLE colors(
	id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
	color_name TEXT
);

INSERT INTO candies (candy_name, sweetness)
	VALUES
	('Junior Mints', 9),
	('Skittles', 8),
	('Nerds', 9),
	('M&Ms', 7),
	('Milk chocolate', 8);

INSERT INTO colors (color_name)
	VALUES
	('blue'),
	('green'),
	('red'),
	('brown'),
	('white'),
	('yellow');

DROP TABLE IF EXISTS candies_colors;
CREATE TABLE candies_colors(
	candy_id INTEGER REFERENCES candies(id) NOT NULL,
	color_id INTEGER REFERENCES colors(id) NOT NULL,
	color_proportion NUMERIC,
	PRIMARY KEY (candy_id, color_id)
);

INSERT INTO candies_colors (candy_id, color_id, color_proportion) VALUES
	(1,4, .67),
	(1,5, .33),
	(2,1, .2),
	(2,2, .2),
	(2,3, .2),
	(2,6, .2),
	(3,1, .18),
	(3,2, .33),
	(3,3, .1),
	(3,6, .2);

INSERT INTO candies_colors (candy_id, color_id, color_proportion) VALUES
    (4,1, .18),
	(4,2, .18),
	(4,3, .18),
	(4,6, .18),
	(5, 4, 1);

-- which candies are which colors?
SELECT candy_name, color_name, color_proportion FROM candies
	JOIN candies_colors ON candies.id = candies_colors.candy_id 
	JOIN colors ON candies_colors.color_id = colors.id;

SELECT candy_name, color_name, sweetness FROM candies
	JOIN candies_colors ON candies.id = candies_colors.candy_id 
	JOIN colors ON candies_colors.color_id = colors.id
	WHERE color_name = 'blue';

-- other joins for our candies and colors
INSERT INTO colors (color_name) VALUES ('gray');
INSERT INTO candies (candy_name, sweetness) VALUES ('clear gummy bears', 6);



SELECT candy_name, color_name, color_proportion FROM candies
	LEFT JOIN candies_colors ON candies.id = candies_colors.candy_id 
	LEFT JOIN colors ON candies_colors.color_id = colors.id;

SELECT candy_name, color_name, color_proportion FROM candies
	JOIN candies_colors ON candies.id = candies_colors.candy_id 
	RIGHT JOIN colors ON candies_colors.color_id = colors.id;

SELECT candy_name, color_name, color_proportion FROM candies
	FULL JOIN candies_colors ON candies.id = candies_colors.candy_id 
	FULL JOIN colors ON candies_colors.color_id = colors.id;


	

