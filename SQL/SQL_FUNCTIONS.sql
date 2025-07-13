-- 1. Funkcja zwracająca średnią wartość koszyka dla danego sklepu
CREATE OR REPLACE FUNCTION avg_shoppingcart_for_shop(arg_shop_id INT)
RETURNS NUMERIC AS $$
DECLARE
	avg_result NUMERIC;
BEGIN
	SELECT AVG(purchasedproducts.price * purchasedproducts.quantity) INTO avg_result
	FROM purchasedproducts
	INNER JOIN shoppingcarts ON shoppingcarts.shoppingcart_id = purchasedproducts.shoppingcart_id
	WHERE shoppingcarts.shop_id = arg_shop_id;

	RETURN avg_result;
END;
$$ LANGUAGE plpgsql;

-- Wywołanie funkcji
SELECT avg_shoppingcart_for_shop(1);

-- Usunięcie funkcji
DROP FUNCTION IF EXISTS avg_shoppingcart_for_shop(INT);

-- 2. Funkcja zwracająca liczbę sprzedanych produktów w podanej kategorii
CREATE OR REPLACE FUNCTION number_of_product_sold_for_category(arg_category TEXT)
RETURNS INT AS $$
DECLARE
	number_of_products INT;
BEGIN
	SELECT SUM(purchasedproducts.quantity) INTO number_of_products
	FROM purchasedproducts
	INNER JOIN products ON purchasedproducts.product_id = products.product_id
	WHERE products.category = arg_category;

	RETURN number_of_products;
END;
$$ LANGUAGE plpgsql;

-- Wywołanie funkcji
SELECT number_of_product_sold_for_category('TV');

-- Usunięcie funkcji
DROP FUNCTION IF EXISTS number_of_product_sold_for_category(TEXT);

-- 3. Funkcja zwracająca najnowszy koszyk zakupowy utworzony przez danego klienta (jako jeden rekord)
CREATE OR REPLACE FUNCTION latest_created_shoppingcart_by_client(arg_client_id INT)
RETURNS RECORD AS $$
DECLARE
	row_shoppingcart RECORD;
BEGIN
	SELECT * INTO row_shoppingcart
	FROM shoppingcarts
	WHERE client_id = arg_client_id
	ORDER BY date_of_purchase DESC
	LIMIT 1;

	RETURN row_shoppingcart;
END;
$$ LANGUAGE plpgsql;

-- Wywołanie funkcji
SELECT latest_created_shoppingcart_by_client(1);

-- Usunięcie funkcji
DROP FUNCTION IF EXISTS latest_created_shoppingcart_by_client(INT);

-- Funkcja zwracająca najnowszy koszyk zakupowy utworzony przez danego klienta (jako wiersz tabeli)
CREATE OR REPLACE FUNCTION latest_created_shoppingcart_by_client2(arg_client_id INT)
RETURNS TABLE(shoppingcart_id INT, total_amount NUMERIC, date_of_purchase TIMESTAMP, client_id INT, shop_id INT) AS $$
BEGIN
	RETURN QUERY
	SELECT *
	FROM shoppingcarts
	WHERE shoppingcarts.client_id = arg_client_id
	ORDER BY date_of_purchase DESC
	LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Wywołanie funkcji
SELECT * FROM latest_created_shoppingcart_by_client2(1);

-- Usunięcie funkcji
DROP FUNCTION IF EXISTS latest_created_shoppingcart_by_client2(INT);
