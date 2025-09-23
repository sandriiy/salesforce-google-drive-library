public class GoogleBigFileEntity {
    @AuraEnabled public String resumableSessionId;
    @AuraEnabled public Long resumableLatestByte;
    @AuraEnabled public GoogleFileEntity file;
}