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

public with sharing class GoogleLabelModificationBuilder {
    private Map<String, Object> labelModification = new Map<String, Object>();
    private List<Object> fieldModifications = new List<Object>();

    public GoogleLabelModificationBuilder setLabelId(String labelId) {
        this.labelModification.put('labelId', labelId);
        return this;
    }

    public GoogleLabelModificationBuilder setRemoveLabel(Boolean removeLabel) {
        this.labelModification.put('removeLabel', removeLabel);
        return this;
    }

    public GoogleLabelModificationBuilder setTextValues(String fieldId, List<String> values) {
        return this.addFieldModification(fieldId, 'setTextValues', values);
    }

    public GoogleLabelModificationBuilder setSelectionValues(String fieldId, List<String> values) {
        return this.addFieldModification(fieldId, 'setSelectionValues', values);
    }

    public GoogleLabelModificationBuilder setDateValues(String fieldId, List<String> values) {
        return this.addFieldModification(fieldId, 'setDateValues', values);
    }

    public GoogleLabelModificationBuilder setUserValues(String fieldId, List<String> values) {
        return this.addFieldModification(fieldId, 'setUserValues', values);
    }

    public GoogleLabelModificationBuilder setIntegerValues(String fieldId, List<Integer> values) {
        return this.addFieldModification(fieldId, 'setIntegerValues', values);
    }

    public GoogleLabelModificationBuilder unsetValues(String fieldId) {
        return this.addFieldModification(fieldId, 'unsetValues', true);
    }

    public Map<String, Object> build() {
        Map<String, Object> builtLabelModification = this.labelModification.clone();
        if (!this.fieldModifications.isEmpty()) {
            builtLabelModification.put('fieldModifications', this.fieldModifications);
        }

        return builtLabelModification;
    }

    private GoogleLabelModificationBuilder addFieldModification(String fieldId, String modificationName, Object values) {
        this.fieldModifications.add(new Map<String, Object>{
            'fieldId' => fieldId,
            modificationName => values
        });

        return this;
    }
}
