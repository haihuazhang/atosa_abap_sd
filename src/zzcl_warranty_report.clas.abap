CLASS zzcl_warranty_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS get_warranty IMPORTING io_request  TYPE REF TO if_rap_query_request
                                   io_response TYPE REF TO if_rap_query_response
                         RAISING   cx_rap_query_prov_not_impl
                                   cx_rap_query_provider.
ENDCLASS.



CLASS ZZCL_WARRANTY_REPORT IMPLEMENTATION.


  METHOD get_warranty.
    TRY.

        DATA: lt_funcs TYPE TABLE OF zzr_warranty_report.

        DATA : lr_salesorder TYPE RANGE OF i_salesdocumentitem-salesdocument.
        DATA : lr_plant TYPE RANGE OF i_salesdocumentitem-plant.
        DATA : lr_salesorganization TYPE RANGE OF i_salesdocumentitem-salesorganization.
        DATA : lr_soldtoparty TYPE RANGE OF i_salesdocumentitem-soldtoparty.
        DATA : lr_creationdate TYPE RANGE OF i_salesdocumentitem-creationdate.
        DATA : lr_purchaseorderbycustomer TYPE RANGE OF i_salesdocumentitem-purchaseorderbycustomer.
        DATA : lr_salesdocumenttype TYPE RANGE OF i_salesdocument-salesdocumenttype.
        DATA : lr_serialnumber TYPE RANGE OF i_serialnumberdeliverydocument-serialnumber.
        DATA : lr_zoldserialnumber TYPE RANGE OF ztmm001-zoldserialnumber.
        DATA : lr_material TYPE RANGE OF i_salesdocumentitem-material.

        DATA(lo_filter) = io_request->get_filter(  ).
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'SALESDOCUMENT'.
              MOVE-CORRESPONDING ls_filter-range TO lr_salesorder.
            WHEN 'PLANT1'.
              MOVE-CORRESPONDING ls_filter-range TO lr_plant.
            WHEN 'SALESORGANIZATION'.
              MOVE-CORRESPONDING ls_filter-range TO lr_salesorganization.
            WHEN 'SOLDTOPARTY'.
              MOVE-CORRESPONDING ls_filter-range TO lr_soldtoparty.
            WHEN 'CREATIONDATE'.
              MOVE-CORRESPONDING ls_filter-range TO lr_creationdate.
            WHEN 'PURCHASEORDERBYCUSTOMER'.
              MOVE-CORRESPONDING ls_filter-range TO lr_purchaseorderbycustomer.
            WHEN 'SALESDOCUMENTTYPE'.
              MOVE-CORRESPONDING ls_filter-range TO lr_salesdocumenttype.
            WHEN 'SERIALNUMBER1'.
              MOVE-CORRESPONDING ls_filter-range TO lr_serialnumber.
            WHEN 'ZOLDSERIALNUMBER'.
              MOVE-CORRESPONDING ls_filter-range TO lr_zoldserialnumber.
            WHEN 'MATERIAL1'.
              MOVE-CORRESPONDING ls_filter-range TO lr_material.

          ENDCASE.

        ENDLOOP.

        SELECT *
        FROM zi_warranty_report
*        WHERE salesdocument IN @lr_salesorder
        WHERE   plant1         IN @lr_plant
        AND   salesorganization IN @lr_salesorganization
*        AND   soldtoparty   IN @lr_soldtoparty
*        AND   creationdate  IN @lr_creationdate
        AND   purchaseorderbycustomer IN @lr_purchaseorderbycustomer
*        AND   salesdocumenttype IN @lr_salesdocumenttype
*        AND   serialnumber1  IN @lr_serialnumber
*        AND   zoldserialnumber IN @lr_zoldserialnumber
*        AND   material1   IN @lr_material
        INTO TABLE @DATA(lt_funcs1).


        MOVE-CORRESPONDING lt_funcs1 TO lt_funcs.
        DELETE lt_funcs WHERE zwarrantytype IS INITIAL AND zwarrantymaterial IS INITIAL.
        DELETE lt_funcs WHERE postingdate IS INITIAL AND ( salesdocumenttype <> 'GA2' AND salesdocumenttype <> 'G2' AND salesdocumenttype <> 'CBAR' ) AND legacy <> 'X'.
        IF lt_funcs IS NOT INITIAL.
          SELECT z_warranty_material
          FROM ztsd001
          FOR ALL ENTRIES IN @lt_funcs
          WHERE z_warranty_material = @lt_funcs-material1
          INTO TABLE @DATA(lt_material).
          SORT lt_material BY z_warranty_material.
          SELECT z_warranty_material
          FROM ztsd001
          FOR ALL ENTRIES IN @lt_funcs
          WHERE z_warranty_material = @lt_funcs-zwarrantymaterial
          INTO TABLE @DATA(lt_warrantymaterial).
          SORT lt_warrantymaterial BY z_warranty_material.
        ENDIF.
        DATA:lv_material          TYPE ztsd001-z_warranty_material,
             lv_zwarrantymaterial TYPE ztsd001-z_warranty_material.
        LOOP AT lt_funcs INTO DATA(is_funcs).
          IF is_funcs-salesdocumenttype = 'G2' OR is_funcs-salesdocumenttype = 'DR'.
            READ TABLE lt_material INTO DATA(ls_material) WITH KEY z_warranty_material = is_funcs-material1 BINARY SEARCH.
            IF sy-subrc = 0.
              lv_material = ls_material-z_warranty_material.
            ENDIF.
*            SELECT SINGLE z_warranty_material
*            FROM ztsd001
*            WHERE z_warranty_material = @is_funcs-material1
*            INTO @DATA(lv_material).
            READ TABLE lt_warrantymaterial INTO DATA(ls_warrantymaterial) WITH KEY z_warranty_material = is_funcs-zwarrantymaterial BINARY SEARCH.
            IF sy-subrc = 0.
              lv_zwarrantymaterial = ls_warrantymaterial-z_warranty_material.
            ENDIF.
*            SELECT SINGLE z_warranty_material
*            FROM ztsd001
*            WHERE z_warranty_material = @is_funcs-zwarrantymaterial
*            INTO @DATA(lv_zwarrantymaterial).
            IF is_funcs-zwarrantytype = 'STANDARD'.
              IF lv_material IS INITIAL.
                DELETE lt_funcs[].
              ENDIF.
            ELSE.
              IF lv_zwarrantymaterial IS INITIAL AND lv_material IS INITIAL.
                DELETE lt_funcs[].
              ENDIF.
            ENDIF.
          ENDIF.
          IF is_funcs-Legacy = 'X'.
            is_funcs-salesdocumenttype = 'TA'.
            MODIFY lt_funcs FROM is_funcs.
          ENDIF.
          CLEAR:lv_material,is_funcs,lv_zwarrantymaterial,ls_material,ls_warrantymaterial.
        ENDLOOP.
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

            DATA(lv_path) = |{ '/API_PRODUCT_SRV/A_ProductBasicText' }|.

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
*            READ TABLE lo_error-d-results INTO DATA(ls_results) INDEX 1.
*            IF sy-subrc = 0.
*              DATA(lv_longtext) = ls_results-longtext.
*            ENDIF.
*            IF lv_longtext IS NOT INITIAL.
*              is_funcs-salesdocumentitemtext = lv_longtext.
*            ENDIF.
*            CLEAR:lv_longtext.
          CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        ENDTRY.

        DATA(ggt_funcs) = lt_funcs.
        DELETE ggt_funcs WHERE zwarrantytype  = 'EXTEND'.
        DELETE ggt_funcs WHERE zactive <> 'X'.
        LOOP AT lt_funcs INTO is_funcs.
          IF is_funcs-zwarrantytype ='EXTEND'.
            READ TABLE ggt_funcs INTO DATA(ggs_funcs) WITH KEY serialnumber1 = is_funcs-yy1_warrantyserial_sdi.
            IF sy-subrc = 0.
              IF is_funcs-creationdate >= ggs_funcs-creationdate.
                is_funcs-zactive = 'X'.
                is_funcs-active = '3'.
              ENDIF.
            ENDIF.
            MODIFY lt_funcs FROM is_funcs.
          ENDIF.
          CLEAR:is_funcs,ggs_funcs.
        ENDLOOP.
        IF lt_funcs IS NOT INITIAL.
          SELECT customerreturn,
                 customerreturnitem,
                 returnsrefundtype
          FROM i_customerreturnitemenhanced
          FOR ALL ENTRIES IN @lt_funcs
          WHERE customerreturn = @lt_funcs-salesdocument
          AND   customerreturnitem = @lt_funcs-salesdocumentitem
          INTO TABLE @DATA(lt_customer).
          SORT lt_customer BY customerreturn customerreturnitem.
        ENDIF.
        SORT lo_error-d-results BY product.
        DATA(lt_funcss) = lt_funcs.
        DELETE lt_funcss WHERE zactive <> '' OR zwarrantytype <> 'STANDARD'.
        SORT lt_funcss BY material1 serialnumber1 creationdatetime DESCENDING.
        LOOP AT lt_funcs INTO is_funcs WHERE zwarrantytype = 'EXTEND'.
          READ TABLE lt_funcss INTO DATA(ls_funcss) WITH KEY material1 = is_funcs-material1
                                                             serialnumber1 = is_funcs-serialnumber1 BINARY SEARCH.
          IF sy-subrc = 0.
            ls_funcss-zactive = 'X'.
            ls_funcss-active = '3'.
            MODIFY lt_funcs FROM ls_funcss TRANSPORTING zactive active WHERE serialnumber1 = ls_funcss-serialnumber1 AND salesdocument = ls_funcss-salesdocument
            AND salesdocumentitem = ls_funcss-salesdocumentitem AND material1 = ls_funcss-material1.
          ENDIF.
          CLEAR:ls_funcss.
        ENDLOOP.
        LOOP AT lt_funcs INTO is_funcs.
          READ TABLE lo_error-d-results INTO DATA(ls_results) WITH KEY product = is_funcs-material1 BINARY SEARCH.
          IF sy-subrc = 0.
            is_funcs-salesdocumentitemtext = ls_results-longtext.
          ENDIF.
