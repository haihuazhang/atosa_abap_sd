@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Packing Slip PrintOut - Item'
define root view entity ZR_PSD015 as select from I_DeliveryDocumentItem as _DNItem
//composition of target_data_source_name as _association_name
association [0..*] to ZR_PSD016 as _SerialNumber on _SerialNumber.DeliveryDocument = $projection.DeliveryDocument
                                                 and _SerialNumber.DeliveryDocumentItem = $projection.DeliveryDocumentItem
{
    
//    _association_name // Make association public
    key _DNItem.DeliveryDocument,
    key _DNItem.DeliveryDocumentItem,
    _DNItem.Product as Material,
    _DNItem.ActualDeliveryQuantity,
    _DNItem.DeliveryQuantityUnit,
    _SerialNumber
    
}

where _DNItem.PickingStatus <> ''
