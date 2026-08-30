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

public inherited sharing class GoogleScopeResolver {
    /**
     * The full OAuth URL for a single scope, for example
     * https://www.googleapis.com/auth/drive.file
    */
    public static String toScopeUrl(GoogleScope scope) {
        return GoogleConstants.GOOGLE_SCOPE_URLS.get(scope);
    }

    /**
     * The scope URLs as one space-delimited string, which is the form the OAuth
     * token endpoint expects. Returns an empty string when nothing was requested.
    */
    public static String toScopeUrls(List<GoogleScope> scopes) {
        return String.join(toScopeUrlList(scopes), ' ');
    }

    /**
     * The scope URLs as a list, sorted so that the same set of scopes always
     * produces the same order.
    */
    public static List<String> toScopeUrlList(List<GoogleScope> scopes) {
        List<String> scopeUrls = new List<String>();
        if (scopes == null) {
            return scopeUrls;
        }

        for (GoogleScope scope : scopes) {
            String scopeUrl = GoogleConstants.GOOGLE_SCOPE_URLS.get(scope);
            if (String.isNotBlank(scopeUrl) && !scopeUrls.contains(scopeUrl)) {
                scopeUrls.add(scopeUrl);
            }
        }

        scopeUrls.sort();
        return scopeUrls;
    }
}
