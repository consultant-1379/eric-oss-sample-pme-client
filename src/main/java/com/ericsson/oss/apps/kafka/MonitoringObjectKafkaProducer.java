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

import java.time.OffsetDateTime;
import java.time.ZonedDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import com.ericsson.oss.apps.client.epme.model.Session;
import com.ericsson.oss.apps.model.MonitoringObjectMessage;
import com.ericsson.oss.apps.model.StateEnum;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class MonitoringObjectKafkaProducer {
    private final String monitoringObjectTopic;
    private final KafkaTemplate<String, MonitoringObjectMessage> kafkaTemplate;

    public MonitoringObjectKafkaProducer(@Value("${spring.kafka.topics.monitoringObjectTopic}") final String monitoringObjectTopic,
            @Qualifier("monitoringObjectKafkaTemplate") final KafkaTemplate<String, MonitoringObjectMessage> kafkaTemplate) {
        this.monitoringObjectTopic = monitoringObjectTopic;
        this.kafkaTemplate = kafkaTemplate;
    }

    public void sendVerdict(final Session session, final List<String> fdns) {
        log.info("Sending monitoring objects for {}", session.getId());

        final var startTime = OffsetDateTime.now().truncatedTo(ChronoUnit.HOURS).minusHours(2).toInstant();

        fdns
                .parallelStream()
                .map(fdn -> new MonitoringObjectMessage(session.getId(), fdn, startTime, StateEnum.ENABLED))
                .forEach(monitoringObject -> {
                    log.info("Sending message: {}", monitoringObject);
                    kafkaTemplate.send(monitoringObjectTopic, monitoringObject);
                });

        log.info("Finished sending monitoring objects: {}", session.getId());
    }
}
