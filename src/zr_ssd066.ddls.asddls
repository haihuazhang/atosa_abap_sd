@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Business Partner Email and PhoneNumber'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_SSD066
  as select distinct from I_BillingDocumentPartnerBasic as _BillingPartnerBasic
{
  key _BillingPartnerBasic.Customer,
  key _BillingPartnerBasic.PartnerFunction,
      _BillingPartnerBasic.AddressID
}
where
       _BillingPartnerBasic.Customer        <> ''
  and(
       _BillingPartnerBasic.PartnerFunction =  'Z1'
    or _BillingPartnerBasic.PartnerFunction =  'Z2'
    or _BillingPartnerBasic.PartnerFunction =  'Z3'
    or _BillingPartnerBasic.PartnerFunction =  'Z4'
    or _BillingPartnerBasic.PartnerFunction =  'Z5'
    or _BillingPartnerBasic.PartnerFunction =  'Z6'
    or _BillingPartnerBasic.PartnerFunction =  'Z7'
    or _BillingPartnerBasic.PartnerFunction =  'Z8'
    or _BillingPartnerBasic.PartnerFunction =  'Z9'
    or _BillingPartnerBasic.PartnerFunction =  'ZP'
  )
