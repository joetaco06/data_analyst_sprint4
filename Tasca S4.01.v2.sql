# NIVEL 1 : 
# Descargar los archivos CSV, estudiar y diseñar una base de datos con un esquema de estrella que contenga
# al menos 4 tablas de las que se pueda realizar algunas consultas.

# Creando la BD:

create database transactionsTS4;
use transactionsTS4; 

# Creando las tablas:

create table companies (
	company_id varchar(10) unique,
    company_name varchar(255),
    phone varchar(20),
    email varchar(60),
    country varchar(60),
    website varchar(60),
    primary key (company_id)
		);

create table credit_cards (
	id varchar(15),
    user_id varchar(10),
    iban varchar(50),
    pan varchar(50), 
    pin varchar(4),
    cvv varchar(3),
    track1 varchar(60),
    track2 varchar(60),
    expiring_date varchar(10),
    primary key (id)
		);
        
        
create table users (
	id int,
    name varchar(60),
    surname varchar(60),
    phone varchar(15),
    email varchar(60),
    birth_date varchar(30),
    country varchar(60),
    city varchar(60),
    postal_code varchar(15),
    address varchar(250),
    primary key (id)
		);

create table transactions (
	id varchar(255),
    card_id varchar(15),
    business_id varchar(15),
    timestamp varchar(35),
    amount decimal(15,2),
    declined boolean,
    product_ids varchar(25),
    user_id int,
    lat varchar(60),
    longitude varchar(60),
    primary key (id),
    foreign key (card_id) references credit_cards(id),
    foreign key (business_id) references companies (company_id),
    foreign key (user_id) references users(id)
		);
    
# Insertando la data de los archivos CSV: 

set global local_infile = 'ON';


LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# * Inicialmente nos da error, ya que debemos subir el archivo desde una carpeta "segura" predeterminada por el mysql.
# Identificamos cual es la carpeta y subimos desde allí todos los archivos restantes.

show variables like 'secure_file_priv';

# Nos arroja que la carpeta "segura" sería la siguiente: "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv" 


SET GLOBAL group_concat_max_len = 10000;

SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv"
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv"
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv"
INTO TABLE users
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS = 1;


/* Ejercicio 1.1 : Realizar una subconsulta que muestre a todos los usuarios con más de 30 transacciones
   utilizando al menos 2 tablas  */
   
# Para la query solicitada utilizamos el mínimo de tablas necesarias, es decir, users y transactions:
   
SELECT users.id, users.name, users.surname, country, city, COUNT(transactions.id) AS num_trans
FROM users
JOIN transactions
ON users.id = transactions.user_id
GROUP BY users.id
HAVING num_trans >= 30
ORDER BY num_trans DESC
;

/* Ejercicio 1.2 : Mostrar la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., 
utiliza por lo menos 2 tablas.  */

# Para la siguiente query requerimos incluir una tercera tabla que contenga información de iban, por lo que terminaremos usando
# las tablas transactions, credit_cards y companies.

select transactions.business_id, credit_cards.iban, avg(transactions.amount) as med_transac
from transactions
join credit_cards on transactions.card_id = credit_cards.id
join companies on companies.company_id = transactions.business_id
where company_name = "Donec Ltd"
group by transactions.business_id, credit_cards.iban;
