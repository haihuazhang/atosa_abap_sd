CLASS zzcl_sd_022 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object .
    INTERFACES if_apj_rt_exec_object .
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
    TYPES tt_data TYPE TABLE OF ZC_SSD048.
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

    TYPES ty_properties TYPE c LENGTH 5.
    TYPES ty_project TYPE c LENGTH 30.

    DATA properties TYPE RANGE OF ty_properties.
    DATA project TYPE RANGE OF ty_project.
    DATA sender TYPE c LENGTH 20.
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
    METHODS get_item_description RETURNING VALUE(rt_description) LIKE lt_return.

    METHODS write_to_excel IMPORTING it_data TYPE tt_data
                           EXPORTING ev_file_content TYPE zzattachment.
    METHODS send_email IMPORTING iv_attachment TYPE zzattachment.
ENDCLASS.



CLASS ZZCL_SD_022 IMPLEMENTATION.


  METHOD get_all_data.
    DATA: lt_data TYPE TABLE OF ZC_SSD048,
          lt_description LIKE lt_return,
          lv_sum_billingqty TYPE I_BillingDocumentItem-BillingQuantity.

    SELECT *
    FROM ZR_SSD048
    WHERE Properties IN @properties "( '102','103','104' )
      AND Project IN @project
    INTO CORRESPONDING FIELDS OF TABLE @lt_data.

    SELECT
        _SalesDocItmSubsqntProcFlow~SalesDocument,
        _SalesDocItmSubsqntProcFlow~SalesDocumentItem,
        _BillingDocumentItem~BillingQuantity
    FROM I_SalesDocItmSubsqntProcFlow WITH PRIVILEGED ACCESS AS _SalesDocItmSubsqntProcFlow
    INNER JOIN I_BillingDocumentItem WITH PRIVILEGED ACCESS AS _BillingDocumentItem
    ON _BillingDocumentItem~BillingDocument = _SalesDocItmSubsqntProcFlow~SubsequentDocument
        AND _BillingDocumentItem~BillingDocumentItem = _SalesDocItmSubsqntProcFlow~SubsequentDocumentItem
    INNER JOIN I_BillingDocument WITH PRIVILEGED ACCESS AS _BillingDocument
    ON _BillingDocument~BillingDocument = _BillingDocumentItem~BillingDocument
    WHERE _SalesDocItmSubsqntProcFlow~SubsequentDocumentCategory = 'M'
        AND _BillingDocument~BillingDocumentIsCancelled = ''
    INTO TABLE @DATA(lt_billing).

    SORT lt_billing BY SalesDocument SalesDocumentItem.

    lt_description = get_item_description(  ).
    SORT lt_description-d-results BY Product.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>).

        " ItemStatus
        READ TABLE lt_billing ASSIGNING FIELD-SYMBOL(<fs_billing>) WITH KEY SalesDocument = <lfs_data>-SalesOrderNumber
            SalesDocumentItem = <lfs_data>-SalesDocumentItem BINARY SEARCH.
        IF sy-subrc <> 0.
            <lfs_data>-ItemStatus = 'O'.
            <lfs_data>-RemainingQuantity = <lfs_data>-OrderedQauntity.
        ELSE.
            LOOP AT lt_billing ASSIGNING <fs_billing> FROM sy-tabix.
                IF <fs_billing>-SalesDocument <> <lfs_data>-SalesOrderNumber
                OR <fs_billing>-SalesDocumentItem <> <lfs_data>-SalesDocumentItem.
                    EXIT.
                ENDIF.

                lv_sum_billingqty += <fs_billing>-BillingQuantity.
            ENDLOOP.

            " RemainingQuantity
            <lfs_data>-RemainingQuantity = <lfs_data>-OrderedQauntity - lv_sum_billingqty.

            IF <lfs_data>-RemainingQuantity > 0.
                <lfs_data>-ItemStatus = 'O'.
            ELSE.
                <lfs_data>-ItemStatus = 'C'.
            ENDIF.

            CLEAR lv_sum_billingqty.
        ENDIF.

        " ItemDescription
        READ TABLE lt_description-d-results ASSIGNING FIELD-SYMBOL(<fs_description>)
        WITH KEY product = <lfs_data>-Product BINARY SEARCH.
        IF sy-subrc = 0.
            <lfs_data>-ItemDescription = <fs_description>-longtext.
        ELSE.
            SELECT SINGLE ProductName
            FROM I_ProductText WITH PRIVILEGED ACCESS AS _ProductText
            WHERE _ProductText~Product = @<lfs_data>-Product
                AND _ProductText~Language = 'E'
            INTO @<lfs_data>-ItemDescription.
        ENDIF.

        " UnitPrice
        TRY.
            <lfs_data>-UnitPrice = <lfs_data>-ItemTotal / <lfs_data>-OrderedQauntity.
        CATCH CX_SY_ZERODIVIDE.
            <lfs_data>-UnitPrice = 0.
        ENDTRY.

    ENDLOOP.

    " SalesOrderStatus
    DATA lv_sum_remaining_qty TYPE p LENGTH 8 DECIMALS 2.

    LOOP AT lt_data INTO DATA(ls_data)
    GROUP BY ( SalesOrderNumber = ls_data-SalesOrderNumber )
    ASSIGNING FIELD-SYMBOL(<lfs_group>).

        CLEAR lv_sum_remaining_qty.
        LOOP AT GROUP <lfs_group> ASSIGNING FIELD-SYMBOL(<lfs_member>).
            lv_sum_remaining_qty += <lfs_member>-RemainingQuantity.
        ENDLOOP.

        IF lv_sum_remaining_qty = 0.
            LOOP AT GROUP <lfs_group> ASSIGNING <lfs_member>.
                <lfs_member>-SalesOrderStatus = 'C'.
            ENDLOOP.
        ELSE.
            LOOP AT GROUP <lfs_group> ASSIGNING <lfs_member>.
                <lfs_member>-SalesOrderStatus = 'O'.
            ENDLOOP.
        ENDIF.
    ENDLOOP.

    et_data = lt_data.

  ENDMETHOD.


  METHOD get_item_description.
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
        EXIT.
    ENDTRY.

    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

        DATA(lo_request) = lo_http_client->get_http_request(   ).

        lo_http_client->enable_path_prefix( ).

        DATA(lv_path) = |/API_PRODUCT_SRV/A_ProductBasicText|.
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
              data = rt_description
          ).
        ENDIF.

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).

    ENDTRY.
  ENDMETHOD.


  METHOD get_parameters.
    LOOP AT it_parameters INTO DATA(ls_parameter).
        CASE ls_parameter-selname.
          WHEN 'S_Proper'.
            APPEND VALUE #( sign = ls_parameter-sign
                            option = ls_parameter-option
                            low = ls_parameter-low
                            high = ls_parameter-high ) TO properties.
          WHEN 'S_Proje'.
            APPEND VALUE #( sign = ls_parameter-sign
                            option = ls_parameter-option
                            low = ls_parameter-low
                            high = ls_parameter-high ) TO project.
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
      ( selname = 'S_Proper' kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 5 param_text = 'Properties' changeable_ind = abap_true )
      ( selname = 'S_Proje'    kind = if_apj_dt_exec_object=>select_option datatype = 'C' length = 30 param_text = 'Project' changeable_ind = abap_true )
      ( selname = 'P_Sender' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 20 param_text = 'Email of Sender' changeable_ind = abap_true )
      ( selname = 'P_Conf' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 30 param_text = 'Email Config Name' changeable_ind = abap_true )
      ( selname = 'P_Temp' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 30 param_text = 'Email Template Name' changeable_ind = abap_true )
      ( selname = 'P_Attach' kind = if_apj_dt_exec_object=>parameter datatype = 'C' length = 255 param_text = 'Attachment Name' changeable_ind = abap_true )
    ).

    " Return the default parameters values here
    et_parameter_val = VALUE #(
      ( selname = 'P_Attach' kind = if_apj_dt_exec_object=>parameter sign = 'I' option = 'EQ' low = 'Order Status Report' )
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
          low = 'Wendy@AtosaUSA.com' )
        ( selname = 'P_Subje'
          kind = if_apj_dt_exec_object=>parameter
          sign = 'I'
          option = 'EQ'
          low = 'Wendy’s and Franchisee Order Status Report' )
        ( selname = 'P_Conf'
          kind = if_apj_dt_exec_object=>parameter
          sign = 'I'
          option = 'EQ'
          low = 'LOB04-033' )
        ( selname = 'P_Temp'
          kind = if_apj_dt_exec_object=>parameter
          sign = 'I'
          option = 'EQ'
          low = 'Template_3' )
        ( selname = 'P_Attach'
          kind = if_apj_dt_exec_object=>parameter
          sign = 'I'
          option = 'EQ'
          low = 'Report Exported from S/4 in Excel Format' )
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
    lo_cursor->get_cell( )->value->write_from( 'Customer Code' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Customer Name' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Sales Order Number' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Order Entry Date' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Ship-to Store Number' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Buyer/Destination Contact Name' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Item Status' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Item Code' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Item Description' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Ship-from Warehouse' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Ordered Quantity' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Unit Price' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Item Total' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Remaining Quantity' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Sales Order Status' ).
    lo_cursor->move_right( )->get_cell( )->value->write_from( 'Project' ).

    TYPES:
        BEGIN OF ts_row,
            CustomerCode TYPE string,
            CustomerName TYPE string,
            SalesOrderNumber TYPE zzesd014,
            OrderEntryDate TYPE sy-datum,
            ShipToStoreNumber TYPE string,
            BuyerDestinationContactName TYPE string,
            ItemStatus TYPE c LENGTH 1,
            ItemCode TYPE string,
            ItemDescription TYPE string,
            ShipFromWarehouse TYPE string,
            OrderedQauntity TYPE p LENGTH 8 DECIMALS 3,
            UnitPrice TYPE p LENGTH 8 DECIMALS 2,
            ItemTotal TYPE p LENGTH 8 DECIMALS 2,
            RemainingQuantity TYPE p LENGTH 8 DECIMALS 2,
            SalesOrderStatus TYPE c LENGTH 1,
            Project TYPE string,
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
