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
            String refreshToken = authorizerInstance.retieveRefreshToken();

            return buildCredentialInfo(accessToken, 'Bearer', refreshToken);
        }

        private GoogleCredential buildCredentialInfo(String accessToken, String tokenType, String refreshToken) {
            GoogleCredential newCredential = new GoogleCredential();
            newCredential.accessToken = accessToken;
            newCredential.tokenType = tokenType;
            newCredential.refreshToken = refreshToken;
            
            return newCredential;
        }
    }
}