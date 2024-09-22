CLASS lhc_udf DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR udf
        RESULT result,
      copyUDFToDN FOR MODIFY
        IMPORTING keys FOR ACTION udf~copyUDFToDN,
      copyUDFToBIL FOR MODIFY
        IMPORTING keys FOR ACTION udf~copyUDFToBIL,
      copyUDFToSO FOR MODIFY
        IMPORTING keys FOR ACTION udf~copyUDFToSO.
ENDCLASS.

CLASS lhc_udf IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD copyUDFToDN.

    DATA:
    udfs       TYPE TABLE FOR CREATE zr_tsd007\\udf.

    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_inital_cid).
    ASSERT key_with_inital_cid IS INITIAL.

    READ ENTITIES OF zr_tsd007 IN LOCAL MODE
      ENTITY udf
       ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(udf_origin)
    FAILED failed.

    LOOP AT udf_origin ASSIGNING FIELD-SYMBOL(<udf>).
      APPEND VALUE #( %cid     = keys[ 1 ]-%cid
                      %data    = CORRESPONDING #( <udf> EXCEPT BaseFreight LiftGate LimitedAccess OtherFees OtherFeesDescription ) )
        TO  udfs ASSIGNING FIELD-SYMBOL(<new_udf>).

    ENDLOOP.

    "create new BO instance
    MODIFY ENTITIES OF zr_tsd007 IN LOCAL MODE
      ENTITY udf
        CREATE FIELDS ( ApInvoice1 ApInvoice2 BaseFreight BaseFreight1 BaseFreight2 BusinessAddress BusinessName CarrierContactName CarrierName
                        CheckAmount CheckDate CheckNumber ClaimAmount ClaimAttachments ClaimNumber ClaimOutcome ClaimStatus
                        ContactEmailAddress ContactPhoneNo DiscountCreditAmount FilingDate FirstName FollowUpDate LastName LiftGate LiftGate1
                        LiftGate2 LimitedAccess LimitedAccess1 LimitedAccess2 Note OriginalAtosaInvoiceNo OtherFees OtherFees1 OtherFees2
                        OtherFeesDescription OtherFeesDescription1 OtherFeesDescription2 PhoneNumber ResidentialFee1 ResidentialFee2 StoreNumber Waers )
          WITH udfs
      MAPPED mapped
      FAILED failed
      REPORTED reported.

*    mapped-udf   =  mapped_create-udf .


  ENDMETHOD.

  METHOD copyUDFToBIL.
    DATA:
  udfs       TYPE TABLE FOR CREATE zr_tsd007\\udf.

    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_inital_cid).
    ASSERT key_with_inital_cid IS INITIAL.

    READ ENTITIES OF zr_tsd007 IN LOCAL MODE
      ENTITY udf
       ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(udf_origin)
    FAILED failed.

    LOOP AT udf_origin ASSIGNING FIELD-SYMBOL(<udf>).
      APPEND VALUE #( %cid     = keys[ 1 ]-%cid
                      %data    = CORRESPONDING #( <udf>   ) )
        TO  udfs ASSIGNING FIELD-SYMBOL(<new_udf>).

      SELECT SINGLE salesdocument FROM I_SalesDocument
        WHERE yy1_udf_sdh = @<udf>-uuid
        INTO @<new_udf>-SalesOrder.

    ENDLOOP.

    "create new BO instance
    MODIFY ENTITIES OF zr_tsd007 IN LOCAL MODE
      ENTITY udf
        CREATE FIELDS ( ApInvoice1 ApInvoice2 BaseFreight BaseFreight1 BaseFreight2 BusinessAddress BusinessName CarrierContactName CarrierName
                        CheckAmount CheckDate CheckNumber ClaimAmount ClaimAttachments ClaimNumber ClaimOutcome ClaimStatus
                        ContactEmailAddress ContactPhoneNo DiscountCreditAmount FilingDate FirstName FollowUpDate LastName LiftGate LiftGate1
                        LiftGate2 LimitedAccess LimitedAccess1 LimitedAccess2 Note OriginalAtosaInvoiceNo OtherFees OtherFees1 OtherFees2
                        OtherFeesDescription OtherFeesDescription1 OtherFeesDescription2 PhoneNumber ResidentialFee1 ResidentialFee2 StoreNumber Waers  SalesOrder )
          WITH udfs
      MAPPED mapped
      FAILED failed
      REPORTED reported.
  ENDMETHOD.

  METHOD copyUDFToSO.

    DATA:
   udfs       TYPE TABLE FOR CREATE zr_tsd007\\udf.

    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_inital_cid).
    ASSERT key_with_inital_cid IS INITIAL.

    READ ENTITIES OF zr_tsd007 IN LOCAL MODE
      ENTITY udf
       ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(udf_origin)
    FAILED failed.

    LOOP AT udf_origin ASSIGNING FIELD-SYMBOL(<udf>).
      APPEND VALUE #( %cid     = keys[ 1 ]-%cid
                      %data    = CORRESPONDING #( <udf> ) )
        TO  udfs ASSIGNING FIELD-SYMBOL(<new_udf>).

    ENDLOOP.

    "create new BO instance
    MODIFY ENTITIES OF zr_tsd007 IN LOCAL MODE
      ENTITY udf
        CREATE FIELDS ( ApInvoice1 ApInvoice2 BaseFreight BaseFreight1 BaseFreight2 BusinessAddress BusinessName CarrierContactName CarrierName
                        CheckAmount CheckDate CheckNumber ClaimAmount ClaimAttachments ClaimNumber ClaimOutcome ClaimStatus
                        ContactEmailAddress ContactPhoneNo DiscountCreditAmount FilingDate FirstName FollowUpDate LastName LiftGate LiftGate1
                        LiftGate2 LimitedAccess LimitedAccess1 LimitedAccess2 Note OriginalAtosaInvoiceNo OtherFees OtherFees1 OtherFees2
                        OtherFeesDescription OtherFeesDescription1 OtherFeesDescription2 PhoneNumber ResidentialFee1 ResidentialFee2 StoreNumber Waers
                         )
          WITH udfs
      MAPPED mapped
      FAILED failed
      REPORTED reported.
  ENDMETHOD.

ENDCLASS.