*          IF ( is_funcs-zwarrantytype = 'EXTEND' AND ( is_funcs-salesdocumenttype = 'G2' OR is_funcs-salesdocumenttype = 'CBAR' ) AND is_funcs-zactive = 'X' ).
*            is_funcs-zactive = 'E'.
*            is_funcs-active = '1'.
*          ENDIF.
*          IF ( is_funcs-zwarrantytype = 'STANDARD' AND ( is_funcs-salesdocumenttype = 'G2' OR is_funcs-salesdocumenttype = 'CBAR' ) AND is_funcs-zactive = 'X' ).
*            is_funcs-zactive = ''.
*            is_funcs-active = '2'.
*          ENDIF.
          IF is_funcs-salesdocumenttype = 'CBAR'.
            READ TABLE lt_customer INTO DATA(ls_customer) WITH KEY customerreturn = is_funcs-salesdocument
                                                                   customerreturnitem = is_funcs-salesdocumentitem BINARY SEARCH.
            IF sy-subrc = 0.
              IF ls_customer-returnsrefundtype = '1'.
                is_funcs-zactive = ''.
                is_funcs-active = '2'.
              ELSEIF ls_customer-returnsrefundtype = ''.
                is_funcs-zactive = 'E'.
                is_funcs-active = '1'.
              ENDIF.
            ENDIF.
          ENDIF.
          IF (  is_funcs-salesdocumenttype = 'G2' OR is_funcs-salesdocumenttype = 'GA2' ).
            is_funcs-zactive = 'E'.
            is_funcs-active = '1'.
          ENDIF.
          MODIFY lt_funcs FROM is_funcs.
          CLEAR:is_funcs,ls_results.
        ENDLOOP.
        DATA(lt_funcs_copy) = lt_funcs.
        LOOP AT lt_funcs INTO is_funcs WHERE salesdocumenttype = 'G2'.
          LOOP AT lt_funcs_copy INTO DATA(ls_funcs_copy) WHERE zwarrantymaterial = is_funcs-material1 AND serialnumber1 = is_funcs-serialnumber1.
            IF ls_funcs_copy-creationdate < is_funcs-creationdate.
              ls_funcs_copy-zactive = 'S'.
              ls_funcs_copy-active = '1'.
              MODIFY lt_funcs FROM ls_funcs_copy TRANSPORTING zactive active WHERE uuid = ls_funcs_copy-uuid AND salesdocument = ls_funcs_copy-salesdocument AND salesdocumentitem = ls_funcs_copy-salesdocumentitem.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
        DATA(gt_funcs) = lt_funcs.
        DELETE gt_funcs WHERE salesdocumenttype <> 'TA'.
        SORT gt_funcs BY material1 serialnumber1 zwarrantyvalidfrom.
        LOOP AT lt_funcs INTO DATA(ls_funcs).
*    CLEAR:ls_funcs-zactive.
*          IF ls_funcs-salesdocumenttype = 'TA' AND ls_funcs-zwarrantytype = 'EXTEND'.
*            READ TABLE gt_funcs INTO DATA(gs_funcs) WITH KEY material1 = ls_funcs-material1
*                                                             serialnumber1 = ls_funcs-serialnumber1 BINARY SEARCH.
*            IF sy-subrc = 0.
*              DATA:lv_date TYPE REF TO if_xco_cp_tm_date.
*              IF gs_funcs-ZWarrantyValidFrom IS NOT INITIAL.
*                lv_date = xco_cp_time=>date( iv_year = gs_funcs-zwarrantyvalidfrom+0(4)
*                                             iv_month = gs_funcs-zwarrantyvalidfrom+4(2)
*                                             iv_day  = gs_funcs-zwarrantyvalidfrom+6(2) ).
*                lv_date = lv_date->add( iv_month = gs_funcs-zwarrantymonths ).
*                ls_funcs-zwarrantyvalidto = lv_date->as( xco_cp_time=>format->abap )->value.
*              ENDIF.
*            ENDIF.
**********************************************************************
*calculate the validto of warranty report where salesdocumenttype equal to 'SD2' or 'CR'
**********************************************************************
          IF ( ls_funcs-salesdocumenttype = 'SD2' )." OR ls_funcs-salesdocumenttype = 'G2' )." OR ls_funcs-zwarrantytype = 'EXTEND'.
            READ TABLE gt_funcs INTO DATA(gs_funcs) WITH KEY material1 = ls_funcs-material1
                                                       serialnumber1 = ls_funcs-serialnumber2 BINARY SEARCH.
            IF sy-subrc = 0.
              DATA:lv_date1 TYPE REF TO if_xco_cp_tm_date.
              IF gs_funcs-zwarrantyvalidfrom IS NOT INITIAL.
                lv_date1 = xco_cp_time=>date( iv_year = gs_funcs-zwarrantyvalidfrom+0(4)
                                              iv_month = gs_funcs-zwarrantyvalidfrom+4(2)
                                              iv_day  = gs_funcs-zwarrantyvalidfrom+6(2) ).
*                lv_date1 = lv_date1->add( iv_month = ls_funcs-zwarrantymonths ).
                lv_date1 = lv_date1->add( iv_day = ls_funcs-zwarrantymonths ).
                ls_funcs-zwarrantyvalidto = lv_date1->as( xco_cp_time=>format->abap )->value.
              ENDIF.
            ENDIF.
          ENDIF.

          TRY.
              ls_funcs-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
          MODIFY lt_funcs FROM ls_funcs.
          CLEAR:ls_funcs,gs_funcs,lv_date1.
        ENDLOOP.
*    DATA(lt_serial) = lt_funcs.
*    DELETE ADJACENT DUPLICATES FROM lt_serial COMPARING serialnumber1.
*    DATA(lt_serialorder) = lt_funcs.
*    DELETE ADJACENT DUPLICATES FROM lt_serialorder COMPARING serialnumber1 salesdocumenttype.
*    SORT lt_funcs BY serialnumber1 ASCENDING creationdatetime DESCENDING.
*   LOOP AT lt_serial INTO DATA(ls_serial).
*        DATA:lv_flag TYPE int1.
*        CLEAR:lv_flag.
*         lv_flag = 1.
*        LOOP AT lt_serialorder INTO DATA(ls_serialorder) WHERE serialnumber1 = ls_serial-serialnumber1.
*            lv_flag = lv_flag + 1.
*            IF lv_flag > 1.
*              RETURN.
*            ELSE.
*              IF ls_serialorder-salesdocumenttype = 'OR'.
*                ls_serialorder-zactive = 'X'.
*              ENDIF.
*            ENDIF.
*            MODIFY lt_serialorder FROM ls_serialorder.
*        ENDLOOP.
*        ls_serial-zactive = 'X'.
*        MODIFY lt_serial FROM ls_serial.
*    ENDLOOP.
*    DELETE lt_serialorder WHERE zactive <> 'X'.
*   SORT lt_serialorder BY serialnumber1.
*    LOOP AT lt_serial INTO ls_serial.
*        READ TABLE lt_funcs INTO ls_funcs WITH KEY serialnumber1 = ls_serial-serialnumber1 BINARY SEARCH.
*        IF sy-subrc = 0.
*          ls_funcs-zactive = 'X'.
*        ENDIF.
*        MODIFY lt_funcs FROM ls_funcs TRANSPORTING zactive.
*    ENDLOOP.
*    LOOP AT lt_funcs INTO ls_funcs.
*        READ TABLE lt_serialorder INTO ls_serialorder WITH KEY serialnumber1 = ls_funcs-serialnumber1 BINARY SEARCH.
*        IF sy-subrc = 0.
*          ls_funcs-zactive = 'X'.
*        ENDIF.
*        MODIFY lt_funcs FROM ls_funcs.
*    ENDLOOP.
*        CLEAR:gt_funcs.
**********************************************************************
*calculate the validfrom of warranty report where warrantytype is 'EXTEND' and salesdocumenttype is 'OR' or 'SD2'
**********************************************************************
        DATA(gt_funcs1) = lt_funcs.
        DATA(gt_funcs2) = lt_funcs.
        DELETE gt_funcs2 WHERE zactive <> 'X'.
        DELETE gt_funcs2 WHERE zwarrantytype <> 'STANDARD'.
        DELETE gt_funcs1 WHERE zwarrantytype <> 'STANDARD'.
        DELETE gt_funcs1 WHERE zwarrantymaterial <> 'STANDARD WARRANTY-LABOR'.
        DELETE gt_funcs2 WHERE zwarrantymaterial <> 'STANDARD WARRANTY-LABOR'.
        SORT gt_funcs1 BY material1 serialnumber1 salesdocument ASCENDING zwarrantyvalidto DESCENDING.
        SORT gt_funcs2 BY material1 serialnumber1 ASCENDING zwarrantyvalidto DESCENDING.
        LOOP AT lt_funcs INTO ls_funcs.
*          CLEAR:ls_funcs-zactive.
          IF ls_funcs-salesdocumenttype = 'TA' OR ls_funcs-salesdocumenttype = 'SD2'.
            DATA:lv_flag TYPE string.
            IF ls_funcs-zwarrantyvalidfrom IS INITIAL.
              READ TABLE gt_funcs1 INTO DATA(gs_funcs1) WITH KEY material1 = ls_funcs-yy1_warrantymaterial_sdi
                                                                 serialnumber1 = ls_funcs-yy1_warrantyserial_sdi
                                                                 salesdocument = ls_funcs-salesdocument BINARY SEARCH.
              IF sy-subrc = 0.
                DATA:iv_date TYPE REF TO if_xco_cp_tm_date.
                IF gs_funcs1-zwarrantyvalidto IS NOT INITIAL.
                  iv_date = xco_cp_time=>date( iv_year = gs_funcs1-zwarrantyvalidto+0(4)
                                               iv_month = gs_funcs1-zwarrantyvalidto+4(2)
                                               iv_day  = gs_funcs1-zwarrantyvalidto+6(2) ).
                  iv_date = iv_date->add( iv_day = 1 ).
                  ls_funcs-zwarrantyvalidfrom = iv_date->as( xco_cp_time=>format->abap )->value.
                ENDIF.
*              ls_funcs-zwarrantyvalidfrom = gs_funcs1-zwarrantyvalidto.
              ELSE.
                lv_flag = 'X'.
              ENDIF.
              IF lv_flag = 'X'.
                READ TABLE gt_funcs2 INTO DATA(gs_funcs2) WITH KEY material1 = ls_funcs-yy1_warrantymaterial_sdi
                                                                   serialnumber1 = ls_funcs-yy1_warrantyserial_sdi BINARY SEARCH.
                IF sy-subrc = 0.
                  DATA:iv_date1 TYPE REF TO if_xco_cp_tm_date.
                  IF gs_funcs2-zwarrantyvalidto IS NOT INITIAL.
                    iv_date1 = xco_cp_time=>date( iv_year = gs_funcs2-zwarrantyvalidto+0(4)
                                                 iv_month = gs_funcs2-zwarrantyvalidto+4(2)
                                                 iv_day  = gs_funcs2-zwarrantyvalidto+6(2) ).
                    iv_date1 = iv_date1->add( iv_day = 1 ).
                    ls_funcs-zwarrantyvalidfrom = iv_date1->as( xco_cp_time=>format->abap )->value.
                  ENDIF.
*                ls_funcs-zwarrantyvalidfrom = gs_funcs2-zwarrantyvalidto.
                ENDIF.
              ENDIF.
            ENDIF.
            MODIFY lt_funcs FROM ls_funcs.
            CLEAR:lv_flag,gs_funcs1,gs_funcs2,ls_funcs,iv_date,iv_date1.
          ENDIF.
        ENDLOOP.




        gt_funcs = lt_funcs.
        DELETE gt_funcs WHERE salesdocumenttype <> 'TA'.
        SORT gt_funcs BY material1 serialnumber1 zwarrantyvalidfrom.

        DATA(gt_funcss) = lt_funcs.
        DELETE gt_funcss WHERE zwarrantytype <> 'STANDARD'.
        DELETE gt_funcss WHERE zwarrantymaterial <> 'STANDARD WARRANTY-LABOR'.
        DELETE gt_funcs WHERE salesdocumenttype <> 'TA'.
        SORT gt_funcss BY material1 serialnumber1 zwarrantyvalidfrom.

        LOOP AT lt_funcs INTO ls_funcs.

          IF ( ls_funcs-salesdocumenttype = 'SD2' AND ls_funcs-zwarrantytype = 'STANDARD' )." OR ls_funcs-salesdocumenttype = 'G2' )." OR ls_funcs-zwarrantytype = 'EXTEND'.
            READ TABLE gt_funcs INTO gs_funcs  WITH KEY material1 = ls_funcs-material1
                                                        serialnumber1 = ls_funcs-serialnumber2 BINARY SEARCH.
            IF sy-subrc = 0.
              DATA:gv_date1 TYPE REF TO if_xco_cp_tm_date.
              IF gs_funcs-zwarrantyvalidfrom IS NOT INITIAL AND ls_funcs-zwarrantyvalidto IS INITIAL.
                gv_date1 = xco_cp_time=>date( iv_year = gs_funcs-zwarrantyvalidfrom+0(4)
                                              iv_month = gs_funcs-zwarrantyvalidfrom+4(2)
                                              iv_day  = gs_funcs-zwarrantyvalidfrom+6(2) ).
