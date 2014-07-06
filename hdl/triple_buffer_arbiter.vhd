----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:18:22 07/06/2014 
-- Design Name: 
-- Module Name:    triple_buffer_arbiter - triple_buffer_arbiter_arch 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity triple_buffer_arbiter is 
  generic (
    offset : integer;
    size   : integer;
    addr : integer := 32);
  port (
    input_clk : in std_logic;
    output_clk : in std_logic;
    input_addr : out unsigned(addr-1 downto 0);
    output_addr : out unsigned(addr-1 downto 0);
    rst : in std_logic);
end triple_buffer_arbiter;


architecture triple_buffer_arbiter_arch of triple_buffer_arbiter is
  constant lock_initial : unsigned(1 downto 0) := "11";
  signal input_lock: unsigned(1 downto 0);
  signal output_lock: unsigned(1 downto 0);

  signal n0_buffer: unsigned(1 downto 0);
  signal n1_buffer: unsigned(1 downto 0);
  signal n2_buffer: unsigned(1 downto 0);
  
  constant buffer0: unsigned(1 downto 0) := "00";
  constant buffer1: unsigned(1 downto 0) := "01";
  constant buffer2: unsigned(1 downto 0) := "10";
  
  constant buffer0_addr : unsigned(addr-1 downto 0) := to_unsigned(offset, addr);
  constant buffer1_addr : unsigned(addr-1 downto 0) := to_unsigned(offset + size, addr);
  constant buffer2_addr : unsigned(addr-1 downto 0) := to_unsigned(offset + size * 2, addr);

  signal okay: std_logic := '1';

begin
  okay_process: process (input_lock) is
  begin
    case n2_buffer & n1_buffer & n0_buffer is
      when buffer0 & buffer1 & buffer2 =>
        okay <= '1';
      when buffer2 & buffer0 & buffer1 =>
        okay <= '1';
      when buffer1 & buffer2 & buffer0 =>
        okay <= '1';
      when buffer0 & buffer2 & buffer1 =>
        okay <= '1';
      when buffer1 & buffer0 & buffer2 =>
        okay <= '1';
      when buffer2 & buffer1 & buffer0 =>
        okay <= '1';
      when others =>
        okay <= '0';
    end case;    
  end process okay_process;
  
  -- Locking a buffer for input generates the address on input_addr
  input_addr_process: process (input_lock) is
  begin
    case input_lock is
      when buffer0 =>
	input_addr <= buffer0_addr;
      when buffer1 =>
	input_addr <= buffer1_addr;
      when buffer2 =>
	input_addr <= buffer2_addr;
      when others =>
        input_addr <= "UUUUUUUU";
    end case;
  end process input_addr_process;  

  -- Locking a buffer for output generates the address on output_addr
  output_addr_process: process (output_lock) is
  begin
    case output_lock is
      when buffer0 =>
	output_addr <= buffer0_addr;
      when buffer1 =>
	output_addr <= buffer1_addr;
      when buffer2 =>
	output_addr <= buffer2_addr;
      when others =>
        output_addr <= "UUUUUUUU";
    end case;
  end process output_addr_process;  

  input_process: process (input_clk, rst) is
  begin
    -- Reset
    if rising_edge(rst) then
      input_lock <= lock_initial;
      
      n0_buffer <= buffer2;
      n1_buffer <= buffer1;
      n2_buffer <= buffer0;
    end if;

    -- On falling edge, update buffer ages and unlock.
    if falling_edge(input_clk) then
      -- Update buffer ages
      if (n2_buffer /= output_lock) then
        n2_buffer <= n1_buffer;
      end if;
      n1_buffer <= n0_buffer;    
      n0_buffer <= input_lock;
      
      -- Unlock the buffers
      input_lock <= lock_initial;
    end if;
    
    -- On falling edge, unlock buffers.
    if rising_edge(input_clk) then
      -- Figure out the oldest unlocked buffer to use.
      if (n2_buffer /= output_lock) then
        input_lock <= n2_buffer;
      else
        input_lock <= n1_buffer;
      end if;
    end if;
  end process input_process;

  output_process: process (output_clk, rst) is
  begin
    -- Reset
    if rising_edge(rst) then
      output_lock <= lock_initial;
    end if;

    -- On falling edge, unlock buffer.
    if falling_edge(output_clk) then
      output_lock <= lock_initial;
    end if;
    
    -- On rising edge, find the newest buffer and lock for reading.
    if rising_edge(output_clk) then
      -- Figure out the newest buffer to use.
      if (n0_buffer /= input_lock) then
        output_lock <= n0_buffer;
      else
        output_lock <= n1_buffer;
      end if;
    end if;
  end process output_process;

end triple_buffer_arbiter_arch;

