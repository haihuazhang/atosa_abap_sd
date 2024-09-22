CLASS lhc_zr_tsd004 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zr_tsd004
        RESULT result,

      getScannedQty FOR READ
        IMPORTING keys FOR FUNCTION zr_tsd004~getScannedQty RESULT result,
      createScannedRecord FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd004~createScannedRecord,
      deleteScannedRecord FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd004~deleteScannedRecord RESULT result,
      checkAllItemsScanned FOR READ
        IMPORTING keys FOR FUNCTION zr_tsd004~checkAllItemsScanned RESULT result,
      postGoodsIssue FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd004~postGoodsIssue RESULT result,
      checkItemScanned FOR READ
        IMPORTING keys FOR FUNCTION zr_tsd004~checkItemScanned RESULT result,
      changeQuantity FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd004~changeQuantity RESULT result,
      deleteSerialNumber FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd004~deleteSerialNumber RESULT result,
      changePickedQuantity FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd004~changePickedQuantity RESULT result,
      writeBackSerialNumber FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd004~writeBackSerialNumber RESULT result,
      checkAllItemsFullyScanned FOR READ
        IMPORTING keys FOR FUNCTION zr_tsd004~checkAllItemsFullyScanned RESULT result,
      writeBackSerialNumberDN FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd004~writeBackSerialNumberDN RESULT result.
ENDCLASS.

CLASS lhc_zr_tsd004 IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD getScannedQty.
    DATA: lv_outbounddelivery     TYPE vbeln_vl,
          lv_outbounddeliveryitem TYPE n LENGTH 6.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*      lv_outbounddelivery = | { <key>-%param-OutboundDelivery ALPHA = IN  } |.
      lv_outbounddelivery = <key>-%param-OutboundDelivery.
      lv_outbounddeliveryitem = <key>-%param-OutboundDeliveryItem.
    ENDLOOP.
    " Check Serial Number Profile
    SELECT SINGLE SerialNumberProfile
        FROM zr_ssd018 WITH PRIVILEGED ACCESS AS item
        WHERE item~OutboundDelivery = @lv_outbounddelivery
          AND item~OutboundDeliveryItem = @lv_outbounddeliveryitem
        INTO @DATA(lv_serialnumberprofile).

    IF lv_serialnumberprofile NE ''.

      SELECT COUNT( * ) FROM zr_tsd004 WITH PRIVILEGED ACCESS AS a
                             JOIN I_SerialNumberDeliveryDocument AS b ON a~DeliveryNumber = b~DeliveryDocument
                                                                      AND a~DeliveryItem = b~DeliveryDocumentItem
                                                                      AND a~SerialNumber = b~SerialNumber
        WHERE DeliveryNumber = @lv_outbounddelivery
            AND DeliveryItem = @lv_outbounddeliveryitem
          INTO @DATA(lv_count).
    ELSE.
      SELECT SINGLE ScannedQuantity FROM zr_tsd012 WITH PRIVILEGED ACCESS
        WHERE DeliveryNumber = @lv_outbounddelivery
           AND DeliveryItem = @lv_outbounddeliveryitem
           INTO @lv_count.

    ENDIF.

    result = VALUE #( ( %cid =  <key>-%cid %param-ScannedQuantity = lv_count ) ).

  ENDMETHOD.

  METHOD createScannedRecord.
*    select SINGLE * FROM
*    if( strlen(  ) )
    DATA : lt_tsd004          TYPE TABLE FOR CREATE zr_tsd004,
           lv_serialnumber    TYPE zzesd023,
           lv_oldserialnumber TYPE zzesd012.
    ASSERT lines( keys ) > 0.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      " strlen = 18
      IF strlen( <key>-%param-SerialNumber ) = 18.
        lv_serialnumber = <key>-%param-SerialNumber.
      ELSE.
        SELECT SINGLE zserialnumber FROM zr_tmm001 WITH PRIVILEGED ACCESS WHERE Product = @<key>-%param-Product
                                         AND Zoldserialnumber = @<key>-%param-SerialNumber
            INTO @lv_serialnumber.
        lv_oldserialnumber = <key>-%param-SerialNumber.
      ENDIF.



      SELECT SINGLE * FROM zr_ssd018 WITH PRIVILEGED ACCESS WHERE OutboundDelivery = @<key>-%param-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
                                              AND OutboundDeliveryItem = @<key>-%param-OutboundDeliveryItem
        INTO @DATA(ls_outbounddeliveryitem).

      SELECT SINGLE * FROM I_SerialNumberDeliveryDocument WITH PRIVILEGED ACCESS WHERE DeliveryDocument = @<key>-%param-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
                                                     AND DeliveryDocumentItem = @<key>-%param-OutboundDeliveryItem
                                                     AND Material = @<key>-%param-Product
                                                     AND SerialNumber = @lv_serialnumber
          INTO @DATA(Ls_serialnumber).
      IF sy-subrc NE 0.
        "When S2-2-1-⑥Scanned Qty = S2-2-1-⑤Order Qty
        "IF the user scans serial number again
        READ ENTITIES OF zr_tsd004 IN LOCAL MODE ENTITY zr_tsd004
        EXECUTE getScannedQty FROM VALUE #( ( %param-OutboundDelivery = <key>-%param-OutboundDelivery %param-OutboundDeliveryItem = <key>-%param-OutboundDeliveryItem ) )
        RESULT FINAL(lt_scanned_qty).

        IF lines( lt_scanned_qty ) > 0.
          IF  lt_scanned_qty[ 1 ]-%param-ScannedQuantity = ls_outbounddeliveryitem-ActualDeliveryQuantity.
            reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 005 severity = if_abap_behv_message=>severity-error  ) ) ).
            failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid  ) ).

            RETURN.
          ENDIF.

        ENDIF.

        "Not Exist Serial Number
        reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 010 severity = if_abap_behv_message=>severity-error  ) ) ).
        failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid  ) ).
      ELSE.
        " Check serial number has been scanned.
        SELECT SINGLE * FROM zr_tsd004 WITH PRIVILEGED ACCESS WHERE DeliveryNumber = @ls_serialnumber-DeliveryDocument "#EC CI_ALL_FIELDS_NEEDED
                                         AND DeliveryItem = @ls_serialnumber-DeliveryDocumentItem
                                         AND material = @ls_serialnumber-Material
                                         AND SerialNumber = @ls_serialnumber-SerialNumber
                INTO @DATA(ls_scanned_record).
        IF sy-subrc = 0.
          reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                                          %msg = new_message( id = 'ZZSD' number = 006 severity = if_abap_behv_message=>severity-error  )
                                          DeliveryItem = ls_scanned_record-DeliveryItem
                                          DeliveryNumber = ls_scanned_record-DeliveryNumber
                                          Material = ls_scanned_record-Material
                                          SerialNumber = ls_scanned_record-SerialNumber ) ).
          failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                                        DeliveryItem = ls_scanned_record-DeliveryItem
                                        DeliveryNumber = ls_scanned_record-DeliveryNumber
                                        Material = ls_scanned_record-Material
                                        SerialNumber = ls_scanned_record-SerialNumber  ) ).
        ELSE.


          lt_tsd004 = VALUE #( ( %cid = <key>-%cid
                               DeliveryNumber = ls_serialnumber-DeliveryDocument
                               DeliveryItem = ls_serialnumber-DeliveryDocumentItem
                               Material = ls_serialnumber-Material
                               SerialNumber = ls_serialnumber-SerialNumber
                               Plant = ls_outbounddeliveryitem-Plant
                               StorageLocation = ls_outbounddeliveryitem-StorageLocation
                               OldSerialNumber = COND #( WHEN lv_oldserialnumber NE '' THEN lv_oldserialnumber ELSE '' )
                                ) ).
          MODIFY ENTITIES OF zr_tsd004 IN LOCAL MODE
              ENTITY zr_tsd004
              CREATE  FIELDS ( DeliveryNumber DeliveryItem Material SerialNumber Plant StorageLocation OldSerialNumber ) WITH lt_tsd004
                        MAPPED mapped
                        REPORTED reported
                        FAILED failed.
        ENDIF.

      ENDIF.

    ENDIF.
  ENDMETHOD.

  METHOD deleteScannedRecord.
    DATA : lt_tsd004          TYPE TABLE FOR DELETE zr_tsd004,
           lv_serialnumber    TYPE zzesd023,
           lv_oldserialnumber TYPE zzesd012.
    ASSERT lines( keys ) > 0.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      IF strlen( <key>-%param-SerialNumber ) = 18.
        lv_serialnumber = <key>-%param-SerialNumber.
      ELSE.
        SELECT SINGLE zserialnumber FROM zr_tmm001 WITH PRIVILEGED ACCESS WHERE Product = @<key>-%param-Product
                                         AND Zoldserialnumber = @<key>-%param-SerialNumber
            INTO @lv_serialnumber.
*        lv_oldserialnumber = <key>-%param-SerialNumber.
      ENDIF.
    ENDIF.

*    lt_tsd004 = VALUE #( ( %cid_ref = <key>-%cid
*                           %tky = VALUE #( DeliveryItem )
*                     DeliveryNumber = <key>-%param-OutboundDelivery
*                     DeliveryItem = <key>-%param-OutboundDeliveryItem
*                     Material = <key>-%param-Product
*                     SerialNumber = lv_serialnumber
*                      ) ).
    MODIFY ENTITIES OF zr_tsd004 IN LOCAL MODE
    ENTITY zr_tsd004 DELETE FROM VALUE #( ( DeliveryNumber = <key>-%param-OutboundDelivery
                                          DeliveryItem = <key>-%param-OutboundDeliveryItem
                                          Material = <key>-%param-Product
                                          SerialNumber = lv_serialnumber ) )
    MAPPED Mapped
    REPORTED Reported
    FAILED Failed.


  ENDMETHOD.

  METHOD checkAllItemsScanned.
    ASSERT lines( keys ) > 0.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.

      " Check not return item
*      SELECT SINGLE CustomerReturnDelivery
*        FROM I_CustomerReturnDelivery
*        WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery
*        INTO @DATA(lv_customerreturndelivery).
*      IF sy-subrc = 0.
*        result = VALUE #( ( %cid = <key>-%cid %param = abap_true ) ).
*        RETURN.
*      ENDIF.

*        read ENTITIES OF zr_tsd004 IN LOCAL MODE
*        READ ENTITIES OF I_OutboundDeliveryTP ENTITY OutboundDeliveryItem
*        ALL FIELDS WITH VALUE #(
      SELECT outbounddelivery,
             outbounddeliveryitem,
             ActualDeliveryQuantity,
             DeliveryDocumentItemCategory,
             HigherLevelItem
             FROM zr_ssd018 WITH PRIVILEGED ACCESS
             WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
