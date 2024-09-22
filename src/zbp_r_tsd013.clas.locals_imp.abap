CLASS LHC_ZR_TSD013 DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZR_TSD013
        RESULT result,

      createSerialNumber
        IMPORTING is_parameter TYPE zr_ssd007
        RETURNING VALUE(rv_result) TYPE abap_boolean,
      deleteSerialNumber
        IMPORTING is_parameter TYPE zr_ssd007
        RETURNING VALUE(rv_result) TYPE abap_boolean,
      addPickedQuantity
        IMPORTING is_parameter TYPE zr_ssd007
        RETURNING VALUE(rv_result) TYPE abap_boolean,
      minusPickedQuantity
        IMPORTING is_parameter TYPE zr_ssd007
        RETURNING VALUE(rv_result) TYPE abap_boolean,
      checkSerialNumberInStock
        IMPORTING is_parameter TYPE zr_ssd007
        RETURNING VALUE(rv_result) TYPE abap_boolean,
      minusPickedQuantity_action FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd013~minusPickedQuantity RESULT result,
      createScannedRecord FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd013~createScannedRecord RESULT result,
      deleteScannedRecord FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd013~deleteScannedRecord RESULT result,
      createNoSerialNumber FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd013~createNoSerialNumber RESULT result,
      deletePGIRecord FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd013~deletePGIRecord RESULT result,
      checkAllSNPicked FOR READ
        IMPORTING keys FOR FUNCTION zr_tsd013~checkAllSNPicked RESULT result,
      checkAllItemsPicked FOR MODIFY
        IMPORTING keys FOR ACTION zr_tsd013~checkAllItemsPicked RESULT result.
ENDCLASS.

