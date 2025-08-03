trigger ValidacionSeguimientoTrigger on Seguimiento__c (before insert, before update) {
    // Solo proceso si hay registros con etpa "Pendiente"
    List<Seguimiento__c> seguimientosPendientes = new List<Seguimiento__c>();
    Set<Id> contactIds = new Set<Id>();
    
    // Filtrar solo los registros que son "Pendiente" y tienen Contacto
    for (Seguimiento__c seg : Trigger.new) {
        if (seg.Contacto__c != null && seg.Etapa__c == 'Pendiente') {
            seguimientosPendientes.add(seg);
            contactIds.add(seg.Contacto__c);
        }
    }
    if (seguimientosPendientes.isEmpty()) {
        return;
    }
    
    // Contar registros pendientes existentes por contacto
    Map<Id, Integer> contactPendingCount = new Map<Id, Integer>();
    
    // Query para contar registros pendientes existentes
    List<AggregateResult> results = [
        SELECT Contacto__c contacto, COUNT(Id) cantidad
        FROM Seguimiento__c 
        WHERE Contacto__c IN :contactIds 
        AND Etapa__c = 'Pendiente'
        AND Id NOT IN :Trigger.new
        GROUP BY Contacto__c
    ];
    
    // Llenar el mapa con los conteos
    for (AggregateResult ar : results) {
        Id contactId = (Id)ar.get('contacto');
        Integer count = (Integer)ar.get('cantidad');
        contactPendingCount.put(contactId, count);
    }
    
    // Validar cada registro pendiente
    for (Seguimiento__c seg : seguimientosPendientes) {
        Integer currentCount = contactPendingCount.get(seg.Contacto__c);
        
        if (currentCount == null) {
            currentCount = 0;
        }
        
        // Si ya tiene 5 o más registros pendientes
        if (currentCount >= 5) {
            seg.addError(
                'No se pueden crear más de 5 registros pendientes para el mismo contacto. ' +
                'Este contacto ya tiene ' + currentCount + ' seguimientos pendientes. ' +
                'Complete o cambie la etapa de algunos seguimientos antes de crear nuevos.'
            );
        }
    }
}