-- 1. Trigger aktualizujący total_amount w tabeli shoppingcarts na podstawie dodanych pozycji w purchasedproducts

-- Funkcja stworzona do odpalania przez trigger
CREATE OR REPLACE FUNCTION calculate_total_amount()
RETURNS TRIGGER AS $$
DECLARE
	tmp_shoppingcart_id INT;
	new_total_amount DECIMAL(10, 2);
	old_total_amount DECIMAL(10, 2);
BEGIN
	IF TG_OP = 'DELETE' THEN
		tmp_shoppingcart_id := OLD.shoppingcart_id;
	ELSE
		tmp_shoppingcart_id := NEW.shoppingcart_id;
	END IF;
	
	IF EXISTS (
		SELECT 1
		FROM shoppingcarts
		WHERE shoppingcarts.shoppingcart_id = tmp_shoppingcart_id
	) THEN
		SELECT COALESCE(SUM(purchasedproducts.price * purchasedproducts.quantity), 0) INTO new_total_amount
		FROM purchasedproducts
		WHERE purchasedproducts.shoppingcart_id = tmp_shoppingcart_id;

		SELECT shoppingcarts.total_amount INTO old_total_amount
		FROM shoppingcarts
		WHERE shoppingcarts.shoppingcart_id = tmp_shoppingcart_id;
		
		UPDATE shoppingcarts
		SET total_amount = new_total_amount
		WHERE shoppingcart_id = tmp_shoppingcart_id;

		RAISE NOTICE 'Zaktualizowano łączną cenę w koszyku z % na %!', old_total_amount, new_total_amount;
	ELSE
		RAISE NOTICE 'Koszyk o id: % nie istnieje!', tmp_shoppingcart_id;
	END IF;

	IF TG_OP = 'DELETE' THEN
		RETURN OLD;
	ELSE
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

-- Trigger odpalający funkcję
CREATE TRIGGER update_total_amount
AFTER INSERT OR UPDATE OR DELETE ON purchasedproducts
FOR EACH ROW
EXECUTE FUNCTION calculate_total_amount();

-- Usunięcie triggera
DROP TRIGGER update_total_amount ON purchasedproducts;

-- Usunięcie funkcji
DROP FUNCTION IF EXISTS calculate_total_amount();

-- Naprawa błędu ze złym numerowaniem id w purchasedproducts
SELECT setval('purchasedproducts_purchasedproduct_id_seq', (SELECT MAX(purchasedproduct_id) FROM purchasedproducts));

-- Testowanie triggera
INSERT INTO purchasedproducts (price, quantity, product_id, shoppingcart_id)
VALUES (1600, 2, 1, 1);
DELETE FROM purchasedproducts WHERE purchasedproduct_id = 21414;
SELECT * FROM purchasedproducts ORDER BY purchasedproduct_id DESC;
SELECT * FROM shoppingcarts ORDER BY shoppingcart_id;

-- 2. Trigger zmniejszający ilość produktów (stock) po dodaniu pozycji w purchasedproducts

-- Funkcja stworzona do odpalania przez trigger
CREATE OR REPLACE FUNCTION change_stock_product()
RETURNS TRIGGER AS $$
DECLARE
	number_of_products INT;
BEGIN
	SELECT stock INTO number_of_products
	FROM products
	WHERE products.product_id = NEW.product_id;

	IF number_of_products >= NEW.quantity THEN
		UPDATE products
		SET stock = number_of_products - NEW.quantity
		WHERE product_id = NEW.product_id;

		RAISE NOTICE 'Zmniejszono liczbę produktów z % na %', number_of_products, number_of_products - NEW.quantity;
	ELSE
		RAISE EXCEPTION 'Nie ma wymaganej ilości produktów w magazynie! Potrzeba % produktów, a na stanie jest %.', NEW.quantity, number_of_products;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger odpalający funkcję
CREATE TRIGGER update_stock_product
AFTER INSERT ON purchasedproducts
FOR EACH ROW
EXECUTE FUNCTION change_stock_product();

-- Usunięcie triggera
DROP TRIGGER update_stock_product ON purchasedproducts;

-- Usunięcie funkcji
DROP FUNCTION IF EXISTS change_stock_product();

-- Testowanie triggera
INSERT INTO purchasedproducts (price, quantity, product_id, shoppingcart_id)
VALUES (1200, 100, 4, 1);
INSERT INTO purchasedproducts (price, quantity, product_id, shoppingcart_id)
VALUES (1200, 2, 4, 1);
SELECT * FROM purchasedproducts ORDER BY purchasedproduct_id DESC;
SELECT * FROM products;

-- 3. Trigger zapisujący zmiany w cenie produktu

-- Funkcja stworzona do odpalania przez trigger
CREATE OR REPLACE FUNCTION add_old_prices()
RETURNS TRIGGER AS $$
DECLARE
	now_datetime TIMESTAMP;
BEGIN
	IF NEW.price > 0 THEN
		SELECT CURRENT_TIMESTAMP INTO now_datetime;
		
		INSERT INTO changesproductprices (old_price, new_price, product_id, created_at)
		VALUES (OLD.price, NEW.price, OLD.product_id, now_datetime);

		RAISE NOTICE 'Zmieniono cenę % na %.', OLD.price, NEW.price;
	ELSE
		RAISE EXCEPTION 'Nowa cena jest ujemna (%)!', NEW.price;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger odpalający funkcję
CREATE TRIGGER insert_old_product_price
BEFORE UPDATE ON products
FOR EACH ROW
WHEN (OLD.price IS DISTINCT FROM NEW.price)
EXECUTE FUNCTION add_old_prices();

-- Tabela pomocnicza do której trigger dodaje dane archiwalne odnośnie zmian cen produktów
CREATE TABLE changesproductprices (
	changesproductprices_id SERIAL PRIMARY KEY,
	old_price DECIMAL(10, 2),
	new_price DECIMAL(10, 2),
	product_id INTEGER,
	created_at TIMESTAMP,
	FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Testowanie triggera
SELECT * FROM products ORDER BY product_id;
UPDATE products SET price = price - 100 WHERE product_id = 87;
SELECT * FROM changesproductprices;
