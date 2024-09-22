CLASS zzcl_sd_029 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

*    INTERFACES if_sadl_exit .
    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_SD_029 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA lt_original_data TYPE STANDARD TABLE OF zc_ssd058 WITH DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).
    SELECT *
    FROM zr_ssd059
    WHERE salesdocument IS NOT INITIAL
    INTO TABLE @DATA(lt_ssd059).
    SORT lt_ssd059 BY salesdocument salesdocumentitem.
    LOOP AT lt_ssd059 INTO DATA(ls_ssd059).
      READ TABLE lt_original_data  ASSIGNING FIELD-SYMBOL(<ls_original_data>) WITH KEY SalesDocument = ls_ssd059-SalesDocument
                                                                                       SalesDocumentItem = ls_ssd059-SalesDocumentItem BINARY SEARCH.
      IF sy-subrc = 0.
        IF <ls_original_data>-InvoiceNo IS NOT INITIAL.
          ls_ssd059-SubsequentDocument = |{ ls_ssd059-SubsequentDocument ALPHA = OUT }|.
          CONCATENATE <ls_original_data>-InvoiceNo ';' ls_ssd059-SubsequentDocument INTO <ls_original_data>-InvoiceNo.
          CONDENSE <ls_original_data>-InvoiceNo NO-GAPS.
        ELSE.
          <ls_original_data>-InvoiceNo = |{ ls_ssd059-SubsequentDocument ALPHA = OUT }|.
        ENDIF.
      ENDIF.
    ENDLOOP.
    SELECT *
    FROM zr_ssd060
    WHERE salesdocument IS NOT INITIAL
    INTO TABLE @DATA(lt_ssd060).
    SORT lt_ssd060 BY salesdocument salesdocumentitem.
    LOOP AT lt_ssd060 INTO DATA(ls_ssd060).
      READ TABLE lt_original_data  ASSIGNING <ls_original_data> WITH KEY SalesDocument = ls_ssd060-SalesDocument
                                                                         SalesDocumentItem = ls_ssd060-SalesDocumentItem BINARY SEARCH.
      IF sy-subrc = 0.
        IF <ls_original_data>-InvoiceDate IS NOT INITIAL.
          CONCATENATE <ls_original_data>-InvoiceDate ';' ls_ssd060-PostingDate INTO <ls_original_data>-InvoiceDate.
          CONDENSE <ls_original_data>-InvoiceDate NO-GAPS.
        ELSE.
          <ls_original_data>-InvoiceDate = ls_ssd060-PostingDate.
        ENDIF.
      ENDIF.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