*               AND PickingStatus NE ''
           INTO TABLE @DATA(lt_deliveryitem).

      IF sy-subrc = 0.
        LOOP AT lt_deliveryitem ASSIGNING FIELD-SYMBOL(<fs_deliveryitem>).
          READ ENTITIES OF zr_tsd004 IN LOCAL MODE ENTITY zr_tsd004
            EXECUTE getScannedQty FROM VALUE #(
                        ( %param-OutboundDelivery = <fs_deliveryitem>-OutboundDelivery
                          %param-OutboundDeliveryItem = <fs_deliveryitem>-OutboundDeliveryItem ) )

            RESULT FINAL(lt_scanned_qty).
          IF lines( lt_scanned_qty ) > 0 .
            IF <fs_deliveryitem>-ActualDeliveryQuantity > 0 AND lt_scanned_qty[ 1 ]-%param-ScannedQuantity = 0.
              result = VALUE #( ( %cid = <key>-%cid %param-Boolean = abap_false ) ).
              reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                                              %msg = new_message(
                                                      id = 'ZZSD'
                                                      number = 021
                                                      severity = if_abap_behv_message=>severity-error
                                                      )
                                                                    ) ).
              failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                                             ) ).
              RETURN.
            ENDIF.

            " Check whether the item belongs to a BOM.
            IF <fs_deliveryitem>-DeliveryDocumentItemCategory = 'CBLI' OR ( <fs_deliveryitem>-DeliveryDocumentItemCategory = 'TAN' AND <fs_deliveryitem>-HigherLevelItem <> '' ).
              IF <fs_deliveryitem>-ActualDeliveryQuantity NE lt_scanned_qty[ 1 ]-%param-ScannedQuantity.
                result = VALUE #( ( %cid = <key>-%cid %param-Boolean = abap_false ) ).
                reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                                                %msg = new_message(
                                                        id = 'ZZSD'
                                                        number = 022
                                                        severity = if_abap_behv_message=>severity-error
                                                        )
                                                                      ) ).
                failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                                               ) ).
                RETURN.
              ENDIF.
            ENDIF.



          ENDIF.

        ENDLOOP.
      ENDIF.

    ENDIF.
    result = VALUE #( ( %cid = <key>-%cid %param-Boolean = abap_true ) ).

  ENDMETHOD.


  METHOD postGoodsIssue.

    ASSERT lines( keys ) > 0.

    DATA: has_error TYPE abap_boolean.

    has_error = abap_false.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.


      DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
      DATA: lo_client_proxy      TYPE REF TO /iwbep/if_cp_client_proxy.


      " Find CA by Scenario ID
      lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
      DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
      lo_factory->query_ca(
        EXPORTING
          is_query           = VALUE #( cscn_id_range = lr_cscn )
        IMPORTING
          et_com_arrangement = DATA(lt_ca) ).

      IF lt_ca IS INITIAL.
        EXIT.
      ENDIF.
      " take the first one
      READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
      " get destination based on Communication Arrangement and the service ID
      TRY.
          DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
              comm_scenario  = 'YY1_API'
              service_id     = 'YY1_API_REST'
              comm_system_id = lo_ca->get_comm_system_id( ) ).

        CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
*              out->write( lx_http_dest_provider_error->get_text( ) ).
          EXIT.
      ENDTRY.

      " Check not return item
      SELECT SINGLE CustomerReturnDelivery
        FROM I_CustomerReturnDelivery WITH PRIVILEGED ACCESS
        WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery
        INTO @DATA(lv_customerreturndelivery).
      IF sy-subrc = 0.
*        result = VALUE #( ( %cid = <key>-%cid %param = abap_true ) ).
*        RETURN.
        "Cusomter Return
*        MODIFY ENTITIES OF i_customerreturnsdeliverytp
*            ENTITY CustomerReturnsDelivery
*             EXECUTE PostGoodsMovement
*                FROM VALUE #(
*             ( CustomerReturnDelivery = <key>-%param-OutboundDelivery ) )
*            MAPPED DATA(ls_mapped_csd)
*            REPORTED DATA(ls_reported_csd)
*            FAILED DATA(ls_failed_csd).
*        IF lines( ls_failed_csd-customerreturnsdelivery ) > 0.
*          has_error = abap_true.
*          reported-zr_tsd004 = VALUE #(  FOR csd IN ls_reported_csd-customerreturnsdelivery ( %cid = <key>-%cid %msg = csd-%msg ) ).
*          failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid ) ).
*        ENDIF.
        TRY.
            DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

            DATA(lo_request) = lo_http_client->get_http_request(   ).
            lo_http_client->enable_path_prefix( ).

            lo_request->set_uri_path( EXPORTING i_uri_path = '/API_CUSTOMER_RETURNS_DELIVERY_SRV;v=0002/PostGoodsReceipt' ).
            lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
            lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

            lo_http_client->set_csrf_token(  ).

            lo_request->set_form_field( i_name = 'DeliveryDocument' i_value =  |'{ CONV string( <key>-%param-OutboundDelivery ) }'| ).
*            lo_request->set_form_field( i_name = 'DeliveryDocument' i_value =  |'{ CONV string( <key>-%param-OutboundDelivery ) }'| ).

            DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).

            DATA(lv_response) = lo_response->get_text(  ).

            DATA(status) = lo_response->get_status( ).
            IF status-code NE 200.
              DATA : lo_error TYPE REF TO data.
              "Error handling here
              "handle odata error message here
              /ui2/cl_json=>deserialize(
                  EXPORTING
                      json = lv_response
                  CHANGING
                      data = lo_error
              ).
              ASSIGN COMPONENT 'ERROR' OF STRUCTURE lo_error->* TO FIELD-SYMBOL(<fo_error>).
              IF sy-subrc = 0.
                ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <fo_error>->* TO FIELD-SYMBOL(<fo_message>).
                IF sy-subrc = 0.
                  ASSIGN COMPONENT 'VALUE' OF STRUCTURE <fo_message>->* TO FIELD-SYMBOL(<fo_msgVALUE>).
                  IF sy-subrc = 0.
                    reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text = <fo_msgVALUE>->* )  ) ).
                  ENDIF.
                ENDIF.

              ENDIF.
              failed-zr_tsd004  = VALUE #( ( %cid = <key>-%cid ) ).
              has_error = abap_true.
            ELSE.
              " success
*                read ENTITIES OF zr_tsd004 IN LOCAL MODE
*                    entity zr_tsd004
*                    FIELDS ( DeliveryNumber DeliveryItem Material SerialNumber )
*                    WITH VALUE #( ( DeliveryNumber = <key>-%param-OutboundDelivery ) )
*                    RESULT DATA(LT_TSD004).
              has_error = abap_false.

            ENDIF.

          CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
*            CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
            DATA : lv_message TYPE string.
            lv_message = lX_WEB_HTTP_CLIENT_ERROR->get_longtext(  ).
            reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                       %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                    text = lv_message )  ) ).
            failed-zr_tsd004  = VALUE #( ( %cid = <key>-%cid ) ).
            has_error = abap_true.
        ENDTRY.


      ELSE.

        "post goods issue.



        TRY.


            lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

            lo_request = lo_http_client->get_http_request(   ).
            lo_http_client->enable_path_prefix( ).

            lo_request->set_uri_path( EXPORTING i_uri_path = '/API_OUTBOUND_DELIVERY_SRV;v=0002/PostGoodsIssue' ).
            lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
            lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

            lo_http_client->set_csrf_token(  ).

            lo_request->set_form_field( i_name = 'DeliveryDocument' i_value =  |'{ CONV string( <key>-%param-OutboundDelivery ) }'| ).

            lo_response = lo_http_client->execute( if_web_http_client=>post ).

            lv_response = lo_response->get_text(  ).





            status = lo_response->get_status( ).
            IF status-code NE 200.
*              lo_error TYPE REF TO data.
              "Error handling here
              "handle odata error message here
              /ui2/cl_json=>deserialize(
                  EXPORTING
                      json = lv_response
                  CHANGING
                      data = lo_error
              ).
              ASSIGN COMPONENT 'ERROR' OF STRUCTURE lo_error->* TO <fo_error>.
              IF sy-subrc = 0.
                ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <fo_error>->* TO <fo_message>.
                IF sy-subrc = 0.
                  ASSIGN COMPONENT 'VALUE' OF STRUCTURE <fo_message>->* TO <fo_msgVALUE>.
                  IF sy-subrc = 0.
                    reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                            %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                         text = <fo_msgVALUE>->* )  ) ).
                  ENDIF.
                ENDIF.

              ENDIF.
              failed-zr_tsd004  = VALUE #( ( %cid = <key>-%cid ) ).
              has_error = abap_true.
            ELSE.
              " success
*                read ENTITIES OF zr_tsd004 IN LOCAL MODE
*                    entity zr_tsd004
*                    FIELDS ( DeliveryNumber DeliveryItem Material SerialNumber )
*                    WITH VALUE #( ( DeliveryNumber = <key>-%param-OutboundDelivery ) )
*                    RESULT DATA(LT_TSD004).
              has_error = abap_false.

            ENDIF.



          CATCH cx_web_http_client_error INTO lX_WEB_HTTP_CLIENT_ERROR.
*            CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
*            DATA : lv_message TYPE string.
            lv_message = lX_WEB_HTTP_CLIENT_ERROR->get_longtext(  ).
            reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                       %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                    text = lv_message )  ) ).
            failed-zr_tsd004  = VALUE #( ( %cid = <key>-%cid ) ).
            has_error = abap_true.
        ENDTRY.

      ENDIF.

      IF has_error = abap_false.
        SELECT DeliveryNumber,
               DeliveryItem,
               Material,
               SerialNumber
               FROM zr_tsd004 WITH PRIVILEGED ACCESS
               WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
               INTO TABLE @DATA(lt_tsd004).



        MODIFY ENTITIES OF zr_tsd004 IN LOCAL MODE
            ENTITY zr_tsd004
            UPDATE FIELDS ( PgiIndicator PostingDate ) WITH VALUE #( FOR ls_tsd004 IN lt_tsd004 (
                                                                               %tky-DeliveryNumber = ls_tsd004-DeliveryNumber
                                                                               %tky-DeliveryItem = ls_tsd004-DeliveryItem
                                                                               %tky-Material = ls_tsd004-Material
                                                                               %tky-SerialNumber = ls_tsd004-SerialNumber
                                                                               PgiIndicator = 'X'
                                                                               PostingDate = cl_abap_context_info=>get_system_date( )
                                                                               "Record Current Process UUID

                                                                                ) )
                                                                       FAILED failed
                                                                       REPORTED reported
                                                                       MAPPED mapped.
*        DATA : ls_tsd020 TYPE ztsd020.
*        ls_tsd020 = VALUE #( deliverynumber = lt_tsd004[ 1 ]-DeliveryNumber
*                             current_process_uuid = <key>-%param-ProcessUUID ).
*
*        MODIFY ztsd020 FROM @ls_tsd020.
        " Update Current Process UUID
        READ ENTITIES OF zi_tsd020
            ENTITY zr_tsd020 FIELDS ( Deliverynumber ) WITH VALUE #( (  %key-Deliverynumber = lt_tsd004[ 1 ]-DeliveryNumber ) )
            RESULT FINAL(read_record).
        IF ( lines( read_record ) > 0 ).
          MODIFY ENTITIES OF zi_tsd020
              ENTITY zr_tsd020 UPDATE FIELDS ( CurrentProcessUUID ) WITH VALUE #( ( %key-Deliverynumber = lt_tsd004[ 1 ]-DeliveryNumber
                                                                                    CurrentProcessUUID =  <key>-%param-ProcessUUID ) ).

        ELSE.

          MODIFY ENTITIES OF zi_tsd020
              ENTITY zr_tsd020 CREATE FIELDS ( Deliverynumber CurrentProcessUUID ) WITH VALUE #( ( %cid = <key>-%cid
                                                                                                    %key-Deliverynumber = lt_tsd004[ 1 ]-DeliveryNumber
*                                                                                                   Deliverynumber = lt_tsd004[ 1 ]-DeliveryNumber
                                                                                                   CurrentProcessUUID =  <key>-%param-ProcessUUID ) ).
        ENDIF.

