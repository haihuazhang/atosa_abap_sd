CLASS zzcl_sd_028 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_028 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF zc_ssd058 WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).

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
        DATA(lo_http_client5) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

        DATA(lo_request5) = lo_http_client5->get_http_request(   ).

        TRY.
            DATA(lv_languagecode5) = cl_abap_context_info=>get_user_language_abap_format(  ).
          CATCH cx_abap_context_info_error.
            "handle exception
        ENDTRY.

        lo_http_client5->enable_path_prefix( ).

        DATA(lv_path5) = |/API_SALES_ORDER_SRV/A_SalesOrderItemText|.
        lo_request5->set_uri_path( EXPORTING i_uri_path = lv_path5 ).
        lo_request5->set_header_field( i_name = 'Accept' i_value = 'application/json').

        lo_http_client5->set_csrf_token(  ).

        DATA(lo_response5) = lo_http_client5->execute( if_web_http_client=>get ).
        DATA(lv_response5) = lo_response5->get_text(  ).
        DATA(status5) = lo_response5->get_status( ).

        TYPES:BEGIN OF ty_tab,
                salesorder     TYPE string,
                salesorderitem TYPE string,
                language       TYPE string,
                longtextid     TYPE string,
                longtext       TYPE string,
              END OF ty_tab.
        DATA:BEGIN OF ls_data,
               results TYPE TABLE OF ty_tab,
             END OF ls_data.
        DATA:BEGIN OF lo_error,
               d LIKE ls_data,
             END OF lo_error.

        IF status5-code = 200.
          DATA lo_result5 TYPE REF TO data.
          /ui2/cl_json=>deserialize(
              EXPORTING
                  json = lv_response5
              CHANGING
                  data = lo_error
          ).
        ENDIF.
        DELETE lo_error-d-results WHERE language <> 'EN'.
        DELETE lo_error-d-results WHERE longtextid <> 'Z001'.
        SORT lo_error-d-results BY salesorder salesorderitem.
      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).

      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
*                   out->write( lx_http_dest_provider_error->get_text( ) ).
        EXIT.


    ENDTRY.
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

        DATA(lo_request) = lo_http_client->get_http_request(   ).

        TRY.
            DATA(lv_languagecode) = cl_abap_context_info=>get_user_language_abap_format(  ).
          CATCH cx_abap_context_info_error.
            "handle exception
        ENDTRY.

        lo_http_client->enable_path_prefix( ).

*          lv_path = |/API_SALES_ORDER_SRV/A_SalesOrderText(SalesOrder='{ <fs_original_data>-salesdocument }',Language='{ lv_languagecode }',LongTextID='TX05')|.
        DATA(lv_path) = |/API_SALES_ORDER_SRV/A_SalesOrderText|.
        lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').

        lo_http_client->set_csrf_token(  ).

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
        DATA(lv_response) = lo_response->get_text(  ).
        DATA(status) = lo_response->get_status( ).

        TYPES:BEGIN OF ty_tab1,
                salesorder TYPE string,
                language   TYPE string,
                longtextid TYPE string,
                longtext   TYPE string,
              END OF ty_tab1.
        DATA:BEGIN OF ls_data1,
               results TYPE TABLE OF ty_tab1,
             END OF ls_data1.
        DATA:BEGIN OF lo_result1,
               d LIKE ls_data1,
             END OF lo_result1.
        IF status-code = 200.
          /ui2/cl_json=>deserialize(
              EXPORTING
                  json = lv_response
              CHANGING
                  data = lo_result1
          ).

        ENDIF.

      CATCH /iwbep/cx_gateway INTO lx_gateway.
      CATCH cx_web_http_client_error INTO lx_web_http_client_error.

    ENDTRY.
    DATA(lo_error1) = lo_result1-d-results.
    DELETE lo_error1 WHERE longtextid <> 'TX05'.
    SORT lo_error1 BY salesorder.
    DATA(lo_error2) = lo_result1-d-results.
    DELETE lo_error2 WHERE longtextid <> 'TX01'.
    SORT lo_error2 BY salesorder.
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).

      <fs_original_data>-salesdocument = |{ <fs_original_data>-salesdocument ALPHA = OUT }|.
      <fs_original_data>-salesdocumentitem = |{ <fs_original_data>-salesdocumentitem ALPHA = OUT }|.

      READ TABLE lo_error-d-results INTO DATA(ls_freetext) WITH KEY salesorder = <fs_original_data>-salesdocument
                                                                    salesorderitem = <fs_original_data>-salesdocumentitem BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_original_data>-freetext = ls_freetext-longtext.
      ENDIF.
      READ TABLE lo_error1 INTO DATA(ls_error1) WITH KEY salesorder = <fs_original_data>-salesdocument BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_original_data>-invoiceremarks = ls_error1-longtext.
      ENDIF.
      READ TABLE lo_error2 INTO DATA(ls_error2) WITH KEY salesorder = <fs_original_data>-salesdocument BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_original_data>-internalremarks = ls_error2-longtext.
      ENDIF.

      <fs_original_data>-salesdocument = |{ <fs_original_data>-salesdocument ALPHA = IN }|.
      <fs_original_data>-salesdocumentitem = |{ <fs_original_data>-salesdocumentitem ALPHA = IN }|.
      CLEAR:ls_freetext,ls_error1,ls_error2.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
