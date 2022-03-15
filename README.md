# Docker Compose Collection

I created this docker configuration pool so that when I forget the configuration environment, I can reuse it.

Basic command :
```bash
docker-compose -f $FILENAME up -d
docker-compose -f $FILENAME down -v
```

## Kafka CLI

Download docker compose configuration using curl

```bash
curl -o kafka-cli.yml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/kafka-cli.yaml
```

This yaml `kafka-cli.yaml` will create a new container `zookeeper` and exposed port `2181` on host port. Also create a new container `kafka` and exposed port `29092`, `9092` and `9101` on host port.

## Redis

By default there are 16 databases (indexed from 0 to 15) and you can navigate between them using `select` command. Number of databases can be changed in redis config file with `databases` setting.

Download docker compose configuration using curl

```bash
curl -o redis.yml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/redis.yaml
```

This yaml `redis.yaml` will create a new container `redis` and exposed port `6379` on host port.

**Redis CLI**

Run `redis-cli`

```bash
docker exec -it redis redis-cli
```

Select the Redis logical database having the specified zero-based numeric index. New connections always use the database 0.

Change database.

```bash
select [INDEX]
```

Set and get key

```bash
set [KEY_NAME] [VALUE]
get [KEY_NAME]
```

**Another Redis Desktop Manager**

Install [Another Redis Desktop Manager](https://formulae.brew.sh/cask/another-redis-desktop-manager) with homebrew. You can run with following command on your terminal.

```bash
brew install cask 
brew install --cask another-redis-desktop-manager
```

Open the application, and should looks like below.

![Another RDM](images/redis1.png)

Another Redis Desktop Manager dashboard

![Another RDM - Dashboard](images/redis2.png)

Another Redis Desktop Manager add new key.

![Another RDM - Add New Key](images/redis3.png)

## MySQL

Download docker compose configuration using curl

```bash
curl -o mysql.yml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/mysql.yaml
```

This yaml `mysql.yaml` will create a new container `mysql` and exposed port `3306` on host port.

Create network `my-network` if does not exists

```bash
docker network create my-network
```

Create volume `mysql-data` to persist data then run `docker-compose`

```bash
docker volume create mysql-data
```

**MySQL CLI**

Run this command to run MySQL command on container. Default user is `root` and password `SevenEightTwo782` you can change the password in `yaml` file.

```bash
docker exec -it mysql bash
```

**Basic command:**

-   Login into database, then type your password
    ```bash
    mysql -u root -p
    ```
-   Get list of databases
    ```sql
    show databases;
    ```
-   Create database and use database
    ```sql
    create database $DB_NAME;
    use $DB_NAME;
    ```
## PostgreSQL

Download docker compose configuration using curl

```bash
curl -o postgresql.yml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/postgresql.yaml
```

This yaml `postgresql.yaml` will create a new container `postgresql` and exposed port `5432` on host port.

Create network `my-network` if does not exists

```bash
docker network create my-network
```

Create volume `postgre-data` to persist data then run `docker-compose`

```bash
docker volume create postgre-data
```

**Postgre SQL CLI**

Run this command to run PostgreSQL command on container. Default user is `postgres` and password `SevenEightTwo782` you can change the password in `yaml` file.

```bash
docker exec -it postgresql bash
```

**Basic command:**

-   Login into database
    ```bash
    psql -Upostgres -w
    ```
-   Get list of databases
    ```sql
    \l
    ```
-   Create database and use database
    ```sql
    create database $DB_NAME;
    \c $DB_NAME
    ```

## SQL Server

Download docker compose configuration using curl

```bash
curl -o sqlserver.yml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/sqlserver.yaml
```

This yaml `sqlserver.yaml` will create a new container `sqlserver` and exposed port `1433` on host port.

Create network `my-network` if does not exists

```bash
docker network create my-network
```

Create volume `sqlserver-data` and `sqlserver-user` to persist data then run `docker-compose`

```bash
docker volume create sqlserver-data && docker volume create sqlserver-user
```

**SQL Server CLI**

Run this command to run SQL Server command on container. Default user is `sa` and password `SevenEightTwo782` you can change the password in `yaml` file.

```bash
docker exec -it sqlserver /opt/mssql-tools/bin/sqlcmd -U sa -P SevenEightTwo782
```

**Basic command:**

-   Get list of databases
    ```sql
    select name from sys.databases
    go
    ```
-   Create database and use database
    ```sql
    create database $DB_NAME
    go
    ```

## RabbitMQ

Download docker compose configuration using curl

```bash
curl -o rabbitmq.yml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/rabbitmq.yaml
```

This yaml `rabbitmq.yaml` will create a new container `rabbitmq` and exposed port `5672` and `15672` on host port.

Create network `my-network` if does not exists

```bash
docker network create my-network
```

Create volume `rabbitmq-data` and `rabbitmq-log` to persist data then run `docker-compose`

```bash
docker volume create rabbitmq-data && docker volume create rabbitmq-log
```

**RabbitMq Management**

Default RabbitMQ management user is `guest` and password is `guest`. Go to `localhost:15672` to acess RabbitMQ management.

![RabbitMQ Management](images/rabbitmq-management.png)

## Sonarqube

Download docker compose configuration using curl

```bash
curl -o sonarqube.yml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/sonarqube.yaml
```

This yaml `sonarqube.yaml` will create a new container `sonarqube` and exposed port `9000` and `9002` on host port.

Create network `my-network` if does not exists

```bash
docker network create my-network
```

Create volume to persist data then run `docker-compose`

```bash
docker volume create sonarqube-data && docker volume create sonarqube-extensions && docker volume create sonarqube-logs && docker volume create sonarqube-temp
```

**Sonarqube Management**

Default Sonarqube management user is `admin` and password is `admin`. Go to `localhost:9000` to acess Sonarqube management and then change the default password first.

![Sonarqube Management](images/sonarqube-management.png)

## MongoDB
Download docker compose configuration using curl

```bash
curl -o mongodb.yaml https://raw.githubusercontent.com/piinalpin/docker-compose-collection/master/mongodb.yaml
```

This yaml `mongodb.yaml` will create a new container `mongodb` and exposed port `27017` on host port.

Create network `my-network` if does not exists

```bash
docker network create my-network
```

Create volume to persist data then run `docker-compose`

```bash
docker volume create mongodb-data && docker volume create mongodb-config
```

**MongoDB CLI**
Run this command to run MongoDB command on container. Default user is `root` and password `SevenEightTwo782` you can change the password in `yaml` file.

```bash
docker exec -it mongodb mongo -u root -p SevenEightTwo782 --authenticationDatabase admin <SOME_DATABASE>
```

**Basic command:**

-   Get list of databases
    ```js
    show dbs
    ```
-   Create database and use database
    ```js
    use some_db
    db
    ```
-   Create collection
    ```js
    db.createCollection('some_collection');
    ```
-   Insert row
    ```js
    db.some_db.insertMany([
        {
            _id: 1,
            first_name: "Maverick",
            last_name: "Johnson",
            gender: 1
        },
        {
            _id: 2,
            first_name: "Calvin",
            last_name: "Joe",
            gender: 1
        },
        {
            _id: 3,
            first_name: "Kagura",
            last_name: "Otsusuki",
            gender: 0
        }
    ]);
    ```
- Find row
    ```js
    db.some_db.find();
    ```
- Update row
    ```js
    db.test.updateOne({_id: 1}, {$set: {
        first_name: "Maverick",
        last_name: "Johnson Updated",
        gender: 1
    }});
    ```