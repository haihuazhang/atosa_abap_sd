@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BackOrder Reoprt'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SSD029
  as select from    I_SalesDocument        as _SalesDocument
    left outer join I_SalesDocumentItem    as _SalesDocumentItem    on  _SalesDocument.SalesDocument                    =  _SalesDocumentItem.SalesDocument
                                                                    and (
                                                                       _SalesDocumentItem.SalesDocumentItemCategory     <> 'TAX'
                                                                       and _SalesDocumentItem.SalesDocumentItemCategory <> 'TAXN'
                                                                       and _SalesDocumentItem.SalesDocumentItemCategory <> 'CNLA'
                                                                     )
                                                                    and _SalesDocumentItem.SDDocumentRejectionStatus    =  'A'
  //                                                                    and _SalesDocumentItem.TotalDeliveryStatus          <> 'C'
  //                                                                    and _SalesDocumentItem.TotalDeliveryStatus          <> ''
  //  as select from    I_SalesDocumentItem          as _SalesDocumentItem
  //    left outer join I_SalesDocument              as _SalesDocument              on _SalesDocument.SalesDocument            =  _SalesDocumentItem.SalesDocument
  //                                                                                and(
  //                                                                                  _SalesDocument.OverallDeliveryStatus     <> 'C'
  //                                                                                  and _SalesDocument.OverallDeliveryStatus <> ''
  //                                                                                )
  //                                                                                and(
  //                                                                                  _SalesDocument.SDDocumentCategory        =  'C'
  //                                                                                  or _SalesDocument.SDDocumentCategory     =  'I'
  //                                                                                )
    left outer join I_Plant                as _Plant                on  _SalesDocumentItem.Plant = _Plant.Plant
                                                                    and _Plant.Language          = 'E'
  //    left outer join I_SalesDocItemPricingElement as _SalesDocItemPricingElement on  _SalesDocItemPricingElement.SalesDocument     = _SalesDocumentItem.SalesDocument
  //                                                                                and _SalesDocItemPricingElement.SalesDocumentItem = _SalesDocumentItem.SalesDocumentItem
  //                                                                                and _SalesDocItemPricingElement.ConditionType     = 'PPR0'
    left outer join I_BusinessPartner      as _BusinessPartner      on _BusinessPartner.BusinessPartner = _SalesDocument.SoldToParty
    left outer join I_SalesDocumentPartner as _SalesDocumentPartner on  _SalesDocumentPartner.SalesDocument   = _SalesDocument.SalesDocument
                                                                    and _SalesDocumentPartner.PartnerFunction = 'WE'
    left outer join I_Address_2            as _Address2             on _Address2.AddressID = _SalesDocumentPartner.AddressID
    left outer join I_DeliveryDocumentItem as _Delivery             on  _Delivery.ReferenceSDDocument     = _SalesDocumentItem.SalesDocument
                                                                    and _Delivery.ReferenceSDDocumentItem = _SalesDocumentItem.SalesDocumentItem
                                                                    and _Delivery.SDDocumentCategory      = 'J'
    left outer join ZR_SSD039              as _MaterialDocumentItem on  _MaterialDocumentItem.DeliveryDocument     = _Delivery.DeliveryDocument
                                                                    and _MaterialDocumentItem.DeliveryDocumentItem = _Delivery.DeliveryDocumentItem
{
  key _SalesDocumentItem.Material,
  key _SalesDocumentItem.Plant,
  key _SalesDocument.SalesDocument,
  key _SalesDocumentItem.SalesDocumentItem,
      _Plant.PlantName,
      cast(_SalesDocumentItem.ConfdDelivQtyInOrderQtyUnit as abap.dec(15,3))            as ConfdDelivQtyInOrderQtyUnit,
      _SalesDocument.SoldToParty                                                        as Customer,
      _SalesDocument.PurchaseOrderByCustomer,
      _SalesDocument.RequestedDeliveryDate,
      _SalesDocument.SalesDocumentDate,
      cast(_SalesDocumentItem.OrderQuantity as abap.dec(15,3))                          as OrderQuantity,
      cast(_SalesDocumentItem.NetAmount as abap.dec(15,2))                              as ConditionAmount,
      concat(_BusinessPartner.OrganizationBPName1,_BusinessPartner.OrganizationBPName2) as CustomerName,
      _SalesDocument.CreationDate,
      _Address2.CityName,
      _Address2.Region,
      cast(_SalesDocumentItem.ConfdDelivQtyInOrderQtyUnit as abap.dec(15,3))            as InventoryQuantity,
      cast(_SalesDocumentItem.ConfdDelivQtyInOrderQtyUnit as abap.dec(15,3))            as BackorderedQuantity,
      cast(_SalesDocumentItem.ConfdDelivQtyInOrderQtyUnit as abap.dec(15,3))            as Balance,
      case
      when _MaterialDocumentItem.GoodsMovementType = '601'
      then
      cast(_MaterialDocumentItem.QuantityInEntryUnit as abap.dec(15,3))
      else
       cast(0 as abap.dec(15,3))
      end                                                                               as OpenQty,
      cast(_SalesDocumentItem.NetAmount as abap.dec(15,2))                              as OpenValues,
      _SalesDocumentItem.ShippingPoint,
      ''                                                                                as flag,
      _SalesDocumentItem.StorageLocation,
      _BusinessPartner.YY1_ChainAccount_bus,
      _BusinessPartner.YY1_NationalAccount_bus,
      _BusinessPartner.YY1_NoRebateOffered_bus,
      _BusinessPartner.YY1_Properties1_bus,
      _BusinessPartner.YY1_Properties2_bus
}
where
        _SalesDocument.OverallSDProcessStatus <> ''
  and(
        _SalesDocument.SDDocumentCategory     =  'C'
    or  _SalesDocument.SDDocumentCategory     =  'I'
  )
  and(
        _SalesDocument.OverallDeliveryStatus  <> 'C'
    and _SalesDocument.OverallDeliveryStatus  <> ''
  )
