-------------------------------------------------------------------------------
--   File Name:             fixed_spi.vhd
--   Type:                  RTL
--   Contributing authors:  J. Tuthill
--   Created:               Wed Aug 09 15:03:08 2023
--   Template Rev:          1.0
--
--   Title:                 Fixed-format SPI interface driver.
--   Description: 
--   
--   
--
--   
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-------------------------------------------------------------------------------
entity fixed_spi is
   port (
      clk   : in std_logic;
      reset : in std_logic;

      -- parallel data interface
      rx_bytes    : in  std_logic_vector(6 downto 0);
      data_in     : in  std_logic_vector(7 downto 0);
      data_in_dv  : in  std_logic;
      data_rdy    : out std_logic;
      data_rd_en  : in  std_logic;
      data_out    : out std_logic_vector(7 downto 0);
      data_out_dv : out std_logic;

      -- control signals
      send_trans : in std_logic;

      -- serial data interface
      spi_clk  : out std_logic;
      spi_mosi : out std_logic;
      spi_miso : in  std_logic;
      spi_ss   : out std_logic
      );
end fixed_spi;

-------------------------------------------------------------------------------
architecture rtl of fixed_spi is


   ---------------------------------------------------------------------------
   --                 CONSTANT, TYPE AND GENERIC DEFINITIONS                --
   ---------------------------------------------------------------------------

   -- power of 2 clock divider for the SPI clock
   constant c_clk_div_spi : integer := 4;

   type t_control_fsm is (idle_st,
                          assert_chip_select_st,
                          enable_output_clk_st,
                          shift_out_st,
                          read_fifo_wait_st,
                          load_next_byte_st,
                          shift_in_st,
                          check_byte_count_st,
                          end_spi_st);

   ---------------------------------------------------------------------------
   --                          SIGNAL DECLARATIONS                          --
   ---------------------------------------------------------------------------

   signal s_control_fsm_state : t_control_fsm                := idle_st;
   signal s_reset             : std_logic                    := '0';
   signal s_send_trans        : std_logic                    := '0';
   signal s_send_trans_reg    : std_logic                    := '0';
   signal s_send_trans_d1     : std_logic                    := '0';
   signal s_send_trans_rising : std_logic;
   signal s_rx_fifo_rst       : std_logic                    := '0';
   signal s_rx_fifo_full      : std_logic;
   signal s_rx_fifo_empty     : std_logic;
   signal s_rx_fifo_wr_en     : std_logic                    := '0';
   signal s_rx_fifo_rd_en     : std_logic;
   signal s_rx_fifo_din       : std_logic_vector(7 downto 0) := (others => '0');
   signal s_rx_fifo_dout      : std_logic_vector(7 downto 0);
   signal s_spi_read_trans    : std_logic                    := '0';
   signal s_spi_trans_done    : std_logic                    := '0';
   signal s_tx_fifo_full      : std_logic;
   signal s_tx_fifo_empty     : std_logic;
   signal s_tx_fifo_rd_en     : std_logic;
   signal s_tx_fifo_dout      : std_logic_vector(7 downto 0);
   signal s_shift_byte        : std_logic_vector(7 downto 0) := (others => '0');
   signal s_data_in_dv        : std_logic                    := '0';
   signal s_data_in_dv_d1     : std_logic                    := '0';
   signal s_data_in_dv_rising : std_logic;
   signal s_rx_bytes          : unsigned(6 downto 0)         := (others => '0');
   signal s_byte_count        : unsigned(6 downto 0)         := (others => '0');
   signal s_shift_counter     : unsigned(3 downto 0)         := (others => '0');
   signal s_spi_clk_div_reg   : unsigned(7 downto 0)         := (others => '0');
   signal s_spi_clk           : std_logic                    := '0';
   signal s_clk_out_en        : std_logic                    := '0';
   signal s_clk_out_en_d1     : std_logic                    := '0';
   signal s_spi_clk_d1        : std_logic                    := '0';
   signal s_spi_clk_rising    : std_logic;
   signal s_spi_clk_falling   : std_logic;
   signal s_spi_chip_sel      : std_logic                    := '0';
   signal s_spi_ss            : std_logic                    := '0';
   signal s_spi_clk_gated     : std_logic                    := '0';
   signal s_spi_mosi          : std_logic                    := '0';

   -- DEBUG
   attribute mark_debug                        : string;
   attribute mark_debug of s_send_trans_rising : signal is "true";
   attribute mark_debug of s_spi_ss            : signal is "true";
   attribute mark_debug of s_spi_clk_gated     : signal is "true";
   attribute mark_debug of s_spi_mosi          : signal is "true";
   attribute mark_debug of s_rx_fifo_din       : signal is "true";
   attribute mark_debug of s_rx_fifo_wr_en     : signal is "true";
   attribute mark_debug of s_rx_fifo_rd_en     : signal is "true";
   attribute mark_debug of s_rx_fifo_dout      : signal is "true";
   attribute mark_debug of data_in             : signal is "true";
   attribute mark_debug of data_in_dv          : signal is "true";
   attribute mark_debug of s_send_trans        : signal is "true";

   ---------------------------------------------------------------------------
   --                        COMPONENT DECLARATIONS                         --
   ---------------------------------------------------------------------------

   component tx_fifo
      port (
         clk   : in  std_logic;
         srst  : in  std_logic;
         din   : in  std_logic_vector(7 downto 0);
         wr_en : in  std_logic;
         rd_en : in  std_logic;
         dout  : out std_logic_vector(7 downto 0);
         full  : out std_logic;
         empty : out std_logic);
   end component;

   component rx_fifo
      port (
         clk   : in  std_logic;
         srst  : in  std_logic;
         din   : in  std_logic_vector(7 downto 0);
         wr_en : in  std_logic;
         rd_en : in  std_logic;
         dout  : out std_logic_vector(7 downto 0);
         full  : out std_logic;
         empty : out std_logic);
   end component;

