public class GoogleBigFileEntity {
    @AuraEnabled public String resumableSessionId;
    @AuraEnabled public Long resumableLatestByte;
    public GoogleFileEntity file;
}