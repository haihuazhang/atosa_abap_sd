CLASS zzcl_sd_019 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES:BEGIN OF ty_t,
            id   TYPE string,
            type TYPE string,
            uri  TYPE string,
          END OF ty_t.
    TYPES:BEGIN OF ty_tab,
            LongText  TYPE string,
            _metadata TYPE ty_t,
          END OF ty_tab.
    DATA:BEGIN OF ls_data,
            results TYPE TABLE OF ty_tab,
         END OF ls_data.
    DATA:BEGIN OF lt_return,
            d LIKE ls_data,
         END OF lt_return.

    METHODS get_data1 IMPORTING io_request  TYPE REF TO if_rap_query_request
                               io_response TYPE REF TO if_rap_query_response
                     RAISING   cx_rap_query_prov_not_impl
                               cx_rap_query_provider.

    METHODS get_data2 IMPORTING io_request  TYPE REF TO if_rap_query_request
                               io_response TYPE REF TO if_rap_query_response
                     RAISING   cx_rap_query_prov_not_impl
                               cx_rap_query_provider.
ENDCLASS.



CLASS ZZCL_SD_019 IMPLEMENTATION.


  METHOD get_data1.
    DATA: lt_data TYPE TABLE OF ZR_PSD025,
          lr_salesdoc TYPE RANGE OF I_SalesDocument-SalesDocument.

    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
    CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    LOOP AT lt_filters ASSIGNING FIELD-SYMBOL(<lfs_filter>).
        TRANSLATE <lfs_filter>-name TO UPPER CASE.
        CASE <lfs_filter>-name.
          WHEN 'SALESDOCUMENT'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_salesdoc.
        ENDCASE.
    ENDLOOP.

    SELECT *
    FROM ZR_PSD005
    WHERE SalesDocument IN @lr_salesdoc
    INTO CORRESPONDING FIELDS OF TABLE @lt_data.

    DATA lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.

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

    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

        DATA(lo_request) = lo_http_client->get_http_request(   ).
    CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
    CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
    ENDTRY.

    DATA lv_languagecode TYPE spras.
    TRY.
        lv_languagecode = cl_abap_context_info=>get_user_language_abap_format(  ).
    CATCH cx_abap_context_info_error.
                    "handle exception
    ENDTRY.

    lo_http_client->enable_path_prefix( ).

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
        TRY.
            IF <fs_data>-SalesDocumentType = 'CR'
            OR <fs_data>-SalesDocumentType = 'GA2'.
                DATA(lv_path) = |/API_CREDIT_MEMO_REQUEST_SRV/A_CreditMemoReqText?$filter=CreditMemoRequest eq '{ <fs_data>-SalesDocument }' and Language eq '{ lv_languagecode }' and LongTextID eq 'TX05'&$select=LongText|.
                lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
                lo_http_client->set_csrf_token(  ).

                DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
                DATA(lv_response) = lo_response->get_text(  ).
                DATA(status) = lo_response->get_status( ).

                IF status-code = 200.
                    /ui2/cl_json=>deserialize(
                        EXPORTING
                            json = lv_response
                        CHANGING
                            data = lt_return
                    ).
                    READ TABLE lt_return-d-results ASSIGNING FIELD-SYMBOL(<fs_result>) INDEX 1.
                    IF sy-subrc = 0.
                        <fs_data>-CustomerNote = <fs_result>-longtext.
                    ENDIF.
                ENDIF.
            ELSEIF <fs_data>-SalesDocumentType = 'DR'.
                lv_path = |/API_DEBIT_MEMO_REQUEST_SRV/A_DebitMemoReqText?$filter=DebitMemoRequest eq '{ <fs_data>-SalesDocument }' and Language eq '{ lv_languagecode }' and LongTextID eq 'TX05'&$select=LongText|.
                lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
                lo_http_client->set_csrf_token(  ).

                lo_response = lo_http_client->execute( if_web_http_client=>get ).
                lv_response = lo_response->get_text(  ).
                status = lo_response->get_status( ).

                IF status-code = 200.
                    /ui2/cl_json=>deserialize(
                        EXPORTING
                            json = lv_response
                        CHANGING
                            data = lt_return
                    ).
                    READ TABLE lt_return-d-results ASSIGNING <fs_result> INDEX 1.
                    IF sy-subrc = 0.
                        <fs_data>-CustomerNote = <fs_result>-longtext.
                    ENDIF.
                ENDIF.
            ELSE.
                lv_path = |/API_SALES_ORDER_SRV/A_SalesOrderText(SalesOrder='{ <fs_data>-SalesDocument }',Language='{ lv_languagecode }',LongTextID='TX05')|.
                lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
                lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
                lo_http_client->set_csrf_token(  ).

                lo_response = lo_http_client->execute( if_web_http_client=>get ).
                lv_response = lo_response->get_text(  ).
                status = lo_response->get_status( ).

                IF status-code = 200.
                    DATA lo_result TYPE REF TO data.
                    /ui2/cl_json=>deserialize(
                        EXPORTING
                            json = lv_response
                        CHANGING
                            data = lo_result
                    ).
                    ASSIGN COMPONENT 'd' OF STRUCTURE lo_result->* TO FIELD-SYMBOL(<fs_d>).
                    IF sy-subrc = 0.
                        ASSIGN COMPONENT 'LongText' OF STRUCTURE <fs_d>->* TO FIELD-SYMBOL(<fs_longtext>).
                        IF sy-subrc = 0.
                            <fs_data>-CustomerNote = <fs_longtext>->*.
                        ENDIF.
                    ENDIF.
                ENDIF.
            ENDIF.

        CATCH /iwbep/cx_gateway INTO lx_gateway.
        CATCH CX_WEB_HTTP_CLIENT_ERROR INTO lx_web_http_client_error.

        ENDTRY.

        SELECT SINGLE SoldToParty
        FROM I_SalesDocument
        WITH PRIVILEGED ACCESS
        WHERE SalesDocument = @<fs_data>-SalesDocument
        INTO @DATA(lv_soldto).

        SELECT SINGLE Customer
        FROM I_SalesDocumentPartner
        WITH PRIVILEGED ACCESS
        WHERE SalesDocument = @<fs_data>-SalesDocument
          AND PartnerFunction = 'WE'
        INTO @DATA(lv_customer).

        SELECT SINGLE BusinessPartnerIDByExtSystem
        FROM I_BusinessPartner
        WITH PRIVILEGED ACCESS
        INNER JOIN I_SalesDocument
        WITH PRIVILEGED ACCESS
            ON I_SalesDocument~SoldToParty = I_BusinessPartner~BusinessPartner
            AND I_SalesDocument~SalesDocument = @<fs_data>-SalesDocument
        INTO @DATA(lv_bpidbyext).

        lv_soldto = |{ lv_soldto ALPHA = OUT }|.
        lv_customer = |{ lv_customer ALPHA = OUT }|.

        IF lv_bpidbyext IS INITIAL.
            <fs_data>-BillToCustomerID = lv_soldto.
            <fs_data>-ShipToID = lv_customer.
        ELSE.
            CONCATENATE lv_soldto '/' lv_bpidbyext INTO <fs_data>-BillToCustomerID SEPARATED BY ` `.
            CONCATENATE lv_customer '/' lv_bpidbyext INTO <fs_data>-ShipToID SEPARATED BY ` `.
        ENDIF.


    ENDLOOP.

    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

    io_response->set_data( lt_data ).

  ENDMETHOD.


  METHOD get_data2.
    DATA: lt_data TYPE TABLE OF ZR_PSD029,
          lr_salesdoc TYPE RANGE OF I_SalesDocumentItem-SalesDocument.

    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).
    CATCH cx_rap_query_filter_no_range.
    ENDTRY.

    LOOP AT lt_filters ASSIGNING FIELD-SYMBOL(<lfs_filter>).
        TRANSLATE <lfs_filter>-name TO UPPER CASE.
        CASE <lfs_filter>-name.
          WHEN 'SALESDOCUMENT'.
            MOVE-CORRESPONDING <lfs_filter>-range TO lr_salesdoc.
        ENDCASE.
    ENDLOOP.

    SELECT *
    FROM ZR_PSD006
    WHERE SalesDocument IN @lr_salesdoc
    ORDER BY SalesDocument,SalesDocumentItem
    INTO CORRESPONDING FIELDS OF TABLE @lt_data.

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
*                   out->write( lx_http_dest_provider_error->get_text( ) ).
        EXIT.
    ENDTRY.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).
        TRY.
          DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

          DATA(lo_request) = lo_http_client->get_http_request(   ).

          DATA lv_languagecode TYPE spras.
          TRY.
              lv_languagecode = cl_abap_context_info=>get_user_language_abap_format(  ).
            CATCH cx_abap_context_info_error.
              "handle exception
          ENDTRY.

          lo_http_client->enable_path_prefix( ).

          DATA(lv_path) = |/API_PRODUCT_SRV/A_Product('{ <fs_data>-material }')/to_ProductBasicText|.
          lv_path = replace( val = lv_path
                           sub = ` `
                           with = `%20`
                           occ = 0 ).
