onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {TBEN SIGNALS}
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/clk
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/reset
add wave -noupdate -format Logic -radix unsigned /fixed_spi_tben/rx_bytes
add wave -noupdate -format Logic -radix hexadecimal /fixed_spi_tben/data_in
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/data_in_dv
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/data_rdy
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/data_rd_en
add wave -noupdate -format Logic -radix hexadecimal /fixed_spi_tben/data_out
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/data_out_dv
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/send_trans
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/spi_clk
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/spi_mosi
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/spi_miso
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/spi_ss

add wave -noupdate -divider {DUT SIGNALS}
add wave -noupdate -format Logic -literal /fixed_spi_tben/dut/s_control_fsm_state
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_send_trans
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_send_trans_d1
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_send_trans_rising
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_rx_fifo_rst
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_rx_fifo_full
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_rx_fifo_empty
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_rx_fifo_wr_en
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_rx_fifo_wr_en_dly
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_rx_fifo_rd_en
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_rx_fifo_din
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_rx_fifo_dout
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_tx_fifo_full
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_tx_fifo_empty
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_tx_fifo_rd_en
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_tx_fifo_dout
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_shift_byte
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_data_in_dv
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_data_in_dv_d1
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_data_in_dv_rising
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_rx_bytes
add wave -noupdate -format Logic -radix unsigned /fixed_spi_tben/dut/s_byte_count
add wave -noupdate -format Logic -radix unsigned /fixed_spi_tben/dut/s_shift_counter
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_spi_clk_div_reg
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_spi_clk
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_clk_out_en
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_clk_out_en_d1
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_spi_clk_gated
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_spi_clk_d1
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_spi_clk_rising
add wave -noupdate -format Logic -radix binary /fixed_spi_tben/dut/s_spi_clk_falling


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {50 ns}
WaveRestoreZoom {0 ns} {100 ns}
#WaveRestoreZoom {3556293 ps} {3862703 ps}
configure wave -namecolwidth 500
configure wave -valuecolwidth 77
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
