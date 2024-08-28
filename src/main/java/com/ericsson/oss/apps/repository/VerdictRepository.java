package com.ericsson.oss.apps.repository;

import java.time.OffsetDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.ericsson.oss.apps.model.VerdictModel;

public interface VerdictRepository extends JpaRepository<VerdictModel, Long> {
    boolean existsByPmeSessionId(String pmeSessionId);

    Optional<VerdictModel> findByPmeSessionIdAndFdnAndTimestamp(String pmeSessionId, String fdn, OffsetDateTime timestamp);
}
