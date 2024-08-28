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

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ericsson.oss.apps.api.VerdictsClientApi;
import com.ericsson.oss.apps.api.model.EpmeKpiVerdict;
import com.ericsson.oss.apps.api.model.EpmeVerdict;
import com.ericsson.oss.apps.api.model.EpmeVerdictResult;
import com.ericsson.oss.apps.model.KpiVerdictModel;
import com.ericsson.oss.apps.model.VerdictModel;
import com.ericsson.oss.apps.repository.VerdictRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping(VERSION)
@RequiredArgsConstructor
@CrossOrigin
public class VerdictsController implements VerdictsClientApi {
    private final VerdictRepository verdictRepository;

    @Override
    public ResponseEntity<List<EpmeVerdict>> getVerdicts(final String accept, final String contentType) {
        final var persisted = verdictRepository.findAll();
        final var verdicts = persisted
                .parallelStream()
                .map(this::verdict)
                .toList();

        return ResponseEntity.ok(verdicts);
    }

    private EpmeVerdict verdict(final VerdictModel verdict) {
        return new EpmeVerdict(
                verdict.getPmeSessionId(),
                verdict.getFdn(),
                verdict.getTimestamp(),
                verdict.getKpiVerdicts().parallelStream().map(this::kpiVerdict).toList())
                        .status(verdict.getStatus());
    }

    private EpmeKpiVerdict kpiVerdict(final KpiVerdictModel kpiVerdict) {
        return new EpmeKpiVerdict(
                kpiVerdict.getKpiName(),
                kpiVerdict.getKpiType(),
                EpmeVerdictResult.fromValue(kpiVerdict.getVerdict().toString()),
                EpmeKpiVerdict.ThresholdTypeEnum.FIXED)
                        .kpiValue(kpiVerdict.getKpiValue())
                        .thresholdValue(kpiVerdict.getThresholdValue());

    }
}
