import pandas as pd
import random
import os
import faker
import numpy as np
import psycopg2

# CLASS TABLES SQL
class products:
    def __init__(self, product_id, name, category, price, stock):
        self.product_id = product_id
        self.name = name
        self.category = category
        self.price = price
        self.stock = stock

class shops:
    def __init__(self, shop_id, name, city, address):
        self.shop_id = shop_id
        self.name = name
        self.city = city
        self.address = address

class clients:
    def __init__(self, client_id, first_name, last_name, email, created_at):
        self.client_id = client_id
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.created_at = created_at

class employees:
    def __init__(self, employee_id, first_name, last_name, salary, shop_id, created_at):
        self.employee_id = employee_id
        self.first_name = first_name
        self.last_name = last_name
        self.salary = salary
        self.shop_id = shop_id
        self.created_at = created_at

    def __str__(self):
        return f'employee_id: {self.employee_id}, first_name: {self.first_name}, last_name: {self.last_name}, salary: {self.salary}, shop_id: {self.shop_id}, created_at: {self.created_at}'

    def __repr__(self):
        return '{' + self.__str__() + '}'

class shoppingcarts:
    def __init__(self, shoppingcart_id, total_amount, date_of_purchase, client_id, shop_id):
        self.shoppingcart_id = shoppingcart_id
        self.total_amount = total_amount
        self.date_of_purchase = date_of_purchase
        self.client_id = client_id
        self.shop_id = shop_id

class purchasedproducts:
    def __init__(self, purchasedproduct_id, price, quantity, product_id, shoppingcart_id):
        self.purchasedproduct_id = purchasedproduct_id
        self.price = price
        self.quantity = quantity
        self.product_id = product_id
        self.shoppingcart_id = shoppingcart_id

# FUNCTIONS TO GENERATE DATA
# https://stackoverflow.com/questions/13148429/how-to-change-the-order-of-dataframe-columns
def generate_products(products_list, path):
    df = pd.DataFrame(products_list)
    df['product_id'] = df.index + 1
    df = df[['product_id', 'name', 'category', 'price']]
    df['stock'] = [random.randint(0, 2000) for _ in range(len(df))]
    print(df)
    print(str(tuple(df.columns.values)).replace("'", ""))

    if not os.path.exists(path):
        os.makedirs(path)
    df.to_csv('csv_files/products.csv', index=None, header=True, sep=';')

# https://stackoverflow.com/questions/34065361/python-class-attributes-to-pandas-dataframe
def generate_shops(shops_list, path):
    df = pd.DataFrame([vars(shops) for shops in shops_list])
    print(df)

    if not os.path.exists(path):
        os.makedirs(path)
    df.to_csv(f'{path}/shops.csv', index=None, header=True, sep=';')

# https://www.analyticsvidhya.com/blog/2021/09/how-to-create-dummy-data-in-python-using-faker-package/
# https://www.geeksforgeeks.org/python/create-a-pandas-dataframe-from-lists/
def generate_clients(n, path):
    f = faker.Faker()
    emails = [f.unique.email() for _ in range(n)]
    first_names = [f.first_name() for _ in range(n)]
    last_names = [f.last_name() for _ in range(n)]
    date_time = [f.unique.date_time_between(start_date='-10y', end_date='-1d') for _ in range(n)]
    print(emails)
    print(first_names)
    print(last_names)
    print(date_time)
    clients = {'first_name': first_names, 'last_name': last_names, 'email': emails, 'created_at': date_time}

    df = pd.DataFrame(clients)
    df['client_id'] = [index + 1 for index in range(1000)]
    cols = list(df)
    cols = [cols[-1]] + cols[:-1]
    df = df[cols]
    print(df)

    if not os.path.exists(path):
        os.makedirs(path)
    df.to_csv(f'{path}/clients.csv', index=None, header=True, sep=';')

def generate_employees(n, path):
    f = faker.Faker()
    first_names = [f.first_name() for _ in range(n)]
    last_names = [f.last_name() for _ in range(n)]
    date_time = [f.unique.date_time_between(start_date='-10y', end_date='-1d') for _ in range(n)]
    salaries = random.choices(range(3000, 15001, 50), k=n)
    shop_ids = random.choices(range(1, 6), k=n)

    employees_list = []
    for index, first_name, last_name, salary, shop_id, created_at in zip(range(n), first_names, last_names, salaries, shop_ids, date_time):
        tmp = employees(
            employee_id = index + 1,
            first_name = first_name,
            last_name = last_name,
            salary = salary,
            shop_id = shop_id,
            created_at = created_at
        )
        employees_list.append(tmp)
    print(employees_list)

    df = pd.DataFrame([vars(employees) for employees in employees_list])
    print(df)

    if not os.path.exists(path):
        os.makedirs(path)
    df.to_csv(f'{path}/employees.csv', index=None, header=True, sep=';')