CLASS LHC_ZR_TSD013 IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD createSerialNumber.
    SELECT SINGLE * FROM I_CustomerReturnDelivery WHERE CustomerReturnDelivery = @is_parameter-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
    INTO @DATA(ls_return_delivery).

    IF sy-subrc <> 0.
        " Check this DN is Credit Block
        SELECT SINGLE TotalCreditCheckStatus
        FROM I_OutboundDelivery
        WHERE OutboundDelivery = @is_parameter-OutboundDelivery
          AND TotalCreditCheckStatus = 'B'
        INTO @DATA(lv_totalcreditstatus).

        IF sy-subrc = 0.
            rv_result = 'B'.
            RETURN.
        ENDIF.

        MODIFY ENTITIES OF I_OutboundDeliveryTP
        ENTITY OutboundDeliveryItem
        CREATE BY \_SerialNumber
        FROM VALUE #( ( %tky-OutboundDelivery = is_parameter-OutboundDelivery
                        %tky-OutboundDeliveryItem = is_parameter-OutboundDeliveryItem
                        %target = VALUE #( ( %cid = 'CID_1'
                                             SerialNumber = is_parameter-SerialNumber
                                             %control-SerialNumber = if_abap_behv=>mk-on ) ) ) )
        MAPPED DATA(mapped)
        REPORTED DATA(reported)
        FAILED DATA(failed).

        IF lines( failed-outbdelivitemserialnumber ) > 0.
            rv_result = abap_false.
        ELSE.
            rv_result = abap_true.
        ENDIF.
    ELSE.
        MODIFY ENTITIES OF I_CustomerReturnsDeliveryTP
        ENTITY CustomerReturnsDeliveryItem
        CREATE BY \_SerialNumber
        FROM VALUE #( ( %tky-CustomerReturnDelivery = is_parameter-OutboundDelivery
                        %tky-CustomerReturnDeliveryItem = is_parameter-OutboundDeliveryItem
                        %target = VALUE #( ( %cid = 'CID_1'
                                             SerialNumber = is_parameter-SerialNumber
                                             %control-SerialNumber = if_abap_behv=>mk-on ) ) ) )
        MAPPED DATA(return_mapped)
        REPORTED DATA(return_reported)
        FAILED DATA(return_failed).

        IF lines( return_failed-customerreturnsdeliveryitem ) > 0.
            rv_result = abap_false.
        ELSE.
            rv_result = abap_true.
        ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD deleteSerialNumber.
    SELECT SINGLE * FROM I_CustomerReturnDelivery WHERE CustomerReturnDelivery = @is_parameter-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
    INTO @DATA(ls_return_delivery).

    IF sy-subrc <> 0.
        MODIFY ENTITIES OF I_OutboundDeliveryTP
        ENTITY OutbDelivItemSerialNumber
        DELETE FROM VALUE #( ( OutboundDelivery = is_parameter-OutboundDelivery
                               OutboundDeliveryItem = is_parameter-OutboundDeliveryItem
                               SerialNumber = is_parameter-SerialNumber ) )
        REPORTED FINAL(delete_reported)
        MAPPED FINAL(delete_mapped)
        FAILED FINAL(delete_failed).

        IF lines( delete_failed-outbdelivitemserialnumber ) > 0.
            rv_result = abap_false.
        ELSE.
            rv_result = abap_true.
        ENDIF.
    ELSE.
        MODIFY ENTITIES OF I_CustomerReturnsDeliveryTP
        ENTITY CustRetDelivItemSerialNumber
        DELETE FROM VALUE #( ( CustomerReturnDelivery = is_parameter-OutboundDelivery
                               CustomerReturnDeliveryItem = is_parameter-OutboundDeliveryItem
                               SerialNumber = is_parameter-SerialNumber ) )
        REPORTED FINAL(reported)
        MAPPED FINAL(mapped)
        FAILED FINAL(failed).

        IF lines( failed-custretdelivitemserialnumber ) > 0.
            rv_result = abap_false.
        ELSE.
            rv_result = abap_true.
        ENDIF.
    ENDIF.



  ENDMETHOD.

  METHOD addPickedQuantity.
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.

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

    SELECT SINGLE BaseUnit FROM ZR_SSD021 WHERE OutboundDelivery = @is_parameter-OutboundDelivery
                                                            AND OutboundDeliveryItem = @is_parameter-OutboundDeliveryItem
    INTO @DATA(lv_baseunit).

    DATA lv_languagecode TYPE spras.
    TRY.
        lv_languagecode = cl_abap_context_info=>get_user_language_abap_format(  ).
        SELECT SINGLE UnitOfMeasure_E
        FROM I_UnitOfMeasureText
        WHERE UnitOfMeasure = @lv_baseunit
            AND Language = @lv_languagecode
        INTO @DATA(lv_unit_output).
    CATCH cx_abap_context_info_error.
            "handle exception
    ENDTRY.

    SELECT SINGLE * FROM I_CustomerReturnDelivery WHERE CustomerReturnDelivery = @is_parameter-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
        INTO @DATA(ls_return_delivery).

    IF sy-subrc <> 0.
        READ ENTITIES OF I_OutboundDeliveryTP
        ENTITY OutboundDeliveryItem
        FIELDS ( PickQuantityInOrderUnit ) WITH VALUE #( ( %tky-OutboundDelivery = is_parameter-OutboundDelivery
                                                           %tky-OutboundDeliveryItem = is_parameter-OutboundDeliveryItem ) )
        RESULT FINAL(LT_PICKEDQTY).

        IF lines( LT_PICKEDQTY ) > 0.
            DATA(lv_pickedqty) = LT_PICKEDQTY[ 1 ]-PickQuantityInOrderUnit.
            lv_pickedqty = lv_pickedqty + 1.

            TRY.
                DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

                DATA(lo_request) = lo_http_client->get_http_request( ).

                lo_http_client->enable_path_prefix( ).

                lo_request->set_uri_path( EXPORTING i_uri_path = '/API_OUTBOUND_DELIVERY_SRV;v=0002/SetPickingQuantityWithBaseQuantity' ).
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
                lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

                lo_http_client->set_csrf_token(  ).

                lo_request->set_form_field( i_name = 'DeliveryDocument' i_value =  |'{ CONV string( is_parameter-OutboundDelivery ) }'| ).
                lo_request->set_form_field( i_name = 'DeliveryDocumentItem' i_value =  |'{ CONV string( is_parameter-OutboundDeliveryItem ) }'| ).
                lo_request->set_form_field( i_name = 'ActualDeliveredQtyInBaseUnit' i_value =  |{ CONV i( lv_pickedqty ) }M| ).
                lo_request->set_form_field( i_name = 'BaseUnit' i_value =  |'{ CONV string( lv_unit_output ) }'| ).

                DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
                DATA(lv_response) = lo_response->get_text(  ).

                DATA(status) = lo_response->get_status( ).
                IF status-code NE 200.
                    rv_result = abap_false.
                ELSE.
                    rv_result = abap_true.
                ENDIF.

            CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
                rv_result = abap_false.
            ENDTRY.
        ENDIF.
    ELSE.
        READ ENTITIES OF I_CUSTOMERRETURNSDELIVERYTP
        ENTITY CustomerReturnsDeliveryItem
        FIELDS ( PickQuantityInOrderUnit ) WITH VALUE #( ( %tky-CustomerReturnDelivery = is_parameter-OutboundDelivery
                                                           %tky-CustomerReturnDeliveryItem = is_parameter-OutboundDeliveryItem ) )
        RESULT FINAL(lt_return_pickedqty).

        IF lines( lt_return_pickedqty ) > 0.
            DATA(lv_return_pickedqty) = lt_return_pickedqty[ 1 ]-PickQuantityInOrderUnit.
            lv_return_pickedqty = lv_return_pickedqty + 1.
            TRY.
                lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

                lo_request = lo_http_client->get_http_request( ).

                lo_http_client->enable_path_prefix( ).

                lo_request->set_uri_path( EXPORTING i_uri_path = '/API_CUSTOMER_RETURNS_DELIVERY_SRV;v=0002/SetPutawayQuantityWithBaseQuantity').
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
                lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

                lo_http_client->set_csrf_token(  ).

                lo_request->set_form_field( i_name = 'DeliveryDocument' i_value =  |'{ CONV string( is_parameter-OutboundDelivery ) }'| ).
                lo_request->set_form_field( i_name = 'DeliveryDocumentItem' i_value =  |'{ CONV string( is_parameter-OutboundDeliveryItem ) }'| ).
                lo_request->set_form_field( i_name = 'ActualDeliveredQtyInBaseUnit' i_value =  |{ CONV i( lv_return_pickedqty ) }M| ).
                lo_request->set_form_field( i_name = 'BaseUnit' i_value =  |'{ CONV string( lv_unit_output ) }'| ).

                lo_response = lo_http_client->execute( if_web_http_client=>post ).
                lv_response = lo_response->get_text(  ).

                status = lo_response->get_status( ).
                IF status-code NE 200.
                    rv_result = abap_false.
                ELSE.
                    rv_result = abap_true.
                ENDIF.
            CATCH cx_web_http_client_error INTO lX_WEB_HTTP_CLIENT_ERROR.

            ENDTRY.
        ENDIF.
    ENDIF.


  ENDMETHOD.

  METHOD minusPickedQuantity.
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.

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

        SELECT SINGLE BaseUnit FROM ZR_SSD021 WHERE OutboundDelivery = @is_parameter-OutboundDelivery
                                                            AND OutboundDeliveryItem = @is_parameter-OutboundDeliveryItem
        INTO @DATA(lv_baseunit).

        DATA lv_languagecode TYPE spras.
        TRY.
            lv_languagecode = cl_abap_context_info=>get_user_language_abap_format(  ).
            SELECT SINGLE UnitOfMeasure_E
            FROM I_UnitOfMeasureText
            WHERE UnitOfMeasure = @lv_baseunit
              AND Language = @lv_languagecode
            INTO @DATA(lv_unit_output).
        CATCH cx_abap_context_info_error.
            "handle exception
        ENDTRY.

    SELECT SINGLE * FROM I_CustomerReturnDelivery WHERE CustomerReturnDelivery = @is_parameter-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
    INTO @DATA(ls_return_delivery).

    IF sy-subrc <> 0.
        READ ENTITIES OF I_OutboundDeliveryTP
        ENTITY OutboundDeliveryItem
        FIELDS ( PickQuantityInOrderUnit ) WITH VALUE #( ( %tky-OutboundDelivery = is_parameter-OutboundDelivery
                                                           %tky-OutboundDeliveryItem = is_parameter-OutboundDeliveryItem ) )
        RESULT FINAL(LT_PICKEDQTY).

        IF lines( LT_PICKEDQTY ) > 0.
            DATA(lv_pickedqty) = LT_PICKEDQTY[ 1 ]-PickQuantityInOrderUnit.
            lv_pickedqty = lv_pickedqty - 1.
            IF lv_pickedqty < 0.
                RETURN.
            ENDIF.

            TRY.
                DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

                DATA(lo_request) = lo_http_client->get_http_request( ).

                lo_http_client->enable_path_prefix( ).

                lo_request->set_uri_path( EXPORTING i_uri_path = '/API_OUTBOUND_DELIVERY_SRV;v=0002/SetPickingQuantityWithBaseQuantity' ).
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
                lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

                lo_http_client->set_csrf_token(  ).

                lo_request->set_form_field( i_name = 'DeliveryDocument' i_value =  |'{ CONV string( is_parameter-OutboundDelivery ) }'| ).
                lo_request->set_form_field( i_name = 'DeliveryDocumentItem' i_value =  |'{ CONV string( is_parameter-OutboundDeliveryItem ) }'| ).
                lo_request->set_form_field( i_name = 'ActualDeliveredQtyInBaseUnit' i_value =  |{ CONV i( lv_pickedqty ) }M| ).
                lo_request->set_form_field( i_name = 'BaseUnit' i_value =  |'{ CONV string( lv_unit_output ) }'| ).

                DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
                DATA(lv_response) = lo_response->get_text(  ).

                DATA(status) = lo_response->get_status( ).
                IF status-code NE 200.
                    rv_result = abap_false.
                ELSE.
                    rv_result = abap_true.
                ENDIF.

            CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
                rv_result = abap_false.
            ENDTRY.
        ENDIF.
    ELSE.
        READ ENTITIES OF I_CUSTOMERRETURNSDELIVERYTP
        ENTITY CustomerReturnsDeliveryItem
        FIELDS ( PickQuantityInOrderUnit ) WITH VALUE #( ( %tky-CustomerReturnDelivery = is_parameter-OutboundDelivery
                                                           %tky-CustomerReturnDeliveryItem = is_parameter-OutboundDeliveryItem ) )
        RESULT FINAL(lt_return_pickedqty).

        IF lines( lt_return_pickedqty ) > 0.
            DATA(lv_return_pickedqty) = lt_return_pickedqty[ 1 ]-PickQuantityInOrderUnit.
            lv_return_pickedqty = lv_return_pickedqty - 1.
            IF lv_return_pickedqty < 0.
                RETURN.
            ENDIF.
            TRY.
                lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

                lo_request = lo_http_client->get_http_request( ).

                lo_http_client->enable_path_prefix( ).

                lo_request->set_uri_path( EXPORTING i_uri_path = '/API_CUSTOMER_RETURNS_DELIVERY_SRV;v=0002/SetPutawayQuantityWithBaseQuantity').
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
                lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

                lo_http_client->set_csrf_token(  ).

                lo_request->set_form_field( i_name = 'DeliveryDocument' i_value =  |'{ CONV string( is_parameter-OutboundDelivery ) }'| ).
                lo_request->set_form_field( i_name = 'DeliveryDocumentItem' i_value =  |'{ CONV string( is_parameter-OutboundDeliveryItem ) }'| ).
                lo_request->set_form_field( i_name = 'ActualDeliveredQtyInBaseUnit' i_value =  |{ CONV i( lv_return_pickedqty ) }M| ).
                lo_request->set_form_field( i_name = 'BaseUnit' i_value =  |'{ CONV string( lv_unit_output ) }'| ).

                lo_response = lo_http_client->execute( if_web_http_client=>post ).
                lv_response = lo_response->get_text(  ).

                status = lo_response->get_status( ).
                IF status-code NE 200.
                    rv_result = abap_false.
                ELSE.
                    rv_result = abap_true.
                ENDIF.
            CATCH cx_web_http_client_error INTO lX_WEB_HTTP_CLIENT_ERROR.

            ENDTRY.
        ENDIF.
    ENDIF.


  ENDMETHOD.

  METHOD checkSerialNumberInStock.
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
    DATA: lv_plant TYPE werks_d,
          lv_storage TYPE zzesd003.

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

    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

        DATA(lo_request) = lo_http_client->get_http_request(   ).

        lo_http_client->enable_path_prefix( ).

        DATA(lv_uri_path) = |/API_MATERIAL_STOCK_SRV/A_MaterialSerialNumber(Material='{ is_parameter-Product }',SerialNumber='{ is_parameter-SerialNumber }')|.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
        lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

        lo_http_client->set_csrf_token(  ).

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).

        DATA(lv_response) = lo_response->get_text(  ).
        DATA(status) = lo_response->get_status( ).
    CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
        RETURN.
    ENDTRY.

    IF status-code = 200.
        DATA lo_result TYPE REF TO data.
        /ui2/cl_json=>deserialize(
            EXPORTING
                json = lv_response
            CHANGING
                data = lo_result
         ).
         ASSIGN COMPONENT 'd' OF STRUCTURE lo_result->* TO FIELD-SYMBOL(<fo_result>).
         IF sy-subrc = 0.
            ASSIGN COMPONENT 'Plant' OF STRUCTURE <fo_result>->* TO FIELD-SYMBOL(<fs_plant>).
            IF sy-subrc = 0.
                lv_plant = <fs_plant>->*.
            ENDIF.
            ASSIGN COMPONENT 'StorageLocation' OF STRUCTURE <fo_result>->* TO FIELD-SYMBOL(<fs_storage>).
            IF sy-subrc = 0.
                lv_storage = <fs_storage>->*.
            ENDIF.
         ENDIF.

         SELECT SINGLE * FROM zr_ssd021 WHERE OutboundDelivery = @is_parameter-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
                                          AND OutboundDeliveryItem = @is_parameter-OutboundDeliveryItem
                                          AND Plant = @lv_plant
                                          AND StorageLocation = @lv_storage
         INTO @DATA(ls_item).
         IF sy-subrc = 0.
            rv_result = abap_true.
         ELSE.
            rv_result = abap_false.
         ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD minusPickedQuantity_action.
      DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
        DATA: lo_client_proxy      TYPE REF TO /iwbep/if_cp_client_proxy.

        ASSERT lines( keys ) > 0.
        READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
        IF sy-subrc <> 0.
          RETURN.
        ENDIF.

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
*                  out->write( lx_http_dest_provider_error->get_text( ) ).
            EXIT.
        ENDTRY.

        SELECT SINGLE BaseUnit FROM ZR_SSD021 WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
                                                            AND OutboundDeliveryItem = @<key>-%param-OutboundDeliveryItem
        INTO @DATA(lv_baseunit).

        DATA lv_languagecode TYPE spras.
        TRY.
            lv_languagecode = cl_abap_context_info=>get_user_language_abap_format(  ).
            SELECT SINGLE UnitOfMeasure_E
            FROM I_UnitOfMeasureText
            WHERE UnitOfMeasure = @lv_baseunit
              AND Language = @lv_languagecode
            INTO @DATA(lv_unit_output).
        CATCH cx_abap_context_info_error.
            "handle exception
        ENDTRY.

    SELECT SINGLE * FROM I_CustomerReturnDelivery WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
    INTO @DATA(ls_return_delivery).

    IF sy-subrc <> 0.
        READ ENTITIES OF I_OutboundDeliveryTP
        ENTITY OutboundDeliveryItem
        FIELDS ( PickQuantityInOrderUnit ) WITH VALUE #( ( %tky-OutboundDelivery = <key>-%param-OutboundDelivery
                                                           %tky-OutboundDeliveryItem = <key>-%param-OutboundDeliveryItem ) )
        RESULT FINAL(LT_PICKEDQTY).

        IF lines( LT_PICKEDQTY ) > 0.
            DATA(lv_pickedqty) = LT_PICKEDQTY[ 1 ]-PickQuantityInOrderUnit.
            lv_pickedqty = lv_pickedqty - 1.
            IF lv_pickedqty < 0.
                RETURN.
            ENDIF.

            TRY.
                DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

                DATA(lo_request) = lo_http_client->get_http_request( ).

                lo_http_client->enable_path_prefix( ).

                lo_request->set_uri_path( EXPORTING i_uri_path = '/API_OUTBOUND_DELIVERY_SRV;v=0002/SetPickingQuantityWithBaseQuantity' ).
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
                lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

                lo_http_client->set_csrf_token(  ).

                lo_request->set_form_field( i_name = 'DeliveryDocument' i_value =  |'{ CONV string( <key>-%param-OutboundDelivery ) }'| ).
                lo_request->set_form_field( i_name = 'DeliveryDocumentItem' i_value =  |'{ CONV string( <key>-%param-OutboundDeliveryItem ) }'| ).
                lo_request->set_form_field( i_name = 'ActualDeliveredQtyInBaseUnit' i_value =  |{ CONV i( lv_pickedqty ) }M| ).
                lo_request->set_form_field( i_name = 'BaseUnit' i_value =  |'{ CONV string( lv_unit_output ) }'| ).

                DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
                DATA(lv_response) = lo_response->get_text(  ).

                DATA(status) = lo_response->get_status( ).
                IF status-code NE 200.
                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                ENDIF.

            CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
            ENDTRY.
        ENDIF.
    ELSE.
        READ ENTITIES OF I_CUSTOMERRETURNSDELIVERYTP
        ENTITY CustomerReturnsDeliveryItem
        FIELDS ( PickQuantityInOrderUnit ) WITH VALUE #( ( %tky-CustomerReturnDelivery = <key>-%param-OutboundDelivery
                                                           %tky-CustomerReturnDeliveryItem = <key>-%param-OutboundDeliveryItem ) )
        RESULT FINAL(lt_return_pickedqty).

        IF lines( lt_return_pickedqty ) > 0.
            DATA(lv_return_pickedqty) = lt_return_pickedqty[ 1 ]-PickQuantityInOrderUnit.
            lv_return_pickedqty = lv_return_pickedqty - 1.
            IF lv_return_pickedqty < 0.
                RETURN.
            ENDIF.

            TRY.
                lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

                lo_request = lo_http_client->get_http_request( ).

                lo_http_client->enable_path_prefix( ).

                lo_request->set_uri_path( EXPORTING i_uri_path = '/API_CUSTOMER_RETURNS_DELIVERY_SRV;v=0002/SetPutawayQuantityWithBaseQuantity').
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
                lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

                lo_http_client->set_csrf_token(  ).

                lo_request->set_form_field( i_name = 'DeliveryDocument' i_value =  |'{ CONV string( <key>-%param-OutboundDelivery ) }'| ).
                lo_request->set_form_field( i_name = 'DeliveryDocumentItem' i_value =  |'{ CONV string( <key>-%param-OutboundDeliveryItem ) }'| ).
                lo_request->set_form_field( i_name = 'ActualDeliveredQtyInBaseUnit' i_value =  |{ CONV i( lv_return_pickedqty ) }M| ).
                lo_request->set_form_field( i_name = 'BaseUnit' i_value =  |'{ CONV string( lv_unit_output ) }'| ).

                lo_response = lo_http_client->execute( if_web_http_client=>post ).
                lv_response = lo_response->get_text(  ).

                status = lo_response->get_status( ).
                IF status-code NE 200.
                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                ENDIF.
            CATCH cx_web_http_client_error INTO lX_WEB_HTTP_CLIENT_ERROR.
                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
            ENDTRY.
        ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD createScannedRecord.
    DATA: lt_tsd013 TYPE TABLE FOR CREATE zr_tsd013,
          lv_serialnumber TYPE zzesd023,
          lv_oldserialnumber TYPE zzesd012.

    DATA ls_parameter TYPE zr_ssd007.

    ASSERT lines( keys ) > 0.
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc = 0.

        IF strlen( <key>-%param-SerialNumber ) = 18.
            lv_serialnumber = <key>-%param-SerialNumber.
        ELSE.
            SELECT SINGLE zserialnumber FROM zr_tmm001 WHERE Product = @<key>-%param-Product
                                                         AND Zoldserialnumber = @<key>-%param-SerialNumber
            INTO @lv_serialnumber.
            IF sy-subrc NE 0.
                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 004 severity = if_abap_behv_message=>severity-error ) ) ).
                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                RETURN.
            ENDIF.
            lv_oldserialnumber = <key>-%param-SerialNumber.
        ENDIF.

        ls_parameter = VALUE #( OutboundDelivery = <key>-%param-OutboundDelivery
                                OutboundDeliveryItem = <key>-%param-OutboundDeliveryItem
                                Product = <key>-%param-Product
                                SerialNumber = lv_serialnumber ).

        SELECT SINGLE * FROM zr_ssd021 WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
                                         AND OutboundDeliveryItem = @<key>-%param-OutboundDeliveryItem
        INTO @DATA(ls_outbounddeliveryitem).

        SELECT SINGLE * FROM I_CustomerReturnDelivery WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
        INTO @DATA(ls_return_delivery).
        "Not Return
        IF sy-subrc <> 0.
            SELECT SINGLE StorageLocation FROM zr_tsd014 WHERE StorageLocation = @ls_outbounddeliveryitem-StorageLocation
            INTO @DATA(lv_storagelocation).

            IF sy-subrc = 0.
            " Picking Type 2: Damage Sales
                SELECT SINGLE SerialNumber FROM I_SerialNumberDeliveryDocument
                WHERE DeliveryDocument = @<key>-%param-OutboundDelivery
                  AND DeliveryDocumentItem = @<key>-%param-OutboundDeliveryItem
                INTO @DATA(lv_is_sn_on_dn).
                " 用户有在DN里手动输入序列号
                IF sy-subrc = 0.
                    SELECT SINGLE SerialNumber FROM I_SerialNumberDeliveryDocument
                    WHERE DeliveryDocument = @<key>-%param-OutboundDelivery
                        AND DeliveryDocumentItem = @<key>-%param-OutboundDeliveryItem
                        AND Material = @<key>-%param-Product
                        AND SerialNumber = @lv_serialnumber
                    INTO @DATA(lv_sn_on_dn).
                    " 用户有在DN里手动输入序列号，但扫描的序列号跟DN上的不一致
                    IF sy-subrc <> 0.
                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 017 severity = if_abap_behv_message=>severity-error ) ) ).
                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                        RETURN.
                    ELSE.

                        " 扫描的序列号与DN上的一致，但是没有库存
                        IF checkSerialNumberInStock( ls_parameter ) <> abap_true.
                            reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 003 severity = if_abap_behv_message=>severity-error ) ) ).
                            failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                            RETURN.
                        " 扫描的序列号与DN上的一致，有库存，但已经扫描过
                        ELSE.
                            SELECT SINGLE SerialNumber FROM ZR_TSD013
                            WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
                              AND DeliveryItem = @<key>-%param-OutboundDeliveryItem
                              AND SerialNumber = @lv_serialnumber
                            INTO @DATA(lv_has_scanned).
                            " 已经扫描过
                            IF sy-subrc = 0.
                                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 006 severity = if_abap_behv_message=>severity-error ) ) ).
                                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                                RETURN.
                            " 还没有扫描过
                            ELSE.
                                IF addPickedQuantity( ls_parameter ) <> abap_true.
                                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                                    RETURN.
