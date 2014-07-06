--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:39:58 07/06/2014
-- Design Name:   
-- Module Name:   /home/tansell/foss/buffer/hdl/triple_buffer_arbiter_tb.vhd
-- Project Name:  buffer
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: triple_buffer_arbiter
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY triple_buffer_arbiter_tb IS
END triple_buffer_arbiter_tb;
 
ARCHITECTURE behavior OF triple_buffer_arbiter_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT) 
    COMPONENT triple_buffer_arbiter
    generic (
         offset : integer;
         size   : integer;
         addr : integer := 32);
    PORT(
         input_clk : IN  std_logic;
         output_clk : IN  std_logic;
         input_addr : OUT  unsigned(7 downto 0);
         output_addr : OUT  unsigned(7 downto 0);
         rst : IN std_logic);
    END COMPONENT;
 

   --Inputs
   signal input_clk : std_logic := '0';
   signal output_clk : std_logic := '0';
   signal rst : std_logic := '0';

   signal evt : std_logic := '0';

   --Outputs
   signal input_addr : unsigned(7 downto 0);
   signal expected_input_addr : unsigned(7 downto 0);
   signal output_addr : unsigned(7 downto 0);
   signal expected_output_addr : unsigned(7 downto 0);

   -- Clock period definitions
   constant addr_delay : time := 5 ns;
   
   constant buffer0_addr : unsigned(7 downto 0) := to_unsigned(100, 8); 
   constant buffer1_addr : unsigned(7 downto 0) := to_unsigned(120, 8);
   constant buffer2_addr : unsigned(7 downto 0) := to_unsigned(140, 8);
