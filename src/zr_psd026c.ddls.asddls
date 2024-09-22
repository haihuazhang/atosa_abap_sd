@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Print CDS of Delivery Note'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_PSD026C
  as select from    I_DeliveryDocument     as _OutboundDelivery
    left outer join I_BusinessUserBasic    as _BusinessUserBasic on _OutboundDelivery.CreatedByUser = _BusinessUserBasic.UserID
    left outer join ZR_PSD007              as _SalesDoc          on _OutboundDelivery.DeliveryDocument = _SalesDoc.DeliveryDocument


    left outer join I_SalesDocument        as _SalesOrder        on _SalesDoc.SalesDocument = _SalesOrder.SalesDocument
    left outer join I_BusinessPartner      as _BusinessPartner   on _OutboundDelivery.SoldToParty = _BusinessPartner.BusinessPartner
    left outer join I_SalesDocumentPartner as _SalesOrderPartner on  _SalesOrderPartner.SalesDocument   = _SalesOrder.SalesDocument
                                                                 and _SalesOrderPartner.PartnerFunction = 'WE'
    left outer join I_BusinessPartner      as _BusinessPartnerY  on _SalesOrderPartner.Customer = _BusinessPartnerY.BusinessPartner
    left outer join I_Address_2            as _Address2          on _Address2.AddressID = _SalesOrderPartner.AddressID
    left outer join I_ShippingTypeText     as _ShippingTypeText  on  _ShippingTypeText.ShippingType = _OutboundDelivery.ShippingType
                                                                 and _ShippingTypeText.Language     = 'E'
    join            ZR_PSD002              as _Plant             on _Plant.DeliveryDocument = _OutboundDelivery.DeliveryDocument

  association [0..*] to ZR_PSD027 as _Item on _Item.DeliveryDocument = $projection.DeliveryDocument
{
  key cast( _OutboundDelivery.DeliveryDocument as zzesd016 )                                             as DeliveryDocument,
      _OutboundDelivery.CreationDate,
      _OutboundDelivery.OverallPickingStatus,
      _OutboundDelivery.PlannedGoodsIssueDate,
      _BusinessUserBasic.PersonFullName,
      _SalesDoc.SalesDocument,
      _SalesOrder.PurchaseOrderByCustomer,
      case
      when (_BusinessPartner.OrganizationBPName1 is not initial and _BusinessPartner.OrganizationBPName2 is not initial)
      then
      concat ( concat(_BusinessPartner.OrganizationBPName1,'-') ,_BusinessPartner.OrganizationBPName2)
      when (_BusinessPartner.OrganizationBPName1 is not initial and _BusinessPartner.OrganizationBPName2 is initial)
      then
      _BusinessPartner.OrganizationBPName1
      when (_BusinessPartner.OrganizationBPName1 is initial and _BusinessPartner.OrganizationBPName2 is not initial)
      then
      _BusinessPartner.OrganizationBPName2
      end                                                                                                as Customer,
      case
      when (_SalesOrder.YY1_BusinessName_SDH is not initial )
      then
      _SalesOrder.YY1_BusinessName_SDH
      else
      _BusinessPartnerY.BusinessPartnerName
      end                                                                                                as YY1_BusinessName_SDH,
      _Address2.StreetName,
      concat_with_space(concat_with_space(_Address2.CityName,_Address2.Region,1),_Address2.PostalCode,1) as CityRegionZipCode,
      _Address2.Country,
      concat(concat(_Plant.Plant,'-'),_Plant.PlantName)                                                  as PlantName,
      _ShippingTypeText.ShippingTypeName                                                                 as ShippingTypeName,
      //      $session.system_date as CurrentDate,
      concat_with_space(
      concat(
      concat(
      concat(substring(cast(tstmp_current_utctimestamp() as abap.char(17)),5,2),'/'),concat(substring(cast(tstmp_current_utctimestamp() as abap.char(17)),7,2),'/')),
      substring(cast(tstmp_current_utctimestamp() as abap.char(17)),1,4)),
      concat(
      concat(
      concat(substring(cast(tstmp_current_utctimestamp() as abap.char(17)),9,2),':'),concat(substring(cast(tstmp_current_utctimestamp() as abap.char(17)),11,2),':')),
      substring(cast(tstmp_current_utctimestamp() as abap.char(17)),13,2)),1)                            as CurrentDateTime,
      _OutboundDelivery.ShippingPoint,
      //      concat(substring(cast(tstmp_current_utctimestamp() as abap.char(17)),1,8),substring(cast(tstmp_current_utctimestamp() as abap.char(17)),9,6)) as CurrentDateTime,
      _Item
}where _OutboundDelivery.OverallGoodsMovementStatus = 'C' and _OutboundDelivery.SDDocumentCategory = 'J'