begin


   ---------------------------------------------------------------------------
   --                    INSTANTIATE COMPONENTS                             --
   ---------------------------------------------------------------------------
   -- TX FIFO is 32 deep
   tx_fifo_1 : tx_fifo
      port map (
         clk   => clk,
         srst  => s_reset,
         din   => data_in,
         wr_en => data_in_dv,
         rd_en => s_tx_fifo_rd_en,
         dout  => s_tx_fifo_dout,
         full  => s_tx_fifo_full,
         empty => s_tx_fifo_empty);

   -- RX FIFO is 128 deep
   rx_fifo_1 : rx_fifo
      port map (
         clk   => clk,
         srst  => s_rx_fifo_rst,
         din   => s_rx_fifo_din,
         wr_en => s_rx_fifo_wr_en,
         rd_en => data_rd_en,
         dout  => s_rx_fifo_dout,
         full  => s_rx_fifo_full,
         empty => s_rx_fifo_empty);

   ---------------------------------------------------------------------------
   --                      CONCURRENT SIGNAL ASSIGNMENTS                    --
   ---------------------------------------------------------------------------

   -- detect the rising edge of the send transaction signal
   s_send_trans_rising <= s_send_trans and not(s_send_trans_d1);

   -- detect the rising edge of the incoming data valid signal
   s_data_in_dv_rising <= s_data_in_dv and not(s_data_in_dv_d1);

   -- detect the rising edge of the SPI clock
   s_spi_clk_rising  <= s_spi_clk and not(s_spi_clk_d1);
   s_spi_clk_falling <= not(s_spi_clk) and s_spi_clk_d1;

   -- parallel interface outputs
   data_rdy    <= s_spi_trans_done and not(s_rx_fifo_empty);
   data_out    <= s_rx_fifo_dout;
   data_out_dv <= s_rx_fifo_rd_en;

   -- serial interface outputs
   spi_clk  <= s_spi_clk_gated;
   spi_mosi <= s_spi_mosi;
   spi_ss   <= s_spi_ss;

   ---------------------------------------------------------------------------
   --                         CONCURRENT PROCESSES                          --
   ---------------------------------------------------------------------------

   ---------------------------------------------------------------------------
   --  Process:  FIXED_SPI_PROCESS  
   --  Purpose:  
   --  Inputs:   
   --  Outputs:  
   ---------------------------------------------------------------------------
   fixed_spi_process : process (clk)

   begin
      if rising_edge(clk) then
         -- register inputs
         s_reset         <= reset;
         s_data_in_dv    <= data_in_dv;
         s_data_in_dv_d1 <= s_data_in_dv;
         s_send_trans    <= send_trans;
         s_send_trans_d1 <= s_send_trans;

         -- register the RX transaction length in bytes on the rising edge of
         -- the data valid signal (rx_bytes needs to be held constant for all
         -- the incoming data valids or at least for the last one)
         if (s_reset = '1') then
            s_rx_bytes <= (others => '0');
         elsif (s_data_in_dv_rising = '1') then
            s_rx_bytes <= unsigned(rx_bytes);
         end if;

         -- latch the send transaction signal
         if ((s_reset = '1') or (s_control_fsm_state = assert_chip_select_st)) then
            s_send_trans_reg <= '0';
         elsif (s_send_trans_rising = '1') then
            s_send_trans_reg <= '1';
         end if;

         -- SPI clock divider
         if (s_reset = '1') then
            s_spi_clk_div_reg <= (others => '0');
         else
            s_spi_clk_div_reg <= s_spi_clk_div_reg + 1;
         end if;
         s_spi_clk    <= s_spi_clk_div_reg(c_clk_div_spi);
         s_spi_clk_d1 <= s_spi_clk;


         -- RX FIFO reset signal
         -- reset on input reset signal or on rising edge of the send transaction signal
         s_rx_fifo_rst <= s_reset or s_send_trans_rising;

         -- finite state machine
         if (s_reset = '1') then
            s_control_fsm_state <= idle_st;
            s_clk_out_en        <= '0';
            s_spi_read_trans    <= '0';
            s_shift_byte        <= (others => '0');
            s_rx_fifo_din       <= (others => '0');
            s_shift_counter     <= (others => '0');
            s_spi_chip_sel      <= '0';
            s_rx_fifo_wr_en     <= '0';
         else
            case s_control_fsm_state is
               when idle_st =>
                  s_clk_out_en    <= '0';
                  s_tx_fifo_rd_en <= '0';
                  s_rx_fifo_wr_en <= '0';
                  if ((s_send_trans_reg = '1') and (s_spi_clk_rising = '1')) then
                     s_tx_fifo_rd_en     <= '1';
                     s_control_fsm_state <= assert_chip_select_st;
                  end if;

               -- assert the output chip (slave) select signal
               when assert_chip_select_st =>
                  s_tx_fifo_rd_en <= '0';
                  s_spi_chip_sel  <= '1';
                  if (s_spi_clk_falling = '1') then
                     s_clk_out_en        <= '1';
                     s_spi_read_trans    <= s_tx_fifo_dout(7);
                     s_shift_byte        <= s_tx_fifo_dout;
                     s_shift_counter     <= to_unsigned(7, 4);
                     s_control_fsm_state <= enable_output_clk_st;
                  end if;

               -- enable the output SPI serial clock to the ADC devices
               when enable_output_clk_st =>
                  if (s_spi_clk_rising = '1') then
                     if (s_spi_read_trans = '0') then  -- SPI WRITE transaction
                        s_control_fsm_state <= shift_out_st;
                     else                              -- SPI READ transaction
                        s_byte_count        <= s_rx_bytes;
                        s_rx_fifo_din       <= (others => '0');
                        s_control_fsm_state <= shift_out_st;
                     end if;
                  end if;

               -- shift bytes out to the serial interface MSB first
               -- only the first command/address byte is shifted out for a read
               -- operation
               when shift_out_st =>
                  if (s_spi_clk_rising = '1') then
                     if (s_shift_counter = "0000") then
                        s_shift_byte <= (others => '0');
                        if (s_spi_read_trans = '1') then
                           s_shift_counter     <= to_unsigned(7, 4);
                           s_control_fsm_state <= shift_in_st;
                        else
                           if (s_tx_fifo_empty = '0') then
                              s_tx_fifo_rd_en     <= '1';
                              s_control_fsm_state <= read_fifo_wait_st;
                           else
                              s_clk_out_en        <= '0';
                              s_control_fsm_state <= end_spi_st;
                           end if;
                        end if;
                     else
                        s_shift_byte(7 downto 0) <= s_shift_byte(6 downto 0) & '0';
                        s_shift_counter          <= s_shift_counter - 1;
                     end if;
                  end if;

               -- single clock cycle wait state for the data to become
               -- available at the TX FIFO output
               when read_fifo_wait_st =>
                  s_tx_fifo_rd_en     <= '0';
                  s_control_fsm_state <= load_next_byte_st;

               -- load the next byte to be shifted out from the TX FIFO
               when load_next_byte_st =>
                  s_shift_byte        <= s_tx_fifo_dout;
                  s_shift_counter     <= to_unsigned(7, 4);
                  s_control_fsm_state <= shift_out_st;

               -- shift in bits from the serial interface into the RX byte (MSB
               -- first and write them to the RX FIFO
               when shift_in_st =>
                  if (s_spi_clk_falling = '1') then
                     s_rx_fifo_din(0)          <= spi_miso;
                     s_rx_fifo_din(7 downto 1) <= s_rx_fifo_din(6 downto 0);
                     if (s_shift_counter = "0000") then
                        s_rx_fifo_wr_en     <= '1';
                        s_byte_count        <= s_byte_count - 1;
                        s_control_fsm_state <= check_byte_count_st;
                     else
                        s_shift_counter <= s_shift_counter - 1;
                     end if;
                  end if;

               -- stop reading from the interface once the required bytes have
               -- been received
               when check_byte_count_st =>
                  s_rx_fifo_wr_en <= '0';
                  s_rx_fifo_din   <= (others => '0');
                  if (s_byte_count = "0000000") then
                     s_spi_chip_sel      <= '0';
                     s_control_fsm_state <= end_spi_st;
                  else
                     s_shift_counter     <= to_unsigned(7, 4);
                     s_control_fsm_state <= shift_in_st;
                  end if;

               -- end the SPI interface transaction
               when end_spi_st =>
                  s_spi_chip_sel      <= '0';
                  s_control_fsm_state <= idle_st;

               -- unhandled states go to idle
               when others =>
                  s_control_fsm_state <= idle_st;
                  
            end case;

            -- generate the transaction done signal
            if ((s_reset = '1') or (s_control_fsm_state = assert_chip_select_st)) then
               s_spi_trans_done <= '0';
            elsif (s_control_fsm_state = end_spi_st) then
               s_spi_trans_done <= '1';
            end if;

            -- register the RX FIFO read enable FIFO to account for the read latency
            s_rx_fifo_rd_en <= data_rd_en;


            -- register the serial interface outputs
            s_clk_out_en_d1 <= s_clk_out_en;
            s_spi_clk_gated <= s_spi_clk_d1 and s_clk_out_en and s_clk_out_en_d1;
            s_spi_mosi      <= s_shift_byte(7);
            s_spi_ss        <= not(s_spi_chip_sel);
            
         end if;  -- if (s_reset = '1')


      end if;  -- if rising_edge(clk)

   end process fixed_spi_process;

end rtl;
-------------------------------------------------------------------------------