union select from ZR_SSD047              as _Delivery
  left outer join I_SalesDocumentItem    as _SalesDocumentItem    on  _Delivery.ReferenceSDDocument                   =  _SalesDocumentItem.SalesDocument
                                                                  and _Delivery.ReferenceSDDocumentItem               =  _SalesDocumentItem.SalesDocumentItem
                                                                  and (
                                                                     _SalesDocumentItem.SalesDocumentItemCategory     <> 'TAX'
                                                                     and _SalesDocumentItem.SalesDocumentItemCategory <> 'TAXN'
                                                                     and _SalesDocumentItem.SalesDocumentItemCategory <> 'CNLA'
                                                                   )
                                                                  and _SalesDocumentItem.SDDocumentRejectionStatus    =  'A'
  left outer join I_OutboundDelivery     as _OutBoundDelivery     on  _OutBoundDelivery.OutboundDelivery           =  _Delivery.DeliveryDocument
                                                                  and (
                                                                     _OutBoundDelivery.DeliveryDocumentType        =  'LF'
                                                                     or _OutBoundDelivery.DeliveryDocumentType     =  'NLCC'
                                                                   )
                                                                  and _OutBoundDelivery.OverallGoodsMovementStatus <> 'C'
                                                                  and _OutBoundDelivery.OverallGoodsMovementStatus <> ''
  left outer join I_SalesDocument        as _SalesDocument        on  _SalesDocumentItem.SalesDocument     = _SalesDocument.SalesDocument
                                                                  and (
                                                                     _SalesDocument.SDDocumentCategory     = 'C'
                                                                     or _SalesDocument.SDDocumentCategory  = 'I'
                                                                   )
                                                                  and _SalesDocument.OverallDeliveryStatus = 'C'
  left outer join I_Plant                as _Plant                on  _SalesDocumentItem.Plant = _Plant.Plant
                                                                  and _Plant.Language          = 'E'
  left outer join I_BusinessPartner      as _BusinessPartner      on _BusinessPartner.BusinessPartner = _SalesDocument.SoldToParty
  left outer join I_SalesDocumentPartner as _SalesDocumentPartner on  _SalesDocumentPartner.SalesDocument   = _SalesDocument.SalesDocument
                                                                  and _SalesDocumentPartner.PartnerFunction = 'WE'
  left outer join I_Address_2            as _Address2             on _Address2.AddressID = _SalesDocumentPartner.AddressID
//  left outer join I_DeliveryDocumentItem as _Delivery             on  _Delivery.ReferenceSDDocument     = _SalesDocumentItem.SalesDocument
//                                                                  and _Delivery.ReferenceSDDocumentItem = _SalesDocumentItem.SalesDocumentItem
//                                                                  and _Delivery.SDDocumentCategory      = 'J'
//                                                                  and _Delivery.PickingStatus <> ''
//  left outer join ZR_SSD039              as _MaterialDocumentItem on  _MaterialDocumentItem.DeliveryDocument     = _Delivery.DeliveryDocument
//                                                                  and _MaterialDocumentItem.DeliveryDocumentItem = _Delivery.DeliveryDocumentItem
{
  key _SalesDocumentItem.Material,
  key _SalesDocumentItem.Plant,
  key _SalesDocument.SalesDocument,
  key _SalesDocumentItem.SalesDocumentItem,
      _Plant.PlantName,
      cast(_SalesDocumentItem.ConfdDelivQtyInOrderQtyUnit as abap.dec(15,3))            as ConfdDelivQtyInOrderQtyUnit,
      _SalesDocument.SoldToParty                                                        as Customer,
      _SalesDocument.PurchaseOrderByCustomer,
      _SalesDocument.RequestedDeliveryDate,
      _SalesDocument.SalesDocumentDate,
      cast(_SalesDocumentItem.OrderQuantity as abap.dec(15,3))                          as OrderQuantity,
      cast(_SalesDocumentItem.NetAmount as abap.dec(15,2))                              as ConditionAmount,
      concat(_BusinessPartner.OrganizationBPName1,_BusinessPartner.OrganizationBPName2) as CustomerName,
      _SalesDocument.CreationDate,
      _Address2.CityName,
      _Address2.Region,
      cast(_SalesDocumentItem.ConfdDelivQtyInOrderQtyUnit as abap.dec(15,3))            as InventoryQuantity,
      cast(_SalesDocumentItem.ConfdDelivQtyInOrderQtyUnit as abap.dec(15,3))            as BackorderedQuantity,
      cast(_SalesDocumentItem.ConfdDelivQtyInOrderQtyUnit as abap.dec(15,3))            as Balance,
      _Delivery.ActualDeliveryQuantity                                                  as OpenQty,
      cast(_SalesDocumentItem.NetAmount as abap.dec(15,2))                              as OpenValues,
      _SalesDocumentItem.ShippingPoint,
      'X'                                                                               as flag,
      _SalesDocumentItem.StorageLocation,
      _BusinessPartner.YY1_ChainAccount_bus,
      _BusinessPartner.YY1_NationalAccount_bus,
      _BusinessPartner.YY1_NoRebateOffered_bus,
      _BusinessPartner.YY1_Properties1_bus,
      _BusinessPartner.YY1_Properties2_bus
}
//where
//      _Delivery.SDDocumentCategory =  'J'
//  and _Delivery.PickingStatus      <> ''