*            with VALUE #(  )



      ENDIF.

    ENDIF.


  ENDMETHOD.

  METHOD checkItemScanned.
    ASSERT lines( keys ) > 0.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.

      SELECT SINGLE outbounddelivery,
         outbounddeliveryitem,
         ActualDeliveryQuantity
         FROM zr_ssd018 WITH PRIVILEGED ACCESS
         WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
           AND OutboundDeliveryItem = @<key>-%param-OutboundDeliveryItem
       INTO  @DATA(ls_deliveryitem).

      READ ENTITIES OF zr_tsd004 IN LOCAL MODE ENTITY zr_tsd004
        EXECUTE getScannedQty FROM VALUE #(
                    ( %param-OutboundDelivery = ls_deliveryitem-OutboundDelivery
                      %param-OutboundDeliveryItem = ls_deliveryitem-OutboundDeliveryItem ) )

        RESULT FINAL(lt_scanned_qty).
      IF lines( lt_scanned_qty ) > 0.
        IF ls_deliveryitem-ActualDeliveryQuantity NE lt_scanned_qty[ 1 ]-%param-ScannedQuantity.
          result = VALUE #( ( %cid = <key>-%cid %param-Boolean = abap_false ) ).
        ELSE.
          result = VALUE #( ( %cid = <key>-%cid %param-Boolean = abap_true ) ).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD changeQuantity.
    ASSERT lines( keys ) > 0.

    DATA: has_error TYPE abap_boolean.

    DATA: lt_dnitem_change TYPE TABLE FOR UPDATE I_OutboundDeliveryItemTP,
          ls_dnitem_change LIKE LINE OF lt_dnitem_change,
          lt_soitem_change TYPE TABLE FOR UPDATE I_salesorderitemtp,
          ls_soitem_change LIKE LINE OF lt_soitem_change.

    CHECK 1 = 2. " Do not execute this action

    has_error = abap_false.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.

      " Check not return item
      SELECT SINGLE CustomerReturnDelivery
        FROM I_CustomerReturnDelivery WITH PRIVILEGED ACCESS
        WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery
        INTO @DATA(lv_customerreturndelivery).
      IF sy-subrc = 0.
        RETURN.
      ENDIF.
      " Get all item line from OutboundDelivery
      SELECT outbounddelivery,
         outbounddeliveryitem,
         referencesddocument,
         referencesddocumentitem,
         product,
*         ActualDeliveredQtyInBaseUnit,
         ActualDeliveryQuantity,
         DeliveryQuantityUnit
         FROM zr_ssd018 WITH PRIVILEGED ACCESS
         WHERE outbounddelivery = @<key>-%param-OutboundDelivery
*         AND PickingStatus ne ''
         INTO TABLE @DATA(lt_outbounddeliveryitem).


      READ ENTITIES OF zr_tsd004 IN LOCAL MODE ENTITY zr_tsd004
*        EXECUTE checkAllItemsScanned FROM VALUE #( ( %param-OutboundDelivery = <key>-%param-OutboundDelivery ) )
        EXECUTE checkAllItemsFullyScanned FROM VALUE #( ( %param-OutboundDelivery = <key>-%param-OutboundDelivery ) )
        RESULT FINAL(lt_scanned).

      IF lines( lt_scanned ) > 0.
        DATA : lv_scanned TYPE abap_boolean.
        lv_scanned = lt_scanned[ 1 ]-%param.

        IF lv_scanned = abap_false.
          "Get Every Delivery Item
          LOOP AT lt_outbounddeliveryitem ASSIGNING FIELD-SYMBOL(<fs_outbounddeliveryitem>).

            "get scanned quantity
            READ ENTITIES OF zr_tsd004 IN LOCAL MODE ENTITY zr_tsd004
               EXECUTE checkItemScanned FROM VALUE #( ( %param-OutboundDelivery = <fs_outbounddeliveryitem>-OutboundDelivery %param-OutboundDeliveryItem = <fs_outbounddeliveryitem>-OutboundDeliveryItem ) )
              RESULT FINAL(lt_item_scanned).
            IF lines( lt_item_scanned ) > 0.
              IF lt_item_scanned[ 1 ]-%param-Boolean = abap_false.



                "change picked item in delivery
                "get scanned quantity
                READ ENTITIES OF zr_tsd004 IN LOCAL MODE ENTITY zr_tsd004
                EXECUTE getScannedQty FROM VALUE #(
                            ( %param-OutboundDelivery = <fs_outbounddeliveryitem>-OutboundDelivery
                              %param-OutboundDeliveryItem = <fs_outbounddeliveryitem>-OutboundDeliveryItem ) )

                RESULT FINAL(lt_scanned_qty).



                CLEAR ls_dnitem_change.
                ls_dnitem_change = VALUE #( ActualDeliveredQtyInOrderUnit = lt_scanned_qty[ 1 ]-%param-ScannedQuantity
*                                        OrderQuantityUnit             = <fs_outbounddeliveryitem>-DeliveryQuantityUnit
                                       %tky-OutboundDelivery         = <fs_outbounddeliveryitem>-OutboundDelivery
                                       %tky-OutboundDeliveryItem     = <fs_outbounddeliveryitem>-OutboundDeliveryItem ).
                APPEND ls_dnitem_Change TO lt_dnitem_change.








*                "change so item quantity
*                DATA: lv_salesorder     TYPE I_SalesOrderItem-SalesOrder,
*                      lv_salesorderitem TYPE I_SalesOrderItem-SalesOrderItem,
*                      lv_soitemqty      TYPE i_salesorderitem-RequestedQuantity.
*
*                "get Sales Document Item
*                SELECT SINGLE salesorder,
*                              salesorderitem,
*                       higherlevelitem
*                       FROM I_salesorderitem
*                       WHERE salesorder = @<fs_outbounddeliveryitem>-ReferenceSDDocument
*                         AND salesorderitem = @<fs_outbounddeliveryitem>-ReferenceSDDocumentItem
*                         AND SalesOrderItemCategory IN ( 'CBLI' , 'TAN' )
*                         AND HigherLevelItem IS NOT INITIAL
*                    INTO @DATA(ls_so_higherlevelitem).
*                IF sy-subrc = 0.
*                  " get higher level material
*                  SELECT SINGLE product,
*                                BOMExplosionDate,
*                                plant
*                          FROM I_SalesOrderItem
*                          WHERE salesorder = @ls_so_higherlevelitem-SalesOrder
*                            AND SalesOrderItem = @ls_so_higherlevelitem-HigherLevelItem
*                       INTO @DATA(ls_so_hitem).
*                  IF sy-subrc = 0.
*                    SELECT SINGLE BillOfMaterial,
*                           BillOfMaterialCategory
*                           FROM I_BillOfMaterialTP_2
*                           WHERE material = @ls_so_hitem-Product
*                             AND BillOfMaterialVariantUsage = '5'
*                             AND plant = @ls_so_hitem-Plant
*                             AND HeaderValidityStartDate <= @ls_so_hitem-BOMExplosionDate
*                             AND HeaderValidityEndDate >= @ls_so_hitem-BOMExplosionDate
*                         INTO @DATA(ls_billofmaterial).
*                    IF sy-subrc = 0.
*                      SELECT SINGLE BillOfMaterialItemQuantity
*                        FROM I_BillOfMaterialItemBasic
*                        WHERE BillOfMaterial = @ls_billofmaterial-BillOfMaterial
*                          AND BillOfMaterialCategory = @ls_billofmaterial-BillOfMaterialCategory
*                          AND BillOfMaterialComponent = @<fs_outbounddeliveryitem>-Product
*                          AND ValidityStartDate <= @ls_so_hitem-BOMExplosionDate
*                          AND ValidityEndDate >= @ls_so_hitem-BOMExplosionDate
*                          INTO @DATA(lv_BillOfMaterialItemQuantity).
*                      IF sy-subrc = 0.
*                        lv_salesorder = ls_so_higherlevelitem-SalesOrder.
*                        lv_salesorderitem = ls_so_higherlevelitem-HigherLevelItem.
*                        lv_soitemqty = lt_scanned_qty[ 1 ]-%param / lv_BillOfMaterialItemQuantity.
*                      ENDIF.
*                    ENDIF.
*
*
*                  ENDIF.
*                ELSE.
*                  lv_salesorder = <fs_outbounddeliveryitem>-ReferenceSDDocument.
*                  lv_salesorderitem = <fs_outbounddeliveryitem>-ReferenceSDDocumentItem.
*                  lv_soitemqty = lt_scanned_qty[ 1 ]-%param.
*                ENDIF.
*                IF lv_salesorder IS NOT INITIAL AND lv_salesorderitem IS NOT INITIAL .
*                  " change so item
*                  CLEAR ls_soitem_change.
*                  ls_soitem_change = VALUE #( RequestedQuantity = lv_soitemqty
*                                    %tky-SalesOrder = lv_salesorder
*                                    %tky-salesorderitem = lv_salesorderitem
*                                    %key-salesorder            = lv_salesorder
*                                    %key-salesorderitem        = lv_salesorderitem ).
*                  APPEND ls_soitem_change TO lt_soitem_change.
*
*
*                ENDIF.
              ENDIF.
            ENDIF.
          ENDLOOP.

          IF lines( lt_dnitem_change ) > 0.
            MODIFY ENTITIES OF I_OutboundDeliveryTP
              ENTITY OutboundDeliveryItem
              UPDATE FIELDS ( ActualDeliveredQtyInOrderUnit  )
              WITH lt_dnitem_change
*            WITH VALUE #( ( ActualDeliveredQtyInOrderUnit = lt_scanned_qty[ 1 ]-%param
**                                        OrderQuantityUnit             = <fs_outbounddeliveryitem>-DeliveryQuantityUnit
*                                        %tky-OutboundDelivery         = <fs_outbounddeliveryitem>-OutboundDelivery
*                      %tky-OutboundDeliveryItem     = <fs_outbounddeliveryitem>-OutboundDeliveryItem ) )
               FAILED   FINAL(failed_dnitem)
              REPORTED FINAL(reported_dnitem).

            IF lines( failed_dnitem-outbounddeliveryitem ) > 0.
              has_error = abap_true.
              LOOP AT reported_dnitem-outbounddeliveryitem ASSIGNING FIELD-SYMBOL(<fs_otbitem>).
                DATA : ls_line LIKE LINE OF reported-zr_tsd004.
                ls_line = VALUE #( %cid = <key>-%cid %msg = <fs_otbitem>-%msg ).
                APPEND ls_line TO reported-zr_tsd004.
              ENDLOOP.
              IF lines( reported-zr_tsd004 ) = 0.
                ls_line = VALUE #( %cid = <key>-%cid %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Error when changing DN' ) ).
                APPEND ls_line TO reported-zr_tsd004.
              ENDIF.
              failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid ) ).
            ENDIF.
          ENDIF.

