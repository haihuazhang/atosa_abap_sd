@EndUserText.label: 'Print CDS of Invoice Item'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_PSD011
  //  provider contract transactional_query
  as projection on ZR_PSD011
{
  key     BillingDocument,
  key     BillingDocumentItem,
          Material,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_014'
  virtual Description : abap.sstring( 255 ),

          UnitPrice,
          DiscountAmount,
          Currency,
          Quantity,
          Unit,
          NetAmount,

          WarrantyMaterial,
          WarrantySerial,
          BusinessName,
          FirstName,
          LastName,
          PhoneNumber,
          Street,

          SalesSDDocumentCategory,

          @UI.hidden: true
          BillingDocumentItemText,
          @UI.hidden: true
          WarrantyInfo,
          @UI.hidden: true
          WarrantyRegistInfo,

          /* Associations */
          _InvoiceItemSerialNumber : redirected to ZC_PSD012
}