*                                ELSE.
*                                    IF createSerialNumber( ls_parameter ) <> abap_true.
*                                        minusPickedQuantity( ls_parameter ).
*                                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
*                                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
*                                        RETURN.
*                                    ENDIF.
                                ENDIF.
                            ENDIF.
                        ENDIF.
                    ENDIF.
                ELSE.
                    " 用户没有在DN里手动输入序列号
                    " 判断用户是否有在SO里手动输入序列号
                    SELECT SINGLE * FROM I_SDDocumentMultiLevelProcFlow as _SDDocumentProcessFlow "#EC CI_ALL_FIELDS_NEEDED
                    INNER JOIN I_SerialNumberSalesOrder as _SerialNumberSalesOrder
                            ON _SDDocumentProcessFlow~PrecedingDocument = _SerialNumberSalesOrder~SalesOrder
                           AND _SDDocumentProcessFlow~PrecedingDocumentItem = _SerialNumberSalesOrder~SalesOrderItem
                    WHERE _SDDocumentProcessFlow~SubsequentDocument = @<key>-%param-OutboundDelivery
                      AND _SDDocumentProcessFlow~SubsequentDocumentItem = @<key>-%param-OutboundDeliveryItem
                      AND _SerialNumberSalesOrder~Material = @<key>-%param-Product
                      AND _SerialNumberSalesOrder~SerialNumber = @lv_serialnumber
                    INTO @DATA(ls_sn_on_so).

                    " 扫描的序列号跟SO上填写的不一致
                    IF sy-subrc <> 0.
                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 017 severity = if_abap_behv_message=>severity-error ) ) ).
                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                        RETURN.
                    " 扫描的序列号跟SO上填写的一致
                    ELSE.
                        " 没有库存
                        IF checkSerialNumberInStock( ls_parameter ) <> abap_true.
                            reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 003 severity = if_abap_behv_message=>severity-error ) ) ).
                            failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                            RETURN.
                        " 扫描的序列号与SO上的一致，有库存
                        ELSE.
                            SELECT SINGLE SerialNumber FROM ZR_TSD013
                            WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
                              AND DeliveryItem = @<key>-%param-OutboundDeliveryItem
                              AND SerialNumber = @lv_serialnumber
                            INTO @lv_has_scanned.
                            " 已经扫描过
                            IF sy-subrc = 0.
                                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 006 severity = if_abap_behv_message=>severity-error ) ) ).
                                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                                RETURN.
                            ELSE.
                            " 没有扫描过
                                IF addPickedQuantity( ls_parameter ) <> abap_true.
                                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                                    RETURN.
