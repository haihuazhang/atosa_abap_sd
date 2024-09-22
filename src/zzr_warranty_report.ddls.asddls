@EndUserText.label: 'CDS of ZI_WARRANTY_REPORT'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_WARRANTY_REPORT'
@UI: {
    headerInfo: {
        typeNamePlural: 'Results',
//        title: {
//            type: #STANDARD,
//            value: 'salesdocument'
//        },
        description: {
            value: 'serialnumber1'
        }
    },
    presentationVariant: [{
        sortOrder: [{
            by: 'salesdocument',
            direction: #ASC
        },{
            by: 'salesdocumentitem',
            direction: #ASC
        }]
    }]
}
define custom entity ZZR_WARRANTY_REPORT
{
  key uuid                        : sysuuid_x16;
      @UI.facet                   : [
      {
           label                  : 'General Information',
           id                     : 'GeneralInfo',
           type                   : #COLLECTION,
           position               : 10
         },{
       id                         : 'idIdentification',
       type                       : #IDENTIFICATION_REFERENCE,
       label                      : 'General Information',
       position                   : 10
      } ]
      @UI                         :{ lineItem:[ { position: 30, importance: #HIGH, label: 'Serial Number' } ],
           selectionField         : [{ position: 80 }] }
      @UI.identification          : [ {position: 30 ,label: 'Serial Number'} ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Equipment', element: 'SerialNumber' }}]
      @EndUserText.label          : 'Serial Number'
      serialnumber1               : zzesd069;
      @UI                         :{ lineItem:[ { position: 230, importance: #LOW, label: 'DN No.' } ]}
      @UI.identification          : [ {position: 230 ,label: 'DN No.'} ]
      @EndUserText.label          : 'DN No.'
      subsequentdocument1         : zzesd016;
      @UI                         :{ lineItem:[ { position: 10, importance: #HIGH, label: 'Product ID' } ],
           selectionField         : [{ position: 100 }] }
      @UI.identification          : [ {position: 10 ,label: 'Product ID'} ]
      //      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductPlantBasic', element: 'Product' }, additionalBinding: [{ localElement: 'plant', element: 'Plant', usage: #FILTER }]}]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductPlantBasic', element: 'Product' }}]
      @EndUserText.label          : 'Product ID'
      material1                   : zzesd006;
      @UI                         :{ lineItem:[ { position: 50, importance: #HIGH, label: 'Warranty Material' } ]}
      @UI.identification          : [ {position: 50 ,label: 'Warranty Material'} ]
      @EndUserText.label          : 'Warranty Material'
      zwarrantymaterial           : abap.char(40);
      @UI                         :{ lineItem:[ { position: 60, importance: #HIGH, label: 'Warranty Type' } ]}
      @UI.identification          : [ {position: 60 ,label: 'Warranty Type'} ]
      @EndUserText.label          : 'Warranty Type'
      zwarrantytype               : abap.char(40);
      @UI                         :{ lineItem:[ { position: 70, importance: #LOW, label: 'Valid From' } ]}
      @UI.identification          : [ {position: 70 ,label: 'Valid From'} ]
      @EndUserText.label          : 'Valid From'
      zwarrantyvalidfrom          : abap.dats;
      @UI                         :{ lineItem:[ { position: 80, importance: #LOW, label: 'Valid To' } ]}
      @UI.identification          : [ {position: 80 ,label: 'Valid To'} ]
      @EndUserText.label          : 'Valid To'
      zwarrantyvalidto            : abap.dats;
      @UI                         :{ lineItem:[ { position: 90, importance: #LOW, label: 'Active' ,criticality:'active'} ]}
      @UI.identification          : [ {position: 90 ,label: 'Active'} ]
      @EndUserText.label          : 'Active'
      zactive                     : abap.char( 10 );
      @UI                         :{ lineItem:[ { position: 20, importance: #HIGH, label: 'Material Description' } ]}
      @UI.identification          : [ {position: 20 ,label: 'Material Description'} ]
      @EndUserText.label          : 'Material Description'
      salesdocumentitemtext       : abap.char(40);
      @UI                         :{ lineItem:[ { position: 100, importance: #LOW, label: 'SO No.' } ],
           selectionField         : [{ position: 10 }] }
      @UI.identification          : [ {position: 100 ,label: 'SO No.'} ]
      //      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesOrderItemCube', element: 'SalesOrder' }}]
      @EndUserText.label          : 'SO No.'
      salesdocument               : zzesd014;
      @UI                         :{ lineItem:[ { position: 110, importance: #LOW, label: 'SO Item No.' } ]}
      @UI.identification          : [ {position: 110 ,label: 'SO Item No.'} ]
      @EndUserText.label          : 'SO Item No.'
      salesdocumentitem           : abap.numc(6);
      @UI                         :{ lineItem:[ { position: 130, importance: #LOW, label: 'SO Item Qty Unit' } ]}
      @UI.identification          : [ {position: 130 ,label: 'SO Item Qty Unit'} ]
      @EndUserText.label          : 'SO Item Qty Unit'
      @Semantics.unitOfMeasure    : true
      @ObjectModel.foreignKey.association: '_OrderUnit'

      OrderQuantityUnit           : meins;
      @UI                         :{ lineItem:[ { position: 120, importance: #LOW, label: 'SO Item Qty' } ]}
      @UI.identification          : [ {position: 120 ,label: 'SO Item Qty'} ]
      @EndUserText.label          : 'SO Item Qty'
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      orderquantity               : abap.quan( 15, 3 );
      @UI                         :{ lineItem:[ { position: 140, importance: #LOW, label: 'SO Extend Warranty Material' } ]}
      @UI.identification          : [ {position: 140 ,label: 'SO Extend Warranty Material'} ]
      @EndUserText.label          : 'SO Extend Warranty Material'
      yy1_warrantymaterial_sdi    : abap.char(40);
      @UI                         :{ lineItem:[ { position: 150, importance: #LOW, label: 'SO Extend Warranty Serial' } ]}
      @UI.identification          : [ {position: 150 ,label: 'SO Extend Warranty Serial'} ]
      @EndUserText.label          : 'SO Extend Warranty Serial'
      yy1_warrantyserial_sdi      : abap.char(40);
      @UI                         :{ lineItem:[ { position: 160, importance: #LOW, label: 'SO Type' } ],
           selectionField         : [{ position: 70 }] }
      @UI.identification          : [ {position: 160 ,label: 'SO Type'} ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesDocumentType', element: 'SalesDocumentType' }}]
      @EndUserText.label          : 'SO Type'
      @ObjectModel.foreignKey.association: '_SalesOrderType'
      salesdocumenttype           : abap.char(4);
      @UI                         :{ lineItem:[ { position: 170, importance: #LOW, label: 'SO Creation Date' } ],
           selectionField         : [{ position: 50 }] }
      @UI.identification          : [ {position: 170 ,label: 'SO Creation Date'} ]
      //        @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesDocumentItem', element: 'CreationDate' }}]
      @EndUserText.label          : 'SO Creation Date'
      creationdate                : abap.dats;
      @UI                         :{ lineItem:[ { position: 180, importance: #LOW, label: 'Customer Reference' } ],
           selectionField         : [{ position: 60 }] }
      @UI.identification          : [ {position: 180 ,label: 'Customer Reference'} ]
      //         @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesDocumentItem', element: 'PurchaseOrderByCustomer' }}]
      @EndUserText.label          : 'Customer Reference'
      purchaseorderbycustomer     : abap.char(35);
      @UI                         :{ lineItem:[ { position: 190, importance: #LOW, label: 'Sold to Party' } ],
           selectionField         : [{ position: 40 }] }
      @UI.identification          : [ {position: 190 ,label: 'Sold to Party'} ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Customer', element: 'Customer' }}]
      @EndUserText.label          : 'Sold to Party'
      soldtoparty                 : zzesd013;
      @UI                         :{ lineItem:[ { position: 210, importance: #LOW, label: 'Ship to Party' } ]}
      @UI.identification          : [ {position: 210 ,label: 'Ship to Party'} ]
      @EndUserText.label          : 'Ship to Party'
      shiptoparty                 : zzesd013;
      @UI                         :{ lineItem:[ { position: 400, importance: #LOW, label: 'Referenece Document' } ]}
      @UI.identification          : [ {position: 400 ,label: 'Referenece Document'} ]
      @EndUserText.label          : 'Referenece Document'
      referencesddocument         : zzesd014;
      @UI                         :{ lineItem:[ { position: 410, importance: #LOW, label: 'Referenece Item' } ]}
      @UI.identification          : [ {position: 410 ,label: 'Referenece Item'} ]
      @EndUserText.label          : 'Referenece Item'
      referencesddocumentitem     : abap.numc(6);
      @UI                         :{ lineItem:[ { position: 420, importance: #LOW, label: 'Reference Document Category' } ]}
      @UI.identification          : [ {position: 420 ,label: 'Reference Document Category'} ]
      @EndUserText.label          : 'Reference Document Category'
      referencesddocumentcategory : abap.char(4);
      @UI                         :{ lineItem:[ { position: 40, importance: #HIGH, label: 'Old Serial Number' } ],
           selectionField         : [{ position: 100 }] }
      @UI.identification          : [ {position: 40 ,label: 'Old Serial Number'} ]
      @EndUserText.label          : 'Old Serial Number'
      zoldserialnumber            : abap.char(40);
      @UI                         :{ lineItem:[ { position: 200, importance: #LOW, label: 'Sold to Party Name' } ]}
      @UI.identification          : [ {position: 200 ,label: 'Sold to Party Name'} ]
      @EndUserText.label          : 'Sold to Party Name'
      fullname1                   : abap.char(80);
      @UI                         :{ lineItem:[ { position: 220, importance: #LOW, label: 'Ship to Party Name' } ]}
      @UI.identification          : [ {position: 220 ,label: 'Ship to Party Name'} ]
      @EndUserText.label          : 'Ship to Party Name'
      fullname2                   : abap.char(80);
      @UI                         :{ lineItem:[ { position: 240, importance: #LOW, label: 'DN Item No.' } ]}
      @UI.identification          : [ {position: 240 ,label: 'DN Item No.'} ]
      @EndUserText.label          : 'DN Item No.'
      subsequentdocumentitem1     : abap.numc(6);
      @UI                         :{ lineItem:[ { position: 250, importance: #LOW, label: 'DN Item Material No.' } ]}
      @UI.identification          : [ {position: 250 ,label: 'DN Item Material No.'} ]
      @EndUserText.label          : 'DN Item Material No.'
      material2                   : abap.char(40);
      @UI                         :{ lineItem:[ { position: 260, importance: #LOW, label: 'DN Item Qty' } ]}
      @UI.identification          : [ {position: 260 ,label: 'DN Item Qty'} ]
      @EndUserText.label          : 'DN Item Qty'
      @Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
      actualdeliveryquantity      : abap.quan(13,3);
      @UI                         :{ lineItem:[ { position: 270, importance: #LOW, label: 'DN Item Qty Unit' } ]}
      @UI.identification          : [ {position: 270 ,label: 'DN Item Qty Unit'} ]
      @EndUserText.label          : 'DN Item Qty Unit'
      @Semantics.unitOfMeasure    : true
      @ObjectModel.foreignKey.association: '_DeliveryQuantityUnit'
      DeliveryQuantityUnit        : meins;
      @UI                         :{ lineItem:[ { position: 280, importance: #LOW, label: 'DN Type' } ]}
      @UI.identification          : [ {position: 280 ,label: 'DN Type'} ]
      @EndUserText.label          : 'DN Type'
      deliverydocumenttype        : abap.char(4);
      @UI                         :{ lineItem:[ { position: 290, importance: #LOW, label: 'DN Post Goods Issue Date' } ]}
      @UI.identification          : [ {position: 290 ,label: 'DN Post Goods Issue Date'} ]
      @EndUserText.label          : 'DN Post Goods Issue Date'
      actualgoodsmovementdate     : abap.dats;
      @UI                         :{ lineItem:[ { position: 300, importance: #LOW, label: 'Billing No.' } ]}
      @UI.identification          : [ {position: 310 ,label: 'Billing No.'} ]
      @EndUserText.label          : 'Billing No.'
      subsequentdocument2         : zzesd015;
      @UI                         :{ lineItem:[ { position: 310, importance: #LOW, label: 'Billing Item No.' } ]}
      @UI.identification          : [ {position: 320 ,label: 'Billing Item No.'} ]
      @EndUserText.label          : 'Billing Item No.'
      subsequentdocumentitem2     : abap.numc(6);
      @UI                         :{ lineItem:[ { position: 320, importance: #LOW, label: 'Billing Item Material No.' } ]}
      @UI.identification          : [ {position: 330 ,label: 'Billing Item Material No.'} ]
      @EndUserText.label          : 'Billing Item Material No.'
      material3                   : abap.char(40);
      @UI                         :{ lineItem:[ { position: 330, importance: #LOW, label: 'Billing Item Qty' } ]}
      @UI.identification          : [ {position: 340 ,label: 'Billing Item Qty'} ]
      @EndUserText.label          : 'Billing Item Qty'
      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      billingquantity             : abap.quan(13,3);
      @UI                         :{ lineItem:[ { position: 340, importance: #LOW, label: 'Billing Item Qty Unit' } ]}
      @UI.identification          : [ {position: 350 ,label: 'Billing Item Qty Unit'} ]
      @EndUserText.label          : 'Billing Item Qty Unit'
      @Semantics.unitOfMeasure    : true
      @ObjectModel.foreignKey.association: '_BillingQuantityUnit'
      BillingQuantityUnit         : meins;
      @UI                         :{ lineItem:[ { position: 350, importance: #LOW, label: 'Extend Warranty Price' } ]}
      @UI.identification          : [ {position: 360 ,label: 'Extend Warranty Price'} ]
      @EndUserText.label          : 'Extend Warranty Price'
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      conditionamount             : abap.curr(15, 2);
      @UI                         :{ lineItem:[ { position: 360, importance: #LOW, label: 'Transaction Currency' } ]}
      @UI.identification          : [ {position: 370 ,label: 'Transaction Currency'} ]
      @EndUserText.label          : 'Transaction Currency'
      @Semantics.currencyCode     : true
      @ObjectModel.foreignKey.association: '_Currency'
      TransactionCurrency         : abap.cuky(5);
      @UI                         :{ lineItem:[ { position: 370, importance: #LOW, label: 'Billing Post Date' } ]}
      @UI.identification          : [ {position: 380 ,label: 'Billing Post Date'} ]
      @EndUserText.label          : 'Billing Post Date'
      postingdate                 : abap.dats;
      @UI                         :{ lineItem:[ { position: 380, importance: #LOW, label: 'Posting Status' } ]}
      @UI.identification          : [ {position: 390 ,label: 'Posting Status'} ]
      @EndUserText.label          : 'Posting Status'
      accountingpostingstatus     : abap.char(1);
      @UI                         :{ lineItem:[ { position: 390, importance: #LOW, label: 'Billing Type' } ]}
      @UI.identification          : [ {position: 400 ,label: 'Billing Type'} ]
      @EndUserText.label          : 'Billing Type'
      billingdocumenttype         : abap.char(4);
      @UI                         :{ lineItem:[ { position: 430, importance: #LOW, label: 'Referenece Material No.' } ]}
      @UI.identification          : [ {position: 440 ,label: 'Referenece Material No.'} ]
      @EndUserText.label          : 'Referenece Material No.'
      material4                   : abap.char(40);
      @UI                         :{ lineItem:[ { position: 440, importance: #LOW, label: 'Referenece Serial No.' } ]}
      @UI.identification          : [ {position: 450 ,label: 'Referenece Serial No.'} ]
      @EndUserText.label          : 'Referenece Serial No.'
      serialnumber2               : zzesd069;
//      @UI                         :{ selectionField: [{ position: 20 }] }
      @UI                         :{ lineItem:[ { position: 450, importance: #LOW, label: 'DN Plant' } ]}
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Plant', element: 'Plant' }}]
      @EndUserText.label          : 'DN Plant'
      plant2                       : abap.char(4);
      @UI                         :{ lineItem:[ { position: 460, importance: #LOW, label: 'DN Storage Location' } ]}
      @UI.identification          : [ {position: 300 ,label: 'DN Storage Location'} ]
      @EndUserText.label          : 'DN Storage Location'
      storagelocation2             : abap.char(4);
      @UI                         :{ selectionField: [{ position: 30 }] }
      @UI                         :{ lineItem:[ { position: 470, importance: #LOW, label: 'Sales Organization' } ]}
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesOrganization', element: 'SalesOrganization' }}]
      @EndUserText.label          : 'Sales Organization'
      salesorganization           : abap.char(4);
      @UI                         :{ selectionField: [{ position: 20 }] }
      @UI                         :{ lineItem:[ { position: 480, importance: #LOW, label: 'SO Plant' } ]}
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Plant', element: 'Plant' }}]
      @EndUserText.label          : 'SO Plant'
      plant1                       : abap.char(4);
      @UI                         :{ lineItem:[ { position: 490, importance: #LOW, label: 'SO Storage Location' } ]}
      @UI.identification          : [ {position: 490 ,label: 'SO Storage Location'} ]
      @EndUserText.label          : 'SO Storage Location'
      storagelocation1             : abap.char(4);
      @UI                         :{ lineItem:[ { position: 500, importance: #LOW, label: 'Warranty Days' } ]}
      zwarrantymonths             : zzesd011;
      @UI                         :{ lineItem:[ { position: 510, importance: #LOW, label: 'Rejection Reason Code' } ]}
      @EndUserText.label          : 'Rejection Reason Code'
      SalesDocumentRjcnReason     : abap.char(2);
      @UI                         :{ lineItem:[ { position: 520, importance: #LOW, label: 'Legacy' } ]}
      @EndUserText.label          : 'Legacy'
      Legacy                      : abap.char(1);
      @UI                         :{ lineItem:[ { position: 530, importance: #LOW, label: 'Equipment' } ]}
      @EndUserText.label          : 'Equipment'
      Equipment                   : zzesd072;
      @UI                         :{ lineItem:[ { position: 540, importance: #LOW, label: 'Manual Changed' } ]}
      @EndUserText.label          : 'Manual Changed'
      ManualChanged               : abap.char(1);
      active                      : abap.char(1);
      SalesDocumentItemCategory   : abap.char(3);
      CreationDateTime            : abap.char(14);
      @ObjectModel.sort.enabled   : false
      @ObjectModel.filter.enabled : false
      _OrderUnit                  : association [0..1] to I_UnitOfMeasure on $projection.OrderQuantityUnit = _OrderUnit.UnitOfMeasure;
      @ObjectModel.sort.enabled   : false
      @ObjectModel.filter.enabled : false
      _BillingQuantityUnit        : association [0..1] to I_UnitOfMeasure on $projection.BillingQuantityUnit = _BillingQuantityUnit.UnitOfMeasure;
      @ObjectModel.sort.enabled   : false
      @ObjectModel.filter.enabled : false
      _DeliveryQuantityUnit       : association [0..1] to I_UnitOfMeasure on $projection.DeliveryQuantityUnit = _DeliveryQuantityUnit.UnitOfMeasure;
      @ObjectModel.sort.enabled   : false
      @ObjectModel.filter.enabled : false
      _SalesOrderType             : association [0..1] to I_SalesOrderType on $projection.salesdocumenttype = _SalesOrderType.SalesOrderType;
      @ObjectModel.sort.enabled   : false
      @ObjectModel.filter.enabled : false
      _Currency                   : association [0..1] to I_Currency on $projection.TransactionCurrency = _Currency.Currency;
      //         zwarrantymonths:abap.int4;
      //         creationdatetime:abap.char(14);

}
