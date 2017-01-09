# daq_closed_loop
matlab data acquisition toolboxも用いたサンプルです。
よくわかってませんがMITライセンスということにしてます。

## 処理の流れ
### 1. pre1_record_calibration.m
record calibration signals

### 2. pre2_cal_userdata.m
calculate calibration ratio/baseline to set real values from recorded voltages

### 3. pre3_view_cal_signal.m
view (calibration) signals to confirm the voltages are set accurately after running pre2_cal_userdata.m

### 4. pre4_record_resting_eeg.m
record resting eeg signals to estimate power spectra and to set threshold to put out TMS pulses.

### 5. main_closed_loop_session.m
main script:

1.  record eegs  
1.  calculate power value of a specific frequency  
1.  put out a pulse through parallel port when power value exceeds a predefined threshold  
1.  record MEPs

## todo
save/load settings between pre2 and pre3
