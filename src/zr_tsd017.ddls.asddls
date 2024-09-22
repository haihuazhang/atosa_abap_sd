@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTSD017'
define root view entity ZR_TSD017
  as select from ztsd017
{
  key serialnumber1 as Serialnumber1,
  key subsequentdocument1 as Subsequentdocument1,
  key subsequentdocumentitem1 as Subsequentdocumentitem1,
  key zwarrantytype as Zwarrantytype,
  key zwarrantymaterial as Zwarrantymaterial,
  key subsequentdocument2 as Subsequentdocument2,
  key subsequentdocumentitem2 as Subsequentdocumentitem2,
  material1 as Material1,
  zwarrantyvalidfrom as Zwarrantyvalidfrom,
  zwarrantyvalidto as Zwarrantyvalidto,
  zactive as Zactive,
  active as Active,
  salesdocumentitemtext as Salesdocumentitemtext,
  salesdocument as Salesdocument,
  salesdocumentitem as Salesdocumentitem,
  orderquantityunit as Orderquantityunit,
  @Semantics.quantity.unitOfMeasure: 'Orderquantityunit'
  orderquantity as Orderquantity,
  yy1_warrantymaterial_sdi as Yy1WarrantymaterialSdi,
  yy1_warrantyserial_sdi as Yy1WarrantyserialSdi,
  salesdocumenttype as Salesdocumenttype,
  creationdate as Creationdate,
  purchaseorderbycustomer as Purchaseorderbycustomer,
  soldtoparty as Soldtoparty,
  shiptoparty as Shiptoparty,
  referencesddocument as Referencesddocument,
  referencesddocumentitem as Referencesddocumentitem,
  referencesddocumentcategory as Referencesddocumentcategory,
  storagelocation1 as StorageLocation1,
  plant1 as Plant1,
  zoldserialnumber as Zoldserialnumber,
  fullname1 as Fullname1,
  fullname2 as Fullname2,
  material2 as Material2,
  @Semantics.quantity.unitOfMeasure: 'Deliveryquantityunit'
  actualdeliveryquantity as Actualdeliveryquantity,
  deliveryquantityunit as Deliveryquantityunit,
  deliverydocumenttype as Deliverydocumenttype,
  actualgoodsmovementdate as Actualgoodsmovementdate,
  storagelocation2 as StorageLocation2,
  material3 as Material3,
  billingquantityunit as Billingquantityunit,
  @Semantics.quantity.unitOfMeasure: 'Billingquantityunit'
  billingquantity as Billingquantity,
  @Semantics.amount.currencyCode: 'Transactioncurrency'
  conditionamount as Conditionamount,
  transactioncurrency as Transactioncurrency,
  postingdate as Postingdate,
  accountingpostingstatus as Accountingpostingstatus,
  billingdocumenttype as Billingdocumenttype,
  material4 as Material4,
  serialnumber2 as Serialnumber2,
  zwarrantymonths as Zwarrantymonths,
  plant2 as Plant2,
  salesorganization as Salesorganization,
  salesdocumentitemcategory as Salesdocumentitemcategory,
  salesdocumentrjcnreason as Salesdocumentrjcnreason,
  legacy as Legacy,
  creationdatetime as CreationDateTime,
  manualchanged as ManualChanged,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
