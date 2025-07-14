-- 1. Procedura aktualizująca wartość total_amount w tabeli shoppingcarts na podstawie danych w tabeli purchasedproducts
CREATE OR REPLACE PROCEDURE update_total_amount_all_shoppingcarts()
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE shoppingcarts
	SET total_amount = tmp_table.total_amount
	FROM(
		SELECT shoppingcart_id, SUM(price * quantity) AS total_amount
		FROM purchasedproducts
		GROUP BY shoppingcart_id
	) AS tmp_table
	WHERE shoppingcarts.shoppingcart_id = tmp_table.shoppingcart_id;
END;
$$;

-- Wywołanie procedury
CALL update_total_amount_all_shoppingcarts();

-- Usunięcie procedury
DROP PROCEDURE update_total_amount_all_shoppingcarts();

-- 2. Procedura zmieniająca w tabeli products nazwę starej kategorii na nową (dodatkowo wypisuje wszystkie istniejące kategorie przed i po użyciu procedury)
CREATE OR REPLACE PROCEDURE change_category(old_category TEXT, new_category TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
	all_categories_before_change TEXT;
	all_categories_after_change TEXT;
BEGIN
	SELECT string_agg(DISTINCT category, ',') INTO all_categories_before_change
	FROM products;
	
	RAISE NOTICE 'Wszystkie kategorie przed zmianą: %', all_categories_before_change;
	
	UPDATE products
	SET category = new_category
	WHERE category = old_category;

	SELECT string_agg(DISTINCT category, ',') INTO all_categories_after_change
	FROM products;

	RAISE NOTICE 'Wszystkie kategorie po zmianie: %', all_categories_after_change;
END;
$$;

-- Wywołanie procedury
CALL change_category('Smartfon', 'Smartphone');

-- Usunięcie procedury
DROP PROCEDURE change_category(TEXT, TEXT);

-- 3. Procedura grupująca klientów w segmenty na podstawie ilości wydanych pieniędzy w sklepie w danym roku i wstawiająca te dane do nowej tabeli clientsegments
CREATE OR REPLACE PROCEDURE clientsegment_insert_data()
LANGUAGE plpgsql
AS $$
DECLARE
	tmp_record RECORD;
BEGIN
	TRUNCATE TABLE clientsegments;
	
	INSERT INTO clientsegments (segment, spent_at_year, summary_year, client_id)
	SELECT *
	FROM(
		SELECT 
			CASE
				WHEN tmp_table.spent_at_year >= 10000 THEN 'Premium'
				WHEN tmp_table.spent_at_year < 10000 AND tmp_table.spent_at_year >= 1500 THEN 'Standard'
				ELSE 'Nowy'
			END AS segment,
			tmp_table.spent_at_year, tmp_table.summary_year, tmp_table.client_id
		FROM(
			SELECT SUM(purchasedproducts.price * purchasedproducts.quantity) AS spent_at_year, EXTRACT(YEAR FROM shoppingcarts.date_of_purchase) AS summary_year, shoppingcarts.client_id
			FROM purchasedproducts
			INNER JOIN shoppingcarts ON shoppingcarts.shoppingcart_id = purchasedproducts.shoppingcart_id
			GROUP BY shoppingcarts.client_id, summary_year
			ORDER BY summary_year, shoppingcarts.client_id
		) AS tmp_table
	);

	FOR tmp_record IN
		SELECT summary_year, segment, COUNT(*) AS number_of_clients
		FROM clientsegments
		GROUP BY summary_year, segment
		ORDER BY summary_year, segment
	LOOP
		RAISE NOTICE 'Rok: %, Segment: %, Liczba klientów: %', tmp_record.summary_year, tmp_record.segment, tmp_record.number_of_clients;
	END LOOP;
END;
$$;

-- Wywołanie procedury
CALL clientsegment_insert_data();

-- Usunięcie procedury
DROP PROCEDURE clientsegment_insert_data();

-- Tabela clientsegments utworzona na potrzeby powyższej procedury (3)
CREATE TABLE clientsegments (
	clientsegment_id SERIAL PRIMARY KEY,
	segment VARCHAR(50),
	spent_at_year DECIMAL(10, 2),
	summary_year VARCHAR(4),
	client_id INTEGER,
	FOREIGN KEY (client_id) REFERENCES clients(client_id)
);
