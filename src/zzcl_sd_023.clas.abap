CLASS zzcl_sd_023 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES tt_data TYPE TABLE OF zr_ssd030.
    TYPES ty_recipients TYPE c LENGTH 50.
    DATA sender TYPE c LENGTH 30.
    DATA conf_name TYPE c LENGTH 30.
    DATA attachment_name TYPE c LENGTH 255.
    DATA subject TYPE string.
    DATA template_name TYPE string.
    DATA content TYPE string.
    DATA recipients TYPE TABLE OF string.
    DATA filename TYPE string.
    DATA mimetype TYPE string.

    METHODS get_parameters IMPORTING it_parameters TYPE if_apj_dt_exec_object=>tt_templ_val.
    METHODS get_all_data EXPORTING et_data  TYPE tt_data.

    METHODS write_to_excel IMPORTING it_data         TYPE tt_data
                           EXPORTING ev_file_content TYPE zzattachment.
    METHODS send_email IMPORTING iv_attachment TYPE zzattachment.
ENDCLASS.



CLASS ZZCL_SD_023 IMPLEMENTATION.


  METHOD get_all_data.
    DATA: lt_funcs TYPE TABLE OF zr_ssd030.

    SELECT *
        FROM zr_ssd029
        WHERE material IS NOT INITIAL
        INTO TABLE @DATA(lt_funcs1).
    DELETE lt_funcs1 WHERE material IS INITIAL.
    DELETE lt_funcs1 WHERE salesdocument IS INITIAL.
    SELECT storage_location
    FROM ztsd014
    WHERE storage_location IS NOT INITIAL
    INTO TABLE @DATA(lt_ztsd014).
    SORT lt_ztsd014 BY storage_location.


    MOVE-CORRESPONDING lt_funcs1 TO lt_funcs.
    LOOP AT lt_funcs INTO DATA(ls_funcs).
      READ TABLE lt_ztsd014 INTO DATA(ls_ztsd014) WITH KEY storage_location = ls_funcs-storagelocation BINARY SEARCH.
      IF sy-subrc = 0.
        DELETE lt_funcs[].
      ENDIF.
    ENDLOOP.
    TYPES:BEGIN OF ty_storge,
            material                     TYPE string,
            plant                        TYPE string,
            matlwrhsstkqtyinmatlbaseunit TYPE zzesd073,
          END OF ty_storge.
    TYPES:BEGIN OF ty_commit,
            material TYPE string,
            plant    TYPE string,
            openqty  TYPE zzesd073,
          END OF ty_commit.
    DATA: lt_data TYPE TABLE OF ty_storge.
    DATA: lt_commit TYPE TABLE OF ty_commit,
          ls_commit TYPE ty_commit.
    SORT lt_funcs BY material plant salesdocument.
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
*            DATA(lv_path) = |{ '/API_MATERIAL_STOCK_SRV/A_MaterialStock(''' }{ ls_funcs-material }{ ''')/to_MatlStkInAcctMod' }|.
        DATA(lv_path) = |{ '/API_MATERIAL_STOCK_SRV/A_MatlStkInAcctMod' }|.
        REPLACE ALL OCCURRENCES OF ` ` IN lv_path WITH '%20'.

*                lv_path = cl_web_http_utility=>escape_url( lv_path ).

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').

        TRY.
            lo_http_client->set_csrf_token(  ).

            DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
          CATCH cx_web_http_client_error.
        ENDTRY.

        DATA(lv_response) = lo_response->get_text(  ).

        TYPES:BEGIN OF ty_t,
                id   TYPE string,
                type TYPE string,
                uri  TYPE string,
              END OF ty_t.
        TYPES:BEGIN OF ty_ms1,
                uri TYPE string,
              END OF ty_ms1.
        TYPES:BEGIN OF ty_ms,
                _deferred TYPE ty_ms1,
              END OF ty_ms.
        TYPES:BEGIN OF ty_tab,
                _metadata                    TYPE ty_t,
                material                     TYPE string,
                plant                        TYPE string,
                storagelocation              TYPE string,
                batch                        TYPE string,
                supplier                     TYPE string,
                customer                     TYPE string,
                wbselementinternalid         TYPE string,
                sddocument                   TYPE string,
                sddocumentitem               TYPE string,
                inventoryspecialstocktype    TYPE string,
                inventorystocktype           TYPE string,
                materialbaseunit             TYPE meins,
                matlwrhsstkqtyinmatlbaseunit TYPE zzesd073,
                to_materialserialnumber      TYPE ty_ms,
                to_materialstock             TYPE ty_ms,
              END OF ty_tab.
        DATA:BEGIN OF ls_data,
               results TYPE TABLE OF ty_tab,
             END OF ls_data.
        DATA:BEGIN OF lo_error,
               d LIKE ls_data,
             END OF lo_error.
        DATA: lt_storge TYPE TABLE OF ty_storge,
              ls_storge TYPE ty_storge.
*                      "Error handling here
*                      "handle odata error message here
        /ui2/cl_json=>deserialize(
            EXPORTING
                json = lv_response
            CHANGING
                data = lo_error
        ).
        LOOP AT lo_error-d-results INTO DATA(ls_results).
          IF ls_results-storagelocation = 'AREG' AND ls_results-inventorystocktype = '01'.
            MOVE-CORRESPONDING ls_results TO ls_storge.
            COLLECT ls_storge INTO lt_storge.
          ENDIF.
        ENDLOOP.
        SORT lt_storge BY material plant.
      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
    ENDTRY.
    LOOP AT lt_funcs INTO ls_funcs.
      CLEAR:ls_funcs-inventoryquantity,ls_funcs-backorderedquantity,ls_funcs-balance,ls_funcs-openvalues.
      TRY.
          ls_funcs-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
        CATCH cx_uuid_error.
          "handle exception
      ENDTRY.
      ls_funcs-conditionamount = ls_funcs-conditionamount / ls_funcs-orderquantity.
      IF ls_funcs-flag = ''.
        ls_funcs-openqty = ls_funcs-orderquantity - ls_funcs-openqty.
      ENDIF.
      ls_funcs-openvalues = ls_funcs-openqty * ls_funcs-conditionamount.
      SORT lt_data BY material plant.
*          READ TABLE lt_data INTO DATA(ls_data1) WITH KEY material = ls_funcs-material
*                                                         plant = ls_funcs-plant BINARY SEARCH.
*          IF sy-subrc = 0.
*            ls_funcs-inventoryquantity = ls_data1-matlwrhsstkqtyinmatlbaseunit.
*          ELSE.
      READ TABLE lt_storge INTO ls_storge WITH KEY material = ls_funcs-material
                                                   plant = ls_funcs-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_funcs-inventoryquantity = ls_storge-matlwrhsstkqtyinmatlbaseunit.
      ENDIF.
*            APPEND LINES OF lt_storge TO lt_data.
*          ENDIF.
      MOVE-CORRESPONDING ls_funcs TO ls_commit.
      COLLECT ls_commit INTO lt_commit.
      MODIFY lt_funcs FROM ls_funcs.
      CLEAR:ls_funcs,ls_storge,ls_commit.
    ENDLOOP.
    SORT lt_commit BY material plant.
    DATA:lv_str TYPE string.
    DATA:lv_balance TYPE zzesd073.
    LOOP AT lt_funcs ASSIGNING FIELD-SYMBOL(<fs_funcs>).
      IF sy-tabix = 1.
        lv_str = <fs_funcs>-material && <fs_funcs>-plant.
        <fs_funcs>-balance = <fs_funcs>-inventoryquantity - <fs_funcs>-openqty.
        lv_balance = <fs_funcs>-balance.
      ELSE.
        DATA(lv_mp) = <fs_funcs>-material && <fs_funcs>-plant.
        IF lv_mp = lv_str.
          <fs_funcs>-balance = lv_balance - <fs_funcs>-openqty.
          lv_balance = <fs_funcs>-balance.
        ELSE.
          lv_str = <fs_funcs>-material && <fs_funcs>-plant.
          lv_balance = <fs_funcs>-inventoryquantity - <fs_funcs>-openqty.
          <fs_funcs>-balance = lv_balance.
        ENDIF.
      ENDIF.
    ENDLOOP.
    LOOP AT lt_funcs INTO ls_funcs.
      CLEAR:ls_funcs-confddelivqtyinorderqtyunit.
      READ TABLE lt_commit INTO ls_commit WITH KEY material = ls_funcs-material
                                                   plant = ls_funcs-plant BINARY SEARCH.
      IF sy-subrc = 0.
        ls_funcs-confddelivqtyinorderqtyunit = ls_commit-openqty.
        ls_funcs-backorderedquantity = ls_funcs-confddelivqtyinorderqtyunit - ls_funcs-inventoryquantity.
        IF ls_funcs-backorderedquantity <= 0.
          ls_funcs-backorderedquantity = 0.
        ENDIF.
      ENDIF.
      MODIFY lt_funcs FROM ls_funcs.
    ENDLOOP.
    DELETE lt_funcs WHERE openqty IS INITIAL.

    et_data = lt_funcs.

  ENDMETHOD.


  METHOD get_parameters.
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'P_Sender'.
          sender = ls_parameter-low.
        WHEN 'P_Conf'.
          conf_name = ls_parameter-low.
        WHEN 'P_Temp'.
          template_name = ls_parameter-low.
        WHEN 'P_Attach'.
          attachment_name = ls_parameter-low.
      ENDCASE.
    ENDLOOP.

    SELECT SINGLE UUID FROM ZR_ZT_EMAIL_CONF WHERE ConfigName = @conf_name
    INTO @DATA(uuid).

    READ ENTITIES OF ZR_ZT_EMAIL_CONF
    ENTITY Config
    BY \_Content
    FIELDS ( TemplateName Subject Content ) WITH VALUE #( ( %key-uuid = uuid ) )
    RESULT FINAL(email_conf).

    READ TABLE email_conf ASSIGNING FIELD-SYMBOL(<fs_conf>) WITH KEY TemplateName = template_name.
    IF sy-subrc = 0.
        subject = <fs_conf>-Subject.
        content = <fs_conf>-Content.
    ENDIF.

    READ ENTITIES OF ZR_ZT_EMAIL_CONF
    ENTITY Config
    BY \_Recipent
    FIELDS ( Type Recipent ) WITH VALUE #( ( %key-uuid = uuid ) )
    RESULT FINAL(recipient_conf).

    LOOP AT recipient_conf ASSIGNING FIELD-SYMBOL(<fs_recipient>).
        APPEND <fs_recipient>-Recipent TO recipients.
    ENDLOOP.

  ENDMETHOD.


  METHOD if_apj_dt_exec_object~get_parameters.
    " Return the supported selection parameters here
    et_parameter_def = VALUE #(
      ( selname = 'P_Sender' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 30 param_text = 'Email of Sender' changeable_ind = abap_true )
      ( selname = 'P_Conf' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 30 param_text = 'Email Config Name' changeable_ind = abap_true )
      ( selname = 'P_Temp' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 30 param_text = 'Email Template Name' changeable_ind = abap_true )
      ( selname = 'P_Attach' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 255 param_text = 'attachment_name Name' changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_Attach' kind = if_apj_dt_exec_object=>parameter sign = 'I' option = 'EQ' low = 'Backorder Report' )
    ).


  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.
    DATA: lt_data TYPE tt_data.

    DATA: lv_file_content TYPE zzattachment.

    get_parameters( it_parameters ).

    get_all_data( IMPORTING et_data = lt_data ).
    write_to_excel( EXPORTING it_data = lt_data
                    IMPORTING ev_file_content = lv_file_content ).
    send_email( EXPORTING iv_attachment = lv_file_content ).


  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.
    DATA  et_parameters TYPE if_apj_rt_exec_object=>tt_templ_val.

    et_parameters = VALUE #(
        ( selname = 'P_Sender'
          kind = if_apj_dt_exec_object=>parameter
          sign = 'I'
          option = 'EQ'
          low = 'SAP@AtosaUSA.com' )
        ( selname = 'P_Conf'
          kind = if_apj_dt_exec_object=>select_option
          sign = 'I'
          option = 'EQ'
          low = 'LOB03-009' )
        ( selname = 'P_Temp'
          kind = if_apj_dt_exec_object=>parameter
          sign = 'I'
          option = 'EQ'
          low = 'Template_1' )
        ( selname = 'P_Attach'
          kind = if_apj_dt_exec_object=>parameter
          sign = 'I'
          option = 'EQ'
          low = 'Backorder Report.' )
      ).

    TRY.

        if_apj_rt_exec_object~execute( it_parameters = et_parameters ).
        out->write( |Finished| ).

      CATCH cx_root INTO DATA(job_scheduling_exception).
        out->write( |Exception has occured: { job_scheduling_exception->get_text(  ) }| ).
    ENDTRY.
  ENDMETHOD.


  METHOD send_email.
    DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).

    lo_mail->set_sender( CONV #( sender ) ).

    LOOP AT recipients INTO DATA(recipient).
      lo_mail->add_recipient( CONV #( recipient ) ).
    ENDLOOP.

    lo_mail->set_subject( CONV #( subject ) ).

    DATA(lv_content) = content.

    lo_mail->set_main( cl_bcs_mail_textpart=>create_instance(
                iv_content      = lv_content
                iv_content_type = 'text/html' ) ).

    DATA(lo_attachment) = cl_bcs_mail_binarypart=>create_instance(
                                     iv_content      = iv_attachment
                                     iv_content_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                     iv_filename     = |{ attachment_name }.xlsx| ).

    lo_mail->add_attachment( lo_attachment ).
    lo_mail->send( IMPORTING et_status = DATA(lt_status) ).

  ENDMETHOD.


  METHOD write_to_excel.
    DATA(lo_write_access) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_worksheet) = lo_write_access->get_workbook( )->worksheet->at_position( 1 ).
    DATA(lo_selection_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
        )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
        )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
        )->get_pattern(  ).

    DATA(lo_cursor) = lo_worksheet->cursor(
        io_column = xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
        io_row = xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
     ).

    " Write Table Header
    lo_cursor->get_cell( )->value->write_from( 'Item' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Whse Code' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Whse Name' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Regular Bin Inventory' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Committed' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Backordered' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Customer Code' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Customer Name' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'PO No.' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Sales Order No.' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Shipping Date' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Document Date' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Creation Date' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'City' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'State' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Ordered Qty' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Open Qty' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Balance' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Unit Price' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Open Values' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'ChainAccount' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'NationalAccount' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'NoRebateOffered' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Properties1' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Properties2' ).

    TYPES:
      BEGIN OF ts_row,
        material                    TYPE zzesd006,
        plant                       TYPE c LENGTH 4,
        plantname                   TYPE c LENGTH 30,
        inventoryquantity           TYPE p LENGTH 15 DECIMALS 3,
        confddelivqtyinorderqtyunit TYPE p LENGTH 15 DECIMALS 3,
        backorderedquantity         TYPE p LENGTH 15 DECIMALS 3,
        customer                    TYPE zzesd013,
        customername                TYPE c LENGTH 80,
        purchaseorderbycustomer     TYPE c LENGTH 35,
        salesdocument               TYPE zzesd014,
        requesteddeliverydate       TYPE sy-datum,
        salesdocumentdate           TYPE sy-datum,
        creationdate                TYPE sy-datum,
        cityname                    TYPE c LENGTH 40,
        region                      TYPE c LENGTH 3,
        orderquantity               TYPE p LENGTH 15 DECIMALS 3,
        openqty                     TYPE p LENGTH 15 DECIMALS 3,
        balance                     TYPE p LENGTH 15 DECIMALS 3,
        conditionamount             TYPE p LENGTH 15 DECIMALS 2,
        openvalues                  TYPE p LENGTH 15 DECIMALS 2,
        yy1_chainaccount_bus        TYPE c LENGTH 3,
        yy1_nationalaccount_bus     TYPE c LENGTH 3,
        yy1_norebateoffered_bus     TYPE c LENGTH 3,
        yy1_properties1_bus         TYPE c LENGTH 3,
        yy1_properties2_bus         TYPE c LENGTH 3,
      END OF ts_row,

      tt_row TYPE STANDARD TABLE OF ts_row WITH DEFAULT KEY.

    DATA lt_rows TYPE tt_row.

    lt_rows = CORRESPONDING #( it_data ).

    lo_worksheet->select( lo_selection_pattern
                )->row_stream(
                )->operation->write_from( REF #( lt_rows )
                )->execute( ).

    DATA(lv_file_content) = lo_write_access->get_file_content( ).
    ev_file_content = lv_file_content.

  ENDMETHOD.
ENDCLASS.
