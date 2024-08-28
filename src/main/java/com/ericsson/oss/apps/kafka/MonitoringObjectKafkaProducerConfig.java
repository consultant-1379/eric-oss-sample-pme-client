/*******************************************************************************
 * COPYRIGHT Ericsson 2023
 *
 *
 *
 * The copyright to the computer program(s) herein is the property of
 *
 * Ericsson Inc. The programs may be used and/or copied only with written
 *
 * permission from Ericsson Inc. or in accordance with the terms and
 *
 * conditions stipulated in the agreement/contract under which the
 *
 * program(s) have been supplied.
 ******************************************************************************/

package com.ericsson.oss.apps.kafka;

import java.util.HashMap;
import java.util.Map;

import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;

import com.ericsson.oss.apps.model.MonitoringObjectMessage;
import com.ericsson.oss.apps.util.avro.AvroSerializer;

@Configuration
public class MonitoringObjectKafkaProducerConfig {
    private final String bootstrapServers;

    public MonitoringObjectKafkaProducerConfig(@Value("${spring.kafka.bootstrap-servers}") final String bootstrapServers) {
        this.bootstrapServers = bootstrapServers;
    }

    private Map<String, Object> producerConfigs() {
        final Map<String, Object> props = new HashMap<>();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, AvroSerializer.class);
        return props;
    }

    private ProducerFactory<String, MonitoringObjectMessage> producerFactory() {
        return new DefaultKafkaProducerFactory<>(producerConfigs());
    }

    @Bean
    public KafkaTemplate<String, MonitoringObjectMessage> monitoringObjectKafkaTemplate() {
        return new KafkaTemplate<>(producerFactory());
    }

}