*                lv_date1 = lv_date1->add( iv_month = ls_funcs-zwarrantymonths ).
                gv_date1 = gv_date1->add( iv_day = ls_funcs-zwarrantymonths ).
                ls_funcs-zwarrantyvalidto = gv_date1->as( xco_cp_time=>format->abap )->value.
              ENDIF.
            ENDIF.
          ENDIF.
          IF ( ls_funcs-salesdocumenttype = 'SD2' AND ls_funcs-zwarrantytype = 'EXTEND' )." OR ls_funcs-salesdocumenttype = 'G2' )." OR ls_funcs-zwarrantytype = 'EXTEND'.
            READ TABLE gt_funcss INTO DATA(gs_funcss)  WITH KEY material1 = ls_funcs-material4
                                                                serialnumber1 = ls_funcs-serialnumber2 BINARY SEARCH.
            IF sy-subrc = 0.
              DATA:gv_date11 TYPE REF TO if_xco_cp_tm_date.
              IF gs_funcss-zwarrantyvalidfrom IS NOT INITIAL AND ls_funcs-zwarrantyvalidto IS INITIAL.
                gv_date11 = xco_cp_time=>date( iv_year = gs_funcss-zwarrantyvalidfrom+0(4)
                                               iv_month = gs_funcss-zwarrantyvalidfrom+4(2)
                                               iv_day  = gs_funcss-zwarrantyvalidfrom+6(2) ).
*                lv_date1 = lv_date1->add( iv_month = ls_funcs-zwarrantymonths ).
                gv_date11 = gv_date11->add( iv_day = gs_funcss-zwarrantymonths ).
                gv_date11 = gv_date11->add( iv_day = 1 ).
                gv_date11 = gv_date11->add( iv_day = ls_funcs-zwarrantymonths ).
                ls_funcs-zwarrantyvalidto = gv_date11->as( xco_cp_time=>format->abap )->value.
              ENDIF.
            ENDIF.
          ENDIF.

          TRY.
              ls_funcs-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
          MODIFY lt_funcs FROM ls_funcs.
          CLEAR:ls_funcs,gs_funcs,gv_date1.
        ENDLOOP.

        DATA(gt_funcs11) = lt_funcs.
        DATA(gt_funcs22) = lt_funcs.
        DELETE gt_funcs22 WHERE zactive <> 'X'.
        DELETE gt_funcs22 WHERE zwarrantytype <> 'STANDARD'.
        DELETE gt_funcs11 WHERE zwarrantytype <> 'STANDARD'.
        DELETE gt_funcs11 WHERE zwarrantymaterial <> 'STANDARD WARRANTY-LABOR'.
        DELETE gt_funcs22 WHERE zwarrantymaterial <> 'STANDARD WARRANTY-LABOR'.
        SORT gt_funcs11 BY material1 serialnumber1 salesdocument ASCENDING zwarrantyvalidto DESCENDING.
        SORT gt_funcs22 BY material1 serialnumber1 ASCENDING zwarrantyvalidto DESCENDING.
        LOOP AT lt_funcs INTO ls_funcs.
*          CLEAR:ls_funcs-zactive.
          IF ls_funcs-salesdocumenttype = 'TA' OR ls_funcs-salesdocumenttype = 'SD2'.
            DATA:lv_flag1 TYPE string.
            IF ls_funcs-zwarrantyvalidfrom IS INITIAL.
              READ TABLE gt_funcs11 INTO DATA(gs_funcs11) WITH KEY material1 = ls_funcs-yy1_warrantymaterial_sdi
                                                                 serialnumber1 = ls_funcs-yy1_warrantyserial_sdi
                                                                 salesdocument = ls_funcs-salesdocument BINARY SEARCH.
              IF sy-subrc = 0.
                DATA:iv_date11 TYPE REF TO if_xco_cp_tm_date.
                IF gs_funcs11-zwarrantyvalidto IS NOT INITIAL.
                  iv_date11 = xco_cp_time=>date( iv_year = gs_funcs11-zwarrantyvalidto+0(4)
                                               iv_month = gs_funcs11-zwarrantyvalidto+4(2)
                                               iv_day  = gs_funcs11-zwarrantyvalidto+6(2) ).
                  iv_date11 = iv_date11->add( iv_day = 1 ).
                  ls_funcs-zwarrantyvalidfrom = iv_date11->as( xco_cp_time=>format->abap )->value.
                ENDIF.
*              ls_funcs-zwarrantyvalidfrom = gs_funcs1-zwarrantyvalidto.
              ELSE.
                lv_flag = 'X'.
              ENDIF.
              IF lv_flag = 'X'.
                READ TABLE gt_funcs22 INTO DATA(gs_funcs22) WITH KEY material1 = ls_funcs-yy1_warrantymaterial_sdi
                                                                   serialnumber1 = ls_funcs-yy1_warrantyserial_sdi BINARY SEARCH.
                IF sy-subrc = 0.
                  DATA:iv_date12 TYPE REF TO if_xco_cp_tm_date.
                  IF gs_funcs22-zwarrantyvalidto IS NOT INITIAL.
                    iv_date12 = xco_cp_time=>date( iv_year = gs_funcs22-zwarrantyvalidto+0(4)
                                                 iv_month = gs_funcs22-zwarrantyvalidto+4(2)
                                                 iv_day  = gs_funcs22-zwarrantyvalidto+6(2) ).
                    iv_date12 = iv_date12->add( iv_day = 1 ).
                    ls_funcs-zwarrantyvalidfrom = iv_date12->as( xco_cp_time=>format->abap )->value.
                  ENDIF.
*                ls_funcs-zwarrantyvalidfrom = gs_funcs2-zwarrantyvalidto.
                ENDIF.
              ENDIF.
            ENDIF.
            MODIFY lt_funcs FROM ls_funcs.
            CLEAR:lv_flag,gs_funcs1,gs_funcs2,ls_funcs,iv_date,iv_date1.
          ENDIF.
        ENDLOOP.
**********************************************************************
*calculate the validfrom of warranty report where warrantytype is 'EXTEND' and salesdocumenttype is 'DR'
**********************************************************************
        DATA(gt_funcs4) = lt_funcs.
        DATA(gt_funcs5) = lt_funcs.
*        DELETE gt_funcs5 WHERE zactive <> 'X'.
        DELETE gt_funcs5 WHERE salesdocumenttype <> 'TA'.
        DELETE gt_funcs5 WHERE zwarrantytype <> 'STANDARD'.
        DELETE gt_funcs4 WHERE zwarrantytype <> 'STANDARD'.
        DELETE gt_funcs4 WHERE zwarrantymaterial <> 'STANDARD WARRANTY-LABOR'.
        DELETE gt_funcs5 WHERE zwarrantymaterial <> 'STANDARD WARRANTY-LABOR'.
        SORT gt_funcs4 BY material1 serialnumber1 salesdocument ASCENDING zwarrantyvalidto DESCENDING.
        SORT gt_funcs5 BY material1 serialnumber1 ASCENDING zwarrantyvalidto DESCENDING.
        LOOP AT lt_funcs INTO ls_funcs.
*          CLEAR:ls_funcs-zactive.
          IF ls_funcs-salesdocumenttype = 'L2'.
*          DATA:lv_flag1 TYPE string.
            IF ls_funcs-zwarrantyvalidfrom IS INITIAL.
*            READ TABLE gt_funcs4 INTO DATA(gs_funcs4) WITH KEY material1 = ls_funcs-yy1_warrantymaterial_sdi
*                                                               serialnumber1 = ls_funcs-yy1_warrantyserial_sdi
*                                                               salesdocument = ls_funcs-salesdocument BINARY SEARCH.
*            IF sy-subrc = 0.
*              DATA:iv_date5 TYPE REF TO if_xco_cp_tm_date.
*              IF gs_funcs4-zwarrantyvalidto IS NOT INITIAL.
*                iv_date5 = xco_cp_time=>date( iv_year = gs_funcs4-zwarrantyvalidto+0(4)
*                                             iv_month = gs_funcs4-zwarrantyvalidto+4(2)
*                                             iv_day  = gs_funcs4-zwarrantyvalidto+6(2) ).
*                iv_date5 = iv_date5->add( iv_day = 1 ).
*                ls_funcs-zwarrantyvalidfrom = iv_date5->as( xco_cp_time=>format->abap )->value.
*              ENDIF.
**              ls_funcs-zwarrantyvalidfrom = gs_funcs4-zwarrantyvalidto.
*            ELSE.
*              lv_flag1 = 'X'.
*            ENDIF.
*            IF lv_flag1 = 'X'.
              DATA(gt_funcs6) = gt_funcs5.
              DELETE gt_funcs6 WHERE creationdate > ls_funcs-creationdate.
              READ TABLE gt_funcs6 INTO DATA(gs_funcs6) WITH KEY material1 = ls_funcs-yy1_warrantymaterial_sdi
                                                                 serialnumber1 = ls_funcs-yy1_warrantyserial_sdi BINARY SEARCH.
              IF sy-subrc = 0.
                DATA:iv_date6 TYPE REF TO if_xco_cp_tm_date.
                IF gs_funcs6-zwarrantyvalidto IS NOT INITIAL.
                  iv_date6 = xco_cp_time=>date( iv_year = gs_funcs6-zwarrantyvalidto+0(4)
                                               iv_month = gs_funcs6-zwarrantyvalidto+4(2)
                                               iv_day  = gs_funcs6-zwarrantyvalidto+6(2) ).
                  iv_date6 = iv_date6->add( iv_day = 1 ).
                  ls_funcs-zwarrantyvalidfrom = iv_date6->as( xco_cp_time=>format->abap )->value.
                  iv_date6 = iv_date6->add( iv_day = ls_funcs-zwarrantymonths ).
                  ls_funcs-zwarrantyvalidto = iv_date6->as( xco_cp_time=>format->abap )->value.
                ENDIF.
*                ls_funcs-zwarrantyvalidfrom = gs_funcs5-zwarrantyvalidto.
              ENDIF.
*            ENDIF.
            ENDIF.
            MODIFY lt_funcs FROM ls_funcs.
            CLEAR:gs_funcs6,ls_funcs,iv_date6.
*          CLEAR:lv_flag1,gs_funcs4,gs_funcs5,ls_funcs,iv_date5,iv_date6.
          ENDIF.
        ENDLOOP.
**********************************************************************
*calculate validto of warranty report where salesdocumenttype is 'TA' and warrantytype is 'EXTEND'
**********************************************************************
        CLEAR:gt_funcs.
        gt_funcs = lt_funcs.
        DELETE gt_funcs WHERE zwarrantytype = 'EXTEND'.
        SORT gt_funcs BY material1 serialnumber1 zwarrantyvalidfrom.
        LOOP AT lt_funcs INTO ls_funcs.
          IF ( ls_funcs-salesdocumenttype = 'TA' ) AND ls_funcs-zwarrantytype = 'EXTEND'.