*                                ELSE.
*                                    IF createSerialNumber( ls_parameter ) <> abap_true.
*                                        minusPickedQuantity( ls_parameter ).
*                                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
*                                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
*                                        RETURN.
*                                    ENDIF.
                                ENDIF.
                            ENDIF.
                        ENDIF.
                    ENDIF.
                ENDIF.

            " Picking Type 1: Normal Order
            ELSE.
                IF checkSerialNumberInStock( ls_parameter ) <> abap_true.
                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 003 severity = if_abap_behv_message=>severity-error ) ) ).
                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                    RETURN.
                ENDIF.

                " Check serial number has been picked
                SELECT SINGLE SerialNumber FROM I_SerialNumberDeliveryDocument WHERE DeliveryDocument = @<key>-%param-OutboundDelivery
                                                                          AND DeliveryDocumentItem = @<key>-%param-OutboundDeliveryItem
                                                                          AND SerialNumber = @lv_serialnumber
                INTO @DATA(lv_picked_sn).
                IF sy-subrc EQ 0.
                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 006 severity = if_abap_behv_message=>severity-error ) ) ).
                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                    RETURN.
                ENDIF.

                IF addPickedQuantity( ls_parameter ) = abap_true.
                    CASE createSerialNumber( ls_parameter ).
                    WHEN abap_false.
                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 009 severity = if_abap_behv_message=>severity-error ) ) ).
                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                        RETURN.
                    WHEN 'B'.
                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 024 severity = if_abap_behv_message=>severity-error ) ) ).
                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                        RETURN.
                    ENDCASE.

