CLASS zzcl_sd_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
*    METHODS get_function_modules IMPORTING io_request  TYPE REF TO if_rap_query_request
*                                           io_response TYPE REF TO if_rap_query_response
*                                 RAISING   cx_rap_query_prov_not_impl
*                                           cx_rap_query_provider.

    METHODS get_propertygroupcode IMPORTING io_request  TYPE REF TO if_rap_query_request
                                            io_response TYPE REF TO if_rap_query_response
                                  RAISING   cx_rap_query_prov_not_impl
                                            cx_rap_query_provider.

    METHODS get_consolidationkey IMPORTING io_request  TYPE REF TO if_rap_query_request
                                           io_response TYPE REF TO if_rap_query_response
                                 RAISING   cx_rap_query_prov_not_impl
                                           cx_rap_query_provider.

    METHODS get_Csr IMPORTING io_request  TYPE REF TO if_rap_query_request
                              io_response TYPE REF TO if_rap_query_response
                    RAISING   cx_rap_query_prov_not_impl
                              cx_rap_query_provider.

    METHODS get_project IMPORTING io_request  TYPE REF TO if_rap_query_request
                                  io_response TYPE REF TO if_rap_query_response
                        RAISING   cx_rap_query_prov_not_impl
                                  cx_rap_query_provider.

    METHODS get_uuid IMPORTING io_request  TYPE REF TO if_rap_query_request
                               io_response TYPE REF TO if_rap_query_response
                     RAISING   cx_rap_query_prov_not_impl
                               cx_rap_query_provider.
ENDCLASS.



CLASS ZZCL_SD_001 IMPLEMENTATION.


  METHOD get_consolidationkey.

    DATA: lt_entity TYPE TABLE OF zr_ssd011.

    SELECT ConsolidationKey,CreatedBy FROM zr_tsd009 "#EC CI_NOWHERE  #EC CI_ALL_FIELDS_NEEDED
*    WHERE language = @lv_curr_lang
    INTO TABLE @DATA(lt_result).

    lt_entity = VALUE #( FOR result IN lt_result ( ConsolidationKey = result-ConsolidationKey  ) ).

    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_entity ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_entity ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_entity ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_entity ).

    io_response->set_data( lt_entity ).



  ENDMETHOD.


  METHOD get_csr.

    DATA: lt_entity TYPE TABLE OF zr_ssd013.

    SELECT * FROM zr_tsd010   "#EC CI_ALL_FIELDS_NEEDED "#EC CI_NOWHERE
*    WHERE language = @lv_curr_lang
    INTO TABLE @DATA(lt_result).

    lt_entity = VALUE #( FOR result IN lt_result ( NationalAccountsTeamCsr = result-NationalAccountsTeamCsr  ) ).

    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_entity ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_entity ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_entity ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_entity ).

    io_response->set_data( lt_entity ).



  ENDMETHOD.


  METHOD get_project.

    DATA: lt_entity TYPE TABLE OF zr_ssd014.

    SELECT * FROM zr_tsd011   "#EC CI_ALL_FIELDS_NEEDED "#EC CI_NOWHERE
*    WHERE language = @lv_curr_lang
    INTO TABLE @DATA(lt_result).

    lt_entity = VALUE #( FOR result IN lt_result ( Project = result-Project  ) ).

    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_entity ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_entity ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_entity ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_entity ).

    io_response->set_data( lt_entity ).



  ENDMETHOD.


  METHOD get_propertygroupcode.

    DATA: lt_entity TYPE TABLE OF zr_ssd010.
*    DATA(lo_package) = xco_cp_abap_repository=>package->for( 'ZZDATAIMPORT' ).
*
*
*
*    DATA(lt_func_result) = xco_cp_abap_repository=>objects->fugr->all->in( lo_package )->get(  ).
*
*    " get function modules under every function group
*    lt_funcs = VALUE #( FOR result IN lt_func_result
*                            FOR func IN result->function_modules->all->get(  )
*                            ( FunctionModuleName = func->name FunctionModuleDesc = func->content(  )->get_short_text(  )  ) ).
*
*    try.
*        data(lv_curr_lang) = cl_abap_context_info=>get_user_language_abap_format(  ).
*      catch cx_abap_context_info_error.
*        "handle exception
*    endtry.
    SELECT * FROM zr_tsd008   "#EC CI_NOWHERE "#EC CI_ALL_FIELDS_NEEDED
*    WHERE language = @lv_curr_lang
    INTO TABLE @DATA(lt_result).

    lt_entity = VALUE #( FOR result IN lt_result ( PropertyGroupCode = result-PropertyGroupCode PropertyName =  result-PropertyName ) ).

    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_entity ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_entity ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_entity ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_entity ).

    io_response->set_data( lt_entity ).



*    DATA(sort_elements) = io_request->get_sort_elements( ).
*    /iwbep/cl_mgw_data_util=>orderby( it_order = sort_elements CHANGING ct_data = lt_funcs ).


  ENDMETHOD.


  METHOD get_UUID.

    DATA: lt_entity TYPE TABLE OF zr_ssd015.

    SELECT uuid, createdby FROM zr_tsd007 "#EC CI_ALL_FIELDS_NEEDED "#EC CI_NOWHERE
*    WHERE language = @lv_curr_lang
    INTO TABLE @DATA(lt_result).

    lt_entity = VALUE #( FOR result IN lt_result ( uuid = result-uuid  ) ).

    zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_entity ).

    IF io_request->is_total_numb_of_rec_requested(  ) .
      io_response->set_total_number_of_records( lines( lt_entity ) ).
    ENDIF.

    zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_entity ).

    zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_entity ).

    io_response->set_data( lt_entity ).



  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.
        CASE io_request->get_entity_id( ).

          WHEN 'ZR_SSD010'.
            get_propertygroupcode( io_request = io_request io_response = io_response ).
          WHEN 'ZR_SSD011'.
            get_consolidationkey( io_request = io_request io_response = io_response ).
          WHEN 'ZR_SSD013'.
            get_csr( io_request = io_request io_response = io_response ).
          WHEN 'ZR_SSD014'.
            get_project( io_request = io_request io_response = io_response ).

          WHEN 'ZR_SSD015'.
            get_UUID( io_request = io_request io_response = io_response ).
        ENDCASE.

      CATCH cx_rap_query_provider.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