*            READ TABLE gt_funcs INTO gs_funcs WITH KEY material1 = ls_funcs-material1
*                                                       serialnumber1 = ls_funcs-serialnumber1 BINARY SEARCH.
*            IF sy-subrc = 0.
            DATA:lv_date TYPE REF TO if_xco_cp_tm_date.
            IF ls_funcs-zwarrantyvalidfrom IS NOT INITIAL.
              lv_date = xco_cp_time=>date( iv_year = ls_funcs-zwarrantyvalidfrom+0(4)
                                           iv_month = ls_funcs-zwarrantyvalidfrom+4(2)
                                           iv_day  = ls_funcs-zwarrantyvalidfrom+6(2) ).
              lv_date = lv_date->add( iv_day = ls_funcs-zwarrantymonths ).
              ls_funcs-zwarrantyvalidto = lv_date->as( xco_cp_time=>format->abap )->value.
            ENDIF.
*            ENDIF.
          ENDIF.

          TRY.
              ls_funcs-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
              "handle exception
          ENDTRY.
          MODIFY lt_funcs FROM ls_funcs.
          CLEAR:ls_funcs,lv_date.
        ENDLOOP.
*        DELETE gt_funcs WHERE salesdocumenttype = 'TA'.
*        SORT gt_funcs BY material1 serialnumber1.
*        LOOP AT lt_funcs INTO ls_funcs.
*        IF ls_funcs-zwarrantytype = 'EXTEND' AND ls_funcs-salesdocumenttype = 'TA'.
*            READ TABLE gt_funcs INTO gs_funcs WITH KEY material1 = ls_funcs-material1
*                                                       serialnumber1 = ls_funcs-serialnumber1 BINARY SEARCH.
*            IF sy-subrc <> 0.
*              ls_funcs-active = '3'.
*            ENDIF.
*            MODIFY lt_funcs FROM ls_funcs.
*        ENDIF.
*        ENDLOOP.
        SORT lt_funcs BY salesdocument DESCENDING salesdocumentitem ASCENDING.
        DELETE lt_funcs WHERE serialnumber1 EQ '' AND yy1_warrantyserial_sdi EQ ''.
**********************************************************************
*set the valid from when copy 'CBAR' is initial
**********************************************************************
*        DATA(lt_funcs_rr2) = lt_funcs.
*        DELETE lt_funcs_rr2 WHERE salesdocumenttype <> 'TA' AND salesdocumenttype <> 'L2'.
*        DELETE lt_funcs_rr2 WHERE zwarrantytype <> 'EXTEND'.
*        SORT lt_funcs_rr2 BY material1 serialnumber1 creationdate DESCENDING.
*        LOOP AT lt_funcs INTO ls_funcs WHERE salesdocumenttype = 'CBAR'.
*          IF ls_funcs-zwarrantyvalidfrom IS INITIAL.
*            READ TABLE lt_funcs_rr2 INTO DATA(ls_funcs_rr2) WITH KEY material1 = ls_funcs-material4
*                                                                     serialnumber1 = ls_funcs-serialnumber2 BINARY SEARCH.
*            IF sy-subrc = 0.
*              ls_funcs-zwarrantyvalidfrom = ls_funcs_rr2-zwarrantyvalidfrom.
*              ls_funcs-material4 = 'N/A'.
*              ls_funcs-serialnumber2 = 'N/A'.
*              MODIFY lt_funcs FROM ls_funcs.
*            ENDIF.
*          ENDIF.
*          CLEAR:ls_funcs,ls_funcs_rr2.
*        ENDLOOP.
**********************************************************************
*when salesdocumenttype is 'CR' and salesdocumentitemcategory is 'TAX',
*if we can find a 'TA' order by using the salesdocument and salesdocumentitem
*of 'CR' order equal to referencesddocument and referencesddocumentitem
* of 'TA' order,set the ative of 'TA' order to red light
**********************************************************************
        gt_funcs = lt_funcs.
*        SORT gt_funcs BY salesdocument salesdocumentitem.
*        LOOP AT lt_funcs INTO ls_funcs.
*          IF ls_funcs-salesdocumenttype = 'CR' AND ls_funcs-salesdocumentitemcategory = 'TAX'.
*            READ TABLE gt_funcs INTO gs_funcs WITH KEY salesdocument = ls_funcs-referencesddocument
*                                                       salesdocumentitem = ls_funcs-referencesddocumentitem BINARY SEARCH.
*            IF sy-subrc = 0.
*              IF ls_funcs-zwarrantytype = 'EXTEND' AND ls_funcs-material1 = gs_funcs-material1 AND ls_funcs-serialnumber1 = gs_funcs-yy1_warrantyserial_sdi.
*                gs_funcs-zactive = 'E'.
*                gs_funcs-active = '1'.
*                MODIFY lt_funcs FROM gs_funcs TRANSPORTING zactive active WHERE uuid = gs_funcs-uuid AND salesdocument = gs_funcs-salesdocument AND salesdocumentitem = gs_funcs-salesdocumentitem.
*              ENDIF.
*            ENDIF.
*          ENDIF.
*        ENDLOOP.

        DATA(gt_funcs3) = lt_funcs.
        DELETE gt_funcs3 WHERE salesdocumenttype <> 'CBAR' AND zactive <> 'E'.
        DELETE gt_funcs3 WHERE zactive IS INITIAL.
        SORT gt_funcs3 BY referencesddocument referencesddocumentitem material1 serialnumber1.
        DELETE gt_funcs3 WHERE referencesddocument IS INITIAL OR referencesddocumentitem IS INITIAL.
        LOOP AT lt_funcs INTO ls_funcs WHERE zwarrantytype = 'STANDARD'.
          READ TABLE gt_funcs3 INTO DATA(gs_funcs3) WITH KEY referencesddocument = ls_funcs-subsequentdocument2
                                                             referencesddocumentitem = ls_funcs-subsequentdocumentitem2
                                                             material1 = ls_funcs-material1
                                                             serialnumber1 = ls_funcs-serialnumber1 BINARY SEARCH.
          IF sy-subrc = 0.
            ls_funcs-zactive = 'E'.
            ls_funcs-active = '1'.
            MODIFY lt_funcs FROM ls_funcs.
          ENDIF.
        ENDLOOP.
        DATA(gt_funcs_cr) = lt_funcs.
        DELETE gt_funcs_cr WHERE salesdocumenttype <> 'G2' AND zactive <> 'E'.
        DELETE gt_funcs_cr WHERE zactive IS INITIAL.
        SORT gt_funcs_cr BY referencesddocument referencesddocumentitem material1 serialnumber1.
        DELETE gt_funcs_cr WHERE referencesddocument IS INITIAL OR referencesddocumentitem IS INITIAL.
        LOOP AT lt_funcs INTO ls_funcs WHERE zwarrantytype = 'EXTEND'.
          READ TABLE gt_funcs_cr INTO DATA(gs_funcs_cr) WITH KEY referencesddocument = ls_funcs-subsequentdocument2
                                                             referencesddocumentitem = ls_funcs-subsequentdocumentitem2
                                                             material1 = ls_funcs-material1
                                                             serialnumber1 = ls_funcs-serialnumber1 BINARY SEARCH.
          IF sy-subrc = 0.
            ls_funcs-zactive = 'E'.
            ls_funcs-active = '1'.
            MODIFY lt_funcs FROM ls_funcs.
          ENDIF.
        ENDLOOP.
        SORT gt_funcs BY subsequentdocument2 subsequentdocumentitem2.

        IF lt_funcs IS NOT INITIAL.
**********************************************************************
*if salesdocumenttype is 'CBAR',the warranty report need to add a new extend line,
*data of new line need to be obtained from the i_billingdocumentitem where it's billingdocument
*equal to subsequentdocument2(referencesddocument of 'CBAR' order) and salesdocumentitemxategory = 'TAX'
*if YY1_WarrantyMaterial_BDI of i_billingdocumentitem equal to material of 'CBAR' order and
*YY1_WarrantySerial_BDI of i_billingdocumentitem equal to serial1 of 'CBAR' order,
*add new extend line and set billingdocumentitem and material to billingdocumentitem and material of i_billingdocumentitem,
*set warrantytype to 'EXTEND',Other data details can be found in the specific code
**********************************************************************
          SELECT billingdocument,
                 billingdocumentitem,
                 salesdocumentitemcategory,
                 yy1_warrantymaterial_bdi,
                 yy1_warrantyserial_bdi,
                 product
          FROM i_billingdocumentitem
          FOR ALL ENTRIES IN @lt_funcs
          WHERE billingdocument = @lt_funcs-subsequentdocument2
*        AND   billingdocumentitem = @lt_funcs-subsequentdocumentitem2
          INTO TABLE @DATA(lt_billingdi).
**********************************************************************
*when the 'TA' order can find a data in i_salesdocitmsubsqntprocflow where
*salesdocument and salesdocumentitem  equal to salesdocument and salesdocumentitem
*of 'TA' order and subsequentdocumentcategory equal to 'O'
*set active of 'TA' order to red light
**********************************************************************
          SELECT salesdocument,
                 salesdocumentitem
          FROM i_salesdocitmsubsqntprocflow
          FOR ALL ENTRIES IN @lt_funcs
          WHERE salesdocument = @lt_funcs-salesdocument
          AND   salesdocumentitem = @lt_funcs-salesdocumentitem
          AND   subsequentdocumentcategory = 'O'
          INTO TABLE @DATA(lt_salesdiflow).
          SORT lt_salesdiflow BY salesdocument salesdocumentitem.
        ENDIF.
        DATA(ltt_funcs) = lt_funcs.
        DELETE ADJACENT DUPLICATES FROM ltt_funcs COMPARING salesdocument serialnumber1.