*                    IF createSerialNumber( ls_parameter ) <> abap_true.
**                        minusPickedQuantity( ls_parameter ).
*                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 009 severity = if_abap_behv_message=>severity-error ) ) ).
*                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
*                        RETURN.
*                    ENDIF.
                ELSE.
                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                    RETURN.
                ENDIF.

            ENDIF.
        ELSE.
            " Picking Type 3: Return
            SELECT SINGLE SerialNumber FROM I_SerialNumberDeliveryDocument
            WHERE DeliveryDocument = @<key>-%param-OutboundDelivery
              AND DeliveryDocumentItem = @<key>-%param-OutboundDeliveryItem
              AND Material = @<key>-%param-Product
              AND SerialNumber NOT IN ( SELECT DISTINCT SerialNumber FROM ZR_TSD013
                WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
                  AND DeliveryItem = @<key>-%param-OutboundDeliveryItem
                  AND Material = @<key>-%param-Product )
            INTO @DATA(lv_has_serial).
            " 用户没有事先填写序列号
            IF sy-subrc <> 0.
                SELECT SINGLE SerialNumber
                FROM I_SerialNumberDeliveryDocument
                WHERE DeliveryDocument IN ( SELECT SubsequentDocument
                FROM I_SalesDocItmSubsqntProcFlow
                WHERE ( SalesDocument,SalesDocumentItem ) IN ( SELECT SalesDocument,
                    SalesDocumentItem
                FROM I_SalesDocItmSubsqntProcFlow AS _SalesDocItmSubsqntProcFlow
                WHERE ( SubsequentDocument,SubsequentDocumentItem ) IN ( SELECT _CustomerReturnItem~ReferenceSDDocument,
                    _CustomerReturnItem~ReferenceSDDocumentItem
                    FROM I_CustomerReturnItem AS _CustomerReturnItem
                    INNER JOIN I_CustomerReturnDeliveryItem AS _CustomerReturnDeliveryItem
                        ON _CustomerReturnDeliveryItem~ReferenceSDDocument = _CustomerReturnItem~CustomerReturn
                        AND _CustomerReturnDeliveryItem~ReferenceSDDocumentItem = _CustomerReturnItem~CustomerReturnItem
                    WHERE _CustomerReturnDeliveryItem~CustomerReturnDelivery = @<key>-%param-OutboundDelivery
                        AND _CustomerReturnDeliveryItem~CustomerReturnDeliveryItem = @<key>-%param-OutboundDeliveryItem )
                AND SDDocumentCategory = 'C' )
                AND SubsequentDocumentCategory = 'J' )
                AND Material = @<key>-%param-Product
                AND SerialNumber = @lv_serialnumber
                INTO @DATA(lv_preceding_serialnumbers).

                " 收到的退货（扫描的序列号）不是这张前序订单发的
                IF sy-subrc <> 0.
                    SELECT SINGLE BillingDocument
                    FROM ZR_TSD016
                    INNER JOIN I_CustomerReturn AS _CustomerReturn
                    ON _CustomerReturn~ReferenceSDDocument = ZR_TSD016~BillingDocument
                    INTO @DATA(lv_billing).
                    " 收到的退货（扫描的序列号）不是B1订单的退货
                    IF sy-subrc <> 0.
                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 018 severity = if_abap_behv_message=>severity-error ) ) ).
                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).

                        RETURN.
                    ELSE.
                    " 收到的退货（扫描的序列号）是B1订单的退货
                    " check whether this serial number exists in other customer return DN
                    " but not yet received or not required to receive
                        SELECT SINGLE
                            _CustomerReturnItemEnhanced~CustRetItmFollowUpActivity,
                            _CustomerReturnItem~CustomerReturn,
                            _CustomerReturnItem~CustomerReturnItem
                        FROM I_SerialNumberSalesOrder AS _SerialNumberSalesOrder
                        INNER JOIN I_CustomerReturnItem AS _CustomerReturnItem
                            ON  _CustomerReturnItem~CustomerReturn = _SerialNumberSalesOrder~SalesOrder
                            AND _CustomerReturnItem~CustomerReturnItem = _SerialNumberSalesOrder~SalesOrderItem
                        INNER JOIN I_CustomerReturnItemEnhanced AS _CustomerReturnItemEnhanced
                            ON  _CustomerReturnItemEnhanced~CustomerReturn = _CustomerReturnItem~CustomerReturn
                            AND _CustomerReturnItemEnhanced~CustomerReturnItem = _CustomerReturnItem~CustomerReturnItem
                        WHERE   _SerialNumberSalesOrder~Material = @<key>-%param-Product
                            AND _SerialNumberSalesOrder~SerialNumber = @lv_serialnumber
                            AND _CustomerReturnItem~SDDocumentRejectionStatus <> 'C'
                            AND _CustomerReturnItemEnhanced~CustRetItmFollowUpActivity = '0013'
                        INTO @DATA(ls_CustRetItmFollowUpActivity).

                        IF sy-subrc = 0.
                            reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 025 severity = if_abap_behv_message=>severity-error ) ) ).
                            failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                            RETURN.
                        ELSE.
                            SELECT SINGLE
                                _CustomerReturnDelivery~OverallGoodsMovementStatus
                            FROM I_SerialNumberDeliveryDocument AS _SerialNumberDeliveryDocument
                            INNER JOIN I_CustomerReturnDelivery AS _CustomerReturnDelivery
                                ON _SerialNumberDeliveryDocument~DeliveryDocument = _CustomerReturnDelivery~CustomerReturnDelivery
                            WHERE _SerialNumberDeliveryDocument~Material = @<key>-%param-Product
                                AND _SerialNumberDeliveryDocument~SerialNumber = @lv_serialnumber
                                AND _SerialNumberDeliveryDocument~DeliveryDocument <> @<key>-%param-OutboundDelivery
                                AND _SerialNumberDeliveryDocument~DeliveryDocumentItem <> @<key>-%param-OutboundDeliveryItem
                                AND _CustomerReturnDelivery~OverallGoodsMovementStatus <> 'C'
                                INTO @DATA(lv_movementstatus).

                            IF sy-subrc = 0.
                                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 025 severity = if_abap_behv_message=>severity-error ) ) ).
                                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                                RETURN.
                            ENDIF.
                        ENDIF.
                        " 收到的退货（扫描的序列号）是B1订单的退货，扫描的序列号是过往售卖的序列号
                        " 旧序列号不为空，说明能在ZTMM001中找到对应的转换
                        IF lv_oldserialnumber IS NOT INITIAL.
                            IF addPickedQuantity( ls_parameter ) = abap_true.
                                CASE createSerialNumber( ls_parameter ).
                                WHEN abap_false.
                                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 009 severity = if_abap_behv_message=>severity-error ) ) ).
                                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                                    RETURN.
                                WHEN 'B'.
                                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 024 severity = if_abap_behv_message=>severity-error ) ) ).
                                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                                    RETURN.
                                ENDCASE.
                            ELSE.
                                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                                RETURN.
                            ENDIF.
                        ELSE.
                            " 收到的退货（扫描的序列号）是B1订单的退货，扫描的序列号不是过往售卖的序列号
                            reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 018 severity = if_abap_behv_message=>severity-error ) ) ).
                            failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).

                            RETURN.
                        ENDIF.
                    ENDIF.

                ELSE.
                    " check whether this serial number exists in other customer return DN
                    " but not yet received or not required to receive
                    SELECT SINGLE
                        _CustomerReturnItemEnhanced~CustRetItmFollowUpActivity
                    FROM I_SerialNumberSalesOrder AS _SerialNumberSalesOrder
                    INNER JOIN I_CustomerReturnItem AS _CustomerReturnItem
                        ON  _CustomerReturnItem~CustomerReturn = _SerialNumberSalesOrder~SalesOrder
                        AND _CustomerReturnItem~CustomerReturnItem = _SerialNumberSalesOrder~SalesOrderItem
                    INNER JOIN I_CustomerReturnItemEnhanced AS _CustomerReturnItemEnhanced
                        ON  _CustomerReturnItemEnhanced~CustomerReturn = _CustomerReturnItem~CustomerReturn
                        AND _CustomerReturnItemEnhanced~CustomerReturnItem = _CustomerReturnItem~CustomerReturnItem
                    WHERE   _SerialNumberSalesOrder~Material = @<key>-%param-Product
                        AND _SerialNumberSalesOrder~SerialNumber = @lv_serialnumber
                        AND _CustomerReturnItem~SDDocumentRejectionStatus <> 'C'
                        AND _CustomerReturnItemEnhanced~CustRetItmFollowUpActivity = '0013'
                    INTO @DATA(lv_CustRetItmFollowUpActivity).

                    IF sy-subrc = 0.
                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 025 severity = if_abap_behv_message=>severity-error ) ) ).
                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                        RETURN.
                    ELSE.
                        SELECT SINGLE
                            _CustomerReturnDelivery~OverallGoodsMovementStatus
                        FROM I_SerialNumberDeliveryDocument AS _SerialNumberDeliveryDocument
                        INNER JOIN I_CustomerReturnDelivery AS _CustomerReturnDelivery
                            ON _SerialNumberDeliveryDocument~DeliveryDocument = _CustomerReturnDelivery~CustomerReturnDelivery
                        WHERE _SerialNumberDeliveryDocument~Material = @<key>-%param-Product
                          AND _SerialNumberDeliveryDocument~SerialNumber = @lv_serialnumber
                          AND _SerialNumberDeliveryDocument~DeliveryDocument <> @<key>-%param-OutboundDelivery
                          AND _SerialNumberDeliveryDocument~DeliveryDocumentItem <> @<key>-%param-OutboundDeliveryItem
                          AND _CustomerReturnDelivery~OverallGoodsMovementStatus <> 'C'
                        INTO @lv_movementstatus.

                        IF sy-subrc = 0.
                            reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 025 severity = if_abap_behv_message=>severity-error ) ) ).
                            failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                            RETURN.
                        ENDIF.
                    ENDIF.

                " 收到的退货（扫描的序列号）是这张前序订单发的，但退货仓里无库存（确实需要收货）
                    IF checkSerialNumberInStock( ls_parameter ) <> abap_true.
                        SELECT SINGLE SerialNumber FROM ZR_TSD013
                        WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
                          AND DeliveryItem = @<key>-%param-OutboundDeliveryItem
                          AND SerialNumber = @lv_serialnumber
                        INTO @lv_has_scanned.
                        " 序列号是前序订单的且不在库存，但有扫描过
                        IF sy-subrc = 0.
                            reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 006 severity = if_abap_behv_message=>severity-error ) ) ).
                            failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).

                            RETURN.
                        ELSE.
                        " 没有扫描过
                            IF addPickedQuantity( ls_parameter ) = abap_true.
                                CASE createSerialNumber( ls_parameter ).
                                WHEN abap_false.
                                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 009 severity = if_abap_behv_message=>severity-error ) ) ).
                                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                                    RETURN.
                                WHEN 'B'.
                                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 024 severity = if_abap_behv_message=>severity-error ) ) ).
                                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                                    RETURN.
                                ENDCASE.
                            ELSE.
                                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                                RETURN.
                            ENDIF.
                        ENDIF.
                    ELSE.
                    " 有库存（不需要收货）
                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 019 severity = if_abap_behv_message=>severity-error ) ) ).
                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                        RETURN.
                    ENDIF.
                ENDIF.
            ELSE.
                " 用户事先填写了序列号
                " check whether this serial number exists in other customer return DN
                    " but not yet received or not required to receive
                SELECT SINGLE
                    _CustomerReturnItemEnhanced~CustRetItmFollowUpActivity,
                    _CustomerReturnItem~CustomerReturn,
                    _CustomerReturnItem~CustomerReturnItem
                FROM I_SerialNumberSalesOrder AS _SerialNumberSalesOrder
                INNER JOIN I_CustomerReturnItem AS _CustomerReturnItem
                    ON  _CustomerReturnItem~CustomerReturn = _SerialNumberSalesOrder~SalesOrder
                    AND _CustomerReturnItem~CustomerReturnItem = _SerialNumberSalesOrder~SalesOrderItem
                INNER JOIN I_CustomerReturnItemEnhanced AS _CustomerReturnItemEnhanced
                    ON  _CustomerReturnItemEnhanced~CustomerReturn = _CustomerReturnItem~CustomerReturn
                    AND _CustomerReturnItemEnhanced~CustomerReturnItem = _CustomerReturnItem~CustomerReturnItem
                WHERE   _SerialNumberSalesOrder~Material = @<key>-%param-Product
                    AND _SerialNumberSalesOrder~SerialNumber = @lv_serialnumber
                    AND _CustomerReturnItem~SDDocumentRejectionStatus <> 'C'
                    AND _CustomerReturnItemEnhanced~CustRetItmFollowUpActivity = '0013'
                INTO @ls_CustRetItmFollowUpActivity.

                IF sy-subrc = 0.
                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 025 severity = if_abap_behv_message=>severity-error ) ) ).
                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                    RETURN.
                ELSE.
                    SELECT SINGLE
                        _CustomerReturnDelivery~OverallGoodsMovementStatus
                    FROM I_SerialNumberDeliveryDocument AS _SerialNumberDeliveryDocument
                    INNER JOIN I_CustomerReturnDelivery AS _CustomerReturnDelivery
                        ON _SerialNumberDeliveryDocument~DeliveryDocument = _CustomerReturnDelivery~CustomerReturnDelivery
                    WHERE _SerialNumberDeliveryDocument~Material = @<key>-%param-Product
                        AND _SerialNumberDeliveryDocument~SerialNumber = @lv_serialnumber
                        AND _SerialNumberDeliveryDocument~DeliveryDocument <> @<key>-%param-OutboundDelivery
                        AND _SerialNumberDeliveryDocument~DeliveryDocumentItem <> @<key>-%param-OutboundDeliveryItem
                        AND _CustomerReturnDelivery~OverallGoodsMovementStatus <> 'C'
                        INTO @lv_movementstatus.

                    IF sy-subrc = 0.
                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 025 severity = if_abap_behv_message=>severity-error ) ) ).
                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                        RETURN.
                    ENDIF.
                ENDIF.

                SELECT SINGLE SerialNumber FROM I_SerialNumberDeliveryDocument
                WHERE DeliveryDocument = @<key>-%param-OutboundDelivery
                  AND DeliveryDocumentItem = @<key>-%param-OutboundDeliveryItem
                  AND Material = @<key>-%param-Product
                  AND SerialNumber = @lv_serialnumber
                INTO @DATA(lv_return_sn).

                IF sy-subrc <> 0.
                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 017 severity = if_abap_behv_message=>severity-error ) ) ).
                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                    RETURN.
                ELSE.
                    " 扫描的序列号与DN上的一致，但是没有库存（确实需要收货）
                    IF checkSerialNumberInStock( ls_parameter ) <> abap_true.
                        SELECT SINGLE SerialNumber FROM ZR_TSD013
                        WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
                        AND DeliveryItem = @<key>-%param-OutboundDeliveryItem
                        AND SerialNumber = @lv_serialnumber
                        INTO @lv_has_scanned.
                        " 已经扫描过
                        IF sy-subrc = 0.
                            reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 006 severity = if_abap_behv_message=>severity-error ) ) ).
                            failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                            RETURN.
                        " 还没有扫描过
                        ELSE.
                            IF addPickedQuantity( ls_parameter ) <> abap_true.
                                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                                RETURN.
                            ENDIF.
                        ENDIF.
                    " 扫描的序列号与DN上的一致，但是有库存（不需要收货）
                    ELSE.
                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 019 severity = if_abap_behv_message=>severity-error ) ) ).
                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                        RETURN.
                    ENDIF.
                ENDIF.
            ENDIF.

        ENDIF.

        SELECT SINGLE PersonFullName FROM I_BusinessUserBasic
        WHERE UserID = @sy-uname
        INTO @DATA(lv_personfullname).

        TRY.
        lt_tsd013 = VALUE #( ( %cid = <key>-%cid
                               DeliveryNumber = ls_outbounddeliveryitem-OutboundDelivery
                               DeliveryItem = ls_outbounddeliveryitem-OutboundDeliveryItem
                               Plant = ls_outbounddeliveryitem-Plant
                               StorageLocation = ls_outbounddeliveryitem-StorageLocation
                               Material = ls_outbounddeliveryitem-Material
                               SerialNumber = lv_serialnumber
                               ScannedDate = cl_abap_context_info=>get_system_date( )
                               ScannedTime = cl_abap_context_info=>get_system_time( )
                               ScannedUserID = sy-uname
                               ScannedUserName = lv_personfullname
                               SalesOrder = ls_outbounddeliveryitem-SalesOrder ) ).
        CATCH CX_ABAP_CONTEXT_INFO_ERROR.
            reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Error when modify table') ) ).
            failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
            RETURN.
        ENDTRY.

        MODIFY ENTITIES OF zr_tsd013 IN LOCAL MODE
        ENTITY zr_tsd013
        CREATE FIELDS ( DeliveryNumber DeliveryItem Plant StorageLocation Material SerialNumber ScannedDate ScannedTime ScannedUserID ScannedUserName SalesOrder )
        WITH lt_tsd013
        MAPPED mapped
        REPORTED reported
        FAILED failed.

    ENDIF.

  ENDMETHOD.

  METHOD deleteScannedRecord.
      DATA: lv_serialnumber TYPE zzesd023.

      DATA ls_parameter TYPE zr_ssd007.

      ASSERT lines( keys ) > 0.

      READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
      IF sy-subrc = 0.
        IF strlen( <key>-%param-SerialNumber ) = 18.
            lv_serialnumber = <key>-%param-SerialNumber.
        ELSE.
            SELECT SINGLE zserialnumber FROM zr_tmm001 WHERE Product = @<key>-%param-Product
                                                         AND Zoldserialnumber = @<key>-%param-SerialNumber
            INTO @lv_serialnumber.
        ENDIF.

        ls_parameter = VALUE #( OutboundDelivery = <key>-%param-OutboundDelivery
                                OutboundDeliveryItem = <key>-%param-OutboundDeliveryItem
                                Product = <key>-%param-Product
                                SerialNumber = lv_serialnumber ).

        SELECT SINGLE StorageLocation FROM zr_ssd021 WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
                                         AND OutboundDeliveryItem = @<key>-%param-OutboundDeliveryItem
        INTO @DATA(lv_storage).

        SELECT SINGLE * FROM I_CustomerReturnDelivery WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
        INTO @DATA(ls_return_delivery).

        " Not Return
        IF sy-subrc <> 0.
            SELECT SINGLE StorageLocation FROM zr_tsd014 WHERE StorageLocation = @lv_storage
            INTO @DATA(lv_storagelocation).

            IF sy-subrc = 0.
            " Picking Type 2: Damage Sales
