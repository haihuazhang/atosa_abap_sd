@EndUserText.label: 'Print CDS of Invoice Header'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_PSD010
  provider contract transactional_query
  as projection on ZR_PSD010
{
  key     BillingDocument,
          PostingStatus,
          BillingDocumentDate,
          PurchaseOrder,
          SalesOrder,

          // Billto
          _BilltoAddress.OrganizationName1     as BilltoName1,
          _BilltoAddress.OrganizationName2     as BilltoName2,
          _BilltoAddress.StreetName            as BilltoStreetName,
          _BilltoAddress.CityName              as BilltoCityName,
          _BilltoAddress.Region                as BilltoRegion,
          _BilltoAddress.PostalCode            as BilltoPostalCode,

          // Deliveryto
          _DeliverytoAddress.OrganizationName1 as DeliverytoName1,
          _DeliverytoAddress.OrganizationName2 as DeliverytoName2,
          _DeliverytoAddress.StreetName        as DeliverytoStreetName,
          _DeliverytoAddress.CityName          as DeliverytoCityName,
          _DeliverytoAddress.Region            as DeliverytoRegion,
          _DeliverytoAddress.PostalCode        as DeliverytoPostalCode,

          _SalesRepAddress.OrganizationName1   as SalesRepName1,
          _SalesRepAddress.OrganizationName2   as SalesRepName2,

          CustomerID,
          PaymentTerms,
          _PaymentTermsText.PaymentTermsName,

          DueDate,

          Plant,
          _Plant.PlantName,

          ShippingType,
          _ShippingTypeText.ShippingTypeName,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_013'
  virtual InvoiceRemarks : abap.sstring( 255 ),

          TrackingNumber,
          TotalNetAmount,
          TotalTaxAmount,
          InvoiceTotal,
          OpenBalance,
          Currency,


          @Semantics.largeObject: { mimeType: 'MimeType',
                                    fileName: 'FileName',
                                    contentDispositionPreference: #ATTACHMENT }
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_013'
  virtual Pdf            : zzattachment,
          @UI.hidden: true
          @Semantics.mimeType: true
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_SD_013'
  virtual MimeType       : zzmime_type,

          isAllowSend,
          BillingDocumentType,

          @UI.hidden: true
          BilltoAddressID,
          @UI.hidden: true
          DeliveryAddressID,
          @UI.hidden: true
          ShipFrom,
          @UI.hidden: true
          FileName,
          @UI.hidden: true
          SalesOrganization,

          /* Associations */
          //          _InvoiceItem : redirected to ZC_PSD011

          @ObjectModel.filter.enabled: false
          _InvoiceItem
}