*          IF has_error = abap_false AND lines( lt_soitem_change ) > 0.
*            MODIFY ENTITIES OF i_salesordertp
*              ENTITY SalesOrderItem
*              UPDATE FIELDS ( RequestedQuantity )
*              WITH lt_soitem_change
**            WITH VALUE #( ( RequestedQuantity = lv_soitemqty
**                  %tky-SalesOrder = lv_salesorder
**                  %tky-salesorderitem = lv_salesorderitem
**                  %key-salesorder            = lv_salesorder
**                  %key-salesorderitem        = lv_salesorderitem ) )
*              FAILED   DATA(ls_soitem_failed)
*              REPORTED DATA(ls_soitem_reported).
*            IF lines( ls_soitem_failed-salesorderitem ) > 0.
*              has_error = abap_true.
*              reported-zr_tsd004 = VALUE #(  FOR soitem IN ls_soitem_reported-salesorderitem ( %cid = <key>-%cid %msg = soitem-%msg ) ).
*              failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid ) ).
*            ENDIF.
*          ENDIF.


        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD deleteSerialNumber.
    ASSERT lines( keys ) > 0.

    DATA: has_error TYPE abap_boolean.

    has_error = abap_false.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.

      " Check not return item
      SELECT SINGLE CustomerReturnDelivery
        FROM I_CustomerReturnDelivery WITH PRIVILEGED ACCESS
        WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery
        INTO @DATA(lv_customerreturndelivery).
      IF sy-subrc = 0.
        RETURN.
      ENDIF.
      "Get Every Delivery Item

*      LOOP AT lt_outbounddeliveryitem ASSIGNING FIELD-SYMBOL(<fs_outbounddeliveryitem>).
      IF has_error = abap_false.
        "get scanned quantity

        "change serial number and picked item in delivery
        SELECT outbounddelivery,
               outbounddeliveryitem,
               serialnumber
               FROM I_OutbDelivItemSerialNumberTP WITH PRIVILEGED ACCESS
               WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
*                   AND OutboundDeliveryItem = @<fs_outbounddeliveryitem>-OutboundDeliveryItem
                 INTO TABLE @DATA(lt_picked_serialnumber).

        SELECT DeliveryNumber,
               deliveryitem,
               serialnumber
               FROM zr_tsd004 WITH PRIVILEGED ACCESS
               WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
*                   AND DeliveryItem = @<fs_outbounddeliveryitem>-OutboundDeliveryItem
                 INTO TABLE @DATA(lt_scanned_serialnumber).

        SORT lt_scanned_serialnumber BY DeliveryNumber DeliveryItem SerialNumber.

        LOOP AT lt_picked_serialnumber ASSIGNING FIELD-SYMBOL(<picked_serialnumber>).
          READ TABLE lt_scanned_serialnumber TRANSPORTING NO FIELDS WITH KEY DeliveryNumber = <picked_serialnumber>-OutboundDelivery
                                                                             DeliveryItem = <picked_serialnumber>-OutboundDeliveryItem
                                                                             SerialNumber = <picked_serialnumber>-SerialNumber
                                                                             BINARY SEARCH.
          IF sy-subrc = 0.
            DELETE lt_picked_serialnumber.
          ENDIF.
        ENDLOOP.


        "change serial number & change picked item on item level
        IF lines( lt_picked_serialnumber ) > 0.
          MODIFY ENTITIES OF I_OutboundDeliveryTP
              ENTITY OutbDelivItemSerialNumber
*                      DELETE FROM CORRESPONDING #( lt_picked_serialnumber )
              DELETE FROM VALUE #( FOR picked_sn IN lt_picked_serialnumber (
*                                                                             %tky-OutboundDelivery = picked_sn-OutboundDelivery
*                                                                             %tky-outbounddeliveryitem = picked_sn-outbounddeliveryitem
*                                                                             %tky-SerialNumber = picked_sn-SerialNumber
                                                                             %tky = VALUE #(
                                                                                OutboundDelivery = picked_sn-OutboundDelivery
                                                                                outbounddeliveryitem = picked_sn-outbounddeliveryitem
                                                                                SerialNumber = picked_sn-SerialNumber
                                                                              )
                                                                             OutboundDelivery = picked_sn-OutboundDelivery
                                                                             outbounddeliveryitem = picked_sn-outbounddeliveryitem
                                                                             SerialNumber = picked_sn-SerialNumber ) )

              MAPPED FINAL(deleted_sn)
              REPORTED FINAL(reported_sn)
              FAILED FINAL(failed_sn).

          IF lines( failed_sn-outbdelivitemserialnumber ) > 0 .
            has_error = abap_true.
            reported-zr_tsd004 = VALUE #(  FOR otbsn IN reported_sn-outbdelivitemserialnumber ( %cid = <key>-%cid %msg = otbsn-%msg ) ).
            DATA : ls_line LIKE LINE OF reported-zr_tsd004.
            IF lines( reported-zr_tsd004 ) = 0.
              ls_line = VALUE #( %cid = <key>-%cid %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Error when deleting serial number' ) ).
              APPEND ls_line TO reported-zr_tsd004.
            ENDIF.
            failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid ) ).
          ENDIF.
        ENDIF.
      ENDIF.
*      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD changePickedQuantity.
    ASSERT lines( keys ) > 0.

    DATA: has_error TYPE abap_boolean.
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      " Check not return item
      SELECT SINGLE CustomerReturnDelivery
        FROM I_CustomerReturnDelivery WITH PRIVILEGED ACCESS
        WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery
        INTO @DATA(lv_customerreturndelivery).
      IF sy-subrc = 0.
        RETURN.
      ENDIF.



      " Get all item line from OutboundDelivery
      "
      SELECT outbounddelivery,
         outbounddeliveryitem,
         referencesddocument,
         referencesddocumentitem,
         product,
*         ActualDeliveredQtyInBaseUnit,
         ActualDeliveryQuantity,
         DeliveryQuantityUnit
         FROM zr_ssd018 WITH PRIVILEGED ACCESS
         WHERE outbounddelivery = @<key>-%param-OutboundDelivery
*          AND PickingStatus ne ''
         INTO TABLE @DATA(lt_outbounddeliveryitem).

      READ ENTITIES OF zr_tsd004 IN LOCAL MODE ENTITY zr_tsd004
*        EXECUTE checkAllItemsScanned FROM VALUE #( ( %param-OutboundDelivery = <key>-%param-OutboundDelivery ) )
        EXECUTE checkAllItemsFullyScanned FROM VALUE #( ( %param-OutboundDelivery = <key>-%param-OutboundDelivery ) )
        RESULT FINAL(lt_scanned).

      IF lines( lt_scanned ) > 0.
        DATA : lv_scanned TYPE abap_boolean.
        lv_scanned = lt_scanned[ 1 ]-%param.

        IF lv_scanned = abap_false.

          DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
          DATA: lo_client_proxy      TYPE REF TO /iwbep/if_cp_client_proxy.


          " Find CA by Scenario ID
          lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
          DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
          lo_factory->query_ca(
            EXPORTING
              is_query           = VALUE #( cscn_id_range = lr_cscn )
            IMPORTING
              et_com_arrangement = DATA(lt_ca) ).

          IF lt_ca IS INITIAL.
            EXIT.
          ENDIF.
          " take the first one
          READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
          " get destination based on Communication Arrangement and the service ID
          TRY.
              DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
                  comm_scenario  = 'YY1_API'
                  service_id     = 'YY1_API_REST'
                  comm_system_id = lo_ca->get_comm_system_id( ) ).

            CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
*              out->write( lx_http_dest_provider_error->get_text( ) ).
              EXIT.
          ENDTRY.

          "Get Every Delivery Item
          LOOP AT lt_outbounddeliveryitem ASSIGNING FIELD-SYMBOL(<fs_outbounddeliveryitem>).

            "get scanned quantity
            READ ENTITIES OF zr_tsd004 IN LOCAL MODE ENTITY zr_tsd004
               EXECUTE checkItemScanned FROM VALUE #( ( %param-OutboundDelivery = <fs_outbounddeliveryitem>-OutboundDelivery %param-OutboundDeliveryItem = <fs_outbounddeliveryitem>-OutboundDeliveryItem ) )
              RESULT FINAL(lt_item_scanned).
            IF lines( lt_item_scanned ) > 0.
              IF lt_item_scanned[ 1 ]-%param-Boolean = abap_false.

                "get scanned quantity
                READ ENTITIES OF zr_tsd004 IN LOCAL MODE ENTITY zr_tsd004
                EXECUTE getScannedQty FROM VALUE #(
                            ( %param-OutboundDelivery = <fs_outbounddeliveryitem>-OutboundDelivery
                              %param-OutboundDeliveryItem = <fs_outbounddeliveryitem>-OutboundDeliveryItem ) )

                RESULT FINAL(lt_scanned_qty).




                TRY.


                    DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

                    DATA(lo_request) = lo_http_client->get_http_request(   ).

                    DATA : lv_languagecode TYPE spras.
                    TRY.
                        lv_languagecode = cl_abap_context_info=>get_user_language_abap_format(  ).
                        SELECT SINGLE UnitOfMeasure_E
                            FROM I_UnitOfMeasureText WITH PRIVILEGED ACCESS
                            WHERE UnitOfMeasure = @<fs_outbounddeliveryitem>-DeliveryQuantityUnit
                              AND Language = @lv_languagecode
                             INTO @DATA(lv_unit_output).
                      CATCH cx_abap_context_info_error.
                        "handle exception
                    ENDTRY.


                    lo_http_client->enable_path_prefix( ).

                    lo_request->set_uri_path( EXPORTING i_uri_path = '/API_OUTBOUND_DELIVERY_SRV;v=0002/PickOneItemWithSalesQuantity' ).
                    lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
                    lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

                    lo_http_client->set_csrf_token(  ).

                    lo_request->set_form_field( i_name = 'DeliveryDocument' i_value =  |'{ CONV string( <key>-%param-OutboundDelivery ) }'| ).
                    lo_request->set_form_field( i_name = 'DeliveryDocumentItem' i_value =  |'{ CONV string( <fs_outbounddeliveryitem>-OutboundDeliveryItem ) }'| ).
                    lo_request->set_form_field( i_name = 'ActualDeliveryQuantity' i_value =  |{  lt_scanned_qty[ 1 ]-%param-ScannedQuantity  }M| ).
                    lo_request->set_form_field( i_name = 'DeliveryQuantityUnit' i_value =  |'{ lv_unit_output }'| ).

                    DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).

                    DATA(lv_response) = lo_response->get_text(  ).


                    DATA(status) = lo_response->get_status( ).
                    IF status-code NE 200.
                      DATA : lo_error TYPE REF TO data.
                      "Error handling here
                      "handle odata error message here
                      /ui2/cl_json=>deserialize(
                          EXPORTING
                              json = lv_response
                          CHANGING
                              data = lo_error
                      ).
                      ASSIGN COMPONENT 'ERROR' OF STRUCTURE lo_error->* TO FIELD-SYMBOL(<fo_error>).
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <fo_error>->* TO FIELD-SYMBOL(<fo_message>).
                        IF sy-subrc = 0.
                          ASSIGN COMPONENT 'VALUE' OF STRUCTURE <fo_message>->* TO FIELD-SYMBOL(<fo_msgVALUE>).
                          IF sy-subrc = 0.
                            reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                                    %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                 text = <fo_msgVALUE>->* )  ) ).
                          ENDIF.
                        ENDIF.

                      ENDIF.
                      failed-zr_tsd004  = VALUE #( ( %cid = <key>-%cid ) ).
                      EXIT.
                    ELSE.
                      " success
                      " 20240221 HANDZHH Add Change QTY Record to table ZTSD019
                      MODIFY ENTITIES OF zi_tsd019
                        ENTITY zr_tsd019 CREATE FIELDS ( ProcessUUID DeliveryItem Deliverynumber OriginalQuantity LatestQuantity UnitOfMeasure )
                            WITH VALUE #( (
                                            %cid = <key>-%cid
                                            %key-ProcessUUID = <key>-%param-ProcessUUID
                                            Deliverynumber = <key>-%param-OutboundDelivery
                                            DeliveryItem = <fs_outbounddeliveryitem>-OutboundDeliveryItem
                                            UnitOfMeasure = <fs_outbounddeliveryitem>-DeliveryQuantityUnit
                                            OriginalQuantity = <fs_outbounddeliveryitem>-ActualDeliveryQuantity
                                            LatestQuantity = lt_scanned_qty[ 1 ]-%param-ScannedQuantity ) ).

                    ENDIF.


                  CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
