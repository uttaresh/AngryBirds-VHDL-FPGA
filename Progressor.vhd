-- Progressor. We use this entity to control the motion of the
-- moving bird/bird.
---------------------------------------------------------------------------
---------------------------------------------------------------------------
--    Progressor.vhd                                                     --
--                                                            			 --
--    Modified from Bird.vhd as provided for Lab 8, ECE 385 Spring 2013	 --
--    which was created by Viral Mehta, and was modified by Stephen 	 --
--	  Kempf																 --
---------------------------------------------------------------------------
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Progressor is
   Port (	------INPUTS-------
			M, up : in std_logic; -- Control signal from state machine
			init_vel_x, init_vel_y : in std_logic_vector(8 downto 0); -- Launch velocities from Slingshot
			    
			Reset : in std_logic;
			frame_clk : in std_logic;	
			
			-- Piggie start locations and sizes:
			Pig1X, Pig1Y, Pig1_Size : in std_logic_vector(9 downto 0);
			Pig2X, Pig2Y, Pig2_Size : in std_logic_vector(9 downto 0);
			Pig3X, Pig3Y, Pig3_Size : in std_logic_vector(9 downto 0);
			
			
			------OUTPUTS------
			hit,miss : out std_logic;
			which_pigs : out std_logic_vector(2 downto 0); -- which piggies were hit?
			BirdX : out std_logic_vector(9 downto 0);
			BirdY : out std_logic_vector(9 downto 0);
			BirdS : out std_logic_vector(9 downto 0));
end Progressor;

architecture Behavioral of Progressor is

signal Bird_X_pos, Bird_Y_pos : std_logic_vector(14 downto 0);
signal Bird_Size : std_logic_vector(9 downto 0);
--signal frame_clk_div : std_logic_vector(5 downto 0);

constant Bird_X_Start : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(80, 10);  --Bird start position on the X axis
constant Bird_Y_Start : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(400, 10);  --Bird start position on the Y axis

constant Bird_X_Min    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(3, 10);  --Leftmost point on the X axis
constant Bird_X_Max    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(637, 10);  --Rightmost point on the X axis
constant Bird_Y_Min    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(3, 10);   --Topmost point on the Y axis
constant Bird_Y_Max    : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(477, 10);  --Bottommost point on the Y axis
                              
constant Bird_X_Step   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(2, 10);  --Step size on the X axis
constant Bird_Y_Step   : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(1, 10);  --Step size on the Y axis


signal launched : std_logic := '0';	-- Not started moving by default
signal abs_angle : std_logic_vector(9 downto 0);

-- Used to store which pigs are dead:
signal which_pigs_sig : std_logic_vector(2 downto 0) := "000";

-- Used to store velocity components:
signal vel_x, vel_y : std_logic_vector(8 downto 0) := "000000000";

-- Used to add speed downwards due to gravity every 500ms:
signal count : std_logic_vector(3 downto 0) := x"0";

begin
  Bird_Size <= CONV_STD_LOGIC_VECTOR(10, 10); -- assigns the value 4 as a 10-digit binary number for the bird size

