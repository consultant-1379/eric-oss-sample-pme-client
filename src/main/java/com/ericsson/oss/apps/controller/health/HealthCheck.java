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

package com.ericsson.oss.apps.controller.health;

import java.util.Objects;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

/**
 * Health Check component for microservice chassis. Any internal logic can change health state of the chassis.
 */
@Slf4j
@Component
public final class HealthCheck implements HealthIndicator {

    /**
     * Name of the service.
     */
    private final String name;
    /**
     * Error upon health check.
     */
    private String errorMessage;

    public HealthCheck(@Value("${info.app.name}") final String name) {
        this.name = name;
    }

    @Override
    public Health health() {
        log.trace("Invoking chassis specific health check");
        final String errorCode = getErrorMessage();
        if (Objects.nonNull(errorCode)) {
            return Health.down().withDetail("Error: ", errorCode).build();
        }

        log.trace("{} is UP and healthy", this.name);
        return Health.up().build();
    }

    /**
     * Set the error message that will cause fail health check of micro service.
     *
     * @param errorMessage
     *            Error message from health check.
     */
    public void failHealthCheck(final String errorMessage) {
        this.errorMessage = errorMessage;
    }

    /**
     * Getter method for error message.
     *
     * @return errorMessage status of the service
     */
    private String getErrorMessage() {
        return this.errorMessage;
    }
}
