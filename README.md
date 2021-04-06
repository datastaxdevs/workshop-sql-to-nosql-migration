## 🎓🔥 From SQL to NoSQL, a migration path

[![License Apache2](https://img.shields.io/hexpm/l/plug.svg)](http://www.apache.org/licenses/LICENSE-2.0)
[![Discord](https://img.shields.io/discord/685554030159593522)](https://discord.com/widget?id=685554030159593522&theme=dark)

![image](https://user-images.githubusercontent.com/23346205/113427767-9f824880-93a3-11eb-8461-3689a13882a6.jpeg?raw=true)

## Materials for the Session

It doesn't matter if you join our workshop live or you prefer to do at your own pace, we have you covered. In this repository, you'll find everything you need for this workshop:

- [Workshop video](#)
- [Slide deck](./slides.pdf)
- [Discord chat](https://bit.ly/cassandra-workshop)
- [Questions and Answers](https://community.datastax.com/)

## Table of content

1. [Create your Astra Instance](#1-create-your-astra-instance)
2. [Create petclinic NoSQL data model](#2-create-petclinic-nosql-data-model)
3. [Load data into Astra with DSBulk](#3-load-data-into-astra-with-dsbulk)

## 1. Create your Astra instance

`ASTRA` service is available at url [https://astra.datastax.com](https://dtsx.io/workshop). `ASTRA` is the simplest way to run Cassandra with zero operations at all - just push the button and get your cluster. No credit card required, $25.00 USD credit every month, roughly 5M writes, 30M reads, 40GB storage monthly - sufficient to run small production workloads.

**✅ Step 1a. Register (if needed) and Sign In to Astra** : You can use your `Github`, `Google` accounts or register with an `email`.

Make sure to chose a password with minimum 8 characters, containing upper and lowercase letters, at least one number and special character

- [Registration Page](https://dtsx.io/workshop)

![Registration Image](images/astra-create-register.png?raw=true)

- [Authentication Page](https://dtsx.io/workshop)

![Login Image](images/astra-create-login.png?raw=true)


**✅ Step 1b. Create a "pay as you go" plan**

Follow this [guide](https://docs.datastax.com/en/astra/docs/creating-your-astra-database.html) and use the values provided below, to set up a pay as you go database with a free $25 monthly credit.

| Parameter | Value 
|---|---|
| Database name | sql_to_nosql_db |
| Keyspace name | spring_petclinic |

## 2. Create petclinic NoSQL data model
Ok, now that you have a database created the next step is to create a table to work with. 

**✅ Step 2a. Navigate to the CQL Console and login to the database**

In the Summary screen for your database, select **_CQL Console_** from the top menu in the main window. This will take you to the CQL Console and automatically log you in.


**✅ Step 2b. Describe keyspaces and USE killrvideo**

Ok, now we're ready to rock. Creating tables is quite easy, but before we create one we need to tell the database which keyspace we are working with.

First, let's **_DESCRIBE_** all of the keyspaces that are in the database. This will give us a list of the available keyspaces.

📘 **Command to execute**
```
desc KEYSPACES;
```
_"desc" is short for "describe", either is valid_

📗 **Expected output**

<img width="1000" alt="Screenshot 2020-09-30 at 13 54 55" src="https://user-images.githubusercontent.com/20337262/94687725-8cbf8600-0324-11eb-83b0-fbd3d7fbdadc.png">

Depending on your setup you might see a different set of keyspaces then in the image. The one we care about for now is **_spring_petclinic_**. From here, execute the **_USE_** command with the **_spring_petclinic_** keyspace to tell the database our context is within **_spring_petclinic_**.

📘 **Command to execute**
```
use spring_petclinic;
```

📗 **Expected output**

<img width="1000" alt="Screenshot 2020-09-30 at 13 55 56" src="https://user-images.githubusercontent.com/20337262/94687832-b082cc00-0324-11eb-885a-d44e127cf9be.png">

Notice how the prompt displays ```KVUser@cqlsh:spring_petclinic>``` informing us we are **using** the **_spring_petclinic_** keyspace. Now we are ready to create our table.

**✅ 2c. Create tables**

- *Execute the following Cassandra Query Language* 

```sql
use spring_petclinic;

DROP INDEX IF EXISTS petclinic_idx_vetname;
DROP INDEX IF EXISTS petclinic_idx_ownername;
DROP TABLE IF EXISTS petclinic_vet;
DROP TABLE IF EXISTS petclinic_vet_by_specialty;
DROP TABLE IF EXISTS petclinic_reference_lists;
DROP TABLE IF EXISTS petclinic_owner;
DROP TABLE IF EXISTS petclinic_pet_by_owner;
DROP TABLE IF EXISTS petclinic_visit_by_pet;

/** A vet can have multiple specialties. */
CREATE TABLE IF NOT EXISTS petclinic_vet (
  id          uuid,
  first_name  text,
  last_name   text,
  specialties set<text>,
  PRIMARY KEY ((id))
);


/** We could search veterinarian by their names. */
CREATE INDEX IF NOT EXISTS petclinic_idx_vetname ON petclinic_vet(last_name);

/** We may want to list all radiologists. */
CREATE TABLE IF NOT EXISTS petclinic_vet_by_specialty (
 specialty   text,
 vet_id      uuid,
 first_name  text,
 last_name   text,
 PRIMARY KEY ((specialty), vet_id)
);

/** 
 * Here we want all values on a single node, avoiding full scan. 
 * We pick am unordered set to avoid duplication, list to be sorted at ui side. 
 */
CREATE TABLE IF NOT EXISTS petclinic_reference_lists (
  list_name text,
  values set<text>,
  PRIMARY KEY ((list_name))
);

/** Expecting a combobox list references all specialties. */
INSERT INTO petclinic_reference_lists(list_name, values) 
VALUES ('vet_specialty', {'radiology', 'dentistry', 'surgery'});

CREATE TABLE IF NOT EXISTS petclinic_owner (
  id         uuid,
  first_name text,
  last_name  text,
  address    text,
  city       text,
  telephone  text,
  PRIMARY KEY ((id))
);

/** We could search veterinarians by their names. */
CREATE INDEX IF NOT EXISTS petclinic_idx_ownername ON petclinic_owner(last_name);

CREATE TABLE IF NOT EXISTS petclinic_pet_by_owner (
  owner_id   uuid,
  pet_id     uuid,
  pet_type   text,
  name       text,
  birth_date date,
  PRIMARY KEY ((owner_id), pet_id)
);
CREATE TABLE IF NOT EXISTS petclinic_visit_by_pet (
   pet_id      uuid,
   visit_id    uuid,
   visit_date  date,
   description text,
   PRIMARY KEY ((pet_id), visit_id)
);

INSERT INTO petclinic_reference_lists(list_name, values) 
VALUES ('pet_type ', {'bird', 'cat', 'dog', 'lizard','hamster','snake'});
```

- *Visualize structure*
```sql
describe keyspace spring_petclinic;
```

[🏠 Back to Table of Contents](#table-of-content)

## 3. Transform and load data with DSBulk

https://docs.datastax.com/en/astra/docs/loading-and-unloading-data-with-datastax-bulk-loader.html#_prerequisites

```shell
```shell
dsbulk load \
-url ../owner.csv \
-b ../creds.zip \
-u <<YOUR CLIENT ID>> \
-p <<YOUR CLIENT SECRET>> \
-query "INSERT INTO spring_petclinic.petclinic_owner (first_name, last_name, address, city, telephone, id) VALUES (:first_name,:last_name,:address,:city,:telephone,UUID())" \
-header true \
-delim ';'
```

## THE END

Congratulation your made it to the END.


