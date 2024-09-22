@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Metadata.allowExtensions: true
define root view entity ZC_SSD027
   provider contract transactional_query
  as projection on ZR_SSD027
{
    key BillingDocument,
    key BillingDocumentItem,
    CustomerReference,
    PostingDate,
    Customer,
    SalesOrganization,
    SalesDocument,
    CreationDate,
    Product,
    MaterialGroup,
    Plant,
//    @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
    BillingQuantity,
//    BillingQuantityUnit,
//    @Semantics.amount.currencyCode: 'TransactionCurrency'
    NetAmount,
//    @Semantics.amount.currencyCode: 'TransactionCurrency'
    TaxAmount,
//    @Semantics.amount.currencyCode: 'TransactionCurrency'
    CostAmount,
    YY1_Project_SDH,
    YY1_WarrantyMaterial_BDI,
    YY1_WarrantySerial_BDI,
//    TransactionCurrency,
    BillingDocumentTypeName,
    AddressSearchTerm1,
    AddressSearchTerm2,
    CustomerGroupName,
    PlantName,
    ProductGroupName,
    ProductGroupText,
    ShipToParty,
    AdditionalCustomerGroup1Name,
    ManualPrice,
    CustomerName,
    SoldToRegion,
    ShipToPartyName,
    ShipToStreet,
    ShipToCity,
    ShipToRegion,
    SalesEmployee,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_010'
  virtual SerialNumber : abap.string,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_011'
  virtual MaterialDescription : abap.sstring( 255 ),
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_012'
  virtual FreeText : abap.sstring( 255 ),
  BillingDocumentIsCancelled,
  CancelledBillingDocument,
  YY1_ChainAccount_bus,
  YY1_NationalAccount_bus,
  YY1_NoRebateOffered_bus,
  YY1_Properties1_bus,
  YY1_Properties2_bus
}
