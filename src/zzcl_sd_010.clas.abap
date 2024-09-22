CLASS zzcl_sd_010 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_010 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF zc_ssd027 WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).
    SELECT *
    FROM zr_ssd028
    WHERE billingdocument IS NOT INITIAL
    INTO TABLE @DATA(lt_ssd028).
    LOOP AT lt_ssd028 INTO DATA(ls_ssd028).
      READ TABLE lt_original_data  ASSIGNING FIELD-SYMBOL(<ls_original_data>) WITH KEY billingdocument = ls_ssd028-billingdocument
                                                                        billingdocumentitem = ls_ssd028-billingdocumentitem.
      IF sy-subrc = 0.
        IF <ls_original_data>-serialnumber IS NOT INITIAL.
          ls_ssd028-SerialNumber = |{ ls_ssd028-SerialNumber ALPHA = OUT }|.
          CONCATENATE <ls_original_data>-serialnumber ',' ls_ssd028-serialnumber INTO <ls_original_data>-serialnumber.
          CONDENSE <ls_original_data>-SerialNumber NO-GAPS.
        ELSE.
          <ls_original_data>-serialnumber = |{ ls_ssd028-serialnumber ALPHA = OUT }|.
        ENDIF.
      ENDIF.
*      IF ls_original_data IS NOT INITIAL.
*      MODIFY lt_original_data FROM ls_original_data.
*      ENDIF.
*      CLEAR:ls_ssd028,ls_original_data.
    ENDLOOP.
*    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
*
*    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'SERIALNUMBER'.
          INSERT `BILLINGDOCUMENT` INTO TABLE et_requested_orig_elements.

*        WHEN 'ANOTHERELEMENT'.
*          INSERT `` ...

        WHEN OTHERS.
*          RAISE EXCEPTION TYPE /dmo/cx_virtual_elements
*            EXPORTING
*              textid  = /dmo/cx_virtual_elements=>virtual_element_not_known
*              element = <fs_calc_element>
*              entity  = iv_entity.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
