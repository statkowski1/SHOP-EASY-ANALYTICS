CREATE TABLE products (
	product_id SERIAL PRIMARY KEY,
	name VARCHAR(100),
	category VARCHAR(50),
	price DECIMAL(10, 2),
	stock INTEGER
);

CREATE TABLE shops (
	shop_id SERIAL PRIMARY KEY,
	name VARCHAR(100),
	city VARCHAR(50),
	address VARCHAR(100)
);

CREATE TABLE clients (
	client_id SERIAL PRIMARY KEY,
	first_name VARCHAR(100),
	last_name VARCHAR(100),
	email VARCHAR(100) UNIQUE,
	created_at TIMESTAMP
);

CREATE TABLE employees (
	employee_id SERIAL PRIMARY KEY,
	first_name VARCHAR(100),
	last_name VARCHAR(100),
	salary DECIMAL(10, 2),
	shop_id INTEGER,
	created_at TIMESTAMP,
	FOREIGN KEY (shop_id) REFERENCES shops(shop_id)
);

CREATE TABLE shoppingcarts (
	shoppingcart_id SERIAL PRIMARY KEY,
	total_amount DECIMAL(10, 2),
	date_of_purchase TIMESTAMP,
	client_id INTEGER,
	shop_id INTEGER,
	FOREIGN KEY (client_id) REFERENCES clients(client_id),
	FOREIGN KEY (shop_id) REFERENCES shops(shop_id)
);

CREATE TABLE purchasedproducts (
	purchasedproduct_id SERIAL PRIMARY KEY,
	price DECIMAL(10, 2),
	quantity INTEGER,
	product_id INTEGER,
	shoppingcart_id INTEGER,
	FOREIGN KEY (product_id) REFERENCES products(product_id),
	FOREIGN KEY (shoppingcart_id) REFERENCES shoppingcarts(shoppingcart_id)
);

