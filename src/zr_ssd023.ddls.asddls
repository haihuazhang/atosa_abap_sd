@EndUserText.label: 'Parameter of Set Picked Qty'
define abstract entity ZR_SSD023
{
    outbound_delivery      : zzesd016;
    outbound_delivery_item : zzesd017;
    @Semantics.quantity.unitOfMeasure: 'delivery_quantity_unit'
    scanned_quantity       : menge_d;
    delivery_quantity_unit : meins;
}
