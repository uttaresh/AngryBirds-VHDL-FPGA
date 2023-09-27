-- Entity to obtain launch angle and velocity from keyboard input
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std;

entity Slingshot is
	Port (	Slingshot_Clk, Reset, C : in std_logic;
			w, s : in std_logic;	-- w for increase, s for decrease angle
			a, d : in std_logic;	-- d for increase velocity, a for decrease velocity
			
			vel	: out std_logic_vector(2 downto 0);
			vel_x, vel_y : out std_logic_vector(8 downto 0); -- 1024 requires 11 bits + 1 for sign
			angle: out std_logic_vector (7 downto 0) ); -- The launch angle and velocity, as displayed on 7-seg LEDs
end Slingshot;

architecture Behavioral of Slingshot is
	
-- Define a temp signal for angle, use it to calculate the angle to
-- extreme precision so you can actually change it while W or S are
-- pressed down. Then get the sig figs we want.
signal precise_angle : std_logic_vector(7 downto 0) := x"00";

signal sin_val, cos_val : std_logic_vector(5 downto 0) := "000000";

signal velocity : std_logic_vector(2 downto 0) := "000";

signal precise_vel_x, precise_vel_y : std_logic_vector(8 downto 0);
	
begin
	-- This process is used to change the angle based on keyboard input
	get_angle : process (Reset, Slingshot_Clk, w, s, C)
	begin
		if (Reset = '1') then
			precise_angle <= x"00";	-- xD3 is -45 degrees (up)
		elsif (rising_edge(Slingshot_Clk) and C='1') then
			if (s = '1') then	-- down is positive on screen
				if ( ( precise_angle < x"5A" ) or ( precise_angle >= x"A6") ) then	-- xA6 is -90, 
					precise_angle <= precise_angle + "11";							-- x5A is +90
				else
					precise_angle <= precise_angle;
				end if;
			elsif (w = '1') then	-- up is negative on screen
				if ((precise_angle > x"A6") or (precise_angle <= x"5A")) then
					precise_angle <= precise_angle + x"FD";
				else
					precise_angle <= precise_angle;
				end if;
			else
				precise_angle <= precise_angle;
			end if;
		end if;
	end process;
	angle <= precise_angle;	
	
	-- This process is used to change launch velocity based on keyboard input
	get_velocity : process (Reset, Slingshot_Clk, a, d)
	begin
		if (Reset = '1') then
			velocity <= "000";
		elsif (rising_edge(Slingshot_Clk) and C='1') then
			if (a = '1' and velocity > "000") then		-- min vel is 0
				velocity <= velocity + "111";
			elsif (d = '1' and velocity < "111" ) then	-- max vel is 7
				velocity <= velocity + "001";
			else
				velocity <= velocity;
			end if;
		end if;
	end process get_velocity;
	
	-- Used to look up the value of 1024*sin(angle) and 1024*cos(angle)
	calc_values : process (velocity, precise_angle, Slingshot_Clk, C)
	begin
		if (C='1' and rising_edge(Slingshot_Clk)) then
			if (precise_angle=x"00") then
				sin_val <= "000000";
				cos_val <= "100000";
			elsif (precise_angle=x"03" or precise_angle=x"FD") then
				sin_val <= "000001";
				cos_val <= "011111";
			elsif (precise_angle=x"06" or precise_angle=x"FA") then
				sin_val <= "000011";
				cos_val <= "011111";
			elsif (precise_angle=x"09" or precise_angle=x"F7") then
				sin_val <= "000101";
				cos_val <= "011111";
			elsif (precise_angle=x"0C" or precise_angle=x"F4") then
				sin_val <= "000110";
				cos_val <= "011111";
			elsif (precise_angle=x"0F" or precise_angle=x"F1") then
				sin_val <= "001000";
				cos_val <= "011110";
			elsif (precise_angle=x"12" or precise_angle=x"EE") then
				sin_val <= "001001";
				cos_val <= "011110";
			elsif (precise_angle=x"15" or precise_angle=x"EB") then
				sin_val <= "001011";
				cos_val <= "011101";
			elsif (precise_angle=x"18" or precise_angle=x"E8") then
				sin_val <= "001101";
				cos_val <= "011101";
			elsif (precise_angle=x"1B" or precise_angle=x"E5") then
				sin_val <= "001110";
				cos_val <= "011100";
			elsif (precise_angle=x"1E" or precise_angle=x"E2") then
				sin_val <= "001111";
				cos_val <= "011011";
			elsif (precise_angle=x"21" or precise_angle=x"DF") then
				sin_val <= "010001";
				cos_val <= "011010";
			elsif (precise_angle=x"24" or precise_angle=x"DC") then
				sin_val <= "010010";
				cos_val <= "011001";
			elsif (precise_angle=x"27" or precise_angle=x"D9") then
				sin_val <= "010100";
				cos_val <= "011000";
			elsif (precise_angle=x"2A" or precise_angle=x"D6") then
				sin_val <= "010101";
				cos_val <= "010111";
			elsif (precise_angle=x"2D" or precise_angle=x"D3") then
				sin_val <= "010110";
				cos_val <= "010110";
			elsif (precise_angle=x"30" or precise_angle=x"D0") then
				sin_val <= "010111";
				cos_val <= "010101";
			elsif (precise_angle=x"33" or precise_angle=x"CD") then
				sin_val <= "011000";
				cos_val <= "010100";
			elsif (precise_angle=x"36" or precise_angle=x"CA") then
				sin_val <= "011001";
				cos_val <= "010010";
			elsif (precise_angle=x"39" or precise_angle=x"C7") then
				sin_val <= "011010";
				cos_val <= "010001";
			elsif (precise_angle=x"3C" or precise_angle=x"C4") then
				sin_val <= "011011";
				cos_val <= "010000";
			elsif (precise_angle=x"3F" or precise_angle=x"C1") then
				sin_val <= "011100";
				cos_val <= "001110";
			elsif (precise_angle=x"42" or precise_angle=x"BE") then
				sin_val <= "011101";
				cos_val <= "001101";
			elsif (precise_angle=x"45" or precise_angle=x"BB") then
				sin_val <= "011101";
				cos_val <= "001011";
			elsif (precise_angle=x"48" or precise_angle=x"B8") then
				sin_val <= "011110";
				cos_val <= "001001";
			elsif (precise_angle=x"4B" or precise_angle=x"B5") then
				sin_val <= "011110";
				cos_val <= "001000";
			elsif (precise_angle=x"4E" or precise_angle=x"B2") then
				sin_val <= "011111";
				cos_val <= "000110";
			elsif (precise_angle=x"51" or precise_angle=x"AF") then
				sin_val <= "011111";
				cos_val <= "000101";
			elsif (precise_angle=x"54" or precise_angle=x"AC") then
				sin_val <= "011111";
				cos_val <= "000011";
			elsif (precise_angle=x"57" or precise_angle=x"A9") then
				sin_val <= "011111";
				cos_val <= "000001";
			elsif (precise_angle=x"5A" or precise_angle=x"A6") then
				sin_val <= "100000";
				cos_val <= "000000";
			end if;
		end if;
	end process;
	
	-- This process is used to calculate the x- and y- components of the velocity:
	get_comps : process (Reset, Slingshot_Clk, sin_val, cos_val, velocity, C)
	begin
		if (C='1' and rising_edge(Slingshot_Clk)) then
			precise_vel_x <= (velocity * cos_val);
			precise_vel_y <= (velocity * sin_val);	
		end if;
	end process get_comps;
	vel_x <= precise_vel_x;
	vel_y <= precise_vel_y;
	vel <= velocity;
	
end Behavioral;
