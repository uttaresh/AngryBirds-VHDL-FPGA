/* Function to print out the VHDL if statements to output the value of the
 * sines and cosines for the given angle in degrees.
 *
*/
#include<math.h>
#include<stdio.h>

#define PI 3.14159265

//Function to calculate the result of ten raised to a certain number
int pow_ten(int power){
    int ans=1;
    for (int i=0;i<power;i++)
        ans *= 10;

    return ans;
}

//Function to take in an int and return an int value in the binary
//representation of the number consisting of 0's and 1's
int integer_to_binary(int val){

    int result=0;

    // I am particulary glad I thought of this little bit
    // manipulation trick to determine whether a digit
    // should be 0 or 1
    for (int i=0;i<11;i++){
        if ( (val>>i)%2 )
            result += pow_ten(i);
    }
    return result;
}

//Main function
int main(){
    double param, sin_val, cos_val;

    //For every integer angle from 0 to 90, do this
    for (param=0.0;param<=90; param = param + 3.0){

        //Calculate sine and cosine values
        sin_val = 32*sin(param*PI/180);
        cos_val = 32*cos(param*PI/180);

        //Convert the numbers to binary and print required VHDL code:
        printf("\nelsif (precise_angle=x\"%02X\" or precise_angle=x\"%02X\") then\n\tsin_val <= \"%06d\";\n\tcos_val <= \"%06d\";\n\tdisp_angle <= x\"%02d\";",(int)param,((int)-param)%0xFF, integer_to_binary((int)sin_val),integer_to_binary((int)cos_val),(int)param);
    }

    //Exit program
    return 0;
}