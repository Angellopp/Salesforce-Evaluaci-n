public with sharing class SeguimientoController {
    @AuraEnabled(cacheable=true)
    public static List<Seguimiento__c> getSeguimientosByContact(Id contactId) {
        try {
            if (contactId == null) {
                return new List<Seguimiento__c>();
            }
            
            return [
                SELECT Id, Name, Etapa__c, Descripcion__c, Fecha_Objetivo__c, Es_prioritario__c
                FROM Seguimiento__c 
                WHERE Contacto__c = :contactId
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
                LIMIT 100
            ];
        } catch (Exception e) {
            System.debug('Error in getSeguimientosByContact: ' + e.getMessage());
            throw new AuraHandledException('Error loading seguimientos: ' + e.getMessage());
        }
    }
}