*        LOOP AT ltt_funcs INTO DATA(lss_funcs).
*          IF lss_funcs-salesdocumenttype = 'CBAR'.
*            LOOP AT lt_billingdi INTO DATA(ls_billingdi)." WHERE billingdocument = ls_funcs-referencesddocument AND billingdocumentitem = ls_funcs-referencesddocumentitem.
*              IF ls_billingdi-billingdocument = lss_funcs-referencesddocument AND ls_billingdi-salesdocumentitemcategory = 'TAX'.
*                IF lss_funcs-material1 = ls_billingdi-yy1_warrantymaterial_bdi AND lss_funcs-serialnumber1 = ls_billingdi-yy1_warrantyserial_bdi.
*                  CLEAR:ls_funcs.
*                  ls_funcs-salesdocumentitem = ls_billingdi-billingdocumentitem.
*                  ls_funcs-zwarrantymaterial = ls_billingdi-product.
*                  ls_funcs-zwarrantytype = 'EXTEND'.
*                  ls_funcs-salesdocumenttype = lss_funcs-salesdocumenttype.
*                  ls_funcs-material1 = lss_funcs-material1.
*                  ls_funcs-serialnumber1 = lss_funcs-serialnumber1.
*                  ls_funcs-zoldserialnumber = lss_funcs-zoldserialnumber.
*                  ls_funcs-zwarrantyvalidfrom = lss_funcs-zwarrantyvalidfrom.
*                  ls_funcs-zwarrantyvalidto = lss_funcs-zwarrantyvalidto.
*                  ls_funcs-zactive = lss_funcs-zactive.
*                  ls_funcs-active = lss_funcs-active.
*                  ls_funcs-salesdocument = lss_funcs-salesdocument.
*                  ls_funcs-shiptoparty = lss_funcs-shiptoparty.
*                  ls_funcs-fullname2 = lss_funcs-fullname2.
*                  ls_funcs-referencesddocument = lss_funcs-referencesddocument.
*                  ls_funcs-referencesddocumentcategory = lss_funcs-referencesddocumentcategory.
*                  ls_funcs-referencesddocumentitem = lss_funcs-referencesddocumentitem.
*                  ls_funcs-salesdocumentitemtext = 'N/A'.
*                  ls_funcs-yy1_warrantymaterial_sdi = 'N/A'.
*                  ls_funcs-yy1_warrantyserial_sdi = 'N/A'.
*                  ls_funcs-purchaseorderbycustomer = 'N/A'.
*                  ls_funcs-soldtoparty = 'N/A'.
*                  ls_funcs-fullname1 = 'N/A'.
*                  ls_funcs-subsequentdocument1 = 'N/A'.
*                  ls_funcs-subsequentdocumentitem1 = 'N/A'.
*                  ls_funcs-material2 = 'N/A'.
*                  ls_funcs-deliverydocumenttype = 'N/A'.
*                  ls_funcs-subsequentdocument2 = 'N/A'.
*                  ls_funcs-subsequentdocumentitem2 = 'N/A'.
*                  ls_funcs-material3 = 'N/A'.
*                  ls_funcs-billingdocumenttype = 'N/A'.
*                  ls_funcs-referencesddocumentcategory = 'N/A'.
*                  TRY.
*                      ls_funcs-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
*                    CATCH cx_uuid_error.
*                      "handle exception
*                  ENDTRY.
*                  APPEND ls_funcs TO lt_funcs.
*                ENDIF.
*              ENDIF.
*            ENDLOOP.
*          ENDIF.
*        ENDLOOP.
*        LOOP AT lt_funcs INTO ls_funcs.
*          IF ls_funcs-salesdocumenttype = 'TA' AND ls_funcs-zwarrantytype = 'EXTEND'." AND ls_funcs-zactive = 'X'.
*            READ TABLE lt_salesdiflow INTO DATA(ls_salesdiflow) WITH KEY salesdocument = ls_funcs-salesdocument
*                                                                         salesdocumentitem = ls_funcs-salesdocumentitem BINARY SEARCH.
*            IF sy-subrc = 0.
*              ls_funcs-zactive = 'E'.
*              ls_funcs-active = '1'.
*              MODIFY lt_funcs FROM ls_funcs.
*            ENDIF.
*          ENDIF.
*        ENDLOOP.
**********************************************************************
*when salesdocumenttype is 'CBAR' and warrantytype is 'EXTEND',if we can find
*a data where it's salesdocumenttype is 'TA' and warrantytype is 'EXTEND' and
*active is red light('E') and it's referencesddocument and yy1_warrantymaterial_sdi
*and yy1_warrantyserial_sdi is equal to subsequentdocument2 and material1 and serialnumber1,
*set active of 'CBAR' order to red light
**********************************************************************
*        CLEAR:gt_funcs.
*        gt_funcs = lt_funcs.
*        DELETE gt_funcs WHERE salesdocumenttype <> 'TA' OR zwarrantytype <> 'EXTEND' OR zactive <> 'E'.
*        SORT lt_funcs BY subsequentdocument2." subsequentdocumentitem2.
*        LOOP AT lt_funcs INTO ls_funcs.
*          IF ls_funcs-salesdocumenttype = 'CBAR' AND ls_funcs-zwarrantytype = 'EXTEND'.
**            READ TABLE gt_funcs INTO gs_funcs WITH KEY referencesddocument = ls_funcs-subsequentdocument2 BINARY SEARCH.
**                                                       "referencesddocumentitem = ls_funcs-subsequentdocumentitem2 BINARY SEARCH.
**            IF sy-subrc = 0.
*            LOOP AT gt_funcs INTO gs_funcs.
*              IF gs_funcs-referencesddocument = ls_funcs-subsequentdocument2 AND gs_funcs-yy1_warrantymaterial_sdi = ls_funcs-material1 AND gs_funcs-yy1_warrantyserial_sdi = ls_funcs-serialnumber1.
*                ls_funcs-zactive = 'E'.
*                ls_funcs-active = '1'.
*                MODIFY lt_funcs FROM ls_funcs.
*              ENDIF.
*            ENDLOOP.
*          ENDIF.
*        ENDLOOP.
*        CLEAR:gt_funcs,ltt_funcs.



**********************************************************************
*copy 'EXTEND' line of 'CBAR' order to 'SD2' order where referencesddocument
*of 'SD2' order is equal to salesdocument of 'CBAR' order,copy follow data from
*'SD2' order,all other data comes from 'CBAR' order
**********************************************************************
        gt_funcs = lt_funcs.
        ltt_funcs = lt_funcs.
        DELETE gt_funcs WHERE zwarrantytype <> 'EXTEND' OR salesdocumenttype <> 'CBAR'.
        DELETE ADJACENT DUPLICATES FROM ltt_funcs COMPARING salesdocument serialnumber1.
        DELETE ltt_funcs WHERE salesdocumenttype <> 'SD2'.
        SORT ltt_funcs BY referencesddocument.
*        SORT gt_funcs BY referencesddocument.
*        LOOP AT ltt_funcs INTO lss_funcs.
*          IF lss_funcs-salesdocumenttype = 'SD2'.
*            READ TABLE gt_funcs INTO gs_funcs WITH KEY salesdocument = lss_funcs-referencesddocument BINARY SEARCH.
*            IF sy-subrc = 0.
*              TRY.
*                  gs_funcs-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
*                CATCH cx_uuid_error.
*                  "handle exception
*              ENDTRY.
*              gs_funcs-serialnumber1 = lss_funcs-serialnumber1.
*              gs_funcs-salesdocument = lss_funcs-salesdocument.
*              gs_funcs-salesdocumenttype = lss_funcs-salesdocumenttype.
*              gs_funcs-referencesddocument = lss_funcs-referencesddocument.
*              gs_funcs-referencesddocumentitem = lss_funcs-referencesddocumentitem.
*              gs_funcs-referencesddocumentcategory = lss_funcs-referencesddocumentcategory.
*              APPEND gs_funcs TO lt_funcs.
*            ENDIF.
*          ENDIF.
*        ENDLOOP.
*        LOOP AT gt_funcs INTO gs_funcs.
*          READ TABLE ltt_funcs INTO lss_funcs WITH KEY referencesddocument = gs_funcs-salesdocument BINARY SEARCH.
*          IF sy-subrc = 0.
*            TRY.
*                gs_funcs-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
*              CATCH cx_uuid_error.
*                "handle exception
*            ENDTRY.
*            gs_funcs-serialnumber1 = lss_funcs-serialnumber1.
*            gs_funcs-salesdocument = lss_funcs-salesdocument.
*            gs_funcs-salesdocumenttype = lss_funcs-salesdocumenttype.
*            gs_funcs-referencesddocument = lss_funcs-referencesddocument.
*            gs_funcs-referencesddocumentitem = lss_funcs-referencesddocumentitem.
*            gs_funcs-referencesddocumentcategory = lss_funcs-referencesddocumentcategory.
*            APPEND gs_funcs TO lt_funcs.
*          ENDIF.
*        ENDLOOP.
        IF lt_funcs IS NOT INITIAL.
          SELECT  salesdocumenttype,
                  salesdocumenttypelangdepdnt
          FROM i_salesdocumenttypelangdepdnt
          FOR ALL ENTRIES IN @lt_funcs
          WHERE salesdocumenttype = @lt_funcs-salesdocumenttype
          AND language = 'E'
          INTO TABLE @DATA(lt_salesdocumenttype).
          SORT lt_salesdocumenttype BY salesdocumenttype.
        ENDIF.
        DATA(itt_funcs) = lt_funcs.
        DELETE itt_funcs WHERE salesdocumenttype <> 'CBAR'.
        IF itt_funcs IS NOT INITIAL.
          SELECT referencesddocument,
                 referencesddocumentitem,
                 salesdocument,
                 salesdocumentitem
          FROM i_salesdocumentitem
          FOR ALL ENTRIES IN @itt_funcs
          WHERE referencesddocument = @itt_funcs-salesdocument
          AND   referencesddocumentitem = @itt_funcs-salesdocumentitem
          AND   sddocumentcategory = 'I'
          INTO TABLE @DATA(lt_salesdocumentitem).
          SORT lt_salesdocumentitem BY referencesddocument referencesddocumentitem.
        ENDIF.
        IF lt_salesdocumentitem IS NOT INITIAL.
          SELECT  salesdocument,
                  salesdocumentitem,
                  subsequentdocument,
                  subsequentdocumentitem
          FROM i_salesdocitmsubsqntprocflow
          FOR ALL ENTRIES IN @lt_salesdocumentitem
          WHERE salesdocument = @lt_salesdocumentitem-salesdocument
          AND   salesdocumentitem = @lt_salesdocumentitem-salesdocumentitem
          AND   subsequentdocumentcategory = 'M'
          INTO TABLE @DATA(lt_subflow).
          SORT lt_subflow BY salesdocument salesdocumentitem.
          IF lt_subflow IS NOT INITIAL.
            SELECT billingdocument,
                   accountingdocument,
                   fiscalyear,
                   companycode
            FROM i_billingdocumentbasic
            FOR ALL ENTRIES IN @lt_subflow
            WHERE billingdocument = @lt_subflow-subsequentdocument
            INTO TABLE @DATA(lt_billingbasic).
            SORT lt_billingbasic BY billingdocument.
            IF lt_billingbasic IS NOT INITIAL.
              SELECT accountingdocument,
                     fiscalyear,
                     companycode,
                     postingdate
              FROM i_journalentry
              FOR ALL ENTRIES IN @lt_billingbasic
              WHERE accountingdocument = @lt_billingbasic-accountingdocument
              AND   fiscalyear = @lt_billingbasic-fiscalyear
              AND   companycode = @lt_billingbasic-companycode
              AND   accountingdocumenttype = 'RV'
              INTO TABLE @DATA(lt_journalentry).
              SORT lt_journalentry BY accountingdocument fiscalyear companycode.
            ENDIF.
          ENDIF.
        ENDIF.
        LOOP AT lt_funcs INTO ls_funcs.
          READ TABLE lt_salesdocumenttype INTO DATA(ls_salesdocumenttype) WITH KEY salesdocumenttype = ls_funcs-salesdocumenttype BINARY SEARCH.
          IF sy-subrc = 0.
            ls_funcs-salesdocumenttype = ls_salesdocumenttype-salesdocumenttypelangdepdnt.
          ENDIF.
          IF ls_funcs-subsequentdocument1 IS INITIAL AND ls_funcs-serialnumber1 IS INITIAL.
            ls_funcs-serialnumber1 = ls_funcs-yy1_warrantyserial_sdi.
          ENDIF.
