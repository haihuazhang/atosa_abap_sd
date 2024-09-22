@EndUserText.label: 'Parameter of Create/Delete Serial Number'
define abstract entity ZR_SSD022
{
    OutboundDelivery : vbeln_vl;
    OutboundDeliveryItem : abap.numc( 6 );
    SerialNumber : zzesd023;
}
