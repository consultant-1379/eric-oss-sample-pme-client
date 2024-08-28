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

import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import com.ericsson.oss.apps.api.model.EpmeVerdictResult;
import com.ericsson.oss.apps.model.KpiVerdict;
import com.ericsson.oss.apps.model.KpiVerdictModel;
import com.ericsson.oss.apps.model.VerdictMessage;
import com.ericsson.oss.apps.model.VerdictModel;
import com.ericsson.oss.apps.repository.VerdictRepository;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
@RequiredArgsConstructor
public class VerdictConsumer {
    private final VerdictRepository verdictRepository;

    @Getter
    private final List<VerdictMessage> consumedMessages = new ArrayList<>();

    @KafkaListener(topics = "${spring.kafka.topics.verdictTopic}")
    public void readMessage(final VerdictMessage message) {
        log.info("Consumed Verdict from kafka topic: '{}'", message);

        final var sessionId = message.getPmeSessionId().toString();
        if (!verdictRepository.existsByPmeSessionId(sessionId)) {
            log.warn("Verdict does not belong to client, discarding message");
            return;
        }

        final var fdn = message.getFdn().toString();
        final var timestamp = message.getTimestamp().atOffset(ZoneOffset.UTC);

        verdictRepository.findByPmeSessionIdAndFdnAndTimestamp(sessionId, fdn, timestamp).ifPresentOrElse(persisted -> {
            persisted.setKpiVerdicts(message.getKpiVerdicts().parallelStream().map(this::kpiVerdict).toList());
            setStatus(persisted);
            verdictRepository.save(persisted);
        }, () -> verdictRepository.save(verdict(message)));
    }

    private VerdictModel verdict(final VerdictMessage verdictMessage) {
        final var toPersist = VerdictModel.builder()
                .pmeSessionId(verdictMessage.getPmeSessionId().toString())
                .fdn(verdictMessage.getFdn().toString())
                .timestamp(verdictMessage.getTimestamp().atOffset(ZoneOffset.UTC))
                .kpiVerdicts(verdictMessage.getKpiVerdicts().parallelStream().map(this::kpiVerdict).toList())
                .build();

        setStatus(toPersist);

        return toPersist;
    }

    private void setStatus(final VerdictModel verdict) {
        final var total = verdict.getKpiVerdicts().stream()
                .collect(Collectors.groupingBy(v -> v.getVerdict().name()));

        final var degraded = total.getOrDefault(EpmeVerdictResult.DEGRADED.name(), List.of()).size();
        final var notDegraded = total.getOrDefault(EpmeVerdictResult.NOT_DEGRADED.name(), List.of()).size();

        verdict.setStatus("Complete (%d / %d degraded)".formatted(degraded, degraded + notDegraded));
    }

    private KpiVerdictModel kpiVerdict(final KpiVerdict kpiVerdict) {
        return KpiVerdictModel.builder()
                .kpiName(kpiVerdict.getKpiName().toString())
                .kpiType(kpiVerdict.getKpiType().toString())
                .verdict(EpmeVerdictResult.fromValue(kpiVerdict.getVerdict().name()))
                .kpiValue(kpiVerdict.getKpiValue())
                .thresholdValue(kpiVerdict.getThresholdValue())
                .build();
    }
}
