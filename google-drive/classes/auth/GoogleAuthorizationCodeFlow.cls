public inherited sharing class GoogleAuthorizationCodeFlow {
    public class Builder {
        private String apexAuthorizerName;
        private Cache.OrgPartition orgPartition;
        private Cache.SessionPartition sessionPartition;
        private String partitionKey;
        private String cachedAccessToken;

        public Builder setLocalGoogleAuthorizer(String apexClassName) {
            this.apexAuthorizerName = apexClassName;
            return this;
        }

        public Builder setLocalPlatformCache(Cache.OrgPartition orgPartition, String key) {
            this.orgPartition = orgPartition;
            this.partitionKey = key;

            if (orgPartition.contains(key)) {
                this.cachedAccessToken = (String) orgPartition.get(key);
            }

            return this;
        }

        public Builder setLocalPlatformCache(Cache.SessionPartition sessionPartition, String key) {
            this.sessionPartition = sessionPartition;
            this.partitionKey = key;

			try {
				if (sessionPartition.contains(key)) {
					this.cachedAccessToken = (String) sessionPartition.get(key);
				}
			} catch(Exception ex) {
				// No action required. This error occurs in asynchronous or flow invocable contexts.
			}

            return this;
        }

        public GoogleCredential build() {
            return executeGoogleAuthFlow();
        }

        private GoogleCredential executeGoogleAuthFlow() {
            if (String.isNotBlank(this.cachedAccessToken)) {
                return buildCredentialInfo(this.cachedAccessToken, 'Bearer');
            } else {
                Type authorizerType = Type.forName(this.apexAuthorizerName);
                GoogleAuthorizer authorizerInstance = (GoogleAuthorizer) authorizerType.newInstance();

                String accessToken = authorizerInstance.retrieveAccessToken();
                resolvePlatformCacheStorage(accessToken);
                return buildCredentialInfo(accessToken, 'Bearer');
            }
        }

        private void resolvePlatformCacheStorage(String accessToken) {
            if (String.isBlank(this.partitionKey)) return;

			try {
				if (this.orgPartition != null) {
					this.orgPartition.put(this.partitionKey, accessToken, GoogleConstants.DEFAULT_TOKEN_EXPIRATION_SECS);
				} else if (this.sessionPartition != null) {
					this.sessionPartition.put(this.partitionKey, accessToken, GoogleConstants.DEFAULT_TOKEN_EXPIRATION_SECS);
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