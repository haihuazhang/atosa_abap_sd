@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Packing Slip PrintOut - Header SO'
define root view entity ZR_PSD014
  as select from I_DeliveryDocumentItem as _DNItem
  //composition of target_data_source_name as _association_name
    inner join   I_SalesDocument        as _SO on _DNItem.ReferenceSDDocument = _SO.SalesDocument
{

      //    _association_name // Make association public
  key _DNItem.DeliveryDocument,
      max( _DNItem.Plant ) as Plant,
      max( _SO.CreationDate ) as CreationDate,
      max( _SO.SalesDocument ) as SalesDocument,
      max( _SO.PurchaseOrderByCustomer ) as PurchaseOrderByCustomer,
      max( _SO.YY1_WhiteGlovesShipto_SDH ) as YY1_WhiteGlovesShipto_SDH,
      max( _SO.YY1_BusinessName_SDH ) as YY1_BusinessName_SDH,
      max( _SO.SalesOrganization) as SalesOrganization

}
group by _DNItem.DeliveryDocument
