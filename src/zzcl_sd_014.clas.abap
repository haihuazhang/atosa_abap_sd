CLASS zzcl_sd_014 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_014 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA:BEGIN OF ls_result,
           product  TYPE string,
           language TYPE string,
           longtext TYPE string,
         END OF ls_result,

         BEGIN OF ls_results,
           results LIKE TABLE OF ls_result,
         END OF ls_results,

         BEGIN OF ls_data,
           d LIKE ls_results,
         END OF ls_data.

    DATA lt_original_data TYPE STANDARD TABLE OF zc_psd011 WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).

    " Find CA by Scenario ID
    cl_com_arrangement_factory=>create_instance( )->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ) )
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
        DATA(lv_language) = cl_abap_context_info=>get_user_language_abap_format(  ).
      CATCH cx_abap_context_info_error.
    ENDTRY.

    LOOP AT lt_original_data INTO DATA(ls_original_data)
                              GROUP BY ( material = ls_original_data-material )
                             ASSIGNING FIELD-SYMBOL(<fs_group>).

      " Call API for get product description
      TRY.
          DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
          DATA(lo_request) = lo_http_client->get_http_request(   ).
          lo_http_client->enable_path_prefix( ).

          DATA(lv_path) = |/API_PRODUCT_SRV/A_Product('{ <fs_group>-material }')/to_ProductBasicText|.
          REPLACE ALL OCCURRENCES OF ` ` IN lv_path WITH '%20'.

          lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
          lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json' ).

          lo_http_client->set_csrf_token(  ).

          DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
          DATA(lv_response) = lo_response->get_text(  ).
          DATA(lv_status)   = lo_response->get_status( ).

          /ui2/cl_json=>deserialize(
              EXPORTING
                  json = lv_response
              CHANGING
                  data = ls_data
          ).

          DATA(lt_product_text) = ls_data-d-results.
          SORT lt_product_text BY product language.
        CATCH cx_root.
      ENDTRY.

      LOOP AT GROUP <fs_group> ASSIGNING FIELD-SYMBOL(<fs_original_data>).
        READ TABLE lt_product_text INTO DATA(ls_product_text) WITH KEY product  = <fs_original_data>-material
                                                                       language = 'EN'
                                                                       BINARY SEARCH.
        IF ls_product_text-longtext IS INITIAL.
          <fs_original_data>-description = <fs_original_data>-billingdocumentitemtext.
        ELSE.
          <fs_original_data>-description = ls_product_text-longtext.
        ENDIF.
      ENDLOOP.

      CLEAR: lv_path,lv_response,ls_data,ls_product_text.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