*          lv_path = cl_web_http_utility=>escape_url( lv_path ).
          lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
          lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').

          lo_http_client->set_csrf_token(  ).

          DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
          DATA(lv_response) = lo_response->get_text(  ).
          DATA(status) = lo_response->get_status( ).

          TYPES:BEGIN OF ty_t,
                  id   TYPE string,
                  type TYPE string,
                  uri  TYPE string,
                END OF ty_t.
          TYPES:BEGIN OF ty_tab,
                  language  TYPE string,
                  longtext  TYPE string,
                  product   TYPE string,
                  _metadata TYPE ty_t,
                END OF ty_tab.
          DATA:BEGIN OF ls_data,
                 results TYPE TABLE OF ty_tab,
               END OF ls_data.
          DATA:BEGIN OF lt_return,
                 d LIKE ls_data,
               END OF lt_return.

          IF status-code = 200.
            /ui2/cl_json=>deserialize(
                EXPORTING
                    json = lv_response
                CHANGING
                    data = lt_return
            ).
            READ TABLE lt_return-d-results ASSIGNING FIELD-SYMBOL(<fs_results>) INDEX 1.
            IF sy-subrc = 0.
              <fs_data>-salesdocumentitemtext = <fs_results>-longtext.
            ELSE.
              SELECT SINGLE salesdocumentitemtext FROM i_salesdocumentitem
              WITH PRIVILEGED ACCESS
              WHERE salesdocument = @<fs_data>-salesdocument
                  AND salesdocumentitem = @<fs_data>-salesdocumentitem
                  AND material = @<fs_data>-material
              INTO @<fs_data>-salesdocumentitemtext.
            ENDIF.
          ELSE.
            SELECT SINGLE salesdocumentitemtext FROM i_salesdocumentitem
            WITH PRIVILEGED ACCESS
            WHERE salesdocument = @<fs_data>-salesdocument
                AND salesdocumentitem = @<fs_data>-salesdocumentitem
                AND material = @<fs_data>-material
            INTO @<fs_data>-salesdocumentitemtext.
          ENDIF.

        CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).

        ENDTRY.

        TRY.
          lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

          lo_request = lo_http_client->get_http_request(   ).

          TRY.
              lv_languagecode = cl_abap_context_info=>get_user_language_abap_format(  ).
            CATCH cx_abap_context_info_error.
              "handle exception
          ENDTRY.

          lo_http_client->enable_path_prefix( ).

          lv_path = |/API_SALES_ORDER_SRV/A_SalesOrderItemText(SalesOrder='{ <fs_data>-salesdocument }',SalesOrderItem='{ <fs_data>-salesdocumentitem }',Language='{ lv_languagecode }',LongTextID='Z001')|.
          lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
          lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').

          lo_http_client->set_csrf_token(  ).

          lo_response = lo_http_client->execute( if_web_http_client=>get ).
          lv_response = lo_response->get_text(  ).
          status = lo_response->get_status( ).

          IF status-code = 200.
            DATA lo_result TYPE REF TO data.
            /ui2/cl_json=>deserialize(
                EXPORTING
                    json = lv_response
                CHANGING
                    data = lo_result
            ).
            ASSIGN COMPONENT 'd' OF STRUCTURE lo_result->* TO FIELD-SYMBOL(<fs_d>).
            IF sy-subrc = 0.
              ASSIGN COMPONENT 'LongText' OF STRUCTURE <fs_d>->* TO FIELD-SYMBOL(<fs_longtext>).
              IF sy-subrc = 0.
                <fs_data>-materialnote = <fs_longtext>->*.
              ENDIF.
            ENDIF.
          ENDIF.

        CATCH /iwbep/cx_gateway INTO lx_gateway.
        CATCH cx_web_http_client_error INTO lx_web_http_client_error.

        ENDTRY.

    ENDLOOP.

    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_data ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_data ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_data ).

    io_response->set_data( lt_data ).

  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.
        CASE io_request->get_entity_id( ).

          WHEN 'ZR_PSD025'.
            get_data1( io_request = io_request io_response = io_response ).
          WHEN 'ZR_PSD029'.
            get_data2( io_request = io_request io_response = io_response ).
        ENDCASE.

      CATCH cx_rap_query_provider INTO DATA(lx_query).
      CATCH cx_sy_no_handler INTO DATA(lx_synohandler).
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
