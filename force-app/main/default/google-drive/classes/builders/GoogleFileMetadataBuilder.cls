public class GoogleFileMetadataBuilder {
    private Map<String, Object> fileMetadata = new Map<String, Object>();

    public GoogleFileMetadataBuilder setFileProperty(String filePropertyName, String filePropertyValue) {
        this.addPairIfNotEmpty(filePropertyName, filePropertyValue);
        return this;
    }

    public GoogleFileMetadataBuilder setFileProperty(String filePropertyName, List<String> filePropertyValues) {
        this.addPairIfNotEmpty(filePropertyName, filePropertyValues);
        return this;
    }

    public String build() {
        return this.fileMetadata.isEmpty() 
            ? '' 
            : JSON.serialize(this.fileMetadata, true);
    }

    private void addPairIfNotEmpty(String key, String value) {
        if (String.isNotBlank(value)) {
            this.fileMetadata.put(key, value);
        }
    }

    private void addPairIfNotEmpty(String key, List<String> values) {
        if (values != null && !values.isEmpty()) {
            this.fileMetadata.put(key, values);
        }
    }
}