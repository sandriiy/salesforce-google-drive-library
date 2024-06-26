public inherited sharing class GoogleAuthorizationCodeFlow {
    public class Builder {
        private String apexAuthorizerName;

        public Builder setLocalGoogleAuthorizer(String apexClassName) {
            this.apexAuthorizerName = apexClassName;
            return this;
        }

        public GoogleCredential build() {
            return executeGoogleAuthFlow();
        }

        private GoogleCredential executeGoogleAuthFlow() {
            Type authorizerType = Type.forName(this.apexAuthorizerName);
            GoogleAuthorizer authorizerInstance = (GoogleAuthorizer) authorizerType.newInstance();

            String accessToken = authorizerInstance.retrieveAccessToken();
            return buildCredentialInfo(accessToken, 'Bearer');
        }

        private GoogleCredential buildCredentialInfo(String accessToken, String tokenType) {
            GoogleCredential newCredential = new GoogleCredential();
            newCredential.accessToken = accessToken;
            newCredential.tokenType = tokenType;
            
            return newCredential;
        }
    }
}