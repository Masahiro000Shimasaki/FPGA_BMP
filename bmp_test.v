`timescale 1ns/1ns

`define SOURCE_FILE       "./test.bmp"
`define RESULT_FILE       "./result.bmp"

module bmp_test;
  parameter STEP = 100;
  integer fp_src, fp_dst;	//  file pointer
  integer i;
  integer x, y;
  reg [7:0] header [0:53];	// BMP Header
  integer pixel_data;
  reg	clk;
  
  // Clock generator
  initial begin
    clk <= 0;
    #150;
    forever #(STEP/2)
      clk <= ~clk;
  end

  initial begin
	  //  Open source file
    fp_src = $fopen(`SOURCE_FILE, "rb");
    if(!fp_src) begin
      $display("Src file open error.\n");
      $stop;
    end
    //  Open destination file
    fp_dst = $fopen(`RESULT_FILE, "wb");
    if(!fp_dst) begin
      $display("Destination file open error.\n");
      $fclose(fp_src);
      $stop;
    end
    
	  // header
    for(i = 0; i < 54; i = i+1) begin
      header[i] = $fgetc(fp_src);
			$fwrite(fp_dst, "%c", header[i]);
    end
    
    #1000;
    for(y = 0; y < 480; y = y + 1) begin
      for(x = 0; x < 640; x = x + 1) begin
        #STEP;
        read_from_src(pixel_data);
        write_to_dst(pixel_data);
      end
    end
    
    $fclose(fp_src);
    $fclose(fp_dst);
    $stop;
  end

// Define task
task read_from_src;
  output [7:0] DATA;
  integer c;
  begin
    c = $fgetc(fp_src);
    c = c + $fgetc(fp_src);
    c = c + $fgetc(fp_src);
    c = c / 3;
    DATA = c;
  end
endtask

task write_to_dst;
  input [7:0] DATA;
  integer c;
  begin
    c = DATA;
    $fwrite (fp_dst, "%c", c);
    $fwrite (fp_dst, "%c", c);
    $fwrite (fp_dst, "%c", c);
  end
endtask

endmodule

