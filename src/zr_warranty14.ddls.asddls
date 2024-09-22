@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'history data of warranty report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_WARRANTY14
  as select from    ZR_TSD017   as _warranty14
    left outer join I_Equipment as _Equipment on  _Equipment.Material     = _warranty14.Material1
                                              and _Equipment.SerialNumber = _warranty14.Serialnumber1
{
  _warranty14.Serialnumber1,
  _warranty14.Subsequentdocument1,
  _warranty14.Subsequentdocumentitem1,
  _warranty14.Zwarrantytype,
  _warranty14.Zwarrantymaterial,
  _warranty14.Subsequentdocument2,
  _warranty14.Subsequentdocumentitem2,
  _warranty14.Material1,
  _warranty14.Zwarrantyvalidfrom,
  _warranty14.Zwarrantyvalidto,
  cast(_warranty14.Zactive as abap.char(10)) as Zactive,
  case
   when _warranty14.Zactive = 'X'
    then 3
   else 2
  end                                        as active,
  _warranty14.Salesdocumentitemtext,
  _warranty14.Salesdocument,
  _warranty14.Salesdocumentitem,
  _warranty14.Orderquantityunit,
  @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
  _warranty14.Orderquantity,
  _warranty14.Yy1WarrantymaterialSdi         as Yy1_Warrantymaterial_Sdi,
  _warranty14.Yy1WarrantyserialSdi           as Yy1_Warrantyserial_Sdi,
  _warranty14.Salesdocumenttype,
  _warranty14.Creationdate,
  _warranty14.Purchaseorderbycustomer,
  _warranty14.Soldtoparty,
  _warranty14.Shiptoparty,
  _warranty14.Referencesddocument,
  _warranty14.Referencesddocumentitem,
  _warranty14.Referencesddocumentcategory,
  _warranty14.StorageLocation1,
  _warranty14.Plant1,
  _warranty14.Zoldserialnumber,
  _warranty14.Fullname1,
  _warranty14.Fullname2,
  _warranty14.Material2,
  @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
  _warranty14.Actualdeliveryquantity,
  _warranty14.Deliveryquantityunit,
  _warranty14.Deliverydocumenttype,
  _warranty14.Actualgoodsmovementdate,
  _warranty14.StorageLocation2,
  _warranty14.Material3,
  _warranty14.Billingquantityunit,
  @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
  _warranty14.Billingquantity                as BillingQuantity,
  @Semantics.amount.currencyCode: 'TransactionCurrency'
  _warranty14.Conditionamount,
  _warranty14.Transactioncurrency,
  _warranty14.Postingdate,
  _warranty14.Accountingpostingstatus,
  _warranty14.Billingdocumenttype,
  _warranty14.Material4,
  _warranty14.Serialnumber2,
  _warranty14.Zwarrantymonths,
  _warranty14.Plant2,
  _warranty14.Salesorganization,
  _warranty14.Salesdocumentitemcategory,
  _warranty14.Salesdocumentrjcnreason,
  _warranty14.Legacy,
  _warranty14.CreationDateTime,
  _warranty14.ManualChanged,
  _Equipment.Equipment

}
