/**
 * Created by Vladyslav Kravchuk on 6/22/2021.
 */

public with sharing class CalloutClient {
    private String endpoint;
    private Map<String, String> headers = new Map<String, String>();
    @TestVisible
    private HttpRequest request = new HttpRequest();

    public CalloutClient(String requestEndpoint) {
        this.endpoint = requestEndpoint;
    }

    public CalloutClient setHeader(String key, String value) {
        this.setHeaders(new Map<String, String>{
                key => value
        });
        return this;
    }

    public CalloutClient setHeaders(Map<String, String> headers) {
        this.headers.putAll(headers);
        return this;
    }

    public HttpResponse get() {
        return this.execute('GET', null);
    }

    public HttpResponse post() {
        return this.post(null);
    }

    public HttpResponse post(Object requestBody) {
        return this.execute('POST', requestBody);
    }

    public HttpResponse put() {
        return this.put(null);
    }

    public HttpResponse put(Object requestBody) {
        return this.execute('PUT', requestBody);
    }

    public HttpResponse patch() {
        return this.patch(null);
    }

    public HttpResponse patch(Object requestBody) {
        return this.execute('PATCH', requestBody);
    }

    public HttpResponse del() {
        return this.execute('DELETE', null);
    }

    private HttpResponse execute(String method, Object requestBody) {

        this.setMethod(method);
        this.setEndpoint();
        this.setHeaders();

        if (requestBody != null) {
            this.setBody(requestBody);
        }

        HttpResponse response = new Http().send(this.request);

        try {
            Integer statusCode = response.getStatusCode();

            if (statusCode == 200 || statusCode == 204) {
                System.debug('Resource updated/deleted successfully. Current method is: ' + method);
                return response;
            } else {
                String errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
                        + 'Status ' + response.getStatus() + ' and Status Code ' + response.getStatusCode();

                System.debug(errorMessage + response.getBody());

              //  throw new CalloutClientException(errorMessage);
            }
        } catch (System.Exception e) {
            System.debug('#### Exception Executed ' + e.getStackTraceString() + '  ' + e.getMessage());
            throw e;
        }

        return null;
    }

    private void setMethod(String method) {
        this.request.setMethod(method);
    }

    private void setEndpoint() {
        this.request.setEndpoint(this.endpoint);
    }

    private void setHeaders() {
        for (String headerName : this.headers.keySet()) {
            this.request.setHeader(headerName, this.headers.get(headerName));
        }
    }

    private void setBody(Object requestBody) {
        if (requestBody == null) return;

        if (requestBody instanceOf Blob) {
            this.request.setBodyAsBlob((Blob) requestBody);
        } else if (requestBody instanceOf String) {
            this.request.setBody((String) requestBody);
        } else {
            this.request.setBody(Json.serialize(requestBody));
        }
    }

    public class CalloutClientException extends Exception {
    }
}