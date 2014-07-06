----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:11:53 07/06/2014 
-- Design Name: 
-- Module Name:    buffer - buffer_arch 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity triple_buffer_top is
    Port ( 
        in_clk : in  STD_LOGIC;
        in_data : in  STD_LOGIC_VECTOR (8 downto 0);
	in_stall : out STD_LOGIC;
	out_clk  : in  STD_LOGIC;
        out_data : out  STD_LOGIC_VECTOR (8 downto 0);
	out_stall : out STD_LOGIC);
end triple_buffer_top;

architecture buffer_arch of triple_buffer_top is

begin


end buffer_arch;