Move_Bird: process(Reset, frame_clk, Bird_Size)
	begin
		if (M = '0') then
			if(Reset = '1') then   --Asynchronous Reset
				vel_y <= "000000000";--Bird_Y_Step;
				vel_x <= "000000000";--Bird_X_Step;
				Bird_Y_Pos <= Bird_Y_Start & "00000";
				Bird_X_pos <= Bird_X_Start & "00000";
				launched <= '0';
				hit <= '0';
				miss <= '0';
				which_pigs_sig <= "000";
			end if;
		elsif (M = '1') then
			if(Reset = '1') then   --Asynchronous Reset
				vel_y <= "000000000";--Bird_Y_Step;
				vel_x <= "000000000";--Bird_X_Step;
				Bird_Y_Pos <= Bird_Y_Start & "00000";
				Bird_X_pos <= Bird_X_Start & "00000";
				launched <= '0';
				hit <= '0';
				miss <= '0';
				which_pigs_sig <= "000";
			elsif(rising_edge(frame_clk)) then			
				-- At start, launch with vel_y = Angle
				if (launched = '0') then
					Bird_Y_Pos <= Bird_Y_Start & "00000";
					Bird_X_pos <= Bird_X_Start & "00000";
					vel_x <= init_vel_x;
					miss <= '0';
					hit <= '0';	
					which_pigs_sig <= which_pigs_sig;
					count <= count + '1';
					if (up = '0') then
						vel_y <= init_vel_y;
					else
						vel_y <= not(init_vel_y) + 1;
					end if;
					launched <= '1';
				-- Ground/bottom edge:
				elsif   (Bird_Y_Pos(14 downto 5) + Bird_Size >= Bird_Y_Max) then -- Bird is at the bottom edge, BOUNCE!
					vel_y <= "1" & not(vel_y(8 downto 1)); --absorb half vel_y upon each bounce.
					if (vel_y < "001000000") then	-- Reset when done bouncing
						miss <= '1';
						launched <= '0';
						Bird_Y_Pos <= Bird_Y_Start & "00000";
						Bird_X_pos <= Bird_X_Start & "00000";
						vel_y <= "000000000";
						vel_x <= "000000000";
					else							-- Bounce
						miss <= '0';
						Bird_Y_Pos <= (Bird_Y_Max - Bird_Size -5) & "00000";
						Bird_X_Pos <= Bird_X_Pos;
					end if;					
					hit <= '0';
					which_pigs_sig <= which_pigs_sig;
				elsif (Bird_X_Pos(14 downto 5) + Bird_Size >= Bird_X_Max) then -- Bird is at the right edge, MISS!
					miss <= '1';
					hit <= '0';
					launched <= '0';
					Bird_Y_Pos <= Bird_Y_Start & "00000";
					Bird_X_pos <= Bird_X_Start & "00000";
					vel_y <= "000000000";
					vel_x <= "000000000";
					which_pigs_sig <= which_pigs_sig;
				elsif(Bird_X_Pos(14 downto 5) - Bird_Size <= Bird_X_Min) then  -- Bird is at the left edge, MISS!
					miss <= '1';
					hit <= '0'; 
					launched <= '0';
					Bird_Y_Pos <= Bird_Y_Start & "00000";
					Bird_X_pos <= Bird_X_Start & "00000";  	
					vel_y <= "000000000";
					vel_x <= "000000000";
					which_pigs_sig <= which_pigs_sig;									
				else
					miss <= '0';
					
					------------------------
					------------------------
					-- Here we will have to check if the bird has hit a pig, and if
					-- so then report which pig so that it may be deleted.
					------------------------
					------------------------
					
					if ( which_pigs_sig(0)='0' and (Bird_X_Pos(14 downto 5) >= (Pig1X - Pig1_Size)) and (Bird_X_Pos(14 downto 5) <= (Pig1X + Pig1_Size)) and (Bird_Y_Pos(14 downto 5) >= (Pig1Y - Pig1_Size)) and (Bird_Y_Pos(14 downto 5) <= (Pig1Y + Pig1_Size)) )  then
							-- Piggie ONE hit!
							hit <= '1';
							which_pigs_sig <= which_pigs_sig or "001";
							launched <= '0';
							Bird_Y_Pos <= Bird_Y_Start & "00000";
							Bird_X_pos <= Bird_X_Start & "00000";
							vel_y <= "000000000";
							vel_x <= "000000000";
					elsif ( which_pigs_sig(1)='0' and (Bird_X_Pos(14 downto 5) >= (Pig2X - Pig2_Size)) and (Bird_X_Pos(14 downto 5) <= (Pig2X + Pig2_Size)) and (Bird_Y_Pos(14 downto 5) >= (Pig2Y - Pig2_Size)) and (Bird_Y_Pos(14 downto 5) <= (Pig2Y + Pig2_Size)) )  then
							-- Piggie TWO hit!
							hit <= '1';
							which_pigs_sig <= which_pigs_sig or "010";
							launched <= '0';
							Bird_Y_Pos <= Bird_Y_Start & "00000";
							Bird_X_pos <= Bird_X_Start & "00000";
							vel_y <= "000000000";
							vel_x <= "000000000";
					elsif ( which_pigs_sig(2)='0' and (Bird_X_Pos(14 downto 5) >= (Pig3X - Pig3_Size)) and (Bird_X_Pos(14 downto 5) <= (Pig3X + Pig3_Size)) and (Bird_Y_Pos(14 downto 5) >= (Pig3Y - Pig3_Size)) and (Bird_Y_Pos(14 downto 5) <= (Pig3Y + Pig3_Size)) )  then
							-- Piggie THREE hit!
							hit <= '1';
							which_pigs_sig <= which_pigs_sig or "100";
							launched <= '0';
							Bird_Y_Pos <= Bird_Y_Start & "00000";
							Bird_X_pos <= Bird_X_Start & "00000";
							vel_y <= "000000000";
							vel_x <= "000000000";
					else					
					-- Let velocity down increase at a rate of 2px/s from gravity
					-- or 1px/s every 500ms. Assuming a 30Hz clock, that is one px/s
					-- every 15 falling edges
					--count <= count + '1';
						if ( vel_y < "011111101" or vel_y > "011111111") then
							vel_y <= vel_y + x"2";
							if (vel_y(8) = '0') then
								Bird_Y_pos <= Bird_Y_pos + vel_y; -- Update bird position 
							else
								Bird_Y_pos <= Bird_Y_pos + ("111111" & vel_y);
							end if;
							Bird_X_pos <= Bird_X_pos + vel_x;
						else
							if (vel_y(8) = '0') then
								Bird_Y_pos <= Bird_Y_pos + vel_y; -- Update bird position 
							else
								Bird_Y_pos <= Bird_Y_pos + ("111111" & vel_y);
							end if;
							Bird_X_pos <= Bird_X_pos + vel_x;
						end if;
						hit <= '0';
						which_pigs_sig <= which_pigs_sig;
					end if;					
					
					vel_x <= vel_x; -- Bird is somewhere in the middle, don't bounce, just keep moving
				end if;     
			end if;       
		end if;
	end process Move_Bird;

	which_pigs <= which_pigs_sig;
	BirdX <= Bird_X_Pos(14 downto 5);
	BirdY <= Bird_Y_Pos(14 downto 5);
	BirdS <= Bird_Size;
end Behavioral;      
