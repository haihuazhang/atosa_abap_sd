@EndUserText.label: 'CDS of ZR_SSD029'
@ObjectModel.query.implementedBy:'ABAP:ZZCL_SD_015'
@UI: {
    headerInfo: {
        typeNamePlural: 'Results',
        description: {
            value: 'Material'
        }
    }
}
define custom entity ZR_SSD030
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
      @UI                         :{ lineItem:[ { position: 10, importance: #HIGH, label: 'Item' } ],
           selectionField         : [{ position: 10 }] }
      @UI.identification          : [ {position: 10 ,label: '   Item'} ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductPlantBasic', element: 'Product' }}]
      @EndUserText.label          : 'Item'
      Material                    : zzesd006;
      @UI                         :{ lineItem:[ { position: 20, importance: #LOW, label: 'Whse Code' } ],
          selectionField          : [{ position: 20 }]}
      @UI.identification          : [ {position: 20 ,label: 'Whse Code'} ]
      @EndUserText.label          : 'Whse Code'
      Plant                       : abap.char(4);
      @UI                         :{ lineItem:[ { position: 30, importance: #LOW, label: 'Whse Name' } ]}
      @UI.identification          : [ {position: 30 ,label: 'Whse Name'} ]
      @EndUserText.label          : 'Whse Code'
      PlantName                   : abap.char(30);
      @UI                         :{ lineItem:[ { position: 40, importance: #HIGH, label: 'Regular Bin Inventory' } ]}
      @UI.identification          : [ {position: 40 ,label: 'Regular Bin Inventory'} ]
      @EndUserText.label          : 'Regular Bin Inventory'
      //      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      InventoryQuantity           : abap.dec( 12, 0 );
//      InventoryQuantity           : abap.numc(15);
      @UI                         :{ lineItem:[ { position: 50, importance: #HIGH, label: 'Committed' } ]}
      @UI.identification          : [ {position: 50 ,label: 'Committed'} ]
      @EndUserText.label          : 'Warranty Material'
      //      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      ConfdDelivQtyInOrderQtyUnit : abap.dec( 12, 0 );
//      ConfdDelivQtyInOrderQtyUnit : abap.numc(15);
      @UI                         :{ lineItem:[ { position: 60, importance: #HIGH, label: 'Backordered' } ]}
      @UI.identification          : [ {position: 60 ,label: 'Backordered'} ]
      @EndUserText.label          : 'Warranty Type'
      //      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      BackorderedQuantity         : abap.dec( 12, 0 );
//      BackorderedQuantity         : abap.numc(15);
      @UI                         :{ lineItem:[ { position: 70, importance: #LOW, label: 'Customer Code' } ],
      selectionField              : [{ position: 30 }]}
      @UI.identification          : [ {position: 70 ,label: 'Customer Code'} ]
      @EndUserText.label          : 'Customer Code'
      Customer                    : zzesd013;
      @UI                         :{ lineItem:[ { position: 80, importance: #LOW, label: 'Customer Name' } ]}
      @UI.identification          : [ {position: 80 ,label: 'Customer Name'} ]
      @EndUserText.label          : 'Valid To'
      CustomerName                : abap.char( 80 );
      @UI                         :{ lineItem:[ { position: 90, importance: #LOW, label: 'PO No.' } ]}
      @UI.identification          : [ {position: 90 ,label: 'PO No.'} ]
      @EndUserText.label          : 'Active'
      PurchaseOrderByCustomer     : abap.char( 35 );
      @UI                         :{ lineItem:[ { position: 100, importance: #HIGH, label: 'Sales Order No.' } ],
      selectionField              : [{ position: 40 }]}
      @UI.identification          : [ {position: 100 ,label: 'Sales Order No.'} ]
      @EndUserText.label          : 'Sales Order No.'
      SalesDocument               : zzesd014;
      @UI                         :{ lineItem:[ { position: 110, importance: #LOW, label: 'Shipping Date' } ]}
      @UI.identification          : [ {position: 110 ,label: 'Shipping Date'} ]
      @EndUserText.label          : 'Shipping Date'
      RequestedDeliveryDate       : abap.dats;
      @UI                         :{ lineItem:[ { position: 120, importance: #LOW, label: 'Document Date' } ]}
      @UI.identification          : [ {position: 120 ,label: 'Document Date'} ]
      @EndUserText.label          : 'Document Date'
      SalesDocumentDate           : abap.dats;
      @UI                         :{ lineItem:[ { position: 130, importance: #LOW, label: 'Creation Date' } ]}
      @UI.identification          : [ {position: 130 ,label: 'Creation Date'} ]
      @EndUserText.label          : 'City'
      CreationDate                : abap.dats;
      @UI                         :{ lineItem:[ { position: 140, importance: #LOW, label: 'City' } ]}
      @UI.identification          : [ {position: 140 ,label: 'City'} ]
      @EndUserText.label          : 'City'
      CityName                    : abap.char(40);
      @UI                         :{ lineItem:[ { position: 150, importance: #LOW, label: 'State' } ]}
      @UI.identification          : [ {position: 150 ,label: 'State'} ]
      @EndUserText.label          : 'State'
      Region                      : abap.char(3);
      //      @UI                         :{ lineItem:[ { position: 200, importance: #LOW, label: 'SO Item Qty Unit' } ]}
      //      @UI.identification          : [ {position: 200 ,label: 'SO Item Qty Unit'} ]
      //      @EndUserText.label          : 'SO Item Qty Unit'
      //      @Semantics.unitOfMeasure    : true
      //      @ObjectModel.foreignKey.association: '_OrderUnit'
      //      OrderQuantityUnit           : meins;
      @UI                         :{ lineItem:[ { position: 160, importance: #LOW, label: 'Ordered Qty' } ]}
      @UI.identification          : [ {position: 160 ,label: 'Ordered Qty'} ]
      @EndUserText.label          : 'Ordered Qty'
      //      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      orderquantity               : abap.dec( 12, 0 );
//      orderquantity               : abap.numc(15);
      @UI                         :{ lineItem:[ { position: 170, importance: #LOW, label: 'Open Qty' } ]}
      @UI.identification          : [ {position: 170 ,label: 'Open Qty'} ]
      @EndUserText.label          : 'Open Qty'
      //      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      OpenQty                     : abap.dec(12,0);
//      OpenQty                     : abap.numc(15);
      @UI                         :{ lineItem:[ { position: 180, importance: #LOW, label: 'Balance' } ]}
      @UI.identification          : [ {position: 180 ,label: 'Balance'} ]
      @EndUserText.label          : 'Balance'
      //      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      Balance                     : abap.dec(12,0);
//      Balance                     : abap.numc(15);
      @UI                         :{ lineItem:[ { position: 190, importance: #LOW, label: 'Unit Price' } ]}
      @UI.identification          : [ {position: 190 ,label: 'Unit Price'} ]
      @EndUserText.label          : 'Unit Price'
      //      @Semantics.amount.currencyCode: 'TransactionCurrency'
      conditionamount             : abap.dec(13, 0);
//      conditionamount             : abap.numc(15);
      //      @UI                         :{ lineItem:[ { position: 190, importance: #LOW, label: 'Transaction Currency' } ]}
      //      @UI.identification          : [ {position: 190 ,label: 'Transaction Currency'} ]
      //      @EndUserText.label          : 'Transaction Currency'
      //      @Semantics.currencyCode     : true
      //      @ObjectModel.foreignKey.association: '_Currency'
      //      TransactionCurrency         : abap.cuky(5);
      @UI                         :{ lineItem:[ { position: 200, importance: #LOW, label: 'Open Values' } ]}
      @UI.identification          : [ {position: 200 ,label: 'Open Values'} ]
      @EndUserText.label          : 'Open Values'
      //      @Semantics.amount.currencyCode: 'TransactionCurrency'
      OpenValues                  : abap.dec(13,0);
//      OpenValues                  : abap.numc(15);
      @UI                         :{ lineItem:[ { position: 210, importance: #LOW, label: 'ChainAccount' } ]}
      @UI.identification          : [ {position: 210 ,label: 'ChainAccount'} ]
      @EndUserText.label          : 'Open Values'
      YY1_ChainAccount_bus        : abap.char(3);
      @UI                         :{ lineItem:[ { position: 220, importance: #LOW, label: 'NationalAccount' } ]}
      @UI.identification          : [ {position: 220 ,label: 'NationalAccount'} ]
      @EndUserText.label          : 'Open Values'
      YY1_NationalAccount_bus     : abap.char(3);
      @UI                         :{ lineItem:[ { position: 230, importance: #LOW, label: 'NoRebateOffered' } ]}
      @UI.identification          : [ {position: 230 ,label: 'NoRebateOffered'} ]
      @EndUserText.label          : 'Open Values'
      YY1_NoRebateOffered_bus     : abap.char(3);
      @UI                         :{ lineItem:[ { position: 240, importance: #LOW, label: 'Properties1' } ]}
      @UI.identification          : [ {position: 240 ,label: 'Properties1'} ]
      @EndUserText.label          : 'Open Values'
      YY1_Properties1_bus         : abap.char(4);
      @UI                         :{ lineItem:[ { position: 250, importance: #LOW, label: 'Properties2' } ]}
      @UI.identification          : [ {position: 250 ,label: 'Properties2'} ]
      @EndUserText.label          : 'Open Values'
      YY1_Properties2_bus         : abap.char(4);
      ShippingPoint               : abap.char(4);
      flag                        : abap.char(1);
      StorageLocation             : abap.char(4);
      //      @ObjectModel.sort.enabled   : false
      //      @ObjectModel.filter.enabled : false
      //      _OrderUnit                  : association [0..1] to I_UnitOfMeasure on $projection.OrderQuantityUnit = _OrderUnit.UnitOfMeasure;
      //      @ObjectModel.sort.enabled   : false
      //      @ObjectModel.filter.enabled : false
      //      _Currency                   : association [0..1] to I_Currency on $projection.TransactionCurrency = _Currency.Currency;

}