*            CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
                    DATA : lv_message TYPE string.
                    lv_message = lX_WEB_HTTP_CLIENT_ERROR->get_longtext(  ).
                    reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                               %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                            text = lv_message )  ) ).
                    failed-zr_tsd004  = VALUE #( ( %cid = <key>-%cid ) ).
                ENDTRY.



              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD writeBackSerialNumber.

    ASSERT lines( keys ) > 0.

    DATA: has_error TYPE abap_boolean,
          lv_index  TYPE sy-tabix.
    DATA : lt_soitem_change TYPE TABLE FOR UPDATE I_salesorderitemtp,
           ls_soitem_change LIKE LINE OF lt_soitem_change.
*           lt_dnitem_change TYPE TABLE FOR UPDATE I_OutboundDeliveryItemTP,
*           ls_dnitem_change LIKE LINE OF lt_dnitem_change.
    DATA : ls_customerreturn TYPE abap_bool.
    DATA : ls_freeso TYPE abap_bool.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      has_error = abap_false.

      " check damage product
      SELECT storagelocation,                           "#EC CI_NOWHERE
             WriteBackSN
        FROM zr_tsd014 WITH PRIVILEGED ACCESS
        INTO TABLE @DATA(lt_damage_location).
      SORT lt_damage_location BY StorageLocation WriteBackSN.


      " Check not return item
      SELECT SINGLE CustomerReturnDelivery
        FROM I_CustomerReturnDelivery WITH PRIVILEGED ACCESS
        WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery
        INTO @DATA(lv_customerreturndelivery).
      IF sy-subrc = 0.
        ls_customerreturn = abap_true.

        " Get whether DN Item is BOM
        SELECT CustomerReturnDelivery,
               CustomerReturnDeliveryItem,
               Material,
               DeliveryDocumentItemCategory,
               StorageLocation,
               ReferenceSDDocument,
               ReferenceSDDocumentItem
            FROM I_CustomerReturnDeliveryItem WITH PRIVILEGED ACCESS
            WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery
            INTO TABLE @DATA(lt_customerreturndeliveryitem).
        IF lt_customerreturndeliveryitem IS NOT INITIAL.
          SELECT a~SalesOrderWithoutCharge,
                 a~SalesOrderWithoutChargeItem,
                 a~ReferenceSDDocument,
                 a~ReferenceSDDocumentItem,
                 a~Product,
                 a~YY1_RefereneceSerialNo_SDI
              FROM I_SalesOrderWithoutChargeItem WITH PRIVILEGED ACCESS AS a
              JOIN I_CustomerReturnDeliveryItem WITH PRIVILEGED ACCESS AS b ON a~ReferenceSDDocument = b~ReferenceSDDocument
*                                                                                            AND a~ReferenceSDDocumentItem = CustomerReturnDeliveryItem~ReferenceSDDocumentItem
              WHERE b~CustomerReturnDelivery =  @<key>-%param-OutboundDelivery
*                 FOR ALL ENTRIES IN @lt_customerreturndeliveryitem
*                 WHERE ReferenceSDDocument = @lt_customerreturndeliveryitem-ReferenceSDDocument
*                   AND ReferenceSDDocumentItem = @lt_customerreturndeliveryitem-ReferenceSDDocumentItem
               INTO TABLE @DATA(lt_salesorder_withoutcharge).

            SELECT a~SalesOrderWithoutCharge,
                 a~SalesOrderWithoutChargeItem,
                 c~ReferenceSDDocument,
                 a~ReferenceSDDocumentItem,
                 a~Product,
                 a~YY1_RefereneceSerialNo_SDI
              FROM I_SalesOrderWithoutChargeItem WITH PRIVILEGED ACCESS AS a
              JOIN I_SalesOrderWithOutCharge WITH PRIVILEGED ACCESS as c on a~SalesOrderWithoutCharge = c~SalesOrderWithoutCharge
              join I_CustomerReturnDeliveryItem WITH PRIVILEGED ACCESS AS b ON c~ReferenceSDDocument = b~ReferenceSDDocument
*                                                                                            AND a~ReferenceSDDocumentItem = CustomerReturnDeliveryItem~ReferenceSDDocumentItem
              WHERE b~CustomerReturnDelivery =  @<key>-%param-OutboundDelivery
                AND a~SDDocumentRejectionStatus <> 'C'
*                 FOR ALL ENTRIES IN @lt_customerreturndeliveryitem
*                 WHERE ReferenceSDDocument = @lt_customerreturndeliveryitem-ReferenceSDDocument
*                   AND ReferenceSDDocumentItem = @lt_customerreturndeliveryitem-ReferenceSDDocumentItem
               APPENDING TABLE @lt_salesorder_withoutcharge.

        ENDIF.



*        RETURN.
*        SELECT WithoutChargeItem~SalesOrderWithoutCharge,
*               WithoutChargeItem~SalesOrderWithoutChargeItem,
*               CustomerReturnDeliveryItem~CustomerReturnDelivery,
*               CustomerReturnDeliveryItem~CustomerReturnDeliveryItem,
*               CustomerReturnDeliveryItem~StorageLocation
*               FROM I_SalesOrderWithoutChargeItem AS WithoutChargeItem JOIN I_SalesOrderWithoutCharge AS WithoutCharge ON WithoutChargeItem~SalesOrderWithoutCharge = WithoutCharge~SalesOrderWithoutCharge
*                                                                       JOIN I_CustomerReturnDeliveryItem AS CustomerReturnDeliveryItem ON WithoutChargeItem~ReferenceSDDocument = CustomerReturnDeliveryItem~ReferenceSDDocument
*                                                                                                                                      AND WithoutChargeItem~ReferenceSDDocumentItem = CustomerReturnDeliveryItem~ReferenceSDDocumentItem
*         WHERE CustomerReturnDeliveryItem~Customerreturndelivery = @<key>-%param-OutboundDelivery
*            INTO TABLE @DATA(lt_soitemwithoutcharge).

        " Get all serial number
        SELECT
                a~serialnumber,
                a~material,
                a~DeliveryDocument,
                a~DeliveryDocumentItem,
                b~storagelocation
*                _DeliveryDocumentItem~storagelocation

         FROM I_SerialNumberDeliveryDocument WITH PRIVILEGED ACCESS AS a
              JOIN I_deliverydocumentitem WITH PRIVILEGED ACCESS AS b ON a~DeliveryDocument = b~DeliveryDocument
                                          AND a~DeliveryDocumentItem = b~DeliveryDocumentitem
            WHERE a~DeliveryDocument = @<key>-%param-OutboundDelivery
            INTO TABLE @DATA(lt_sn).

        SORT lt_sn BY DeliveryDocument DeliveryDocumentItem.

*        LOOP AT lt_soitemwithoutcharge ASSIGNING FIELD-SYMBOL(<fs_soitemwithoutcharge>).
        LOOP AT lt_customerreturndeliveryitem ASSIGNING FIELD-SYMBOL(<fs_dn>).
          " skip damage product stoarge location
          READ TABLE lt_damage_location TRANSPORTING NO FIELDS WITH KEY StorageLocation = <fs_dn>-StorageLocation
                                                                        writebacksn = abap_false
                                                                        BINARY SEARCH.
          IF sy-subrc = 0.
            CONTINUE.
          ENDIF.

          IF <fs_dn>-DeliveryDocumentItemCategory <> 'RENI'.
            READ TABLE lt_salesorder_withoutcharge ASSIGNING FIELD-SYMBOL(<fs_soitemwithoutcharge>) WITH KEY ReferenceSDDocument = <fs_dn>-ReferenceSDDocument
                                                                                                             ReferenceSDDocumentItem = <fs_dn>-ReferenceSDDocumentItem.
            IF sy-subrc = 0.
              READ TABLE lt_sn ASSIGNING FIELD-SYMBOL(<fs_sn>) WITH KEY DeliveryDocument = <fs_dn>-CustomerReturnDelivery
                                                                        DeliveryDocumentItem = <fs_dn>-CustomerReturnDeliveryItem
                                                                        BINARY SEARCH.
              IF sy-subrc = 0.
                lv_index = sy-tabix.
                CLEAR ls_soitem_change.
                ls_soitem_change = VALUE #( YY1_RefereneceMaterial_SDI = <fs_sn>-Material
                                            YY1_RefereneceSerialNo_SDI = <fs_sn>-SerialNumber
                                            YY1_RefereneceOldSeria_SDI = ''
                                  %tky-SalesOrder = <fs_soitemwithoutcharge>-SalesOrderWithoutCharge
                                  %tky-salesorderitem = <fs_soitemwithoutcharge>-SalesOrderWithoutChargeItem
                                  ).

                SELECT SINGLE zoldserialnumber
                    FROM zr_tmm001 WITH PRIVILEGED ACCESS
                    WHERE product = @<fs_sn>-Material
                      AND Zserialnumber = @<fs_sn>-SerialNumber
                    INTO @ls_soitem_change-YY1_RefereneceOldSeria_SDI.

                APPEND ls_soitem_change TO lt_soitem_change.
                DELETE lt_sn INDEX lv_index.
              ENDIF.
            ENDIF.

          ELSE.
            READ TABLE lt_salesorder_withoutcharge ASSIGNING <fs_soitemwithoutcharge> WITH KEY ReferenceSDDocument = <fs_dn>-ReferenceSDDocument
                                                                                                              Product = <fs_dn>-Material
                                                                                                              YY1_RefereneceSerialNo_SDI = ''.
            IF sy-subrc = 0.
              READ TABLE lt_sn ASSIGNING <fs_sn> WITH KEY DeliveryDocument = <fs_dn>-CustomerReturnDelivery
                                                                        DeliveryDocumentItem = <fs_dn>-CustomerReturnDeliveryItem
                                                                        BINARY SEARCH.
              IF sy-subrc = 0.
                lv_index = sy-tabix.
                CLEAR ls_soitem_change.
                ls_soitem_change = VALUE #( YY1_RefereneceMaterial_SDI = <fs_sn>-Material
                                            YY1_RefereneceSerialNo_SDI = <fs_sn>-SerialNumber
                                            YY1_RefereneceOldSeria_SDI = ''
                                  %tky-SalesOrder = <fs_soitemwithoutcharge>-SalesOrderWithoutCharge
                                  %tky-salesorderitem = <fs_soitemwithoutcharge>-SalesOrderWithoutChargeItem
                                  ).

                SELECT SINGLE zoldserialnumber
                    FROM zr_tmm001 WITH PRIVILEGED ACCESS
                    WHERE product = @<fs_sn>-Material
                      AND Zserialnumber = @<fs_sn>-SerialNumber
                    INTO @ls_soitem_change-YY1_RefereneceOldSeria_SDI.

                APPEND ls_soitem_change TO lt_soitem_change.
                DELETE lt_sn INDEX lv_index.
              ENDIF.
            ENDIF.

          ENDIF.

        ENDLOOP.




      ELSE.
        ls_customerreturn = abap_false.


        " Get all serial number
        SELECT
                a~serialnumber,
                a~material,
                a~DeliveryDocument,
                a~DeliveryDocumentItem,
                b~storagelocation