*          IF ls_funcs-zwarrantytype = 'EXTEND'.
*            ls_funcs-material1 = ls_funcs-yy1_warrantymaterial_sdi.
*          ENDIF.
          IF ls_funcs-salesdocumenttype = 'CBAR' AND ( ls_funcs-zactive = '' OR ls_funcs-zactive = 'E' ).
            READ TABLE lt_customer INTO ls_customer WITH KEY customerreturn = ls_funcs-salesdocument
                                                             customerreturnitem = ls_funcs-salesdocumentitem BINARY SEARCH.
            IF sy-subrc = 0.
              IF ls_customer-returnsrefundtype = '1'.
                READ TABLE lt_salesdocumentitem INTO DATA(ls_salesdocumentitem) WITH KEY referencesddocument = ls_funcs-salesdocument
                                                                                         referencesddocumentitem = ls_funcs-salesdocumentitem BINARY SEARCH.
                IF sy-subrc = 0.
                  READ TABLE lt_subflow INTO DATA(ls_subflow) WITH KEY salesdocument = ls_salesdocumentitem-salesdocument
                                                                       salesdocumentitem = ls_salesdocumentitem-salesdocumentitem BINARY SEARCH.
                  IF sy-subrc = 0.
                    READ TABLE lt_billingbasic INTO DATA(ls_billingbasic) WITH KEY billingdocument = ls_subflow-subsequentdocument BINARY SEARCH.
                    IF sy-subrc = 0.
                      READ TABLE lt_journalentry INTO DATA(ls_journalentry) WITH KEY accountingdocument = ls_billingbasic-accountingdocument
                                                                                     fiscalyear = ls_billingbasic-fiscalyear
                                                                                     companycode = ls_billingbasic-companycode BINARY SEARCH.
                      IF sy-subrc = 0.
                        DATA:gv_date TYPE REF TO if_xco_cp_tm_date.
                        IF ls_journalentry-postingdate IS NOT INITIAL.
                          gv_date = xco_cp_time=>date( iv_year = ls_journalentry-postingdate+0(4)
                                                       iv_month = ls_journalentry-postingdate+4(2)
                                                       iv_day  = ls_journalentry-postingdate+6(2) ).
*                  lv_date = lv_date->add( iv_month = ls_funcs-zwarrantymonths ).
                          gv_date = gv_date->add( iv_day = -1 ).
                          ls_funcs-zwarrantyvalidto = gv_date->as( xco_cp_time=>format->abap )->value.
                          ls_funcs-zwarrantyvalidfrom = ls_funcs-zwarrantyvalidto.
*                          ls_funcs-zwarrantyvalidto = ls_journalentry-postingdate.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
          MODIFY lt_funcs FROM ls_funcs.
          CLEAR:ls_salesdocumenttype,ls_customer,ls_salesdocumentitem,ls_subflow,ls_billingbasic,ls_journalentry,ls_funcs.
        ENDLOOP.
        DATA(gt_funcs_cbar) = lt_funcs.
        DELETE gt_funcs_cbar WHERE salesdocumenttype <> 'CBAR'.
        SORT gt_funcs_cbar BY referencesddocument referencesddocumentitem.
        LOOP AT lt_funcs INTO ls_funcs WHERE ( salesdocumenttype = 'OR' OR salesdocumenttype = 'SD2' ) AND zactive <> 'X'.
          READ TABLE gt_funcs_cbar INTO DATA(gs_funcs_cbar) WITH KEY referencesddocument = ls_funcs-subsequentdocument2
                                                                     referencesddocumentitem = ls_funcs-subsequentdocumentitem2 BINARY SEARCH.
          IF sy-subrc = 0.
            ls_funcs-zwarrantyvalidto = gs_funcs_cbar-zwarrantyvalidto.
            MODIFY lt_funcs FROM ls_funcs.
          ENDIF.
          CLEAR:ls_funcs,gs_funcs_cbar.
        ENDLOOP.

        LOOP AT lt_funcs INTO ls_funcs WHERE salesdocumenttype = 'DR' AND zactive <> 'X'.
          DATA(lt_funcs_or) = lt_funcs.
          DELETE lt_funcs_or WHERE salesdocumenttype <> 'OR'.
          DELETE lt_funcs_or WHERE material1 <> ls_funcs-yy1_warrantymaterial_sdi OR serialnumber1 <> ls_funcs-yy1_warrantyserial_sdi.
          DELETE lt_funcs_or WHERE creationdatetime < ls_funcs-creationdatetime.
          SORT lt_funcs_or BY zwarrantyvalidto DESCENDING.
          READ TABLE lt_funcs_or INTO DATA(ls_funcs_or) WITH KEY material1 = ls_funcs-yy1_warrantymaterial_sdi
                                                                 serialnumber1 = ls_funcs-yy1_warrantyserial_sdi BINARY SEARCH.
          IF sy-subrc = 0.
            ls_funcs-zwarrantyvalidto = ls_funcs_or-zwarrantyvalidto.
            MODIFY lt_funcs FROM ls_funcs.
          ENDIF.
          CLEAR:lt_funcs_or,ls_funcs,ls_funcs_or.
        ENDLOOP.
        DATA(lt_funcs_cbar) = lt_funcs.
        DELETE lt_funcs_cbar WHERE salesdocumenttype <> 'CBAR'.
        DATA(lt_funcs_yy) = lt_funcs.
        SORT lt_funcs_yy BY material1 serialnumber1 salesdocument.
        DELETE lt_funcs_yy WHERE yy1_warrantymaterial_sdi IS INITIAL AND yy1_warrantyserial_sdi IS INITIAL.
        DATA(lt_funcs_rr) = lt_funcs.
        DELETE lt_funcs_rr WHERE salesdocumenttype <> 'OR' AND salesdocumenttype <> 'DR'.
        DELETE lt_funcs_rr WHERE zwarrantytype <> 'EXTEND'.
        DELETE lt_funcs_rr WHERE zactive = 'E'.
        DATA: ls_funcs_cc LIKE is_funcs.
        SORT lt_funcs_rr BY material1 serialnumber1 creationdate DESCENDING.
        LOOP AT lt_funcs_cbar INTO DATA(ls_funcs_cbar).
          READ TABLE lt_funcs_yy INTO DATA(ls_funcs_yy) WITH KEY material1 = ls_funcs_cbar-material1
                                                                 serialnumber1 = ls_funcs_cbar-serialnumber1
                                                                 salesdocument = ls_funcs_cbar-salesdocument BINARY SEARCH.
          IF sy-subrc <> 0.
*            IF ls_funcs_yy-yy1_warrantymaterial_sdi  IS INITIAL AND ls_funcs_yy-yy1_warrantyserial_sdi IS INITIAL.
            READ TABLE lt_funcs_rr INTO DATA(ls_funcs_rr) WITH KEY material1 = ls_funcs_cbar-material4
                                                                   serialnumber1 = ls_funcs_cbar-serialnumber2 BINARY SEARCH.
            IF sy-subrc = 0.
              ls_funcs_cc-soldtoparty = ls_funcs_cbar-soldtoparty.
              ls_funcs_cc-fullname1 = ls_funcs_cbar-fullname1.
              ls_funcs_cc-shiptoparty = ls_funcs_cbar-shiptoparty.
              ls_funcs_cc-fullname2 = ls_funcs_cbar-fullname2.
              ls_funcs_cc-zactive = ls_funcs_rr-zactive.
              ls_funcs_cc-active = ls_funcs_rr-active.
              ls_funcs_cc-material1 = ls_funcs_rr-material1.
              ls_funcs_cc-serialnumber1 = ls_funcs_rr-serialnumber1.
              ls_funcs_cc-yy1_warrantymaterial_sdi = ls_funcs_rr-yy1_warrantymaterial_sdi.
              ls_funcs_cc-yy1_warrantyserial_sdi = ls_funcs_rr-yy1_warrantyserial_sdi.
              ls_funcs_cc-zoldserialnumber = ls_funcs_rr-zoldserialnumber.
              ls_funcs_cc-zwarrantymaterial = ls_funcs_rr-zwarrantymaterial.
              ls_funcs_cc-zwarrantytype = ls_funcs_rr-zwarrantytype.
              ls_funcs_cc-zwarrantyvalidfrom = ls_funcs_cbar-zwarrantyvalidfrom.
              ls_funcs_cc-zwarrantyvalidto = ls_funcs_cbar-zwarrantyvalidto.
              ls_funcs_cc-equipment = ls_funcs_rr-equipment.
              ls_funcs_cc-manualchanged = ls_funcs_rr-manualchanged.
              ls_funcs_cc-salesdocument = ls_funcs_cbar-salesdocument.
              ls_funcs_cc-salesdocumentitem = ls_funcs_cbar-salesdocumentitem.
              ls_funcs_cc-salesdocumenttype = ls_funcs_cbar-salesdocumenttype.
              ls_funcs_cc-creationdate = ls_funcs_cbar-creationdate.
              ls_funcs_cc-creationdatetime = ls_funcs_cbar-creationdatetime.
              ls_funcs_cc-zwarrantymonths = ls_funcs_rr-zwarrantymonths.
              ls_funcs_cc-salesdocumentitemcategory = 'N/A'.
              ls_funcs_cc-billingdocumenttype = 'N/A'.
              ls_funcs_cc-deliverydocumenttype = 'N/A'.
              ls_funcs_cc-material2 = 'N/A'.
              ls_funcs_cc-material3 = 'N/A'.
              ls_funcs_cc-material4 = ls_funcs_cbar-material4.
              ls_funcs_cc-plant1 = 'N/A'.
              ls_funcs_cc-plant2 = 'N/A'.
              ls_funcs_cc-purchaseorderbycustomer = 'N/A'.
              ls_funcs_cc-referencesddocument = 'N/A'.
              ls_funcs_cc-referencesddocumentcategory = 'N/A'.
              ls_funcs_cc-salesdocumentitemtext = 'N/A'.
              ls_funcs_cc-salesorganization = 'N/A'.
              ls_funcs_cc-serialnumber2 = ls_funcs_cbar-serialnumber2.
              ls_funcs_cc-storagelocation1 = 'N/A'.
              ls_funcs_cc-storagelocation2 = 'N/A'.
              ls_funcs_cc-subsequentdocument1 = 'N/A'.
              ls_funcs_cc-subsequentdocument2 = 'N/A'.
              TRY.
                  ls_funcs_cc-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
                CATCH cx_uuid_error.
                  "handle exception
              ENDTRY.
              APPEND ls_funcs_cc  TO lt_funcs.
              CLEAR:ls_funcs_cc,ls_funcs_rr,ls_funcs_cbar,ls_funcs_yy.
            ENDIF.
