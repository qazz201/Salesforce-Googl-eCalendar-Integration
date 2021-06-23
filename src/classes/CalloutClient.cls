/**
 * Created by Vladyslav Kravchuk on 6/22/2021.
 */

public inherited sharing class CalloutClient {
    private String endpoint;
    private Map<String, String> headers = new Map<String, String>();
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
        return this.execute('POST', null);
    }

    public HttpResponse post(Object requestBody) {
        return this.execute('POST', requestBody);
    }

    private HttpResponse execute(String method, Object requestBody) {
        Http http = new Http();

        this.setMethod(method);
        this.setEndpoint();
        this.setHeaders();

        if (requestBody != null) {
            this.setBody(requestBody);
        }

        HttpResponse response = http.send(this.request);

        try {
            if (response.getStatusCode() == 200) {
                return response;
            } else {
                String errorMessage = 'Unexpected Error while communicating with Google Calendar API. '
                        + 'Status ' + response.getStatus() + ' and Status Code ' + response.getStatusCode();

                System.debug(errorMessage);
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

        System.debug(requestBody instanceof String);

        if (requestBody instanceOf Blob) {
            this.request.setBodyAsBlob((Blob) requestBody);
            // this.setHeader('Content-Type', 'multipart/form-data; charset=utf-8');
        } else {
            this.request.setBody(Json.serialize(requestBody));
            // this.setHeader('Content-Type', 'application/json; charset=utf-8');
        }
    }

    public class CalloutApiException extends Exception {
    }
}