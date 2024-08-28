package com.ericsson.oss.apps.model;

import com.ericsson.oss.apps.api.model.EpmeKpiVerdict;
import com.ericsson.oss.apps.api.model.EpmeVerdictResult;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@Entity
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "kpi_verdicts")
public class KpiVerdictModel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String kpiName;
    private String kpiType;
    @Enumerated(value = EnumType.STRING)
    private EpmeVerdictResult verdict;
    @Builder.Default
    @Enumerated(value = EnumType.STRING)
    private EpmeKpiVerdict.ThresholdTypeEnum thresholdType = EpmeKpiVerdict.ThresholdTypeEnum.FIXED;
    private Double kpiValue;
    private Double thresholdValue;
}
