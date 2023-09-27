---------------------------------------------------------------------------
--    Color_Mapper.vhd                                                   --
--    Stephen Kempf                                                      --
--    3-1-06                                                             --
--												 --
--    Modified by David Kesler - 7-16-08						 --
--                                                                       --
--    Spring 2013 Distribution                                             --
--                                                                       --
--    For use with ECE 385 Lab 9                                         --
--    University of Illinois ECE Department                              --
---------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity Color_Mapper is
   Port ( BirdX : in std_logic_vector(9 downto 0);
          BirdY : in std_logic_vector(9 downto 0);
          
          Pig1X, Pig1Y, Pig1_Size : in std_logic_vector(9 downto 0);
          Pig2X, Pig2Y, Pig2_Size : in std_logic_vector(9 downto 0);
          Pig3X, Pig3Y, Pig3_Size : in std_logic_vector(9 downto 0);
          
          which_pigs : in std_logic_vector(2 downto 0);
          
          DrawX : in std_logic_vector(9 downto 0);
          DrawY : in std_logic_vector(9 downto 0);
          Bird_size : in std_logic_vector(9 downto 0);
          Red   : out std_logic_vector(9 downto 0);
          Green : out std_logic_vector(9 downto 0);
          Blue  : out std_logic_vector(9 downto 0));
end Color_Mapper;

architecture Behavioral of Color_Mapper is

signal Bird_on, Pig1_on, Pig2_on, Pig3_on : std_logic;

begin

  Bird_on_proc : process (BirdX, BirdY, DrawX, DrawY, Bird_size)
  begin
  -- Old Bird: Generated square box by checking if the current pixel is within a square of length
  -- 2*Bird_Size, centered at (BirdX, BirdY).  Note that this requires unsigned comparisons, by using
  -- IEEE.STD_LOGIC_UNSIGNED.ALL at the top.
--   if ((DrawX >= BirdX - Bird_size) AND
--      (DrawX <= BirdX + Bird_size) AND
--      (DrawY >= BirdY - Bird_size) AND
--      (DrawY <= BirdY + Bird_size)) then

  -- New Bird: Generates (pixelated) circle by using the standard circle formula.  Note that while 
  -- this single line is quite powerful descriptively, it causes the synthesis tool to use up three
  -- of the 12 available multipliers on the chip!  It also requires IEEE.STD_LOGIC_SIGNED.ALL for
  -- the signed multiplication to operate correctly.
    if ((((DrawX - BirdX) * (DrawX - BirdX)) + ((DrawY - BirdY) * (DrawY - BirdY))) <= (Bird_Size*Bird_Size)) then
      Bird_on <= '1';
    else
      Bird_on <= '0';
    end if;
  end process Bird_on_proc;
  
  -- Now do the same for pig1
	Pig1_on_proc : process (Pig1X, Pig1Y, DrawX, DrawX, DrawY, Pig1_size)
	begin
		if ((((DrawX - Pig1X) * (DrawX - Pig1X)) + ((DrawY - Pig1Y) * (DrawY - Pig1Y))) <= (Pig1_Size*Pig1_Size)) then
			if (which_pigs(0)='0') then
				Pig1_on <= '1';
			end if;
		else
		  Pig1_on <= '0';
		end if;
	end process;

   --Now do the same for pig2
	Pig2_on_proc : process (Pig2X, Pig2Y, DrawX, DrawX, DrawY, Pig2_size)
	begin
		if ((((DrawX - Pig2X) * (DrawX - Pig2X)) + ((DrawY - Pig2Y) * (DrawY - Pig2Y))) <= (Pig2_Size*Pig2_Size)) then
			if (which_pigs(1)='0') then
				Pig2_on <= '1';
			end if;
		else
		  Pig2_on <= '0';
		end if;
	end process;
	
   --Now do the same for pig3
	Pig3_on_proc : process (Pig3X, Pig3Y, DrawX, DrawX, DrawY, Pig3_size)
	begin
		if ((((DrawX - Pig3X) * (DrawX - Pig3X)) + ((DrawY - Pig3Y) * (DrawY - Pig3Y))) <= (Pig3_Size*Pig3_Size)) then
			if (which_pigs(2)='0') then
				Pig3_on <= '1';
			end if;
		else
		  Pig3_on <= '0';
		end if;
	end process;	

  RGB_Display : process (Bird_on, DrawX, DrawY)
    variable GreenVar, BlueVar : std_logic_vector(22 downto 0);
  begin
    if (Bird_on = '1') then -- RED bird is our Angry Bird
      Red <= "1111111111";
      Green <= "0000000000";
      Blue <= "0000000000";
      
     -- GREEN means piggies 
     elsif (Pig1_on = '1') then 
		Red <= "0000000000";
		Green <= "1000111111";
		Blue <= "0000000000";    
	 elsif (Pig2_on = '1') then 
		Red <= "0000000000";
		Green <= "1000111111";
		Blue <= "0000000000";    
     elsif (Pig3_on = '1') then
 		Red <= "0000000000";
		Green <= "1000111111";
		Blue <= "0000000000";    
	-- Draw a stone block for pig 2 to sit on
	elsif ( (DrawX >= (Pig2X - 8)) and (DrawX < (Pig1X - 5)) and (DrawY > (Pig2Y + Pig2_Size)) ) then	
		Red <= "0101000100";
		Green <= "0101000100";
		Blue <= "0101000100";  
	-- Draw a wooden trunk to sit on for pig 1
	elsif ( (DrawX >= (Pig1X - 5)) and (DrawX <= (Pig1X + 5)) and (DrawY > (Pig1Y + Pig1_Size)) ) then	
		Red <= "1000000000";
		Green <= "0100000000";
		Blue <= "0000100000";   
    elsif ( DrawY <= 400 ) then          -- sky background
		Red <= "0000000000";
		Green <= "1011111111";
		Blue <= "1111111111";  
    else         				-- land background
		Red <= "1111111111";
		Green <= "1110111111";
		Blue <= "1011111111"; 		
		
--    else         -- gradient background
--      Red   <= DrawX(9 downto 0);
--      Green <= DrawX(9 downto 0);
--      Blue  <= DrawX(9 downto 0);     
      
    end if;
  end process RGB_Display;

end Behavioral;
