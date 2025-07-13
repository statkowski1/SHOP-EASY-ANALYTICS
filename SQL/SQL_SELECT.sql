-- 1. Proste wyświetlenie tabel z bazy SQL
SELECT * FROM products;
SELECT * FROM shops;
SELECT * FROM clients;
SELECT * FROM employees;
SELECT * FROM shoppingcarts;
SELECT * FROM purchasedproducts;

-- 2. Produkty z 1500 większą lub równą ilością w magazynie
SELECT * FROM products WHERE stock >= 1500;

-- 3. Nazwa i cena produktu kategorii Headphones
SELECT name, price FROM products WHERE category = 'Headphones';

-- 4. Produkty z ceną wyższą niż 1000
SELECT * FROM products WHERE price > 1000;

-- 5. Wszystkie sklepy w mieście Warszawa
SELECT * FROM shops WHERE city = 'Warszawa';

-- 6. Klienci utworzeni od roku 2024 posortowani według daty
SELECT * FROM clients WHERE created_at >= '2024-01-01 00:00:00' ORDER BY created_at;

-- 7. Wyświetlenie zakupionych produktów (tabela purchasedproducts) w połączeniu z nazwą z tabeli products
SELECT purchasedproducts.*, products.name FROM purchasedproducts INNER JOIN products ON purchasedproducts.product_id = products.product_id;
SELECT purchasedproducts.purchasedproduct_id, purchasedproducts.price, purchasedproducts.quantity, purchasedproducts.shoppingcart_id, products.name FROM purchasedproducts INNER JOIN products ON purchasedproducts.product_id = products.product_id;

-- 8. Klienci z przynajmniej jednym koszykiem zakupowym
SELECT DISTINCT shoppingcarts.client_id, clients.* FROM shoppingcarts INNER JOIN clients ON shoppingcarts.client_id = clients.client_id ORDER BY shoppingcarts.client_id;

-- 9. Najniższa cena dla każdej kategorii produktu
SELECT MIN(price), category FROM products GROUP BY category;

-- 10. Liczba produktów dla każdej kategorii
SELECT category, COUNT(*) AS quantity_in_category FROM products GROUP BY category ORDER BY quantity_in_category;

-- 11. Łączne zarobki dla każdego sklepu
SELECT shops.*, SUM(purchasedproducts.quantity * purchasedproducts.price) AS stores_earnings FROM shoppingcarts INNER JOIN purchasedproducts ON shoppingcarts.shoppingcart_id = purchasedproducts.shoppingcart_id INNER JOIN shops ON shops.shop_id = shoppingcarts.shop_id GROUP BY shops.shop_id ORDER BY stores_earnings;

-- 12. Klienci, którzy mają więcej niż 5 koszyków zakupowych
SELECT clients.*, COUNT(*) AS number_of_shoppingcarts FROM shoppingcarts INNER JOIN clients ON shoppingcarts.client_id = clients.client_id GROUP BY clients.client_id HAVING COUNT(*) > 5 ORDER BY number_of_shoppingcarts;

SELECT * FROM(
	SELECT clients.*, COUNT(*) AS number_of_shoppingcarts
	FROM shoppingcarts
	INNER JOIN clients ON shoppingcarts.client_id = clients.client_id
	GROUP BY clients.client_id
)
WHERE number_of_shoppingcarts > 5
ORDER BY number_of_shoppingcarts;

-- 13. Średnia cena dla każdej kategorii w tabeli produktów
SELECT category, AVG(price) FROM products GROUP BY category;

-- 14. Liczba pracowników dla poszczególnego sklepu
SELECT shops.*, COUNT(*) AS number_of_employees FROM shops INNER JOIN employees ON shops.shop_id = employees.shop_id GROUP BY shops.shop_id ORDER BY number_of_employees;

-- 15. Top 5 najlepiej sprzedających się produktów
SELECT products.*, SUM(purchasedproducts.quantity) AS number_of_products_sold FROM purchasedproducts INNER JOIN products ON purchasedproducts.product_id = products.product_id GROUP BY products.product_id ORDER BY number_of_products_sold DESC LIMIT 5;

-- 16. Koszyki zakupowe w roku 2025
SELECT * FROM shoppingcarts WHERE date_part('year', date_of_purchase) = '2025' ORDER BY date_of_purchase;

-- 17. Kategorie produktów ze sprzedażą przekraczającą 10000
SELECT * FROM(
	SELECT category, SUM(purchasedproducts.price * purchasedproducts.quantity) AS earnings_per_category
	FROM purchasedproducts
	INNER JOIN products ON purchasedproducts.product_id = products.product_id
	GROUP BY products.category
)
WHERE earnings_per_category > 10000
ORDER BY earnings_per_category DESC;

-- 18. Klienci, którzy niedokonali żadnych zakupów, czyli nie mają żadnego zrealizowanego koszyka zakupowego
SELECT * FROM(
	SELECT clients.*, COUNT(*) AS number_of_shoppingcarts
	FROM shoppingcarts
	INNER JOIN clients ON shoppingcarts.client_id = clients.client_id
	GROUP BY clients.client_id
)
WHERE number_of_shoppingcarts = 0;

-- 19. Klienci, którzy odwiedzili więcej niż 1 sklep
SELECT * FROM(
	SELECT clients.*, COUNT(DISTINCT shoppingcarts.shop_id) AS number_of_shops_visited
	FROM shoppingcarts
	INNER JOIN clients ON shoppingcarts.client_id = clients.client_id
	GROUP BY clients.client_id
)
WHERE number_of_shops_visited > 1
ORDER BY number_of_shops_visited;

-- 20. Liczba klientów według ilości odwiedzonych sklepów
SELECT number_of_shops_visited, COUNT(number_of_shops_visited) AS number_of_clients FROM(
	SELECT clients.*, COUNT(DISTINCT shoppingcarts.shop_id) AS number_of_shops_visited
	FROM shoppingcarts
	INNER JOIN clients ON shoppingcarts.client_id = clients.client_id
	GROUP BY clients.client_id
)
GROUP BY number_of_shops_visited
ORDER BY number_of_shops_visited;

-- 21. Średnia wartość koszyka zakupowego na każde miasto
SELECT shops.city, AVG(shoppingcart_value) AS avg_shoppingcart_per_city FROM(
	SELECT shoppingcarts.*, SUM(purchasedproducts.price * purchasedproducts.quantity) AS shoppingcart_value
	FROM shoppingcarts
	INNER JOIN purchasedproducts ON shoppingcarts.shoppingcart_id = purchasedproducts.shoppingcart_id
	GROUP BY shoppingcarts.shoppingcart_id
) AS tmp_table
INNER JOIN shops ON shops.shop_id = tmp_table.shop_id
GROUP BY shops.city
ORDER BY avg_shoppingcart_per_city;

-- 22. Klient, który kupił największą ilość Laptopów
SELECT clients.*, SUM(tmp_table1.quantity) number_of_laptops_purchased FROM(
	SELECT purchasedproducts.quantity, purchasedproducts.shoppingcart_id
	FROM purchasedproducts
	INNER JOIN products ON products.product_id = purchasedproducts.product_id
	WHERE products.category = 'Laptop'
) AS tmp_table1
INNER JOIN shoppingcarts ON shoppingcarts.shoppingcart_id = tmp_table1.shoppingcart_id
INNER JOIN clients ON clients.client_id = shoppingcarts.client_id
GROUP BY clients.client_id
ORDER BY number_of_laptops_purchased DESC LIMIT 1;
