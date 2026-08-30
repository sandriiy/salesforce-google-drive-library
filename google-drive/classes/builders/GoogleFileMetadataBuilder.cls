/**
 * MIT License
 *
 * Copyright (c) 2024-2026 Andrii Sukhetskyi
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

public class GoogleFileMetadataBuilder {
    private Map<String, Object> fileMetadata = new Map<String, Object>();

    public GoogleFileMetadataBuilder setFileProperty(String filePropertyName, String filePropertyValue) {
        this.addPairIfNotEmpty(filePropertyName, filePropertyValue);
        return this;
    }

	public GoogleFileMetadataBuilder setFileProperty(String filePropertyName, Boolean filePropertyValue) {
        this.addPairIfNotEmpty(filePropertyName, filePropertyValue);
        return this;
    }

	public GoogleFileMetadataBuilder setFileProperty(String filePropertyName, Map<String, Object> filePropertyValues) {
        this.addPairIfNotEmpty(filePropertyName, filePropertyValues);
        return this;
    }

    public GoogleFileMetadataBuilder setFileProperty(String filePropertyName, List<String> filePropertyValues) {
        this.addPairIfNotEmpty(filePropertyName, filePropertyValues);
        return this;
    }

    public GoogleFileMetadataBuilder setFileProperty(String filePropertyName, List<Object> filePropertyValues) {
        this.addPairIfNotEmpty(filePropertyName, filePropertyValues);
        return this;
    }

    public String build() {
        return this.fileMetadata.isEmpty() 
            ? '' 
            : JSON.serialize(this.fileMetadata, true);
    }

    private void addPairIfNotEmpty(String key, List<Object> values) {
        if (values != null && !values.isEmpty()) {
            this.fileMetadata.put(key, values);
        }
    }

    private void addPairIfNotEmpty(String key, String value) {
        if (String.isNotBlank(value)) {
            this.fileMetadata.put(key, value);
        }
    }

	private void addPairIfNotEmpty(String key, Boolean value) {
        if (value != null) {
            this.fileMetadata.put(key, value);
        }
    }

	private void addPairIfNotEmpty(String key, Map<String, Object> values) {
        if (!values.isEmpty()) {
            this.fileMetadata.put(key, values);
        }
    }

    private void addPairIfNotEmpty(String key, List<String> values) {
        if (values != null && !values.isEmpty()) {
            this.fileMetadata.put(key, values);
        }
    }
}