class Encode

	def initialize(link)
		@link = link
		@thongdiep
		@data_input
		@list_byte = Array.new
		@dem = 0
		@data_output = Array.new
	end

	def GomByte # 
		for i in 1..(@data_input.length/8) 
			byte = @data_input[0,8] # get from 0 
			@list_byte.push(byte)
			@data_input = @data_input[8..@data_input.length]  #Get from 8 to the end
		end
	end

	def ChenThongDiep(i)
		byte_array = @list_byte[i].chars
		byte_array[7]=@thongdiep[@dem]
		@dem += 1
		@list_byte[i] = byte_array.join
		
	end

	
	def encode
		begin

			@data_input = File.binread(@link) 	#open file 
			@data_input = @data_input.unpack("B*") #convert ASCII => Array binary (Array.length == 1)
			@data_input = @data_input.pop  # convert Array binary => string binary
			print "nhap vao thong diep : " # enter messages
			nhap = gets.chomp 
			@thongdiep = nhap.unpack("B*")	# string => binary data
			thongdiep1 = @thongdiep.pop.chars # binary data -> array char
			@thongdiep = thongdiep1
		
			GomByte() # 8 bit = 1 byte
			 for i in 54..@list_byte.length
			 	if @dem == @thongdiep.length
			 		@list_byte[i] = "00000000"
			 		@list_byte[i+1] ="00000000"
			 		@list_byte[i+2] = "00000000"
			 		break
			 	else 
			 		
			 		ChenThongDiep(i)
			 		
			 	end
			 end
			 image_hidden = @link.split("/")[2] # split string
			 image_hidden = image_hidden.split(".")[0]
			 image_hidden = "./Modified_Image/" + image_hidden + "_hidden.bmp"
			 @list_byte = @list_byte.join # Array byte (Array.length > 1 ) => string binary
			 @data_output.push(@list_byte) # string binay => Array binary (Array.length == 1)
			 File.open(image_hidden , 'wb') do|f| # write new file , with @data_output is Array binary (Array.length == 1) 
	  			f.write(@data_output.pack("B*")) 
				end
		rescue
			puts "File not found ! "
		end
	end
end



class Decode 
	def initialize(link)
		@link = link 
		@thongdiep =""
		@data_input
		@list_byte = Array.new
		@nguyenvan =""
	end

	def GomByte
		for i in 1..(@data_input.length/8)
			byte = @data_input[0,8]
			@list_byte.push(byte)
			
			@data_input = @data_input[8..@data_input.length]
		end
	end

	def TimThongDiep(byte)
		byte_array = byte.chars
		@thongdiep = @thongdiep + byte_array[7] 

	end

	 def GomTu
		
		for i in 1..(@thongdiep.length/8) 
			word = @thongdiep[0,8] # bat dau tu vi tri 0 , lay 8 phan tu (string)
			@nguyenvan = @nguyenvan + word.to_i(2).chr # 8 bit binary -> integer -> ASCII 
			@thongdiep = @thongdiep[8..@thongdiep.length] # bo di phan da lay
		end
	end

	def decode
		begin

			@data_input = File.binread(@link)
			@data_input = @data_input.unpack("B*")
			@data_input = @data_input.pop 
			GomByte()
			 for i in 54..@list_byte.length
			 	if @list_byte[i] == "00000000" && @list_byte[i+1] =="00000000" && @list_byte[i+2] =="00000000"
			 		break
			 	else 
			 		
			 		TimThongDiep(@list_byte[i])

			 	end
			 end
			 
			 GomTu()
			 puts "Messages : #{@nguyenvan}"
		rescue
			puts "File not found!"
		end
	end
end

menu = "1.Encode\n2.Decode"
puts menu
print "chon : "
chon = gets.chomp.to_i
case chon
when 1 
	puts "-- Original_Image :"
	system "ls ./Original_Image/"
	print "Nhap anh : "
	link = gets.chomp
	link = "./Original_Image/"+link
	encode = Encode.new(link)
	encode.encode
when 2
	puts "--Modified_Image :"
	system "ls ./Modified_Image/"
	print "Nhap anh : "
	link = gets.chomp
	link = "./Modified_Image/"+link
	decode = Decode.new(link)
	decode.decode
end

