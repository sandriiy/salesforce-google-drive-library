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

public inherited sharing class GoogleAuthorizationCodeFlow {
    public class Builder {
        private String apexAuthorizerName;
        private Cache.OrgPartition orgPartition;
        private Cache.SessionPartition sessionPartition;
        private String partitionKey;
        private String cachedAccessToken;
        private List<GoogleScope> requestedScopes;

        public Builder setLocalGoogleAuthorizer(String apexClassName) {
            this.apexAuthorizerName = apexClassName;
            return this;
        }

        /**
         * Declares what the credential is going to be used for, so an authorizer
         * implementing GoogleScopedAuthorizer can mint a token narrow enough for the job
         * instead of falling back on the full drive scope.
        */
        public Builder setRequestedScopes(List<GoogleScope> requestedScopes) {
            this.requestedScopes = requestedScopes;
            return this;
        }

        public Builder setLocalPlatformCache(Cache.OrgPartition orgPartition, String key) {
            this.orgPartition = orgPartition;
            this.partitionKey = key;
            return this;
        }

        public Builder setLocalPlatformCache(Cache.SessionPartition sessionPartition, String key) {
            this.sessionPartition = sessionPartition;
            this.partitionKey = key;
            return this;
        }

        public GoogleCredential build() {
            resolveCachedAccessToken();
            return executeGoogleAuthFlow();
        }

        /**
         * The cache is read here rather than in setLocalPlatformCache because the key is
         * only final once every setter has run - setRequestedScopes may follow the cache
         * setter, and it changes the key.
        */
        private void resolveCachedAccessToken() {
            String cacheKey = this.buildPartitionKey();
            if (String.isBlank(cacheKey)) return;

            if (this.orgPartition != null) {
                if (this.orgPartition.contains(cacheKey)) {
                    this.cachedAccessToken = (String) this.orgPartition.get(cacheKey);
                }
            } else if (this.sessionPartition != null) {
                try {
                    if (this.sessionPartition.contains(cacheKey)) {
                        this.cachedAccessToken = (String) this.sessionPartition.get(cacheKey);
                    }
                } catch (Exception ex) {
                    // No action required. This error occurs in asynchronous or flow invocable contexts.
                }
            }
        }

        private GoogleCredential executeGoogleAuthFlow() {
            if (String.isNotBlank(this.cachedAccessToken)) {
                return buildCredentialInfo(this.cachedAccessToken, 'Bearer');
            } else {
                Type authorizerType = Type.forName(this.apexAuthorizerName);
                Object authorizerInstance = authorizerType.newInstance();

                String accessToken = authorizerInstance instanceof GoogleScopedAuthorizer
                    ? ((GoogleScopedAuthorizer) authorizerInstance).retrieveAccessToken(resolveRequestedScopes())
                    : ((GoogleAuthorizer) authorizerInstance).retrieveAccessToken();

                resolvePlatformCacheStorage(accessToken);
                return buildCredentialInfo(accessToken, 'Bearer');
            }
        }

        private List<GoogleScope> resolveRequestedScopes() {
            return this.requestedScopes == null ? new List<GoogleScope>() : this.requestedScopes;
        }

        /**
         * Platform Cache keys are alphanumeric and capped at 50 characters, so the scope
         * set is folded in as a short hex digest rather than as the scope names themselves.
        */
        private String buildPartitionKey() {
            if (String.isBlank(this.partitionKey)) return this.partitionKey;
            if (this.requestedScopes == null || this.requestedScopes.isEmpty()) return this.partitionKey;

            String scopedPartitionKey = this.partitionKey + this.buildRequestedScopesDigest();
            if (scopedPartitionKey.length() > GoogleConstants.PLATFORM_CACHE_KEY_MAX_LENGTH) {
                throw new IllegalArgumentException(
                    'The Platform Cache key "' + this.partitionKey + '" leaves no room for the scope suffix. '
                    + 'Keys are limited to ' + GoogleConstants.PLATFORM_CACHE_KEY_MAX_LENGTH
                    + ' characters and requesting scopes appends '
                    + GoogleConstants.SCOPE_CACHE_KEY_DIGEST_LENGTH + ' more, so shorten the key.'
                );
            }

            return scopedPartitionKey;
        }

        private String buildRequestedScopesDigest() {
            String joinedScopeUrls = GoogleScopeResolver.toScopeUrls(this.requestedScopes);
            Blob digest = Crypto.generateDigest('MD5', Blob.valueOf(joinedScopeUrls));
            return EncodingUtil.convertToHex(digest).left(GoogleConstants.SCOPE_CACHE_KEY_DIGEST_LENGTH);
        }

        private void resolvePlatformCacheStorage(String accessToken) {
            String cacheKey = this.buildPartitionKey();
            if (String.isBlank(cacheKey)) return;

            try {
                if (this.orgPartition != null) {
                    this.orgPartition.put(cacheKey, accessToken, GoogleConstants.DEFAULT_TOKEN_EXPIRATION_SECS);
                } else if (this.sessionPartition != null) {
                    this.sessionPartition.put(cacheKey, accessToken, GoogleConstants.DEFAULT_TOKEN_EXPIRATION_SECS);
                }
            } catch (Exception ex) {
                // No action required. This error occurs in asynchronous or flow invocable contexts.
            }
        }

        private GoogleCredential buildCredentialInfo(String accessToken, String tokenType) {
            GoogleCredential newCredential = new GoogleCredential();
            newCredential.accessToken = accessToken;
            newCredential.tokenType = tokenType;
            
            return newCredential;
        }
    }
}