*            ENDIF.
          ENDIF.
        ENDLOOP.
        SORT lt_funcs BY material1 serialnumber1 salesdocument salesdocumentitem zwarrantymaterial zwarrantytype soldtoparty.
        DELETE ADJACENT DUPLICATES FROM lt_funcs COMPARING material1 serialnumber1 salesdocument salesdocumentitem zwarrantymaterial zwarrantytype soldtoparty.
        DATA(lt_funcs_sd2) = lt_funcs.
        DELETE lt_funcs_sd2 WHERE salesdocumenttype <> 'SD2'.
        DATA(lt_funcs_yy1) = lt_funcs.
        SORT lt_funcs_yy1 BY material1 serialnumber1 salesdocument.
        DELETE lt_funcs_yy1 WHERE yy1_warrantymaterial_sdi IS INITIAL AND yy1_warrantyserial_sdi IS INITIAL.
        DATA(lt_funcs_rr1) = lt_funcs.
        DELETE lt_funcs_rr1 WHERE zwarrantytype <> 'EXTEND'.
        DELETE lt_funcs_rr1 WHERE zactive = 'E'.
        DATA: ls_funcs_sd LIKE is_funcs.
        SORT lt_funcs_rr1 BY salesdocument salesdocumentitem material1 serialnumber1 DESCENDING.
        LOOP AT lt_funcs_sd2 INTO DATA(ls_funcs_sd2).
          DATA(lt_funcs_other) = lt_funcs.
          DELETE lt_funcs_other WHERE salesdocumenttype <> 'SD2'.
          READ TABLE lt_funcs_yy1 INTO DATA(ls_funcs_yy1) WITH KEY material1 = ls_funcs_sd2-material1
                                                                   serialnumber1 = ls_funcs_sd2-serialnumber1
                                                                   salesdocument = ls_funcs_sd2-salesdocument BINARY SEARCH.
          IF sy-subrc <> 0.
            READ TABLE lt_funcs_rr1 INTO DATA(ls_funcs_rr1) WITH KEY salesdocument = ls_funcs_sd2-referencesddocument
                                                                     salesdocumentitem = ls_funcs_sd2-referencesddocumentitem
                                                                     material1 = ls_funcs_sd2-material4
                                                                     serialnumber1 = ls_funcs_sd2-serialnumber2 BINARY SEARCH.
            IF sy-subrc = 0.
              ls_funcs_sd-soldtoparty = ls_funcs_sd2-soldtoparty.
              ls_funcs_sd-fullname1 = ls_funcs_sd2-fullname1.
              ls_funcs_sd-shiptoparty = ls_funcs_sd2-shiptoparty.
              ls_funcs_sd-fullname2 = ls_funcs_sd2-fullname2.
              ls_funcs_sd-zactive = ls_funcs_sd2-zactive.
              ls_funcs_sd-active = ls_funcs_sd2-active.
              ls_funcs_sd-material1 = ls_funcs_sd2-material1.
              ls_funcs_sd-serialnumber1 = ls_funcs_sd2-serialnumber1.
              ls_funcs_sd-yy1_warrantymaterial_sdi = ls_funcs_sd2-material1.
              ls_funcs_sd-yy1_warrantyserial_sdi = ls_funcs_sd2-serialnumber1.
*              ls_funcs_sd-zoldserialnumber = ls_funcs_rr1-zoldserialnumber.
              ls_funcs_sd-zwarrantymaterial = ls_funcs_rr1-zwarrantymaterial.
              ls_funcs_sd-zwarrantytype = ls_funcs_rr1-zwarrantytype.
              ls_funcs_sd-zwarrantyvalidfrom = ls_funcs_sd2-zwarrantyvalidfrom.
              ls_funcs_sd-zwarrantyvalidto = ls_funcs_sd2-zwarrantyvalidto.
              ls_funcs_sd-equipment = ls_funcs_rr1-equipment.
              ls_funcs_sd-manualchanged = ls_funcs_rr1-manualchanged.
              ls_funcs_sd-salesdocument = ls_funcs_sd2-salesdocument.
              ls_funcs_sd-salesdocumentitem = ls_funcs_sd2-salesdocumentitem.
              ls_funcs_sd-salesdocumenttype = ls_funcs_sd2-salesdocumenttype.
              ls_funcs_sd-creationdate = ls_funcs_sd2-creationdate.
              ls_funcs_sd-creationdatetime = ls_funcs_sd2-creationdatetime.
              ls_funcs_sd-salesdocumentitemcategory = 'N/A'.
              ls_funcs_sd-billingdocumenttype = 'N/A'.
              ls_funcs_sd-deliverydocumenttype = 'N/A'.
              ls_funcs_sd-material2 = 'N/A'.
              ls_funcs_sd-material3 = 'N/A'.
*              ls_funcs_sd-material4 = 'N/A'.
              ls_funcs_sd-plant1 = 'N/A'.
              ls_funcs_sd-plant2 = 'N/A'.
              ls_funcs_sd-purchaseorderbycustomer = 'N/A'.
              DELETE lt_funcs_other WHERE salesdocument <> ls_funcs_sd2-salesdocument OR material1 <> ls_funcs_sd2-material1 OR serialnumber1 <> ls_funcs_sd2-serialnumber1.
*              DELETE lt_funcs_other WHERE salesdocumentitem = ls_funcs_sd2-salesdocumentitem.
              DELETE lt_funcs_other WHERE referencesddocument IS INITIAL AND referencesddocumentitem IS INITIAL AND material2 IS INITIAL AND serialnumber2 IS INITIAL AND zoldserialnumber IS INITIAL.
              READ TABLE lt_funcs_other INTO DATA(ls_funcs_other) INDEX 1.
              IF sy-subrc = 0.
                ls_funcs_sd-referencesddocument = ls_funcs_other-referencesddocument.
                ls_funcs_sd-referencesddocumentitem = ls_funcs_other-referencesddocumentitem.
                ls_funcs_sd-material4 = ls_funcs_other-material4.
                ls_funcs_sd-serialnumber2 = ls_funcs_other-serialnumber2.
                ls_funcs_sd-zoldserialnumber = ls_funcs_rr1-zoldserialnumber.
              ENDIF.
              ls_funcs_sd-referencesddocumentcategory = 'N/A'.
              ls_funcs_sd-salesdocumentitemtext = 'N/A'.
              ls_funcs_sd-salesorganization = 'N/A'.
*              ls_funcs_sd-serialnumber2 = 'N/A'.
              ls_funcs_sd-storagelocation1 = 'N/A'.
              ls_funcs_sd-storagelocation2 = 'N/A'.
              ls_funcs_sd-subsequentdocument1 = 'N/A'.
              ls_funcs_sd-subsequentdocument2 = 'N/A'.
              ls_funcs_sd-zwarrantymonths = ls_funcs_rr1-zwarrantymonths.
              TRY.
                  ls_funcs_sd-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
                CATCH cx_uuid_error.
                  "handle exception
              ENDTRY.
              APPEND ls_funcs_sd  TO lt_funcs.
              CLEAR:ls_funcs_sd,ls_funcs_rr1,ls_funcs_other,ls_funcs_sd2,ls_funcs_yy1.
            ENDIF.
          ENDIF.
        ENDLOOP.
        SORT lt_funcs BY material1 serialnumber1 salesdocument salesdocumentitem zwarrantymaterial zwarrantytype soldtoparty.
        DELETE ADJACENT DUPLICATES FROM lt_funcs COMPARING material1 serialnumber1 salesdocument salesdocumentitem zwarrantymaterial zwarrantytype soldtoparty.
        DATA(lt_funcs_cr) = lt_funcs.
        DELETE lt_funcs_cr WHERE salesdocumenttype <> 'CR'.
        DELETE lt_funcs_cr WHERE salesdocumenttype <> 'EXTEND'.
        SORT lt_funcs_cr BY referencesddocument referencesddocumentitem yy1_warrantymaterial_sdi yy1_warrantyserial_sdi.
        LOOP AT lt_funcs INTO ls_funcs WHERE ( salesdocumenttype = 'OR' OR salesdocumenttype = 'DR') AND zwarrantytype = 'EXTEND'.
          READ TABLE lt_funcs_cr INTO DATA(ls_funcs_cr) WITH KEY referencesddocument = ls_funcs-subsequentdocument2
                                                                 referencesddocumentitem = ls_funcs-subsequentdocumentitem2
                                                                 yy1_warrantymaterial_sdi = ls_funcs-yy1_warrantymaterial_sdi
                                                                 yy1_warrantyserial_sdi = ls_funcs-yy1_warrantyserial_sdi BINARY SEARCH.
          IF sy-subrc = 0.
            ls_funcs-zactive = 'E'.
            ls_funcs-active = '1'.
          ENDIF.
          MODIFY lt_funcs FROM ls_funcs.
          CLEAR:ls_funcs,ls_funcs_cr.
        ENDLOOP.
        DATA(lt_funcs_od) = lt_funcs.
        DELETE lt_funcs_od WHERE salesdocumenttype <> 'OR' AND salesdocumenttype <> 'DR'.
        DELETE lt_funcs_od WHERE zwarrantytype <> 'EXTEND' OR zactive <> 'E'.
        DATA(lt_funcs_odd) = lt_funcs_od.
        DELETE lt_funcs_od WHERE salesdocumenttype <> 'DR'.
        DELETE lt_funcs_odd WHERE salesdocumenttype <> 'OR'.