# https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.html
# https://stackoverflow.com/questions/61392258/most-efficient-method-to-concatenate-strings-in-python
def generate_shoppingcarts(n, path, n_clients):
    f = faker.Faker()

    df = pd.DataFrame(data=[[index, None, ''.join((str(f.date_between(start_date='-10y', end_date='now')), ' ', ('0' + str(random.randint(9, 17)))[-2:], ':', ('0' + str(random.randint(0, 59)))[-2:], ':', ('0' + str(random.randint(0, 59)))[-2:])), random.choice(range(1, n_clients + 1)), random.choice(range(1, 6))] for index in range(1, n+1)], columns=['shoppingcart_id', 'total_amount', 'date_of_purchase', 'client_id', 'shop_id'])
    print(df)

    if not os.path.exists(path):
        os.makedirs(path)
    df.to_csv(f'{path}/shoppingcarts.csv', index=None, header=True, sep=';')

# https://www.geeksforgeeks.org/python/pandas-dataframe-to_dict/
def generate_purchasedproducts(n_shoppingcarts, path, products_list):
    df_tmp = pd.DataFrame(products_list)
    df_tmp['product_id'] = df_tmp.index + 1
    df_tmp = df_tmp[['product_id'] + [col for col in df_tmp.columns if col != 'product_id']]
    print(df_tmp)
    print(df_tmp.to_dict(orient='records'))

    purchasedproducts_list = []
    for index in range(n_shoppingcarts):
        n_purchasedproducts_in_shoppingcart = random.choices([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [50, 25, 10, 5, 3, 2.5, 2, 1.75, 0.5, 0.25])[0]
        products_drawn = random.choices(df_tmp.to_dict(orient='records'), k=n_purchasedproducts_in_shoppingcart)
        quantity_purchasedproducts = np.ceil(np.random.exponential(scale=1.5, size=(n_purchasedproducts_in_shoppingcart)))

        for product, quantity in zip(products_drawn, quantity_purchasedproducts):
            purchasedproducts_list.append([product['price'], int(quantity), product['product_id'], index + 1])

    df = pd.DataFrame(purchasedproducts_list, columns=['price', 'quantity', 'product_id', 'shoppingcart_id'])
    df['purchasedproduct_id'] = df.index + 1
    df.set_index(df.columns[-1], inplace=True)
    df.reset_index(inplace=True)
    print(df)

    if not os.path.exists(path):
        os.makedirs(path)
    df.to_csv(f'{path}/purchasedproducts.csv', index=None, header=True, sep=';')

# INSERT DATA TO DATABASE POSTGRESQL
# https://www.geeksforgeeks.org/python/insert-python-list-into-postgresql-database/
# https://stackoverflow.com/questions/16476924/how-can-i-iterate-over-rows-in-a-pandas-dataframe
# https://www.w3schools.com/python/python_try_except.asp
def postgresql_insert_data(file, table_name):
    conn = psycopg2.connect(
        database='FirstProjectShop',
        user='postgres',
        password='password',
        host='localhost',
        port='5432'
    )

    cursor = conn.cursor()

    df = pd.read_csv(file, sep=';')
    try:
        for index, row in df.iterrows():
            query = f'INSERT INTO {table_name}{str(tuple(df.columns.values)).replace("'", "")} VALUES {str(('%s',) * len(df.columns)).replace("'", "")}'
            row_values = tuple(round(float(x), 2) if isinstance(x, (float, np.float64)) else x for x in tuple(row.values))
            print(query)
            print(row_values)
            cursor.execute(query, row_values)

        print(f'Successfully loaded data into postgresql database in {table_name} table!!!')
    except:
        print(f'An exception occured in the {table_name} table!!!')

    conn.commit()
    conn.close()

if __name__ == '__main__':
    products_list = [
        {'name': 'SAMSUNG Galaxy A56', 'category': 'Smartphone', 'price': 1600},
        {'name': 'MOTOROLA Moto G86', 'category': 'Smartphone', 'price': 1200},
        {'name': 'REALME 14 Pro+', 'category': 'Smartphone', 'price': 2200},
        {'name': 'SAMSUNG Galaxy A36', 'category': 'Smartphone', 'price': 1200},
        {'name': 'APPLE iPhone 16 Pro Max', 'category': 'Smartfon', 'price': 7690},
        {'name': 'HUAWEI Mate X6', 'category': 'Smartfon', 'price': 7300},
        {'name': 'SAMSUNG Galaxy S25 Ultra', 'category': 'Smartfon', 'price': 6999},
        {'name': 'ASUS Rog Phone 9 Pro', 'category': 'Smartfon', 'price': 6499},
        {'name': 'GOOGLE Pixel 9 Pro XL', 'category': 'Smartfon', 'price': 6099},
        {'name': 'XIAOMI 15 Ultra', 'category': 'Smartfon', 'price': 5999},
        {'name': 'MOTOROLA Razr 60 Ultra', 'category': 'Smartfon', 'price': 5690},
        {'name': 'APPLE iPhone 15', 'category': 'Smartfon', 'price': 5353},
        {'name': 'ONEPLUS 13', 'category': 'Smartfon', 'price': 4199},
        {'name': 'APPLE iPhone 14 Plus', 'category': 'Smartfon', 'price': 3999},
        {'name': 'REALME GT 7', 'category': 'Smartfon', 'price': 3999},
        {'name': 'GOOGLE Pixel 8', 'category': 'Smartfon', 'price': 3899},
        {'name': 'VIVO X200 FE', 'category': 'Smartfon', 'price': 3799},
        {'name': 'HUAWEI Pura 70', 'category': 'Smartfon', 'price': 2999},
        {'name': 'MOTOROLA Edge 60 Pro', 'category': 'Smartfon', 'price': 2499},
        {'name': 'MYPHONE Hammer Construction 2', 'category': 'Smartfon', 'price': 2399},
        {'name': 'INFINIX Zero 40', 'category': 'Smartfon', 'price': 2369},
        {'name': 'DOOGEE V31 GT', 'category': 'Smartfon', 'price': 2299},
        {'name': 'ULEFONE Armor 27T Pro', 'category': 'Smartfon', 'price': 2259},
        {'name': 'HONOR 400', 'category': 'Smartfon', 'price': 1799},
        {'name': 'XIAOMI Poco F6 Pro', 'category': 'Smartfon', 'price': 1799},
        {'name': 'IIIF150 B3 Pro', 'category': 'Smartfon', 'price': 1699},
        {'name': 'OPPO Reno 12', 'category': 'Smartfon', 'price': 1699},
        {'name': 'CUBOT X90', 'category': 'Smartfon', 'price': 1199},
        {'name': 'MOTOROLA ThinkPhone', 'category': 'Smartfon', 'price': 1199},
        {'name': 'ULEFONE Armor 22', 'category': 'Smartfon', 'price': 949},
        {'name': 'MEIZU Note 21 Pro', 'category': 'Smartfon', 'price': 899},
        {'name': 'ONEPLUS Nord CE 4 Lite', 'category': 'Smartfon', 'price': 899.99},
        {'name': 'SAMSUNG Galaxy A26 5G', 'category': 'Smartfon', 'price': 899},
        {'name': 'NUBIA Neo 2', 'category': 'Smartfon', 'price': 899},
        {'name': 'TCL 40 Nxtpaper', 'category': 'Smartfon', 'price': 699.99},
        {'name': 'CUBOT King Kong Ace 2', 'category': 'Smartfon', 'price': 649.99},
        {'name': 'KRUGER&MATZ Live 12', 'category': 'Smartfon', 'price': 509.99},
        {'name': 'REALME Note 60', 'category': 'Smartfon', 'price': 399.99},
        {'name': 'MEIZU Mblu 21', 'category': 'Smartfon', 'price': 299.99},
        {'name': 'TCL 501', 'category': 'Smartfon', 'price': 199.99},
        {'name': 'ASUS TUF Gaming A15', 'category': 'Laptop', 'price': 3999},
        {'name': 'PREDATOR Helios 18', 'category': 'Laptop', 'price': 26899},
        {'name': 'ASUS ROG Strix Scar 18', 'category': 'Laptop', 'price': 23999},
        {'name': 'RAZER Blade 14', 'category': 'Laptop', 'price': 9499},
        {'name': 'MSI Alpha', 'category': 'Laptop', 'price': 7399.99},
        {'name': 'LENOVO LOQ', 'category': 'Laptop', 'price': 5699.99},
        {'name': 'DELL G15', 'category': 'Laptop', 'price': 5559},
        {'name': 'HP Victus', 'category': 'Laptop', 'price': 5499.99},
        {'name': 'ACER Nitro V 14', 'category': 'Laptop', 'price': 5299},
        {'name': 'MSI Katana 17', 'category': 'Laptop', 'price': 5199.99},
        {'name': 'ASUS TUF Gaming F15', 'category': 'Laptop', 'price': 4599.99},
        {'name': 'MSI Cyborg', 'category': 'Laptop', 'price': 4599},
        {'name': 'ASUS TUF Gaming A15', 'category': 'Laptop', 'price': 4299.99},
        {'name': 'ASUS TUF Gaming A15', 'category': 'Laptop', 'price': 3099.99},
        {'name': 'ACER Chromebook Plus 514', 'category': 'Laptop', 'price': 2599},
        {'name': 'ASUS Vivobook 15', 'category': 'Laptop', 'price': 2299},
        {'name': 'LENOVO IdeaPad 3', 'category': 'Laptop', 'price': 1999},
        {'name': 'MAXCOM Office mBook 14', 'category': 'Laptop', 'price': 1599.99},
        {'name': 'CHUWI HeroBook Pro', 'category': 'Laptop', 'price': 1199.99},
        {'name': 'TECHBITE Zin 5', 'category': 'Laptop', 'price': 854.42},
        {'name': 'KRUGER&MATZ Edge', 'category': 'Laptop', 'price': 839},
        {'name': 'APPLE AirPods Max', 'category': 'Headphones', 'price': 2215.07},
        {'name': 'FIIO FH5S', 'category': 'Headphones', 'price': 1299},
        {'name': 'JBL Tour Pro 3', 'category': 'Headphones', 'price': 1249},
        {'name': 'BEYERDYNAMIC Amiron 300', 'category': 'Headphones', 'price': 1059},
        {'name': 'JBL Tour Pro 2', 'category': 'Headphones', 'price': 999},
        {'name': 'JABRA Engage 50 II', 'category': 'Headphones', 'price': 847.43},
        {'name': 'APPLE AirPods Pro II', 'category': 'Headphones', 'price': 1029},
        {'name': 'XIAOMI Buds 5', 'category': 'Headphones', 'price': 344.17},
        {'name': 'SKULLCANDY Sesh Active', 'category': 'Headphones', 'price': 307},
        {'name': 'APPLE AirPods 4', 'category': 'Headphones', 'price': 799},
        {'name': 'MARSHALL Minor IV', 'category': 'Headphones', 'price': 299},
        {'name': 'ONEODIO OpenRock Pro', 'category': 'Headphones', 'price': 299},
        {'name': 'SOUNDPEATS OPERA05', 'category': 'Headphones', 'price': 298.8},
        {'name': 'DEFUNC Mondo', 'category': 'Headphones', 'price': 271},
        {'name': 'HYPERX Cloud III', 'category': 'Headphones', 'price': 249},
        {'name': 'GUESS GUTWSPGTSPSK', 'category': 'Headphones', 'price': 221},
        {'name': 'WEOFLY LifeFits', 'category': 'Headphones', 'price': 179},
        {'name': 'TOZO T12S', 'category': 'Headphones', 'price': 149},
        {'name': 'HAMA Spirit Calypso III', 'category': 'Headphones', 'price': 149},
        {'name': 'SAMSUNG EO-IA500', 'category': 'Headphones', 'price': 49.99},
        {'name': 'CANYON SEP-5', 'category': 'Headphones', 'price': 39.99},
        {'name': 'AUDEEO AO-EP2', 'category': 'Headphones', 'price': 19.99},
        {'name': 'SENCOR SEP 120', 'category': 'Headphones', 'price': 14},
        {'name': 'USAMS EP-39', 'category': 'Headphones', 'price': 9.98},
        {'name': 'LG 55QNED87T6B 55', 'category': 'TV', 'price': 2999},
        {'name': 'SAMSUNG QE65Q74D', 'category': 'TV', 'price': 3199},
        {'name': 'PHILIPS 55PML9059', 'category': 'TV', 'price': 3299},
        {'name': 'HISENSE 65U8NQ', 'category': 'TV', 'price': 5499.99},
        {'name': 'HISENSE 110UXNQ', 'category': 'TV', 'price': 74999.99},
        {'name': 'LG 83M49LA', 'category': 'TV', 'price': 39999},
        {'name': 'TCL 98P89K', 'category': 'TV', 'price': 9999.99},
        {'name': 'SAMSUNG QE77S85F', 'category': 'TV', 'price': 9999.99},
        {'name': 'LG 65B56LA', 'category': 'TV', 'price': 7999},
        {'name': 'SONY XR-75X90L', 'category': 'TV', 'price': 6499},
        {'name': 'LG 55C45LA', 'category': 'TV', 'price': 4999},
        {'name': 'SAMSUNG QE65Q8FA', 'category': 'TV', 'price': 3699},
        {'name': 'LG 50QNED80A6A', 'category': 'TV', 'price': 3099},
        {'name': 'XIAOMI S Mini 2025', 'category': 'TV', 'price': 2499},
        {'name': 'TCL 65P755', 'category': 'TV', 'price': 2199.99},
        {'name': 'HISENSE 65A6N', 'category': 'TV', 'price': 2199},
        {'name': 'JVC LT-55VG7400', 'category': 'TV', 'price': 1599.99},
        {'name': 'PHILIPS 43PUS8209', 'category': 'TV', 'price': 1599},
        {'name': 'KIVI 43U760QW', 'category': 'TV', 'price': 1199},
        {'name': 'SHARP 43GL4760E', 'category': 'TV', 'price': 1199.99},
        {'name': 'HYUNDAI FLM40TS349SMART', 'category': 'TV', 'price': 999.99},
        {'name': 'GOGEN TVF40M340', 'category': 'TV', 'price': 989},
        {'name': 'KRUGER&MATZ KM0232-S6', 'category': 'TV', 'price': 799.99},
        {'name': 'XIAOMI A 2025 32', 'category': 'TV', 'price': 639},
        {'name': 'OPTICUM Trivio 32Z3', 'category': 'TV', 'price': 469},
        {'name': 'LIN 24LHDD06', 'category': 'TV', 'price': 369},
        {'name': 'KIANO Slim 19 Travel 19', 'category': 'TV', 'price': 349},
        {'name': 'DJI Mini 4 Pro Fly More Combo (RC 2)', 'category': 'Drone', 'price': 4345},
        {'name': 'FIMI X8 Mini 3', 'category': 'Drone', 'price': 1699.99},
        {'name': 'OVERMAX X-Bee Drone 9.5 Fold', 'category': 'Drone', 'price': 627.3},
        {'name': 'EXTRALINK Smart Life F10', 'category': 'Drone', 'price': 299},
        {'name': 'HISENSE RB5P410SAFC', 'category': 'Fridge', 'price': 3199.99},
        {'name': 'SHARP SJ-UE121T0S-EU', 'category': 'Fridge', 'price': 799},
        {'name': 'GORENJE RF414EPS4', 'category': 'Fridge', 'price': 1199.99},
        {'name': 'BEKO TSE1284N', 'category': 'Fridge', 'price': 869},
        {'name': 'AMICA FM107.4', 'category': 'Fridge', 'price': 743},
        {'name': 'LIN LI-BC55', 'category': 'Fridge', 'price': 389},
        {'name': 'CANON EOS 2000D', 'category': 'Camera', 'price': 2199},
        {'name': 'OLYMPUS OM System TG-7', 'category': 'Camera', 'price': 2189}
    ]

    shops_list = [
        shops(1, 'sklep AGDDD', 'Warszawa', 'pl. Kępa 5/6'),
        shops(2, 'sklep elektroniczny IDEA', 'Kraków', 'al. Nowaczyk 666'),
        shops(3, 'XCRT', 'Poznań', 'wyb. Marcinkowski 063'),
        shops(4, 'X-SELL', 'Toruń', 'bulw. Słowiński 81a'),
        shops(5, 'GAMING X-MALL', 'Katowice', 'pl. Kula 70c')
    ]

    path = 'csv_files'
    # generate_products(products_list, path)
    # generate_shops(shops_list, path)
    # generate_clients(n=1000, path=path)
    # generate_employees(150, path)
    # generate_shoppingcarts(10000, path, 1000)
    # generate_purchasedproducts(10000, path, products_list)

    postgresql_insert_data(os.path.join(path, 'products.csv'), 'products')
    postgresql_insert_data(os.path.join(path, 'shops.csv'), 'shops')
    postgresql_insert_data(os.path.join(path, 'clients.csv'), 'clients')
    postgresql_insert_data(os.path.join(path, 'employees.csv'), 'employees')
    postgresql_insert_data(os.path.join(path, 'shoppingcarts.csv'), 'shoppingcarts')
    postgresql_insert_data(os.path.join(path, 'purchasedproducts.csv'), 'purchasedproducts')

    