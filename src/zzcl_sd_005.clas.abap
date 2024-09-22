CLASS zzcl_sd_005 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_005 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF zc_psd003 WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).
    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
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

      TRY.

          TRY.
              DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
            CATCH cx_web_http_client_error.
          ENDTRY.

          DATA(lo_request) = lo_http_client->get_http_request(   ).

          DATA : lv_languagecode TYPE spras.
          TRY.
              lv_languagecode = cl_abap_context_info=>get_user_language_abap_format(  ).
            CATCH cx_abap_context_info_error.
              "handle exception
          ENDTRY.


          lo_http_client->enable_path_prefix( ).

          DATA(lv_path) = |{ '/API_PRODUCT_SRV/A_Product(''' }{ <fs_original_data>-material }{ ''')/to_ProductBasicText' }|.

          REPLACE ALL OCCURRENCES OF ` ` IN lv_path WITH '%20'.

          lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
          lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').

          TRY.
              lo_http_client->set_csrf_token(  ).

              DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
            CATCH cx_web_http_client_error.
          ENDTRY.

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
          DATA:BEGIN OF lo_error,
                 d LIKE ls_data,
               END OF lo_error.
          /ui2/cl_json=>deserialize(
              EXPORTING
                  json = lv_response
              CHANGING
                  data = lo_error
          ).
          READ TABLE lo_error-d-results INTO DATA(ls_results) INDEX 1.
          IF sy-subrc = 0.
            DATA(lv_longtext) = ls_results-longtext.
          ELSE.
            SELECT SINGLE productname
            FROM zr_psd017
            WHERE product = @<fs_original_data>-material
            AND   language = 'E'
            INTO @lv_longtext.
          ENDIF.
          <fs_original_data>-productlongtext = lv_longtext.
          CLEAR:lv_longtext.
        CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
      ENDTRY.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'PRODUCTLONGTEXT'.
          INSERT `DELIVERYDOCUMENT` INTO TABLE et_requested_orig_elements.

        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
