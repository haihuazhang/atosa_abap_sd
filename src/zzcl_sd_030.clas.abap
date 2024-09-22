CLASS zzcl_sd_030 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_030 IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    TRY.
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

        DATA: lt_original_data   TYPE TABLE OF zr_psd030,
              lr_billingdocument TYPE RANGE OF i_billingdocument-billingdocument.

        TRY.
            DATA(lo_filter) = io_request->get_filter(  ).
            DATA(lt_filters) = lo_filter->get_as_ranges(  ).
          CATCH cx_rap_query_filter_no_range.
        ENDTRY.

        LOOP AT lt_filters ASSIGNING FIELD-SYMBOL(<lfs_filter>).
          TRANSLATE <lfs_filter>-name TO UPPER CASE.
          CASE <lfs_filter>-name.
            WHEN 'BILLINGDOCUMENT'.
              MOVE-CORRESPONDING <lfs_filter>-range TO lr_billingdocument.
          ENDCASE.
        ENDLOOP.

        SELECT *
          FROM zr_psd011
         WHERE billingdocument IN @lr_billingdocument
          INTO TABLE @DATA(lt_psd011).

        IF lt_psd011 IS NOT INITIAL.

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

          LOOP AT lt_psd011 INTO DATA(ls_psd011) GROUP BY ( material = ls_psd011-material )
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

            LOOP AT GROUP <fs_group> ASSIGNING FIELD-SYMBOL(<fs_group_line>).

              APPEND INITIAL LINE TO lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
              <fs_original_data> = CORRESPONDING #( <fs_group_line> ).

              READ TABLE lt_product_text INTO DATA(ls_product_text) WITH KEY product  = <fs_original_data>-material
                                                                             language = 'EN'
                                                                             BINARY SEARCH.
              IF ls_product_text-longtext IS INITIAL.
                <fs_original_data>-description = <fs_original_data>-billingdocumentitemtext.
              ELSE.
                <fs_original_data>-description = ls_product_text-longtext.
              ENDIF.

              CLEAR <fs_original_data>-discountamount.
              <fs_original_data>-discountamount = <fs_group_line>-conditionamount_zdrn +
                                                  <fs_group_line>-conditionamount_zdc7 +
                                                  <fs_group_line>-conditionamount_d001.

              IF <fs_original_data>-billingdocumenttype = 'G2'
              OR <fs_original_data>-billingdocumenttype = 'S2'.
                <fs_original_data>-unitprice *= -1.
                <fs_original_data>-discountamount *= -1.
                <fs_original_data>-netamount *= -1.
                <fs_original_data>-subtotal1amount *= -1.
              ENDIF.
            ENDLOOP.

            CLEAR: lv_path,lv_response,ls_data,ls_product_text.
          ENDLOOP.

          SORT lt_original_data BY billingdocument billingdocumentitem.
        ENDIF.

        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
                                     CHANGING  ct_data   = lt_original_data ).

        IF io_request->is_total_numb_of_rec_requested(  ).
          io_response->set_total_number_of_records( lines( lt_original_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                   CHANGING  ct_data  = lt_original_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                  CHANGING  ct_data   = lt_original_data ).

        io_response->set_data( lt_original_data ).

      CATCH cx_root.
        " Do Nothing
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