*                _DeliveryDocumentItem~storagelocation

         FROM I_SerialNumberDeliveryDocument WITH PRIVILEGED ACCESS AS a
              JOIN I_deliverydocumentitem WITH PRIVILEGED ACCESS AS b ON a~DeliveryDocument = b~DeliveryDocument
                                          AND a~DeliveryDocumentItem = b~DeliveryDocumentitem
            WHERE a~DeliveryDocument = @<key>-%param-OutboundDelivery
            INTO TABLE @lt_sn.


        " Get all Extend Warranty Order Item ( extend warranty serial number empty )

*        "如果SDDocumentCategory = 'C'，就要找YY1_WarrantySerial_SDI为空的回写。如果SDDocumentCategory = 'I'，就不用判断YY1_WarrantySerial_SDI是否为空，直接回写------废弃，使用LOB04-035逻辑
        SELECT SINGLE I_SalesDocument~SDDocumentCategory
            FROM I_SalesDocument WITH PRIVILEGED ACCESS
            JOIN I_deliverydocumentitem WITH PRIVILEGED ACCESS ON I_deliverydocumentitem~ReferenceSDDocument = I_SalesDocument~SalesDocument
             WHERE I_deliverydocumentitem~DeliveryDocument = @<key>-%param-OutboundDelivery
             INTO @DATA(LV_SDDocumentCategory).
        " Changed by HANDZHH 20240229 LOB04-035 Change write back serial number logic to custom field YY1_EXTENDSERIALFIXED_SDI.
        IF LV_SDDocumentCategory = 'I'.
          ls_freeso = abap_true.
        ELSE.
          ls_freeso = abap_false.
        ENDIF.
        SELECT SalesDocument,
               SalesDocumentItem,
               deliverydocument,
               deliverydocumentitem,
               YY1_WarrantyMaterial_SDI,
               dnitem~storagelocation
               FROM I_SalesDocumentItem WITH PRIVILEGED ACCESS AS item
               JOIN zr_tsd001 WITH PRIVILEGED ACCESS AS tsd001 ON item~Product = tsd001~ZWarrantyMaterial
               JOIN I_deliverydocumentitem WITH PRIVILEGED ACCESS AS dnitem ON item~SalesDocument = dnitem~ReferenceSDDocument
                                                                                  AND item~salesdocumentitem = dnitem~ReferenceSDDocumentItem
                                             WHERE dnItem~DeliveryDocument = @<key>-%param-OutboundDelivery
*                                                 AND item~YY1_WarrantySerial_SDI = ''
                                               AND item~YY1_ExtendSerialFixed_SDI = @abap_false
                INTO TABLE @DATA(lt_notassignsoitem).
        SORT lt_notassignsoitem BY salesdocument SalesDocumentItem.
        DELETE ADJACENT DUPLICATES FROM lt_notassignsoitem COMPARING salesdocument SalesDocumentItem.



        "Change V7 Deleted by Vic 231201 Overwrite all so line item
        " Get all assigned extend line item
*          SELECT YY1_WarrantySerial_SDI
*              FROM I_SalesDocumentItem AS item JOIN zr_tsd001 AS tsd001 ON item~Product = tsd001~ZWarrantyMaterial
*                                        JOIN I_deliverydocumentitem AS dnitem ON item~SalesDocument = dnitem~ReferenceSDDocument
*                                        WHERE dnItem~DeliveryDocument = @<key>-%param-OutboundDelivery
*                                          AND item~YY1_WarrantySerial_SDI <> ''
*              INTO TABLE @DATA(lt_assignedsn).
*          SORT lt_assignedsn BY YY1_WarrantySerial_SDI.

        "Get all Fixed Extended Line
        SELECT YY1_WarrantySerial_SDI
             FROM I_SalesDocumentItem WITH PRIVILEGED ACCESS AS item
             JOIN I_deliverydocumentitem WITH PRIVILEGED ACCESS AS dnitem ON item~SalesDocument = dnitem~ReferenceSDDocument
                  WHERE dnItem~DeliveryDocument = @<key>-%param-OutboundDelivery
                    AND item~YY1_ExtendSerialFixed_SDI = @abap_true
                    INTO TABLE @DATA(lt_fixedsn).
        SORT lt_fixedsn BY YY1_WarrantySerial_SDI.

        LOOP AT lt_sn ASSIGNING <fs_sn>.
          READ TABLE lt_fixedsn TRANSPORTING NO FIELDS WITH KEY YY1_WarrantySerial_SDI = <fs_sn>-SerialNumber BINARY SEARCH.
          IF sy-subrc = 0 .
            DELETE lt_sn.
            CONTINUE.
          ENDIF.

          READ TABLE lt_damage_location TRANSPORTING NO FIELDS WITH KEY StorageLocation = <fs_sn>-StorageLocation
                                                                        writebacksn = abap_false
                                                                        BINARY SEARCH.
          IF sy-subrc = 0 .
            DELETE lt_sn.
            CONTINUE.
          ENDIF.

        ENDLOOP.


*        IF LV_SDDocumentCategory = 'C'.
*          ls_freeso = abap_false.
*
*          SELECT SalesDocument,
*                 SalesDocumentItem,
*                 deliverydocument,
*                 deliverydocumentitem,
*                 YY1_WarrantyMaterial_SDI,
*                 dnitem~storagelocation
*                 FROM I_SalesDocumentItem AS item JOIN zr_tsd001 AS tsd001 ON item~Product = tsd001~ZWarrantyMaterial
*                                               JOIN I_deliverydocumentitem AS dnitem ON item~SalesDocument = dnitem~ReferenceSDDocument
*                                                                                    AND item~salesdocumentitem = dnitem~ReferenceSDDocumentItem
*                                               WHERE dnItem~DeliveryDocument = @<key>-%param-OutboundDelivery
*                                                 AND item~YY1_WarrantySerial_SDI = ''
*                  INTO TABLE @DATA(lt_notassignsoitem).
*          SORT lt_notassignsoitem BY salesdocument SalesDocumentItem.
*          DELETE ADJACENT DUPLICATES FROM lt_notassignsoitem COMPARING salesdocument SalesDocumentItem.
*
*
*
*          "Change V7 Deleted by Vic 231201 Overwrite all so line item
*          " Get all assigned extend line item
*          SELECT YY1_WarrantySerial_SDI
*              FROM I_SalesDocumentItem AS item JOIN zr_tsd001 AS tsd001 ON item~Product = tsd001~ZWarrantyMaterial
*                                        JOIN I_deliverydocumentitem AS dnitem ON item~SalesDocument = dnitem~ReferenceSDDocument
*                                        WHERE dnItem~DeliveryDocument = @<key>-%param-OutboundDelivery
*                                          AND item~YY1_WarrantySerial_SDI <> ''
*              INTO TABLE @DATA(lt_assignedsn).
*          SORT lt_assignedsn BY YY1_WarrantySerial_SDI.
*
*
*          LOOP AT lt_sn ASSIGNING <fs_sn>.
*            READ TABLE lt_assignedsn TRANSPORTING NO FIELDS WITH KEY YY1_WarrantySerial_SDI = <fs_sn>-SerialNumber BINARY SEARCH.
*            IF sy-subrc = 0 .
*              DELETE lt_sn.
*              CONTINUE.
*            ENDIF.
*
*            READ TABLE lt_damage_location TRANSPORTING NO FIELDS WITH KEY StorageLocation = <fs_sn>-StorageLocation
*                                                                          writebacksn = abap_false
*                                                                          BINARY SEARCH.
*            IF sy-subrc = 0 .
*              DELETE lt_sn.
*              CONTINUE.
*            ENDIF.
*
*          ENDLOOP.
*        ELSE.
*          IF LV_SDDocumentCategory = 'I'.
*            ls_freeso = abap_true.
*          ELSE.
*            ls_freeso = abap_false.
*          ENDIF.
*
*
*          SELECT SalesDocument,
*                 SalesDocumentItem,
*                 deliverydocument,
*                 deliverydocumentitem,
*                 YY1_WarrantyMaterial_SDI,
*                 dnitem~storagelocation
*                 FROM I_SalesDocumentItem AS item JOIN zr_tsd001 AS tsd001 ON item~Product = tsd001~ZWarrantyMaterial
*                                               JOIN I_deliverydocumentitem AS dnitem ON item~SalesDocument = dnitem~ReferenceSDDocument
*                                                                                    AND item~salesdocumentitem = dnitem~ReferenceSDDocumentItem
*                                               WHERE dnItem~DeliveryDocument = @<key>-%param-OutboundDelivery
**                                                 AND item~YY1_WarrantySerial_SDI = ''
*                  INTO TABLE @lt_notassignsoitem.
*          SORT lt_notassignsoitem BY salesdocument SalesDocumentItem.
*          DELETE ADJACENT DUPLICATES FROM lt_notassignsoitem COMPARING salesdocument SalesDocumentItem.
*
*
*
*          "Change V7 Deleted by Vic 231201 Overwrite all so line item
*          " Get all assigned extend line item
**          SELECT YY1_WarrantySerial_SDI
**              FROM I_SalesDocumentItem AS item JOIN zr_tsd001 AS tsd001 ON item~Product = tsd001~ZWarrantyMaterial
**                                        JOIN I_deliverydocumentitem AS dnitem ON item~SalesDocument = dnitem~ReferenceSDDocument
**                                        WHERE dnItem~DeliveryDocument = @<key>-%param-OutboundDelivery
**                                          AND item~YY1_WarrantySerial_SDI <> ''
**              INTO TABLE @DATA(lt_assignedsn).
**          SORT lt_assignedsn BY YY1_WarrantySerial_SDI.
*
*
*          LOOP AT lt_sn ASSIGNING <fs_sn>.
**            READ TABLE lt_assignedsn TRANSPORTING NO FIELDS WITH KEY YY1_WarrantySerial_SDI = <fs_sn>-SerialNumber BINARY SEARCH.
**            IF sy-subrc = 0 .
**              DELETE lt_sn.
**              CONTINUE.
**            ENDIF.
*
*            READ TABLE lt_damage_location TRANSPORTING NO FIELDS WITH KEY StorageLocation = <fs_sn>-StorageLocation
*                                                                          writebacksn = abap_false
*                                                                          BINARY SEARCH.
*            IF sy-subrc = 0 .
*              DELETE lt_sn.
*              CONTINUE.
*            ENDIF.
*
*          ENDLOOP.
*
*        ENDIF.




        LOOP AT lt_notassignsoitem ASSIGNING FIELD-SYMBOL(<fs_notassignsn>).

          " skip damage product stoarge location
*          READ TABLE lt_damage_location TRANSPORTING NO FIELDS WITH KEY StorageLocation = <fs_notassignsn>-StorageLocation
*                                                                        BINARY SEARCH.
*          IF sy-subrc = 0.
*            CONTINUE.
*          ENDIF.

          READ TABLE lt_sn ASSIGNING <fs_sn> WITH KEY Material = <fs_notassignsn>-YY1_WarrantyMaterial_SDI.
          IF sy-subrc = 0.
            lv_index = sy-tabix.
            CLEAR ls_soitem_change.
            ls_soitem_change = VALUE #( YY1_WarrantySerial_SDI = <fs_sn>-SerialNumber
                              %tky-SalesOrder = <fs_notassignsn>-SalesDocument
                              %tky-salesorderitem = <fs_notassignsn>-SalesDocumentItem