*        SORT lt_funcs_od BY material4 serialnumber2 yy1_warrantymaterial_sdi yy1_warrantyserial_sdi.
*        SORT lt_funcs_odd BY referencesddocument referencesddocumentitem yy1_warrantymaterial_sdi yy1_warrantyserial_sdi.
        DATA(gt_funcs_cbarcopy) = lt_funcs.
        DELETE gt_funcs_cbarcopy WHERE subsequentdocument2 <> 'N/A'.
        DELETE gt_funcs_cbarcopy WHERE zwarrantytype <> 'EXTEND'.
        DELETE gt_funcs_cbarcopy WHERE salesdocumenttype <> 'CBAR'.
        DATA(gt_funcs_copy) = gt_funcs_cbarcopy.
        LOOP AT lt_funcs_od INTO DATA(ls_funcs_od).
          gt_funcs_cbarcopy = gt_funcs_copy.
          DELETE gt_funcs_cbarcopy WHERE creationdatetime < ls_funcs_od-creationdatetime.
          SORT gt_funcs_cbarcopy BY material4 serialnumber2 yy1_warrantymaterial_sdi yy1_warrantyserial_sdi creationdatetime.
          READ TABLE gt_funcs_cbarcopy INTO DATA(gs_funcs_cbarcopy) WITH KEY material4 = ls_funcs_od-yy1_warrantymaterial_sdi
                                                                             serialnumber2 = ls_funcs_od-yy1_warrantyserial_sdi
                                                                             yy1_warrantymaterial_sdi = ls_funcs_od-yy1_warrantymaterial_sdi
                                                                             yy1_warrantyserial_sdi = ls_funcs_od-yy1_warrantyserial_sdi BINARY SEARCH.
          IF sy-subrc = 0.
            gs_funcs_cbarcopy-zactive = 'E'.
            gs_funcs_cbarcopy-active = '1'.
            MODIFY lt_funcs FROM gs_funcs_cbarcopy TRANSPORTING zactive active WHERE uuid = gs_funcs_cbarcopy-uuid.
          ENDIF.
          CLEAR:ls_funcs_od,gs_funcs_cbarcopy.
        ENDLOOP.
        SORT gt_funcs_copy BY referencesddocument referencesddocumentitem yy1_warrantymaterial_sdi yy1_warrantyserial_sdi.
        LOOP AT lt_funcs_odd INTO DATA(ls_funcs_odd).
          READ TABLE gt_funcs_copy INTO DATA(gs_funcs_copy) WITH KEY referencesddocument = ls_funcs_odd-subsequentdocument2
                                                                     referencesddocumentitem = ls_funcs_odd-subsequentdocumentitem2
                                                                     yy1_warrantymaterial_sdi = ls_funcs_odd-yy1_warrantymaterial_sdi
                                                                     yy1_warrantyserial_sdi = ls_funcs_odd-yy1_warrantyserial_sdi BINARY SEARCH.
          IF sy-subrc = 0.
            gs_funcs_copy-zactive = 'E'.
            gs_funcs_copy-active = '1'.
            MODIFY lt_funcs FROM gs_funcs_copy TRANSPORTING zactive active WHERE uuid = gs_funcs_copy-uuid.
          ENDIF.
          CLEAR:ls_funcs_odd,gs_funcs_copy.
        ENDLOOP.
        DATA(lt_funcs_cbare) = lt_funcs.
        DELETE lt_funcs_cbare WHERE zactive <> 'E'.
        DELETE lt_funcs_cbare WHERE salesdocumenttype <> 'CBAR'.
        DATA(lt_funcs_sd2copy) = lt_funcs.
        DELETE lt_funcs_sd2copy WHERE subsequentdocument2 <> 'N/A'.
        DELETE lt_funcs_sd2copy WHERE zwarrantytype <> 'EXTEND'.
        DELETE lt_funcs_sd2copy WHERE salesdocumenttype <> 'SD2'.
        SORT lt_funcs_sd2copy BY referencesddocument referencesddocumentitem material4 serialnumber2.
        LOOP AT lt_funcs_cbare INTO DATA(ls_funcs_cbare).
          READ TABLE lt_funcs_sd2copy INTO DATA(ls_funcs_sd2copy) WITH KEY  referencesddocument = ls_funcs_cbare-salesdocument
                                                                            referencesddocumentitem = ls_funcs_cbare-salesdocumentitem
                                                                            material4 = ls_funcs_cbare-material4
                                                                            serialnumber2 = ls_funcs_cbare-serialnumber2 BINARY SEARCH.
          IF sy-subrc = 0.
            ls_funcs_sd2copy-zactive = 'E'.
            ls_funcs_sd2copy-active = '1'.
            MODIFY lt_funcs FROM ls_funcs_sd2copy TRANSPORTING zactive active WHERE uuid = ls_funcs_sd2copy-uuid.
          ENDIF.
          CLEAR:ls_funcs_cbare,ls_funcs_sd2copy.
        ENDLOOP.
        DATA(lt_funcs_cbarre) = lt_funcs.
        SORT lt_funcs_cbarre BY salesdocument salesdocumentitem.
        DATA(lt_funcs_billing) = lt_funcs.
        DELETE lt_funcs_billing WHERE salesdocumenttype <> 'OR'.
        SORT lt_funcs_billing BY subsequentdocument2 subsequentdocumentitem2 zwarrantyvalidfrom.
        IF lt_funcs IS NOT INITIAL.
          SELECT material,
                 serialnumber,
                 equipment
          FROM i_equipment
          FOR ALL ENTRIES IN @lt_funcs
          WHERE material = @lt_funcs-material1
          AND   serialnumber = @lt_funcs-serialnumber1
          INTO TABLE @DATA(lt_equipment1).
          SORT lt_equipment1 BY material serialnumber.


          DATA  r_serialnumber TYPE RANGE OF i_equipment-serialnumber.
          DATA  l_wa_serialnumber  LIKE LINE OF r_serialnumber.
          LOOP AT lt_funcs INTO ls_funcs.
            l_wa_serialnumber-sign   = 'I'.
            l_wa_serialnumber-option = 'EQ'.
            l_wa_serialnumber-low   = ls_funcs-yy1_warrantyserial_sdi.
            APPEND l_wa_serialnumber TO r_serialnumber.
          ENDLOOP.

          SELECT material,
                 serialnumber,
                 equipment
          FROM i_equipment
          FOR ALL ENTRIES IN @lt_funcs
          WHERE material = @lt_funcs-yy1_warrantymaterial_sdi
          AND   serialnumber IN @r_serialnumber
          INTO TABLE @DATA(lt_equipment2).
          SORT lt_equipment2 BY material serialnumber.
        ENDIF.


        LOOP AT lt_funcs INTO ls_funcs.
          IF ls_funcs-subsequentdocument1 = 'N/A' AND ls_funcs-salesdocumenttype = 'SD2' AND ls_funcs-zactive = 'X'.
            READ TABLE lt_funcs_cbarre INTO DATA(ls_funcs_cbarre) WITH KEY salesdocument = ls_funcs-referencesddocument
                                                                           salesdocumentitem = ls_funcs-referencesddocumentitem BINARY SEARCH.
            IF sy-subrc = 0.
              READ TABLE lt_funcs_billing INTO DATA(ls_funcs_billing) WITH KEY subsequentdocument2 = ls_funcs_cbarre-referencesddocument
                                                                               subsequentdocumentitem2 = ls_funcs_cbarre-referencesddocumentitem BINARY SEARCH.
              IF sy-subrc = 0.
                DATA:gv_date2 TYPE REF TO if_xco_cp_tm_date.
                IF ls_funcs_billing-zwarrantyvalidfrom IS NOT INITIAL.
                  gv_date2 = xco_cp_time=>date( iv_year = ls_funcs_billing-zwarrantyvalidfrom+0(4)
                                               iv_month = ls_funcs_billing-zwarrantyvalidfrom+4(2)
                                               iv_day  = ls_funcs_billing-zwarrantyvalidfrom+6(2) ).
                  gv_date2 = gv_date2->add( iv_day = ls_funcs-zwarrantymonths ).
                  ls_funcs-zwarrantyvalidto = gv_date2->as( xco_cp_time=>format->abap )->value.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
          IF ls_funcs-zwarrantytype = 'STANDARD' AND ls_funcs-equipment IS INITIAL.
            READ TABLE lt_equipment1 INTO DATA(ls_equipment1) WITH KEY material = ls_funcs-material1
                                                                       serialnumber = ls_funcs-serialnumber2 BINARY SEARCH.
            IF sy-subrc = 0.
              ls_funcs-equipment = ls_equipment1-equipment.
            ENDIF.
          ENDIF.
          IF ls_funcs-zwarrantytype = 'EXTEND' AND ls_funcs-equipment IS INITIAL.
            READ TABLE lt_equipment2 INTO DATA(ls_equipment2) WITH KEY material = ls_funcs-yy1_warrantymaterial_sdi
                                                                       serialnumber = ls_funcs-yy1_warrantyserial_sdi BINARY SEARCH.
            IF sy-subrc = 0.
              ls_funcs-equipment = ls_equipment2-equipment.
            ENDIF.
          ENDIF.
          IF ls_funcs-zactive = 'X'.
            ls_funcs-zactive = 'Yes'.
            ls_funcs-active = 3.
          ELSEIF ls_funcs-zactive = 'E'.
            ls_funcs-zactive = 'No-W/CR'.
            ls_funcs-active = 1.
          ELSEIF ls_funcs-zactive = 'S'.
            ls_funcs-zactive = 'No-W/Avoid'.
            ls_funcs-active = 1.
          ELSE.
            ls_funcs-zactive = 'No-W/O CR'.
            ls_funcs-active = 2.
          ENDIF.
          IF ls_funcs-Legacy = 'X'.
            ls_funcs-salesdocumenttype = ''.
          ENDIF.
          MODIFY lt_funcs FROM ls_funcs.
        ENDLOOP.
        IF lt_funcs IS NOT INITIAL.
          SELECT salesdocument,
                 salesdocumentitem,
                 distributionchannel,
                 division
          FROM i_salesdocumentitem
          FOR ALL ENTRIES IN @lt_funcs
          WHERE salesdocument = @lt_funcs-salesdocument
          AND   salesdocumentitem = @lt_funcs-salesdocumentitem
          INTO TABLE @DATA(lt_salesdocitems).
          SORT lt_salesdocitems BY salesdocument salesdocumentitem.
        ENDIF.
        DATA:lv_distributionchannel TYPE i_salesdocumentitem-distributionchannel.
        DATA:lv_division TYPE i_salesdocumentitem-division.
        LOOP AT lt_funcs INTO ls_funcs.
          READ TABLE lt_salesdocitems INTO DATA(ls_salesdocitems) WITH KEY salesdocument = ls_funcs-salesdocument
                                                                           salesdocumentitem = ls_funcs-salesdocumentitem BINARY SEARCH.
          IF sy-subrc = 0.
            lv_distributionchannel = ls_salesdocitems-distributionchannel.
            lv_division = ls_salesdocitems-division.
          ENDIF.
          AUTHORITY-CHECK OBJECT 'V_VBAK_VKO'
          ID 'ACTVT' FIELD '03'
          ID 'VTWEG' FIELD lv_distributionchannel
          ID 'SPART' FIELD lv_division
          ID 'VKORG' FIELD ls_funcs-salesorganization.
          IF sy-subrc <> 0.
            DELETE lt_funcs[].
          ENDIF.
          AUTHORITY-CHECK OBJECT 'V_VBRK_VKO'
          ID 'ACTVT' FIELD '03'
          ID 'VKORG' FIELD ls_funcs-salesorganization.
          IF sy-subrc <> 0.
            DELETE lt_funcs[].
          ENDIF.
          IF ls_funcs-salesorganization = '2900' OR ls_funcs-salesorganization = '2901'.
            DELETE lt_funcs[].
          ENDIF.
          CLEAR:lv_distributionchannel,lv_division.
        ENDLOOP.
        DATA(rt_funcs) = lt_funcs.
        SORT rt_funcs BY material1 serialnumber1 creationdatetime DESCENDING.
        DATA(rt_funcs1) = lt_funcs.
        DELETE rt_funcs1 WHERE zactive <> 'Yes'.
        LOOP AT rt_funcs1 INTO DATA(rs_funcs1).
          READ TABLE rt_funcs INTO DATA(rs_funcs) WITH KEY material1 = rs_funcs1-material1
                                                           serialnumber1 = rs_funcs1-serialnumber1 BINARY SEARCH.
          IF sy-subrc = 0.
            IF rs_funcs1-CreationDateTime < rs_funcs-CreationDateTime.
              rs_funcs1-zactive = 'No-W/O CR'.
              rs_funcs1-active = 2.
              MODIFY lt_funcs FROM rs_funcs1 TRANSPORTING zactive active WHERE uuid = rs_funcs1-uuid AND material1 = rs_funcs1-material1 AND serialnumber1 = rs_funcs1-serialnumber1.
            ENDIF.
          ENDIF.
        ENDLOOP.
        IF lr_salesorder[] IS NOT INITIAL.
          DELETE lt_funcs WHERE salesdocument NOT IN lr_salesorder[].
        ENDIF.
        IF lr_soldtoparty[] IS NOT INITIAL.
          DELETE lt_funcs WHERE soldtoparty NOT IN lr_soldtoparty[].
        ENDIF.
        IF lr_creationdate[] IS NOT INITIAL.
          DELETE lt_funcs WHERE creationdate NOT IN lr_creationdate[].
        ENDIF.
        IF lr_salesdocumenttype[] IS NOT INITIAL.
          DELETE lt_funcs WHERE salesdocumenttype NOT IN lr_salesdocumenttype[].
        ENDIF.
        IF lr_serialnumber[] IS NOT INITIAL.
          DELETE lt_funcs WHERE serialnumber1 NOT IN lr_serialnumber[].
        ENDIF.
        IF lr_zoldserialnumber[] IS NOT INITIAL.
          DELETE lt_funcs WHERE zoldserialnumber NOT IN lr_zoldserialnumber[].
        ENDIF.
        IF lr_material[] IS NOT INITIAL.
          DELETE lt_funcs WHERE material1 NOT IN lr_material[].
        ENDIF.
*        SORT lt_funcs BY salesdocument DESCENDING salesdocumentitem ASCENDING.
        SORT lt_funcs BY creationdatetime DESCENDING salesdocumentitem ASCENDING serialnumber1 ASCENDING zwarrantytype DESCENDING zwarrantymaterial DESCENDING.
        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_funcs ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_funcs ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_funcs ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_funcs ).

        io_response->set_data( lt_funcs ).



      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
    TRY.
        CASE io_request->get_entity_id( ).

          WHEN 'ZZR_WARRANTY_REPORT'.
            get_warranty( io_request = io_request io_response = io_response ).
        ENDCASE.

      CATCH cx_rap_query_provider INTO DATA(lx_query).
      CATCH cx_sy_no_handler INTO DATA(lx_synohandler).
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
