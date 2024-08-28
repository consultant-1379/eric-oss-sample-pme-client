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

package com.ericsson.oss.apps.util;

import lombok.experimental.UtilityClass;

@UtilityClass
public class Constants {

    public static final String VERSION = "/v1";
    public static final String COLON = ":";

    //IAM ACCESS
    public static final String HTTPS = "https";
    public static final String IAM = "iam";
    public static final String JSON_PROPERTY_ACCESS_TOKEN = "access_token";
    public static final String JSON_PROPERTY_EXPIRES_IN = "expires_in";
    public static final String CLIENT_CREDENTIALS = "client_credentials";
    public static final String GRANT_TYPE = "grant_type";
    public static final String CLIENT_ID = "client_id";
    public static final String CLIENT_SECRET = "client_secret";

    //DMM Data Discovery Access
    public static final String PME = "pme";

    //Connection
    public static final int MAX_TOTAL_CONNECTIONS_PER_ROUTE = 20;
    public static final int MAX_TOTAL_CONNECTIONS = 50;
    public static final int CONNECT_TIMEOUT_SECONDS = 30;
    public static final int REQUEST_TIMEOUT_SECONDS = 10;
    public static final int SOCKET_TIMEOUT_SECONDS = 60;
    public static final int CONNECTION_TIME_TO_LIVE_SECONDS = 30;
    public static final String STANDARD_COOKIE_SPEC = "standard";

    // Certificate management
    public static final int CERT_FILE_CHECK_SCHEDULE_IN_SECONDS = 300;
    public static final String JKS = "JKS";
}
