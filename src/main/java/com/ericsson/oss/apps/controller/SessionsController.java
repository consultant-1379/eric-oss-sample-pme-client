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

package com.ericsson.oss.apps.controller;

import static com.ericsson.oss.apps.util.Constants.VERSION;

import java.time.OffsetDateTime;
import java.time.temporal.ChronoUnit;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ericsson.oss.apps.api.SessionsClientApi;
import com.ericsson.oss.apps.api.model.EpmeExecution;
import com.ericsson.oss.apps.api.model.EpmeExecutionResponse;
import com.ericsson.oss.apps.client.epme.SessionsApi;
import com.ericsson.oss.apps.client.epme.model.SessionRequest;
import com.ericsson.oss.apps.kafka.MonitoringObjectKafkaProducer;
import com.ericsson.oss.apps.service.VerdictService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping(VERSION)
@CrossOrigin
public class SessionsController implements SessionsClientApi {
    private final String clientId;
    private final SessionsApi sessionsApi;
    private final MonitoringObjectKafkaProducer monitoringObjectKafkaProducer;
    private final ThreadPoolTaskScheduler scheduler;
    private final VerdictService verdictService;

    public SessionsController(@Value("${gateway.services.iam.clientId}") final String clientId,
            final SessionsApi sessionsApi,
            final MonitoringObjectKafkaProducer monitoringObjectKafkaProducer,
            final ThreadPoolTaskScheduler threadPoolTaskScheduler,
            final VerdictService verdictService) {
        this.clientId = clientId;
        this.sessionsApi = sessionsApi;
        this.monitoringObjectKafkaProducer = monitoringObjectKafkaProducer;
        this.scheduler = threadPoolTaskScheduler;
        this.verdictService = verdictService;
    }

    @Override
    public ResponseEntity<EpmeExecutionResponse> createExecution(final String accept, final String contentType,
            final EpmeExecution epmeExecution) {
        log.info("Creating a session with PME: {}", epmeExecution);

        final var response = sessionsApi.createSession(clientId,
                SessionRequest.builder()
                        .duration(epmeExecution.getDuration())
                        .sessionReference(epmeExecution.getName())
                        .pmeConfigId(epmeExecution.getPmeConfigId())
                        .build(),
                null, null);

        log.info("PME session created: {}", response);

        final var startTime = OffsetDateTime.now().minusHours(1).truncatedTo(ChronoUnit.HOURS);

        scheduler.execute(() -> monitoringObjectKafkaProducer.sendVerdict(response, epmeExecution.getFdns()));
        verdictService.persistNewVerdicts(startTime, response, epmeExecution.getFdns());

        return new ResponseEntity<>(
                new EpmeExecutionResponse(
                        response.getSessionReference(),
                        response.getPmeConfigId(),
                        response.getId(),
                        epmeExecution.getFdns()),
                HttpStatus.CREATED);
    }

}