*                SELECT SINGLE SerialNumber FROM ZR_TSD013
*                            WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
*                              AND DeliveryItem = @<key>-%param-OutboundDeliveryItem
*                              AND SerialNumber = @lv_serialnumber
*                INTO @DATA(lv_has_scanned).
*                IF sy-subrc = 0.
                    IF minusPickedQuantity( ls_parameter ) = abap_true.
*                        IF deleteSerialNumber( ls_parameter ) <> abap_true.
*                            reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Error when deleting serial number' ) ) ).
*                            failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
*                            RETURN.
*                        ENDIF.
*                    ELSE.
                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 023 severity = if_abap_behv_message=>severity-error ) ) ).
                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                        RETURN.
                    ENDIF.
*                ELSE.
*                    IF deleteSerialNumber( ls_parameter ) <> abap_true.
*                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Error when deleting serial number' ) ) ).
*                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
*                        RETURN.
*                    ENDIF.
*                ENDIF.
            ELSE.
            " Picking Type 1: Normal Order
                IF minusPickedQuantity( ls_parameter ) = abap_true.
                        IF deleteSerialNumber( ls_parameter ) <> abap_true.
                            reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 023 severity = if_abap_behv_message=>severity-error ) ) ).
                            failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                            RETURN.
                        ENDIF.
                ELSE.
                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 023 severity = if_abap_behv_message=>severity-error ) ) ).
                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                    RETURN.
                ENDIF.
            ENDIF.
        ELSE.
            " Picking Type 3: Return
