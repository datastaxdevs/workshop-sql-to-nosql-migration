## 🎓🔥 From SQL to NoSQL, a migration path

[![License Apache2](https://img.shields.io/hexpm/l/plug.svg)](http://www.apache.org/licenses/LICENSE-2.0)
[![Discord](https://img.shields.io/discord/685554030159593522)](https://discord.com/widget?id=685554030159593522&theme=dark)

![image](https://user-images.githubusercontent.com/23346205/113427767-9f824880-93a3-11eb-8461-3689a13882a6.jpeg?raw=true)

## Materials for the Session

It doesn't matter if you join our workshop live or you prefer to do at your own pace, we have you covered. In this repository, you'll find everything you need for this workshop:

- [Workshop video](https://youtu.be/tNvBjY8izSk)
- [Slide deck](./slides.pdf)
- [Discord chat](https://bit.ly/cassandra-workshop)
- [Questions and Answers](https://community.datastax.com/)

## Table of content

1. [Create your Astra Instance](#1-create-your-astra-instance)
2. [Create petclinic NoSQL data model](#2-create-petclinic-nosql-data-model)
3. [Generate your Astra application token and service account](#3-generate-your-astra-application-token-and-service-account)
4. [Load data into Astra with DSBulk](#4-transform-and-load-data-with-dsbulk)

## 1. Create your Astra instance

`ASTRA` service is available at url [https://astra.datastax.com](https://dtsx.io/workshop). `ASTRA` is the simplest way to run Cassandra with zero operations at all - just push the button and get your cluster. **No credit card or any payment required**, $25.00 USD credit every month, roughly 5M writes, 30M reads, 40GB storage monthly - **sufficient to run small production workloads**.

### ✅ Step 1a. Register (if needed) and Sign In to Astra** : You can use your `Github`, `Google` accounts or register with an `email`.

Make sure to chose a password with minimum 8 characters, containing upper and lowercase letters, at least one number and special character

- [Registration Page](https://dtsx.io/workshop)

![Registration Image](https://user-images.githubusercontent.com/23346205/113758960-84387580-96e2-11eb-96dc-27448cf0d55f.png)

- [Authentication Page](https://dtsx.io/workshop)

![Login Image](https://user-images.githubusercontent.com/23346205/113758903-6ec34b80-96e2-11eb-990d-49e8a381cb6d.png)


### ✅ Step 1b. Create a "pay as you go" plan

Follow this [guide](https://docs.datastax.com/en/astra/docs/creating-your-astra-database.html) and use the values provided below, to set up a pay as you go database with a **FREE** $25 monthly credit.

| Parameter | Value 
|---|---|
| Database name | sql_to_nosql_db |
| Keyspace name | spring_petclinic |

## 2. Create petclinic NoSQL data model
Ok, now that you have a database created the next step is to create a tables to work with.

### ✅ Step 2a. Navigate to the CQL Console and login to the database

In the Summary screen for your database, select **_CQL Console_** from the top menu in the main window. This will take you to the CQL Console and automatically log you in.


### ✅ Step 2b. Describe keyspaces and USE killrvideo

Ok, now we're ready to rock. Creating tables is quite easy, but before we create one we need to tell the database which keyspace we are working with.

First, let's **_DESCRIBE_** all of the keyspaces that are in the database. This will give us a list of the available keyspaces.

📘 **Command to execute**
```
desc KEYSPACES;
```
_"desc" is short for "describe", either is valid_

📗 **Expected output**

![Screen Shot 2021-04-06 at 2 11 09 PM](https://user-images.githubusercontent.com/23346205/113758501-f5c3f400-96e1-11eb-8f40-4eb2c9b8c2c4.png)

Depending on your setup you might see a different set of keyspaces then in the image. The one we care about for now is **_spring_petclinic_**. 

From here, execute the **_USE_** command with the **_spring_petclinic_** keyspace to tell the database our context is within **_spring_petclinic_**.

📘 **Command to execute**
```
use spring_petclinic;
```

📗 **Expected output**

![Screen Shot 2021-04-06 at 2 12 24 PM](https://user-images.githubusercontent.com/23346205/113758637-2015b180-96e2-11eb-85f0-a53c9a6a604a.png)

Notice how the prompt displays ```token@cqlsh:spring_petclinic>``` informing us we are **using** the **_spring_petclinic_** keyspace. Now we are ready to create our tables.

### ✅ 2c. Create tables

- *Execute the following Cassandra Query Language. Copy and paste the following statements into your CQL Console* 

📘 **Command to execute**

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

- *You should now have a set of petclinic tables*
```sql
describe tables;
```

📗 **Expected output**

![Screen Shot 2021-04-07 at 9 29 25 AM](https://user-images.githubusercontent.com/23346205/113874468-d2ea1c00-9783-11eb-8f7f-e0438682311c.png)


[🏠 Back to Table of Contents](#table-of-content)

## 3. Generate your Astra application token and service account
In order for you to securely connect to your Cassandra database on Astra you need to generate an application token. The cool thing once you generate this once you can then use it for any of your applications or tools to talk to your database. We'll also create a service account to use the DevOps API.

### ✅ 3a. Create a service account
An Astra service account lets you use the DevOps API (Hi Devops folks, this is for you). Why this matters for this workshop is it allows us to very easily pull down your secure connect bundle in an automated fashion using a script.

First things first though, if you haven't already you need to go and create a service account in Astra to enable this. Follow the instructions [**HERE**](https://docs.datastax.com/en/astra/docs/manage-service-account.html#_create_your_service_account) to create your account.

### ✅ 3b. Generate your application token
If you don't already have one follow the instructions [**HERE**](https://docs.datastax.com/en/astra/docs/manage-application-tokens.html#_create_application_token) to generate your new token. **Don't forget to download it once created because you will not be able to see it again** without generating a new one.

Once you **DOWNLOAD** the token if you view the contents they should look something like this:

```shell
"Client Id","Client Secret","Token","Role"
"fdsfdslKFdLFdslDFFDjf","aaaaaaadsdadasdasdasdfsadfldsjfldjdsaldjasljdasljdsaljdasljdasljdlasjdal-FLflirFdfl.lfjdfdsljfjdl+fdlffkdsslfd","AstraCS:ppppdspfdsdslfjsdlfjdlj:540524888-04384039399999999999999999","Admin User"
```

You'll need to use this in a moment to authenticate with DSBulk so **keep it handy**.

## 4. Transform and load data with DSBulk
In order to use DSBulk you need to download and install it. While you can do this locally if you would like following the instructions [**HERE**](https://docs.datastax.com/en/astra/docs/loading-and-unloading-data-with-datastax-bulk-loader.html#_prerequisites) we've already provided it for you using **GitPod**. Click the button below to launch your instance.

[![Open in Gitpod](https://img.shields.io/badge/Gitpod-Open--in--Gitpod-blue?logo=gitpod)](https://gitpod.io/#https://github.com/datastaxdevs/workshop-sql-to-nosql-migration)

### ✅ 4a. Get your secure connect bundle
We're going to need a secure connect bundle to talk to our Astra database with an external app. The bundle contains all of the information about where our cluster is up on the cloud and how to securly connect. After you launched GitPod you may have noticed a prompt asking you for your `service account credentials`.

![Screen Shot 2021-04-07 at 9 00 19 AM](https://user-images.githubusercontent.com/23346205/113870516-ea270a80-977f-11eb-9231-a7b270e159d8.png)

To get your credentials, go back to the Astra UI, click on your organization on the top left of the UI, then choose `Organization Settings`.

![Screen Shot 2021-04-07 at 9 03 50 AM](https://user-images.githubusercontent.com/23346205/113871130-97018780-9780-11eb-8a0a-dbe27cb0ce64.png)

From there:
1. click `Security Settings`
2. then the stacked ellipses next to your service account
3. and finally click `Copy Credentials`

![Screen Shot 2021-04-07 at 9 04 11 AM](https://user-images.githubusercontent.com/23346205/113871458-ee9ff300-9780-11eb-95e3-49754ddb2856.png)

Paste the copied credentials into the prompt and hit **`ENTER`**. 

Now, you will see a prompt asking for your **database ID**. 

Go back to the Astra UI dashboard screen and:
1. choose the `sql_to_nosql_db` database
2. copy the DB ID using the copy widget

![Screen Shot 2021-04-07 at 9 15 26 AM](https://user-images.githubusercontent.com/23346205/113872647-0e83e680-9782-11eb-9dc3-340633466a41.png)

Finally, paste the DB ID into prompt in GitPod and hit **`ENTER`**. That's it, you should have your bundle.

📗 **Expected output**
![Screen Shot 2021-04-07 at 9 20 46 AM](https://user-images.githubusercontent.com/23346205/113873287-ada8de00-9782-11eb-879e-99f6682342dc.png)

### ✅ 4b. Load `owner` table SQL export into `petclinic_owner` NoSQL table
Ok, we're going to use DSBulk in this section to: 
- connect to our Astra database using the **CLIENT ID** and **CLIENT SECRET** we created earlier in step 3 and the secure connect bundle `astra-creds.zip`
- load data from the owner.csv file (exported from our relational DB `owner` table)
- do this using a regular **INSERT** statement that maps values from our CSV file while **transforming** data with `UUID()`
- use CSV file headers to identify what data each delimited column contains
- and finally set our delimiter to use ";"

Once this command is constructed it should look something like this:
<img width="1184" alt="Screen Shot 2021-04-07 at 8 05 22 AM" src="https://user-images.githubusercontent.com/23346205/113863760-0d4dbc00-9778-11eb-95cb-ffdb9742525d.png">

_An example of how to construct the above DSBulk command can be found [**HERE**](https://docs.datastax.com/en/dsbulk/doc/dsbulk/reference/dsbulkLoad.html)._

We've made this a little easier by constructing the command for you. Just run the `dsbulk.sh` script. This will ask for the **CLIENT ID** and **CLIENT SECRET** you created earlier. When it asks, just paste in your value and hit **`ENTER`** to go to the next step.

📘 **Command to execute**
```shell
./dsbulk.sh
```

📗 **Expected output**
![Screen Shot 2021-04-07 at 8 29 07 AM](https://user-images.githubusercontent.com/23346205/113866689-9c100800-977b-11eb-95dc-b990d268ac9d.png)

Now, go back to `CQL Console` in your Astra UI and view the data from the `petclinic_owner` table.

📘 **Command to execute**
```SQL
SELECT * FROM petclinic_owner;
```

📗 **Expected output**
![Screen Shot 2021-04-07 at 8 37 54 AM](https://user-images.githubusercontent.com/23346205/113867461-91a23e00-977c-11eb-93b9-0da86fe7e2d7.png)

Awesome! You now have data in your new NoSQL table.

### ✅ 4b. Let's break this down a bit
So great, you just ran the DSBulk command and something happened, but lets explain this a bit more.

First thing, here is the source CSV we are using generated from our SQL relational database for the `owner` table.
<img width="636" alt="Screen Shot 2021-04-07 at 8 11 49 AM" src="https://user-images.githubusercontent.com/23346205/113864466-eba10480-9778-11eb-9324-1fe57aedbc9d.png">

If you remember from our discussion and the [**slide deck**](./slides.pdf) when moving into something like Cassandra we don't tend to use INTegers for IDs. We use UUIDs instead. This is to ensure IDs are truly unique when using a distributed system. With that, we need to transform the INT based IDs from the SQL data to UUIDs. We do this by using the `**UUID()**` function in our **INSERT** statement.

<img width="855" alt="Screen Shot 2021-04-07 at 9 37 31 AM" src="https://user-images.githubusercontent.com/23346205/113875678-02e5ef00-9785-11eb-9a51-8666cb9bb885.png">

This will generate UUIDs for us as data is inserted into our new Cassandra table.

Also, notice the header line in our CSV.

<img width="503" alt="Screen Shot 2021-04-07 at 9 44 17 AM" src="https://user-images.githubusercontent.com/23346205/113876552-d7173900-9785-11eb-8745-dad34f18740c.png">

If you look back to the **INSERT** statement we used you may have noticed something like 

```sql
VALUES (:first_name,:last_name,:address,:city,:telephone,UUID())
```

where you see items `:first_name` and `:last_name`. These are bindings. They are binding the values passed into the **INSERT** statement to the each column by the name of the column. You can use this to map values all sorts of ways and this just scratches the surface, but I think you get the idea.

## THE END

Whoohoo! Congrats on making it to the end. While this workshop just touches on this process from a pretty high level hopefully it gives you an idea of the kinds of things you need to do and where to start. To learn more about what you can do with DSBulk take a look at the docs [**HERE**](https://docs.datastax.com/en/dsbulk/doc/dsbulk/reference/dsbulkCmd.html). Also, don't forget that you can use Astra to experiment and play around with your data model for **FREE** well within the limits of the $25 monthly credit.