*                              %key-salesorder            = <fs_notassignsn>-SalesDocument
*                              %key-salesorderitem        = <fs_notassignsn>-SalesDocumentItem
                               ).
            APPEND ls_soitem_change TO lt_soitem_change.

*            CLEAR ls_dnitem_change.
*            ls_dnitem_change = VALUE #( YY1_WarrantySerial_DLI = <fs_sn>-SerialNumber
*                  %tky-OutboundDelivery = <fs_notassignsn>-DeliveryDocument
*                  %tky-OutboundDeliveryItem = <fs_notassignsn>-DeliveryDocumentItem
**                  %key-OutboundDelivery            = <fs_notassignsn>-DeliveryDocument
**                  %key-OutboundDeliveryItem        = <fs_notassignsn>-DeliveryDocumentItem
*                   ).
*            APPEND ls_dnitem_change TO lt_dnitem_change.

            DELETE lt_sn INDEX lv_index.
          ENDIF.
        ENDLOOP.

      ENDIF.

      IF has_error = abap_false AND lines( lt_soitem_change ) > 0.
        IF ls_customerreturn = abap_false.

          IF ls_freeso = abap_false.
            MODIFY ENTITIES OF i_salesordertp
              ENTITY SalesOrderItem
              UPDATE FIELDS ( YY1_WarrantySerial_SDI )
              WITH lt_soitem_change
