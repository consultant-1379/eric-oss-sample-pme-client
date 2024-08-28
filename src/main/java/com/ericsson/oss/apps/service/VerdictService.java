package com.ericsson.oss.apps.service;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

import org.springframework.stereotype.Service;

import com.ericsson.oss.apps.client.epme.model.Session;
import com.ericsson.oss.apps.model.VerdictModel;
import com.ericsson.oss.apps.repository.VerdictRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class VerdictService {
    private final VerdictRepository verdictRepository;

    public void persistNewVerdicts(final OffsetDateTime startTime, final Session session, final List<String> fdns) {
        final var duration = session.getDuration();
        final var sessionId = session.getId();

        final List<VerdictModel> toPersist = new ArrayList<>();

        for (int timeOffset = 0; timeOffset < duration; timeOffset++) {
            final var time = startTime.plusHours(timeOffset);
            toPersist.addAll(
                    new ArrayList<>(fdns.parallelStream()
                            .map(fdn -> verdictModel(sessionId, fdn, time))
                            .toList()));
        }

        verdictRepository.saveAllAndFlush(toPersist);

        log.info("Persisted all monitoring objects ({})", toPersist.size());
    }

    private VerdictModel verdictModel(final String sessionId, final String fdn, final OffsetDateTime time) {
        return VerdictModel.builder()
                .fdn(fdn)
                .pmeSessionId(sessionId)
                .timestamp(time)
                .build();
    }
}
