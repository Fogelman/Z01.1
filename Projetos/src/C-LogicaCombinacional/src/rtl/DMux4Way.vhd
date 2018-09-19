library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DMux4Way is
	port (
			a:   in  STD_LOGIC;
			sel: in  STD_LOGIC_VECTOR(1 downto 0);
			q0:  out STD_LOGIC;
			q1:  out STD_LOGIC;
			q2:  out STD_LOGIC;
			q3:  out STD_LOGIC);
end entity;
architecture rtl of DMux4Way is
begin
	process (a,sel) is
	begin
		if (sel="00") then q0 <= a ; else q0 <= '0';
		end if;
		if (sel="01") then q1 <= a ; else q1 <= '0';
		end if;
		if (sel="10") then q2 <= a ; else q2 <= '0';
		end if;
		if (sel="11") then q3 <= a ; else q3 <= '0';
		end if;
	end process;
end rtl;
