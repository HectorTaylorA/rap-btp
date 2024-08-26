CLASS zcl_delete_table_02 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DELETE_TABLE_02 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DELETE FROM zrent_brands_02.

    IF sy-subrc EQ 0.
      out->write( 'Todos los registros Eliminados').
    ENDIF.

  ENDMETHOD.
ENDCLASS.