*            WITH VALUE #( ( RequestedQuantity = lv_soitemqty
*                  %tky-SalesOrder = lv_salesorder
*                  %tky-salesorderitem = lv_salesorderitem
*                  %key-salesorder            = lv_salesorder
*                  %key-salesorderitem        = lv_salesorderitem ) )
              FAILED   DATA(ls_soitem_failed)
              REPORTED DATA(ls_soitem_reported).
          ELSE.
            DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
            DATA: lo_client_proxy      TYPE REF TO /iwbep/if_cp_client_proxy.


            " Find CA by Scenario ID
            lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
            DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
            lo_factory->query_ca(
              EXPORTING
                is_query           = VALUE #( cscn_id_range = lr_cscn )
              IMPORTING
                et_com_arrangement = DATA(lt_ca) ).

            IF lt_ca IS INITIAL.
              EXIT.
            ENDIF.
            " take the first one
            READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
            " get destination based on Communication Arrangement and the service ID
            TRY.
                DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
                    comm_scenario  = 'YY1_API'
                    service_id     = 'YY1_API_REST'
                    comm_system_id = lo_ca->get_comm_system_id( ) ).

              CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
                EXIT.
            ENDTRY.

            "Get Every free so item
            LOOP AT lt_soitem_change ASSIGNING FIELD-SYMBOL(<fs_soitem_change>).

              TRY.


                  DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

                  DATA(lo_request) = lo_http_client->get_http_request(   ).



                  lo_http_client->enable_path_prefix( ).
                  DATA: lv_url TYPE string.

                  lv_url = '/API_SALES_ORDER_WITHOUT_CHARGE_SRV/A_SalesOrderWithoutChargeItem(SalesOrderWithoutCharge='''
                           &&  <fs_soitem_change>-SalesOrder
                           && ''',SalesOrderWithoutChargeItem=''' && <fs_soitem_change>-SalesOrderItem && ''')'.

                  lo_request->set_uri_path( EXPORTING i_uri_path = lv_url ).
                  lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
                  lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

                  lo_http_client->set_csrf_token(  ).

                  lo_request->set_content_type( 'application/json' ).

                  TYPES : BEGIN OF ts_free_so_item_change1,
                            YY1_WarrantySerial_SDI TYPE string,
*                            YY1_RefereneceMaterial_SDI TYPE string,
*                            YY1_RefereneceOldSeria_SDI TYPE string,
                          END OF ts_free_so_item_change1.

                  DATA : ls_free_so_item_change1 TYPE ts_free_so_item_change1,
                         lt_mapping              TYPE /ui2/cl_json=>name_mappings,
                         lv_json                 TYPE /ui2/cl_json=>json.
                  ls_free_so_item_change1-YY1_WarrantySerial_SDI = <fs_soitem_change>-YY1_WarrantySerial_SDI.
*                  ls_free_so_item_change-YY1_RefereneceMaterial_SDI = <fs_soitem_change>-YY1_RefereneceMaterial_SDI.
*                  ls_free_so_item_change-YY1_RefereneceOldSeria_SDI = <fs_soitem_change>-YY1_RefereneceOldSeria_SDI.


                  lt_mapping = VALUE #( ( abap = `YY1_WARRANTYSERIAL_SDI` json = `YY1_WarrantySerial_SDI` ) ).

                  lv_json = /ui2/cl_json=>serialize(
                      data = ls_free_so_item_change1
                      name_mappings = lt_mapping
                   ).

                  lo_request->set_text( lv_json ).



                  DATA(lo_response) = lo_http_client->execute( if_web_http_client=>patch ).

                  DATA(lv_response) = lo_response->get_text(  ).


                  DATA(status) = lo_response->get_status( ).
                  IF status-code > 299.
                    DATA : lo_error TYPE REF TO data.
                    "Error handling here
                    "handle odata error message here
                    /ui2/cl_json=>deserialize(
                        EXPORTING
                            json = lv_response
                        CHANGING
                            data = lo_error
                    ).
                    ASSIGN COMPONENT 'ERROR' OF STRUCTURE lo_error->* TO FIELD-SYMBOL(<fo_error>).
                    IF sy-subrc = 0.
                      ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <fo_error>->* TO FIELD-SYMBOL(<fo_message>).
                      IF sy-subrc = 0.
                        ASSIGN COMPONENT 'VALUE' OF STRUCTURE <fo_message>->* TO FIELD-SYMBOL(<fo_msgVALUE>).
                        IF sy-subrc = 0.
                          reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                                  %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                               text = <fo_msgVALUE>->* )  ) ).
                        ENDIF.
                      ENDIF.

                    ENDIF.
                    failed-zr_tsd004  = VALUE #( ( %cid = <key>-%cid ) ).
                    EXIT.
                  ELSE.
                    " success

                  ENDIF.


                CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
*            CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
                  DATA : lv_message TYPE string.
                  lv_message = lX_WEB_HTTP_CLIENT_ERROR->get_longtext(  ).
                  reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                             %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                          text = lv_message )  ) ).
                  failed-zr_tsd004  = VALUE #( ( %cid = <key>-%cid ) ).
              ENDTRY.

            ENDLOOP.
          ENDIF.
        ELSE.
*          MODIFY ENTITIES OF i_salesordertp
*            ENTITY SalesOrderItem
*            UPDATE FIELDS ( YY1_RefereneceMaterial_SDI  YY1_RefereneceSerialNo_SDI YY1_RefereneceOldSeria_SDI )
*            WITH lt_soitem_change
**            WITH VALUE #( ( RequestedQuantity = lv_soitemqty
**                  %tky-SalesOrder = lv_salesorder
**                  %tky-salesorderitem = lv_salesorderitem
**                  %key-salesorder            = lv_salesorder
**                  %key-salesorderitem        = lv_salesorderitem ) )
*            FAILED   ls_soitem_failed
*            REPORTED ls_soitem_reported.

*          DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
*          DATA: lo_client_proxy      TYPE REF TO /iwbep/if_cp_client_proxy.


          " Find CA by Scenario ID
          lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
          lo_factory = cl_com_arrangement_factory=>create_instance( ).
          lo_factory->query_ca(
            EXPORTING
              is_query           = VALUE #( cscn_id_range = lr_cscn )
            IMPORTING
              et_com_arrangement = lt_ca ).

          IF lt_ca IS INITIAL.
            EXIT.
          ENDIF.
          " take the first one
          READ TABLE lt_ca INTO lo_ca INDEX 1.
          " get destination based on Communication Arrangement and the service ID
          TRY.
              lo_dest = cl_http_destination_provider=>create_by_comm_arrangement(
                  comm_scenario  = 'YY1_API'
                  service_id     = 'YY1_API_REST'
                  comm_system_id = lo_ca->get_comm_system_id( ) ).

            CATCH cx_http_dest_provider_error INTO lx_http_dest_provider_error.
              EXIT.
          ENDTRY.

          "Get Every free so item
          LOOP AT lt_soitem_change ASSIGNING <fs_soitem_change>.

            TRY.


                lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

                lo_request = lo_http_client->get_http_request(   ).



                lo_http_client->enable_path_prefix( ).
*                DATA: lv_url TYPE string.

                lv_url = '/API_SALES_ORDER_WITHOUT_CHARGE_SRV/A_SalesOrderWithoutChargeItem(SalesOrderWithoutCharge='''
                         &&  <fs_soitem_change>-SalesOrder
                         && ''',SalesOrderWithoutChargeItem=''' && <fs_soitem_change>-SalesOrderItem && ''')'.

                lo_request->set_uri_path( EXPORTING i_uri_path = lv_url ).
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).
                lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

                lo_http_client->set_csrf_token(  ).

                lo_request->set_content_type( 'application/json' ).

                TYPES : BEGIN OF ts_free_so_item_change,
                          YY1_RefereneceSerialNo_SDI TYPE string,
                          YY1_RefereneceMaterial_SDI TYPE string,
                          YY1_RefereneceOldSeria_SDI TYPE string,
                        END OF ts_free_so_item_change.

                DATA : ls_free_so_item_change TYPE ts_free_so_item_change.
*                       lt_mapping             TYPE /ui2/cl_json=>name_mappings,
*                       lv_json                TYPE /ui2/cl_json=>json.
                ls_free_so_item_change-YY1_RefereneceSerialNo_SDI = <fs_soitem_change>-YY1_RefereneceSerialNo_SDI.
                ls_free_so_item_change-YY1_RefereneceMaterial_SDI = <fs_soitem_change>-YY1_RefereneceMaterial_SDI.
                ls_free_so_item_change-YY1_RefereneceOldSeria_SDI = <fs_soitem_change>-YY1_RefereneceOldSeria_SDI.


                lt_mapping = VALUE #( ( abap = `YY1_REFERENECESERIALNO_SDI` json = `YY1_RefereneceSerialNo_SDI` )
                      ( abap = `YY1_REFERENECEMATERIAL_SDI` json = `YY1_RefereneceMaterial_SDI` )
                      ( abap = `YY1_REFERENECEOLDSERIA_SDI` json = `YY1_RefereneceOldSeria_SDI` ) ).

                lv_json = /ui2/cl_json=>serialize(
                    data = ls_free_so_item_change
                    name_mappings = lt_mapping
                 ).

                lo_request->set_text( lv_json ).



                lo_response = lo_http_client->execute( if_web_http_client=>patch ).

                lv_response = lo_response->get_text(  ).


                status = lo_response->get_status( ).
                IF status-code > 299.
*                  DATA : lo_error TYPE REF TO data.
                  "Error handling here
                  "handle odata error message here
                  /ui2/cl_json=>deserialize(
                      EXPORTING
                          json = lv_response
                      CHANGING
                          data = lo_error
                  ).
                  ASSIGN COMPONENT 'ERROR' OF STRUCTURE lo_error->* TO <fo_error>.
                  IF sy-subrc = 0.
                    ASSIGN COMPONENT 'MESSAGE' OF STRUCTURE <fo_error>->* TO <fo_message>.
                    IF sy-subrc = 0.
                      ASSIGN COMPONENT 'VALUE' OF STRUCTURE <fo_message>->* TO <fo_msgVALUE>.
                      IF sy-subrc = 0.
                        reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                                %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                             text = <fo_msgVALUE>->* )  ) ).
                      ENDIF.
                    ENDIF.

                  ENDIF.
                  failed-zr_tsd004  = VALUE #( ( %cid = <key>-%cid ) ).
                  EXIT.
                ELSE.
                  " success

                ENDIF.


              CATCH cx_web_http_client_error INTO lX_WEB_HTTP_CLIENT_ERROR.
*            CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
*                DATA : lv_message TYPE string.
                lv_message = lX_WEB_HTTP_CLIENT_ERROR->get_longtext(  ).
                reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                           %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                        text = lv_message )  ) ).
                failed-zr_tsd004  = VALUE #( ( %cid = <key>-%cid ) ).
            ENDTRY.

          ENDLOOP.

        ENDIF.


        IF lines( ls_soitem_failed-salesorderitem ) > 0.
          has_error = abap_true.
          reported-zr_tsd004 = VALUE #(  FOR soitem IN ls_soitem_reported-salesorderitem ( %cid = <key>-%cid %msg = soitem-%msg ) ).
          failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid ) ).
        ELSE.
*          IF lines( lt_dnitem_change ) > 0.
*            MODIFY ENTITIES OF I_OutboundDeliveryTP
*                ENTITY OutboundDeliveryItem
*                UPDATE FIELDS ( YY1_WarrantySerial_DLI )
*                WITH lt_dnitem_change
*            FAILED   DATA(ls_dnitem_failed)
*          REPORTED DATA(ls_dnitem_reported).
*          ENDIF.
*          IF lines( ls_dnitem_failed-outbounddeliveryitem ) > 0.
*            has_error = abap_true.
*            reported-zr_tsd004 = VALUE #(  FOR dnitem IN ls_dnitem_reported-outbounddeliveryitem ( %cid = <key>-%cid %msg = dnitem-%msg ) ).
*            failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid ) ).
*          ENDIF.
        ENDIF.
      ENDIF.

    ENDIF.
  ENDMETHOD.

  METHOD checkAllItemsFullyScanned.
    ASSERT lines( keys ) > 0.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.

      " Check not return item
      SELECT SINGLE CustomerReturnDelivery
        FROM I_CustomerReturnDelivery WITH PRIVILEGED ACCESS
        WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery
        INTO @DATA(lv_customerreturndelivery).
      IF sy-subrc = 0.
        result = VALUE #( ( %cid = <key>-%cid %param-Boolean = abap_true ) ).
        RETURN.
      ENDIF.

*        read ENTITIES OF zr_tsd004 IN LOCAL MODE
*        READ ENTITIES OF I_OutboundDeliveryTP ENTITY OutboundDeliveryItem
*        ALL FIELDS WITH VALUE #(
      SELECT outbounddelivery,
             outbounddeliveryitem,
             ActualDeliveryQuantity
             FROM zr_ssd018 WITH PRIVILEGED ACCESS
             WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
*               AND PickingStatus NE ''
           INTO TABLE @DATA(lt_deliveryitem).

      IF sy-subrc = 0.
        LOOP AT lt_deliveryitem ASSIGNING FIELD-SYMBOL(<fs_deliveryitem>).
          READ ENTITIES OF zr_tsd004 IN LOCAL MODE ENTITY zr_tsd004
            EXECUTE getScannedQty FROM VALUE #(
                        ( %param-OutboundDelivery = <fs_deliveryitem>-OutboundDelivery
                          %param-OutboundDeliveryItem = <fs_deliveryitem>-OutboundDeliveryItem ) )

            RESULT FINAL(lt_scanned_qty).
          IF lines( lt_scanned_qty ) > 0 .
            IF <fs_deliveryitem>-ActualDeliveryQuantity NE lt_scanned_qty[ 1 ]-%param-ScannedQuantity.
              result = VALUE #( ( %cid = <key>-%cid %param-Boolean = abap_false ) ).
              reported-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                                              %msg = new_message(
                                                      id = 'ZZSD'
                                                      number = 014
                                                      severity = if_abap_behv_message=>severity-error
                                                      )
                                                                    ) ).
              failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid
                                             ) ).
              RETURN.
            ENDIF.
          ENDIF.

        ENDLOOP.
      ENDIF.

    ENDIF.
    result = VALUE #( ( %cid = <key>-%cid %param-Boolean = abap_true ) ).

  ENDMETHOD.

  METHOD writeBackSerialNumberDN.

    ASSERT lines( keys ) > 0.

    DATA: has_error TYPE abap_boolean,
          lv_index  TYPE sy-tabix.
    DATA : lt_soitem_change TYPE TABLE FOR UPDATE I_salesorderitemtp,
           ls_soitem_change LIKE LINE OF lt_soitem_change,
           lt_dnitem_change TYPE TABLE FOR UPDATE I_OutboundDeliveryItemTP,
           ls_dnitem_change LIKE LINE OF lt_dnitem_change.
    DATA : ls_customerreturn TYPE abap_bool.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.
      has_error = abap_false.

      " check damage product
      SELECT storagelocation,                           "#EC CI_NOWHERE
             writebacksn
        FROM zr_tsd014 WITH PRIVILEGED ACCESS
        INTO TABLE @DATA(lt_damage_location).
      SORT lt_damage_location BY StorageLocation writebacksn.


      " Check not return item
      SELECT SINGLE CustomerReturnDelivery
        FROM I_CustomerReturnDelivery WITH PRIVILEGED ACCESS
        WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery
        INTO @DATA(lv_customerreturndelivery).
      IF sy-subrc = 0.
        ls_customerreturn = abap_true.

      ELSE.
        ls_customerreturn = abap_false.


        " Get all serial number
        SELECT
                a~serialnumber,
                a~material,
                a~DeliveryDocument,
                a~DeliveryDocumentItem,
                b~storagelocation
*                _DeliveryDocumentItem~storagelocation

         FROM I_SerialNumberDeliveryDocument WITH PRIVILEGED ACCESS AS a
              JOIN I_deliverydocumentitem WITH PRIVILEGED ACCESS AS b ON a~DeliveryDocument = b~DeliveryDocument
                                          AND a~DeliveryDocumentItem = b~DeliveryDocumentitem
            WHERE a~DeliveryDocument = @<key>-%param-OutboundDelivery
            INTO TABLE @DATA(lt_sn).


        " Get all Extend Warranty Order Item ( extend warranty serial number empty )
        SELECT SalesDocument,
               SalesDocumentItem,
               deliverydocument,
               deliverydocumentitem,
               YY1_WarrantyMaterial_SDI,
               item~YY1_WarrantySerial_SDI,
               dnitem~storagelocation
               FROM I_SalesDocumentItem WITH PRIVILEGED ACCESS AS item
               JOIN zr_tsd001 WITH PRIVILEGED ACCESS AS tsd001 ON item~Product = tsd001~ZWarrantyMaterial
               JOIN I_deliverydocumentitem WITH PRIVILEGED ACCESS AS dnitem ON item~SalesDocument = dnitem~ReferenceSDDocument
                                                                                  AND item~salesdocumentitem = dnitem~ReferenceSDDocumentItem
                                             WHERE dnItem~DeliveryDocument = @<key>-%param-OutboundDelivery
                                               AND item~YY1_WarrantySerial_SDI <> ''
                INTO TABLE @DATA(lt_assignsoitem).
        SORT lt_assignsoitem BY salesdocument SalesDocumentItem.
        DELETE ADJACENT DUPLICATES FROM lt_assignsoitem COMPARING salesdocument SalesDocumentItem.

*        "Change V7 Deleted by Vic 231201 Overwrite all so line item
        " Get all assigned extend line item
*        SELECT YY1_WarrantySerial_SDI
*            FROM I_SalesDocumentItem AS item JOIN zr_tsd001 AS tsd001 ON item~Product = tsd001~ZWarrantyMaterial
*                                      JOIN I_deliverydocumentitem AS dnitem ON item~SalesDocument = dnitem~ReferenceSDDocument
*                                      WHERE dnItem~DeliveryDocument = @<key>-%param-OutboundDelivery
*                                        AND item~YY1_WarrantySerial_SDI <> ''
*            INTO TABLE @DATA(lt_assignedsn).
*        SORT lt_assignedsn BY YY1_WarrantySerial_SDI.


*        LOOP AT lt_sn ASSIGNING FIELD-SYMBOL(<fs_sn>).
*          READ TABLE lt_assignedsn TRANSPORTING NO FIELDS WITH KEY YY1_WarrantySerial_SDI = <fs_sn>-SerialNumber BINARY SEARCH.
*          IF sy-subrc = 0.
*            DELETE lt_sn.
*            CONTINUE.
*          ENDIF.
*          READ TABLE lt_damage_location TRANSPORTING NO FIELDS WITH KEY StorageLocation = <fs_sn>-StorageLocation
*                                                                        writebacksn = abap_false
*                                                                        BINARY SEARCH.
*          IF sy-subrc = 0.
*            DELETE lt_sn.
*            CONTINUE.
*          ENDIF.
*        ENDLOOP.





        LOOP AT lt_assignsoitem ASSIGNING FIELD-SYMBOL(<fs_assignsn>).

          " skip damage product stoarge location
*          READ TABLE lt_damage_location TRANSPORTING NO FIELDS WITH KEY StorageLocation = <fs_notassignsn>-StorageLocation
*                                                                        BINARY SEARCH.
*          IF sy-subrc = 0.
*            CONTINUE.
*          ENDIF.

*          READ TABLE lt_sn ASSIGNING <fs_sn> WITH KEY Material = <fs_notassignsn>-YY1_WarrantyMaterial_SDI.
*          IF sy-subrc = 0.
*            lv_index = sy-tabix.
          CLEAR ls_dnitem_change.
          ls_dnitem_change = VALUE #( YY1_WarrantySerial_DLI = <fs_assignsn>-YY1_WarrantySerial_SDI
                %tky-OutboundDelivery = <fs_assignsn>-DeliveryDocument
                %tky-OutboundDeliveryItem = <fs_assignsn>-DeliveryDocumentItem
*                %key = VALUE #(
**                    OutboundDelivery            = <fs_assignsn>-DeliveryDocument
*                    OutboundDeliveryItem        = <fs_assignsn>-DeliveryDocumentItem
*                 )
*                %key-OutboundDelivery            = <fs_assignsn>-DeliveryDocument
*                %key-OutboundDeliveryItem        = <fs_assignsn>-DeliveryDocumentItem

                 ).
          APPEND ls_dnitem_change TO lt_dnitem_change.

*            DELETE lt_sn INDEX lv_index.
*          ENDIF.
        ENDLOOP.

      ENDIF.


      IF ls_customerreturn = abap_false.


        IF lines( lt_dnitem_change ) > 0.
          MODIFY ENTITIES OF I_OutboundDeliveryTP
              ENTITY OutboundDeliveryItem
              UPDATE FIELDS ( YY1_WarrantySerial_DLI )
              WITH lt_dnitem_change
          FAILED   DATA(ls_dnitem_failed)
        REPORTED DATA(ls_dnitem_reported).
        ENDIF.
        IF lines( ls_dnitem_failed-outbounddeliveryitem ) > 0.
          has_error = abap_true.
          reported-zr_tsd004 = VALUE #(  FOR dnitem IN ls_dnitem_reported-outbounddeliveryitem ( %cid = <key>-%cid %msg = dnitem-%msg ) ).
          failed-zr_tsd004 = VALUE #( ( %cid = <key>-%cid ) ).
        ENDIF.
      ENDIF.


    ENDIF.
  ENDMETHOD.

ENDCLASS.
