#!/usr/bin/env bash

# Save certificates and keys passed in the environment.
if [[ "$CA_CERT" == "-----BEGIN CERTIFICATE-----"* ]]; then
	echo "$CA_CERT" > /etc/rabbitmq/ca.crt
else
	echo "Missing CA Certificate (CA_CERT) environment variable or invalid certificate was set!"
	exit 1
fi

if [[ "$SERVER_CERT" == "-----BEGIN CERTIFICATE-----"* ]]; then
	echo "$SERVER_CERT" > /etc/rabbitmq/server.crt
else
	echo "Missing Server Certificate (SERVER_CERT) environment variable or invalid certificate was set!"
	exit 1
fi

if [[ "$SERVER_KEY" == "-----BEGIN PRIVATE KEY-----"* ]] || [[ "$SERVER_KEY" == "-----BEGIN RSA PRIVATE KEY-----"* ]]; then
	echo "$SERVER_KEY" > /etc/rabbitmq/server.key
else
	echo "Missing Server Key (SERVER_KEY) environment variable or invalid key was set!"
	exit 1
fi

# Configure RabbitMQ Broker after boot.
configure_rabbitmq_server() {
	rabbitmqctl wait /var/run/rabbitmq.pid

	echo " "
	echo "========== Post-Startup RabbitMQ Broker Configuration =========="

	# Add admin user.
	if [ -n "${ADMIN_PASSWORD}" ]
	then
	    echo "Admin user for this broker is 'admin' with password '${ADMIN_PASSWORD}'"
		rabbitmqctl add_user admin ${ADMIN_PASSWORD}
		rabbitmqctl set_user_tags admin administrator
		rabbitmqctl set_permissions admin ".*" ".*" ".*"
	else
		echo "No admin user is created."
	fi

	# Add cloud.iO micro-services user.
	rabbitmqctl add_user cloudio_services DUMMY
	rabbitmqctl clear_password cloudio_services
	rabbitmqctl set_permissions cloudio_services ".*" ".*" ".*"

	echo " "
	echo "========== Finished, cloud.iO Broker ready to use. =========="
}
configure_rabbitmq_server &

rabbitmq-server
