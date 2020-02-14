# fifo_out_sync_xpm_id

Parametrized syncronous fifo with support TID field transmission, based upon Xilinx XPM macros

## GENERIC PARAMETERS:
Next parameters can be configured: 
* `DATA_WIDTH`
_width of data bus, such using for calculate TKEEP width. Must be multiple to 8 bits_

* `MEMTYPE` 
_type of using memory can be next: _
1) "block"
2) "distributed"
3) "auto"
4) "ultra"

* `DEPTH` 

_number of words in FIFO_

* `ID_WIDTH` 

_width of TID field(uses in OUT_DIN_ID, M_AXIS_TID signals_

* `PROG_FULL_THRESH`

_Value for assert signal prog_full, which presented as output from FIFO_ 