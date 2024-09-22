@EndUserText.label: '111.01 AR Invoice List-All'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_SSD056
  provider contract transactional_query
  as projection on ZR_SSD056
{
  key     BillingDocument,
  key     BillingDocumentItem,
          @ObjectModel: { text.element: [ 'BillingDocumentTypeName' ] }
          BillingDocumentType,
          SalesOrganization,
          SoldToParty,
          BusinessPartnerIDByExtSystem,
          BusinessPartnerName,
          YY1_Project_BDH,
          OrganizationBPName,
          BillingDocumentDate,
          BillingDocumentIsCancelled,
          CancelledBillingDocument,
          TotalAmount,
          @Semantics.currencyCode: true
          TransactionCurrency,
          @ObjectModel: { text.element: [ 'CustomerGroupName' ] }
          CustomerGroup,
          CompanyCode,
          @ObjectModel: { text.element: [ 'PlantName' ] }
          Plant,

          _JournalEntryItem.NetDueDate,

          _SSD055.PurchaseOrderByCustomer,
          @ObjectModel: { text.element: [ 'PersonFullName' ] }
          _SSD055.CreatedByUser,
          _SSD055.YY1_BusinessName_SDH,

          @UI.hidden: true
          _BillingDocumentTypeText.BillingDocumentTypeName,
          @UI.hidden: true
          _CustomerGroupText.CustomerGroupName,
          @UI.hidden: true
          _Plant.PlantName,
          @UI.hidden: true
          _SSD055._BusinessUserBasic.PersonFullName,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_027'
          @Semantics.amount.currencyCode: 'TransactionCurrency'
  virtual PaidtoDate      : abap.curr( 23, 2 ),

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_027'
  virtual DocumentStatus  : abap.char( 1 ),

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_027'
  virtual InvoiceRemarks  : abap.sstring( 255 ),

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_027'
  virtual InternalRemarks : abap.sstring( 255 )

}