*            SELECT SINGLE SerialNumber FROM ZR_TSD013
*                            WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
*                              AND DeliveryItem = @<key>-%param-OutboundDeliveryItem
*                              AND SerialNumber = @lv_serialnumber
*                INTO @DATA(lv_has_scanned).
*                IF sy-subrc = 0.
                    IF minusPickedQuantity( ls_parameter ) = abap_true.
                        IF deleteSerialNumber( ls_parameter ) <> abap_true.
                            reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 023 severity = if_abap_behv_message=>severity-error ) ) ).
                            failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                            RETURN.
                        ENDIF.
                    ELSE.
                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 023 severity = if_abap_behv_message=>severity-error ) ) ).
                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                        RETURN.
                    ENDIF.
*                ELSE.
*                    IF deleteSerialNumber( ls_parameter ) <> abap_true.
*                        reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Error when deleting serial number' ) ) ).
*                        failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
*                        RETURN.
*                    ENDIF.
*                ENDIF.
        ENDIF.

        SELECT DeliveryNumber,
               DeliveryItem,
               Plant,
               StorageLocation,
               Material,
               SerialNumber,
               ScannedDate,
               ScannedTime,
               ScannedUserID,
               ScannedUserName
        FROM zr_tsd013
        WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
          AND DeliveryItem = @<key>-%param-OutboundDeliveryItem
          AND Material = @<key>-%param-Product
          AND SerialNumber = @<key>-%param-SerialNumber
        INTO TABLE @DATA(lt_tsd013).

        MODIFY ENTITIES OF zr_tsd013 IN LOCAL MODE
        ENTITY zr_tsd013 DELETE FROM VALUE #( FOR ls_tsd013 IN lt_tsd013 (
                                              %tky-DeliveryNumber = ls_tsd013-DeliveryNumber
                                              %tky-DeliveryItem = ls_tsd013-DeliveryItem
                                              %tky-Plant = ls_tsd013-Plant
                                              %tky-StorageLocation = ls_tsd013-StorageLocation
                                              %tky-Material = ls_tsd013-Material
                                              %tky-SerialNumber = ls_tsd013-SerialNumber
                                              %tky-ScannedDate = ls_tsd013-ScannedDate
                                              %tky-ScannedTime = ls_tsd013-ScannedTime
                                              %tky-ScannedUserID = ls_tsd013-ScannedUserID
                                              %tky-ScannedUserName = ls_tsd013-ScannedUserName ) )
        MAPPED mapped
        REPORTED reported
        FAILED failed.
      ENDIF.

  ENDMETHOD.

  METHOD createNoSerialNumber.

    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
    DATA: lo_client_proxy      TYPE REF TO /iwbep/if_cp_client_proxy.

    ASSERT lines( keys ) > 0.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc <> 0.
        RETURN.
    ENDIF.

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

    SELECT SINGLE BaseUnit FROM ZR_SSD021 WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
                                                            AND OutboundDeliveryItem = @<key>-%param-OutboundDeliveryItem
    INTO @DATA(lv_baseunit).

    DATA lv_languagecode TYPE spras.
    TRY.
        lv_languagecode = cl_abap_context_info=>get_user_language_abap_format(  ).
        SELECT SINGLE UnitOfMeasure_E
        FROM I_UnitOfMeasureText
        WHERE UnitOfMeasure = @lv_baseunit
            AND Language = @lv_languagecode
        INTO @DATA(lv_unit_output).
    CATCH cx_abap_context_info_error.
            "handle exception
    ENDTRY.

    SELECT SINGLE TotalQty FROM ZR_SSD021 WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
                                            AND OutboundDeliveryItem = @<key>-%param-OutboundDeliveryItem
    INTO @DATA(lv_totalqty).

    SELECT SINGLE * FROM I_CustomerReturnDelivery WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery "#EC CI_ALL_FIELDS_NEEDED
    INTO @DATA(ls_return_delivery).

    IF sy-subrc <> 0.
        READ ENTITIES OF I_OutboundDeliveryTP
        ENTITY OutboundDeliveryItem
        FIELDS ( PickQuantityInOrderUnit ) WITH VALUE #( ( %tky-OutboundDelivery = <key>-%param-OutboundDelivery
                                                           %tky-OutboundDeliveryItem = <key>-%param-OutboundDeliveryItem ) )
        RESULT FINAL(LT_PICKEDQTY).

        IF lines( LT_PICKEDQTY ) > 0.
            DATA(lv_pickedqty) = LT_PICKEDQTY[ 1 ]-PickQuantityInOrderUnit.
            IF lv_totalqty - lv_pickedqty < <key>-%param-ScannedQuantity.
                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid
                                %msg = new_message( id = 'ZZSD' number = 016 severity = if_abap_behv_message=>severity-error  )
                                ) ).
                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid ) ).
                RETURN.
            ENDIF.

            TRY.
                DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

                DATA(lo_request) = lo_http_client->get_http_request( ).

                lo_http_client->enable_path_prefix( ).

                lo_request->set_uri_path( EXPORTING i_uri_path = '/API_OUTBOUND_DELIVERY_SRV;v=0002/SetPickingQuantityWithBaseQuantity' ).
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
                lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

                lo_http_client->set_csrf_token(  ).

                lo_request->set_form_field( i_name = 'DeliveryDocument' i_value =  |'{ CONV string( <key>-%param-OutboundDelivery ) }'| ).
                lo_request->set_form_field( i_name = 'DeliveryDocumentItem' i_value =  |'{ CONV string( <key>-%param-OutboundDeliveryItem ) }'| ).
                lo_request->set_form_field( i_name = 'ActualDeliveredQtyInBaseUnit' i_value =  |{ CONV i( <key>-%param-ScannedQuantity ) }M| ).
                lo_request->set_form_field( i_name = 'BaseUnit' i_value =  |'{ CONV string( lv_unit_output ) }'| ).

                DATA(lo_response) = lo_http_client->execute( if_web_http_client=>post ).
                DATA(lv_response) = lo_response->get_text(  ).

                DATA(status) = lo_response->get_status( ).
                IF status-code NE 200.
                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                ENDIF.

            CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
            ENDTRY.
        ENDIF.
    ELSE.
        READ ENTITIES OF I_CUSTOMERRETURNSDELIVERYTP
        ENTITY CustomerReturnsDeliveryItem
        FIELDS ( PickQuantityInOrderUnit ) WITH VALUE #( ( %tky-CustomerReturnDelivery = <key>-%param-OutboundDelivery
                                                           %tky-CustomerReturnDeliveryItem = <key>-%param-OutboundDeliveryItem ) )
        RESULT FINAL(lt_return_pickedqty).

        IF lines( lt_return_pickedqty ) > 0.
            DATA(lv_return_pickedqty) = lt_return_pickedqty[ 1 ]-PickQuantityInOrderUnit.
            IF lv_totalqty - lv_return_pickedqty < <key>-%param-ScannedQuantity.
                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid
                                %msg = new_message( id = 'ZZSD' number = 016 severity = if_abap_behv_message=>severity-error  )
                                ) ).
                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid ) ).
                RETURN.
            ENDIF.

            TRY.
                lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

                lo_request = lo_http_client->get_http_request( ).

                lo_http_client->enable_path_prefix( ).

                lo_request->set_uri_path( EXPORTING i_uri_path = '/API_CUSTOMER_RETURNS_DELIVERY_SRV;v=0002/SetPutawayQuantityWithBaseQuantity').
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
                lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

                lo_http_client->set_csrf_token(  ).

                lo_request->set_form_field( i_name = 'DeliveryDocument' i_value =  |'{ CONV string( <key>-%param-OutboundDelivery ) }'| ).
                lo_request->set_form_field( i_name = 'DeliveryDocumentItem' i_value =  |'{ CONV string( <key>-%param-OutboundDeliveryItem ) }'| ).
                lo_request->set_form_field( i_name = 'ActualDeliveredQtyInBaseUnit' i_value =  |{ CONV i( <key>-%param-ScannedQuantity ) }M| ).
                lo_request->set_form_field( i_name = 'BaseUnit' i_value =  |'{ CONV string( lv_unit_output ) }'| ).

                lo_response = lo_http_client->execute( if_web_http_client=>post ).
                lv_response = lo_response->get_text(  ).

                status = lo_response->get_status( ).
                IF status-code NE 200.
                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                ENDIF.
            CATCH cx_web_http_client_error INTO lX_WEB_HTTP_CLIENT_ERROR.
                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message( id = 'ZZSD' number = 008 severity = if_abap_behv_message=>severity-error ) ) ).
                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
            ENDTRY.
        ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD deletePGIRecord.
    ASSERT lines( keys ) > 0.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc <> 0.
        RETURN.
    ENDIF.

    SELECT SINGLE IsFullyScanned
    FROM ZR_SSD021
    WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
      AND OutboundDeliveryItem = @<key>-%param-OutboundDeliveryItem
    INTO @DATA(lv_isfullyscanned).

    IF lv_isfullyscanned = abap_false.
        SELECT SINGLE SerialNumberProfile
        FROM ZR_SSD021
        WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
          AND OutboundDeliveryItem = @<key>-%param-OutboundDeliveryItem
        INTO @DATA(lv_serialnumberprofile).
        IF lv_serialnumberprofile IS NOT INITIAL.
            SELECT DeliveryNumber,
                DeliveryItem,
                Material,
                SerialNumber
            FROM ZR_TSD004
            WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
              AND DeliveryItem = @<key>-%param-OutboundDeliveryItem
              AND Material = @<key>-%param-Product
            INTO TABLE @DATA(lt_pgi_record).

            MODIFY ENTITIES OF ZI_TSD004
            ENTITY ZR_TSD004
            DELETE FROM VALUE #( FOR ls_pgi_record IN lt_pgi_record (
                                 %tky-DeliveryNumber = ls_pgi_record-DeliveryNumber
                                 %tky-DeliveryItem   = ls_pgi_record-DeliveryItem
                                 %tky-Material       = ls_pgi_record-Material
                                 %tky-SerialNumber   = ls_pgi_record-SerialNumber ) )
            MAPPED DATA(deleted_mapped)
            REPORTED DATA(deleted_reported)
            FAILED DATA(deleted_failed).

            IF lines( deleted_failed-zr_tsd004 ) > 0.
                reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Error When Deleting PGI Record' ) ) ).
                failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
            ENDIF.
        ELSE.
            SELECT SINGLE DeliveryNumber,
                DeliveryItem
            FROM ZR_TSD012
            WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
              AND DeliveryItem = @<key>-%param-OutboundDeliveryItem
              AND Material = @<key>-%param-Product
            INTO @DATA(ls_no_sn_record).

            IF sy-subrc = 0.
                MODIFY ENTITIES OF ZI_TSD012
                ENTITY ZR_TSD012
                DELETE FROM VALUE #( ( %tky-DeliveryNumber = <key>-%param-OutboundDelivery
                                       %tky-DeliveryItem   = <key>-%param-OutboundDeliveryItem ) )
                MAPPED DATA(demapped)
                REPORTED DATA(dereported)
                FAILED DATA(defailed).

                IF lines( defailed-zr_tsd012 ) > 0.
                    reported-zr_tsd013 = VALUE #( ( %cid = <key>-%cid %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Error When Deleting PGI Record(No SN.)' ) ) ).
                    failed-zr_tsd013 = VALUE #( ( %cid = <key>-%cid  ) ).
                ENDIF.
            ENDIF.
        ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD checkAllSNPicked.
    ASSERT lines( keys ) > 0.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc <> 0.
        RETURN.
    ENDIF.

    SELECT SINGLE TotalQty FROM ZR_SSD021 WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
                                            AND OutboundDeliveryItem = @<key>-%param-OutboundDeliveryItem
    INTO @DATA(lv_totalqty).

    SELECT SINGLE CustomerReturnDelivery, CustomerReturnDeliveryItem
    FROM I_CustomerReturnDeliveryItem
    WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery
      AND CustomerReturnDeliveryItem = @<key>-%param-OutboundDeliveryItem
    INTO @DATA(ls_return_item).
    " check the item is Return or Not
    IF sy-subrc <> 0.
        READ ENTITIES OF I_OutboundDeliveryTP
            ENTITY OutboundDeliveryItem
            FIELDS ( PickQuantityInOrderUnit ) WITH VALUE #( ( %tky-OutboundDelivery = <key>-%param-OutboundDelivery
                                                               %tky-OutboundDeliveryItem = <key>-%param-OutboundDeliveryItem ) )
            RESULT FINAL(LT_PICKEDQTY).

        IF lines( LT_PICKEDQTY ) > 0.
            DATA(lv_pickedqty) = LT_PICKEDQTY[ 1 ]-PickQuantityInOrderUnit.
            IF lv_totalqty - lv_pickedqty = 0.
                result = VALUE #( ( %cid = <key>-%cid %param = abap_true ) ).
            ELSE.
                result = VALUE #( ( %cid = <key>-%cid %param = abap_false ) ).
            ENDIF.
        ENDIF.
    ELSE.
        READ ENTITIES OF I_CUSTOMERRETURNSDELIVERYTP
            ENTITY CustomerReturnsDeliveryItem
            FIELDS ( PickQuantityInBaseUnit ) WITH VALUE #( ( %tky-CustomerReturnDelivery = <key>-%param-OutboundDelivery
                                                              %tky-CustomerReturnDeliveryItem = <key>-%param-OutboundDeliveryItem ) )
            RESULT FINAL(LT_RETURN_PICKEDQTY).
        IF lines( LT_RETURN_PICKEDQTY ) > 0.
            DATA(lv_return_pickedqty) = LT_RETURN_PICKEDQTY[ 1 ]-PickQuantityInBaseUnit.
            IF lv_totalqty - lv_return_pickedqty = 0.
                result = VALUE #( ( %cid = <key>-%cid %param = abap_true ) ).
            ELSE.
                result = VALUE #( ( %cid = <key>-%cid %param = abap_false ) ).
            ENDIF.
        ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD checkAllItemsPicked.
    ASSERT lines( keys ) > 0.

    READ TABLE keys ASSIGNING FIELD-SYMBOL(<key>) INDEX 1.
    IF sy-subrc <> 0.
        RETURN.
    ENDIF.

    SELECT OverallPickingStatus
    FROM I_OutboundDelivery
    WHERE OutboundDelivery = @<key>-%param-OutboundDelivery
      AND OverallPickingStatus = 'C'
    UNION
    SELECT OverallPickingStatus
    FROM I_CustomerReturnDelivery
    WHERE CustomerReturnDelivery = @<key>-%param-OutboundDelivery
      AND OverallPickingStatus = 'C'
    INTO TABLE @DATA(lt_overallpickingstatus).

    SORT lt_overallpickingstatus BY OverallPickingStatus DESCENDING.

    IF lt_overallpickingstatus IS NOT INITIAL.
            result = VALUE #( ( %cid = <key>-%cid %param = VALUE #( hasAllPicked = abap_true ) ) ).

            SELECT DeliveryNumber,
                   DeliveryItem,
                   Plant,
                   StorageLocation,
                   Material,
                   SerialNumber,
                   ScannedDate,
                   ScannedTime,
                   ScannedUserID,
                   ScannedUserName
            FROM zr_tsd013
            WHERE DeliveryNumber = @<key>-%param-OutboundDelivery
            INTO TABLE @DATA(lt_tsd013).

            IF lines( lt_tsd013 ) > 0.
                MODIFY ENTITIES OF zr_tsd013 IN LOCAL MODE
                ENTITY zr_tsd013
                UPDATE FIELDS ( PickingCompleted ) WITH VALUE #( FOR ls_tsd013 IN lt_tsd013 (
                                                %tky-DeliveryNumber = ls_tsd013-DeliveryNumber
                                                %tky-DeliveryItem = ls_tsd013-DeliveryItem
                                                %tky-Plant = ls_tsd013-Plant
                                                %tky-StorageLocation = ls_tsd013-StorageLocation
                                                %tky-Material = ls_tsd013-Material
                                                %tky-SerialNumber = ls_tsd013-SerialNumber
                                                %tky-ScannedDate = ls_tsd013-ScannedDate
                                                %tky-ScannedTime = ls_tsd013-ScannedTime
                                                %tky-ScannedUserID = ls_tsd013-ScannedUserID
                                                %tky-ScannedUserName = ls_tsd013-ScannedUserName
                                                PickingCompleted = 'X' ) ).
            ENDIF.

    ELSE.

            result = VALUE #( ( %cid = <key>-%cid %param = VALUE #( hasAllPicked = abap_false ) ) ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.
