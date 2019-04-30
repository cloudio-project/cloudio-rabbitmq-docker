# Docker image of RabbitMQ for cloud.iO

## Description

Docker image of [**RabbitMQ**](https://www.rabbitmq.com) adapted to the needs of the [*cloud.iO*](http://cloudio.hevs.ch) IoT project.

The image contains an installation of the **RabbitMQ** message broker along with the [**auth_backend_amqp**](https://github.com/rabbitmq/rabbitmq-auth-backend-amqp) plugin and is already configured to be used in the context of a *cloud.iO* installation.

RabbitMQ is configured to listen to port **5672** for incomming **AMQP** (TCP) connections and to port **1883** for **MQTT** connections. We discourage to expose them as data is exchanged in plain text. The broker listens to port **5671** for **AMQPS** connections and on port **8883** for **MQTTS** connections. Both support **username/password** and **x509 certiciate** (common name is used as username) authentication.

Authentication and authorization is - apart some system accounts - handled by an external service that will connect to the message broker via AMQPS and handle all authentication and authorizatoin requests via **AMQP RPC**.

The following plugins are activated:

- **rabbitmq_auth_backend_amqp**:  
  This plugin will forward the authentication and authorization requests to the *cloud.iO* security microservice, which is connected via AMQPS to the broker.
- **rabbitmq_auth_backend_cache**:  
  Caches the decisions from the *cloud.iO* security microservice in order to limit the number of messages to send and receive.
- **rabbitmq_auth_mechanism_ssl**:  
  Enables *cloud.io* endpoints and microservices to connect to the message broker via MQTTS or AMQPS using an x509 certificate.
- **rabbitmq_mqtt**:  
  Enables MQTT and MQTTS compatibility layer.

- **rabbitmq_management**:  
  RabbitMQ management interface.

## Starting a container

The broker needs a valid SSL configuration in order to start. The certificate of the **Cretificate Authority** (CA) certificate, the **server certificate** and the **server private key** are all passed via environment variables (required):

- **CA_CERT**: The Certificate Authority's certificate in PEM format.
- **SERVER_CERT**: The server's certificate in PEM format.
- **SERVER_KEY**: The server's private key in PEM format.

If a local (RabbitMQ) admin user is required, you can set the environment variable **ADMIN_PASSWORD** to a secret password and the container will add a user called **admin** with that password to the RabbitMQ's local user base.

A typical example:

    docker run -d -p 8883:8883 -p 5671:5671 -e CA_CERT='-----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----' -e SERVER_CERT='-----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----' -e SERVER_KEY='-----BEGIN PRIVATE KEY-----
    ...
    -----END PRIVATE KEY-----' cloudio/cloudio-rabbitmq:latest

If you like to add an admin user, specify the admin user's password:

    docker run -d -p 8883:8883 -p 5671:5671 -e CA_CERT='-----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----' -e SERVER_CERT='-----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----' -e SERVER_KEY='-----BEGIN PRIVATE KEY-----
    ...
    -----END PRIVATE KEY-----' -e ADMIN_PASSWORD='MySecretPassword' cloudio/cloudio-rabbitmq:latest

