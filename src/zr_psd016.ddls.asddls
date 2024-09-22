@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Packing Slip PrintOut - Serial Number'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_PSD016
  as select from    I_SerialNumberDeliveryDocument as _SN
    left outer join ZR_TMM001                      as _OldSN on  _SN.Material     = _OldSN.Product
                                                             and _SN.SerialNumber = _OldSN.Zserialnumber
  //composition of target_data_source_name as _association_name
{

      //    _association_name // Make association public
  key _SN.Equipment,
  key _SN.DeliveryDocument,
  key _SN.DeliveryDocumentItem,
      _SN.Material,
      case when _OldSN.Zoldserialnumber is not null and _OldSN.Zoldserialnumber <> '' then
       cast( concat( concat( concat ( _SN.SerialNumber , '(' ) , _OldSN.Zoldserialnumber ) , ')')  as abap.char( 60 ) )
       else
       cast( _SN.SerialNumber as abap.char( 60 ) )
       end as SerialNumber

      //      _SN._DeliveryDocument,
      //      _SN._DeliveryDocumentItem,
      //      _SN._Equipment,
      //      _SN._Product
}

//union select from I_DeliveryDocumentItem as _DNItem
//  inner join I_ProductPlantBasic as _ProductPlant on _ProductPlant.Plant = _DNItem.Plant
//                                            and _ProductPlant.Product = _DNItem.Material
//  left outer join            ztsd001                as _extend on _DNItem.Material = _extend.z_warranty_material
//{
//  key cast( 1 as abap.char( 18 ))                                                                                                          as Equipment,
//  key _DNItem.DeliveryDocument,
//  key _DNItem.DeliveryDocumentItem,
//      _DNItem.Material,
//
//      case when _extend.z_warranty_material is null then 'N/A'
//      else
//      cast( concat( concat( concat( _DNItem.YY1_WarrantySerial_DLI , '(' ) , _DNItem.YY1_WarrantyMaterial_DLI ) , ')' ) as abap.char(60) ) end as SerialNumber
//
//}
// where _ProductPlant.SerialNumberProfile = ''
