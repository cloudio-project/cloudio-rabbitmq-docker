FROM rabbitmq:3.11.10-management-alpine

ADD rabbitmq_auth_backend_amqp-v3.11.x.ez /opt/rabbitmq/plugins/
RUN rabbitmq-plugins enable --offline rabbitmq_auth_backend_amqp rabbitmq_auth_backend_cache rabbitmq_auth_mechanism_ssl rabbitmq_mqtt

ADD rabbitmq-env.conf /etc/rabbitmq/
ADD rabbitmq.conf /etc/rabbitmq/
ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENV CA_CERT ""
ENV SERVER_CERT ""
ENV SERVER_KEY ""

EXPOSE 5671 8883 15672

ENTRYPOINT ["/entrypoint.sh"]