BEGIN
 
   evt <= rst or input_clk or output_clk;
 
	-- Instantiate the Unit Under Test (UUT)
   uut: triple_buffer_arbiter
   GENERIC MAP (
     offset => 100,
     size => 20,
     addr => 8)
   PORT MAP (
     input_clk => input_clk,
     output_clk => output_clk,
     input_addr => input_addr,
     output_addr => output_addr,
     rst => rst);

   -- Stimulus process        
   stim_proc: process
   
     procedure Reset is
     begin
       wait for 35 ns;
       expected_input_addr <= "UUUUUUUU";
       expected_output_addr <= "UUUUUUUU";
       rst <= '1';
       wait for 1 ns;
       rst <= '0';
       wait for 35 ns;
     end procedure;
     
     procedure ExpectedInputAddr(
       constant expected_value : unsigned(7 downto 0)) is
     begin
       wait for 5 ns;
       input_clk <= '1';
       wait for addr_delay;
       expected_input_addr <= expected_value; 
     end procedure;

     procedure ExpectedInputClear is
     begin
       wait for 5 ns;
       input_clk <= '0';
       expected_input_addr <= "UUUUUUUU";
     end procedure;

     procedure ExpectedOutputAddr(
       constant expected_value : unsigned(7 downto 0)) is
     begin
       wait for 5 ns;     
       output_clk <= '1';
       wait for addr_delay;
       expected_output_addr <= expected_value;
     end procedure;
     
     procedure ExpectedOutputClear is
     begin
       wait for 5 ns;
       output_clk <= '0';
       expected_output_addr <= "UUUUUUUU";
     end procedure;   
   begin
      Reset;

      -- Write starts, should go to buffer0    
      ExpectedInputAddr(buffer0_addr);
      ExpectedInputClear;

      -- Write starts, should go to buffer1
      ExpectedInputAddr(buffer1_addr);
      ExpectedInputClear;
      
      -- Write starts, should go to buffer2
      ExpectedInputAddr(buffer2_addr);
      ExpectedInputClear;
      
      -- Write starts, should go to buffer0
      ExpectedInputAddr(buffer0_addr);
      ExpectedInputClear;
      
      -------------------------------------------------------------------
      -- Finished the initial write tests
      Reset;
      -------------------------------------------------------------------
      ExpectedInputAddr(buffer0_addr);
      ExpectedInputClear;
            
      -- Read, should get the last input_addr
      ExpectedOutputAddr(buffer0_addr);
      ExpectedOutputClear;
      
      -- Make sure read keeps getting the same addr
      ExpectedOutputAddr(buffer0_addr);
      ExpectedOutputClear;
      
      -- Advance the input buffer
      ExpectedInputAddr(buffer1_addr);
      ExpectedInputClear;

      -- Read should have advanced to the next addr
      ExpectedOutputAddr(buffer1_addr);
      ExpectedOutputClear;
      ExpectedOutputAddr(buffer1_addr);
      ExpectedOutputClear;
      
      -- Go around the buffer
      ----
      ExpectedInputAddr(buffer2_addr);
      ExpectedInputClear;
      --
      ExpectedOutputAddr(buffer2_addr);
      ExpectedOutputClear;
      ExpectedOutputAddr(buffer2_addr);
      ExpectedOutputClear;
      ----
      ExpectedInputAddr(buffer0_addr);
      ExpectedInputClear;
      --
      ExpectedOutputAddr(buffer0_addr);
      ExpectedOutputClear;
      ExpectedOutputAddr(buffer0_addr);
      ExpectedOutputClear;

      ----
      Reset;

      -- Write starts, should go to buffer0    
      ExpectedInputAddr(buffer0_addr);
      ExpectedInputClear;

      ExpectedInputAddr(buffer1_addr);
      
      ExpectedOutputAddr(buffer0_addr);
      ExpectedOutputClear;
      ExpectedOutputAddr(buffer0_addr);
      ExpectedOutputClear;

      ExpectedInputClear;
      ExpectedInputAddr(buffer2_addr);

      ExpectedOutputAddr(buffer1_addr);
      ExpectedOutputClear;

      ExpectedInputClear;
      ExpectedInputAddr(buffer0_addr);

      ExpectedOutputAddr(buffer2_addr);
      ExpectedOutputClear;
      ExpectedOutputAddr(buffer2_addr);
      ExpectedOutputClear;

      ExpectedInputClear;

      ExpectedOutputAddr(buffer0_addr);
      ExpectedOutputClear;

      
      -------------------------------------------------------------------
      -- Finished the initial read tests
      Reset;
      -------------------------------------------------------------------

      ExpectedInputAddr(buffer0_addr);
      ExpectedInputClear;

      -- Start reading from the first buffer, make sure the writer bounced 
      -- between the two remaining buffers
      ExpectedOutputAddr(buffer0_addr);

      ExpectedInputAddr(buffer1_addr);
      ExpectedInputClear;
      ExpectedInputAddr(buffer2_addr);
      ExpectedInputClear;
      ExpectedInputAddr(buffer1_addr);
      ExpectedInputClear;

      -- Release the reader, should write to buffer0 now
      ExpectedOutputClear;
      
      ExpectedInputAddr(buffer0_addr);
      ExpectedInputClear;      
      ExpectedInputAddr(buffer2_addr);
      ExpectedInputClear;
      ExpectedInputAddr(buffer1_addr);
      ExpectedInputClear;
      ExpectedInputAddr(buffer0_addr);
      ExpectedInputClear;      
      ExpectedInputAddr(buffer2_addr);
      ExpectedInputClear;
      
      -- Try again, except reading from buffer2
      ExpectedOutputAddr(buffer2_addr);
      
      ExpectedInputAddr(buffer1_addr);
      ExpectedInputClear;
      ExpectedInputAddr(buffer0_addr);
      ExpectedInputClear;
      ExpectedInputAddr(buffer1_addr);
      ExpectedInputClear;
      ExpectedInputAddr(buffer0_addr);
      ExpectedInputClear;      
      
      ExpectedOutputClear;
      
      ExpectedInputAddr(buffer2_addr);
      ExpectedInputClear;
      ExpectedInputAddr(buffer1_addr);      
      ExpectedInputClear;
      ExpectedInputAddr(buffer0_addr);
      ExpectedInputClear;
      ExpectedInputAddr(buffer2_addr);
      ExpectedInputClear;
      ExpectedInputAddr(buffer1_addr);      
      ExpectedInputClear;
      ExpectedInputAddr(buffer0_addr);
      ExpectedInputClear;
      
      --      
      Reset;
      wait;
   end process;

END;
