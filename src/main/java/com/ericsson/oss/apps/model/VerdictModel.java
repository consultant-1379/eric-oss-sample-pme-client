package com.ericsson.oss.apps.model;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "verdicts", uniqueConstraints = { @UniqueConstraint(columnNames = { "pmeSessionId", "fdn", "timestamp" }) })
public class VerdictModel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String pmeSessionId;
    private String fdn;
    private OffsetDateTime timestamp;
    @Builder.Default
    private String status = "PENDING";

    @Builder.Default
    @OneToMany(fetch = FetchType.EAGER, orphanRemoval = true, cascade = CascadeType.ALL)
    private List<KpiVerdictModel> kpiVerdicts = new ArrayList<>();
}
