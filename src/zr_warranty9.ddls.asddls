@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Serial Number CDS(From DN + Extend Warranty)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WARRANTY9 as 
select from I_SerialNumberDeliveryDocument
{
    key DeliveryDocument,
    key DeliveryDocumentItem,
    key Material,
    key SerialNumber as SerialNumber
    /* Associations */
//    _DeliveryDocument,
//    _DeliveryDocumentItem,
//    _Equipment,
//    _Product
}

union
 select from I_SalesDocumentItem as _SalesDocumentItem
   inner join I_DeliveryDocumentItem as _DeliveryDocumentItem on _SalesDocumentItem.SalesDocument = _DeliveryDocumentItem.ReferenceSDDocument
                                                              and _SalesDocumentItem.SalesDocumentItem = _DeliveryDocumentItem.ReferenceSDDocumentItem
//   inner join ztsd001                as _ZTSD001              on _SalesDocumentItem.Material = _ZTSD001.product                                                              
//                                                              and _SalesDocumentItem.MaterialGroup = _ZTSD001.product_group  
   inner join ztsd001                as _ZTSD001              on _SalesDocumentItem.Material = _ZTSD001.z_warranty_material                                             
{
   key _DeliveryDocumentItem.DeliveryDocument as DeliveryDocument,
   key _DeliveryDocumentItem.DeliveryDocumentItem as DeliveryDocumentItem,
   key _SalesDocumentItem.Material as Material,
   key cast( _SalesDocumentItem.YY1_WarrantySerial_SDI as zzesd069 ) as SerialNumber                                                          
}
where _ZTSD001.z_warranty_type = 'EXTEND'
