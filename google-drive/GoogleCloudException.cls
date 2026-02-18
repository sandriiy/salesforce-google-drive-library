public class GoogleCloudException extends Exception {
    public String endpoint;
    public Map<String, String> httpHeaders;
    public Map<String, String> httpParameters;
}