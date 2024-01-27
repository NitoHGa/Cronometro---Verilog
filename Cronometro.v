module Cronometro(
	input clk,	//Señal de reloj 50MHz
	input rst, stop, //Pulso de reset y stop
	output [7:0]an,seg	//Salida a anodos y segmentos
	);
	 
	//Declaración de registros
	reg [7:0]data[0:9]; //vector de 10 de 3 bits 'data'
	reg [1:0]barrido;
	reg [25:0]cnt; //contador para actualizacion de datos
	reg [3:0]cnt1, cnt2, cnt3, cnt4; //Contadores 0-9
	reg senal;	//Señal de actualización
	reg [7:0]anodos, segmentos;
	//Inicializacion de registros
	initial begin
		barrido = 0;
		cnt = 0;
		cnt1 = 0; cnt2 = 0; cnt3 = 0; cnt4 = 0;
		senal = 0;
		segmentos = 0;
		anodos = 0;
	end 
	//Bloque de memoria
	initial begin	
					  //pgfedcba
		data[0] = 8'b11000000; //0
		data[1] = 8'b11111001; //1
		data[2] = 8'b10100100; //2
		data[3] = 8'b10110000; //3.
		data[4] = 8'b10011001; //4
		data[5] = 8'b10010010; //5
		data[6] = 8'b10000011; //6.
		data[7] = 8'b11111000; //7
		data[8] = 8'b10000000; //8
		data[9] = 8'b10011000; //9
	end
		
	 //Bloque de instrucciones para señal de actualización
	 always@(posedge clk) begin
		if(cnt == 25_000) begin
			senal <= ~senal; //Pulso de señal de actualización
			cnt <= 0;
		end
		else cnt <= cnt + 1;
	 end
	 //Bloque de instrucciones para contador 0-9999
	 always@(posedge senal) begin
		case(rst)
			0: begin	//Colocamos todo en cero
				cnt1 <= 0;
				cnt2 <= 0;
				cnt3 <= 0;
				cnt4 <= 0;
			end
			1: begin
				if(stop == 1) begin
					if(cnt1 == 9) begin
						cnt1 <= 0;	//Reinciamos contador 1
						if(cnt2 == 9) begin
							cnt2 <= 0; //Reinciamos contador 2
							if(cnt3 == 9) begin
								cnt3 <= 0; //Reinciamos contador 3
								if(cnt4 == 9) begin
									if(cnt1 == 9 && cnt2 == 9 && cnt3 == 9) begin
										cnt1 <= 9; cnt2 <= 9; //Detenemos todo en 9999
										cnt3 <= 9; cnt4 <= 9;
									end
								end
								else cnt4 <= cnt4 + 1;	//Incrementamos con cada flanco de subida.
							end
							else cnt3 <= cnt3 + 1; //Incrementamos con cada flanco de subida.
						end
						else cnt2 <= cnt2 + 1; //Incrementamos con cada flanco de subida.
					end
					else cnt1 <= cnt1 + 1; //Incrementamos con cada flanco de subida.
				end
				else begin	//Mantenemos en el valor en el que se preciona
					cnt1 <= cnt1; cnt2 <= cnt2;
					cnt3 <= cnt3; cnt4 <= cnt4;
				end
			end
		endcase
	 end
	 //Bloque de instrucciones para activacion de displays
	 always@(posedge senal) begin
		//Pasamos de un display a otro
		barrido <= (barrido == 2'b11) ? 2'b00 : barrido + 1'b1;
		case(barrido)
			0: begin // Display 00000001
				anodos <= 8'b11111110; 
				segmentos <= data[cnt1];
			end
			1: begin // Display 00000010
				anodos <= 8'b11111101;
				segmentos <= data[cnt2];
			end
			2: begin // Display 00000100
				anodos <= 8'b11111011;
				segmentos <= data[cnt3];
			end
			3: begin // Display 00001000
				anodos <= 8'b11110111;
				segmentos <= data[cnt4];
			end
		endcase
	 end
	 //Asignacion de variables fisicas
	 assign an = anodos;
	 assign seg = segmentos;
endmodule