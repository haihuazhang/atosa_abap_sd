@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Get Scanned Qty CDS for PGI'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_SSD019
  as select from ZR_TSD004
    inner join   I_DeliveryDocumentItem as _DeliveryItem on  _DeliveryItem.DeliveryDocument     = ZR_TSD004.DeliveryNumber
                                                                 and _DeliveryItem.DeliveryDocumentItem = ZR_TSD004.DeliveryItem
  //composition of target_data_source_name as _association_name
{
  key ZR_TSD004.DeliveryNumber                                                as OutboundDelivery,
  key ZR_TSD004.DeliveryItem                                                  as OutboundDeliveryItem,
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      cast ( count( distinct ZR_TSD004.SerialNumber ) as abap.quan( 13, 3 ) ) as ScannedQty,
      _DeliveryItem.DeliveryQuantityUnit
      //    key Material,
      //    key SerialNumber,
      //    Plant,
      //    StorageLocation,
      //    PostingDate,
      //    PgiIndicator,
      //    OldSerialNumber,
      //    CreatedBy,
      //    CreatedAt,
      //    LastChangedBy,
      //    LastChangedAt,
      //    LocalLastChangedAt,
      //    _association_name // Make association public
}
group by
  ZR_TSD004.DeliveryNumber,
  ZR_TSD004.DeliveryItem,
  _DeliveryItem.DeliveryQuantityUnit


union select from ZR_TSD012
{
  key DeliveryNumber  as OutboundDelivery,
  key DeliveryItem    as OutboundDeliveryItem,
      Scannedquantity as ScannedQty,
      Unitofmeasure   as DeliveryQuantityUnit

}
